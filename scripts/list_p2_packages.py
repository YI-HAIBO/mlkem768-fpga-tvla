#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""List every xc7a200t part Vivado 2026.1 offers (name + available IOBs),
so the P2 synthesis runner can pin an exact part number."""
import subprocess, os, io, sys

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
RESULTS   = os.path.join(PROJECT, "results")
VIVADO    = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"

TCL = r'''
set ps [get_parts -quiet -regexp {^xc7a200t-.*}]
foreach p [lsort $ps] {
    set dev [get_property DEVICE $p]
    set pkg [get_property PACKAGE $p]
    set spd [get_property SPEED $p]
    set io  [get_property AVAILABLE_IOBS $p]
    puts "PART $p  pkg=$pkg speed=$spd iobs=$io"
}
set cands [get_parts -quiet -regexp {^xc7a200t-(fbg484|sbg484|fbg676|fbv484|ffg1156)-.*}]
foreach p $cands {
    puts "SAMPLE $p slices=[get_property SLICES $p] lut=[get_property LUT_ELEMENTS $p] ff=[get_property FLIPFLOPS $p] bram=[get_property BLOCK_RAMS $p] dsp=[get_property DSP $p]"
}
exit 0
'''


def main():
    tmp = os.path.join(RESULTS, "_p2_pkg.tcl")
    with io.open(tmp, "w", encoding="utf-8") as fh:
        fh.write(TCL)
    cmd = [VIVADO, "-mode", "batch", "-nojournal", "-nolog", "-source", tmp]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=300,
                       cwd=RESULTS, errors="replace")
    out = r.stdout or ""
    keep = [l for l in out.splitlines() if l.startswith(("PART ", "SAMPLE "))]
    print("\n".join(keep))
    print("\ntotal xc7a200t parts = %d" % len([l for l in keep if l.startswith("PART ")]))
    with io.open(os.path.join(RESULTS, "p2_part_list.txt"), "w", encoding="utf-8") as fh:
        fh.write("\n".join(keep) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
