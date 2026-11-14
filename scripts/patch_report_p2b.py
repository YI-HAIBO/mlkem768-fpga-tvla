#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Final touch-up after patch_report_p2.py: the P3 recommendation line
in section 9 still said 'Not needed if P2 is acceptable', which is no
longer true once P2 is blocked by the Vivado 2026.1 hang."""
import io, sys

P = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype\results\kem_synth_final_report.md"

OLD = ("   - **P3:** vendor IP (see `p3_ip_evaluation.md`).  Not needed if\n"
       "     P2 is acceptable.\n")
NEW = ("   - **P3:** vendor IP (see `p3_ip_evaluation.md`).  Not needed —\n"
       "     the design already fits xc7a100t on resources.\n")


def main():
    t = io.open(P, encoding="utf-8").read()
    n = t.count(OLD)
    if n != 1:
        print("ABORT: expected 1 occurrence of the P3 line, found %d" % n)
        return 1
    t = t.replace(OLD, NEW)
    io.open(P, "w", encoding="utf-8").write(t)
    b = io.open(P, encoding="utf-8").read()
    print("lines %d  bytes %d" % (len(b.splitlines()), len(b)))
    print("\nheadings:")
    for i, l in enumerate(b.splitlines(), 1):
        if l.startswith("#"):
            print(" %4d %s" % (i, l[:72]))
    print("\nfinal stale scan:")
    bad = False
    for s in ["1.81× over", "3.11×", "3.83×", "1.67× over", "over 32,600",
              "fits 65,200", "270 tiles", "88% of device", "19% of the",
              "~26K LUTs", "深圳技术大学", "Not needed if"]:
        c = b.count(s)
        if c:
            bad = True
            print("  STILL PRESENT %d× %r" % (c, s))
    if not bad:
        print("  clean")
    return 0


if __name__ == "__main__":
    sys.exit(main())
