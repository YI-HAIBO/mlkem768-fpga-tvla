#!/usr/bin/env python3
"""Diff the actual g.invntt (golden) against the RTL-faithful inverse,
comparing the PRE-SCALE coefficient arrays (before fqmul(x,1441))."""
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
to_i16, u16, fqmul, barrett = g.to_i16, g.u16, g.fqmul, g.barrett_reduce

N = 256


def inv_prescale_ref(a, zetas):
    """Verbatim copy of g.invntt body, but returns the pre-scale array."""
    a = [to_i16(x) for x in a]
    k, ln = 127, 2
    while ln <= 128:
        start = 0
        while start < N:
            zeta = zetas[k]
            k -= 1
            for j in range(start, start + ln):
                t = a[j]
                a[j] = barrett(t + a[j + ln])
                a[j + ln] = to_i16(a[j + ln] - t)
                a[j + ln] = fqmul(zeta, a[j + ln])
            start += 2 * ln
        ln <<= 1
    return a  # NOTE: no final fqmul(x, 1441)


def inv_prescale_rtl(x_u16, z_u16):
    coeff = list(x_u16)
    zeta_cnt = 127
    length = 2
    for layer in range(7):
        blocks = 128 // length
        for block_cnt in range(blocks):
            bs = block_cnt * (length * 2)
            for j in range(length):
                aj = coeff[bs + j]
                ajl = coeff[bs + j + length]
                z = z_u16[zeta_cnt & 0x7F]
                coeff[bs + j] = u16(barrett(to_i16(aj) + to_i16(ajl)))
                coeff[bs + j + length] = u16(fqmul(z, to_i16(ajl) - to_i16(aj)))
            zeta_cnt = (zeta_cnt - 1) & 0x7F
        length <<= 1
    return [u16(v) for v in coeff]


def main():
    import json
    with io.open(os.path.join(RESULTS, "ntt_golden.json"), encoding="utf-8") as f:
        gold = json.load(f)
    z16 = gold["zetas_u16"]
    z_signed = [to_i16(v) for v in z16]

    for tag in ("ZERO", "RAND"):
        xin = [u16(v) for v in gold["vectors"]["NTT_" + tag]]
        exp_full = [u16(v) for v in gold["vectors"]["INTT_" + tag]]

        pre_ref = [u16(v) for v in inv_prescale_ref(list(xin), z_signed)]
        pre_rtl = inv_prescale_rtl(list(xin), z16)
        print("NTT_%s pre-scale arrays equal: %s"
              % (tag, pre_ref == pre_rtl))
        d = [i for i in range(N) if pre_ref[i] != pre_rtl[i]]
        print("  differ at %d positions: %s" % (len(d), d[:10]))
        if d:
            i = d[0]
            print("  ref pre[%d..%d] = %s" % (i, i + 3, ["%04x" % v for v in pre_ref[i:i + 4]]))
            print("  rtl pre[%d..%d] = %s" % (i, i + 3, ["%04x" % v for v in pre_rtl[i:i + 4]]))
        # sanity: ref pre-scale through fqmul(x,1441) must equal golden INTT
        scaled = [u16(fqmul(v, 1441)) for v in pre_ref]
        print("  ref pre-scale *1441 == golden INTT: %s" % (scaled == exp_full))
        scaled_rtl = [u16(fqmul(v, 1441)) for v in pre_rtl]
        print("  rtl pre-scale *1441 == golden INTT: %s" % (scaled_rtl == exp_full))
        print("  ref pre c[0..7] = %s" % " ".join("%04x" % v for v in pre_ref[:8]))
        print("  rtl pre c[0..7] = %s" % " ".join("%04x" % v for v in pre_rtl[:8]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
