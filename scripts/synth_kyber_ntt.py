#!/usr/bin/env python3
"""
Synthesize kyber_ntt standalone with reduced timing optimization effort.
The full synth_design hangs at timing optimization for this module
(240 DSPs, complex routing).  Using -directive AreaOptimized_high
reduces timing effort and should complete.
"""
import subprocess, os, sys, shutil, time, io

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
CONST     = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")

VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART   = "xc7a100tcsg324-1"

TMP      = "C:/tmp_kem_ntt2_" + str(int(time.time()))
TMP_CORE = os.path.join(TMP, "core")
TMP_XDC  = os.path.join(TMP, "kem.xdc")
TMP_TCL  = os.path.join(TMP, "synth.tcl")
TMP_LOG  = os.path.join(TMP, "synth.log")
TMP_PROJ = os.path.join(TMP, "proj")

def main():
    os.makedirs(TMP_CORE, exist_ok=True)

    # Copy source
    shutil.copy2(os.path.join(CORE, "kyber_ntt.v"), os.path.join(TMP_CORE, "kyber_ntt.v"))
    shutil.copy2(os.path.join(CONST, "kem.xdc"), TMP_XDC)

    tcl = f"""set PROJ "{TMP}"
set CORE "$PROJ/core"
set XDC  "$PROJ/kem.xdc"
set PART "{PART}"
puts "=== Synth kyber_ntt (AreaOptimized_high) ==="
set WORK "$PROJ/proj"
if {{[file exists $WORK]}} {{ file delete -force $WORK }}
file mkdir $WORK
create_project -force ntt_synth $WORK -part $PART
add_files "$CORE/kyber_ntt.v"
read_xdc $XDC
puts "=== Running synth_design ==="
synth_design -top kyber_ntt -part $PART -directive AreaOptimized_high
puts "=== Writing reports ==="
set RPT "$WORK/reports"
file mkdir $RPT
report_utilization -file "$RPT/util.rpt" -hierarchical
report_timing_summary -file "$RPT/timing.rpt" -delay_type minmax -warn_on_timing -max_paths 3
report_hierarchy -file "$RPT/hierarchy.rpt"
puts "=== Done ==="
exit
"""
    with io.open(TMP_TCL, "w", encoding="utf-8") as fh:
        fh.write(tcl)

    cmd = [VIVADO, "-mode", "batch", "-nojournal",
           "-log", TMP_LOG, "-source", TMP_TCL]
    print(f"CMD: {' '.join(cmd)}")
    t0 = time.time()
    try:
        r = subprocess.run(cmd, capture_output=True, text=True,
                         timeout=600, cwd=TMP, errors='replace')
        elapsed = time.time() - t0
        print(f"rc={r.returncode}  time={elapsed:.1f}s")

        # Copy log
        log_dst = os.path.join(RESULTS, "synth_sub_kyber_ntt2.log")
        if os.path.exists(TMP_LOG):
            shutil.copy2(TMP_LOG, log_dst)

        # Copy reports
        rpt_dir = os.path.join(TMP_PROJ, "reports")
        if os.path.exists(rpt_dir):
            for rf in ["util.rpt", "timing.rpt", "hierarchy.rpt"]:
                src = os.path.join(rpt_dir, rf)
                if os.path.exists(src):
                    dst = os.path.join(RESULTS, f"synth_sub_kyber_ntt2_{rf}")
                    shutil.copy2(src, dst)
                    print(f"Report: {rf} ({os.path.getsize(src)} bytes)")

        # Parse util
        util_path = os.path.join(rpt_dir, "util.rpt")
        if os.path.exists(util_path):
            with io.open(util_path, "r", encoding="utf-8", errors='replace') as fh:
                for line in fh:
                    line = line.strip()
                    if line.startswith("Slice LUTs") or line.startswith("Slice Registers") or line.startswith("DSPs"):
                        parts = line.split("|")
                        if len(parts) >= 5:
                            print(f"  {parts[0].strip()}: {parts[1].strip()}")
        return 0 if r.returncode == 0 else 1
    except subprocess.TimeoutExpired:
        print("TIMEOUT after 600s")
        return -1
    except Exception as e:
        print("ERR:", e)
        return -1

if __name__ == "__main__":
    sys.exit(main())