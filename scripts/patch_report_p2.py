#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Correct kem_synth_final_report.md after the 2026-10-14/15 findings.

Two independent corrections:

(1) DEVICE BUDGET. Section 1 documented xc7a50t's budget (32,600 LUT /
    65,200 FF / 120 DSP / 270 BRAM) for a design targeting xc7a100t,
    whose real budget is 63,400 LUT / 126,800 FF / 240 DSP / 135 BRAM.
    Every "x times over budget" verdict in the report is therefore wrong.
    Corrected figures were read from the same Vivado 2026.1 install via
    both get_property and the report_utilization 'Available' column,
    which agree exactly (results/device_budget_probe.log).

(2) P2 RETARGET. xc7a325t and xc7a680t do not exist (get_parts, 0
    matches); the Artix-7 family stops at xc7a200t. The xc7a200t run
    completes synthesis cleanly but Vivado 2026.1 then hangs at
    'Synthesis Optimization Runtime', reproduced 3/3 times at the same
    line and the same elapsed time, project-mode and project-less, with
    46 GB of free virtual memory. New section 3.3 documents this.

Every replacement asserts its expected occurrence count, then the file
is re-read and re-scanned to confirm nothing regressed.
"""
import io, os, sys

P = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype\results\kem_synth_final_report.md"

# (expected_count, old, new, label)
EDITS = [
    # --- header ---
    (1,
     "**Date:** 2026-10-12 (updated with P1-c full-top re-synthesis results)  ",
     "**Date:** 2026-10-15 (updated: device-budget correction, xc7a200t P2 attempt)  ",
     "header date"),
    (1, "深圳技术大学", "深圳职业技术大学", "affiliation"),

    # --- section 1 ---
    (1,
     "| Resource   | Available |\n"
     "|------------|-----------|\n"
     "| Slice LUTs | 32,600    |\n"
     "| Slice FFs  | 65,200    |\n"
     "| DSP48E1    | 120       |\n"
     "| Block RAM  | 270 tiles (RAMB36 = 40 columns, RAMB18 = 80 columns) |\n",
     "**CORRECTED 2026-10-15.** This table was originally filled in with\n"
     "**xc7a50t** figures (32,600 LUT / 65,200 FF / 120 DSP / 270 BRAM) while\n"
     "the design targets **xc7a100t**.  Every \"x times over budget\" verdict in\n"
     "this report that was derived from it is wrong and has been corrected\n"
     "throughout.  The figures below were read from the same Vivado 2026.1\n"
     "installation — `get_property` and the `report_utilization` *Available*\n"
     "column agree exactly (`results/device_budget_probe.log`).\n\n"
     "| Resource        | xc7a50t | **xc7a100t (target)** | xc7a200t |\n"
     "|-----------------|---------|------------------------|----------|\n"
     "| Slice LUTs      | 32,600  | **63,400**             | 134,600  |\n"
     "| Slice FFs       | 65,200  | **126,800**            | 269,200  |\n"
     "| DSP48E1         | 120     | **240**                | 740      |\n"
     "| Block RAM tile  | 75      | **135**                | 365      |\n"
     "| Slices          | 8,150   | **15,850**             | 33,650   |\n\n"
     "`xc7a325t` and `xc7a680t` **do not exist** in Vivado 2026.1 — the\n"
     "Artix-7 family stops at `xc7a200t` (`get_parts -regexp {^xc7a.*}`, 32\n"
     "packages, `results/p2_part_probe.log`).  `xc7a200t` is the largest\n"
     "Artix-7 and is the only candidate for P2.\n",
     "section 1 table"),

    # --- section 2 ---
    (1, "**Synthesizes, but netlist is ~3.1× over device**",
        "**Synthesizes; pre-P1 netlist is 1.97× the LUT budget**",
        "s2 kyber_kem note"),

    # --- section 3.1 pre-P1 bullets ---
    (1, "- **FF total = 202,589 = 3.11× the 65,200 FF limit.**",
        "- **FF total = 202,589 = 1.60× the 126,800 FF limit.**", "pre-P1 FF ratio"),
    (1, "- **LUT6 + MUXF7 + MUXF8 = 124,888 ≈ 3.83× the 32,600 LUT limit.**",
        "- **LUT6 + MUXF7 + MUXF8 = 124,888 = 1.97× the 63,400 LUT limit.**",
        "pre-P1 LUT ratio"),

    # --- section 3.1 post-P1 table ---
    (1, "| Slice FFs     | 39,738  | 65,200  | 61%         | **FITS** ✅ |",
        "| Slice FFs     | 39,738  | 126,800 | 31.4%       | **FITS** ✅ |",
        "post-P1 FF row"),
    (1, "| Total LUTs    | 58,852  | 32,600  | 181%        | 1.81× over ❌ |",
        "| Total LUTs    | 58,852  | 63,400  | 92.8%       | **FITS**, but above the ~80% routing-closure comfort ceiling ⚠️ |",
        "post-P1 LUT row"),
    (1,
     "| RAMB36        | 0       | 40 cols | 0%          | unused |\n"
     "| RAMB18        | 0       | 80 cols | 0%          | unused |\n"
     "| DSP48E1       | 61      | 120     | 51%         | fits ✅ |\n",
     "| Block RAM tile| 0       | 135     | 0%          | unused — arrays infer as LUTRAM |\n"
     "| DSP48E1       | 61      | 240     | 25.4%       | fits ✅ |\n",
     "post-P1 BRAM/DSP rows"),

    # --- section 3.2 ---
    (1, "0 errors, FF 39,738 (fits 65,200), LUT 58,852 (1.81× over 32,600),",
        "0 errors, FF 39,738 (31.4% of 126,800), LUT 58,852 (92.8% of 63,400),",
        "s3.2 result line"),

    # --- new section 3.3 ---
    (1,
     "## 4. Root Causes (three distinct problems)\n",
     "### 3.3 P2 retarget attempt — xc7a200t (2026-10-14 / 2026-10-15)\n\n"
     "Retargeting the identical post-P1 netlist to the largest Artix-7\n"
     "(`xc7a200tfbg484-1`, -1 grade, same timing grade as the 100T part)\n"
     "was attempted twice — project mode (`scripts/run_kem_synth_p2.py`)\n"
     "and project-less (`scripts/run_kem_synth_p2b.py`) — and both gave the\n"
     "same result:\n\n"
     "- Synthesis itself is clean: `Synthesis finished with 0 errors, 0\n"
     "  critical warnings and 47 warnings`; regression guards all quiet\n"
     "  (8-7186 / 8-2914 / 8-6090 / 8-327 = 0, and the single 8-4767 is the\n"
     "  known benign `keccak_perm` `round.B_reg` read-address-stuck case).\n"
     "- Vivado 2026.1 then **hangs** at `Synthesis Optimization Runtime`,\n"
     "  immediately before `Synthesis Optimization Complete` and `Translating\n"
     "  synthesized netlist`, so `report_utilization` and `report_timing_summary`\n"
     "  are never reached and no reports are written.  Reproduced 3 of 3 times,\n"
     "  every time with the log stopping at the same line and almost the same\n"
     "  elapsed time (00:05:28, 00:05:28, 00:05:30).  The host is an i5-14600KF\n"
     "  with 68 GB RAM and 46 GB of free virtual address space, so this is not\n"
     "  memory pressure, and it is not a project-mode artifact — the identical\n"
     "  flow on `xc7a100tcsg324-1` completes in 5.5 min.  Treat it as a Vivado\n"
     "  2026.1 bug on this netlist/part combination, not a design problem.\n\n"
     "Useful data harvested from the logs before the hang (pre-optimization,\n"
     "so an upper bound on the mapped figures):\n\n"
     "| Primitive class              | Count | xc7a200t budget | Share |\n"
     "|------------------------------|-------|-----------------|-------|\n"
     "| FDCE + FDRE + FDPE (FF)      | 39,748 | 269,200         | 14.8% |\n"
     "| LUT1–LUT6 + MUXF7 + MUXF8    | 76,045 | 134,600         | 56.5% |\n"
     "| DSP48E1                      | 61    | 740             | 8.2%  |\n"
     "| CARRY4                       | 988   | —               | —     |\n\n"
     "Both xc7a200t runs produced byte-identical primitive counts, which is the\n"
     "expected result: the 100T and 200T share the same Artix-7 fabric logic.\n"
     "**P2 is unnecessary on resource grounds** (§1) and is not currently\n"
     "achievable with this tool release (§3.3).\n\n"
     "---\n\n"
     "## 4. Root Causes (three distinct problems)\n",
     "insert section 3.3"),

    # --- section 6 ---
    (1,
     "The device has 270 BRAM tiles = 270 × 18 Kb = **4,860 Kb ≈ 607 KB\n"
     "of block-RAM capacity in total** (bit→byte divide by 8). Even the\n"
     "conservative RAMB36 view gives 270 × 36 Kb = 9.72 Mbit ≈ 1.2 MB.\n"
     "Either way, 24 KB of storage is **less than 5% of available BRAM**:\n"
     "`⌈24 KB / 4.5 KB per RAMB36⌉ = 6 RAMB36 = 2.2% of 270 tiles`.\n",
     "The device has 135 BRAM tiles = 135 × 36 Kb = **4,860 Kb ≈ 607 KB\n"
     "of block-RAM capacity in total** (bit→byte divide by 8).\n"
     "24 KB of storage is **less than 5% of available BRAM**:\n"
     "`⌈24 KB / 4.5 KB per RAMB36⌉ = 6 BRAM = 4.4% of 135 tiles`.\n",
     "s6 BRAM capacity"),
    (1, "resolved**: 202,589 → 39,738 FF, within the 65,200 budget.",
        "resolved**: 202,589 → 39,738 FF, 31.4% of the 126,800 budget.",
        "s6 FF budget"),
    (1,
     "The remaining gap is **LUT 1.81× over budget**, and it is dominated by\n"
     "combinational logic, not memory:\n",
     "The remaining issue is **LUT utilisation at 92.8% of the 63,400 budget**\n"
     "— legal, but well above the ~80% mark where routing usually still closes.\n"
     "That pressure is dominated by combinational logic, not memory:\n",
     "s6 LUT gap"),
    (1,
     "Even if all LUTRAMs moved to BRAM (freeing 4,448 LUTs), the design\n"
     "would still be 54,404 LUTs = 1.67× over.  **The LUT gap is an NTT /\n"
     "SHAKE architecture problem, not a memory-mapping problem.**\n",
     "Even if all LUTRAMs moved to BRAM (freeing 4,448 LUTs), the design\n"
     "would still be 54,404 LUTs = 85.8% of budget.  **The LUT pressure is an\n"
     "NTT / SHAKE architecture question, not a memory-mapping problem.**\n",
     "s6 LUTRAM scenario"),
    (1, "is the constraint. **On XC7A100T, 270 BRAM tiles is more than enough",
        "is the constraint. **On XC7A100T, 135 BRAM tiles is more than enough",
        "s6 BRAM tiles note"),

    # --- section 6 conclusion + path table ---
    (1, "**Conclusion: after P1, FF fits (61%) but LUT is still 1.81× over.**",
        "**Conclusion: after P1 the design fits xc7a100t — FF 31.4%, LUT 92.8%,\n"
        "DSP 25.4%, BRAM 0%.**  LUT is inside budget but above the comfort zone.",
        "s6 conclusion"),
    (1,
     "| **P1. Flatten + async-reset + write-port merge** | **DONE 2026-10-12.** 3 stages, 0 synthesis errors, bit-exact at every step | **FF yes (39,738 / 65,200 = 61%); LUT no (58,852 / 32,600 = 181%).** Arrays are LUTRAM, not BRAM — the FF explosion is gone but the LUT gap is architectural (NTT 48%, SHAKE 25%) |",
     "| **P1. Flatten + async-reset + write-port merge** | **DONE 2026-10-12.** 3 stages, 0 synthesis errors, bit-exact at every step | **FF 31.4% (39,738 / 126,800); LUT 92.8% (58,852 / 63,400); DSP 25.4%.** Arrays are LUTRAM, not BRAM — the FF explosion is gone; the LUT pressure is architectural (NTT 48%, SHAKE 25%) |",
     "s6 P1 row"),
    (1,
     "| **P2. Bigger device** (xc7a325t: 576 RAMB36, 142K FF, 80K LUT, 280 DSP; or xc7a680t) | Board change | **Yes, with P1 applied.** Post-P1 netlist (39,738 FF / 58,852 LUT) fits xc7a325t comfortably (28% FF / 74% LUT). This is now the fastest route to a working prototype |",
     "| **P2. Bigger device** (xc7a200t: 134,600 LUT / 269,200 FF / 740 DSP / 365 BRAM — xc7a325t and xc7a680t do not exist) | Board change | **Resources are trivial** (pre-opt FF 14.8%, LUT+MUXF 56.5%, §3.3) — **but not needed**, and currently **blocked**: Vivado 2026.1 hangs deterministically on this netlist/part (§3.3) |",
     "s6 P2 row"),
    (1,
     "| **P4 (new). NTT/SHAKE LUT reduction** — pipeline the NTT butterfly, share zeta ROM, or retime | Large RTL rewrite | Potentially: freeing ~26K LUTs would bring the total to ~33K ≈ fits 100T. Highest risk, highest reward |",
     "| **P4. NTT/SHAKE LUT reduction** — pipeline the NTT butterfly, share the zeta ROM, or retime | Large RTL rewrite | **Preferred route.** Freeing ~8K LUTs takes 58,852 → ~51,000 ≈ 80%, into comfortable routing-closure territory. Targets: `kyber_ntt` 28,565 LUT, `shake` ×2 14,976 LUT |",
     "s6 P4 row"),

    # --- section 7 ---
    (1, "### `kyber_ntt` — 28,668 LUTs, 88% of device; Fmax 34.1 MHz",
        "### `kyber_ntt` — 28,668 LUTs, 45.2% of device; Fmax 34.1 MHz",
        "s7 ntt share"),
    (1, "The critical path is **18.9 ns**. This module alone uses 19% of the",
        "The critical path is **18.9 ns**. This module alone uses 9.7% of the",
        "s7 poly FF share"),

    # --- section 9 ---
    (1, "   source), FF 202,589 → **39,738** (fits 65,200), LUT 124,888 →\n   **58,852** (still 1.81× over 32,600).",
        "   source), FF 202,589 → **39,738** (31.4% of 126,800), LUT 124,888 →\n   **58,852** (92.8% of the real 63,400 — inside budget, see the §1 correction).",
        "s9 item 2"),
    (1, "3. **Post-P1 verdict: FF fits, LUT does not.** The arrays infer as",
        "3. **Post-P1 verdict: the design fits xc7a100t (FF 31.4%, LUT 92.8%).**\n"
        "   The arrays infer as",
        "s9 item 3 head"),
    (1,
     "   the FF explosion (the original blocker) is gone.  The remaining LUT\n"
     "   gap is **48% NTT + 25% SHAKE + 10% basemul** — an architecture\n"
     "   problem, not a memory problem.  Options, in order of effort:\n",
     "   the FF explosion (the original blocker) is gone and LUT is inside\n"
     "   budget but at 92.8%, above the ~80% where routing usually closes.\n"
     "   The LUT pressure is **48% NTT + 25% SHAKE + 10% basemul** — an\n"
     "   architecture question, not a memory or device-size question.\n"
     "   Options, in order of effort:\n",
     "s9 item 3 body"),
    (1,
     "   - **P2 (fastest):** switch to xc7a325t.  Post-P1 netlist fits at\n"
     "     28% FF / 74% LUT.  Board change only; no RTL work.\n",
     "   - **P4 (preferred):** reduce LUT so the design sits comfortably\n"
     "     inside xc7a100t — target ≤51,000 LUT (80%) by freeing ~8K from\n"
     "     the NTT zeta ROM / butterfly pipeline or the two SHAKE instances.\n",
     "s9 P2 bullet"),
    (1,
     "   - **P4 (highest risk):** pipeline the NTT butterfly and share the\n"
     "     zeta ROM to reclaim ~26K LUTs.  Would bring 100T to ~33K LUT ≈\n"
     "     fits, but is a large RTL rewrite and changes the FSM timing.\n",
     "   - **P2 (only if P4 fails):** xc7a200t — the largest Artix-7; resources\n"
     "     are trivial (pre-opt FF 14.8% / LUT+MUXF 56.5%, §3.3).  Board change\n"
     "     only, no RTL work.  But it is not currently achievable: Vivado 2026.1\n"
     "     hangs on this netlist/part, so a different tool release or a vendor\n"
     "     fix is needed first.\n",
     "s9 P4 bullet"),

    # --- section 8 file index ---
    (1,
     "| `p3_ip_evaluation.md` | P3 IP / implementation survey (Jung 2025, Fan 2026, Xiphera XIP6110B) with integration sketch, adapter draft, and fallback-to-P2 analysis |\n",
     "| `p3_ip_evaluation.md` | P3 IP / implementation survey (Jung 2025, Fan 2026, Xiphera XIP6110B) with integration sketch, adapter draft, and fallback-to-P2 analysis |\n"
     "| `device_budget_probe.log` | **Authoritative device budgets** — get_property + report_utilization 'Available' for xc7a50t/xc7a100t/xc7a200t; the source of the §1 correction |\n"
     "| `p2_part_probe.log` | `get_parts` proof that xc7a325t / xc7a680t do not exist; xc7a200t has 32 packages |\n"
     "| `p2_part_list.txt` | All 32 xc7a200t packages with IOB counts |\n"
     "| `kem_p2_synth.log` | P2 attempt 1, project mode, xc7a200t: synthesis clean, then hangs (§3.3) |\n"
     "| `kem_p2b_synth.log` | P2 attempt 2, project-less, xc7a200t: identical clean synthesis, identical hang |\n"
     "| `kem_p2b_synth_summary.txt` | Harvested regression guards + pre-opt cell usage (FF 39,748 / LUT+MUXF 76,045 / DSP 61) |\n"
     "| `kem_p2b_run_console.txt` | Driver console output for the project-less run (rc=1, elapsed 638.6 s) |\n"
     "| `kill_p2.log` / `kill_p2b.log` | The hung Vivado process trees killed after each P2 attempt |\n",
     "s8 results index"),
    (1,
     "| `run_kem_synth_p1.py` | Full-top re-synthesis driver for the P1 path (primitive-count probe moved before `report_utilization` to survive report hangs) |\n",
     "| `run_kem_synth_p1.py` | Full-top re-synthesis driver for the P1 path (primitive-count probe moved before `report_utilization` to survive report hangs) |\n"
     "| `probe_p2_parts.py` | `get_parts` / `get_property` probe that disproved xc7a325t and xc7a680t and captured the real xc7a200t budget |\n"
     "| `list_p2_packages.py` | Enumerated all 32 xc7a200t packages with their IOB counts |\n"
     "| `run_kem_synth_p2.py` | P2 project-mode synthesis driver on xc7a200tfbg484-1 |\n"
     "| `run_kem_synth_p2b.py` | P2 project-less synthesis driver on xc7a200tfbg484-1 (RTL copied to an ASCII temp dir to dodge the Chinese-path mangle) |\n"
     "| `probe_device_budget.py` | Trivial one-FF synthesis per part to read the utilization engine's Available column — basis of the §1 correction |\n",
     "s8 script index"),
]

STALE = ["xc7a325t: 576", "xc7a680t", "1.81× over", "over 32,600", "32,600 LUT limit",
         "the 65,200 FF limit", "fits 65,200", "65,200  | 61%", "270 tiles",
         "88% of device", "19% of the", "~26K LUTs", "1.67× over", "3.11×", "3.83×"]


def main():
    txt = io.open(P, encoding="utf-8").read()
    before = len(txt)
    log = []
    for i, (exp, old, new, label) in enumerate(EDITS, 1):
        n = txt.count(old)
        if n != exp:
            print("ABORT edit %d (%s): found %d, expected %d\n  probe: %r"
                  % (i, label, n, exp, old[:70]))
            return 1
        txt = txt.replace(old, new)
        log.append("  %2d  %-22s ok (%d occurrence%s)"
                   % (i, label, n, "" if n == 1 else "s"))
    io.open(P, "w", encoding="utf-8").write(txt)
    back = io.open(P, encoding="utf-8").read()
    print("wrote %d -> %d bytes (%+d)\n" % (before, len(back), len(back) - before))
    print("applied:")
    print("\n".join(log))
    bad = [(s, back.count(s)) for s in STALE if back.count(s)]
    print("\nstale-string scan after patch:")
    if not bad:
        print("  clean — no stale budget figures remain")
    else:
        for s, c in bad:
            print("  STILL PRESENT %2d×  %r" % (c, s))
    print("\nresidual '32,600' / '65,200' mentions (should only be the xc7a50t rows):")
    for ln, line in enumerate(back.splitlines(), 1):
        if "32,600" in line or "65,200" in line or "126,800" in line or "63,400" in line:
            print("  %4d: %s" % (ln, line[:118]))
    return 0 if not bad else 1


if __name__ == "__main__":
    sys.exit(main())
