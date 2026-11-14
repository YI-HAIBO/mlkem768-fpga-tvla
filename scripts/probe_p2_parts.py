#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
P2 feasibility probe: does Vivado 2026.1 actually have xc7a325t (or bigger
Artix-7) parts in its installed part database?

The final report (§9) proposes "switch to xc7a325t" as the fastest route to
a working prototype, citing 576 RAMB36 / 142K FF / 80K LUT / 280 DSP.
Public Artix-7 tables only go up to XC7A200T, so the part name and its
resource numbers must be verified against the local Vivado installation
before the P2 synthesis script can be written.

This script runs a 5-second Vivado query (no synthesis) and prints every
Artix-7 part >= XC7A100T that Vivado knows about, with full device
resources via [get_property -regexp .*].  Output is cached to
results/p2_part_probe.txt so the P2 runner can reuse it.
"""
import subprocess, os, io, sys, time

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
RESULTS   = os.path.join(PROJECT, "results")

VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"

TCL = r'''
puts "=== P2 part probe ==="
# 1) Does xc7a325t exist at all, in ANY package/speed?
set p325 [get_parts -quiet -regexp {xc7a325t.*}]
puts "PARTS_325T: [llength $p325]"
foreach p $p325 { puts "  $p" }

# 2) xc7a680t (the other candidate named in report section 9)
set p680 [get_parts -quiet -regexp {xc7a680t.*}]
puts "PARTS_680T: [llength $p680]"
foreach p $p680 { puts "  $p" }

# 3) All Artix-7 families Vivado knows
set fams [get_parts -quiet -regexp {xc7a.*}]
set devlist {}
foreach p $fams {
    set dev [get_property DEVICE $p]
    if { ![dict exists $devlist $dev] } { dict set devlist $dev 1 }
}
puts "ARTIX7_DEVICES: [lsort [dict keys $devlist]]"

# 4) Full resource dump for the biggest artix-7 die we can find,
#    plus the current xc7a100t for a known-good reference.
foreach probe_device {xc7a325t xc7a680t xc7a200t xc7a100t} {
    set cand [lsearch -inline -all [lsort -unique $fams] "${probe_device}*"]
    # the above lsearch runs on part names; use get_parts directly instead
    set cand [get_parts -quiet -regexp "^${probe_device}-.*"]
    if { [llength $cand] == 0 } {
        puts "DEVICE $probe_device: NOT FOUND"
        continue
    }
    set part [lindex $cand 0]
    puts "DEVICE $probe_device: [llength $cand] parts, sample = $part"
    # all properties of one sample part
    foreach prop [lsort [list_property $part]] {
        set val [get_property $prop $part]
        if { $val ne "" && $val ne "*" } {
            puts "  $prop = $val"
        }
    }
}
puts "=== DONE ==="
exit 0
'''


def main():
    tmp = os.path.join(RESULTS, "_p2_probe.tcl")
    log = os.path.join(RESULTS, "p2_part_probe.log")
    with io.open(tmp, "w", encoding="utf-8") as fh:
        fh.write(TCL)

    cmd = [VIVADO, "-mode", "batch", "-nojournal", "-nolog", "-source", tmp]
    print("Running Vivado part probe (timeout 300s)...")
    t0 = time.time()
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=300,
                           cwd=RESULTS, errors="replace")
        rc = r.returncode
        out = r.stdout or ""
    except subprocess.TimeoutExpired:
        rc, out = -999, "TIMEOUT"
    except Exception as e:
        rc, out = -1, "ERR: %s" % e
    print("rc=%s  time=%.1fs" % (rc, time.time() - t0))

    with io.open(log, "w", encoding="utf-8") as fh:
        fh.write(out)
    print(out)
    print("\nProbe log -> %s" % log)
    return 0


if __name__ == "__main__":
    sys.exit(main())
