# =============================================================================
# Golden model for B3 tvla_online.v (fixed-vs-random Welch T-test, TVLA)
# -----------------------------------------------------------------------------
# RTL decision (all integer, division-free, population variance, n = 2^k):
#     S_i = sum of group i samples, Q_i = sum of squares, n = 2^k
#     D   = n*(Q1+Q2) - S1^2 - S2^2
#     d   = S1 - S2
#     t^2 = n * d^2 / D
#     leak <=> t^2 > 4.5^2 = 20.25  <=>  4*n*d^2 > 81*D      (shift form:
#             d^2 << (k+2) > 81*D since n = 2^k)
#     degenerate D == 0:  leak <=> d != 0      (constant groups)
#
# This script builds the exact TB stream generators, computes the float t,
# the integer-formula decision, and reports the two borderline stream pairs
# that straddle |t| = 4.5 with the smallest margin.
# =============================================================================
import math

N_LOG2 = 12
N = 1 << N_LOG2
THRESH = 4.5


def galois8(x):
    # 8-bit Galois LFSR, taps 0xB8, nonzero state never reaches 0
    if x & 1:
        return (x >> 1) ^ 0xB8
    return x >> 1


def lfsr_stream(seed, count):
    x = seed & 0xFF
    out = []
    for _ in range(count):
        out.append(x)
        x = galois8(x)
    return out


def stats(samples):
    n = len(samples)
    s = sum(samples)
    q = sum(v * v for v in samples)
    mu = s / n
    var = q / n - mu * mu          # population variance (RTL form)
    return s, q, mu, var


def rtl_decision(s1, q1, s2, q2):
    d = s1 - s2
    D = (N * (q1 + q2)) - s1 * s1 - s2 * s2
    if D == 0:
        return d != 0, d, D
    lhs = (d * d) << (N_LOG2 + 2)      # 4 * n * d^2
    rhs = 81 * D
    return lhs > rhs, d, D


def welch_t(s1, q1, s2, q2):
    mu1 = s1 / N
    mu2 = s2 / N
    var1 = q1 / N - mu1 * mu1
    var2 = q2 / N - mu2 * mu2
    v = (var1 + var2) / N
    if v == 0:
        return float('inf') if mu1 != mu2 else 0.0
    return (mu1 - mu2) / math.sqrt(v)


def report(name, fx, rx):
    s1, q1, _, _ = stats(fx)
    s2, q2, _, _ = stats(rx)
    leak, d, D = rtl_decision(s1, q1, s2, q2)
    t = welch_t(s1, q1, s2, q2)
    print(f"{name}: d={d} D={D} t={t:+.4f} |t|={abs(t):.4f} "
          f"rtl_leak={leak} float_leak={abs(t) > THRESH} "
          f"agree={leak == (abs(t) > THRESH)}")
    return t, leak


if __name__ == "__main__":
    # ---- T1: two LFSR streams, different seeds (same distribution) --------
    a = lfsr_stream(0x01, N)
    b = lfsr_stream(0x5A, N)
    report("T1 lfsr-vs-lfsr", a, b)

    # ---- T2: constant fixed group vs LFSR random group --------------------
    report("T2 const255-vs-lfsr", [0xFF] * N, b)

    # ---- borderline search: F = 2048x0 + 2048x2 ; R = z zeros + t twos -----
    print("\nborderline search (F fixed 2048x0+2048x2):")
    prev = None
    for twos in range(1840, 1870):
        zeros = N - twos
        fx = [0] * 2048 + [2] * 2048
        rx = [0] * zeros + [2] * twos
        t, leak = report(f"  twos={twos}", fx, rx)
        if prev is not None and prev[1] != leak:
            print(f"  >>> threshold crossed between twos={prev[0]} "
                  f"(leak={prev[1]}) and twos={twos} (leak={leak})")
        prev = (twos, leak)

    # ---- T6 degenerate: both groups constant ------------------------------
    print()
    report("T6 const0-vs-const0", [0] * N, [0] * N)
    report("T6 const127-vs-const0", [0x7F] * N, [0] * N)
