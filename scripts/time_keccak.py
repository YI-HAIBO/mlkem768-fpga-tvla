#!/usr/bin/env python3
"""time_keccak.py — synthesize ONLY the (2-way pipelined) keccak_perm and
report WNS/Fmax at the 100 MHz constraint.  Confirms the pipeline closed the
setup gap.  Uses the same TCL/timeout machinery as sub_timing.py.
"""
import os
import sys
import io

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sub_timing as st  # noqa


def main():
    timeout = int(os.environ.get("KECCAK_TIMEOUT", "360"))
    r = st.synth_one("keccak_perm", [], "kem.xdc", timeout)
    print("rc=%s time=%.1fs timed_out=%s" % (r.get("rc"), r.get("time", 0), r.get("timed_out")))
    print("timing:", r.get("timing"))
    print("util:", r.get("util"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
