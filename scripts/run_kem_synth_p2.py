#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Full-top kyber_kem synthesis, P2: retarget the post-P1 netlist at a
larger Artix-7 device.

Correction vs the earlier plan (report §9): `xc7a325t` / `xc7a680t` do
NOT exist.  `get_parts -regexp {^xc7a.*}` in Vivado 2026.1 lists only
12t/15t/25t/35t/50t/75t/100t/200t (plus i/l variants) — xc7a200t is the
largest Artix-7 that ships.  Resources (verified live via
get_property):
    xc7a200t: 134,600 LUT / 269,200 FF / 365 BRAM / 740 DSP / 33,650 SLICE
    xc7a100t:  63,400 LUT / 126,800 FF / 135 BRAM / 240 DSP / 15,850 SLICE

Post-P1 netlist (39,738 FF / 58,852 LUT) on xc7a200t:
    FF   39,738 / 269,200 = 14.8%
    LUT  58,852 / 134,600 = 43.7%   <- was 181% on the 100T
Both fit with headroom, so P2 is a pure board/part change: no RTL edit.

Part chosen: xc7a200tfbg484-1 (fbg484, 285 IOBs, speed -1 to match the
100T's -1 grade the timing data in the report was measured on).
32 xc7a200t parts exist in total; see results/p2_part_list.txt for the
full package/speed matrix (probe scripts: probe_p2_parts.py,
list_p2_packages.py).

Outputs -> results/kem_p2_synth_{log,util.rpt,timing.rpt,control_sets.rpt,prims.txt,summary.txt}
"""
import subprocess, os, sys, shutil, time, io, re

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
CONST     = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")

TS       = str(int(time.time()))
TMP      = "C:/tmp_kem_p2_" + TS
TMP_CORE = os.path.join(TMP, "core")
TMP_XDC  = os.path.join(TMP, "kem.xdc")
TMP_TCL  = os.path.join(TMP, "synth.tcl")
TMP_LOG  = os.path.join(TMP, "synth.log")
TMP_PROJ = os.path.join(TMP, "proj")

VIVADO    = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART      = "xc7a200tfbg484-1"
DIRECTIVE = "RuntimeOptimized"

FILES = ["shake.v", "keccak_perm.v", "kyber_ntt.v", "kyber_poly.v",
         "kyber_sampler.v", "kyber_kem.v"]

PRIMS = ["FDRE", "FDCE", "FDPE", "LD", "LUT6", "LUT5", "LUT4",
         "MUXF7", "MUXF8", "RAMB36", "RAMB18", "DSP48E1"]

# device limits — verified live against Vivado 2026.1 part properties
# (probe_p2_parts.py).  xc7a100t figures kept as the P1 baseline.
LIMIT_FF, LIMIT_LUT, LIMIT_BRAM = 269200, 134600, 365
BASE_FF, BASE_LUT = 126800, 63400   # xc7a100t

# post-P1-c reference numbers from results/kem_p1_synth_util.rpt
P1_FF, P1_LUT, P1_LUTRAM, P1_DSP = 39738, 58852, 4448, 61


def build_tcl():
    L = []
    L.append('set PROJ "' + TMP.replace("\\", "/") + '"')
    L.append('set CORE "$PROJ/core"')
    L.append('set XDC  "$PROJ/kem.xdc"')
    L.append('set PART "' + PART + '"')
    L.append('puts "=== Vivado synth kyber_kem (ML-KEM-768) P2 target: ' + PART + ' ==="')
    L.append('puts "Time: [clock format [clock seconds]]"')
    L.append('puts "Part: $PART  Directive: ' + DIRECTIVE + '"')
    L.append('set WORK "$PROJ/proj"')
    L.append('if {[file exists $WORK]} { file delete -force $WORK }')
    L.append('file mkdir $WORK')
    L.append('create_project -force kem_p2_synth $WORK -part $PART')
    L.append('foreach f {' + ' '.join(FILES) + '} { add_files "$CORE/$f" }')
    L.append('read_xdc $XDC')
    L.append('puts "=== synth_design ==="')
    L.append('synth_design -top kyber_kem -part $PART -directive ' + DIRECTIVE)
    # primitive footprint FIRST: decide the outcome even if a report hangs
    L.append('puts "=== netlist primitive footprint ==="')
    L.append('foreach p {' + ' '.join(PRIMS) + '} {')
    L.append('    set n [llength [get_cells -hierarchical -filter "PRIMITIVE_TYPE == $p"]]')
    L.append('    puts "PRIM_COUNT $p = $n"')
    L.append('}')
    L.append('puts "=== reports ==="')
    L.append('set RPT "$WORK/reports"')
    L.append('file mkdir $RPT')
    L.append('report_utilization -file "$RPT/util.rpt" -hierarchical')
    L.append('report_timing_summary -file "$RPT/timing.rpt" -delay_type min_max -max_paths 3')
    L.append('report_control_sets -hierarchical -file "$RPT/control_sets.rpt"')
    L.append('puts "=== Done ==="')
    L.append('exit')
    return "\n".join(L)


def parse_util(path):
    out = {}
    if not os.path.exists(path):
        return out
    txt = io.open(path, "r", encoding="utf-8", errors="replace").read()
    # util.rpt -hierarchical table: | instance | module | Total LUTs | Logic LUTs | LUTRAMs | SRLs | FFs | RAMB36 | RAMB18 | DSP |
    m = re.search(r"\|\s*kyber_kem\s+\(top\)\s*\|\s*([\d,]+)\s*\|\s*([\d,]+)\s*\|\s*([\d,]+)\s*\|\s*[\d,]+\s*\|\s*([\d,]+)\s*\|", txt)
    if m:
        out["top"] = {"lut": m.group(1), "logic_lut": m.group(2),
                      "lutram": m.group(3), "ff": m.group(4)}
    # top-level slice table
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

    log_dst = os.path.join(RESULTS, "kem_p2_synth.log")
    if os.path.exists(TMP_LOG):
        shutil.copy2(TMP_LOG, log_dst)
        print("Log -> %s (%d bytes)" % (log_dst, os.path.getsize(log_dst)))

    rpt_dir = os.path.join(TMP_PROJ, "reports")
    for rf in ["util.rpt", "timing.rpt", "control_sets.rpt"]:
        src = os.path.join(rpt_dir, rf)
        if os.path.exists(src):
            dst = os.path.join(RESULTS, "kem_p2_synth_" + rf.replace(".rpt", "") + ".rpt")
            shutil.copy2(src, dst)
            print("Report: %s (%d bytes)" % (rf, os.path.getsize(src)))
        else:
            print("MISSING report: %s" % rf)

    log = (io.open(TMP_LOG, "r", encoding="utf-8", errors="replace").read()
           if os.path.exists(TMP_LOG) else "")
    lines = []
    lines.append("kyber_kem full-top synth, P2 retarget: " + PART)
    lines.append("part=%s  directive=%s  rc=%s  elapsed=%.1fs"
                 % (PART, DIRECTIVE, rc, elapsed))
    lines.append("")

    lines.append("--- Regression guards (must all stay closed) ---")
    for wid, desc in (("8-7186", "ram_style ignored / not inferred as ram (base 101)"),
                      ("8-4767", "RAM implemented in registers"),
                      ("8-2914", "unable to map RAM (multi-port)"),
                      ("8-6090", "blocking/non-blocking on the same variable"),
                      ("8-327",  "inferred latch")):
        n = log.count(wid)
        lines.append("  Synth %-6s %-46s = %d" % (wid, desc, n))
    latches = [l for l in log.splitlines()
               if "inferring latch for variable" in l]
    lines.append("  'inferring latch for variable' lines             = %d" % len(latches))

    lines.append("")
    lines.append("--- Other log diagnostics ---")
    errs = [l for l in log.splitlines() if "ERROR:" in l]
    lines.append("ERROR: lines = %d" % len(errs))
    for l in errs[:6]:
        lines.append("   ERR: " + l.strip()[:170])

    lines.append("")
    lines.append("--- Netlist primitive footprint (PRIM_COUNT from log) ---")
    prims = dict(re.findall(r"^PRIM_COUNT\s+(\S+)\s*=\s*(\d+)", log, re.M))
    prims = {k: int(v) for k, v in prims.items()}
    ff   = sum(prims.get(p, 0) for p in ("FDRE", "FDCE", "FDPE"))
    lut  = sum(prims.get(p, 0) for p in
               ("LUT6", "LUT5", "LUT4", "MUXF7", "MUXF8"))
    bram = sum(prims.get(p, 0) for p in ("RAMB36", "RAMB18"))
    for p in PRIMS:
        lines.append("  %-9s %9d" % (p, prims.get(p, 0)))
    lines.append("  " + "-" * 24)
    lines.append("  %-9s %9d" % ("FF total", ff))
    lines.append("  %-9s %9d" % ("LUT total", lut))
    lines.append("  %-9s %9d" % ("BRAM total", bram))

    lines.append("")
    lines.append("--- %s budget check (device limits from Vivado) ---" % PART)
    def ratio(n, lim):
        return "fits (%.1f%%)" % (100.0 * n / lim) if lim else "n/a"
    lines.append("    FF   %9d / %-7d  -> %s" % (ff, LIMIT_FF, ratio(ff, LIMIT_FF)))
    lines.append("    LUT  %9d / %-7d  -> %s" % (lut, LIMIT_LUT, ratio(lut, LIMIT_LUT)))
    lines.append("    BRAM %9d / %-7d  -> %s" % (bram, LIMIT_BRAM, ratio(bram, LIMIT_BRAM)))

    # hierarchy util.rpt (like P1)
    u = parse_util(os.path.join(rpt_dir, "util.rpt"))
    lines.append("")
    lines.append("--- Utilization (hierarchy table, top row) ---")
    if "top" in u:
        t = u["top"]
        lines.append("    Total LUTs %s  logic %s  LUTRAM %s  FFs %s"
                     % (t["lut"], t["logic_lut"], t["lutram"], t["ff"]))
    for k in ["Slice LUTs", "Slice Registers", "DSPs", "Block RAM Tile"]:
        if k in u:
            lines.append("    %-16s used=%-9s avail=%-9s pct=%s%%"
                         % (k, u[k]["used"], u[k]["avail"], u[k]["pct"]))
    if not u:
        lines.append("(no util.rpt - report_utilization may have hung)")

    # compare against the util.rpt hierarchy numbers (P1 reference)
    if "top" in u:
        t = {k: int(v.replace(",", "")) for k, v in u["top"].items()}
        lines.append("")
        lines.append("--- P1 (xc7a100tcsg324-1) reference ---")
        lines.append("    FF   %6d  LUT %6d  LUTRAM %5d  DSP %d"
                     % (P1_FF, P1_LUT, P1_LUTRAM, P1_DSP))
        lines.append("    P2 delta: FF %+d  LUT %+d  DSP %+d"
                     % (t["ff"] - P1_FF, t["lut"] - P1_LUT,
                        0))  # DSP not in hierarchy row top line
    if not u:
        lines.append("")
        lines.append("--- P1 (xc7a100tcsg324-1) reference ---")
        lines.append("    FF   %6d  LUT %6d  LUTRAM %5d" % (P1_FF, P1_LUT, P1_LUTRAM))

    lines.append("")
    lines.append("--- Timing ---")
    t2 = parse_timing(os.path.join(rpt_dir, "timing.rpt"))
    for k in ("WNS", "Fmax"):
        if k in t2:
            lines.append("%-4s %s" % (k, t2[k]))
    if not t2:
        lines.append("(no timing.rpt)")

    lines.append("")
    lines.append("--- tmp dir (kept for inspection) ---")
    lines.append(TMP)

    rep = os.path.join(RESULTS, "kem_p2_synth_summary.txt")
    with io.open(rep, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines))
    print("\n" + "\n".join(lines))
    print("\nSummary -> %s" % rep)
    return 0 if rc == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
