#!/usr/bin/env python3
"""Synthesize full top-level with kyber_kem integration."""
import subprocess, os, shutil, time

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
VIVADO    = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART      = "xc7a100tcsg324-1"

stamp = str(int(time.time()))
TMP = f"C:/tmp_top_kem2_{stamp}"
os.makedirs(TMP, exist_ok=True)

# Copy RTL to ASCII-only temp dir (core + real + top-level)
for sub in ["core", "real"]:
    src = os.path.join(PROJECT, "rtl", sub)
    dst = os.path.join(TMP, "rtl", sub)
    os.makedirs(dst, exist_ok=True)
    for f in os.listdir(src):
        if f.endswith(".v"):
            shutil.copy2(os.path.join(src, f), os.path.join(dst, f))

# Copy top-level module (in rtl/ directly)
top_src = os.path.join(PROJECT, "rtl", "ipx_aoi_sec_fpga_top.v")
if os.path.exists(top_src):
    shutil.copy2(top_src, os.path.join(TMP, "rtl", "ipx_aoi_sec_fpga_top.v"))

# Copy other top-level files (nexys_top etc.)
for f in os.listdir(os.path.join(PROJECT, "rtl")):
    if f.endswith(".v") and f != "ipx_aoi_sec_fpga_top.v":
        shutil.copy2(os.path.join(PROJECT, "rtl", f), os.path.join(TMP, "rtl", f))

# XDC
xdc_path = os.path.join(TMP, "top.xdc").replace("\\", "/")
with open(xdc_path, "w") as f:
    f.write("# 100 MHz clock\n")
    f.write("create_clock -period 10.0 [get_ports clk]\n")
    f.write("set_clock_uncertainty 0.300 [get_ports clk]\n")
    f.write("set_false_path -from [get_ports rst_n]\n")

# Collect RTL file list (forward slashes for Tcl)
rtl_files = []
# Top-level files in rtl/ directly
for f in sorted(os.listdir(os.path.join(TMP, "rtl"))):
    if f.endswith(".v"):
        rtl_files.append(f"{os.path.join(TMP, 'rtl', f)}".replace("\\", "/"))
# Core + real subdirs
for sub in ["core", "real"]:
    d = os.path.join(TMP, "rtl", sub)
    for f in sorted(os.listdir(d)):
        if f.endswith(".v"):
            rtl_files.append(f"{d}/{f}".replace("\\", "/"))

# TCL - use forward slashes, no empty add_files
tcl_path = os.path.join(TMP, "synth.tcl").replace("\\", "/")
with open(tcl_path, "w") as f:
    f.write(f'create_project -name top_kem -dir "{TMP}/proj" -part {PART} -force\n')
    for rf in rtl_files:
        f.write(f'add_files -fileset sources_1 "{rf}"\n')
    f.write(f'add_files -fileset constrs_1 "{xdc_path}"\n')
    f.write("synth_design -top ipx_aoi_sec_fpga_top\n")
    f.write("report_timing -max_paths 5\n")
    f.write(f"report_timing -file \"{TMP}/timing.rpt\" -max_paths 5\n")
    f.write(f"report_utilization -file \"{TMP}/util.rpt\"\n")
    f.write("exit\n")

print(f"TMP: {TMP}")
print(f"RTL files: {len(rtl_files)}")

t0 = time.time()
r = subprocess.run(
    [VIVADO, "-mode", "batch",
     "-log", f"{TMP}/synth.log",
     "-journal", f"{TMP}/synth.jou",
     "-source", tcl_path],
    capture_output=True, text=True, encoding='latin-1', timeout=900
)
elapsed = time.time() - t0
print(f"Duration: {elapsed:.1f}s")

out = r.stdout
for line in out.split("\n"):
    if any(k in line for k in ["Slack", "LUT", "FF", "DSP", "Fmax", "WNS"]):
        print(line.strip())

# Copy reports
results = os.path.join(PROJECT, "results")
for rpt in ["timing.rpt", "util.rpt"]:
    src = os.path.join(TMP, rpt)
    if os.path.exists(src):
        shutil.copy2(src, os.path.join(results, f"top_kem_{rpt}"))
        print(f"Copied {rpt}")

if r.stderr:
    print("=== STDERR ===")
    print(r.stderr[-500:])

print("=== DONE ===")
