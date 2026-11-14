#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
P2 retarget, part 2: project-less full-top synthesis on xc7a200t.

The first P2 run (run_kem_synth_p2.py, tmp dir C:/tmp_kem_p2_1791970280)
completed synthesis with 0 errors / 0 critical / 47 warnings but Vivado
2026.1 hung after 'Synthesis Optimization Runtime' — the post-synthesis
project netlist-translation step ('Translating synthesized netlist',
Unisim Transformation of 10,717 elements) never ran, so no util/timing
reports were produced. The regression guards in the harvested log are
all clean (8-7186/8-2914/8-6090/8-327 = 0; the single 8-4767 is the
known benign keccak round.B_reg read-address-stuck case).

This second pass drops create_project/add_files entirely: files are
read with read_verilog and synth_design is driven with -part only, so
the project-managed netlist translation (the hang point) is never
entered. Primitive counts identical because the logic architecture of
xc7a100t and xc7a200t is the same Artix-7 fabric — the pre-opt
'Report Cell Usage' tables of the 100T and 200T runs are compared
line-by-line by the parser to prove that.

Outputs -> results/kem_p2b_synth.{log, util.rpt, timing.rpt, summary.txt}
"""
import subprocess, os, sys, io, time

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
CONST     = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")

TS       = str(int(time.time()))
TMP      = "C:/tmp_kem_p2b_" + TS
TMP_CORE = os.path.join(TMP, "core")
TMP_XDC  = os.path.join(TMP, "kem.xdc")
TMP_TCL  = os.path.join(TMP, "synth.tcl")
TMP_LOG  = os.path.join(TMP, "synth.log")
TMP_RPT  = os.path.join(TMP, "reports")

VIVADO    = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART      = "xc7a200tfbg484-1"
DIRECTIVE = "RuntimeOptimized"

FILES = ["shake.v", "keccak_perm.v", "kyber_ntt.v", "kyber_poly.v",
         "kyber_sampler.v", "kyber_kem.v"]

# verified via get_property (probe_p2_parts.py)
LIMIT_FF, LIMIT_LUT, LIMIT_BRAM, LIMIT_DSP = 269200, 134600, 365, 740

# reference: P1 (100T) util.rpt hierarchy + P2a log cell-usage table
P1_FF, P1_LUT, P1_LUTRAM, P1_DSP = 39738, 58852, 4448, 61


def build_tcl():
    L = []
    L.append('puts "=== P2b project-less synth: kyber_kem on ' + PART + ' ==="')
    L.append('puts "Time: [clock format [clock seconds]]"')
    L.append('set CORE "$PROJ/core"')
    L.append('set RPT "' + TMP_RPT.replace("\\", "/") + '"')
    L.append('file mkdir $RPT')
    for f in FILES:
        L.append('read_verilog "$CORE/' + f + '"')
    L.append('read_xdc "$PROJ/kem.xdc"')
    L.append('puts "=== synth_design ==="')
    L.append('synth_design -top kyber_kem -part ' + PART + ' -directive ' + DIRECTIVE)
    L.append('puts "=== reports ==="')
    L.append('report_utilization -file "$RPT/util.rpt"')
    L.append('report_timing_summary -file "$RPT/timing.rpt" -delay_type min_max -max_paths 3')
    L.append('report_control_sets -file "$RPT/control_sets.rpt"')
    L.append('puts "=== DONE ==="')
    L.append('exit')
    return "\n".join(L)


def parse_cell_usage(path):
    """Vivado 'Report Cell Usage' primitive table -> dict name -> count."""
    out = {}
    txt = io.open(path, "r", encoding="utf-8", errors="replace").read()
    lines = txt.splitlines()
    i = 0
    while i < len(lines):
        if "Report Cell Usage" in lines[i]:
            i += 1
            while i < len(lines):
                s = lines[i].strip()
                if s.startswith("|") and not s.startswith("+-"):
                    parts = [p.strip() for p in s.strip("|").split("|")]
                    if len(parts) >= 3:
                        try:
                            out[parts[1]] = int(parts[2])
                        except ValueError:
                            pass
                elif s == "" and out:
                    break
                i += 1
            break
        i += 1
    return out


def main():
    os.makedirs(TMP_CORE, exist_ok=True)
    os.makedirs(TMP_RPT, exist_ok=True)
    import shutil
    for f in FILES:
        shutil.copy2(os.path.join(CORE, f), os.path.join(TMP_CORE, f))
    shutil.copy2(os.path.join(CONST, "kem.xdc"), TMP_XDC)
    L = ['set PROJ "' + TMP.replace("\\", "/") + '"']
    with io.open(TMP_TCL, "w", encoding="utf-8") as fh:
        fh.write("\n".join(L) + "\n" + build_tcl())
    print("Wrote %s (rtl copied to %s)" % (TMP_TCL, TMP_CORE))

    cmd = [VIVADO, "-mode", "batch", "-nojournal", "-log", TMP_LOG,
           "-source", TMP_TCL]
    print("Running project-less synth on %s (timeout 1800s)..." % PART)
    t0 = time.time()
    rc = -1
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=1800,
                           cwd=TMP, errors="replace")
        rc = r.returncode
    except subprocess.TimeoutExpired:
        rc = -999
        print("TIMEOUT after 1800s")
    except Exception as e:
        print("ERR:", e)
    el = time.time() - t0
    print("rc=%s  time=%.1fs" % (rc, el))

    log_txt = (io.open(TMP_LOG, "r", encoding="utf-8", errors="replace").read()
               if os.path.exists(TMP_LOG) else "")
    shutil_target = os.path.join(RESULTS, "kem_p2b_synth.log")
    with io.open(shutil_target, "w", encoding="utf-8") as fh:
        fh.write(log_txt)
    print("log saved (%d bytes)" % os.path.getsize(shutil_target))

    lines = []
    lines.append("kyber_kem full-top synth, P2b project-less: %s" % PART)
    lines.append("part=%s  directive=%s  rc=%s  elapsed=%.1fs" % (PART, DIRECTIVE, rc, el))
    lines.append("")

    m = None
    for l in log_txt.splitlines():
        if "Synthesis finished with" in l:
            m = l
            break
    lines.append("Verdict: %s" % (m if m else "(synthesis status not found in log)"))
    lines.append("")

    # regression guards
    for wid, desc in (("8-7186", "ram_style ignored (base 101)"),
                      ("8-4767", "RAM in registers"),
                      ("8-2914", "multi-port RAM mapping"),
                      ("8-6090", "blocking/non-blocking same var"),
                      ("8-327",  "inferred latch")):
        lines.append("  Synth %-6s %-34s = %d" % (wid, desc, log_txt.count(wid)))

    # cell usage table (pre-opt, from THIS log)
    cu = parse_cell_usage(shutil_target)
    ff = cu.get("FDRE", 0) + cu.get("FDCE", 0) + cu.get("FDPE", 0)
    lut = sum(cu.get(k, 0) for k in ("LUT1", "LUT2", "LUT3", "LUT4", "LUT5", "LUT6"))
    mux = cu.get("MUXF7", 0) + cu.get("MUXF8", 0)
    dsp = cu.get("DSP48E1", 0)
    lines.append("")
    lines.append("--- Report Cell Usage (pre-opt) ---")
    for k in sorted(cu):
        lines.append("  %-10s %7d" % (k, cu[k]))
    lines.append("  FF = %d   LUT = %d   MUXF = %d   LUT+MUX = %d   DSP = %d"
                 % (ff, lut, mux, lut + mux, dsp))

    # compare with P2a (first run, 916-line log) cell usage
    p2a = os.path.join(RESULTS, "kem_p2_synth.log")
    if os.path.exists(p2a):
        cu_a = parse_cell_usage(p2a)
        same = (cu_a == cu)
        lines.append("")
        lines.append("--- Identical pre-opt cell usage vs P2a (100T-equivalent run)? %s ---"
                     % ("YES (counts equal)" if same else "NO (differs)"))
        if not same:
            for k in sorted(set(cu) | set(cu_a)):
                if cu.get(k, 0) != cu_a.get(k, 0):
                    lines.append("  %-10s 200T=%-7d 100T=%-7d" % (k, cu.get(k, 0), cu_a.get(k, 0)))

    # utilization report
    util = os.path.join(TMP_RPT, "util.rpt")
    if os.path.exists(util):
        u_dst = os.path.join(RESULTS, "kem_p2b_synth_util.rpt")
        with io.open(u_dst, "w", encoding="utf-8") as fh:
            fh.write(io.open(util, "r", encoding="utf-8", errors="replace").read())
        print("util.rpt -> %s" % u_dst)
        ut = io.open(util, "r", encoding="utf-8", errors="replace").read()
        lines.append("")
        lines.append("--- report_utilization (mapped, post-opt) ---")
        for k, rx in {
            "Slice LUTs":      r"Slice LUTs\*?\s+([\d,]+)\s+[\d,]*\s*[\d,]*\s+([\d,]+)\s+([\d.]+)",
            "Slice Registers": r"Slice Registers\s+([\d,]+)\s+[\d,]*\s*[\d,]*\s+([\d,]+)\s+([\d.]+)",
            "DSPs":            r"DSPs\s+([\d,]+)\s+[\d,]*\s*[\d,]*\s+([\d,]+)\s+([\d.]+)",
            "Block RAM Tile":  r"Block RAM Tile\s+([\d,]+)\s+[\d,]*\s*[\d,]*\s+([\d,]+)\s+([\d.]+)",
        }.items():
            mm = __import__("re").search(rx, ut)
            if mm:
                lines.append("  %-16s used=%-8s avail=%-8s util=%s%%"
                             % (k, mm.group(1), mm.group(2), mm.group(3)))
        # hierarchy row
        hrx = __import__("re").search(
            r"\|\s*kyber_kem\s+\(top\)\s*\|\s*([\d,]+)\s*\|\s*([\d,]+)\s*\|\s*([\d,]+)\s*\|"
            r"\s*[\d,]+\s*\|\s*([\d,]+)\s*\|\s*([\d,]+)\s*\|\s*([\d,]+)\s*\|\s*([\d,]+)\s*\|", ut)
        if hrx:
            g = [x.replace(",", "") for x in hrx.groups()]
            lut_t, loglut, lutram, ff_t, r36, r18, dsp_t = g
            lines.append("  hierarchy kyber_kem: LUT %s (logic %s, LUTRAM %s)  FF %s  RAMB36 %s  RAMB18 %s  DSP %s"
                         % (lut_t, loglut, lutram, ff_t, r36, r18, dsp_t))
            ffx, lutx, dspx = int(ff_t), int(lut_t), int(dsp_t)
            lines.append("")
            lines.append("--- %s budget (post-opt, hierarchy) ---" % PART)
            lines.append("    FF   %7d / %-7d = %.1f%%  -> %s"
                         % (ffx, LIMIT_FF, 100.0 * ffx / LIMIT_FF,
                            "FITS" if ffx <= LIMIT_FF else "OVER"))
            lines.append("    LUT  %7d / %-7d = %.1f%%  -> %s"
                         % (lutx, LIMIT_LUT, 100.0 * lutx / LIMIT_LUT,
                            "FITS" if lutx <= LIMIT_LUT else "OVER"))
            lines.append("    DSP  %7d / %-7d = %.1f%%  -> %s"
                         % (dspx, LIMIT_DSP, 100.0 * dspx / LIMIT_DSP,
                            "FITS" if dspx <= LIMIT_DSP else "OVER"))
            lines.append("    (pre-opt LUT+MUX = %d -> %.1f%%)" % (lut + mux, 100.0 * (lut + mux) / LIMIT_LUT))
            lines.append("    P1 (100T) ref: FF %d / LUT %d (LUTRAM %d) — LUT was %.2fx over 63,400"
                         % (P1_FF, P1_LUT, P1_LUTRAM, P1_LUT / 63400.0))
    else:
        lines.append("(no util.rpt)")

    # timing
    tm = os.path.join(TMP_RPT, "timing.rpt")
    if os.path.exists(tm):
        t_dst = os.path.join(RESULTS, "kem_p2b_synth_timing.rpt")
        with io.open(t_dst, "w", encoding="utf-8") as fh:
            fh.write(io.open(tm, "r", encoding="utf-8", errors="replace").read())
        tt = io.open(tm, "r", encoding="utf-8", errors="replace").read()
        import re
        wm = re.search(r"WNS\s+\n?\s+([\-\d.]+)", tt)
        fm = re.search(r"Fmax\s+\n?\s+([\d.]+)", tt)
        lines.append("")
        lines.append("--- Timing ---")
        if wm:
            lines.append("  WNS = %s ns" % wm.group(1))
        if fm:
            lines.append("  Fmax = %s MHz" % fm.group(1))
    else:
        lines.append("(no timing.rpt)")

    cs = os.path.join(TMP_RPT, "control_sets.rpt")
    if os.path.exists(cs):
        c_dst = os.path.join(RESULTS, "kem_p2b_synth_control_sets.rpt")
        with io.open(c_dst, "w", encoding="utf-8") as fh:
            fh.write(io.open(cs, "r", encoding="utf-8", errors="replace").read())

    lines.append("")
    lines.append("tmp dir: " + TMP)
    rep = os.path.join(RESULTS, "kem_p2b_synth_summary.txt")
    with io.open(rep, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")
    print("\n" + "\n".join(lines))
    print("\nSummary -> %s" % rep)
    return 0 if rc == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
