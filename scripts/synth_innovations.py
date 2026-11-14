#!/usr/bin/env python3
"""
Task #87: synthesize the 12 innovation modules that were never run through
Vivado. Produces util/timing/power reports + a summary table.

Workarounds baked in (from project memory):
  - ASCII temp work dir (Chinese paths corrupt Vivado RTL elaboration)
  - synth.elaboration.useElabCache false (synth-stage hang)
  - maxThreads 1 only around report_timing_summary (crash workaround)
  - random Vivado crashes -> retry each module once
  - kill orphan vivado processes between runs
"""
import os
import sys
import subprocess
import shutil
import time
import json
import glob as globmod
import re

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
RTL_REAL = os.path.join(ROOT, "rtl", "real")
RTL_CORE = os.path.join(ROOT, "rtl", "core")
STUBS = os.path.join(ROOT, "rtl", "submodule_stubs.v")
RESULTS = os.path.join(ROOT, "results")
VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"

PART = "xc7a100tcsg324-1"

# (tag, module name, source dir)
MODULES = [
    ("A2", "puf_trng_fused", "real"),
    ("A3", "adaptive_mask_ctrl", "real"),
    ("A4", "hybrid_kex", "real"),
    ("A5", "watermark_backdoor_scan", "core"),
    ("B1", "he_engine", "core"),
    ("B2", "masked_accumulate_3rd_dip", "real"),
    ("B3", "tvla_online", "real"),
    ("B4", "mpc_private_infer", "core"),
    ("C1", "chain_anchor_audit", "core"),
    ("C2", "sec_acc_pareto", "core"),
    ("C3", "model_theft_detect", "core"),
    ("C4", "puf_model_bind", "core"),
]


def kill_orphans():
    subprocess.run(["taskkill", "/F", "/IM", "vivado.exe"],
                   capture_output=True)
    subprocess.run(["taskkill", "/F", "/IM", "vivado.bat"],
                   capture_output=True)


TCL_TMPL = r"""catch {set_param synth.enableParallelHelperSpawn none}
catch {set_param synth.elaboration.useElabCache false}
set WORK "%s"
set TOP "%s"
puts "=== synth $TOP ==="
create_project -force $TOP $WORK/proj -part %s
foreach f [glob -nocomplain $WORK/src/*.v] { read_verilog -sv $f }
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


def run_synth(mod, work):
    src = os.path.join(work, "src")
    os.makedirs(src, exist_ok=True)
    for d in (RTL_REAL, RTL_CORE):
        for f in globmod.glob(os.path.join(d, "*.v")):
            shutil.copy2(f, os.path.join(src, os.path.basename(f)))
    shutil.copy2(STUBS, os.path.join(src, "submodule_stubs.v"))

    tcl_path = os.path.join(work, "run.tcl")
    with open(tcl_path, "w") as f:
        f.write(TCL_TMPL % (work.replace("\\", "/"), mod, PART, PART))

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
        return "TIMEOUT", 0, ""
    dt = time.time() - t0
    so = p.stdout.decode("utf-8", errors="replace")
    se = p.stderr.decode("utf-8", errors="replace")
    with open(os.path.join(work, "console.log"), "w") as f:
        f.write(so + "\n--- STDERR ---\n" + se)
    if "synth $TOP done" in so:
        return "OK", dt, so
    return "FAIL", dt, so + se


def parse_reports(work):
    out = {}
    util = os.path.join(work, "util.rpt")
    if os.path.exists(util):
        with open(util, errors="replace") as f:
            txt = f.read()
        for key, pat in [
            ("lut", r"\| Slice LUTs\s+\|\s+(\d+)"),
            ("ff", r"\| Slice Registers\s+\|\s+(\d+)"),
            ("dsp", r"\|\s+DSPs\s+\|\s+(\d+)"),
            ("bram", r"\| Block RAM Tile\s+\|\s+(\d+)"),
        ]:
            m = re.search(pat, txt)
            if m:
                out[key] = int(m.group(1))
    timing = os.path.join(work, "timing.rpt")
    if os.path.exists(timing):
        with open(timing, errors="replace") as f:
            txt = f.read()
        m = re.search(r"WN.S.*?\(\s*(-?[\d.]+) ns", txt)
        if not m:
            m = re.search(r"WNS.\((-?[\d.]+)ns", txt)
        if m:
            out["wns"] = float(m.group(1))
    power = os.path.join(work, "power.rpt")
    if os.path.exists(power):
        with open(power, errors="replace") as f:
            txt = f.read()
        m = re.search(r"Total On-Chip Power \(W\)\s+\|\s+([\d.]+)", txt)
        if m:
            out["power_w"] = float(m.group(1))
    return out


def main():
    print("=" * 78, flush=True)
    print("Innovation modules Vivado synthesis (12 modules)", flush=True)
    print("=" * 78, flush=True)

    base = "c:/tmp/synth_innov_%d" % int(time.time())
    os.makedirs(base, exist_ok=True)

    results = {}
    for tag, mod, srcdir in MODULES:
        print("\n--- %s %s ---" % (tag, mod), flush=True)
        work = os.path.join(base, mod)
        os.makedirs(work, exist_ok=True)
        for attempt in (1, 2):
            kill_orphans()
            # fresh timestamped dir per attempt (rmtree triggers host
            # safe-delete confirmation)
            work = "%s_%d" % (os.path.join(base, mod), int(time.time()))
            os.makedirs(work, exist_ok=True)
            status, dt, so = run_synth(mod, work)
            print("  attempt %d: %s (%.0f s)" % (attempt, status, dt),
                  flush=True)
            if status == "OK":
                break

        entry = {"tag": tag, "module": mod, "status": status,
                 "seconds": round(dt, 1)}
        if status == "OK":
            entry.update(parse_reports(work))
        else:
            tail = so[-600:] if so else ""
            entry["error_tail"] = tail
        results[mod] = entry

        # save reports
        if status == "OK":
            for r in ("util.rpt", "timing.rpt", "power.rpt"):
                src = os.path.join(work, r)
                if os.path.exists(src):
                    shutil.copy2(
                        src, os.path.join(RESULTS,
                                          "synth_innov_%s_%s" % (mod, r)))
        print("  %s" % {k: v for k, v in entry.items()
                        if k != "error_tail"}, flush=True)

    # summary
    summ_path = os.path.join(RESULTS, "synth_innovations_summary.json")
    with open(summ_path, "w") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    md_path = os.path.join(RESULTS, "synth_innovations_summary.md")
    with open(md_path, "w") as f:
        f.write("# 12 个创新模块 Vivado 综合结果（2026-10-25）\n\n")
        f.write("器件 xc7a100tcsg324-1，synth directive default，"
                "时钟约束 10 ns（clk 端口存在时）。\n\n")
        f.write("| 模块 | 顶层 | 状态 | LUT | FF | DSP | BRAM | WNS (ns) | "
                "Power (W) |\n")
        f.write("|---|---|:---:|---:|---:|---:|---:|---:|---:|\n")
        for tag, mod, _ in MODULES:
            e = results.get(mod, {})
            f.write("| %s | `%s` | %s | %s | %s | %s | %s | %s | %s |\n" % (
                tag, mod, e.get("status", "?"),
                e.get("lut", "-"), e.get("ff", "-"), e.get("dsp", "-"),
                e.get("bram", "-"), e.get("wns", "-"),
                e.get("power_w", "-")))
    print("\nSummary:")
    print("  JSON: %s" % summ_path)
    print("  MD:   %s" % md_path, flush=True)
    n_ok = sum(1 for e in results.values() if e["status"] == "OK")
    print("  %d/%d modules synthesized OK" % (n_ok, len(MODULES)), flush=True)
    print("=" * 78, flush=True)
    return 0 if n_ok == len(MODULES) else 1


if __name__ == "__main__":
    sys.exit(main())
