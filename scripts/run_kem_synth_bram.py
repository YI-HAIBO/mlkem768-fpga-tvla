#!/usr/bin/env python3
"""
Full-top kyber_kem synthesis with BRAM-annotated polynomial arrays.
- Copies 6 core .v files + kem.xdc to a timestamped ASCII tmp dir
- synth_design -top kyber_kem -part xc7a100tcsg324-1 -directive RuntimeOptimized
- Emits results/kem_bram_synth_{util,timing}.rpt + log
- Parses LUT / FF / DSP / BRAM / WNS + counts latch / dissolved-RAM warnings
"""
import subprocess, os, sys, shutil, time, io, re

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
CONST     = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")

TS       = str(int(time.time()))
TMP      = "C:/tmp_kem_bram_" + TS
TMP_CORE = os.path.join(TMP, "core")
TMP_XDC  = os.path.join(TMP, "kem.xdc")
TMP_TCL  = os.path.join(TMP, "synth.tcl")
TMP_LOG  = os.path.join(TMP, "synth.log")
TMP_PROJ = os.path.join(TMP, "proj")

VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART   = "xc7a100tcsg324-1"
DIRECTIVE = "RuntimeOptimized"

FILES = ["shake.v", "keccak_perm.v", "kyber_ntt.v", "kyber_poly.v", "kyber_sampler.v", "kyber_kem.v"]


def build_tcl():
    L = []
    L.append('set PROJ "' + TMP.replace("\\", "/") + '"')
    L.append('set CORE "$PROJ/core"')
    L.append('set XDC  "$PROJ/kem.xdc"')
    L.append('set PART "' + PART + '"')
    L.append('puts "=== Vivado synth kyber_kem (ML-KEM-768) BRAM-annotated ==="')
    L.append('puts "Time: [clock format [clock seconds]]"')
    L.append('puts "Part: $PART  Directive: ' + DIRECTIVE + '"')
    L.append('set WORK "$PROJ/proj"')
    L.append('if {[file exists $WORK]} { file delete -force $WORK }')
    L.append('file mkdir $WORK')
    L.append('create_project -force kem_bram_synth $WORK -part $PART')
    L.append('foreach f {' + ' '.join(FILES) + '} {')
    L.append('    add_files "$CORE/$f"')
    L.append('}')
    L.append('read_xdc $XDC')
    L.append('puts "=== synth_design ==="')
    L.append('synth_design -top kyber_kem -part $PART -directive ' + DIRECTIVE)
    L.append('puts "=== reports ==="')
    L.append('set RPT "$WORK/reports"')
    L.append('file mkdir $RPT')
    L.append('report_utilization -file "$RPT/util.rpt" -hierarchical')
    L.append('report_timing_summary -file "$RPT/timing.rpt" -delay_type minmax -warn_on_timing -max_paths 3')
    L.append('report_control_sets -hierarchical -file "$RPT/control_sets.rpt"')
    L.append('puts "=== Done ==="')
    L.append('exit')
    return "\n".join(L)


def parse_util(path):
    """Extract slice LUTs / registers / DSP / BRAM from a utilization report."""
    out = {}
    if not os.path.exists(path):
        return out
    txt = io.open(path, "r", encoding="utf-8", errors="replace").read()
    pat = {
        "Slice LUTs":        r"Slice LUTs\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)",
        "Slice Registers":   r"Slice Registers\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)",
        "DSPs":              r"DSPs?\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)",
        "Block RAM Tile":    r"Block RAM Tile\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)",
        "F7 Muxes":          r"F7 Muxes\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)",
    }
    for k, rx in pat.items():
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
                  ("WHN", r"WHN\s+\n?\s+([\-\d.]+)"),
                  ("Fmax", r"Fmax\s+\n?\s+([\d.]+)")]:
        m = re.search(rx, txt)
        if m:
            out[k] = m.group(1)
    m = re.search(r"Design Timing Summary\s*\n[^\n]*\n[^\n]*\n([^\n]*)", txt)
    if m:
        out["_hdr"] = m.group(1).strip()[:160]
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

    # Copy log
    log_dst = os.path.join(RESULTS, "kem_bram_synth.log")
    if os.path.exists(TMP_LOG):
        shutil.copy2(TMP_LOG, log_dst)
        print("Log -> %s (%d bytes)" % (log_dst, os.path.getsize(log_dst)))

    rpt_dir = os.path.join(TMP_PROJ, "reports")
    for rf in ["util.rpt", "timing.rpt", "control_sets.rpt"]:
        src = os.path.join(rpt_dir, rf)
        if os.path.exists(src):
            dst = os.path.join(RESULTS, "kem_bram_synth_" + rf.replace(".rpt", "") + ".rpt")
            shutil.copy2(src, dst)
            print("Report: %s (%d bytes)" % (rf, os.path.getsize(src)))

    # Parse & summarize
    lines = []
    lines.append("kyber_kem full-top synth (BRAM-annotated), part=%s, directive=%s" % (PART, DIRECTIVE))
    lines.append("rc=%s  elapsed=%.1fs" % (rc, elapsed))
    lines.append("")
    lines.append("--- Utilization ---")
    u = parse_util(os.path.join(rpt_dir, "util.rpt"))
    if u:
        for k in ["Slice LUTs", "Slice Registers", "DSPs", "Block RAM Tile"]:
            if k in u:
                lines.append("%-18s used=%-9s avail=%-9s pct=%s%%"
                             % (k, u[k]["used"], u[k]["avail"], u[k]["pct"]))
    else:
        lines.append("(no util.rpt)")
    lines.append("")
    lines.append("--- Timing ---")
    t = parse_timing(os.path.join(rpt_dir, "timing.rpt"))
    if t:
        for k in ["WNS", "WHN", "Fmax"]:
            if k in t:
                lines.append("%-4s %s" % (k, t[k]))
    else:
        lines.append("(no timing.rpt)")

    # Warning/error counts from log
    log = ""
    if os.path.exists(TMP_LOG):
        log = io.open(TMP_LOG, "r", encoding="utf-8", errors="replace").read()
    lines.append("")
    lines.append("--- Log diagnostics ---")
    errs   = [l for l in log.splitlines() if "ERROR:" in l]
    latches= [l for l in log.splitlines() if "inferring latch for variable" in l]
    diss   = [l for l in log.splitlines() if "dissolved" in l.lower()]
    bram_w = [l for l in log.splitlines() if "8-11357" in l or "8-13159" in l or "8-3876" in l]
    lines.append("ERROR: lines              = %d" % len(errs))
    lines.append("latch inferred            = %d" % len(latches))
    lines.append("RAM dissolved-to-register = %d" % len(diss))
    lines.append("ram-inference warnings    = %d" % len(bram_w))
    for l in latches[:6]:
        lines.append("   LATCH: " + l.strip()[:180])
    for l in diss[:6]:
        lines.append("   DISSOLVE: " + l.strip()[:180])
    for l in errs[:6]:
        lines.append("   ERR: " + l.strip()[:180])

    # RTL component stats (register/multiplier footprint) - tells us FF pressure
    lines.append("")
    lines.append("--- RTL register footprint (from log) ---")
    for ln in log.splitlines():
        s = ln.strip()
        if re.match(r"\d+\s+(?:Bit|Bit)\s+Registers\s+:=", s) or "Bit    Registers :=" in s:
            lines.append("   " + s)
        elif "Multipliers :=" in s and "Multip" not in s and re.search(r"\d+x\d+\s+Multipliers", s):
            lines.append("   " + s)

    rep = os.path.join(RESULTS, "kem_bram_synth_summary.txt")
    io.open(rep, "w", encoding="utf-8").write("\n".join(lines))
    print("\n===== SUMMARY =====")
    print("\n".join(lines))
    print("\nSummary -> %s" % rep)
    return 0 if rc == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
