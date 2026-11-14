#!/usr/bin/env python3
"""Diagnostic synthesis for B4 mpc_private_infer / C4 puf_model_bind.

Both modules: synth_design completes ("Synthesis finished with 0 errors"),
then the next Tcl command never starts -- the process sits idle and dies/
times out.  The successful 10 modules used the identical template, so the
stall is design-specific, not template-specific.

This script:
  1. writes the synthesized checkpoint IMMEDIATELY after synth_design
     (before any report), so the design survives even if reporting hangs;
  2. emits a `puts` marker before/after every subsequent command so the
     hang point is identifiable in the log;
  3. if the reports never land but the checkpoint does, opens the DCP in a
     second Vivado session and generates the util/timing/power reports
     from the checkpoint.

Usage: python synth_b4c4_diag.py [module ...]   (default: mpc_private_infer
puf_model_bind)
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

TCL_SYNTH = r"""catch {set_param synth.enableParallelHelperSpawn none}
catch {set_param synth.elaboration.useElabCache false}
set WORK "%(w)s"
set TOP "%(t)s"
puts "M1 project"
create_project -force $TOP $WORK/proj -part %(p)s
read_verilog -sv $WORK/src/%(t)s.v
puts "M2 synth_design"
synth_design -top $TOP -part %(p)s -directive default
puts "M3 synth_design_done"
write_checkpoint -force $WORK/post_synth.dcp
puts "M4 checkpoint_done"
catch {create_clock -period 10.000 -name sys_clk [get_ports clk]}
puts "M5 clock_done"
catch {set_param general.maxThreads 1}
catch {report_timing_summary -file $WORK/timing.rpt -delay_type min_max -max_paths 5}
catch {set_param general.maxThreads 4}
puts "M6 timing_done"
report_utilization -file $WORK/util.rpt
puts "M7 util_done"
report_power -file $WORK/power.rpt
puts "M8 power_done"
puts "=== synth $TOP done ==="
exit
"""

TCL_DCP = r"""catch {set_param synth.enableParallelHelperSpawn none}
open_checkpoint %s/post_synth.dcp
puts "D1 open"
catch {create_clock -period 10.000 -name sys_clk [get_ports clk]}
catch {set_param general.maxThreads 1}
catch {report_timing_summary -file %s/timing.rpt -delay_type min_max -max_paths 5}
catch {set_param general.maxThreads 4}
puts "D2 timing"
report_utilization -file %s/util.rpt
puts "D3 util"
report_power -file %s/power.rpt
puts "D4 power"
puts "=== dcp reports done ==="
exit
"""


def kill_orphans():
    subprocess.run(["taskkill", "/F", "/IM", "vivado.exe"], capture_output=True)
    subprocess.run(["taskkill", "/F", "/IM", "vivado.bat"], capture_output=True)


def run_vivado(tcl_path, work, timeout):
    env = os.environ.copy()
    parts = env.get("PATH", "").split(os.pathsep)
    env["PATH"] = os.pathsep.join(
        p for p in parts if p.strip() and not os.path.isfile(p))
    env["XILINX_VIVADO"] = "D:/FPGA/2026.1/Vivado"
    t0 = time.time()
    try:
        p = subprocess.run(
            [VIVADO, "-mode", "batch", "-source", tcl_path, "-nojournal"],
            cwd=work, env=env, capture_output=True, timeout=timeout)
        return p.stdout.decode("utf-8", errors="replace"), \
            p.stderr.decode("utf-8", errors="replace"), time.time() - t0, None
    except subprocess.TimeoutExpired as e:
        so = (e.stdout or b"").decode("utf-8", errors="replace")
        se = (e.stderr or b"").decode("utf-8", errors="replace")
        return so, se, time.time() - t0, "TIMEOUT"


def last_marker(out):
    marks = re.findall(r"M\d|M\d_\w+|D\d", out)
    return marks[-1] if marks else "?"


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


def run_module(mod):
    kill_orphans()
    base = "c:/tmp/synth_diag_%d" % int(time.time())
    os.makedirs(base, exist_ok=True)
    work = "%s/%s" % (base, mod)
    src = os.path.join(work, "src")
    os.makedirs(src, exist_ok=True)
    shutil.copy2(os.path.join(RTL_CORE, mod + ".v"),
                 os.path.join(src, mod + ".v"))
    tcl = os.path.join(work, "run.tcl")
    with open(tcl, "w") as f:
        f.write(TCL_SYNTH % {"w": work.replace("\\", "/"), "t": mod,
                             "p": PART})
    print("  --- %s: synth phase ---" % mod, flush=True)
    so, se, dt, err = run_vivado(tcl, work, 1400)
    with open(os.path.join(work, "console.log"), "w") as f:
        f.write(so + "\n--- STDERR ---\n" + se)
    print("  %s synth phase: %s (%.0f s) last marker=%s" % (
        mod, err or ("done" if ("=== synth %s done ===" % mod) in so
                     else "NO-DONE-MARKER"),
        dt, last_marker(so)), flush=True)

    dcp = os.path.join(work, "post_synth.dcp")
    reports = parse_reports(work)
    if reports or not os.path.exists(dcp):
        pass  # reports already there (or nothing to retry from)
    else:
        # second phase: open the DCP and generate reports
        time.sleep(2)
        tcl2 = os.path.join(work, "run_dcp.tcl")
        with open(tcl2, "w") as f:
            f.write(TCL_DCP % (work.replace("\\", "/"),
                               work.replace("\\", "/"),
                               work.replace("\\", "/"),
                               work.replace("\\", "/")))
        print("  --- %s: DCP report phase ---" % mod, flush=True)
        so2, se2, dt2, err2 = run_vivado(tcl2, work, 900)
        with open(os.path.join(work, "console_dcp.log"), "w") as f:
            f.write(so2 + "\n--- STDERR ---\n" + se2)
        print("  %s dcp phase: %s (%.0f s) last marker=%s" % (
            mod, err2 or ("done" if "dcp reports done" in so2
                          else "NO-DONE-MARKER"),
            dt2, last_marker(so2)), flush=True)
        reports = parse_reports(work)

    if reports:
        for r in ("util.rpt", "timing.rpt", "power.rpt"):
            sr = os.path.join(work, r)
            if os.path.exists(sr):
                shutil.copy2(sr, os.path.join(
                    RESULTS, "synth_innov_%s_%s" % (mod, r)))
    tag = {"mpc_private_infer": "B4", "puf_model_bind": "C4"}.get(mod, mod)
    print("  %s %s: %s" % (tag, mod, reports), flush=True)
    return reports


def main():
    mods = sys.argv[1:] or ["mpc_private_infer", "puf_model_bind"]
    print("=" * 78, flush=True)
    print("Diagnostic synthesis (checkpoint-first): %s" % mods, flush=True)
    print("=" * 78, flush=True)
    for mod in mods:
        run_module(mod)
    kill_orphans()
    print("\nDone. Re-run parse_synth_innovations.py to refresh the summary.",
          flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
