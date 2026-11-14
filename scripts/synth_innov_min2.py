#!/usr/bin/env python3
"""Minimal single-file Vivado synthesis — v2 (Tcl template fixed).

v1 (synth_innov_min.py) set `set_param general.maxThreads 2` BEFORE
synth_design.  The successful 10-module batch run only touched maxThreads
around the timing report and disabled the parallel helper spawn at the top;
with the wrong global threading state Vivado finished synth_design and then
died silently before the first `puts`, so no report was ever written
(B4 and C4) or it crashed mid-synthesis (C1).

v2 reuses the batch script's proven Tcl command for command order verbatim,
only swapping `foreach f [glob ...]` for a single-file read.  Runs B4, C4
and C1 (C1 re-synthesized after the RAM-template fix so the 24,576-bit
audit RAM infers as distributed RAM instead of 273k LUTs of registers).
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

MODULES = [
    ("C1", "chain_anchor_audit"),   # RAM fix, highest value to re-measure
    ("B4", "mpc_private_infer"),
    ("C4", "puf_model_bind"),
]

# Verbatim command order from the successful synth_innovations.py run.
TCL_TMPL = r"""catch {set_param synth.enableParallelHelperSpawn none}
catch {set_param synth.elaboration.useElabCache false}
set WORK "%s"
set TOP "%s"
puts "=== synth $TOP ==="
create_project -force $TOP $WORK/proj -part %s
read_verilog -sv $WORK/src/%s.v
synth_design -top $TOP -part %s -directive default
catch {create_clock -period 10.000 -name sys_clk [get_ports clk]}
report_utilization -file $WORK/util.rpt
catch {set_param general.maxThreads 1}
catch {report_timing_summary -file $WORK/timing.rpt -delay_type min_max -max_paths 5}
catch {set_param general.maxThreads 4}
report_power -file $WORK/power.rpt
write_checkpoint -force $WORK/$TOP.dcp
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


def run_module(tag, mod, base):
    kill_orphans()
    work = "%s/%s_min_%d" % (base, mod, int(time.time()))
    src = os.path.join(work, "src")
    os.makedirs(src, exist_ok=True)
    shutil.copy2(os.path.join(RTL_CORE, mod + ".v"),
                 os.path.join(src, mod + ".v"))
    tcl_path = os.path.join(work, "run.tcl")
    tcl = (TCL_TMPL % (work.replace("\\", "/"), mod, PART, mod, PART))
    with open(tcl_path, "w") as f:
        f.write(tcl)
    env = os.environ.copy()
    parts = env.get("PATH", "").split(os.pathsep)
    env["PATH"] = os.pathsep.join(
        p for p in parts if p.strip() and not os.path.isfile(p))
    env["XILINX_VIVADO"] = "D:/FPGA/2026.1/Vivado"
    t0 = time.time()
    try:
        p = subprocess.run(
            [VIVADO, "-mode", "batch", "-source", tcl_path, "-nojournal"],
            cwd=work, env=env, capture_output=True, timeout=1500)
    except subprocess.TimeoutExpired:
        print("  %s %s: TIMEOUT (1500 s)" % (tag, mod), flush=True)
        return None
    dt = time.time() - t0
    so = p.stdout.decode("utf-8", errors="replace")
    se = p.stderr.decode("utf-8", errors="replace")
    with open(os.path.join(work, "console.log"), "w") as f:
        f.write(so + "\n--- STDERR ---\n" + se)
    if ("synth %s done" % mod) not in so:
        tail = [l for l in so.split("\n") if l.strip()]
        print("  %s %s: FAIL (%.0f s) last: %s" % (
            tag, mod, dt, (tail[-1][:140] if tail else se[-140:])),
            flush=True)
        return None
    entry = {"tag": tag, "module": mod, "seconds": round(dt, 1)}
    entry.update(parse_reports(work))
    for r in ("util.rpt", "timing.rpt", "power.rpt"):
        src_r = os.path.join(work, r)
        if os.path.exists(src_r):
            shutil.copy2(src_r, os.path.join(
                RESULTS, "synth_innov_%s_%s" % (mod, r)))
    print("  %s %s: OK (%.0f s) %s" % (tag, mod, dt, entry), flush=True)
    return entry


def main():
    print("=" * 78, flush=True)
    print("Minimal single-file Vivado synthesis v2 (C1, B4, C4)", flush=True)
    print("=" * 78, flush=True)
    base = "c:/tmp/synth_min2_%d" % int(time.time())
    os.makedirs(base, exist_ok=True)
    results = []
    for tag, mod in MODULES:
        r = run_module(tag, mod, base)
        if r:
            results.append(r)
    kill_orphans()
    print("\nSummary:", flush=True)
    for r in results:
        print("  %s %-20s LUT=%-8s FF=%-7s DSP=%-3s WNS=%-8s P=%s" % (
            r["tag"], r["module"], r.get("lut"), r.get("ff"), r.get("dsp"),
            r.get("wns"), r.get("power_w")), flush=True)
    print("\nDone. Re-run parse_synth_innovations.py to refresh the summary.",
          flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
