#!/usr/bin/env python3
"""Faithful Python sim of the kyber_ntt.v INVERSE path, layer by layer,
compared against the golden model (gen_ntt_vectors.invntt).

Mirrors the RTL S_BUTTER(inv_mode) literally:
    coeff[bs+j]      <= barrett_reduce(aj + ajl)
    coeff[bs+j+len]  <= fqmul(z, ajl - aj)     (int16 wrap)
zeta_cnt starts at 127 and decrements once per block (S_NEXT_BLOCK),
len doubles 2..128 over 7 layers, then S_SCALE multiplies everything by 1441.
"""
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


def rtl_inverse(z_u16, x_u16, verbose=True):
    coeff = list(x_u16)
    zeta_cnt = 127
    length = 2
    for layer in range(7):
        blocks = 128 // length
        for block_cnt in range(blocks):
            block_start = block_cnt * (length * 2)
            for j in range(length):
                aj = coeff[block_start + j]
                ajl = coeff[block_start + j + length]
                z = z_u16[zeta_cnt & 0x7F]
                coeff[block_start + j] = u16(g.barrett_reduce(s16(aj) + s16(ajl)))
                coeff[block_start + j + length] = u16(g.fqmul(z, s16(ajl) - s16(aj)))
            zeta_cnt = (zeta_cnt - 1) & 0x7F
        if verbose:
            print("  after layer %d (len=%d): c[0..7] = %s"
                  % (layer, length, " ".join("%04x" % v for v in coeff[:8])))
        length <<= 1
    for i in range(N):
        coeff[i] = u16(g.fqmul(coeff[i], 1441))
    return coeff


def main():
    import json
    with io.open(os.path.join(RESULTS, "ntt_golden.json"), encoding="utf-8") as f:
        gold = json.load(f)
    z_u16 = gold["zetas_u16"]

    vecs = gold["vectors"]
    tags = ("RAND", "ZERO", "POS", "NEG", "EXT")
    for t in tags:
        xin = [u16(v) for v in vecs["NTT_" + t]]
        exp = [u16(v) for v in vecs["INTT_" + t]]
        print("NTT_%s -> INTT_%s:" % (t, t))
        got = rtl_inverse(z_u16, xin, verbose=(t == "ZERO"))
        bad = [i for i in range(N) if got[i] != exp[i]]
        print("  differ: %d/256, first %s" % (len(bad), bad[0] if bad else None))
        if bad:
            i = bad[0]
            print("  got c[0..7] : %s" % " ".join("%04x" % v for v in got[:8]))
            print("  exp c[0..7] : %s" % " ".join("%04x" % v for v in exp[:8]))
        # cross-check vs iverilog DUT probe (NTT_ZERO inverse)
        if t == "ZERO":
            print("  iverilog DUT was: fbec 0000 0000 0000 0000 0000 0000 0000")
    return 0


if __name__ == "__main__":
    sys.exit(main())
