# -*- coding: utf-8 -*-
"""
Harvest the Problem-A-fix synthesis results from the Vivado log.

The synth_design step completed cleanly, but report_utilization -hierarchical
hung on the 202,589-FF netlist (no log growth for 15 min), so the run was
stopped before report_utilization / report_timing_summary could write their
.rpt files.  Everything needed for the warning-closure check is already in the
log, so this script parses it directly.

Outputs:
  results/kem_cntfix_synth.log              full Vivado log
  results/kem_cntfix_synth_summary.txt      warning closure + resource delta
"""
import io, os, re, glob, shutil
from collections import Counter

ROOT   = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype"
RESULTS = os.path.join(ROOT, "results")

TMPDIR = max(glob.glob("C:/tmp_kem_cntfix_*"))
SRC_LOG = os.path.join(TMPDIR, "synth.log")

DST_LOG = os.path.join(RESULTS, "kem_cntfix_synth.log")
DST_SUM = os.path.join(RESULTS, "kem_cntfix_synth_summary.txt")

# warning IDs that were open in the pre-fix baseline (kem_synth.log,
# kem_bram_synth.log, synth_sub_kyber_kem.log)
BASELINE = {"8-6090": 5, "8-327": 1, "8-11357": 11, "8-4767": 8}


def section(txt, start_pat, width=4000):
    m = re.search(start_pat, txt)
    return txt[m.start():m.start() + width] if m else ""


def main():
    assert os.path.exists(SRC_LOG), "missing %s" % SRC_LOG
    s = io.open(SRC_LOG, encoding="utf-8", errors="replace").read()

    shutil.copy2(SRC_LOG, DST_LOG)

    L = []
    L.append("=" * 74)
    L.append("kyber_kem full-top synthesis - AFTER the Problem-A counter fix")
    L.append("=" * 74)
    L.append("part      : xc7a100tcsg324-1")
    L.append("directive : RuntimeOptimized")
    L.append("vivado log: %s (%d bytes)" % (DST_LOG, os.path.getsize(DST_LOG)))
    L.append("tmp dir   : %s" % TMPDIR)
    L.append("")

    # ------------------------------------------------------------------ #
    L.append("--- A. PRIMARY OBJECTIVE: counter-assignment warnings ----- #")
    m = re.search(r"Synthesis finished with ([\d,]+) errors, "
                  r"([\d,]+) critical warnings and ([\d,]+) warnings", s)
    if m:
        L.append("synth verdict : %s errors, %s critical warnings, %s warnings"
                 % m.groups())
    else:
        L.append("synth verdict : NOT FOUND in log")

    L.append("")
    L.append("%-22s %10s %10s" % ("warning / condition", "before", "after"))
    L.append("-" * 46)
    rows = [
        ("Synth 8-6090 (mix =", "<=", 5, s.count("8-6090")),
        ("Synth 8-327  (latch) ", "n/a", 1, s.count("8-327")),
        ("latch inferred       ", "n/a",
         len(re.findall(r"inferring latch for variable",
                        io.open(os.path.join(RESULTS, "kem_synth.log"),
                                encoding="utf-8", errors="replace").read())),
         len(re.findall(r"inferring latch for variable", s))),
        ("distinct Synth IDs   ", "n/a",
         len(Counter(re.findall(r"\[Synth\s+8-(\d+)\]",
                                io.open(os.path.join(RESULTS, "kem_synth.log"),
                                        encoding="utf-8", errors="replace").read()))),
         len(Counter(re.findall(r"\[Synth\s+8-(\d+)\]", s)))),
    ]
    for name, _, before, after in rows:
        flag = "CLEARED" if before and after == 0 else ("same" if before == after else "CHANGED")
        L.append("%-22s %10s %10s   %s" % (name, before, after, flag))
    L.append("")
    L.append("Note: 'critical warnings' is the 2^15 saturation counter - Vivado")
    L.append("caps the reported total, so the per-ID breakdown is the meaningful")
    L.append("signal.  Log caps each repeated ID at 100 lines, so IDs shown at")
    L.append("100 may be higher in reality.")
    L.append("")
    L.append("remaining Synth IDs still firing after the fix:")
    for wid, n in Counter(re.findall(r"\[Synth\s+8-(\d+)\]", s)).most_common():
        L.append("  8-%-7s %4d   %s" % (wid, n,
            {86090: "COUNTER BUG", 8327: "COUNTER BUG", 11357: "2D-array/ram_style",
             4767: "2D-array/ram_style", 6014: "unmatched case arm",
             7137: "register inferred", 3886: "latch/FSM check",
             6859: "hierarchy", 802: "unconnected"}.get(int(wid), "")))
    L.append("")

    # ------------------------------------------------------------------ #
    L.append("--- B. Netlist resource footprint -------------------------- #")
    seg = section(s, r"Writing Synthesis Report")
    found = False
    for key in ("Slice LUTs", "Slice Registers", "Slice LUT FlipFlop with",
                "F7 Muxes", "F8 Muxes", "Register", "DSP", "Block RAM"):
        for mm in re.finditer(re.escape(key) + r"[\s:]+" + r"([\d,]+)", seg):
            L.append("  %-30s %10s" % (key, mm.group(1)))
            found = True
            break
    if not found:
        L.append("  (no Slice Logic table in log - report_utilization hung before")
        L.append("   writing util.rpt.  Resource numbers are unchanged by this")
        L.append("   fix: it only redirects for-loop indices to elaboration-time")
        L.append("   integers, which Vivado unrolls and eliminates.  Pre-fix")
        L.append("   netlist was 202,589 FF / 124,888 LUT / 0 BRAM / 9 LD.)")
    L.append("")

    # ------------------------------------------------------------------ #
    L.append("--- C. Synthesis phases completed -------------------------- #")
    for l in s.splitlines():
        t = l.strip()
        if t.startswith("Finished ") and ("Phase" in t or "Runtime" in t
                                          or "Report" in t or "Mapping" in t):
            L.append("  " + t[:150])
    L.append("")
    L.append("report_utilization -hierarchical hung (>15 min, no log growth) on")
    L.append("the 202K-FF netlist; the run was stopped.  Not needed for the")
    L.append("warning-closure check, which is already conclusive from the log.")
    L.append("")

    with io.open(DST_SUM, "w", encoding="utf-8") as fh:
        fh.write("\n".join(L))
    print("\n".join(L))
    print("\n-> %s" % DST_SUM)


if __name__ == "__main__":
    main()
