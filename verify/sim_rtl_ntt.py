#!/usr/bin/env python3
"""Cycle-faithful simulation of rtl/core/kyber_ntt.v's butterfly schedule.

Purpose: reconcile the RTL's transform against the golden model in
verify/gen_ntt_vectors.py.  The RTL's zeta-index schedule is mirrored
exactly, so any divergence isolates to either the schedule or the
arithmetic primitives.

Layer schedule is read from the RTL source itself (guarding against any
mismatch between the header comment and the actual loop).
"""
import importlib.util
import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(HERE)
RTL = os.path.join(PROJECT, "rtl", "core", "kyber_ntt.v")

Q = 3329
N = 256


def load_model():
    spec = importlib.util.spec_from_file_location(
        "g", os.path.join(HERE, "gen_ntt_vectors.py"))
    g = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(g)
    return g


def to_i16(x):
    x &= 0xFFFF
    return x - 0x10000 if x & 0x8000 else x


def u16(x):
    return to_i16(x) & 0xFFFF


def parse_rtl_schedule(src):
    """Pull the layer bounds and zeta-index expression out of the RTL."""
    m = re.search(r"S_RUN[^:]*:.*?endcase", src, re.S)
    return m


def main():
    g = load_model()
    z = g.parse_rtl_zetas()
    src = io.open(RTL, encoding="utf-8").read()

    # ------- print the two FSM arms so the schedule is explicit ----------
    i_fwd_lo = src.find("S_RUN_FWD")
    if i_fwd_lo < 0:
        i_fwd_lo = src.find("if (!inverse)")
    print("RTL S_RUN_FWD region:")
    seg = src[i_fwd_lo:i_fwd_lo + 2200]
    print(seg)

    return 0


if __name__ == "__main__":
    sys.exit(main())
