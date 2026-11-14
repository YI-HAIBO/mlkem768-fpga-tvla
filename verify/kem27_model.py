#!/usr/bin/env python3
"""KEM@BW=27 runtime constants + faithful Python model of unified_ntt.v.

Task 76 support: a single unified_ntt instance with the SIGN datapath
(BW=27, N_LAYERS=8) must also run Kyber (q=3329, 7 layers).  Because the
Montgomery radix becomes R = 2^BW = 2^27, the KEM constants cannot be reused
as-is; they have to be re-derived for the 2^27 radix:

  * QINV27  = 3329^{-1} mod 2^27
  * zeta27  = zeta16 * 2^11 mod 3329   (re-scaled Montgomery twiddles)
  * SCALE_K27 = 2^22 * 1441 mod 3329   (keeps INTT(NTT(f)) == f*2^27 mod q)
  * Barrett M=20159, SH=26 stay valid: M*a <= 2^26 * 2^14 << 2^53 (W_WIDTH=54)

This module also carries a cycle-exact Python re-implementation of the
unified_ntt datapath (butterfly schedule, Montgomery reduce split, Barrett,
INTT scale).  It is validated first against the SIGN configuration with the
known-good constants and the bit-exact gold_ntt vectors parsed from
sim/tb_unified_ntt_sign.v; once the model is proven faithful it is used to
prove the KEM@BW=27 configuration before any RTL/TB is touched.

Usage:  python verify/kem27_model.py        (runs validation, prints report)
        import kem27_model                  (reuse tables/constants)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
SIM = os.path.join(ROOT, "sim")

# ---------------------------------------------------------------------------
# Known-good SIGN configuration (compile-time, from dilithium_ntt.v)
# ---------------------------------------------------------------------------
SIGN = dict(q=8380417, qinv=58728449, scale_k=49145, bm=33587228, sh=48,
            bw=27, nl=8, n=256)
# Known-good KEM configuration at its native BW=16 (from tb_unified_ntt.v)
KEM16 = dict(q=3329, qinv=62209, scale_k=1441, bm=20159, sh=26,
             bw=16, nl=7, n=256)


def parse_array(path, name, width, count):
    """Parse `<name>[i] = <width>'dN;` assignments from a Verilog TB file."""
    txt = open(path, encoding="utf-8").read()
    pat = re.compile(r"%s\[(\d+)\]\s*=\s*%d'd(\d+)\s*;" % (re.escape(name), width))
    out = {}
    for m in pat.finditer(txt):
        out[int(m.group(1))] = int(m.group(2))
    assert len(out) == count, "parsed %d %s entries from %s, expected %d" % (
        len(out), name, os.path.basename(path), count)
    return [out[i] for i in range(count)]


def s_can(v, bw):
    """Canonical signed BW-bit interpretation of an integer."""
    m = 1 << bw
    v &= m - 1
    return v - m if v >= (m >> 1) else v


def load_tables():
    """Parse zeta/gold vectors out of the existing (trusted) testbenches."""
    kem_zeta16 = parse_array(os.path.join(SIM, "tb_unified_ntt.v"),
                             "kyber_zetas", 16, 128)
    sign_zeta = parse_array(os.path.join(SIM, "tb_unified_ntt_sign.v"),
                            "sign_zeta", 27, 256)
    f1 = parse_array(os.path.join(SIM, "tb_unified_ntt_sign.v"),
                     "test_input", 27, 256)
    gold_ntt = parse_array(os.path.join(SIM, "tb_unified_ntt_sign.v"),
                           "gold_ntt", 27, 256)
    # zetas are stored as two's-complement BW-bit values -> canonical signed
    kem_zeta16 = [s_can(v, 16) for v in kem_zeta16]
    sign_zeta = [s_can(v, 27) for v in sign_zeta]
    return kem_zeta16, sign_zeta, [s_can(v, 27) for v in f1], \
        [s_can(v, 27) for v in gold_ntt]


# ---------------------------------------------------------------------------
# Faithful model of the unified_ntt.v datapath
# ---------------------------------------------------------------------------
class NTTModel:
    def __init__(self, q, qinv, scale_k, bm, sh, bw, nl, zetas):
        self.q, self.qinv, self.scale_k, self.bm, self.sh = q, qinv, scale_k, bm, sh
        self.bw, self.nl, self.zetas = bw, nl, zetas
        self.logn = 8  # N = 256

    def mont_red(self, a):
        """RTL montgomery_reduce: (a - t*Q) >>> BW with t = (a_low*QINV) mod 2^BW."""
        bw, q, qinv = self.bw, self.q, self.qinv
        low = a & ((1 << bw) - 1)
        t = (low * qinv) & ((1 << bw) - 1)
        t_se = t - (1 << bw) if t >= (1 << (bw - 1)) else t
        r = (a - t_se * q) >> bw            # exact: a - t*q == 0 mod 2^bw
        return s_can(r, bw)

    def barrett(self, a):
        """RTL barrett_reduce: (M*a + 2^(SH-1)) >>> SH, then a - t*Q."""
        t = (self.bm * a + (1 << (self.sh - 1))) >> self.sh
        return s_can(a - t * self.q, self.bw)

    def run(self, c, inverse):
        bw, nl, z = self.bw, self.nl, self.zetas
        c = list(c)
        if not inverse:
            zc = 1
            for layer in range(nl):
                ln = 128 >> layer
                for b in range(1 << layer):
                    bs = b * (ln << 1)
                    zv = z[zc]
                    zc += 1
                    for j in range(ln):
                        ia, ib = bs + j, bs + j + ln
                        pa, pb = c[ia], c[ib]
                        t = self.mont_red(zv * pb)
                        c[ia] = s_can(pa + t, bw)
                        c[ib] = s_can(pa - t, bw)
            return [self.barrett(v) for v in c]
        else:
            zc = (1 << nl) - 1
            for layer in range(nl):
                ln = (256 >> nl) << layer
                nblk = (128 >> (8 - nl)) >> layer
                for b in range(nblk):
                    bs = b * (ln << 1)
                    zv = z[zc]
                    zc -= 1
                    for j in range(ln):
                        ia, ib = bs + j, bs + j + ln
                        pa, pb = c[ia], c[ib]
                        xd = s_can(pb - pa, bw)
                        sm = s_can(pa + pb, bw)
                        t = self.mont_red(zv * xd)
                        c[ia] = self.barrett(sm)
                        c[ib] = t
            return [self.mont_red(v * self.scale_k) for v in c]


def mod(v, q):
    return ((v % q) + q) % q


# ---------------------------------------------------------------------------
# KEM@BW=27 constant derivation
# ---------------------------------------------------------------------------
def kem27_constants(kem_zeta16):
    q = 3329
    qinv27 = pow(q, -1, 1 << 27)               # 3329^{-1} mod 2^27
    r_mod27 = (1 << 27) % q                    # R mod q for the new radix
    # SCALE_K27: keep the invariant INTT(NTT(f)) == f * 2^27 mod q.
    # BW=16: d*1441*2^-16 == f*2^16  ->  d == f*2^32*1441^-1.
    # BW=27 (same integer datapath values, same d): d*SCALE*2^-27 == f*2^27
    #   -> SCALE == 2^22 * 1441 mod q.
    scale_k27 = ((1 << 22) * 1441) % q
    # zeta27[i] = zeta16[i] * 2^11 mod q, canonical signed (|z| <= 1664)
    zeta27 = [s_can(mod(v * (1 << 11), q), 27) if v != 0 else 0
              for v in kem_zeta16]
    # Barrett: reuse M/SH from BW=16 (headroom at W_WIDTH=54 is ample)
    bm, sh = 20159, 26
    return dict(q=q, qinv=qinv27, scale_k=scale_k27, bm=bm, sh=sh,
                bw=27, nl=7, n=256, r_mod=r_mod27), zeta27


def validate():
    kem_zeta16, sign_zeta, f1, gold_ntt = load_tables()
    print("== tables parsed ==")
    print("  kyber_zetas(16b) x128, sign_zeta x256, f1 x256, gold_ntt x256")

    ok = True

    # ---- 1. model fidelity: SIGN config must reproduce gold_ntt bit-exactly
    m_sign = NTTModel(SIGN["q"], SIGN["qinv"], SIGN["scale_k"], SIGN["bm"],
                      SIGN["sh"], SIGN["bw"], SIGN["nl"], sign_zeta)
    got = m_sign.run(f1, inverse=False)
    bad = [i for i in range(256) if got[i] != gold_ntt[i]]
    print("== SIGN fidelity: forward NTT vs gold_ntt: %s (%d bad)" % (
        "OK" if not bad else "FAIL", len(bad)))
    if bad:
        ok = False
        for i in bad[:5]:
            print("   [%d] got %d exp %d" % (i, got[i], gold_ntt[i]))

    # ---- 2. model fidelity: SIGN round-trip on f1
    rt = m_sign.run(gold_ntt, inverse=True)
    exp = [mod(f1[i] * (1 << 27), SIGN["q"]) for i in range(256)]
    bad = [i for i in range(256) if mod(rt[i], SIGN["q"]) != exp[i]]
    print("== SIGN fidelity: INTT(gold_ntt) == f*2^27 mod q: %s (%d bad)" % (
        "OK" if not bad else "FAIL", len(bad)))
    if bad:
        ok = False
        for i in bad[:5]:
            print("   [%d] got %d exp %d" % (i, mod(rt[i], SIGN["q"]), exp[i]))

    # ---- 3. KEM@BW=27 configuration
    k27, zeta27 = kem27_constants(kem_zeta16)
    print("== KEM@BW=27 constants ==")
    print("  Q        = %d" % k27["q"])
    print("  QINV27   = %d  (3329^-1 mod 2^27)" % k27["qinv"])
    print("  SCALE_K27= %d  (2^22*1441 mod 3329)" % k27["scale_k"])
    print("  R_MOD27  = %d  (2^27 mod 3329)" % k27["r_mod"])
    print("  BARRETT  = M=%d SH=%d" % (k27["bm"], k27["sh"]))
    print("  zeta27[0..7] = %s" % zeta27[:8])

    m_kem = NTTModel(k27["q"], k27["qinv"], k27["scale_k"], k27["bm"],
                     k27["sh"], 27, 7, zeta27)
    q = k27["q"]

    def check_poly(f, tag):
        # forward: range + canonical, then round trip
        f_ntt = m_kem.run(f, inverse=False)
        oor = [i for i in range(256) if not (-q // 2 <= f_ntt[i] <= q // 2)]
        rt = m_kem.run(f_ntt, inverse=True)
        exp = [mod(f[i] * (1 << 27), q) for i in range(256)]
        bad = [i for i in range(256) if mod(rt[i], q) != exp[i]]
        print("  %-28s range %s (%d oor)  round-trip %s (%d bad)" % (
            tag, "OK" if not oor else "FAIL", len(oor),
            "OK" if not bad else "FAIL", len(bad)))
        return (not oor) and (not bad)

    print("== KEM@BW=27 model checks ==")
    # zero polynomial
    ok &= check_poly([0] * 256, "INTT(NTT(0)) == 0*R")
    # ramp (same vector the KEM TB uses)
    ok &= check_poly([i for i in range(256)], "f[i]=i")
    # ramp+1
    ok &= check_poly([(i + 1) for i in range(256)], "f[i]=i+1")
    # pseudo-random via simple LCG, seed fixed
    rng = [0] * 256
    s = 20261024
    for i in range(256):
        s = (1103515245 * s + 12345) % (1 << 31)
        rng[i] = s % q
    ok &= check_poly(rng, "LCG random (seed 20261024)")
    # near-boundary values
    edge = [((i * 13) % 2) * (q // 2 - 1) - (i % 3) for i in range(256)]
    ok &= check_poly(edge, "edge values +/-q/2-1")

    # bonus: KEM27 forward must equal the KEM16 forward *as integers* (the
    # re-scaled twiddles make every butterfly step identical mod q and the
    # canonical values are identical as signed integers).
    m_kem16 = NTTModel(KEM16["q"], KEM16["qinv"], KEM16["scale_k"], KEM16["bm"],
                       KEM16["sh"], 16, 7, kem_zeta16)
    f = [i % q for i in range(256)]
    a16 = m_kem16.run(f, inverse=False)
    a27 = m_kem.run(f, inverse=False)
    bad = [i for i in range(256) if a16[i] != a27[i]]
    print("  KEM27 forward == KEM16 forward (bit-identical): %s (%d bad)" % (
        "OK" if not bad else "FAIL", len(bad)))
    ok &= not bad

    # overflow headroom audit for W_WIDTH=54
    print("== headroom audit (W_WIDTH=54) ==")
    maxprod = max(abs(v) for v in zeta27) * max(abs(v) for v in rng + edge)
    print("  |zeta*coeff| max ~ 2^%.1f  (limit 2^53)" % (maxprod.bit_length()))
    print("  M*a max ~ 2^%.1f  (limit 2^53)"
          % ((k27["bm"] * (q // 2 * 8)).bit_length()))
    print("  t_low*Q <= 2^27 * 2^13 = 2^40  OK")

    print("\nRESULT: %s" % ("ALL OK" if ok else "FAILURES PRESENT"))
    return ok, k27, zeta27


if __name__ == "__main__":
    ok, _, _ = validate()
    sys.exit(0 if ok else 1)
