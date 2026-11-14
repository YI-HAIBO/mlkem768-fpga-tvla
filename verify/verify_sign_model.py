"""
Final model verification for the Dilithium SIGN-mode NTT (q=8380417, BW=27).

Checks the Python golden (ntt_model.RTLNTT) which the SIGN testbench embeds as
its expected values:

  1. invntt(ntt(f))            == f * R            (round trip, full INTT)
  2. invntt_raw(ntt(a) * ntt(b)) == (a*b) * C      (C = raw round-trip factor)
  3. invntt(ntt(a) * ntt(b))   == (a*b) * R        (gold standard: the full
                                                    INTT must deliver the
                                                    negacyclic convolution * R,
                                                    exactly what the RTL TB
                                                    Test 6 checks)
  4. no fixed-width overflow, no out-of-range Barrett output

Note on the constant C:  invntt_raw(ntt(e0)) = C * e0  with C = raw[0].
The hardware scale pass computes mont_reduce(raw * SCALE_K) = raw * SCALE_K * R^-1,
so SCALE_K must equal R^2 * C^-1 for the full INTT to yield f*R.
"""
import os, sys, random
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from ntt_model import RTLNTT, DILITHIUM_ZETAS, schoolbook

QD = 8380417
BW = 27
M, SH, SCALE_K = 33587228, 48, 49145
R_MOD = pow(2, BW, QD)
L = 8

# R=2^32 reference table -> R=2^27 Montgomery domain
Rinv_ref = pow(2, -32, QD)
zetas = [(((DILITHIUM_ZETAS[k] % QD) * Rinv_ref) % QD * R_MOD) % QD
         for k in range(256)]

d = RTLNTT(q=QD, bw=BW, layers=L, bm=M, bsh=SH, scale_k=SCALE_K)
rng = random.Random(20261022)


def to_signed(v):
    return [((x + (QD // 2)) % QD) - QD // 2 for x in v]


def red(v):
    return [((x % QD) + QD) % QD for x in v]


def rnd():
    return [rng.randint(0, QD - 1) for _ in range(256)]


print("Dilithium SIGN-mode NTT model check")
print("  q=%d  BW=%d  layers=%d  R=2^%d mod q=%d" % (QD, BW, L, BW, R_MOD))
print("  SCALE_K=%d  BARRETT_M=%d  BARRETT_SH=%d" % (SCALE_K, M, SH))
print()

# --- raw round-trip factor C -------------------------------------------------
e0 = [0] * 256
e0[0] = 1
fwd0, _ = d.ntt(zetas, to_signed(e0))
raw0, _ = d.invntt_raw(zetas, fwd0)
C = raw0[0] % QD
offdiag = [i for i in range(1, 256) if raw0[i] % QD != 0]
print("raw round-trip factor C = %d   (off-diagonal non-zero: %d)" % (C, len(offdiag)))
scale_implied = (pow(R_MOD, 2, QD) * pow(C, -1, QD)) % QD
print("SCALE_K implied by C = %d   (RTL uses %d)  -> %s"
      % (scale_implied, SCALE_K, "MATCH" if scale_implied == SCALE_K else "MISMATCH"))
print()

# --- 1. round trip ----------------------------------------------------------
ok1 = 0
IT = 60
for _ in range(IT):
    f = rnd()
    fwd, _ = d.ntt(zetas, to_signed(f))
    back, _ = d.invntt(zetas, fwd)
    if red(back) == [(f[i] * R_MOD) % QD for i in range(256)]:
        ok1 += 1
print(" 1. invntt(ntt(f)) == f*R                : %d/%d" % (ok1, IT))

# --- 2. invntt_raw of a plain pointwise product ----------------------------
ok2 = 0
for _ in range(IT):
    a = to_signed(rnd())
    b = to_signed(rnd())
    ta, _ = d.ntt(zetas, a)
    tb, _ = d.ntt(zetas, b)
    got = d.invntt_raw(zetas, [((ta[i] % QD) * (tb[i] % QD)) % QD
                               for i in range(256)])[0]
    if red(got) == [(s * C) % QD for s in schoolbook(a, b, QD)]:
        ok2 += 1
print(" 2. invntt_raw(ntt(a)*ntt(b)) == (a*b)*C : %d/%d" % (ok2, IT))

# --- 3. FULL INTT of a plain pointwise product (the TB Test 6 property) ----
ok3 = 0
for _ in range(IT):
    a = to_signed(rnd())
    b = to_signed(rnd())
    ta, _ = d.ntt(zetas, a)
    tb, _ = d.ntt(zetas, b)
    pt = [((ta[i] % QD) * (tb[i] % QD)) % QD for i in range(256)]
    back, _ = d.invntt(zetas, [p - QD if p > QD // 2 else p for p in pt])
    if red(back) == [(s * R_MOD) % QD for s in schoolbook(a, b, QD)]:
        ok3 += 1
print(" 3. invntt(ntt(a)*ntt(b)) == (a*b)*R     : %d/%d   <- gold standard" % (ok3, IT))

# --- 4. fqmul pointwise product (the real hardware path) --------------------
# fqmul(A,B) = A*B*R^-1, so the extra R^-1 cancels the R the full INTT adds:
# invntt(fqmul(ntt(a),ntt(b))) == (a*b)  -- the plain convolution, no R factor.
ok4 = 0
for _ in range(IT):
    a = to_signed(rnd())
    b = to_signed(rnd())
    ta, _ = d.ntt(zetas, a)
    tb, _ = d.ntt(zetas, b)
    pt = [d.fqmul(ta[i], tb[i]) for i in range(256)]
    back, _ = d.invntt(zetas, pt)
    if red(back) == [s for s in schoolbook(a, b, QD)]:
        ok4 += 1
print(" 4. invntt(fqmul(ntt(a),ntt(b))) == (a*b)  : %d/%d  <- real hardware path"
      % (ok4, IT))

# --- magnitude / width instrumentation --------------------------------------
d2 = RTLNTT(q=QD, bw=BW, layers=L, bm=M, bsh=SH, scale_k=SCALE_K)
peak = 0
for _ in range(200):
    f = rnd()
    fwd, mx = d2.ntt(zetas, to_signed(f))
    peak = max(peak, max(mx))
print()
print("  peak |intermediate| over 200 random forwards : %d  (signed-%d max = %d) -> %s"
      % (peak, BW - 1, (1 << (BW - 1)) - 1,
         "FITS" if peak <= (1 << (BW - 1)) - 1 else "OVERFLOW"))
print("  overflow events : %d" % len(d2.overflow))
print("  bad barrett     : %d" % len(d2.bad_barrett))
print()
allok = (ok1 == IT and ok2 == IT and ok3 == IT and ok4 == IT
         and not d2.overflow and not d2.bad_barrett and not offdiag
         and scale_implied == SCALE_K)
print("MODEL VERDICT: %s" % ("ALL PASS" if allok else "FAIL"))
