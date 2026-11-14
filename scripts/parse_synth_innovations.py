#!/usr/bin/env python3
"""Re-parse the 12 innovation-module util/timing reports into a summary.

The synth_innovations.py regex missed 'Slice LUTs*' (asterisk in the label)
and the WNS format; this re-parses from the saved reports in results/.
"""
import os
import re
import json

RESULTS = os.path.join(os.path.abspath(os.path.dirname(__file__)),
                       "..", "results")

MODULES = [
    ("A2", "puf_trng_fused"),
    ("A3", "adaptive_mask_ctrl"),
    ("A4", "hybrid_kex"),
    ("A5", "watermark_backdoor_scan"),
    ("B1", "he_engine"),
    ("B2", "masked_accumulate_3rd_dip"),
    ("B3", "tvla_online"),
    ("B4", "mpc_private_infer"),
    ("C1", "chain_anchor_audit"),
    ("C2", "sec_acc_pareto"),
    ("C3", "model_theft_detect"),
    ("C4", "puf_model_bind"),
]


def parse_util(path):
    out = {}
    with open(path, errors="replace") as f:
        txt = f.read()
    pats = [
        ("lut", r"\|\s*Slice LUTs\*?\s*\|\s*(\d+)"),
        ("ff", r"\|\s*Slice Registers\s*\|\s*(\d+)"),
        ("dsp", r"\|\s*DSPs\s*\|\s*(\d+)"),
        ("bram", r"\|\s*Block RAM Tile\s*\|\s*(\d+)"),
    ]
    for key, pat in pats:
        m = re.search(pat, txt)
        if m:
            out[key] = int(m.group(1))
    return out


def parse_timing(path):
    with open(path, errors="replace") as f:
        txt = f.read()
    # Vivado 2026.1: "Design Timing Summary" header, a '-------' rule, then
    # "WNS(ns) TNS(ns) ..." header, another rule, then the value line.
    i = txt.find("Design Timing Summary")
    if i >= 0:
        sub = txt[i:i + 4000]
        m = re.search(r"^\s*(-?\d+\.\d+)\s+(-?\d+\.\d+)\s+\d+\s+\d+",
                      sub, re.M)
        if m:
            return float(m.group(1))
    m = re.search(r"WNS\(ns\)\s+(-?[\d.]+)", txt)
    if m:
        return float(m.group(1))
    return None


def parse_power(path):
    with open(path, errors="replace") as f:
        txt = f.read()
    m = re.search(r"Total On-Chip Power \(W\)\s*\|\s*([\d.]+)", txt)
    return float(m.group(1)) if m else None


def main():
    rows = []
    for tag, mod in MODULES:
        entry = {"tag": tag, "module": mod}
        util = os.path.join(RESULTS, "synth_innov_%s_util.rpt" % mod)
        timing = os.path.join(RESULTS, "synth_innov_%s_timing.rpt" % mod)
        power = os.path.join(RESULTS, "synth_innov_%s_power.rpt" % mod)
        ok = os.path.exists(util)
        entry["status"] = "OK" if ok else "MISSING"
        if ok:
            entry.update(parse_util(util))
            if os.path.exists(timing):
                wns = parse_timing(timing)
                if wns is not None:
                    entry["wns"] = wns
                    # slack = 10ns - D  =>  D = 10 - wns
                    entry["fmax_mhz"] = round(1000.0 / (10.0 - wns), 1)
            if os.path.exists(power):
                p = parse_power(power)
                if p is not None:
                    entry["power_w"] = p
        rows.append(entry)

    with open(os.path.join(RESULTS, "synth_innovations_summary.json"), "w") as f:
        json.dump(rows, f, indent=2, ensure_ascii=False)

    with open(os.path.join(RESULTS, "synth_innovations_summary.md"), "w") as f:
        f.write("# 12 个创新模块 Vivado 综合结果（2026-10-25）\n\n")
        f.write("器件 xc7a100tcsg324-1（Artix-7 100T），synth directive default，"
                "时钟约束 10 ns（clk 端口存在时）。\n")
        f.write("LUT/FF/DSP/BRAM 为综合后利用率，WNS 为 10 ns 约束下的最差负松弛，"
                "Power 为 vectorless pre-layout 估计。\n\n")
        f.write("| 模块 | 顶层 | 状态 | LUT | FF | DSP | BRAM | WNS (ns) | "
                "Power (W) |\n")
        f.write("|---|---|:---:|---:|---:|---:|---:|---:|---:|\n")
        for e in rows:
            f.write("| %s | `%s` | %s | %s | %s | %s | %s | %s | %s |\n" % (
                e["tag"], e["module"], e["status"],
                e.get("lut", "-"), e.get("ff", "-"), e.get("dsp", "-"),
                e.get("bram", "-"), e.get("wns", "-"), e.get("power_w", "-")))

    print("| 模块 | 顶层 | LUT | FF | DSP | BRAM | WNS | Power |")
    for e in rows:
        print("| %s | %s | %s | %s | %s | %s | %s | %s |" % (
            e["tag"], e["module"], e.get("lut", "-"), e.get("ff", "-"),
            e.get("dsp", "-"), e.get("bram", "-"), e.get("wns", "-"),
            e.get("power_w", "-")))
    print("\nSaved: results/synth_innovations_summary.{json,md}")


if __name__ == "__main__":
    main()
