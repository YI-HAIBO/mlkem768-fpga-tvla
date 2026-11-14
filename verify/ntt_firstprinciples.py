"""
First-principles 256-point NTT over Zq, q = 3329 (CRYSTALS-Kyber ring).

NO reference implementation is used anywhere in this file.  Everything is
derived from the definition:

    Rq = Zq[X] / (X^256 + 1)

The roots of X^256 + 1 in Zq are  17^(2i+1),  i = 0..255,
because 17 is a primitive 512th root of unity (17^256 == -1 mod q).

A correct NTT is therefore an evaluation:

    ntt(f)[i] = f( 17^(2i+1) )      (up to a fixed global Montgomery scale)

That is the ONLY specification.  From it we derive:

  (1) ntt(e_j)[i] = 17^((2i+1) j)   -- geometric in i for fixed j
  (2) ntt is linear over Zq
  (3) DECISIVE:  ntt(a * b mod X^256+1) == ntt(a) .* ntt(b)   componentwise,
      because evaluation turns ring multiplication into pointwise multiplication.
      (3) needs no zeta table, no butterfly schedule, no reference at all.

A Cooley-Tukey (decimation-in-time) schedule that realises (1)-(3) is then
written down and checked against (1)-(3).  If a candidate schedule fails (3)
it is rejected, whatever it claims to be a port of.
"""

Q = 3329
N = 256
ROOT = 17                     # primitive 512th root of unity
MONT = 2285                   # R mod q, R = 2^16


def qroot():
    """Sanity: 17 must be a primitive 512th root of unity mod q."""
    assert pow(ROOT, 256, Q) == Q - 1, "17^256 != -1 mod q"
    assert pow(ROOT, 512, Q) == 1
    # and no smaller exponent than 512 gives 1
    for d in (1, 2, 4, 8, 16, 32, 64, 128, 256):
        assert pow(ROOT, d, Q) != 1 or d == 512
    return True


# ---------------------------------------------------------------------------
# Oracle: evaluation at the 256 roots of X^256 + 1.  O(N^2), no shortcuts.
# ---------------------------------------------------------------------------

def roots():
    return [pow(ROOT, 2 * i + 1, Q) for i in range(N)]


def eval_ntt(x):
    """ntt(f)[i] = sum_j x[j] * r[i]^j,  with r[i] = 17^(2i+1)."""
    xs = [(v % Q) for v in x]
    out = []
    for i in range(N):
        r = roots()[i]
        s, p = 0, 1
        for j in range(N):
            s += xs[j] * p
            p = p * r % Q
        out.append(s % Q)
    return out


# ---------------------------------------------------------------------------
# Candidate schedule: Cooley-Tukey DIT, 8 stages, twiddle precomputed.
# ---------------------------------------------------------------------------

def ct_ntt(x, stages):
    """
    Generic radix-2 DIT Cooley-Tukey NTT over Zq (NOT Montgomery form).

    stages: list of (num_blocks, block_half, twiddle_base)
      - stage s: m = block_half butterflies per block,
        twiddle for butterfly i is  W ^ (i * m * (number_of_butterflies_total_per_block_row))
    We generate it from the evaluation definition instead of guessing.
    """
    y = [v % Q for v in x]
    for (nb, m, tw) in stages:
        y2 = [0] * N
        for b in range(nb):
            base = b * (2 * m)
            for i in range(m):
                u = y[base + i]
                v = y[base + i + m] * tw[i] % Q
                y2[base + i] = (u + v) % Q
                y2[base + i + m] = (u - v) % Q
        y = y2
    return y


def derive_stages():
    """
    Derive the Cooley-Tukey schedule directly from the evaluation map.

    Decimation in time:  X^N + 1 with N = 2M.  Since (X-M)(X+M) = X^2 - M^2
    and, working in the quotient by X^N+1, we split
        f(X) = f_even(X^2) + X * f_odd(X^2)
    and the 256 roots of X^256+1 pair up as {r, -r}.  So

        f(r) = f_even(r^2) + r * f_odd(r^2)
        f(-r) = f_even(r^2) - r * f_odd(r^2)

    which is exactly one stage of butterflies with twiddle r, followed by two
    independent 128-point transforms on the r^2 lattice (the 128 roots of
    X^128 + 1).  Recursing gives 8 stages.

    Roots of X^(2^k)+1 are 17^( 2^(9-k) * odd ).  At stage s (s = 0..7) we
    combine two length-2^(7-s) transforms, the twiddles being the 2^(7-s)
    roots of X^(2^(8-s)) + 1, which are  17^( 2^(8-s) * t ) for t = 0..2^(7-s)-1.
    """
    stages = []
    for s in range(8):
        m = 1 << (7 - s)                 # butterflies per block
        nb = 1 << s                      # number of blocks
        tw = [pow(ROOT, 2 ** (8 - s) * t, Q) for t in range(m)]
        stages.append((nb, m, tw))
    return stages


def ct_ntt_derived(x):
    return ct_ntt(x, derive_stages())


# ---------------------------------------------------------------------------
# The "7-layer" candidate (the schedule the RTL / fetched reference use):
# same butterfly, but only stages for distance 128,64,32,16,8,4,2.
# ---------------------------------------------------------------------------

def ct_ntt_7stage(x):
    stages = []
    for s in range(7):
        m = 1 << (7 - s)
        nb = 1 << s
        # twiddles from the same root lattice as the 8-stage version
        tw = [pow(ROOT, 2 ** (8 - s) * t, Q) for t in range(m)]
        stages.append((nb, m, tw))
    return ct_ntt(x, stages)


# ---------------------------------------------------------------------------
# Decisive tests
# ---------------------------------------------------------------------------

def anticirc_conv(a, b):
    """Product in Rq = Zq[X]/(X^256+1), naive O(N^2)."""
    c = [0] * N
    for i in range(N):
        if a[i] == 0:
            continue
        ai = a[i] % Q
        for j in range(N):
            if b[j] == 0:
                continue
            bj = b[j] % Q
            if i + j < N:
                c[i + j] = (c[i + j] + ai * bj) % Q
            else:
                c[i + j - N] = (c[i + j - N] - ai * bj) % Q
    return c


def ring_homomorphism_check(ntt, trials=6, label=""):
    """(3): ntt(a*b) == ntt(a) .* ntt(b) componentwise mod q."""
    rng_state = [0x9E3779B9]

    def rnd():
        rng_state[0] = (rng_state[0] + 0x6D2B79F5) & 0xFFFFFFFF
        t = rng_state[0]
        t = ((t ^ (t >> 15)) * (t | 0x7CBD5CA1)) & 0xFFFFFFFF
        t = ((t ^ (t >> 12)) * (t | 0x4CEB9F55)) & 0xFFFFFFFF
        return t ^ (t >> 15)

    bad = 0
    total = 0
    per_trial = []
    for _ in range(trials):
        a = [rnd() % Q for _ in range(N)]
        b = [rnd() % Q for _ in range(N)]
        ca, cb, cc = ntt(a), ntt(b), ntt(anticirc_conv(a, b))
        mism = sum(1 for i in range(N) if ca[i] * cb[i] % Q != cc[i])
        per_trial.append(mism)
        bad += mism
        total += N
    return bad, total, per_trial


def main():
    print("=" * 74)
    print("FIRST-PRINCIPLES NTT VALIDATION  (q=3329, N=256, root=17)")
    print("=" * 74)
    print()
    print("[0] 17 is a primitive 512th root of unity mod q :", qroot())

    print()
    print("[1] ORACLE  eval_ntt :  evaluation at the 256 roots of X^256+1")
    e0 = [0] * N
    e0[0] = 1
    y = eval_ntt(e0)
    print("    eval_ntt(e_0) all equal 1 :", set(y) == {1})
    e1 = [0] * N
    e1[1] = 1
    y1 = eval_ntt(e1)
    print("    eval_ntt(e_1)[0..3]      :", y1[:4], "(= 17, 17^3, 17^5, ...)")
    b, t, pt = ring_homomorphism_check(eval_ntt, 4, "oracle")
    print("    ring homomorphism  ntt(a*b) == ntt(a).ntt(b) :",
          "%d/%d" % (t - b, t), "(per trial mismatches:", pt, ")")

    print()
    print("[2] DERIVED 8-stage Cooley-Tukey vs oracle")
    e0y = ct_ntt_derived(e0)
    print("    ct_ntt_derived(e_0) all equal 1 :", set(e0y) == {1})
    diffs = 0
    for trial in range(4):
        a = [pow(3, trial + 1, Q) * (i + 1) for i in range(N)]
        d = sum(1 for i in range(N) if ct_ntt_derived(a)[i] != eval_ntt(a)[i])
        diffs += d
    print("    mismatches vs oracle over 4 polys:", diffs, "/ 1024")
    b, t, pt = ring_homomorphism_check(ct_ntt_derived, 4, "ct8")
    print("    ring homomorphism :", "%d/%d" % (t - b, t), "(per trial:", pt, ")")

    print()
    print("[3] 7-stage candidate (RTL / fetched reference schedule)")
    e0y = ct_ntt_7stage(e0)
    print("    7stage(e_0) : first 12 =", e0y[:12])
    print("    distinct values in 7stage(e_0):", len(set(e0y)))
    b, t, pt = ring_homomorphism_check(ct_ntt_7stage, 4, "ct7")
    print("    ring homomorphism :", "%d/%d" % (t - b, t), "(per trial:", pt, ")")

    print()
    print("[4] What does the 7-stage transform actually compute?")
    a = [(i * 37) % Q for i in range(N)]
    full = ct_ntt_derived(a)
    s7 = ct_ntt_7stage(a)
    even = [a[2 * i] for i in range(128)]
    odd = [a[2 * i + 1] for i in range(128)]
    # 128-point NTT of a subsequence, using roots of X^128+1 = 17^(2^8 * t)=17^(256t)
    def ntt128(z):
        zz = [v % Q for v in z]
        for s in range(7):
            m = 1 << (6 - s)
            nb = 1 << s
            tw = [pow(ROOT, 256 * t % 512, Q) for t in range(m)]
            y2 = [0] * 128
            for bb in range(nb):
                base = bb * (2 * m)
                for i in range(m):
                    u = zz[base + i]
                    v = zz[base + i + m] * tw[i] % Q
                    y2[base + i] = (u + v) % Q
                    y2[base + i + m] = (u - v) % Q
            zz = y2
        return zz
    de, do = ntt128(even), ntt128(odd)
    inter = [0] * N
    for i in range(128):
        inter[2 * i] = de[i]
        inter[2 * i + 1] = do[i]
    same = sum(1 for i in range(N) if s7[i] == inter[i])
    print("    7stage == interleaved(NTT128(even), NTT128(odd)) :", same, "/ 256")
    same2 = sum(1 for i in range(N) if s7[i] == full[i])
    print("    7stage == full 256-point NTT                     :", same2, "/ 256")
    print("    7stage is injective? (12 distinct inputs -> 12 images)")
    imgs = []
    for k in range(12):
        imgs.append(tuple(ct_ntt_7stage([(i * k * 13) % Q for i in range(N)])))
    print("      distinct images:", len(set(imgs)), "/ 12")

    print()
    print("=" * 74)
    print("VERDICT")
    print("=" * 74)


if __name__ == "__main__":
    main()
