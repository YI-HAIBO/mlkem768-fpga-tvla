#!/usr/bin/env python3
"""B4/C4 synthesis with -directive Quick + checkpoint-first + cell-usage
fallback.

Findings so far (scripts/synth_b4c4_diag.py):
  * B4 and C4 BOTH hang *inside* synth_design after it prints
    "Synthesis finished with 0 errors" + "Synthesis Optimization Runtime";
    the Tcl command never returns, so no report and no checkpoint.
    The successful 10-module template is identical, so it is
    design-specific.
  * B4 emits 100x Synth 8-7137 (register both set and reset) warnings.

This script:
  1. tries `synth_design -directive RuntimeOptimized` (different optimization
     path, and the only "fast" directive Vivado 2026.1 accepts -- `Quick` is
     rejected with "Invalid option value 'quick'"), which may avoid the hang;
  2. writes the checkpoint immediately after synth_design;
  3. if the reports land, saves them under the usual
     results/synth_innov_<module>_* names;
  4. if synth_design still does not return, falls back to the "Report Cell
     Usage" table already printed inside the log, which gives a synthesis
     LUT/FF/DSP cell count good enough for the evidence table (marked as
     such).

Usage: python synth_b4c4_quick.py [module ...]
"""
import os
import sys
import subprocess
import shutil
import time
import re

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
RTL_CORE = os.path.join(ROOT, "rtl", "core")
RESULTS = os.path.join(ROOT, "results")
VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART = "xc7a100tcsg324-1"

TCL_TMPL = r"""catch {set_param synth.enableParallelHelperSpawn none}
catch {set_param synth.elaboration.useElabCache false}
set WORK "%(w)s"
set TOP "%(t)s"
puts "M1 project"
create_project -force $TOP $WORK/proj -part %(p)s
read_verilog -sv $WORK/src/%(t)s.v
puts "M2 synth_start"
synth_design -top $TOP -part %(p)s -directive %(d)s
puts "M3 synth_done"
write_checkpoint -force $WORK/post_synth.dcp
puts "M4 checkpoint"
catch {create_clock -period 10.000 -name sys_clk [get_ports clk]}
catch {set_param general.maxThreads 1}
catch {report_timing_summary -file $WORK/timing.rpt -delay_type min_max -max_paths 5}
catch {set_param general.maxThreads 4}
report_utilization -file $WORK/util.rpt
report_power -file $WORK/power.rpt
puts "M5 reports"
puts "=== synth $TOP done ==="
exit
"""


def kill_orphans():
    subprocess.run(["taskkill", "/F", "/IM", "vivado.exe"], capture_output=True)
    subprocess.run(["taskkill", "/F", "/IM", "vivado.bat"], capture_output=True)


def parse_reports(work):
    out = {}
    util = os.path.join(work, "util.rpt")
    if os.path.exists(util):
        txt = open(util, errors="replace").read()
        for key, pat in [
            ("lut", r"\|\s*Slice LUTs\*?\s*\|\s*(\d+)"),
            ("ff", r"\|\s*Slice Registers\s*\|\s*(\d+)"),
            ("dsp", r"\|\s*DSPs\s*\|\s+(\d+)"),
            ("bram", r"\| Block RAM Tile\s+\|\s+(\d+)"),
        ]:
            m = re.search(pat, txt)
            if m:
                out[key] = int(m.group(1))
    timing = os.path.join(work, "timing.rpt")
    if os.path.exists(timing):
        txt = open(timing, errors="replace").read()
        i = txt.find("Design Timing Summary")
        if i >= 0:
            m = re.search(r"^\s*(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+\d+\s+\d+",
                          txt[i:i + 4000], re.M)
            if m:
                out["wns"] = float(m.group(1))
    power = os.path.join(work, "power.rpt")
    if os.path.exists(power):
        txt = open(power, errors="replace").read()
        m = re.search(r"Total On-Chip Power \(W\)\s*\|\s*([\d.]+)", txt)
        if m:
            out["power_w"] = float(m.group(1))
    return out


def parse_cell_usage(work):
    """Fallback: the Report Cell Usage table printed before the hang."""
    log = os.path.join(work, "vivado.log")
    if not os.path.exists(log):
        return None
    txt = open(log, errors="replace").read()
    i = txt.find("Report Cell Usage")
    if i < 0:
        return None
    seg = txt[i:i + 1200]
    lut = 0
    ff = 0
    dsp = 0
    for m in re.finditer(r"\|\s*(LUT\d|FDRE|FDCE|FDPE|FDLR|DSP48E1)\s*\|\s*(\d+)", seg):
        kind, n = m.group(1), int(m.group(2))
        if kind.startswith("LUT"):
            lut += n
        elif kind.startswith("FD"):
            ff += n
        else:
            dsp += n
    if lut == 0 and ff == 0:
        return None
    return {"lut_cells": lut, "ff_cells": ff, "dsp_cells": dsp,
            "source": "synthesis cell-usage table (Vivado hung in synth_design)"
            .replace("Vivado hung in synth_design",
                     "synth_design Tcl did not return; cell usage printed pre-hang")}


def run_module(mod):
    kill_orphans()
    base = "c:/tmp/synth_quick_%d" % int(time.time())
    os.makedirs(base, exist_ok=True)
    work = "%s/%s" % (base, mod)
    src = os.path.join(work, "src")
    os.makedirs(src, exist_ok=True)
    shutil.copy2(os.path.join(RTL_CORE, mod + ".v"),
                 os.path.join(src, mod + ".v"))
    tcl = os.path.join(work, "run.tcl")
    d = os.environ.get("SYNTH_DIRECTIVE", "RuntimeOptimized")
    with open(tcl, "w") as f:
        f.write(TCL_TMPL % {"w": work.replace("\\", "/"), "t": mod,
                            "p": PART, "d": d})
    env = os.environ.copy()
    parts = env.get("PATH", "").split(os.pathsep)
    env["PATH"] = os.pathsep.join(
        p for p in parts if p.strip() and not os.path.isfile(p))
    env["XILINX_VIVADO"] = "D:/FPGA/2026.1/Vivado"
    print("  --- %s: synth (directive %s) ---" % (mod, d), flush=True)
    t0 = time.time()
    try:
        p = subprocess.run(
            [VIVADO, "-mode", "batch", "-source", tcl, "-nojournal"],
            cwd=work, env=env, capture_output=True, timeout=900)
        so = p.stdout.decode("utf-8", errors="replace")
        se = p.stderr.decode("utf-8", errors="replace")
        err = None
    except subprocess.TimeoutExpired as e:
        so = (e.stdout or b"").decode("utf-8", errors="replace")
        se = (e.stderr or b"").decode("utf-8", errors="replace")
        err = "TIMEOUT"
    dt = time.time() - t0
    with open(os.path.join(work, "console.log"), "w") as f:
        f.write(so + "\n--- STDERR ---\n" + se)
    marks = re.findall(r"M\d[_\w]*", so)
    done = ("=== synth %s done ===" % mod) in so
    print("  %s: %s (%.0f s) markers=%s" % (
        mod, err or ("done" if done else "HANG"), dt, marks), flush=True)

    if done:
        entry = parse_reports(work)
        if entry:
            for r in ("util.rpt", "timing.rpt", "power.rpt"):
                sr = os.path.join(work, r)
                if os.path.exists(sr):
                    shutil.copy2(sr, os.path.join(
                        RESULTS, "synth_innov_%s_%s" % (mod, r)))
            return entry
    # fallback to cell usage
    cu = parse_cell_usage(work)
    return cu


def main():
    mods = sys.argv[1:] or ["mpc_private_infer", "puf_model_bind"]
    print("=" * 78, flush=True)
    print("B4/C4 Quick-directive synthesis + cell-usage fallback: %s" % mods,
          flush=True)
    print("=" * 78, flush=True)
    got = {}
    for mod in mods:
        got[mod] = run_module(mod)
    kill_orphans()
    print("\nSummary:", flush=True)
    for mod, e in got.items():
        print("  %-22s %s" % (mod, e), flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
