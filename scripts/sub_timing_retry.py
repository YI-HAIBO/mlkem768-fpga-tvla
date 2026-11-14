#!/usr/bin/env python3
"""
Retry only the modules whose timing report is still missing.
Uses -delay_type max (setup only) to lighten the timing engine load
(kyber_ntt crashed during min+max timing in the full run).
"""
import subprocess, os, shutil, time, io, re

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
CONST     = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")
VIVADO    = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART      = "xc7a100tcsg324-1"
DIRECTIVE = "RuntimeOptimized"
XDC       = "kem.xdc"

MODULES = [
    ("kyber_ntt",  []),
    ("kyber_poly", ["kyber_ntt.v"]),
]
PERIOD_NS = 10.0   # from kem.xdc (100 MHz)


def build_tcl(mod, extra, tmp):
    xdc = os.path.join(tmp, XDC)
    L = [
        'set PROJ "' + tmp.replace("\\", "/") + '"',
        'set CORE "$PROJ/core"',
        'set PART "' + PART + '"',
        'set WORK "$PROJ/proj"',
        'if {[file exists $WORK]} { file delete -force $WORK }',
        'file mkdir $WORK',
        'create_project -force %s_timing $WORK -part $PART' % mod,
        'add_files "$CORE/%s.v"' % mod,
    ]
    for e in extra:
        L.append('add_files "$CORE/%s"' % e)
    L += [
        'set xdc "' + xdc.replace("\\", "/") + '"',
        'if {[file exists "$xdc"]} {',
        '  if {[catch {read_xdc "$xdc"} e]} {',
        '    puts "XDC error: $e"',
        '    catch {create_clock -period 10.0 -name clk [get_ports clk]}',
        '  } else { puts "XDC loaded" }',
        '} else {',
        '  catch {create_clock -period 10.0 -name clk [get_ports clk]}',
        '}',
        'puts "=== synth_design -top %s ==="' % mod,
        'synth_design -top %s -part $PART -directive %s' % (mod, DIRECTIVE),
        'set RPT "$WORK/reports"',
        'file mkdir $RPT',
        'report_timing_summary -file "$RPT/timing.rpt" -setup -max_paths 3',
        'report_utilization  -file "$RPT/util.rpt"',
        'puts "=== Done %s ==="' % mod,
        'exit',
    ]
    return "\n".join(L)


def parse_dts(path):
    """Parse the Design Timing Summary block from a timing report."""
    out = {}
    if not os.path.exists(path):
        return out
    txt = io.open(path, encoding="utf-8", errors="replace").read()
    m = re.search(
        r"Design Timing Summary[\s\S]{0,2500}?([\-\d\.]+)\s+([\-\d\.]+)\s+(\d+)\s+(\d+)\s+([\-\d\.]+)\s+([\-\d\.]+)\s+(\d+)\s+(\d+)",
        txt,
    )
    if m:
        out["WNS"]  = m.group(1)
        out["TNS"]  = m.group(2)
        out["TNS_fail"] = m.group(3)
        out["TNS_tot"]  = m.group(4)
        out["WHS"]  = m.group(5)
        out["THS"]  = m.group(6)
        out["THS_fail"] = m.group(7)
        out["THS_tot"]  = m.group(8)
        try:
            wns = float(m.group(1))
            out["Fmax_MHz"] = "%.1f" % (1000.0 / (PERIOD_NS - wns))
            out["path_ns"]  = "%.3f" % (PERIOD_NS - wns)
        except ValueError:
            pass
    return out


def parse_util(path):
    out = {}
    if not os.path.exists(path):
        return out
    txt = io.open(path, encoding="utf-8", errors="replace").read()
    for k, rx in [
        ("Slice LUTs",      r"Slice LUTs\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)"),
        ("Slice Registers", r"Slice Registers\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)"),
        ("DSPs",            r"DSPs?\s+([\d,]+)\s+([\d,]+)\s+([\d.]+)"),
    ]:
        m = re.search(rx, txt)
        if m:
            out[k] = {"used": m.group(1), "avail": m.group(2), "pct": m.group(3)}
    return out


def synth_one(mod, extra, timeout):
    tmp = "C:/tmp_subtim2_%s_%d" % (mod, int(time.time() * 1000) % 10**9)
    os.makedirs(os.path.join(tmp, "core"), exist_ok=True)
    for f in [mod + ".v"] + extra:
        shutil.copy2(os.path.join(CORE, f), os.path.join(tmp, "core", f))
    src_xdc = os.path.join(CONST, XDC)
    if os.path.exists(src_xdc):
        shutil.copy2(src_xdc, os.path.join(tmp, XDC))
    io.open(os.path.join(tmp, "synth.tcl"), "w", encoding="utf-8").write(
        build_tcl(mod, extra, tmp))
    log = os.path.join(tmp, "synth.log")
    t0 = time.time()
    try:
        r = subprocess.run(
            [VIVADO, "-mode", "batch", "-nojournal", "-log", log, "-source",
             os.path.join(tmp, "synth.tcl")],
            capture_output=True, text=True, timeout=timeout, cwd=tmp, errors="replace")
        rc = r.returncode
    except subprocess.TimeoutExpired:
        rc = -999
    el = time.time() - t0

    if os.path.exists(log):
        shutil.copy2(log, os.path.join(RESULTS, "sub_timing_%s.log" % mod))
    for rf in ["timing.rpt", "util.rpt"]:
        s = os.path.join(tmp, "proj", "reports", rf)
        if os.path.exists(s):
            dst = os.path.join(RESULTS, "sub_timing_%s_%s.rpt" % (mod, rf.split(".")[0]))
            shutil.copy2(s, dst)

    return {
        "mod": mod, "rc": rc, "time": el,
        "timing": parse_dts(os.path.join(tmp, "proj", "reports", "timing.rpt")),
        "util":   parse_util(os.path.join(tmp, "proj", "reports", "util.rpt")),
    }


def main():
    results = [synth_one(m, e, 2400) for m, e in MODULES]

    lines = ["Sub-module timing retry (setup-only), part=%s, directive=%s" % (PART, DIRECTIVE)]
    lines.append("Clock: %s ns period (%d MHz)" % (PERIOD_NS, int(1000.0 / PERIOD_NS)))
    lines.append("")
    lines.append("%-14s %5s %7s %7s %9s %9s %8s %9s %9s" %
                 ("module", "rc", "t(s)", "LUT", "FF", "DSP", "WNS", "WHS", "Fmax_MHz"))
    for r in results:
        u = r["util"]; t = r["timing"]
        lines.append("%-14s %5s %7.1f %9s %9s %8s %9s %9s %9s" % (
            r["mod"], r["rc"], r["time"],
            u.get("Slice LUTs", {}).get("used", "-"),
            u.get("Slice Registers", {}).get("used", "-"),
            u.get("DSPs", {}).get("used", "-"),
            t.get("WNS", "-"),
            t.get("WHS", "-"),
            t.get("Fmax_MHz", "-")))
    lines.append("")
    lines.append("Derived Fmax_MHz = 1000 / (period_ns - WNS_ns)")
    lines.append("Positive WNS => meets the %d MHz setup target." % int(1000.0 / PERIOD_NS))
    lines.append("Negative WHS => hold violations (common on synthetic sub-module-only runs)")
    lines.append("because input/output I/O paths are unconstrained.")

    rep = os.path.join(RESULTS, "sub_timing_retry.txt")
    io.open(rep, "w", encoding="utf-8").write("\n".join(lines))
    print("\n".join(lines))
    print("\nWrote", rep)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
