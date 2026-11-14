#!/usr/bin/env python3
"""B4/C4 synthesis with .Xil isolation + own-tree-only kill + fast-fail retry.

Why this script exists (see .workbuddy/memory/MEMORY.md section 4):
  B4 (mpc_private_infer) and C4 (puf_model_bind) both hang AFTER synth_design
  prints "Synthesis finished with 0 errors" / "Synthesis Optimization Runtime":
  the Tcl command never returns, 0% CPU, no checkpoint, no report.  The other
  10 modules synthesize in under a minute with the identical Tcl template, so
  this is NOT design-specific -- it is the classic .Xil / helper-kill deadlock:
  this host runs Vivado for other projects (hedge / fpga_ckks / tvla), whose
  runners do a global `taskkill /F /IM vivado.exe /T`.  Our synthesis helper
  gets killed, the main process blocks on a dead peer forever.

Fixes applied here (per the vivado-batch-hang-and-fake-timing skill):
  1. Every attempt runs in a BRAND-NEW cwd, so .Xil/Vivado-<pid> never collides.
  2. NO global taskkill.  We diff tasklist before/after launch and only kill
     our own PID tree.
  3. Fast-fail: once the log shows "Synthesis finished with 0 errors" and the
     success marker does not appear within FASTFAIL seconds, kill our tree and
     retry (a failed attempt costs ~1 min instead of ~15).
  4. If all attempts hang, fall back to the "Report Cell Usage" table that
     Vivado prints before the hang -- good enough for the evidence table, and
     clearly labelled as cell-usage-derived.

Usage: python synth_b4c4_isolated.py [module ...]
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

FASTFAIL = int(os.environ.get("SYNTH_FASTFAIL", "240"))   # s after "finished"
HARD_TIMEOUT = int(os.environ.get("SYNTH_HARD_TIMEOUT", "1200"))
ATTEMPTS = int(os.environ.get("SYNTH_ATTEMPTS", "3"))

TCL_TMPL = r"""set WORK "%(w)s"
set TOP "%(t)s"
puts "M1 project"
create_project -force $TOP $WORK/proj -part %(p)s
read_verilog -sv $WORK/src/%(t)s.v
puts "M2 synth_start"
synth_design -top $TOP -part %(p)s -directive default
puts "M3 synth_done"
write_checkpoint -force $WORK/post_synth.dcp
puts "M4 checkpoint"
catch {create_clock -period 10.000 -name sys_clk [get_ports clk]}
puts "M5 clock"
catch {set_param general.maxThreads 1}
catch {report_timing_summary -file $WORK/timing.rpt -delay_type min_max -max_paths 5}
catch {set_param general.maxThreads 4}
puts "M6 timing"
report_utilization -file $WORK/util.rpt
report_power -file $WORK/power.rpt
puts "M7 reports"
puts "=== synth $TOP done ==="
exit
"""

DONE_MARK = "=== synth %s done ==="
FINISH_MARK = "Synthesis finished with 0 errors"


# ---------------------------------------------------------------- process utils
def _tasklist_pids():
    try:
        out = subprocess.run(
            ["tasklist", "/FI", "IMAGENAME eq vivado.exe", "/FO", "CSV", "/NH"],
            capture_output=True).stdout.decode("mbcs", errors="replace")
    except Exception:
        return set()
    pids = set()
    for line in out.splitlines():
        f = [x.strip('"') for x in line.split(",")]
        if len(f) >= 2 and f[1].isdigit():
            pids.add(int(f[1]))
    return pids


def kill_own(baseline):
    """Kill only processes that appeared after `baseline` was taken."""
    cur = _tasklist_pids()
    targets = cur - set(baseline)
    for pid in sorted(targets):
        subprocess.run(["taskkill", "/PID", str(pid), "/T", "/F"],
                       capture_output=True)
    return sorted(targets)


def wait_quiet(max_procs=3, budget=120):
    """Wait for the machine to be reasonably quiet.  Never wait forever."""
    t0 = time.time()
    while time.time() - t0 < budget:
        n = len(_tasklist_pids())
        if n <= max_procs:
            return n
        time.sleep(10)
    return len(_tasklist_pids())


# ---------------------------------------------------------------------- parsing
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
    """Fallback: Report Cell Usage printed before the hang."""
    log = os.path.join(work, "vivado.log")
    if not os.path.exists(log):
        return None
    txt = open(log, errors="replace").read()
    i = txt.find("Report Cell Usage")
    if i < 0:
        return None
    seg = txt[i:i + 1500]
    lut = ff = dsp = 0
    for m in re.finditer(r"\|\s*(LUT\d|FDRE|FDCE|FDPE|FDLR|DSP48E1)\s*\|\s*(\d+)",
                         seg):
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
            "source": "cell-usage table (synth_design did not return)"}


# --------------------------------------------------------------------- one run
def one_attempt(mod, attempt):
    stamp = "%s_%d" % (time.strftime("%H%M%S"), os.getpid())
    base = "c:/tmp/synth_iso_%s" % stamp
    os.makedirs(base, exist_ok=True)
    work = os.path.join(base, mod)
    src = os.path.join(work, "src")
    os.makedirs(src, exist_ok=True)
    shutil.copy2(os.path.join(RTL_CORE, mod + ".v"),
                 os.path.join(src, mod + ".v"))
    tcl = os.path.join(work, "run.tcl")
    with open(tcl, "w") as f:
        f.write(TCL_TMPL % {"w": work.replace("\\", "/"), "t": mod, "p": PART})
    log = os.path.join(work, "vivado.log")
    open(log, "w").close()          # truncate, never os.remove (blocking)

    env = os.environ.copy()
    parts = env.get("PATH", "").split(os.pathsep)
    env["PATH"] = os.pathsep.join(
        p for p in parts if p.strip() and not os.path.isfile(p))
    env["XILINX_VIVADO"] = "D:/FPGA/2026.1/Vivado"

    baseline = _tasklist_pids()
    print("    [%s a%d] launching fresh cwd=%s (baseline vivado=%d)"
          % (mod, attempt, work, len(baseline)), flush=True)
    t0 = time.time()
    proc = subprocess.Popen([VIVADO, "-mode", "batch", "-source", tcl,
                             "-nojournal"], cwd=work, env=env,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    own = _tasklist_pids() - baseline

    finish_at = None
    verdict = "HANG"
    while True:
        if proc.poll() is not None:
            verdict = "exit"
            break
        el = time.time() - t0
        if el > HARD_TIMEOUT:
            verdict = "HARD_TIMEOUT"
            break
        try:
            txt = open(log, errors="replace").read()
        except Exception:
            txt = ""
        if DONE_MARK % mod in txt:
            verdict = "done"
            break
        if FINISH_MARK in txt and finish_at is None:
            finish_at = time.time()
            print("    [%s a%d] synthesis finished at %.0f s, waiting for "
                  "post-synth Tcl (fastfail=%d s)" % (mod, attempt, el,
                                                      FASTFAIL), flush=True)
        if finish_at is not None and time.time() - finish_at > FASTFAIL:
            verdict = "FASTFAIL_HANG"
            break
        time.sleep(10)
    dt = time.time() - t0

    out = b""
    try:
        out = proc.communicate(timeout=60)[0] or b""
    except Exception:
        pass
    killed = kill_own(baseline | own)
    with open(os.path.join(work, "console.log"), "wb") as f:
        f.write(out)
    print("    [%s a%d] %s (%.0f s) killed_own=%s"
          % (mod, attempt, verdict, dt, killed), flush=True)
    return verdict, work


def run_module(mod):
    print("  --- %s ---" % mod, flush=True)
    n = wait_quiet()
    print("    [%s] vivado processes on host: %d (accepted risk)" % (mod, n),
          flush=True)
    last_work = None
    for a in range(1, ATTEMPTS + 1):
        verdict, work = one_attempt(mod, a)
        last_work = work
        if verdict in ("done", "exit"):
            txt = ""
            lp = os.path.join(work, "console.log")
            if os.path.exists(lp):
                txt = open(lp, errors="replace").read()
            if DONE_MARK % mod in txt or verdict == "done":
                entry = parse_reports(work)
                if entry:
                    for r in ("util.rpt", "timing.rpt", "power.rpt"):
                        sr = os.path.join(work, r)
                        if os.path.exists(sr):
                            shutil.copy2(sr, os.path.join(
                                RESULTS, "synth_innov_%s_%s" % (mod, r)))
                    print("    [%s] OK %s" % (mod, entry), flush=True)
                    return entry
            print("    [%s] exited but no reports; retrying" % mod, flush=True)
        else:
            print("    [%s] %s; retrying" % (mod, verdict), flush=True)
    cu = parse_cell_usage(last_work) if last_work else None
    print("    [%s] fallback: %s" % (mod, cu), flush=True)
    return cu


def main():
    mods = sys.argv[1:] or ["mpc_private_infer", "puf_model_bind"]
    print("=" * 78, flush=True)
    print("B4/C4 isolated synthesis (.Xil isolation + own-tree kill + retry): %s"
          % mods, flush=True)
    print("=" * 78, flush=True)
    got = {}
    for mod in mods:
        got[mod] = run_module(mod)
    print("\nSummary:", flush=True)
    for mod, e in got.items():
        print("  %-22s %s" % (mod, e), flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
