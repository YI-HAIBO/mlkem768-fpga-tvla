#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Re-parse the nttvar_* artefacts already collected under results/ and print a
clean LUT-attribution table.

Why a separate script: probe_ntt_variants.py *collects* (runs Vivado, copies
artefacts, prints a summary). This one only *analyzes*, so it can be re-run
after the parsers are fixed without spending another 6 Vivado hours.

Data sources per variant, in order of trust:
  1. util.rpt            report_utilization -hierarchical  -> device-budget totals
  2. synth-log census    "Report Cell Usage" table        -> LUT6/LUT5/.../DSP48E1
  3. netlist.v           write_verilog -force -nolib      -> per-name attribution

The synth-log census and the netlist agree cell-for-cell (V0 LUT6 = 22,429
both places); report_utilization reports a *lower* Total LUTs (28,485) than
the sum of LUT1..LUT6 in the netlist (30,463).  The 1,978 gap is not a
parser artefact, so both numbers are reported side by side and attribution
is done on netlist counts, where the delta between variants is exact.
"""
import io
import os
import re
import sys

RESULTS = os.path.join(os.path.dirname(os.path.abspath(__file__)), os.pardir, "results")
RESULTS = os.path.normpath(RESULTS)

PRIMS = ["LUT1", "LUT2", "LUT3", "LUT4", "LUT5", "LUT6", "MUXF7", "MUXF8",
         "CARRY4", "DSP48E1", "FDRE", "FDCE", "FDSE", "FDPE", "LDCE",
         "SRLC32E", "SRLC16E", "RAM32X1S", "RAM64X1S", "RAM64M",
         "RAM128X1S", "RAMB36E1", "RAMB18E1", "IBUF", "OBUF", "BUFG"]
LUTS = {"LUT1", "LUT2", "LUT3", "LUT4", "LUT5", "LUT6"}
FLOPS = {"FDRE", "FDCE", "FDSE", "FDPE", "LDCE"}
BUCKETS = ["coeff", "zeta", "fqmul", "montgomery", "barrett", "modadd",
           "modsub", "block_start", "block_cnt", "zeta_cnt", "j_cnt",
           "read_data", "load_data", "aj", "ajl", "zv", "FSM_sequential",
           "state", "layer_idx", "len", "cnt", "p_1_out", "p_4_out", "p_7_out"]

PRIM_ALT = "|".join(PRIMS)
_NAME_A = re.compile(r"\)\s*\n?\s*\\?([^\s(]+)\s*\n?\s*\(")
_NAME_B = re.compile(r"\b(?:%s)\b\s+\\?([^\s(]+)\s*\(" % PRIM_ALT)
_PRIM = re.compile(r"\b(%s)\b" % PRIM_ALT)

VARIANTS = [("V0", "baseline"),
            ("V1", "read_data=0  [DEAD CODE, invalid]"),
            ("V1b", "read_addr const"),
            ("V2", "ram_style=distributed"),
            ("V3", "arith pass-through"),
            ("V4", "N=256 -> N=16")]


def read(path):
    try:
        return io.open(path, encoding="utf-8", errors="replace").read()
    except OSError:
        return ""


def parse_util(tag):
    out = {}
    s = read(os.path.join(RESULTS, "nttvar_%s_util.rpt" % tag))
    for ln in s.splitlines():
        m = re.match(r"\|\s*(\w+)\s*\|\s*\(?\w*\)?\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|"
                     r"\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|\s*(\d+)\s*\|"
                     r"\s*(\d+)\s*\|\s*(\d+)\s*\|", ln)
        if m:
            out[m.group(1)] = {"LUTs": int(m.group(2)), "LogicLUTs": int(m.group(3)),
                               "LUTRAM": int(m.group(4)), "SRL": int(m.group(5)),
                               "FFs": int(m.group(6)), "BRAM36": int(m.group(7)),
                               "BRAM18": int(m.group(8)), "DSP": int(m.group(9))}
    return out


def parse_census(tag):
    out = {}
    s = read(os.path.join(RESULTS, "nttvar_%s_alllogs.txt" % tag))
    for m in re.finditer(r"\|\s*(\d+)\s+\|\s*(\w+)\s+\|\s*([\d,]+)\s*\|", s):
        if m.group(2) not in PRIMS:
            continue
        out[m.group(2)] = out.get(m.group(2), 0) + int(m.group(3).replace(",", ""))
    return out, s


def parse_netlist(tag):
    cens, blut, bff = {}, {}, {}
    txt = read(os.path.join(RESULTS, "nttvar_%s_netlist.v" % tag))
    n = 0
    if not txt:
        return cens, blut, bff, n
    for chunk in txt.split(";"):
        m = _PRIM.search(chunk)
        if not m:
            continue
        pri = m.group(1)
        cens[pri] = cens.get(pri, 0) + 1
        mi = _NAME_A.search(chunk) or _NAME_B.search(chunk)
        if not mi:
            continue
        n += 1
        ln = mi.group(1).lstrip("\\").lower()
        for b in BUCKETS:
            if b.lower() in ln:
                if pri in LUTS:
                    blut[b] = blut.get(b, 0) + 1
                elif pri in FLOPS:
                    bff[b] = bff.get(b, 0) + 1
    return cens, blut, bff, n


def main():
    data = {}
    for tag, _ in VARIANTS:
        cens_log, log = parse_census(tag)
        cens_nl, blut, bff, nn = parse_netlist(tag)
        data[tag] = {"cens_log": cens_log, "cens_nl": cens_nl, "log": log,
                     "blut": blut, "bff": bff, "nn": nn,
                     "util": parse_util(tag)}

    print("=" * 100)
    print("A. DEVICE-BUDGET TOTALS (report_utilization -hierarchical, xc7a100tcsg324-1)")
    print("=" * 100)
    print("%-5s %-34s %8s %8s %7s %6s %5s %5s %4s" %
          ("tag", "variant", "LUTs", "LogicL", "LUTRAM", "FFs", "DSP", "BRAM", "SRL"))
    for tag, name in VARIANTS:
        u = data[tag]["util"].get("kyber_ntt")
        if not u:
            print("%-5s %-34s %s" % (tag, name, "(no util.rpt)"))
            continue
        print("%-5s %-34s %8d %8d %7d %6d %5d %5d %4d" %
              (tag, name, u["LUTs"], u["LogicLUTs"], u["LUTRAM"], u["FFs"],
               u["DSP"], u["BRAM36"] + u["BRAM18"], u["SRL"]))

    print()
    print("=" * 100)
    print("B. PRIMITIVE CENSUS (synth-log 'Report Cell Usage')")
    print("=" * 100)
    tags = [t for t, _ in VARIANTS]
    keys = [k for k in PRIMS if any(data[t]["cens_log"].get(k) for t in tags)]
    head = "%-10s %14s" % ("prim", "netLUTsum")
    head += "".join("%12s" % ("%s.%s" % (t, n.split()[0])) for t, n in VARIANTS)
    print("%-10s" % "prim" + "".join("%12s" % t for t in tags))
    for k in keys:
        row = "%-10s" % k
        for t in tags:
            row += "%12d" % data[t]["cens_log"].get(k, 0)
        print(row)
    for label, fn in (("LUT1..6", lambda t: sum(data[t]["cens_log"].get(k, 0)
                                                for k in LUTS)),
                      ("FD*FFs", lambda t: sum(data[t]["cens_log"].get(k, 0)
                                               for k in FLOPS)),
                      ("MUXF7+8", lambda t: data[t]["cens_log"].get("MUXF7", 0)
                                          + data[t]["cens_log"].get("MUXF8", 0))):
        print("%-10s" % label + "".join("%12d" % fn(t) for t in tags))

    print()
    print("=" * 100)
    print("C. CROSSES: netlist LUT sum vs report_utilization Total LUTs")
    print("=" * 100)
    for tag, name in VARIANTS:
        nl = sum(data[tag]["cens_nl"].get(k, 0) for k in LUTS)
        cf = sum(data[tag]["cens_nl"].get(k, 0) for k in FLOPS)
        u = data[tag]["util"].get("kyber_ntt", {}).get("LUTs")
        print("%-5s netLUT=%8d netFF=%7d  util_LUTs=%-8s  gap=%s  names=%d" %
              (tag, nl, cf, u if u is not None else "-",
               (nl - u) if u is not None else "-", data[tag]["nn"]))

    print()
    print("=" * 100)
    print("D. Deltas vs V0 (netlist LUT sum)")
    print("=" * 100)
    base = sum(data["V0"]["cens_nl"].get(k, 0) for k in LUTS)
    print("V0 netlist LUT sum = %d" % base)
    for tag, name in VARIANTS:
        if tag == "V0":
            continue
        v = sum(data[tag]["cens_nl"].get(k, 0) for k in LUTS)
        if not v:
            continue
        print("  %s %-34s %8d   %+8d  (%+.1f%%)" %
              (tag, name, v, v - base, 100.0 * (v - base) / base))

    print()
    print("=" * 100)
    print("E. NAME-BUCKET ATTRIBUTION (netlist parse)")
    print("=" * 100)
    for tag, name in VARIANTS:
        tot = sum(data[tag]["blut"].values())
        print("%s (%s)  LUT-bucket hits=%d  FF-bucket hits=%d  of %d names" %
              (tag, name, tot, sum(data[tag]["bff"].values()), data[tag]["nn"]))
    print()
    print("%-18s" % "bucket" + "".join("%12s" % t for t in tags))
    allk = set()
    for t in tags:
        allk |= set(data[t]["blut"])
    for k in sorted(allk, key=lambda b: -max(data[t]["blut"].get(b, 0) for t in tags)):
        print("%-18s" % k + "".join("%12d" % data[t]["blut"].get(k, 0) for t in tags))

    print()
    print("%-18s" % "FF bucket" + "".join("%12s" % t for t in tags))
    allk = set()
    for t in tags:
        allk |= set(data[t]["bff"])
    for k in sorted(allk, key=lambda b: -max(data[t]["bff"].get(b, 0) for t in tags)):
        print("%-18s" % k + "".join("%12d" % data[t]["bff"].get(k, 0) for t in tags))

    print()
    print("=" * 100)
    print("F. ROM INFERENCE + REGISTER COUNTS + WARNINGS")
    print("=" * 100)
    for tag, name in VARIANTS:
        log = data[tag]["log"]
        rom = re.findall(r"\|\s*(\w+)\s*\|\s*(\w+)\s*\|\s*(\d+)x(\d+)\s*\|\s*(\w+)\s*\|",
                         log)
        reg = re.findall(r"(\d+)\s+Bit\s+Registers\s*:=\s*(\d+)", log)
        rb = sum(int(a) * int(b) for a, b in reg)
        warns = {w: log.count("[Synth %s]" % w) for w in
                 ("8-7186", "8-4767", "8-6849", "8-2914", "8-6090", "8-327",
                  "8-6014", "8-1962", "8-3333")}
        warns = {k: v for k, v in warns.items() if v}
        print("%s: ROM=%s  regbits=%d  warnings=%s" % (tag, rom, rb, warns or "{}"))


if __name__ == "__main__":
    sys.exit(main())
