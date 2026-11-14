#!/usr/bin/env python3
"""Part 2 runner: open board_synth DCP, report_power baseline vs SAIF."""
import os
import sys
import subprocess
import shutil
import glob as globmod

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
RESULTS = os.path.join(ROOT, "results")
VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
SAIF_TCL = os.path.join(HERE, "power_saif_part2.tcl")


def find_work():
    dirs = sorted(globmod.glob("c:/tmp/power_saif_*"))
    for d in reversed(dirs):
        dcp = os.path.join(d, "board_synth.dcp")
        saif = os.path.join(d, "power_activity.saif")
        if os.path.exists(dcp) and os.path.exists(saif):
            return d
    raise RuntimeError("no prepared work dir found")


def main():
    work = find_work()
    print("WORK: %s" % work, flush=True)
    tcl_path = os.path.join(work, "part2.tcl")
    with open(SAIF_TCL) as f:
        body = f.read()
    with open(tcl_path, "w") as f:
        f.write(body % work.replace("\\", "/"))

    env = os.environ.copy()
    parts = env.get("PATH", "").split(os.pathsep)
    env["PATH"] = os.pathsep.join(
        p for p in parts if p.strip() and not os.path.isfile(p))
    env["XILINX_VIVADO"] = "D:/FPGA/2026.1/Vivado"

    p = subprocess.run(
        [VIVADO, "-mode", "batch", "-source", tcl_path, "-nojournal"],
        cwd=work, env=env, capture_output=True, timeout=1200)
    so = p.stdout.decode("utf-8", errors="replace")
    print("rc=%s" % p.returncode, flush=True)
    for line in so.splitlines():
        if any(k in line for k in ("READ_SAIF", "power part2", "ERROR",
                                    "WARNING" if "annotat" in line else "ZZZ")):
            print("  | " + line.strip(), flush=True)
    with open(os.path.join(work, "part2_console.log"), "w") as f:
        f.write(so)

    summary = {}
    for tag in ("baseline", "saif"):
        rpt = os.path.join(work, "power_%s.rpt" % tag)
        if not os.path.exists(rpt):
            print("MISSING %s" % rpt, flush=True)
            continue
        dst = os.path.join(RESULTS, "power_board_%s.rpt" % tag)
        shutil.copy2(rpt, dst)
        keys = {}
        with open(rpt, errors="replace") as f:
            for line in f:
                ls = line.strip()
                for needle in ("Total On-Chip Power", "Dynamic",
                               "Device Static", "Confidence",
                               "Junction Temperature", "Clocks",
                               "Signals", "Logic", "Set/Reset"):
                    if needle in ls and needle not in keys:
                        keys[needle] = ls
        summary[tag] = keys

    print("\n=== Comparison (vectorless vs SAIF-annotated) ===", flush=True)
    for k in ("Confidence", "Total On-Chip Power", "Dynamic",
              "Device Static", "Junction Temperature"):
        b = summary.get("baseline", {}).get(k, "n/a")
        s = summary.get("saif", {}).get(k, "n/a")
        print("  %-25s | baseline: %-40s | saif: %s" % (k, b, s), flush=True)


if __name__ == "__main__":
    sys.exit(main())
