#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Settle the device-budget question authoritatively.

The report's section 1 budget table (32,600 LUT / 65,200 FF / 120 DSP /
270 BRAM for xc7a100t) does not match the device database: get_property
on the same Vivado install gives xc7a100t LUT_ELEMENTS=63400,
FLIPFLOPS=126800, DSP=240, BLOCK_RAMS=135. If the 63,400 figure is the
one Vivado's own utilization engine uses, then the post-P1 netlist
(58,852 LUT / 39,738 FF) FITS xc7a100t at 92.8% LUT / 31.4% FF, and the
'1.81x over' verdict plus the whole P2 board-change recommendation rests
on a wrong budget.

report_utilization prints the device 'Available' column from exactly the
same database that produces the 'Used' column, so probing it on a trivial
one-flipflop design settles the question in seconds instead of
re-synthesising the full 58k-LUT netlist.

One Vivado process per part (avoids reset_run/close_design issues in
project-less mode). xc7a50t is probed too because its FLIPFLOPS = 32,600,
which is the suspected source of the erroneous 32,600 figure.

Outputs -> results/device_budget_probe.log
"""
import subprocess, os, sys, io, time

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
RESULTS   = os.path.join(PROJECT, "results")

TS    = str(int(time.time()))
TMP   = "C:/tmp_devbudget_" + TS
VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"

PARTS = [
    ("xc7a100tcsg324-1", "TARGET BOARD PART  (report s1 claims 32,600 LUT)"),
    ("xc7a50tfgg484-1",  "SUSPECT SOURCE OF THE 32,600 FIGURE"),
    ("xc7a200tfbg484-1", "P2 FALLBACK"),
]

DUMMY_V = """module dummy(input clk, output reg q);
always @(posedge clk) q <= ~q;
endmodule
"""


def build_tcl(part, dummy_path):
    L = []
    L.append('puts "### PART ' + part + '"')
    L.append('# get_property device database view')
    L.append('foreach pr {LUT_ELEMENTS FLIPFLOPS SLICES BLOCK_RAMS DSP AVAILABLE_IOBS} {')
    L.append('    puts "  GP_$pr = [get_property $pr [get_parts ' + part + ']]"')
    L.append('}')
    L.append('# synthesis-engine view (report_utilization Available column)')
    L.append('read_verilog "' + dummy_path.replace("\\", "/") + '"')
    L.append('synth_design -top dummy -part ' + part)
    L.append('puts "  ---- report_utilization (non-hierarchical) ----"')
    L.append('report_utilization')
    L.append('puts "  ---- end report_utilization ----"')
    L.append('puts "### END PART ' + part + '"')
    L.append('exit 0')
    return "\n".join(L)


def run(part, label, dummy_path):
    tcl = os.path.join(TMP, "probe_" + part + ".tcl")
    log = os.path.join(TMP, "probe_" + part + ".log")
    with io.open(tcl, "w", encoding="utf-8") as fh:
        fh.write(build_tcl(part, dummy_path))
    t0 = time.time()
    try:
        r = subprocess.run([VIVADO, "-mode", "batch", "-nojournal",
                            "-log", log, "-source", tcl],
                           capture_output=True, text=True, timeout=300,
                           cwd=TMP, errors="replace")
        rc = r.returncode
    except subprocess.TimeoutExpired:
        rc = -999
    el = time.time() - t0
    txt = io.open(log, encoding="utf-8", errors="replace").read() \
          if os.path.exists(log) else ""
    return {"part": part, "label": label, "rc": rc, "elapsed": el, "log": txt}


def main():
    os.makedirs(TMP, exist_ok=True)
    dummy = os.path.join(TMP, "dummy.v")
    with io.open(dummy, "w", encoding="utf-8") as fh:
        fh.write(DUMMY_V)
    print("tmp ->", TMP)

    chunks = ["# device budget probe, %s" % time.strftime("%Y-%m-%d %H:%M:%S"),
              "# tool: " + VIVADO, "",
              "# Host memory 68 GB, 46 GB available virtual -> the Oct-14 xc7a200t",
              "# synthesis stall cannot be memory pressure.", ""]
    for part, label in PARTS:
        res = run(part, label, dummy)
        chunks.append("=" * 100)
        chunks.append("PART %-20s  %s" % (res["part"], res["label"]))
        chunks.append("rc=%s  elapsed=%.1fs" % (res["rc"], res["elapsed"]))
        chunks.append("=" * 100)
        chunks.append(res["log"])
        print("  %s rc=%s %.1fs" % (part, res["rc"], res["elapsed"]))

    out = os.path.join(RESULTS, "device_budget_probe.log")
    with io.open(out, "w", encoding="utf-8") as fh:
        fh.write("\n".join(chunks))
    print("log -> %s (%d bytes)" % (out, os.path.getsize(out)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
