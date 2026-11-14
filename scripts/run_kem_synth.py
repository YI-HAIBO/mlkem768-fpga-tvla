#!/usr/bin/env python3
"""
Vivado synthesis for kyber_kem standalone (ML-KEM-768).
- Copies 6 core .v files + kem.xdc to C:/tmp_kem_synth/ (ASCII path)
- Runs vivado.bat -mode batch with a tcl that does synth_design + reports
- Emits: results/kem_synth_util.rpt, results/kem_synth_timing.rpt, results/kem_synth.log
- Reports LUT/FF usage and WNS.
"""
import subprocess, os, sys, shutil, time, io

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
CONST     = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")

TMP      = "C:/tmp_kem_synth_" + str(int(time.time()))
TMP_CORE = os.path.join(TMP, "core")
TMP_XDC  = os.path.join(TMP, "kem.xdc")
TMP_TCL  = os.path.join(TMP, "synth.tcl")
TMP_LOG  = os.path.join(TMP, "synth.log")
TMP_PROJ = os.path.join(TMP, "proj")

VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART   = "xc7a100tcsg324-1"

FILES = ["shake.v", "keccak_perm.v", "kyber_ntt.v", "kyber_poly.v", "kyber_sampler.v", "kyber_kem.v"]

def build_tcl():
    lines = []
    lines.append('set PROJ "' + TMP.replace("\\", "/") + '"')
    lines.append('set CORE "$PROJ/core"')
    lines.append('set XDC  "$PROJ/kem.xdc"')
    lines.append('set PART "' + PART + '"')
    lines.append('puts "=== Vivado synth for kyber_kem (ML-KEM-768) ==="')
    lines.append('puts "Time: [clock format [clock seconds]]"')
    lines.append('puts "Part: $PART"')
    lines.append('set WORK "$PROJ/proj"')
    lines.append('if {[file exists $WORK]} { file delete -force $WORK }')
    lines.append('file mkdir $WORK')
    lines.append('create_project -force kem_synth $WORK -part $PART')
    lines.append('')
    lines.append('puts "=== Adding sources ==="')
    lines.append('foreach f {' + ' '.join(FILES) + '} {')
    lines.append('    add_files "$CORE/$f"')
    lines.append('    puts "  added $f"')
    lines.append('}')
    lines.append('puts "=== Adding constraints ==="')
    lines.append('read_xdc $XDC')
    # Note: synth_design -top below sets the top module; set_property top
    # on [get_filesets] is not valid in this context.
    lines.append('')
    lines.append('puts "=== Running synth_design ==="')
    lines.append('synth_design -top kyber_kem -part $PART')
    lines.append('')
    lines.append('puts "=== Writing reports ==="')
    lines.append('set RPT "$WORK/reports"')
    lines.append('file mkdir $RPT')
    lines.append('report_utilization -file "$RPT/util.rpt" -hierarchical')
    lines.append('report_timing_summary -file "$RPT/timing.rpt" -max_paths 3')
    lines.append('report_timing -file "$RPT/timing_paths.rpt" -max_paths 15 -setup')
    lines.append('report_control_sets -hierarchical -file "$RPT/control_sets.rpt"')
    lines.append('write_checkpoint -force "$WORK/kem_synth.dcp"')
    lines.append('')
    lines.append('puts "=== Done ==="')
    lines.append('exit')
    return '\n'.join(lines)

def main():
    # Use timestamped tmp dir to avoid bulk-delete confirm prompts
    os.makedirs(TMP_CORE, exist_ok=True)

    print(f"=== Copying {len(FILES)} .v files + xdc to {TMP} ===")
    for f in FILES:
        src = os.path.join(CORE, f)
        dst = os.path.join(TMP_CORE, f)
        shutil.copy2(src, dst)
        print(f"  {f}  ({os.path.getsize(dst)} bytes)")
    xdc_src = os.path.join(CONST, "kem.xdc")
    shutil.copy2(xdc_src, TMP_XDC)
    print(f"  kem.xdc  ({os.path.getsize(TMP_XDC)} bytes)")

    tcl = build_tcl()
    with io.open(TMP_TCL, "w", encoding="utf-8") as fh:
        fh.write(tcl)
    print(f"Wrote {TMP_TCL}")

    print(f"\n=== Running Vivado synth ({PART}) ===")
    cmd = [VIVADO, "-mode", "batch", "-nojournal", "-log", TMP_LOG, "-source", TMP_TCL]
    print(f"CMD: {' '.join(cmd)}")
    t0 = time.time()
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=3600,
                          cwd=TMP, errors='replace')
        elapsed = time.time() - t0
        print(f"rc={r.returncode}  time={elapsed:.1f}s")

        # Copy log
        log_dst = os.path.join(RESULTS, "kem_synth.log")
        if os.path.exists(TMP_LOG):
            shutil.copy2(TMP_LOG, log_dst)
            print(f"Log copied: {log_dst} ({os.path.getsize(log_dst)} bytes)")

        # Copy reports
        rpt_dir = os.path.join(TMP_PROJ, "reports")
        if os.path.exists(rpt_dir):
            for rf in ["util.rpt", "timing.rpt", "timing_paths.rpt", "control_sets.rpt", "hierarchy.rpt"]:
                src = os.path.join(rpt_dir, rf)
                if os.path.exists(src):
                    dst = os.path.join(RESULTS, f"kem_synth_{rf.replace('.rpt','')}.rpt")
                    shutil.copy2(src, dst)
                    print(f"Report: {rf} ({os.path.getsize(src)} bytes)")

        # Parse key metrics from log
        if os.path.exists(TMP_LOG):
            with io.open(TMP_LOG, "r", encoding="utf-8", errors='replace') as fh:
                log = fh.read()
            # Look for LUT/FF summary
            print("\n=== Key metrics from log ===")
            for ln in log.splitlines():
                if any(k in ln for k in ['Slice LUTs', 'Slice Registers', 'WNS', 'WHN', 'Fmax', 'Slack', 'Number of errors', 'ERROR:']):
                    print(f"  {ln[:200]}")
            # Errors
            errs = [ln for ln in log.splitlines() if 'ERROR:' in ln or 'error:' in ln]
            print(f"\nErrors: {len(errs)}")
            for e in errs[:10]:
                print(f"  {e[:200]}")

        return 0 if r.returncode == 0 else 1
    except subprocess.TimeoutExpired:
        print("TIMEOUT after 3600s")
        return -1
    except Exception as e:
        print("ERR:", e)
        return -1

if __name__ == "__main__":
    sys.exit(main())
