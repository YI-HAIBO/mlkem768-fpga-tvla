#!/usr/bin/env python3
"""probe_ntt_bram.py — evaluate forcing the kyber_ntt coefficient array into
Block RAM (the §7.1 R2 route) to escape the 25K-LUT LUTRAM cost.

Test matrix:
  V_base   : unmodified kyber_ntt.v (baseline, expect LUTRAM)
  V_block  : coeff[] gets (* ram_style = "block" *)  — attribute only
  V_split  : butterfly split into read-phase / write-phase (2 cycles) +
             ram_style="block" so the 2R+2W fits a dual-port BRAM

For each variant: synth on xc7a100tcsg324-1 (RuntimeOptimized), capture
LUT / LUT-as-Memory / FF / BRAM counts and any Synth 8-* RAM-inference notes.
"""
import io
import os
import re
import shutil
import subprocess
import sys
import time

PROJECT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CORE = os.path.join(PROJECT, "rtl", "core")
RESULTS = os.path.join(PROJECT, "results")
VIVADO = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART = "xc7a100tcsg324-1"
DIRECTIVE = "RuntimeOptimized"
TIMEOUT = int(os.environ.get("NTT_BRAM_TIMEOUT", "600"))

XDC = "create_clock -period 10.0 [get_ports clk]\nset_false_path -from [get_ports rst_n]\n"


def make_variants():
    src = io.open(os.path.join(CORE, "kyber_ntt.v"), encoding="utf-8").read()
    variants = {"V_base": src}

    # V_block: attribute only
    anchor = "    reg [BW-1:0] coeff [0:N-1];"
    assert anchor in src, "coeff decl anchor not found"
    vblock = src.replace(
        anchor,
        "    (* ram_style = \"block\" *) reg [BW-1:0] coeff [0:N-1];",
        1)
    variants["V_block"] = vblock
    return variants


def synth_variant(tag, verilog_src):
    tmp = "C:/tmp_nttbram_%s_%d" % (tag, int(time.time() * 1000) % 10 ** 9)
    os.makedirs(tmp, exist_ok=True)
    vpath = os.path.join(tmp, "kyber_ntt.v")
    io.open(vpath, "w", encoding="utf-8", newline="\n").write(verilog_src)
    io.open(os.path.join(tmp, "probe.xdc"), "w", encoding="utf-8").write(XDC)
    tcl = os.path.join(tmp, "synth.tcl")
    L = [
        'set WORK "%s/proj"' % tmp.replace("\\", "/"),
        'if {[file exists $WORK]} { file delete -force $WORK }',
        'file mkdir $WORK',
        'create_project -force ntt_bram $WORK -part %s' % PART,
        'add_files "%s"' % vpath.replace("\\", "/"),
        'read_xdc "%s/probe.xdc"' % tmp.replace("\\", "/"),
        'synth_design -top kyber_ntt -part %s -directive %s' % (PART, DIRECTIVE),
        'set RPT "$WORK/reports"; file mkdir $RPT',
        'report_utilization -file "$RPT/util.rpt"',
        'puts "=== Done %s ==="' % tag,
        'exit',
    ]
    io.open(tcl, "w", encoding="utf-8").write("\n".join(L))
    log = os.path.join(tmp, "synth.log")
    t0 = time.time()
    timed_out = False
    try:
        subprocess.run([VIVADO, "-mode", "batch", "-nojournal", "-log", log,
                        "-source", tcl], capture_output=True, text=True,
                       timeout=TIMEOUT, cwd=tmp, errors="replace")
    except subprocess.TimeoutExpired:
        timed_out = True
    el = time.time() - t0

    res = {"tag": tag, "time": el, "timed_out": timed_out}
    util = os.path.join(tmp, "proj", "reports", "util.rpt")
    if os.path.exists(util):
        shutil.copy2(util, os.path.join(RESULTS, "ntt_bram_%s_util.rpt" % tag))
        res["util"] = parse_util(util)
    if os.path.exists(log):
        txt = io.open(log, encoding="utf-8", errors="replace").read()
        res["ram_notes"] = extract_ram_notes(txt)
        shutil.copy2(log, os.path.join(RESULTS, "ntt_bram_%s.log" % tag))
    return res


def parse_util(path):
    u = {}
    t = io.open(path, encoding="utf-8", errors="replace").read()
    for k, rx in [("LUT", r"Slice LUTs\*\s+\|\s+([\d,]+)"),
                  ("LUT_MEM", r"LUT as Memory\s+\|\s+([\d,]+)"),
                  ("FF", r"Slice Registers\s+\|\s+([\d,]+)"),
                  ("BRAM", r"Block RAM Tile\s+\|\s+([\d,]+)")]:
        m = re.search(rx, t)
        if m:
            u[k] = m.group(1)
    return u


def extract_ram_notes(txt):
    notes = []
    for m in re.finditer(r"(Synth 8-\d+[^\n]*)", txt):
        s = m.group(1).strip()
        if "RAM" in s or "ram" in s or "memory" in s.lower():
            notes.append(s[:160])
    # de-dup preserve order
    seen = set()
    out = []
    for n in notes:
        if n not in seen:
            seen.add(n)
            out.append(n)
    return out


def main():
    variants = make_variants()
    only = sys.argv[1] if len(sys.argv) > 1 else None
    results = []
    for tag, src in variants.items():
        if only and tag != only:
            continue
        print("\n==== %s ====" % tag, flush=True)
        r = synth_variant(tag, src)
        results.append(r)
        print("  time=%.1fs timed_out=%s util=%s" % (r["time"], r["timed_out"], r.get("util")))
        for n in r.get("ram_notes", [])[:6]:
            print("   note:", n)
    print("\n==== SUMMARY ====")
    for r in results:
        u = r.get("util", {})
        print("  %-8s LUT=%-7s LUTmem=%-7s FF=%-7s BRAM=%-4s %s" % (
            r["tag"], u.get("LUT", "-"), u.get("LUT_MEM", "-"),
            u.get("FF", "-"), u.get("BRAM", "-"),
            "TIMEOUT" if r["timed_out"] else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
