#!/usr/bin/env python3
"""Merge per-device multidev_synth results (util.rpt + timing.rpt) into a
comparison table and fill shortcomings_advancement_10bc_20261115.md.
Usage: python merge_multidev.py [--write]
Reads C:/mdv_work/out_<tag>/{util.rpt,timing.rpt} for all 4 tags.
"""
import os, re, sys, json, datetime

BASE = r"C:\mdv_work"
DOC  = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype\paper_mlkem_tvla\tecs\shortcomings_advancement_10bc_20261115.md"

TAGS = [
    ("artix7",      "xc7a100tcsg324-1",  "Artix-7",            "-1"),
    ("zynq7",       "xc7z020clg400-1",   "Zynq-7 (Zynq-7000)", "-1"),
    ("kintex7",     "xc7k325tffg900-1",  "Kintex-7",           "-1"),
    ("kintexuplus", "xcku5p-ffva676-2-e","Kintex UltraScale+", "-2"),
]

def parse_util(rpt):
    """Return dict of key resource used/avail from report_utilization table.
    UltraScale+ names LUT 'CLB LUTs' / 'CLB Registers'; 7-series 'Slice LUTs'."""
    d = {}
    if not os.path.exists(rpt):
        return d
    txt = open(rpt, encoding="utf-8", errors="replace").read()
    lines = txt.splitlines()
    pat = re.compile(r"\|\s*([^|]+?)\s*\|\s*([\d.,]+)\s*\|\s*[\d,]+\s*\|\s*[\d,]+\s*\|\s*([\d,]+)\s*\|\s*([\d.]+)?")
    for l in lines:
        m = pat.search(l)
        if not m:
            continue
        name = m.group(1).strip().rstrip("*").strip()
        used = m.group(2)
        avail = m.group(3).replace(",", "") if m.group(3) else None
        pct = m.group(4)
        if name in ("Slice LUTs", "CLB LUTs"):
            d["LUT"] = {"used": used, "avail": avail, "pct": pct}
        elif name in ("Slice Registers", "CLB Registers"):
            d["FF"] = {"used": used, "avail": avail, "pct": pct}
        elif name in ("DSPs", "DSP48E1", "DSP48E2"):
            d["DSP"] = {"used": used, "avail": avail, "pct": pct}
        elif name in ("Block RAM Tile",):
            d["BRAM"] = {"used": used, "avail": avail, "pct": pct}
    return d

def parse_timing(rpt):
    """Return (wns, whs, setup_fail, hold_fail) from report_timing_summary."""
    if not os.path.exists(rpt):
        return None
    txt = open(rpt, encoding="utf-8", errors="replace").read()
    m = re.search(r"WNS\(ns\)\s+TNS\(ns\)\s+TNS Failing Endpoints\s+TNS Total Endpoints\s+WHS\(ns\)\s+THS\(ns\)",
                  txt)
    if not m:
        return None
    # find the first data row after header
    seg = txt[m.end():m.end()+300]
    nums = re.findall(r"-?\d+\.\d+|-?\d+", seg)
    # The summary table row: WNS TNS fail total WHS THS fail total
    # We need WNS, WHS, and failing endpoints for setup/hold.
    # Better: find "Setup :" / "Hold :" lines.
    setup = re.search(r"Setup\s*:\s*(\d+)\s+Failing Endpoints,\s*Worst Slack\s+(-?\d+\.\d+)ns", txt)
    hold  = re.search(r"Hold\s*:\s*(\d+)\s+Failing Endpoints,\s*Worst Slack\s+(-?\d+\.\d+)ns", txt)
    wns = whs = None
    if setup: wns = float(setup.group(2))
    if hold:  whs = float(hold.group(2))
    return {"wns": wns, "whs": whs,
            "setup_fail": int(setup.group(1)) if setup else None,
            "hold_fail": int(hold.group(1)) if hold else None}

def collect():
    res = []
    for tag, part, fam, spd in TAGS:
        u = parse_util(os.path.join(BASE, "out_%s" % tag, "util.rpt"))
        t = parse_timing(os.path.join(BASE, "out_%s" % tag, "timing.rpt"))
        dcp = os.path.join(BASE, "out_%s" % tag, "synth.dcp")
        res.append({"tag": tag, "part": part, "family": fam, "speed": spd,
                    "util": u, "timing": t,
                    "dcp": os.path.exists(dcp) and os.path.getsize(dcp) or 0})
    return res

def fmt_row(r):
    u = r["util"]; t = r["timing"]
    def g(name):
        e = u.get(name)
        return (e["used"] if e else "–"), (e["avail"] if e and e["avail"] else "–"), (e["pct"] if e else "–")
    lut, lav, lp = g("LUT")
    ff, fav, fp = g("FF")
    dsp, dav, dp = g("DSP")
    bram, bav, bp = g("BRAM")
    wns = t["wns"] if t else "–"
    whs = t["whs"] if t else "–"
    sf = t["setup_fail"] if t else "–"
    hf = t["hold_fail"] if t else "–"
    return (r["family"], r["part"], f"{lut}", f"{ff}", f"{dsp}", f"{bram}", f"{wns}", f"{whs}", f"{sf}/{hf}")

def main(write=False):
    data = collect()
    # print JSON summary
    for r in data:
        print(json.dumps(r, ensure_ascii=False))
    if not write:
        return
    # build markdown tables
    lines = []
    lines.append("## 二、资源利用对比（post-synthesis）\n")
    lines.append("| 器件家族 | 器件 | Slice LUTs | Slice Registers | DSPs | Block RAM | 时序 WNS(ns) | 时序 WHS(ns) | Setup/Hold 违例端点 |")
    lines.append("|---|---|---|---|---|---|---|---|---|")
    for r in data:
        fam, part, lut, ff, dsp, bram, wns, whs, sf = fmt_row(r)
        lines.append(f"| {fam} | `{part}` | {lut} | {ff} | {dsp} | {bram} | {wns} | {whs} | {sf} |")
    lines.append("\n> LUT 含 LUTRAM（分布式 RAM/移位寄存器）；时序为 100 MHz `create_clock -period 10.000` 下 post-synthesis 最差 Slack，0 违例端点=闭合。")
    lines.append("\n## 三、结论\n")
    lines.append("（待数据核验后填结论）\n")
    body = "\n".join(lines)
    # splice into doc between section two header and section three
    doc = open(DOC, encoding="utf-8").read()
    # replace placeholder region
    start = doc.find("## 二、资源利用对比")
    end = doc.find("## 四、结论")
    if start == -1 or end == -1:
        print("MARKER NOT FOUND"); return
    newdoc = doc[:start] + body + "\n---\n\n" + doc[end:]
    open(DOC, "w", encoding="utf-8").write(newdoc)
    print("DOC UPDATED")

if __name__ == "__main__":
    main(write="--write" in sys.argv)
