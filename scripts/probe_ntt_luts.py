#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Measure where kyber_ntt's 28,668 LUTs actually go.

The final report attributes ~26,876 of them to "the zeta ROM and
barrett-reduce glue".  That attribution is unverified: an older driver
(synth_kyber_ntt_fast.py) records a Vivado ROM-inference row of
`get_zeta | 128x14 | LUT`, i.e. ~1,792 LUTs for the zeta ROM alone.
And report_utilization -hierarchical says kyber_ntt is FLAT:
    28,668 logic LUTs, 0 LUTRAM, 0 SRL, 4,212 FFs, 13 DSP.
So the real LUT consumer is somewhere else and has to be found before
P4 picks a target.

This probe synthesizes kyber_ntt standalone (RuntimeOptimized, the only
directive that completes on this module in Vivado 2026.1) and dumps:

  report_utilization -hierarchical   -> per-submodule LUT/FF/DSP
  per-cell NUM_LUTS / NUM_FLOPS /    -> the decisive one: every generated
    BELS / PRIMITIVE via pure Tcl      cell, sorted + bucketed in Python
  name-substring buckets             -> coeff array / zeta ROM / fqmul /
                                        montgomery / barrett / counters
  primitive census                   -> LUTx / MUXF7 / MUXF8 / CARRY4 / DSP48E1
  report_control_sets -hierarchical  -> reset/set sync structure

TCL uses @TMP@ / @PART@ placeholders (str.replace) -- never str.format --
because the script body is full of literal Tcl braces which .format() eats.

Outputs -> results/ntt_probe_*.{rpt,log,txt}
"""
import io, os, re, shutil, subprocess, sys, time

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE = os.path.join(PROJECT, "rtl", "core")
CONST = os.path.join(PROJECT, "constrains")
RESULTS = os.path.join(PROJECT, "results")

VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART = "xc7a100tcsg324-1"
TMP = "C:/tmp_ntt_probe_" + str(int(time.time()))
TMP_CORE = os.path.join(TMP, "core")
TMP_TCL = os.path.join(TMP, "synth.tcl")
TMP_LOG = os.path.join(TMP, "synth.log")
TMP_PROJ = os.path.join(TMP, "proj")

TCL = """set PROJ "@TMP@"
set CORE "$PROJ/core"
set XDC  "$PROJ/kem.xdc"
set PART "@PART@"
puts "=== LUT probe: kyber_ntt (@PART@) ==="
set WORK "$PROJ/proj"
if {[file exists $WORK]} { file delete -force $WORK }
file mkdir $WORK
create_project -force ntt_lutprobe $WORK -part $PART
add_files "$CORE/kyber_ntt.v"
catch { read_xdc $XDC }
puts "=== synth_design ==="
synth_design -top kyber_ntt -part $PART -directive RuntimeOptimized
puts "=== reports ==="
set RPT "$WORK/reports"
file mkdir $RPT
catch { report_utilization -file "$RPT/util.rpt" -hierarchical }
# report_common_property does not exist in Vivado 2026.1; dump raw per-cell
# data with pure Tcl and sort / bucket in Python.
set fh [open "$RPT/cells.txt" w]
foreach c [get_cells -hierarchical] {
    set n [get_property NUM_LUTS $c]
    set f [get_property NUM_FLOPS $c]
    set b [get_property BELS $c]
    set p [get_property PRIMITIVE $c]
    puts $fh [format "%8d %8d %-12s %-12s %s" $n $f $b $p $c]
}
close $fh
# Bucket by generated-cell name substring: isolates the coeff register
# array, the zeta ROM and the arithmetic functions from each other.
foreach pat {coeff zeta fqmul montgomery barrett block_start block_cnt zeta_cnt j_cnt cnt read_data load_data aj ajl zv state layer_idx len} {
    catch {
        set sel [get_cells -hierarchical -quiet -filter "NAME =~ *${pat}*"]
        set s 0
        set fl 0
        foreach c $sel {
            set s  [expr {$s + [get_property NUM_LUTS $c]}]
            set fl [expr {$fl + [get_property NUM_FLOPS $c]}]
        }
        puts "BUCKET *${pat}* cells=[llength $sel] LUTS=$s FLOPS=$fl"
    }
}
# Primitive census
foreach prim {LUT1 LUT2 LUT3 LUT4 LUT5 LUT6 MUXF7 MUXF8 CARRY4 DSP48E1 FDRE FDCE FDPE FDSE SRLC32E SRLC16E RAM32X1S RAM64X1S RAM64M RAM128X1S LUT1_LUT2_LUT3_LUT4_LUT5_LUT6_M XORCY8} {
    catch {
        set sel [get_cells -quiet -filter "PRIMITIVE_TYPE == $prim"]
        puts "PRIM $prim = [llength $sel]"
    }
}
catch { report_control_sets -hierarchical -file "$RPT/control_sets.rpt" }
puts "=== DONE ==="
exit
"""


def parse_log(p):
    """Pull the ROM-inference and register tables out of the synth log."""
    out = {"rom": [], "regs": [], "total_regs": 0, "lines": 0, "markers": []}
    if not os.path.exists(p):
        return out
    txt = io.open(p, encoding="utf-8", errors="replace").read()
    out["lines"] = len(txt.splitlines())
    # ROM / RAM inference table: | inst | module | 128x14 | LUT |
    for m in re.finditer(r"\|\s*([\w.\[\]]+)\s*\|\s*([\w.\[\]]+)\s*\|\s*(\d+)x(\d+)\s*\|\s*(\w+)", txt):
        out["rom"].append((m.group(1), m.group(2), int(m.group(3)),
                           int(m.group(4)), m.group(5)))
    for m in re.finditer(r"(\d+)\s+Bit\s+Registers\s*:=\s*(\d+)", txt):
        out["total_regs"] += int(m.group(1)) * int(m.group(2))
        out["regs"].append((int(m.group(1)), int(m.group(2))))
    for pat in ("Synthesis Optimization Runtime", "Synthesis Optimization Complete",
                "Translating synthesized", "Unisim Transformation completed",
                "Synth Design complete"):
        if pat in txt:
            out["markers"].append(pat)
    return out


def main():
    os.makedirs(TMP_CORE, exist_ok=True)
    shutil.copy2(os.path.join(CORE, "kyber_ntt.v"),
                 os.path.join(TMP_CORE, "kyber_ntt.v"))
    shutil.copy2(os.path.join(CONST, "kem.xdc"), os.path.join(TMP, "kem.xdc"))
    io.open(TMP_TCL, "w", encoding="utf-8").write(
        TCL.replace("@TMP@", TMP).replace("@PART@", PART))

    cmd = [VIVADO, "-mode", "batch", "-nojournal", "-log", TMP_LOG, "-source", TMP_TCL]
    t0 = time.time()
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=900,
                           cwd=TMP, errors="replace")
        rc = r.returncode
    except subprocess.TimeoutExpired:
        rc = -999
    el = time.time() - t0
    print("rc=%s  elapsed=%.1fs" % (rc, el))

    log_dst = os.path.join(RESULTS, "ntt_probe_synth.log")
    if os.path.exists(TMP_LOG):
        shutil.copy2(TMP_LOG, log_dst)
        print("log -> %s (%d bytes)" % (log_dst, os.path.getsize(log_dst)))
    copied = []
    rpt = os.path.join(TMP_PROJ, "reports")
    if os.path.isdir(rpt):
        for f in sorted(os.listdir(rpt)):
            dst = os.path.join(RESULTS, "ntt_probe_" + f)
            shutil.copy2(os.path.join(rpt, f), dst)
            copied.append("%s (%d B)" % (f, os.path.getsize(dst)))
    print("reports ->", ", ".join(copied) if copied else "(none)")

    # ---- ROM inference -------------------------------------------------
    info = parse_log(TMP_LOG)
    print("\n--- markers reached ---")
    print("  " + (", ".join(info["markers"]) if info["markers"] else "NONE"))
    print("\n--- ROM/RAM inference rows (log) ---")
    tot = 0
    for inst, mod, d, w, typ in sorted(info["rom"], key=lambda x: -x[2] * x[3]):
        print("  %-34s %-14s %4dx%-3d  %s   = %7d LUTs"
              % (inst, mod, d, w, typ, d * w))
        tot += d * w
    print("  ROM-inferred LUT total: %d" % tot)
    if info["total_regs"]:
        print("  register bits from 'N Bit Registers := C' rows: %d" % info["total_regs"])

    # ---- per-cell dump --------------------------------------------------
    pc = os.path.join(RESULTS, "ntt_probe_cells.txt")
    rows = []
    if os.path.exists(pc):
        for ln in io.open(pc, encoding="utf-8", errors="replace"):
            m = re.match(r"\s*(\d+)\s+(\d+)\s+(\S+)\s+(\S+)\s+(\S+)", ln)
            if m:
                rows.append((int(m.group(1)), int(m.group(2)),
                             m.group(3), m.group(4), m.group(5)))
        rows.sort(reverse=True)
        print("\n--- top 30 generated cells by NUM_LUTS ---")
        cum = 0
        for n, f, bel, p, name in rows[:30]:
            cum += n
            print("  %7d LUT %6d FF %-11s %-12s %s" % (n, f, bel, p, name))
        print("  (cumulative of top 30: %d)" % cum)
        npos = [r for r in rows if r[0] > 0]
        fpos = [r for r in rows if r[1] > 0]
        print("  cells with >0 LUTs: %d / %d, LUT sum=%d"
              % (len(npos), len(rows), sum(r[0] for r in rows)))
        print("  cells with >0 FFs : %d, FF sum=%d" % (len(fpos), sum(r[1] for r in rows)))
        srt = os.path.join(RESULTS, "ntt_probe_cells_sorted.txt")
        io.open(srt, "w", encoding="utf-8").write(
            "\n".join("%8d %8d %-12s %-12s %s" % (n, f, b, p, nm)
                      for n, f, b, p, nm in rows) + "\n")
        print("  full list -> %s" % srt)

    t = io.open(TMP_LOG, encoding="utf-8", errors="replace").read() \
        if os.path.exists(TMP_LOG) else ""

    # ---- name buckets --------------------------------------------------
    print("\n--- name-substring buckets (LUTS only, top consumers first) ---")
    bks = []
    for ln in t.splitlines():
        m = re.match(r"\s*BUCKET \*(\*)*([^*]+)\*", ln)
        if not m:
            continue
        nums = ln.split()
        cells = luts = flops = 0
        for k, v in enumerate(nums):
            if v.startswith("cells="):
                cells = int(v.split("=")[1])
            elif v.startswith("LUTS="):
                luts = int(v.split("=")[1])
            elif v.startswith("FLOPS="):
                flops = int(v.split("=")[1])
        bks.append((luts, flops, cells, m.group(2)))
    for luts, flops, cells, pat in sorted(bks, reverse=True):
        print("  *%-14s LUTS=%-7d FFs=%-6d cells=%d" % (pat, luts, flops, cells))

    # ---- primitive census ---------------------------------------------
    print("\n--- primitive census (post-synthesis) ---")
    cens = {}
    for ln in t.splitlines():
        m = re.match(r"\s*PRIM (\S+) = (\d+)", ln)
        if m:
            cens[m.group(1)] = cens.get(m.group(1), 0) + int(m.group(2))
    for k in sorted(cens, key=lambda x: -cens[x]):
        if cens[k]:
            print("  %-14s %d" % (k, cens[k]))

    # ---- util ---------------------------------------------------------
    pu = os.path.join(RESULTS, "ntt_probe_util.rpt")
    if os.path.exists(pu):
        print("\n--- report_utilization -hierarchical ---")
        for ln in io.open(pu, encoding="utf-8", errors="replace"):
            s = ln.rstrip()
            if s.startswith("|") or s.startswith("+--"):
                print("  " + s[:160])

    return 0 if rc == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
