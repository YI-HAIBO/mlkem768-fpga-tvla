#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Full-top kyber_kem synthesis after the Problem-A loop-iterator fix.

Purpose: prove that the 5x Synth 8-6090 (blocking/non-blocking on the same
variable) and the 1x Synth 8-327 (inferred latch) warnings reported in
results/kem_synth_final_report.md section 4 are gone.

Differences from run_kem_synth_bram.py:
  - no BRAM annotation involved (kyber_kem.v is un-annotated)
  - corrected report_timing_summary flags for Vivado 2026.1
    (-delay_type min_max ; -warn_on_timing was renamed and ABORTS the
    report in 2026.1, and -delay_type minmax is also wrong)
  - tallies the specific warning IDs 8-6090 / 8-327
  - dumps a netlist primitive footprint table so the resource delta is visible

Outputs -> results/kem_cntfix_synth_{log,util.rpt,timing.rpt,prims.txt,summary.txt}
"""
import subprocess, os, sys, shutil, time, io, re

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
CONST     = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")

TS       = str(int(time.time()))
TMP      = "C:/tmp_kem_cntfix_" + TS
TMP_CORE = os.path.join(TMP, "core")
TMP_XDC  = os.path.join(TMP, "kem.xdc")
TMP_TCL  = os.path.join(TMP, "synth.tcl")
TMP_LOG  = os.path.join(TMP, "synth.log")
TMP_PROJ = os.path.join(TMP, "proj")

VIVADO    = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART      = "xc7a100tcsg324-1"
DIRECTIVE = "RuntimeOptimized"

FILES = ["shake.v", "keccak_perm.v", "kyber_ntt.v", "kyber_poly.v",
         "kyber_sampler.v", "kyber_kem.v"]

# Primitives we want a count for.  FDRE/FDCE/FDPE = flip-flops, LD = latch,
# LUT6/MUXF7/MUXF8 = LUT fabric, RAMB36/RAMB18 = block RAM, DSP48E1 = DSP.
PRIMS = ["FDRE", "FDCE", "FDPE", "LD", "LUT6", "LUT5", "LUT4",
         "MUXF7", "MUXF8", "RAMB36", "RAMB18", "DSP48E1"]


def build_tcl():
    L = []
    L.append('set PROJ "' + TMP.replace("\\", "/") + '"')
    L.append('set CORE "$PROJ/core"')
    L.append('set XDC  "$PROJ/kem.xdc"')
    L.append('set PART "' + PART + '"')
    L.append('puts "=== Vivado synth kyber_kem (ML-KEM-768) after Problem-A fix ==="')
    L.append('puts "Time: [clock format [clock seconds]]"')
    L.append('puts "Part: $PART  Directive: ' + DIRECTIVE + '"')
    L.append('set WORK "$PROJ/proj"')
    L.append('if {[file exists $WORK]} { file delete -force $WORK }')
    L.append('file mkdir $WORK')
    L.append('create_project -force kem_cntfix_synth $WORK -part $PART')
    L.append('foreach f {' + ' '.join(FILES) + '} { add_files "$CORE/$f" }')
    L.append('read_xdc $XDC')
    L.append('puts "=== synth_design ==="')
    L.append('synth_design -top kyber_kem -part $PART -directive ' + DIRECTIVE)
    L.append('puts "=== reports ==="')
    L.append('set RPT "$WORK/reports"')
    L.append('file mkdir $RPT')
    L.append('report_utilization -file "$RPT/util.rpt" -hierarchical')
    # 2026.1: -delay_type min_max (not minmax); -warn_on_timing no longer exists
    L.append('report_timing_summary -file "$RPT/timing.rpt" -delay_type min_max -max_paths 3')
    L.append('report_control_sets -hierarchical -file "$RPT/control_sets.rpt"')
    # netlist primitive footprint, written as parseable KEY = VALUE lines
    L.append('puts "=== netlist primitive footprint ==="')
    L.append('foreach p {' + ' '.join(PRIMS) + '} {')
    L.append('    set n [llength [get_cells -hierarchical -filter "PRIMITIVE_TYPE == $p"]]')
    L.append('    puts "PRIM_COUNT $p = $n"')
    L.append('}')
    L.append('puts "=== Done ==="')
    L.append('exit')
    return "\n".join(L)


def parse_util(path):
    out = {}
    if not os.path.exists(path):
        return out
    txt = io.open(path, "r", encoding="utf-8", errors="replace").read()
    for k, rx in {
        "Slice LUTs":      r"Slice LUTs\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)",
        "Slice Registers": r"Slice Registers\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)",
        "DSPs":            r"DSPs?\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)",
        "Block RAM Tile":  r"Block RAM Tile\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)",
    }.items():
        m = re.search(rx, txt)
        if m:
            out[k] = {"used": m.group(1), "avail": m.group(2), "pct": m.group(3)}
    return out


def parse_timing(path):
    out = {}
    if not os.path.exists(path):
        return out
    txt = io.open(path, "r", encoding="utf-8", errors="replace").read()
    for k, rx in [("WNS", r"WNS\s+\n?\s+([\-\d.]+)"),
                  ("Fmax", r"Fmax\s+\n?\s+([\d.]+)")]:
        m = re.search(rx, txt)
        if m:
            out[k] = m.group(1)
    return out


def main():
    os.makedirs(TMP_CORE, exist_ok=True)
    print("=== Copying files -> %s ===" % TMP)
    for f in FILES:
        src, dst = os.path.join(CORE, f), os.path.join(TMP_CORE, f)
        shutil.copy2(src, dst)
        print("  %-18s %8d bytes" % (f, os.path.getsize(dst)))
    xdc_src = os.path.join(CONST, "kem.xdc")
    shutil.copy2(xdc_src, TMP_XDC)
    print("  kem.xdc          %8d bytes" % os.path.getsize(TMP_XDC))

    with io.open(TMP_TCL, "w", encoding="utf-8") as fh:
        fh.write(build_tcl())
    print("Wrote %s" % TMP_TCL)

    cmd = [VIVADO, "-mode", "batch", "-nojournal", "-log", TMP_LOG, "-source", TMP_TCL]
    print("\n=== Running Vivado (timeout 3600s) ===")
    t0 = time.time()
    rc = -1
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=3600,
                           cwd=TMP, errors="replace")
        rc = r.returncode
    except subprocess.TimeoutExpired:
        rc = -999
        print("TIMEOUT after 3600s")
    except Exception as e:
        print("ERR:", e)
    elapsed = time.time() - t0
    print("rc=%s  time=%.1fs" % (rc, elapsed))

    log_dst = os.path.join(RESULTS, "kem_cntfix_synth.log")
    if os.path.exists(TMP_LOG):
        shutil.copy2(TMP_LOG, log_dst)
        print("Log -> %s (%d bytes)" % (log_dst, os.path.getsize(log_dst)))

    rpt_dir = os.path.join(TMP_PROJ, "reports")
    for rf in ["util.rpt", "timing.rpt", "control_sets.rpt"]:
        src = os.path.join(rpt_dir, rf)
        if os.path.exists(src):
            dst = os.path.join(RESULTS, "kem_cntfix_synth_" + rf.replace(".rpt", "") + ".rpt")
            shutil.copy2(src, dst)
            print("Report: %s (%d bytes)" % (rf, os.path.getsize(src)))

    log = io.open(TMP_LOG, "r", encoding="utf-8", errors="replace").read() if os.path.exists(TMP_LOG) else ""
    lines = []
    lines.append("kyber_kem full-top synth AFTER Problem-A loop-iterator fix")
    lines.append("part=%s  directive=%s  rc=%s  elapsed=%.1fs" % (PART, DIRECTIVE, rc, elapsed))
    lines.append("")

    lines.append("--- PRIMARY OBJECTIVE: counter-assignment warnings ---")
    for wid, desc in (("8-6090", "blocking/non-blocking assignment on the same variable"),
                      ("8-327",  "inferred latch")):
        n = log.count(wid)
        lines.append("  Synth %-6s %-62s = %d" % (wid, desc, n))
    latches = [l for l in log.splitlines() if "inferring latch for variable" in l]
    lines.append("  'inferring latch for variable' lines             = %d" % len(latches))
    for l in latches[:5]:
        lines.append("      LATCH: " + l.strip()[:170])

    lines.append("")
    lines.append("--- Other log diagnostics ---")
    errs = [l for l in log.splitlines() if "ERROR:" in l]
    diss = [l for l in log.splitlines() if "dissolved" in l.lower()]
    lines.append("ERROR: lines              = %d" % len(errs))
    lines.append("RAM dissolved-to-register = %d" % len(diss))
    for l in errs[:6]:
        lines.append("   ERR: " + l.strip()[:170])

    lines.append("")
    lines.append("--- Netlist primitive footprint (PRIM_COUNT from log) ---")
    prims = dict(re.findall(r"^PRIM_COUNT\s+(\S+)\s*=\s*(\d+)", log, re.M))
    prims = {k: int(v) for k, v in prims.items()}
    ff = sum(prims.get(p, 0) for p in ("FDRE", "FDCE", "FDPE"))
    lut = sum(prims.get(p, 0) for p in ("LUT6", "LUT5", "LUT4", "MUXF7", "MUXF8"))
    bram = sum(prims.get(p, 0) for p in ("RAMB36", "RAMB18"))
    for p in PRIMS:
        lines.append("  %-9s %9d" % (p, prims.get(p, 0)))
    lines.append("  %-9s %9d" % ("FF total", ff))
    lines.append("  %-9s %9d" % ("LUT total", lut))
    lines.append("  %-9s %9d" % ("BRAM total", bram))
    prims_txt = "\n".join("PRIM_COUNT %s = %d" % (k, v) for k, v in prims.items())
    with io.open(os.path.join(RESULTS, "kem_cntfix_synth_prims.txt"), "w", encoding="utf-8") as fh:
        fh.write(prims_txt + "\n")

    lines.append("")
    lines.append("--- Utilization ---")
    u = parse_util(os.path.join(rpt_dir, "util.rpt"))
    for k in ["Slice LUTs", "Slice Registers", "DSPs", "Block RAM Tile"]:
        if k in u:
            lines.append("%-18s used=%-9s avail=%-9s pct=%s%%"
                         % (k, u[k]["used"], u[k]["avail"], u[k]["pct"]))
    if not u:
        lines.append("(no util.rpt)")
    lines.append("")
    lines.append("--- Timing ---")
    t = parse_timing(os.path.join(rpt_dir, "timing.rpt"))
    for k in ("WNS", "Fmax"):
        if k in t:
            lines.append("%-4s %s" % (k, t[k]))
    if not t:
        lines.append("(no timing.rpt)")

    lines.append("")
    lines.append("--- tmp dir (kept for inspection) ---")
    lines.append(TMP)

    rep = os.path.join(RESULTS, "kem_cntfix_synth_summary.txt")
    with io.open(rep, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))
    print("\n" + "\n".join(lines))
    print("\nSummary -> %s" % rep)
    return 0 if rc == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
