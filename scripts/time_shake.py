#!/usr/bin/env python3
"""time_shake.py — synthesize the shake sponge (with the 2-way pipelined
keccak_perm) and report WNS/Fmax at 100 MHz.  Answers the Task-57 question:
does pipelining keccak_perm close shake's 1.07 ns setup gap?
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sub_timing as st  # noqa


def main():
    timeout = int(os.environ.get("SHAKE_TIMEOUT", "420"))
    r = st.synth_one("shake", ["keccak_perm.v"], "kem.xdc", timeout)
    print("rc=%s time=%.1fs timed_out=%s" % (r.get("rc"), r.get("time", 0), r.get("timed_out")))
    print("timing:", r.get("timing"))
    print("util:", r.get("util"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
