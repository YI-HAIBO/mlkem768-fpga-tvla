#!/usr/bin/env python3
"""
Priority 2: obtain timing reports (WNS/WHN/Fmax) for the 5 synthesizable
KEM sub-modules on xc7a100tcsg324-1, using -directive RuntimeOptimized
(which sidesteps the Vivado 2026.1 timing-optimization hang on large DSP counts).

Emits: results/sub_timing_<mod>_timing.rpt
Writes: results/sub_timing_summary.txt
"""
import subprocess, os, sys, shutil, time, io, re

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
CONST     = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")
VIVADO    = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART      = "xc7a100tcsg324-1"
DIRECTIVE = "RuntimeOptimized"

# module -> (required extra source files, xdc filename)
MODULES = [
    ("keccak_perm",   [],                       "kem.xdc"),
    ("shake",         ["keccak_perm.v"],        "kem.xdc"),
    ("kyber_sampler", ["shake.v", "keccak_perm.v"], "kem.xdc"),
    ("kyber_ntt",     [],                       "kem.xdc"),
    ("kyber_poly",    ["kyber_ntt.v"],          "kem.xdc"),
]

# Fallback clock constraint (200 MHz) if the project xdc does not cover the submodule clock
FALLBACK_XDC = """
#create_clock -period 5.0 -name clk [get_ports clk]
"""


def build_tcl(mod, extra, tmp, xdc_name):
    L = []
    L.append('set PROJ "' + tmp.replace("\\", "/") + '"')
    L.append('set CORE "$PROJ/core"')
    L.append('set PART "' + PART + '"')
    L.append('set WORK "$PROJ/proj"')
    L.append('if {[file exists $WORK]} { file delete -force $WORK }')
    L.append('file mkdir $WORK')
    L.append('create_project -force %s_timing $WORK -part $PART' % mod)
    L.append('add_files "$CORE/%s.v"' % mod)
    for e in extra:
        L.append('add_files "$CORE/%s"' % e)
    xdc = os.path.join(tmp, xdc_name)
    L.append('set xdc "' + xdc.replace("\\", "/") + '"')
    # kem.xdc already defines create_clock at 10.0ns (100 MHz) for port clk;
    # fall back to 5.0ns only if the xdc fails to load.
    L.append('if {[file exists "$xdc"]} {')
    L.append('  if {[catch {read_xdc "$xdc"} e]} {')
    L.append('    puts "XDC error: $e"')
    L.append('    catch {create_clock -period 5.0 -name clk [get_ports clk]}')
    L.append('  } else { puts "XDC loaded: $xdc" }')
    L.append('} else {')
    L.append('  catch {create_clock -period 5.0 -name clk [get_ports clk]}')
    L.append('}')
    L.append('puts "=== synth_design -top %s ==="' % mod)
    L.append('synth_design -top %s -part $PART -directive %s' % (mod, DIRECTIVE))
    L.append('set RPT "$WORK/reports"')
    L.append('file mkdir $RPT')
    L.append('report_timing_summary -file "$RPT/timing.rpt" -delay_type min_max -max_paths 3')
    L.append('report_utilization -file "$RPT/util.rpt"')
    L.append('puts "=== Done %s ==="' % mod)
    L.append('exit')
    return "\n".join(L)


def parse_timing(path):
    out = {}
    if not os.path.exists(path):
        return out
    txt = io.open(path, "r", encoding="utf-8", errors="replace").read()
    for k, rx in [("WNS", r"WNS\s+\n?\s+([\-\d.]+)"),
                  ("WHN", r"WHN\s+\n?\s+([\-\d.]+)"),
                  ("Fmax", r"Fmax\s+\n?\s+([\-\d.]+)")]:
        m = re.search(rx, txt)
        if m:
            out[k] = m.group(1)
    return out


def parse_util(path):
    out = {}
    if not os.path.exists(path):
        return out
    txt = io.open(path, "r", encoding="utf-8", errors="replace").read()
    for k, rx in [("Slice LUTs", r"Slice LUTs\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)"),
                  ("Slice Registers", r"Slice Registers\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)"),
                  ("DSPs", r"DSPs?\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)")]:
        m = re.search(rx, txt)
        if m:
            out[k] = {"used": m.group(1), "avail": m.group(2), "pct": m.group(3)}
    return out


def synth_one(mod, extra, xdc_name, timeout):
    tmp = "C:/tmp_subtim_%s_%d" % (mod, int(time.time() * 1000) % 10**9)
    os.makedirs(os.path.join(tmp, "core"), exist_ok=True)
    need = [mod + ".v"] + extra
    for f in need:
        shutil.copy2(os.path.join(CORE, f), os.path.join(tmp, "core", f))
    # xdc
    src = os.path.join(CONST, xdc_name)
    if os.path.exists(src):
        shutil.copy2(src, os.path.join(tmp, xdc_name))
    else:
        io.open(os.path.join(tmp, xdc_name), "w", encoding="utf-8").write(FALLBACK_XDC)
    tcl = os.path.join(tmp, "synth.tcl")
    io.open(tcl, "w", encoding="utf-8").write(build_tcl(mod, extra, tmp, xdc_name))
    log = os.path.join(tmp, "synth.log")

    cmd = [VIVADO, "-mode", "batch", "-nojournal", "-log", log, "-source", tcl]
    t0 = time.time()
    rc, timed_out = -1, False
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout,
                           cwd=tmp, errors="replace")
        rc = r.returncode
    except subprocess.TimeoutExpired:
        timed_out = True
    el = time.time() - t0

    # copy artifacts
    res = {"mod": mod, "rc": rc, "time": el, "timed_out": timed_out}
    if os.path.exists(log):
        shutil.copy2(log, os.path.join(RESULTS, "sub_timing_%s.log" % mod))
    for rf in ["timing.rpt", "util.rpt"]:
        s = os.path.join(tmp, "proj", "reports", rf)
        if os.path.exists(s):
            shutil.copy2(s, os.path.join(RESULTS, "sub_timing_%s_%s" % (mod, rf.replace(".rpt", ""))))
            res[rf] = os.path.join(RESULTS, "sub_timing_%s_%s" % (mod, rf.replace(".rpt", "")))
    res["timing"] = parse_timing(os.path.join(tmp, "proj", "reports", "timing.rpt"))
    res["util"] = parse_util(os.path.join(tmp, "proj", "reports", "util.rpt"))
    return res


def main():
    timeout = int(os.environ.get("SUB_TIMING_TIMEOUT", "2400"))
    results = []
    for mod, extra, xdc in MODULES:
        print("\n==== %s (timeout %ds) ====" % (mod, timeout), flush=True)
        try:
            r = synth_one(mod, extra, xdc, timeout)
        except Exception as e:
            r = {"mod": mod, "rc": -1, "time": 0, "timed_out": False, "err": str(e),
                 "timing": {}, "util": {}}
        results.append(r)
        print("  rc=%s time=%.1fs timed_out=%s timing=%s" %
              (r.get("rc"), r.get("time", 0), r.get("timed_out"), r.get("timing")), flush=True)

    lines = ["Sub-module timing report, part=%s, directive=%s" % (PART, DIRECTIVE)]
    lines.append("")
    lines.append("%-14s %6s %9s %-8s %9s %9s %9s %9s %9s" %
                 ("module", "rc", "time(s)", "timeout", "LUT", "FF", "DSP", "WNS", "Fmax"))
    for r in results:
        u = r.get("util", {})
        t = r.get("timing", {})
        lines.append("%-14s %6s %9.1f %-8s %9s %9s %9s %9s %9s" % (
            r["mod"], r.get("rc"), r.get("time", 0),
            "YES" if r.get("timed_out") else "-",
            u.get("Slice LUTs", {}).get("used", "-"),
            u.get("Slice Registers", {}).get("used", "-"),
            u.get("DSPs", {}).get("used", "-"),
            t.get("WNS", "-"),
            t.get("Fmax", "-")))
    lines.append("")
    lines.append("Note: rc=1 with a produced .rpt is normal for Vivado 2026.1 batch here")
    lines.append("(a stray non-zero exit after reports are written).")
    rep = os.path.join(RESULTS, "sub_timing_summary.txt")
    io.open(rep, "w", encoding="utf-8").write("\n".join(lines))
    print("\n===== SUMMARY =====")
    print("\n".join(lines))
    print("\nSummary -> %s" % rep)
    return 0


if __name__ == "__main__":
    sys.exit(main())
