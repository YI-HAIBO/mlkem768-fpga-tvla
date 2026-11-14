#!/usr/bin/env python3
"""
Task #85 final attempt: SAIF-annotated report_power for ipx_aoi_sec_board_top.

Flow:
  1. Reuse the iverilog VCD from the verified board POST self-test
     (regenerate if missing).
  2. Convert VCD -> hierarchical SAIF (scripts/vcd_to_saif.py v2).
  3. Vivado: synth_design ipx_aoi_sec_board_top (xc7a100tcsg324-1),
     write DCP,
     report_power  (baseline, vectorless -> Confidence Low),
     read_saif + report_power  (annotated -> Confidence Medium target).
  4. Diff key numbers, save both reports to results/.
"""
import os
import sys
import subprocess
import shutil
import time
import glob as globmod

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
RTL_CORE = os.path.join(ROOT, "rtl", "core")
BOARD_TOP = os.path.join(ROOT, "rtl", "ipx_aoi_sec_board_top.v")
SIM_DIR = os.path.join(ROOT, "sim")
RESULTS = os.path.join(ROOT, "results")

IV = r"C:\iverilog\bin\iverilog.exe"
VVP = r"C:\iverilog\bin\vvp.exe"
VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"

RTL_FILES = ["kyber_kem.v", "kyber_poly.v", "kyber_ntt.v",
             "kyber_sampler.v", "shake.v", "keccak_perm.v"]
TB_FILE = "tb_ipx_aoi_sec_board_top.v"
TOP = "ipx_aoi_sec_board_top"
PART = "xc7a100tcsg324-1"

WORK = f"c:/tmp/power_saif_{int(time.time())}"


def run_cmd(cmd, cwd=None, timeout=1500, env=None):
    print("  $ " + " ".join(str(c) for c in cmd), flush=True)
    t0 = time.time()
    p = subprocess.run(cmd, capture_output=True, timeout=timeout, cwd=cwd,
                       env=env)
    dt = time.time() - t0
    so = p.stdout.decode("utf-8", errors="replace")
    se = p.stderr.decode("utf-8", errors="replace")
    return p.returncode, so, se, dt


def ensure_vcd(workdir):
    """Regenerate the VCD if not present (iverilog POST self-test)."""
    vcd = os.path.join(workdir, "power.vcd")
    if os.path.exists(vcd) and os.path.getsize(vcd) > 1e6:
        print("  Reusing existing VCD (%.1f MB)" % (os.path.getsize(vcd)/1e6),
              flush=True)
        return vcd

    for f in RTL_FILES:
        shutil.copy2(os.path.join(RTL_CORE, f), os.path.join(workdir, f))
    shutil.copy2(BOARD_TOP, os.path.join(workdir, "ipx_aoi_sec_board_top.v"))
    tb_path = os.path.join(workdir, TB_FILE)
    shutil.copy2(os.path.join(SIM_DIR, TB_FILE), tb_path)

    with open(tb_path) as f:
        content = f.read()
    old = "    initial begin\n        clk      = 1'b0;"
    new = ("    initial begin\n"
           "        $dumpfile(\"power.vcd\");\n"
           "        $dumpvars(0, tb_ipx_aoi_sec_board_top);\n"
           "        clk      = 1'b0;")
    if old in content:
        content = content.replace(old, new, 1)
    else:
        import re
        pattern = r"(initial\s+begin\s*\n\s*clk\s*=\s*1'b0)"
        replacement = ("initial begin\n"
                       "        $dumpfile(\"power.vcd\");\n"
                       "        $dumpvars(0, tb_ipx_aoi_sec_board_top);\n"
                       "        clk      = 1'b0")
        content = re.sub(pattern, replacement, content, count=1)
    with open(tb_path, "w") as f:
        f.write(content)

    all_files = RTL_FILES + ["ipx_aoi_sec_board_top.v", TB_FILE]
    vvp_path = os.path.join(workdir, "tb_power.vvp")
    rc, so, se, dt = run_cmd(
        [IV, "-g2012", "-o", vvp_path] + [os.path.join(workdir, f)
                                          for f in all_files], timeout=300)
    if rc != 0:
        raise RuntimeError("iverilog compile failed: %s" % se)
    rc, so, se, dt = run_cmd([VVP, "tb_power.vvp"], cwd=workdir, timeout=1500)
    for line in so.split("\n"):
        if any(k in line for k in ["BOARD_POST", "PASS", "FAIL"]):
            print("  " + line.strip(), flush=True)
    if not os.path.exists(vcd):
        raise RuntimeError("VCD not generated")
    print("  VCD: %.1f MB" % (os.path.getsize(vcd) / 1e6), flush=True)
    return vcd


POWER_TCL_TMPL = r"""catch {set_param synth.enableParallelHelperSpawn none}
catch {set_param synth.elaboration.useElabCache false}
set WORK "%s"
puts "=== SAIF power flow: %s ==="
create_project -force board_pwr $WORK/proj -part %s
foreach f [glob -nocomplain $WORK/core/*.v] { add_files $f }
add_files $WORK/%s.v
synth_design -top %s -part %s -directive default
create_clock -period 10.000 -name sys_clk [get_ports clk]
write_checkpoint -force $WORK/board_synth.dcp
"""

POWER_TCL_MAIN = r"""
proc mk_report_power {WORK} {
  # baseline: vectorless (default toggle rate) -> Confidence Low
  report_power -file $WORK/power_baseline.rpt -details all
  # SAIF-annotated
  set rc [catch {read_saif -no_strip $WORK/power_activity.saif} err]
  if {$rc != 0} {
    puts "READ_SAIF_ERR: $err"
    set rc2 [catch {read_saif $WORK/power_activity.saif} err2]
    puts "READ_SAIF_RETRY_RC: $rc2 $err2"
  }
  report_power -file $WORK/power_saif.rpt -details all
  puts "=== power flow done ==="
}
"""


def main():
    print("=" * 78, flush=True)
    print("SAIF-annotated report_power (board_top)", flush=True)
    print("=" * 78, flush=True)

    os.makedirs(WORK, exist_ok=True)

    # -------------------------------------------------- VCD
    print("\n--- Step 1: VCD ---", flush=True)
    # reuse the previously generated VCD if still on disk
    old_dirs = sorted(globmod.glob("c:/tmp/power_vcd_*"))
    reused = False
    if old_dirs:
        cand = os.path.join(old_dirs[-1], "power.vcd")
        if os.path.exists(cand) and os.path.getsize(cand) > 1e6:
            shutil.copy2(cand, os.path.join(WORK, "power.vcd"))
            print("  Reused VCD from %s" % old_dirs[-1], flush=True)
            reused = True
    vcd = ensure_vcd(WORK)

    # -------------------------------------------------- SAIF
    print("\n--- Step 2: VCD->SAIF (hierarchy-aware) ---", flush=True)
    sys.path.insert(0, HERE)
    from vcd_to_saif import convert_vcd_to_saif
    saif_path = os.path.join(WORK, "power_activity.saif")
    n_nets, total_ns = convert_vcd_to_saif(vcd, saif_path, TOP, "dut")
    print("  SAIF: %d nets, %d ns window (%.1f KB)"
          % (n_nets, total_ns, os.path.getsize(saif_path) / 1024), flush=True)

    # -------------------------------------------------- Vivado
    print("\n--- Step 3: Vivado synth + report_power ---", flush=True)
    core_dst = os.path.join(WORK, "core")
    os.makedirs(core_dst, exist_ok=True)
    for f in globmod.glob(os.path.join(RTL_CORE, "*.v")):
        shutil.copy2(f, os.path.join(core_dst, os.path.basename(f)))
    shutil.copy2(BOARD_TOP, os.path.join(WORK, TOP + ".v"))

    tcl_body = POWER_TCL_TMPL % (WORK, TOP, PART, TOP, TOP, PART) \
        + POWER_TCL_MAIN + "\nset rc [catch {mk_report_power $WORK} err]\n" \
        "puts \"POWER_PROC_RC: $rc $err\"\nexit\n"
    tcl_path = os.path.join(WORK, "power_flow.tcl")
    with open(tcl_path, "w") as f:
        f.write(tcl_body)

    env = os.environ.copy()
    parts = env.get("PATH", "").split(os.pathsep)
    env["PATH"] = os.pathsep.join(
        p for p in parts if p.strip() and not os.path.isfile(p))
    env["XILINX_VIVADO"] = "D:/FPGA/2026.1/Vivado"

    rc, so, se, dt = run_cmd(
        [VIVADO, "-mode", "batch", "-source", tcl_path, "-nojournal"],
        cwd=WORK, timeout=3000, env=env)
    print("  vivado rc=%s (%.0f s)" % (rc, dt), flush=True)

    # save the full log
    with open(os.path.join(WORK, "vivado_console.log"), "w") as f:
        f.write(so + "\n--- STDERR ---\n" + se)

    for line in so.splitlines():
        low = line.lower()
        if ("saif" in low or "warning" in low and "annotat" in low
                or "power flow" in low or "read_saif" in low):
            print("  | " + line.strip(), flush=True)

    # -------------------------------------------------- reports
    print("\n--- Step 4: reports ---", flush=True)
    summary = {}
    for tag in ("baseline", "saif"):
        rpt = os.path.join(WORK, "power_%s.rpt" % tag)
        if not os.path.exists(rpt):
            print("  MISSING %s" % rpt, flush=True)
            continue
        dst = os.path.join(RESULTS, "power_board_%s.rpt" % tag)
        shutil.copy2(rpt, dst)
        print("  saved %s" % dst, flush=True)
        keys = {}
        with open(rpt, errors="replace") as f:
            for line in f:
                ls = line.strip()
                for needle in ("Total On-Chip Power", "Dynamic (",
                               "Device Static", "Confidence",
                               "Junction Temperature", "Clocks",
                               "Signals", "Logic"):
                    if ls.startswith(needle) or needle in ls:
                        if needle not in keys:
                            keys[needle] = ls
        summary[tag] = keys

    print("\n--- Comparison ---", flush=True)
    for k in ("Confidence", "Total On-Chip Power", "Dynamic (",
              "Device Static", "Junction Temperature"):
        b = summary.get("baseline", {}).get(k, "n/a")
        s = summary.get("saif", {}).get(k, "n/a")
        print("  %-25s | baseline: %-45s | saif: %s" % (k, b, s), flush=True)

    dcp = os.path.join(WORK, "board_synth.dcp")
    if os.path.exists(dcp):
        shutil.copy2(dcp, os.path.join(RESULTS, "board_synth_saif.dcp"))
        print("  DCP saved: results/board_synth_saif.dcp", flush=True)

    print("\nWORK dir: %s" % WORK, flush=True)
    print("=" * 78, flush=True)
    print("DONE rc=%s" % rc, flush=True)
    print("=" * 78, flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
