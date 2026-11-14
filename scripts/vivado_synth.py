#!/usr/bin/env python3
"""
Vivado 系统级综合脚本 (Phase 4)
使用 D:/FPGA/2026.1/Vivado 的 unwrapped 工具链：
  xvlog → xelab → xsc
产出：util_system.rpt, timing_system.rpt, vivado_synth.log
"""
import subprocess, os, sys, shutil, glob, time

PROJECT = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype"
RTL     = os.path.join(PROJECT, "rtl")
CORE    = os.path.join(RTL, "core")
REAL    = os.path.join(RTL, "real")
SIM     = os.path.join(PROJECT, "sim")
RESULTS = os.path.join(PROJECT, "results")
CONST   = os.path.join(PROJECT, "constrains")
WORK     = os.path.join(PROJECT, "vivado_work")

VIVADO_BIN = r"D:\FPGA\2026.1\Vivado\bin\unwrapped\win64.o"
XVLOG  = os.path.join(VIVADO_BIN, "xvlog.exe")
XELAB  = os.path.join(VIVADO_BIN, "xelab.exe")
XSC    = os.path.join(VIVADO_BIN, "xsc.exe")

TOP = "ipx_aoi_sec_fpga_top"

def run(cmd, desc, timeout=300):
    print(f"\n{'='*60}")
    print(f"  {desc}")
    print(f"{'='*60}")
    print(f"  CMD: {' '.join(cmd[:5])} ...")
    t0 = time.time()
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout,
                          cwd=PROJECT, errors='replace')
        elapsed = time.time() - t0
        print(f"  Return: {r.returncode}  ({elapsed:.1f}s)")
        if r.stdout:
            for line in r.stdout.splitlines()[-30:]:
                print(f"  OUT: {line[:200]}")
        if r.stderr:
            for line in r.stderr.splitlines()[-20:]:
                print(f"  ERR: {line[:200]}")
        return r.returncode, r.stdout, r.stderr
    except subprocess.TimeoutExpired:
        print(f"  TIMEOUT after {timeout}s")
        return -1, "", "timeout"
    except Exception as e:
        print(f"  EXCEPTION: {e}")
        return -1, "", str(e)

def main():
    # Clean previous work
    if os.path.exists(WORK):
        shutil.rmtree(WORK)
    os.makedirs(WORK, exist_ok=True)

    # Collect all Verilog files in compile order
    verilog_files = []

    # 1. Top-level + stubs
    verilog_files.append(os.path.join(RTL, "ipx_aoi_sec_fpga_top.v"))
    verilog_files.append(os.path.join(RTL, "submodule_stubs.v"))

    # 2. Core modules (sorted)
    for f in sorted(glob.glob(os.path.join(CORE, "*.v"))):
        verilog_files.append(f)

    # 3. Real modules
    for f in sorted(glob.glob(os.path.join(REAL, "*.v"))):
        verilog_files.append(f)

    print(f"  Total Verilog files: {len(verilog_files)}")
    for f in verilog_files:
        print(f"    {os.path.basename(f)}")

    # ================================================================
    # Step 1: xvlog (compile)
    # ================================================================
    log_path = os.path.join(RESULTS, "vivado_synth.log")
    with open(log_path, "w", encoding="utf-8") as logf:
        logf.write("=== Vivado System-Level Synthesis Log ===\n")
        logf.write(f"Time: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        logf.write(f"Top: {TOP}\n")
        logf.write(f"Files: {len(verilog_files)}\n\n")

        cmd = [XVLOG, "-2012", "-workdir", WORK, "--name", TOP]
        for f in verilog_files:
            cmd.append(f)

        rc, out, err = run(cmd, "Step 1: xvlog (compile Verilog)")
        logf.write(f"\n--- xvlog ---\n")
        logf.write(out[-3000:] if out else "(no stdout)\n")
        logf.write(err[-2000:] if err else "(no stderr)\n")

        if rc != 0:
            print("\n*** xvlog FAILED ***")
            return 1

    # ================================================================
    # Step 2: xelab (elaborate)
    # ================================================================
    rc, out, err = run(
        [XELAB, "-workdir", WORK, "--top", TOP, "-s", TOP + "_sim"],
        "Step 2: xelab (elaborate)"
    )
    with open(log_path, "a", encoding="utf-8") as logf:
        logf.write(f"\n--- xelab ---\n")
        logf.write(out[-3000:] if out else "(no stdout)\n")
        logf.write(err[-2000:] if err else "(no stderr)\n")

    if rc != 0:
        print("\n*** xelab FAILED ***")
        return 1

    # ================================================================
    # Step 3: xsc (synthesize)
    # ================================================================
    xdc = os.path.join(CONST, "project.xdc")
    rc, out, err = run(
        [XSC, "-workdir", WORK, "--top", TOP,
         "-s", "2", "-t", "1", "-flattened", "module",
         "-XILINX_Synthesis", "1",
         "-out", os.path.join(RESULTS, "synthesis_messages.txt")],
        "Step 3: xsc (synthesize)"
    )
    with open(log_path, "a", encoding="utf-8") as logf:
        logf.write(f"\n--- xsc ---\n")
        logf.write(out[-5000:] if out else "(no stdout)\n")
        logf.write(err[-3000:] if err else "(no stderr)\n")

    if rc != 0:
        print("\n*** xsc FAILED ***")
        return 1

    # ================================================================
    # Step 4: Copy reports
    # ================================================================
    print(f"\n{'='*60}")
    print(f"  Copying reports")
    print(f"{'='*60}")

    # xsc writes reports to the work directory
    for rpt_name in ["util_system.rpt", "timing_system.rpt"]:
        src = os.path.join(WORK, rpt_name)
        dst = os.path.join(RESULTS, rpt_name)
        if os.path.exists(src):
            shutil.copy2(src, dst)
            print(f"  Copied: {rpt_name} ({os.path.getsize(dst)} bytes)")
        else:
            print(f"  NOT FOUND: {rpt_name} in {WORK}")

    # Also check for any .rpt files in work dir
    for f in os.listdir(WORK):
        if f.endswith('.rpt'):
            print(f"  Work file: {f} ({os.path.getsize(os.path.join(WORK, f))} bytes)")

    print(f"\n=== Synthesis Complete ===")
    return 0

if __name__ == "__main__":
    sys.exit(main())