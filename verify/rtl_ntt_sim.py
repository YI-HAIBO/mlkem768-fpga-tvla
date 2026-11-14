#!/usr/bin/env python3
"""Cycle-faithful simulation of rtl/core/kyber_ntt.v (forward path only).

Mirrors the RTL state machine literally - S_IDLE, S_LAYER_SETUP,
S_BUTTER, S_NEXT_BLOCK, S_NEXT_LAYER, S_REDUCE - including:

  * zeta_cnt starting at 1 and incrementing once per *block*, never
    reset between layers (the schedule that makes the 128-entry ROM
    exactly cover the forward transform);
  * unsigned 16-bit storage in coeff[], matching `reg [BW-1:0]`;
  * the forward butterfly exactly as written in S_BUTTER;
  * S_REDUCE applying barrett_reduce to every coefficient.

Use it to reconcile the RTL against gen_ntt_vectors.ntt (which drives the
testbench golden vectors) layer by layer.
"""
import importlib.util
import io
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RTL = os.path.join(os.path.dirname(HERE), "rtl", "core", "kyber_ntt.v")
Q = 3329
N = 256

spec = importlib.util.spec_from_file_location(
    "g", os.path.join(HERE, "gen_ntt_vectors.py"))
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)


def u16(x):
    return x & 0xFFFF


def s16(x):
    x &= 0xFFFF
    return x - 0x10000 if x & 0x8000 else x


class RtlNtt:
    def __init__(self, zetas_u16):
        self.z = list(zetas_u16)

    def barrett_rtl(self, a):
        """RTL barrett_reduce on a signed 17-bit-range value."""
        return u16(g.barrett_reduce(s16(a)))

    def fqmul_rtl(self, a, b):
        return u16(g.fqmul(a, b))

    def forward(self, x_u16, trace_at=None):
        coeff = list(x_u16)

        def get_zeta(idx):
            return self.z[idx & 0x7F]

        layer = 0
        inv = 0
        zeta_cnt = 1
        length = 128
        blocks = 128 // length
        trace = {}

        while True:
            # S_LAYER_SETUP
            j_cnt = 0
            # S_BUTTER + S_NEXT_BLOCK, per block
            for block_cnt in range(blocks):
                block_start = block_cnt * (length * 2)
                if trace_at is not None and layer in trace_at and block_cnt == 0:
                    trace[(layer, block_cnt)] = list(coeff)
                for j in range(length):
                    aj = coeff[block_start + j]
                    ajl = coeff[block_start + j + length]
                    z = get_zeta(zeta_cnt)
                    t = self.fqmul_rtl(z, ajl)
                    # forward: as written in kyber_ntt.v S_BUTTER
                    coeff[block_start + j] = u16(s16(aj) + s16(t))
                    coeff[block_start + j + length] = u16(s16(aj) - s16(t))
                # S_NEXT_BLOCK: bump zeta per block
                zeta_cnt = (zeta_cnt + 1) & 0x7F
            # S_NEXT_LAYER
            if layer < 6:
                layer += 1
                length >>= 1
                blocks = 128 // length
            else:
                break
        for i in range(N):
            coeff[i] = self.barrett_rtl(coeff[i])
        return coeff, trace


def main():
    rtl_z = [u16(v) for v in g.parse_rtl_zetas()]

    sim = RtlNtt(rtl_z)
    x = [0] * N
    x[0] = 1
    x[255] = 1

    got, _ = sim.forward(x)
    ref = [u16(v) for v in g.ntt([s16(v) for v in x],
                                 [s16(v) for v in rtl_z])]

    bad = [i for i in range(N) if got[i] != ref[i]]
    print("RTL-style sim vs golden (X_ZERO-ish vector): %d/256 differ"
          % len(bad))
    print("  sim  c[0..7] : %s" % ["%04x" % v for v in got[:8]])
    print("  gold c[0..7] : %s" % ["%04x" % v for v in ref[:8]])
    print("  sim  c[248..255]: %s" % ["%04x" % v for v in got[248:]])
    print("  gold c[248..255]: %s" % ["%04x" % v for v in ref[248:]])

    # also compare the hand-run RTL testbench (dbg probe) coefficients
    tb = {0: 0x0001, 1: 0xfb69, 2: 0x0001, 3: 0x0497, 4: 0x0001,
          5: 0x0375, 127: 0xf9d0, 128: 0x0001, 253: 0x0011, 254: 0x0001,
          255: 0xffef}
    print()
    print("iverilog DUT vs this sim:")
    same = all(got[k] == v for k, v in tb.items())
    print("  identical on all probed indices:", same)
    if not same:
        for k, v in sorted(tb.items()):
            mark = "  " if got[k] == v else "!!"
            print("    %s c[%d] sim=%04x dut=%04x" % (mark, k, got[k], v))
    return 0


if __name__ == "__main__":
    sys.exit(main())
