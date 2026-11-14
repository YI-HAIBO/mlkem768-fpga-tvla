#!/usr/bin/env python3
"""Find the exact first divergence between the golden invntt
(gen_ntt_vectors.invntt) and the RTL-faithful inverse schedule
(rtl_inv_sim.rtl_inverse), block by block."""
import importlib.util
import io
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RESULTS = os.path.join(os.path.dirname(HERE), "results")

spec = importlib.util.spec_from_file_location(
    "g", os.path.join(HERE, "gen_ntt_vectors.py"))
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)

N = 256


def u16(x):
    return x & 0xFFFF


def s16(x):
    x &= 0xFFFF
    return x - 0x10000 if x & 0x8000 else x


def ref_inv_stepwise(a16, z16):
    """Golden invntt, but records the coeff array after every start-block."""
    a = [s16(v) for v in a16]
    snaps = []
    k, ln = 127, 2
    while ln <= 128:
        start = 0
        while start < N:
            zeta = z16[k]
            k -= 1
            for j in range(start, start + ln):
                t = a[j]
                a[j] = g.barrett_reduce(t + a[j + ln])
                a[j + ln] = g.fqmul(zeta, a[j + ln] - t)
            snaps.append((ln, start, list(a)))
            start += 2 * ln
        ln <<= 1
    return [u16(x) for x in a], snaps


def rtl_inv_stepwise(a16, z16):
    """RTL-faithful inverse, recording after every block."""
    coeff = list(a16)
    snaps = []
    zeta_cnt = 127
    length = 2
    for layer in range(7):
        blocks = 128 // length
        for block_cnt in range(blocks):
            bs = block_cnt * (length * 2)
            for j in range(length):
                aj = coeff[bs + j]
                ajl = coeff[bs + j + length]
                z = z16[zeta_cnt & 0x7F]
                coeff[bs + j] = u16(g.barrett_reduce(s16(aj) + s16(ajl)))
                coeff[bs + j + length] = u16(g.fqmul(z, s16(ajl) - s16(aj)))
            snaps.append((length, bs, list(coeff)))
            zeta_cnt = (zeta_cnt - 1) & 0x7F
        length <<= 1
    for i in range(N):
        coeff[i] = u16(g.fqmul(coeff[i], 1441))
    return coeff, snaps


def main():
    import json
    with io.open(os.path.join(RESULTS, "ntt_golden.json"), encoding="utf-8") as f:
        gold = json.load(f)
    z16 = [u16(v) for v in gold["zetas_u16"]]
    xin = [u16(v) for v in gold["vectors"]["NTT_ZERO"]]

    r_out, r_snaps = ref_inv_stepwise(xin, z16)
    t_out, t_snaps = rtl_inv_stepwise(xin, z16)
    print("final: ref %04x..  rtl %04x.." % (r_out[0], t_out[0]))
    print("n snaps ref=%d rtl=%d" % (len(r_snaps), len(t_snaps)))

    for idx in range(min(len(r_snaps), len(t_snaps))):
        rl, rs, ra = r_snaps[idx]
        tl, ts, ta = t_snaps[idx]
        assert rl == tl and rs == ts, (idx, rl, rs, tl, ts)
        diff = [i for i in range(N) if (ra[i] & 0xFFFF) != (ta[i] & 0xFFFF)]
        if diff:
            print("FIRST DIVERGENCE at snap %d (len=%d start=%d): %d coeffs differ: %s"
                  % (idx, rl, rs, len(diff), diff[:8]))
            i = diff[0]
            print("  ref a[%d..%d] = %s" % (i, i + 3, ["%04x" % v for v in ra[i:i + 4]]))
            print("  rtl a[%d..%d] = %s" % (i, i + 3, ["%04x" % v for v in ta[i:i + 4]]))
            print("  ref snap len/start: %d/%d  zeta blocks so far: %d" % (rl, rs, idx))
            # show the block's zeta in each variant
            print("  ref zeta idx this block: %d (value %04x), rtl zeta idx: %d (value %04x)"
                  % (127 - idx, z16[(127 - idx) & 0x7F], (127 - idx) & 0x7F,
                     z16[(127 - idx) & 0x7F]))
            break
    else:
        print("no divergence in layer traces; difference must be in final scale")
    return 0


if __name__ == "__main__":
    sys.exit(main())
