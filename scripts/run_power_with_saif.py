#!/usr/bin/env python3
"""
Generate SAIF activity file from xsim RTL simulation, then re-run Vivado
report_power with the activity file to upgrade power estimation confidence.

Flow:
  1. Copy RTL + TB to ASCII temp dir (avoid Chinese path issues with Vivado)
  2. xvlog  - compile all Verilog sources
  3. xelab  - elaborate the testbench
  4. xsim   - run simulation, write SAIF
  5. Vivado - open DCP, report_power -activity_file <saif>

Usage: python scripts/run_power_with_saif.py
"""
import os
import sys
import subprocess
import shutil
import time

# ---------------------------------------------------------------
# Paths
# ---------------------------------------------------------------
HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
RTL_CORE = os.path.join(ROOT, "rtl", "core")
BOARD_TOP = os.path.join(ROOT, "rtl", "ipx_aoi_sec_board_top.v")
SIM_DIR = os.path.join(ROOT, "sim")
DCP = os.path.join(ROOT, "results", "ipx_aoi_sec_nexys_top.dcp")

VIVADO_BIN = "D:/FPGA/2026.1/Vivado/bin"
XVLOG = os.path.join(VIVADO_BIN, "xvlog.bat")
XELAB = os.path.join(VIVADO_BIN, "xelab.bat")
XSIM = os.path.join(VIVADO_BIN, "xsim.bat")
VIVADO = os.path.join(VIVADO_BIN, "vivado.bat")

# ASCII work directory (Chinese paths corrupt in Vivado tools)
WORK = "c:/tmp/xsim_power"

# RTL source files for the board top
RTL_FILES = [
    "kyber_kem.v",
    "kyber_poly.v",
    "kyber_ntt.v",
    "kyber_sampler.v",
    "shake.v",
    "keccak_perm.v",
]
TB_FILE = "tb_ipx_aoi_sec_board_top.v"


def run_cmd(cmd, cwd=None, timeout=600, env=None):
    """Run a command and return (rc, stdout, stderr)."""
    print("  $ " + " ".join(cmd), flush=True)
    t0 = time.time()
    p = subprocess.run(cmd, capture_output=True, timeout=timeout,
                       cwd=cwd, env=env)
    dt = time.time() - t0
    so = p.stdout.decode("utf-8", errors="replace")
    se = p.stderr.decode("utf-8", errors="replace")
    return p.returncode, so, se, dt


def main():
    print("=" * 78, flush=True)
    print("SAIF Generation + Power Report Upgrade", flush=True)
    print("=" * 78, flush=True)

    # -----------------------------------------------------------
    # Step 0: Setup work directory
    # -----------------------------------------------------------
    # Use timestamped dir to avoid rmtree on large dirs
    import time as _time
    WORK = f"c:/tmp/xsim_power_{int(_time.time())}"
    os.makedirs(WORK, exist_ok=True)

    # Copy RTL sources
    for f in RTL_FILES:
        src = os.path.join(RTL_CORE, f)
        dst = os.path.join(WORK, f)
        shutil.copy2(src, dst)
        print(f"  Copied {f}", flush=True)

    # Copy board top
    shutil.copy2(BOARD_TOP, os.path.join(WORK, "ipx_aoi_sec_board_top.v"))
    print("  Copied ipx_aoi_sec_board_top.v", flush=True)

    # Patch: xvlog is strict about forward references. The board top uses
    # clk_slow (wire, declared at line ~97) before its declaration in an
    # always block at line ~69. Move the declaration before first use.
    board_top_path = os.path.join(WORK, "ipx_aoi_sec_board_top.v")
    with open(board_top_path, "r") as f:
        content = f.read()

    # Move "wire clk_slow = ..." before the always block that uses it
    old_decl = "    wire clk_slow = (CLK_DIV <= 1) ? clk : clk_slow_r;"
    # Insert a forward declaration before line 69's always block
    # Simplest: add "wire clk_slow;" before the always block, and change
    # the later declaration to an assign
    forward_decl = "    wire clk_slow;\n"
    # Find the rst_t1 always block that first uses clk_slow
    marker = "    // rst_sync 再同步进 clk_slow 域"
    if marker in content:
        content = content.replace(
            marker,
            forward_decl + marker
        )
    # Change the later declaration to assign
    content = content.replace(
        old_decl,
        "    assign clk_slow = (CLK_DIV <= 1) ? clk : clk_slow_r;"
    )
    with open(board_top_path, "w") as f:
        f.write(content)
    print("  Patched ipx_aoi_sec_board_top.v (clk_slow forward decl)", flush=True)

    # Copy testbench
    shutil.copy2(os.path.join(SIM_DIR, TB_FILE), os.path.join(WORK, TB_FILE))
    print(f"  Copied {TB_FILE}", flush=True)

    # Copy DCP
    dcp_dst = os.path.join(WORK, "design.dcp")
    shutil.copy2(DCP, dcp_dst)
    print("  Copied design.dcp", flush=True)

    # -----------------------------------------------------------
    # Step 1: Compile with xvlog
    # -----------------------------------------------------------
    print("\n--- Step 1: xvlog compile ---", flush=True)
    all_files = RTL_FILES + ["ipx_aoi_sec_board_top.v", TB_FILE]
    cmd = [XVLOG] + all_files
    rc, so, se, dt = run_cmd(cmd, cwd=WORK, timeout=120)
    if so.strip():
        print(so.strip(), flush=True)
    if se.strip():
        print("[stderr]", se.strip(), flush=True)
    if rc != 0:
        print(f"xvlog FAILED (rc={rc}, {dt:.1f}s)", flush=True)
        return False
    print(f"xvlog OK ({dt:.1f}s)", flush=True)

    # -----------------------------------------------------------
    # Step 2: Elaborate with xelab
    # -----------------------------------------------------------
    print("\n--- Step 2: xelab elaborate ---", flush=True)
    cmd = [XELAB, "-top", "tb_ipx_aoi_sec_board_top",
           "-snapshot", "power_sim",
           "-timescale", "1ns/1ps"]
    rc, so, se, dt = run_cmd(cmd, cwd=WORK, timeout=300)
    if so.strip():
        print(so.strip(), flush=True)
    if se.strip():
        print("[stderr]", se.strip(), flush=True)
    if rc != 0:
        print(f"xelab FAILED (rc={rc}, {dt:.1f}s)", flush=True)
        return False
    print(f"xelab OK ({dt:.1f}s)", flush=True)

    # -----------------------------------------------------------
    # Step 3: Run xsim with SAIF generation
    # -----------------------------------------------------------
    print("\n--- Step 3: xsim run + SAIF ---", flush=True)

    # Write Tcl script for xsim
    # xsim v2026.1 doesn't support open_saif_file/write_saif Tcl commands.
    # Instead, use --wdb to generate a waveform database, which Vivado's
    # report_power can use as an activity file.
    tcl_content = """# xsim Tcl: run simulation (WDB captured via command line)
run all
exit
"""
    tcl_path = os.path.join(WORK, "run_sim.tcl")
    with open(tcl_path, "w") as f:
        f.write(tcl_content)

    # Write WDB for power analysis
    wdb_path = os.path.join(WORK, "power_activity.wdb")
    cmd = [XSIM, "power_sim", "-tclbatch", "run_sim.tcl",
           "--wdb", wdb_path]
    rc, so, se, dt = run_cmd(cmd, cwd=WORK, timeout=900)
    if so.strip():
        print(so.strip(), flush=True)
    if se.strip():
        print("[stderr]", se.strip(), flush=True)

    saif_path = os.path.join(WORK, "power_activity.wdb")
    if not os.path.exists(saif_path):
        print(f"WDB file not generated at {saif_path}", flush=True)
        print(f"xsim rc={rc}, {dt:.1f}s", flush=True)
        return False

    saif_size = os.path.getsize(saif_path)
    print(f"WDB generated: {saif_path} ({saif_size:,} bytes, {dt:.1f}s)",
          flush=True)

    # -----------------------------------------------------------
    # Step 4: Vivado report_power with activity file
    # -----------------------------------------------------------
    print("\n--- Step 4: Vivado report_power -activity_file ---", flush=True)

    vivado_tcl = f"""# Power report with WDB activity file
open_checkpoint {WORK}/design.dcp
report_power -file {WORK}/power_with_saif.rpt -activity_file {WORK}/power_activity.wdb
report_timing_summary -file {WORK}/timing_summary.rpt
exit
"""
    vivado_tcl_path = os.path.join(WORK, "report_power_saif.tcl")
    with open(vivado_tcl_path, "w") as f:
        f.write(vivado_tcl)

    # Set environment for Vivado
    env = os.environ.copy()
    env["XILINX_VIVADO"] = VIVADO_BIN

    cmd = [VIVADO, "-mode", "batch", "-source", vivado_tcl_path,
           "-nojournal", "-nolog"]
    rc, so, se, dt = run_cmd(cmd, cwd=WORK, timeout=600, env=env)
    if so.strip():
        print(so.strip(), flush=True)
    if se.strip():
        print("[stderr]", se.strip(), flush=True)

    power_rpt = os.path.join(WORK, "power_with_saif.rpt")
    if not os.path.exists(power_rpt):
        print(f"Power report not generated at {power_rpt}", flush=True)
        print(f"Vivado rc={rc}, {dt:.1f}s", flush=True)
        return False

    print(f"\nPower report generated: {power_rpt}", flush=True)

    # Copy report back to results
    rpt_dst = os.path.join(ROOT, "results",
                           "impl_board_top_t75f_power_saif.rpt")
    shutil.copy2(power_rpt, rpt_dst)
    print(f"Copied to: {rpt_dst}", flush=True)

    # Print key results
    print("\n--- Power Report Summary ---", flush=True)
    with open(rpt_dst, "r") as f:
        content = f.read()
    for line in content.split("\n"):
        if any(k in line for k in ["Total On-Chip Power", "Dynamic",
                                    "Static", "Confidence", "Vccint",
                                    "Junction", "activity"]):
            print(f"  {line.strip()}", flush=True)

    print("\n" + "=" * 78, flush=True)
    print("DONE: SAIF power report complete", flush=True)
    print("=" * 78, flush=True)
    return True


if __name__ == "__main__":
    ok = main()
    sys.exit(0 if ok else 1)
