#!/usr/bin/env python3
"""
Try kyber_ntt synthesis with RuntimeOptimized directive (minimal effort).
If timing optimization still hangs, parse utilization from the synthesis log.
"""
import subprocess, os, sys, shutil, time, io, re

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
CONST     = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")

VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART   = "xc7a100tcsg324-1"

TMP      = "C:/tmp_kem_ntt3_" + str(int(time.time()))
TMP_CORE = os.path.join(TMP, "core")
TMP_XDC  = os.path.join(TMP, "kem.xdc")
TMP_TCL  = os.path.join(TMP, "synth.tcl")
TMP_LOG  = os.path.join(TMP, "synth.log")
TMP_PROJ = os.path.join(TMP, "proj")

def parse_log_util(log_path):
    """Extract utilization estimates from synthesis log."""
    if not os.path.exists(log_path):
        return None
    with io.open(log_path, "r", encoding="utf-8", errors='replace') as fh:
        text = fh.read()

    result = {}

    # Parse register counts
    # Pattern: "16 Bit    Registers := 256"
    reg_match = re.search(r'(\d+)\s+Bit\s+Registers\s*:=\s*(\d+)', text)
    if reg_match:
        bits = int(reg_match.group(1))
        count = int(reg_match.group(2))
        result['FFs_from_log'] = bits * count

    # Parse all register lines
    total_ffs = 0
    for m in re.finditer(r'(\d+)\s+Bit\s+Registers\s*:=\s*(\d+)', text):
        total_ffs += int(m.group(1)) * int(m.group(2))
    if total_ffs:
        result['FFs'] = total_ffs

    # Parse DSP count
    dsp_match = re.search(r'DSPs:\s*(\d+)', text)
    if dsp_match:
        result['DSPs'] = int(dsp_match.group(1))

    # Parse ROM/LUT info
    # Pattern: "|kyber_ntt   | get_zeta   | 128x14        | LUT            |"
    lut_rom = 0
    for m in re.finditer(r'\|\s*([\w.]+)\s+\|\s*([\w.]+)\s+\|\s*(\d+)x(\d+)\s+\|\s*LUT', text):
        lut_rom += int(m.group(3)) * int(m.group(4))
    if lut_rom:
        result['LUT_ROM'] = lut_rom

    # Look for LUT count in the log
    # The log might have a line like "LUTs: XXXX" or similar
    # Actually, Vivado doesn't print LUT count in the synthesis log, only in the util report

    return result if result else None

def main():
    os.makedirs(TMP_CORE, exist_ok=True)

    shutil.copy2(os.path.join(CORE, "kyber_ntt.v"), os.path.join(TMP_CORE, "kyber_ntt.v"))
    shutil.copy2(os.path.join(CONST, "kem.xdc"), TMP_XDC)

    # Try with RuntimeOptimized directive - minimal effort, might complete faster
    tcl = f"""set PROJ "{TMP}"
set CORE "$PROJ/core"
set XDC  "$PROJ/kem.xdc"
set PART "{PART}"
puts "=== Synth kyber_ntt (RuntimeOptimized) ==="
set WORK "$PROJ/proj"
if {{[file exists $WORK]}} {{ file delete -force $WORK }}
file mkdir $WORK
create_project -force ntt_synth $WORK -part $PART
add_files "$CORE/kyber_ntt.v"
read_xdc $XDC
puts "=== Running synth_design ==="
synth_design -top kyber_ntt -part $PART -directive RuntimeOptimized
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
                         timeout=180, cwd=TMP, errors='replace')
        elapsed = time.time() - t0
        print(f"rc={r.returncode}  time={elapsed:.1f}s")

        # Copy log
        log_dst = os.path.join(RESULTS, "synth_sub_kyber_ntt3.log")
        if os.path.exists(TMP_LOG):
            shutil.copy2(TMP_LOG, log_dst)

        # Copy reports
        rpt_dir = os.path.join(TMP_PROJ, "reports")
        if os.path.exists(rpt_dir):
            for rf in ["util.rpt", "timing.rpt", "hierarchy.rpt"]:
                src = os.path.join(rpt_dir, rf)
                if os.path.exists(src):
                    dst = os.path.join(RESULTS, f"synth_sub_kyber_ntt3_{rf}")
                    shutil.copy2(src, dst)
                    print(f"Report: {rf} ({os.path.getsize(src)} bytes)")

        # Parse util from report if available
        util_path = os.path.join(rpt_dir, "util.rpt")
        if os.path.exists(util_path):
            with io.open(util_path, "r", encoding="utf-8", errors='replace') as fh:
                for line in fh:
                    line = line.strip()
                    if line.startswith("Slice LUTs") or line.startswith("Slice Registers") or line.startswith("DSPs"):
                        parts = line.split("|")
                        if len(parts) >= 5:
                            print(f"  {parts[0].strip()}: {parts[1].strip()}")

        # Parse from log if no report
        util_data = parse_log_util(TMP_LOG)
        if util_data:
            print(f"\n  Parsed from log: {util_data}")

        return 0 if r.returncode == 0 else 1
    except subprocess.TimeoutExpired:
        elapsed = time.time() - t0
        print(f"TIMEOUT after {elapsed:.1f}s")
        # Parse what we can from the log
        util_data = parse_log_util(TMP_LOG)
        if util_data:
            print(f"\n  Parsed from log (partial): {util_data}")
        # Copy log anyway
        if os.path.exists(TMP_LOG):
            log_dst = os.path.join(RESULTS, "synth_sub_kyber_ntt3.log")
            shutil.copy2(TMP_LOG, log_dst)
            print(f"Log copied: {log_dst} ({os.path.getsize(TMP_LOG)} bytes)")
        return -1
    except Exception as e:
        print("ERR:", e)
        return -1

if __name__ == "__main__":
    sys.exit(main())