#!/usr/bin/env python3
"""
Synthesize each kyber sub-module individually on Artix-7 XC7A100T.
The full kyber_kem top uses ~184K distributed-register bits (way over the
65,200 FF limit), which makes Vivado hang at logic optimization.  Individual
sub-modules are small enough to synthesize in reasonable time.

Emits: results/synth_sub_<name>.rpt (util + timing) per module.
"""
import subprocess, os, sys, shutil, time, io

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
CONST     = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")

VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART   = "xc7a100tcsg324-1"

# (top_module, [source_files])
# Each entry synthesizes a single top module with its dependency files.
SUBMODULES = [
    ("keccak_perm", ["keccak_perm.v"]),
    ("shake",       ["shake.v", "keccak_perm.v"]),
    ("kyber_sampler", ["kyber_sampler.v"]),
    ("kyber_ntt",   ["kyber_ntt.v"]),
    ("kyber_poly",  ["kyber_poly.v"]),
    ("kyber_kem",   ["shake.v", "keccak_perm.v", "kyber_ntt.v",
                     "kyber_poly.v", "kyber_sampler.v", "kyber_kem.v"]),
]

def build_tcl(top, files, tmp):
    lines = []
    lines.append('set PROJ "' + tmp.replace("\\", "/") + '"')
    lines.append('set CORE "$PROJ/core"')
    lines.append('set XDC  "$PROJ/kem.xdc"')
    lines.append('set PART "' + PART + '"')
    lines.append('puts "=== Synth sub-module: ' + top + ' ==="')
    lines.append('puts "Time: [clock format [clock seconds]]"')
    lines.append('set WORK "$PROJ/proj"')
    lines.append('if {[file exists $WORK]} { file delete -force $WORK }')
    lines.append('file mkdir $WORK')
    lines.append('create_project -force sub_synth $WORK -part $PART')
    lines.append('')
    lines.append('puts "=== Adding sources ==="')
    for f in files:
        lines.append('add_files "$CORE/' + f + '"')
        lines.append('puts "  added ' + f + '"')
    lines.append('puts "=== Adding constraints ==="')
    lines.append('read_xdc $XDC')
    lines.append('')
    lines.append('puts "=== Running synth_design ==="')
    lines.append('synth_design -top ' + top + ' -part $PART')
    lines.append('')
    lines.append('puts "=== Writing reports ==="')
    lines.append('set RPT "$WORK/reports"')
    lines.append('file mkdir $RPT')
    lines.append('report_utilization -file "$RPT/util.rpt" -hierarchical')
    lines.append('report_timing_summary -file "$RPT/timing.rpt" -delay_type minmax -warn_on_timing -max_paths 3')
    lines.append('report_hierarchy -file "$RPT/hierarchy.rpt"')
    lines.append('')
    lines.append('puts "=== Done ==="')
    lines.append('exit')
    return '\n'.join(lines)

def parse_util(log_path):
    """Extract LUT, FF, DSP, BRAM from util report."""
    if not os.path.exists(log_path):
        return None
    with io.open(log_path, "r", encoding="utf-8", errors='replace') as fh:
        text = fh.read()
    result = {}
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("Slice LUTs"):
            parts = line.split("|")
            if len(parts) >= 5:
                result["LUTs"] = parts[1].strip()
        elif line.startswith("Slice Registers"):
            parts = line.split("|")
            if len(parts) >= 5:
                result["FFs"] = parts[1].strip()
        elif line.startswith("DSPs"):
            parts = line.split("|")
            if len(parts) >= 5:
                result["DSPs"] = parts[1].strip()
        elif "Block RAM" in line and "Tile" in line:
            parts = line.split("|")
            if len(parts) >= 5:
                result["BRAM"] = parts[1].strip()
    return result if result else None

def parse_timing(log_path):
    """Extract WNS from timing report."""
    if not os.path.exists(log_path):
        return None
    with io.open(log_path, "r", encoding="utf-8", errors='replace') as fh:
        text = fh.read()
    for line in text.splitlines():
        line = line.strip()
        if "WNS" in line and ("ns" in line or "Total" in line):
            return line[:200]
    return None

def main():
    os.makedirs(RESULTS, exist_ok=True)
    summary = []

    for top, files in SUBMODULES:
        print(f"\n{'='*60}")
        print(f"Synthesizing: {top}  ({len(files)} files)")
        print(f"{'='*60}")

        tmp = "C:/tmp_kem_sub_" + str(int(time.time()))
        tmp_core = os.path.join(tmp, "core")
        tmp_xdc  = os.path.join(tmp, "kem.xdc")
        tmp_tcl  = os.path.join(tmp, "synth.tcl")
        tmp_log  = os.path.join(tmp, "synth.log")
        tmp_proj = os.path.join(tmp, "proj")

        os.makedirs(tmp_core, exist_ok=True)

        # Copy source files
        for f in files:
            shutil.copy2(os.path.join(CORE, f), os.path.join(tmp_core, f))
        shutil.copy2(os.path.join(CONST, "kem.xdc"), tmp_xdc)

        tcl = build_tcl(top, files, tmp)
        with io.open(tmp_tcl, "w", encoding="utf-8") as fh:
            fh.write(tcl)

        cmd = [VIVADO, "-mode", "batch", "-nojournal",
               "-log", tmp_log, "-source", tmp_tcl]
        t0 = time.time()
        try:
            r = subprocess.run(cmd, capture_output=True, text=True,
                             timeout=600, cwd=tmp, errors='replace')
            elapsed = time.time() - t0
            print(f"  rc={r.returncode}  time={elapsed:.1f}s")

            # Copy log
            log_dst = os.path.join(RESULTS, f"synth_sub_{top}.log")
            if os.path.exists(tmp_log):
                shutil.copy2(tmp_log, log_dst)

            # Copy reports
            rpt_dir = os.path.join(tmp_proj, "reports")
            util_data = None
            timing_data = None
            if os.path.exists(rpt_dir):
                for rf in ["util.rpt", "timing.rpt", "hierarchy.rpt"]:
                    src = os.path.join(rpt_dir, rf)
                    if os.path.exists(src):
                        dst = os.path.join(RESULTS, f"synth_sub_{top}_{rf}")
                        shutil.copy2(src, dst)
                        if rf == "util.rpt":
                            util_data = parse_util(src)
                        elif rf == "timing.rpt":
                            timing_data = parse_timing(src)

            # Parse from log if reports missing
            if not util_data and os.path.exists(tmp_log):
                util_data = parse_util(tmp_log)

            status = "OK" if r.returncode == 0 else f"FAIL(rc={r.returncode})"
            entry = f"{top:20s}  {status:12s}  {elapsed:6.1f}s"
            if util_data:
                entry += f"  LUTs={util_data.get('LUTs','?'):>6s}  FFs={util_data.get('FFs','?'):>6s}  DSPs={util_data.get('DSPs','?'):>4s}"
            if timing_data:
                entry += f"  {timing_data[:60]}"
            print(f"  {entry}")
            summary.append(entry)

        except subprocess.TimeoutExpired:
            elapsed = time.time() - t0
            entry = f"{top:20s}  TIMEOUT(600s)  {elapsed:.1f}s"
            print(f"  {entry}")
            summary.append(entry)
        except Exception as e:
            entry = f"{top:20s}  ERROR: {e}"
            print(f"  {entry}")
            summary.append(entry)

    # Write summary
    summary_path = os.path.join(RESULTS, "synth_submodules_summary.txt")
    with io.open(summary_path, "w", encoding="utf-8") as fh:
        fh.write("Sub-module synthesis summary (Artix-7 XC7A100T-1CSG324)\n")
        fh.write("=" * 70 + "\n")
        fh.write(f"{'Module':20s} {'Status':12s} {'Time':>8s}  {'LUTs':>7s} {'FFs':>7s} {'DSPs':>5s}  Timing\n")
        fh.write("-" * 70 + "\n")
        for s in summary:
            fh.write(s + "\n")
    print(f"\nSummary written: {summary_path}")

if __name__ == "__main__":
    sys.exit(main())