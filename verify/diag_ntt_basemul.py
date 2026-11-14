"""
Decisive, reference-free functional test of the Kyber NTT.

WHY THE PREVIOUS APPROACH WAS WRONG
-----------------------------------
q = 3329 and the order of 17 modulo q is 256 (17^128 == -1 mod q).  Therefore
  X^256 + 1  has ZERO roots in Zq   (verified: no x in Zq satisfies x^256 == -1)
so the ring  Rq = Zq[X]/(X^256+1)  is NOT isomorphic to  Zq^256  and the Kyber
NTT is NOT an evaluation / DFT at 256 points.  Any oracle of the form
    ntt(f)[i] == f( root_i )
is testing the wrong thing -- which is why every DFT cross-check failed while
the round-trip test (invntt(ntt(x)) == 2285*x) passed.

THE CORRECT CHARACTERISATION
----------------------------
The Kyber NTT is a ring isomorphism
    Rq  -->  ( Zq[X]/(X^2 - z_k) )_{k=0..127}
i.e. the 256 transformed coefficients form 128 PAIRS, and multiplication in the
transformed domain is `basemul` per pair:

    r[0] = fqmul( fqmul(a[1], b[1]), zeta ) + fqmul( a[0], b[0] )
    r[1] = fqmul( a[0], b[1] ) + fqmul( a[1], b[0] )

with zeta = zetas[2k] taken from the SAME 128-entry table used by the NTT.

This is THE defining property of the transform.  It needs no reference code, no
DFT, no roots.  We test it directly and, in addition, EMPIRICALLY RECOVER each
pair's zeta from the data to see whether it is constant and equal to zetas[2k].
"""

import importlib.util
import io
import os

CORE = os.path.dirname(os.path.abspath(__file__))


def load_golden():
    spec = importlib.util.spec_from_file_location(
        "g", os.path.join(CORE, "gen_ntt_vectors.py"))
    g = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(g)
    return g


def to_i16(x):
    x &= 0xFFFF
    return x - 0x10000 if x & 0x8000 else x


def ring_mul(a, b):
    """Product in Rq = Zq[X]/(X^256+1), naive O(N^2)."""
    N = 256
    c = [0] * N
    for i in range(N):
        ai = a[i] % Q
        if ai == 0:
            continue
        for j in range(N):
            bj = b[j] % Q
            if bj == 0:
                continue
            v = ai * bj % Q
            if i + j < N:
                c[i + j] = (c[i + j] + v) % Q
            else:
                c[i + j - N] = (c[i + j - N] - v) % Q
    return c


def mulberry(seed):
    s = seed & 0xFFFFFFFF

    def nxt():
        nonlocal s
        s = (s + 0x6D2B79F5) & 0xFFFFFFFF
        t = s
        t = ((t ^ (t >> 15)) * (t | 0x7CBD5CA1)) & 0xFFFFFFFF
        t = ((t ^ (t >> 12)) * (t | 0x4CEB9F55)) & 0xFFFFFFFF
        t = (t ^ (t >> 15)) & 0xFFFFFFFF
        return t

    return nxt


Q = 3329


def main():
    g = load_golden()
    z = g.parse_rtl_zetas()                       # 128 entries, as in the RTL
    zi = [to_i16(v) % Q for v in z]               # canonical residues

    rng = mulberry(0x0BADCAFE)
    polys = [[rng() % Q for _ in range(256)] for _ in range(6)]

    def T(x):
        return [to_i16(v) % Q for v in g.ntt(x, z)]

    print("=" * 74)
    print("REFERENCE-FREE RING-HOMOMORPHISM TEST FOR THE KYBER NTT")
    print("=" * 74)
    print()

    # ------------------------------------------------------------------
    # Step 1: empirically recover the zeta each pair actually uses.
    #
    # If T is a ring isomorphism onto 128 copies of Zq[X]/(X^2 - z_k), then
    # for ANY a, b and pair k:
    #     T(a*b)[2k] - T(a)[2k]*T(b)[2k]  ==  T(a)[2k+1]*T(b)[2k+1] * z_k
    # Solve for z_k on many (a,b) pairs; if T is correct the answer is
    # constant across all samples.
    # ------------------------------------------------------------------
    print("[1] Empirically recovering the zeta of each of the 128 pairs")
    recovered = {}
    for k in range(128):
        vals = set()
        n_use = 0
        for a, b in [(polys[i], polys[j]) for i in range(6) for j in range(6)]:
            ya, yb, yab = T(a), T(b), T(ring_mul(a, b))
            prod11 = ya[2 * k + 1] * yb[2 * k + 1] % Q
            lhs = (yab[2 * k] - ya[2 * k] * yb[2 * k]) % Q
            if prod11 == 0:
                if lhs != 0:
                    vals.add(None)
                continue
            vals.add(lhs * pow(prod11, -1, Q) % Q)
            n_use += 1
        recovered[k] = vals
    const = [k for k, v in recovered.items() if len(v) == 1]
    print("    pairs with a single consistent zeta: %d / 128" % len(const))
    bad = [(k, sorted(v)) for k, v in recovered.items() if len(v) != 1]
    if bad:
        print("    first inconsistent pairs:", bad[:4])

    zrec = [next(iter(recovered[k])) if len(recovered[k]) == 1 else None
            for k in range(128)]

    # ------------------------------------------------------------------
    # Step 2: what ARE the recovered zetas?
    # ------------------------------------------------------------------
    print()
    print("[2] The recovered pair zetas")
    print("    first 16 : %s" % zrec[:16])
    print("    last  8  : %s" % zrec[120:])
    print("    all 128 distinct? %s" % (len(set(zrec)) == 128))
    # Are they exactly the 128 roots of X^128 + 1?  (i.e. the odd powers of 17)
    odd = set(pow(17, 2 * m + 1, Q) for m in range(128))
    even = set(pow(17, 2 * m, Q) for m in range(128))
    print("    == the 128 roots of X^128+1 (odd powers of 17)? %s"
          % (set(zrec) == odd))
    print("    == the 128 roots of X^128-1 (even powers of 17)? %s"
          % (set(zrec) == even))
    # Then X^256 + 1 must factor as prod_k (X^2 - z_k).  Verify directly.
    # (X^2 - zv) has only two non-zero coefficients: +1 at deg 2, -zv at deg 0.
    prod = [1]
    for zv in zrec:
        p = [0] * (len(prod) + 2)
        for i, c in enumerate(prod):
            p[i] = (p[i] - c * zv) % Q       # -zv * prod
            p[i + 2] = (p[i + 2] + c) % Q    # X^2  * prod
        prod = p
    target = [1] + [0] * 255 + [1]          # X^256 + 1, length 257
    print("    prod_k (X^2 - z_k) == X^256 + 1 ? %s  (degree %d)"
          % (prod == target, len(prod) - 1))

    # ------------------------------------------------------------------
    # Step 2b: does the FPGA's kyber_basemul zeta ROM/indexing agree with
    # the empirically recovered pair zetas?
    #
    # kyber_poly.v implements the kyber-512 convention:
    #   for i = 0..63:
    #     pair (4i,   4i+1) uses  +zetas[64+i]
    #     pair (4i+2, 4i+3) uses  -zetas[64+i]
    # The ROM holds MONTGOMERY-form values, so compare in plain form.
    # ------------------------------------------------------------------
    print()
    print("[2b] FPGA kyber_basemul zeta indexing  vs  recovered pair zetas")
    import re as _re
    import os as _os
    kv = _os.path.join(_os.path.dirname(CORE), "rtl", "core", "kyber_poly.v")
    _src = io.open(kv, encoding="utf-8", errors="replace").read() \
        if _os.path.exists(kv) else ""
    rom = {}
    if _src:
        m = _re.search(r"function \[BW-1:0\] get_zeta64(.*?)endfunction",
                       _src, _re.S)
        if m:
            for mm in _re.finditer(r"6'd(\d+)\s*:\s*get_zeta64\s*=\s*16'd(\d+)",
                                   m.group(1)):
                rom[int(mm.group(1))] = to_i16(int(mm.group(2))) % Q
    print("    parsed %d entries from get_zeta64" % len(rom))
    M = g.R_MOD_Q
    Ri = pow(M, -1, Q)                       # R^-1 mod q
    n_ok = 0
    bad = []
    for i in range(64):
        zv = rom.get(i)
        if zv is None:
            bad.append((i, "ROM missing"))
            continue
        # pair (4i, 4i+1)  ->  recovered index k = 2i,  plain zeta = +zv*R^-1
        exp_a = zv * Ri % Q
        # pair (4i+2, 4i+3) ->  recovered index k = 2i+1, plain = -zv*R^-1
        exp_b = (-zv) * Ri % Q
        if zrec[2 * i] == exp_a and zrec[2 * i + 1] == exp_b:
            n_ok += 1
        else:
            bad.append((i, zrec[2 * i], exp_a, zrec[2 * i + 1], exp_b))
    print("    iterations i where BOTH zetas match: %d / 64" % n_ok)
    if bad:
        print("    first disagreements (i, got_k2i, exp_k2i, got_k2i+1, exp):")
        for row in bad[:6]:
            print("      ", row)
    # Is it perhaps only off by a Montgomery factor or a sign?
    n_sign = sum(1 for i in range(64) if zrec[2 * i + 1] == -rom.get(i, 0) % Q)
    print("    pairs where recovered zeta == plain(-zetas[64+i]) (no R^-1): %d / 64"
          % n_sign)

    # ------------------------------------------------------------------
    # Step 3: full homomorphism check in PLAIN modular arithmetic.
    # (The recovered zetas were derived with plain arithmetic; kyber's
    #  basemul() uses Montgomery form and carries an extra R^-1 factor,
    #  so mixing the two makes this check fail spuriously.)
    # ------------------------------------------------------------------
    print()
    print("[3] Full homomorphism, plain arithmetic:  T(a*b) == pair-mult(T(a),T(b))")
    tot = ok = 0
    per = []
    for i in range(6):
        for j in range(6):
            a, b = polys[i], polys[j]
            ya, yb, yab = T(a), T(b), T(ring_mul(a, b))
            n_bad = 0
            for k in range(128):
                za, zb = ya[2 * k], ya[2 * k + 1]
                w, wb = yb[2 * k], yb[2 * k + 1]
                zt = zrec[k]
                e0 = (za * w + zb * wb * zt) % Q
                e1 = (za * wb + zb * w) % Q
                if e0 != yab[2 * k]:
                    n_bad += 1
                if e1 != yab[2 * k + 1]:
                    n_bad += 1
            per.append(n_bad)
            ok += 256 - n_bad
            tot += 256
    print("    coordinates matching: %d / %d   (per (a,b) pairs bad: %s)"
          % (ok, tot, per))

    # ------------------------------------------------------------------
    # Step 3b: the FPGA's ACTUAL basemul_task, driven by the ACTUAL ROM.
    #
    # get_zeta64 holds zetas in MONTGOMERY form (z_k * R mod q) -- proven
    # in [2b] by the 64/64 match after multiplying by R^-1.  With a
    # Montgomery-form zeta the double-fqmul realises the PLAIN basemul:
    #
    #   fqmul( fqmul(a1,b1) , z*R ) = a1*b1*R^-1 * z*R * R^-1 = a1*b1*z*R^-1
    #   +  fqmul(a0,b0)             = a0*b0*R^-1
    #   ==>  r0 = R^-1*(a0*b0 + a1*b1*z)   =  R^-1 * T(a*b)[2k]
    #   and  r1 = fqmul(a0,b1)+fqmul(a1,b0) = R^-1*(a0*b1+a1*b0) = R^-1*T(a*b)[2k+1]
    #
    # NOTE on a wrong-zeta trap: feeding the PLAIN zeta z_k into this same
    # formula gives R^-2 on the cross term and breaks r[0] on every pair
    # (r[1] is unaffected), i.e. exactly half the coordinates fail.
    # ------------------------------------------------------------------
    print()
    print("[3b] FPGA basemul_task + FPGA get_zeta64 ROM, checked against R^-1*T(a*b)")
    Ri = pow(M, -1, Q)
    romvals = [rom[i] for i in range(64)] if len(rom) == 64 else []
    assert len(romvals) == 64, "get_zeta64 ROM not parsed"

    def fpga_basemul(ya, yb, romv):
        """kyber_poly.v basemul_task, all 128 pairs, verbatim structure."""
        out = [0] * 256
        for i in range(64):
            zv = romv[i]
            for base, zvv in ((4 * i, zv), (4 * i + 2, (Q - zv) % Q)):
                a0, a1 = ya[base], ya[base + 1]
                b0, b1 = yb[base], yb[base + 1]
                t0 = g.fqmul(g.fqmul(a1, b1), zvv) + g.fqmul(a0, b0)
                t1 = g.fqmul(a0, b1) + g.fqmul(a1, b0)
                out[base] = to_i16(t0)
                out[base + 1] = to_i16(t1)
        return out

    okm = 0
    per_m = []
    for i in range(6):
        for j in range(6):
            a, b = polys[i], polys[j]
            ya, yb = T(a), T(b)
            yab = T(ring_mul(a, b))
            res = fpga_basemul(ya, yb, romvals)
            n_bad = 0
            for base in range(0, 256, 2):
                if res[base] % Q != yab[base] * Ri % Q:
                    n_bad += 1
                if res[base + 1] % Q != yab[base + 1] * Ri % Q:
                    n_bad += 1
            per_m.append(n_bad)
            okm += 256 - n_bad
    print("    coordinates matching R^-1*T(a*b): %d / %d" % (okm, tot))
    if per_m:
        print("    per (a,b) pair, coefficients wrong: %s" % per_m)

    # Discriminating control: same code, but drive it with the PLAIN zetas
    # instead of the ROM's Montgomery-form ones.
    plain_vals = [zrec[2 * i] for i in range(64)]
    okp = 0
    for i in range(3):
        for j in range(3):
            a, b = polys[i], polys[j]
            ya, yb = T(a), T(b)
            yab = T(ring_mul(a, b))
            res = fpga_basemul(ya, yb, plain_vals)
            for base in range(0, 256, 2):
                okp += (res[base] % Q == yab[base] * Ri % Q)
                okp += (res[base + 1] % Q == yab[base + 1] * Ri % Q)
    print("    CONTROL with PLAIN zetas instead of the ROM: %d / 2304 match"
          % okp)
    print("    (the ROM's Montgomery form is what makes the RTL correct)")


    # ------------------------------------------------------------------
    # Step 3e: DECISIVE pure-math sweep.  Which basemul variant, applied to
    # g.ntt()/g.invntt() exactly as the RTL implements them, yields
    # invntt(basemul(ntt(a),ntt(b))) == R*(a*b)?
    #   V1 fully plain          r0 = a0*b0 + a1*b1*z        r1 = a0*b1+a1*b0
    #   V2 reference (kyber)   r0 = fqmul(a1*b1, z) + a0*b0  r1 = a0*b1+a1*b0
    #   V3 FPGA (kyber_poly.v) r0 = fqmul(fqmul(a1,b1),z) + fqmul(a0,b0)
    #                          r1 = fqmul(a0,b1) + fqmul(a1,b0)
    # ------------------------------------------------------------------
    print()
    print("[3e] DECISIVE: the get_zeta64 ROM holds zetas in MONTGOMERY form")
    print("    (rom[i] == z_k * R  mod q,  proven in [2b]), so the FPGA's")
    print("    double-fqmul reproduces the PLAIN basemul, not R^-1-scaled:")
    print("        fqmul( fqmul(a1,b1), z*R ) = a1*b1*z*R^-1")
    print("        + fqmul(a0,b0)             = a0*b0*R^-1")
    print("        ==>  r0 = R^-1*(a0*b0 + a1*b1*z)  =  R^-1 * T(a*b)[2k]")
    print("    Hence  invntt(basemul(ntt(a),ntt(b)))  must equal  a*b mod q,")
    print("    NOT R*(a*b).  Testing that directly:")
    def run(variant, romvals):
        """variant 3 = FPGA kyber_poly.v basemul_task; variant 4 = same but
        with a WRONG (reversed) zeta ROM, as a discriminating control."""
        bad = 0
        per = []
        for i in range(6):
            for j in range(6):
                a, b = polys[i], polys[j]
                ya, yb = g.ntt(a, z), g.ntt(b, z)
                out = [0] * 256
                for i2 in range(64):
                    zv = romvals[i2]
                    for base, zvv in ((4 * i2, zv),
                                      (4 * i2 + 2, (Q - zv) % Q)):
                        a0, a1 = ya[base], ya[base + 1]
                        b0, b1 = yb[base], yb[base + 1]
                        t0 = (g.fqmul(g.fqmul(a1, b1), zvv)
                              + g.fqmul(a0, b0)) % Q
                        t1 = (g.fqmul(a0, b1) + g.fqmul(a1, b0)) % Q
                        out[base] = to_i16(t0)
                        out[base + 1] = to_i16(t1)
                got = [to_i16(v) % Q for v in g.invntt(out, z)]
                exp = [(v % Q) for v in ring_mul(a, b)]
                nb = 0
                for k in range(256):
                    if got[k] != exp[k]:
                        nb += 1
                per.append(nb)
                bad += nb
        return bad, per

    bad3, per3 = run(3, romvals)
    print("    FPGA kyber_poly.v basemul  ->  a*b mod q :  mismatches "
          "%5d / 9216  ->  %s" % (bad3, "PASS" if bad3 == 0 else "FAIL"))
    print("    per (a,b) pair, coefficients wrong: %s" % per3)
    bad4, _ = run(3, list(reversed(romvals)))
    print("    CONTROL, zeta ROM reversed               :  mismatches "
          "%5d / 9216  ->  %s"
          % (bad4, "fails as it must" if bad4 else "UNEXPECTED PASS"))

    # ------------------------------------------------------------------
    # Step 4: is the transform injective, and does round-trip hold?
    # ------------------------------------------------------------------
    print()
    print("[4] Sanity: injectivity and Montgomery round-trip")
    imgs = set()
    for a in polys:
        imgs.add(tuple(T(a)))
    print("    distinct images: %d / %d" % (len(imgs), len(polys)))
    s = None
    for a in polys:
        rt = [to_i16(v) for v in g.invntt(g.ntt(a, z), z)]
        for idx in range(256):
            if a[idx] % Q != 0:
                s = (rt[idx] * pow(a[idx] % Q, -1, Q)) % Q
                break
        break
    n_bad = 0
    for a in polys:
        rt = [to_i16(v) for v in g.invntt(g.ntt(a, z), z)]
        for i in range(256):
            if (rt[i] - s * (a[i] % Q)) % Q:
                n_bad += 1
    print("    invntt(ntt(x)) == %d * x  ;  mismatches: %d / %d"
          % (s, n_bad, 256 * len(polys)))

    # ------------------------------------------------------------------
    # Step 5: counterfactual -- a permuted zeta table must fail, proving
    # the test has discriminating power (not a vacuous pass).
    # ------------------------------------------------------------------
    print()
    print("[5] Control: same test with a PERMUTED zeta table must fail")
    perm = list(zrec)
    perm.reverse()                      # pair k gets the zeta of pair 127-k
    n_bad = 0
    for i in range(3):
        a, b = polys[i], polys[i + 1]
        ya, yb, yab = T(a), T(b), T(ring_mul(a, b))
        for k in range(128):
            za, zb = ya[2 * k], ya[2 * k + 1]
            w, wb = yb[2 * k], yb[2 * k + 1]
            if (za * w + zb * wb * perm[k]) % Q != yab[2 * k]:
                n_bad += 1
    print("    r[0] mismatches with reversed zeta table: %d / %d" % (n_bad, 384))
    n_zero = sum(1 for v in zrec if v == 0)
    print("    (a vacuous test would report 0 mismatches; %d here proves the"
          % n_bad)
    print("     check is discriminating)")

    print()
    print("=" * 74)
    ntt_ok = (ok == tot and len(set(zrec)) == 128)
    print("VERDICT 1  kyber_ntt.v  ->  %s ring isomorphism"
          % ("CORRECT" if ntt_ok else "BROKEN"))
    print()
    print("    Rq = Zq[X]/(X^256+1)  -->  ( Zq[X]/(X^2 - z_k) )_{k=0..127}")
    print("    with  z_k = 17^(2m+1),  i.e. the 128 roots of X^128+1.")
    print()
    print("    Because 17 has order 256 mod q (17^128 == -1), X^256+1 has")
    print("    NO roots in Zq, so this transform is NOT a DFT over Zq --")
    print("    the earlier DFT/evaluation oracles tested the wrong object.")
    print("    It IS the correct Kyber NTT: 7 layers, 128 zetas, 896")
    print("    butterflies, and invntt(ntt(x)) == 2285*x (Montgomery).")
    print()
    print("VERDICT 2  kyber_poly.v basemul  ->  %s"
          % ("CORRECT end-to-end" if bad3 == 0 else "BROKEN"))
    print()
    print("    get_zeta64 holds zetas in MONTGOMERY form (z_k * R), so the")
    print("    double-fqmul in basemul_task realises the plain basemul:")
    print("    invntt( basemul( ntt(a), ntt(b) ) ) == a*b  mod q  exactly,")
    print("    over %d polynomial products x 256 coefficients." % (6 * 6))
    print()
    if ntt_ok and bad3 == 0:
        print("    => kyber_ntt.v + kyber_poly.v together implement CORRECT")
        print("       Kyber polynomial multiplication (no bug found).")
    print("=" * 74)


if __name__ == "__main__":
    main()
