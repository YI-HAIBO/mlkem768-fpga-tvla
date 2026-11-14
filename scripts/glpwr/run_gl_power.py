#!/usr/bin/env python3
"""Drive gl_power_report.tcl: open gl_synth.dcp, annotate SAIF, report power.

Usage:
    python scripts/glpwr/run_gl_power.py --work C:/tmp/glpwr_<ts> \
        [--saif C:/tmp/glpwr_<ts>/power_activity.saif]

Reads the annotated power report (${rpt}.rpt) and prints the key metrics:
  - Design Nets Matched % (read_saif annotation confidence)
  - Total On-Chip Power (Dynamic + Static)
"""
import os, re, sys, time, subprocess, argparse

VIVADO = r"D:/FPGA/2026.1/Vivado/bin/vivado.bat"
HERE = os.path.dirname(os.path.abspath(__file__))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--work", required=True)
    ap.add_argument("--saif", default=None)
    a = ap.parse_args()

    dcp = os.path.join(a.work, "gl_synth.dcp")
    saif = a.saif or os.path.join(a.work, "power_activity.saif")
    rpt = os.path.join(a.work, "gl_power")
    for f in (dcp, saif):
        if not os.path.exists(f):
            sys.exit("missing: " + f)

    tcl = os.path.join(HERE, "gl_power_report.tcl")
    out_log = os.path.join(a.work, "gl_power.log")
    cmd = [VIVADO, "-mode", "batch", "-nojournal",
           "-log", os.path.join(a.work, "gl_power_run.log"),
           "-source", tcl, "-tclargs", dcp, saif, rpt]
    print("CMD:", " ".join(cmd), flush=True)
    t0 = time.time()
    with open(out_log, "w") as lf:
        r = subprocess.run(cmd, stdout=lf, stderr=subprocess.STDOUT,
                           timeout=1800, cwd=a.work)
    print("vivado rc=%d  %.0fs" % (r.returncode, time.time() - t0), flush=True)

    # parse annotation + power from the annotated report
    # Vivado writes `-file <rpt>` verbatim; try both with and without .rpt
    for cand in (rpt + ".rpt", rpt, rpt + "_hier3.rpt"):
        parsed = parse_power(cand)
        if "ERROR" not in parsed or os.path.exists(cand):
            if os.path.exists(cand):
                parsed["REPORT_FILE"] = cand
                break
    for k, v in parsed.items():
        print("  %-32s %s" % (k, v), flush=True)
    print("GL_POWER_DONE" if r.returncode == 0 else "GL_POWER_RC=" + str(r.returncode),
          flush=True)
    return 0


def parse_power(rpt_path):
    """Extract Design Nets Matched % and power numbers from a report_power rpt."""
    out = {}
    if not os.path.exists(rpt_path):
        out["ERROR"] = "no report: " + rpt_path
        return out
    txt = open(rpt_path, encoding="utf-8", errors="replace").read()
    # Design Nets Matched (read_saif summary line in the console, not always in
    # the rpt) — look for the annotation header inside the rpt too.
    for pat, label in [
        (r"Design Nets Matched\s*:\s*([\d.]+)%", "Design Nets Matched %"),
        (r"Design Nets Matched\s*=\s*([\d.]+)%", "Design Nets Matched %"),
        (r"Total On-Chip Power\s*:\s*([\d.]+)\s*W", "Total On-Chip Power W"),
        (r"Dynamic\s*:\s*([\d.]+)\s*W\s*\([\d.]+%\)", "Dynamic W"),
        (r"Static\s*:\s*([\d.]+)\s*W\s*\([\d.]+%\)", "Static W"),
        (r"Design Static Power\s*:\s*([\d.]+)\s*W", "Design Static W"),
    ]:
        m = re.search(pat, txt)
        if m:
            out[label] = m.group(1)
    if not out:
        out["NOTE"] = "power rpt parsed but no key metrics found"
    return out


if __name__ == "__main__":
    sys.exit(main())
