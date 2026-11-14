#!/usr/bin/env python3
"""
Probe the best read_saif naming convention for our hand-built SAIF.

The first attempt (net names relative to design root + read_saif -no_strip)
matched only 3/117836 nets. This script tries three naming/flag variants on
the already-synthesized board_top DCP and reports 'Design Nets Matched' for
each:

  A  names relative to design root          read_saif -no_strip
  B  names with tb/dut prefix               read_saif (default 2-level strip)
  C  names with tb/dut prefix               read_saif -strip_path <tb/dut>
  D  names with tb/dut prefix               read_saif -no_strip (control)
"""
import os
import re
import sys
import subprocess
import glob as globmod

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
sys.path.insert(0, HERE)
from vcd_to_saif import parse_vcd, compute_saif_stats  # noqa: E402

VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
TB_NAME = "tb_ipx_aoi_sec_board_top"


def find_work():
    for d in reversed(sorted(globmod.glob("c:/tmp/power_saif_*"))):
        if os.path.exists(os.path.join(d, "board_synth.dcp")) \
                and os.path.exists(os.path.join(d, "power.vcd")):
            return d
    raise RuntimeError("no work dir")


def build_stats(vcd):
    id_to_name, transitions = parse_vcd(vcd, dut_scope="dut")
    max_t = 0
    for tr in transitions.values():
        if tr and tr[-1][0] > max_t:
            max_t = tr[-1][0]
    total = max_t // 1000  # ps -> ns
    stats = compute_saif_stats(id_to_name, transitions, total)
    return stats, total


def write_saif(stats, total, top, prefix, path):
    with open(path, "w") as f:
        f.write("(SAIFFILE)\n")
        f.write('(DESIGN "%s")\n' % top)
        f.write("(DIVIDER / )\n")
        f.write("(TIMESCALE 1 ns)\n")
        f.write("(DURATION %d)\n" % total)
        f.write('(INSTANCE %s\n' % top)
        for name, (t0, t1, tx, tc) in sorted(stats.items()):
            full = prefix + name if prefix else name
            f.write('  (NET %s\n' % full.replace('.', '/'))
            f.write('    (T0 %d) (T1 %d) (TX %d) (TC %d)\n'
                    % (int(t0), int(t1), int(tx), tc))
            f.write('  )\n')
        f.write(")\n")


def vivado_flow(work, tcl_lines):
    tcl_path = os.path.join(work, "probe.tcl")
    with open(tcl_path, "w") as f:
        f.write("\n".join(tcl_lines) + "\nexit\n")
    env = os.environ.copy()
    parts = env.get("PATH", "").split(os.pathsep)
    env["PATH"] = os.pathsep.join(
        p for p in parts if p.strip() and not os.path.isfile(p))
    env["XILINX_VIVADO"] = "D:/FPGA/2026.1/Vivado"
    p = subprocess.run(
        [VIVADO, "-mode", "batch", "-source", tcl_path, "-nojournal"],
        cwd=work, env=env, capture_output=True, timeout=1200)
    return p.stdout.decode("utf-8", errors="replace")


def extract_match(rpt_path):
    if not os.path.exists(rpt_path):
        return "MISSING REPORT"
    with open(rpt_path, errors="replace") as f:
        for line in f:
            if "Design Nets Matched" in line:
                return line.strip()
    return "no match line"


def main():
    work = find_work()
    print("WORK: %s" % work, flush=True)
    print("building stats from VCD...", flush=True)
    stats, total = build_stats(os.path.join(work, "power.vcd"))
    print("nets: %d, window %d ns" % (len(stats), total), flush=True)

    variants = [
        ("A_rel_no_strip", "", "read_saif -no_strip $W/vA.saif"),
        ("B_tb_default", TB_NAME + ".dut.", "read_saif $W/vB.saif"),
        ("C_tb_strip_path", TB_NAME + ".dut.",
         "read_saif -strip_path %s/dut $W/vC.saif" % TB_NAME),
        ("D_tb_no_strip", TB_NAME + ".dut.", "read_saif -no_strip $W/vD.saif"),
    ]
    results = []
    for tag, prefix, read_cmd in variants:
        saif = os.path.join(work, "v%s.saif" % tag.split("_")[0])
        write_saif(stats, total, "ipx_aoi_sec_board_top", prefix, saif)
        print("\n--- variant %s ---" % tag, flush=True)
        tcl = [
            'set W "%s"' % work.replace("\\", "/"),
            "open_checkpoint $W/board_synth.dcp",
            "catch { %s } rc" % read_cmd,
            'puts "READ_RC: $rc"',
            "report_power -file $W/rpt_%s.rpt" % tag,
        ]
        so = vivado_flow(work, tcl)
        for line in so.splitlines():
            if "READ_RC" in line or "ERROR" in line:
                print("  | " + line.strip(), flush=True)
        m = extract_match(os.path.join(work, "rpt_%s.rpt" % tag))
        print("  MATCH: %s" % m, flush=True)
        results.append((tag, m))

    print("\n=== SUMMARY ===", flush=True)
    for tag, m in results:
        print("  %-20s %s" % (tag, m), flush=True)


if __name__ == "__main__":
    sys.exit(main())
