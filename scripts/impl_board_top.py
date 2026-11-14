#!/usr/bin/env python3
"""
Full implementation flow (synth -> opt -> place -> route -> reports -> bitstream)
for rtl/ipx_aoi_sec_board_top.v on the real Nexys 4 DDR pinout.

Unlike the unified_ntt timing probe, this uses the genuine board constraint file
(constrains/nexys4ddr_nexys_top.xdc: clk=E3 100 MHz, rst_n=C12, 16 LED, 16 SW,
5 BTN), so every top-level port is constrained and the flow produces a real,
board-loadable .bit.  Answers: does the full ML-KEM board top fit the
XC7A100T and still meet 100 MHz after place & route?

Inherits every 2026-10-24/25 host workaround from impl_unified_ntt.py:
  * Vivado process cwd must be ASCII (Chinese CWD -> heap corruption at elaboration)
  * synth.enableParallelHelperSpawn none  (orphan-helper IPC corruption)
  * synth.elaboration.useElabCache false  (synth-finish hang)
  * general.maxThreads 1 ONLY around the timing reports (global cap kills the
    flow inside "Cross Boundary and Area Optimization")

Usage:
    python scripts/impl_board_top.py board t75a

Reports land in results/impl_board_top_<tag>_<report>.rpt (+ .bit).
Run with `python -u` for live progress.
"""
import subprocess, os, sys, shutil, time, io, re

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
REAL      = os.path.join(PROJECT, "rtl", "real")
RTL       = os.path.join(PROJECT, "rtl")
CONSTR    = os.path.join(PROJECT, "constrains")
RESULTS   = os.path.join(PROJECT, "results")

VIVADO  = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART    = "xc7a100tcsg324-1"
TIMEOUT = 3600
TOP     = "ipx_aoi_sec_board_top"
XDC_SRC = os.path.join(CONSTR, "nexys4ddr_nexys_top.xdc")

# board_top + kyber_kem dependency closure (verified by iverilog compile)
RTL_FILES = ["kyber_kem.v", "kyber_poly.v", "kyber_ntt.v", "kyber_sampler.v",
             "shake.v", "keccak_perm.v"]
# Path A: the on-chip Welch t-test engine now lives in the board-level netlist.
# It is copied into tmp_core so the Tcl `glob "$CORE/*.v"` picks it up.
REAL_FILES = ["tvla_online.v"]

MARKS = {
    "00_start":        "vivado started",
    "10_project":      "project + sources + xdc loaded",
    "20_synth_done":   "synth_design finished",
    "25_opt_done":     "opt_design finished",
    "30_place_done":   "place_design finished",
    "31_checkpoint":   "placed checkpoint written",
    "35_pre_route_timing": "pre-route timing reported",
    "40_route_done":   "route_design finished",
    "50_post_timing":  "post-route timing reported",
    "55_post_util":    "post-route utilization reported",
    "60_drc":          "report_drc finished",
    "70_bitstream":    "write_bitstream finished",
}
REPORTS = ("pre_route_timing.rpt", "post_route_timing.rpt",
           "pre_route_util.rpt", "util.rpt", "drc.rpt")

TCL = """\
# Board-top implementation.  Host workarounds (params preamble) are injected
# on the first executable lines below.
@@PARAMS@@
set PROJ "@@PROJ@@"
set RTL  "$PROJ/rtl"
set CORE "$PROJ/core"
set XDC  "$PROJ/board.xdc"
set PART "@@PART@@"
set MARK "@@MARK@@"
set WORK "$PROJ/proj"
set RPT  "$PROJ/rpt"
set TOP  "@@TOP@@"
set BIT  "@@BIT@@"

proc mk {name} {
    global MARK
    set fh [open "$MARK/$name.txt" w]
    puts $fh "[clock format [clock seconds]]"
    close $fh
}

file mkdir $MARK
file mkdir $RPT
mk 00_start

puts "=== impl $TOP ==="
if {[file exists $WORK]} { file delete -force $WORK }
file mkdir $WORK
create_project -force $TOP $WORK -part $PART
foreach f [glob -nocomplain "$CORE/*.v"] { add_files $f }
foreach f [glob -nocomplain "$RTL/$TOP.v"] { add_files $f }
read_xdc $XDC
# Real board pinout constrains every port, but keep NSTD-1/UCIO-1 demoted so a
# stray unconstrained net cannot abort write_bitstream (rc=1) on an otherwise
# clean flow.
set_property SEVERITY {Warning} [get_drc_checks {NSTD-1 UCIO-1}]
mk 10_project

synth_design -top $TOP -part $PART -directive @@DIRECTIVE@@
mk 20_synth_done

opt_design
mk 25_opt_done

place_design -directive @@PLACEMENT@@@@PLACEMENT_SUB@@
mk 30_place_done

# Save the placed design so route_design can be retried standalone.
# The host runs other projects whose runners do a GLOBAL taskkill of
# vivado.exe at irregular intervals (~40-85 min), killing our route;
# the checkpoint lets a route-only retry skip the ~20 min synth+place.
write_checkpoint -force "$PROJ/placed.dcp"
mk 31_checkpoint

report_utilization -file "$RPT/pre_route_util.rpt"
@@TIMING_PARAMS@@
report_timing_summary -file "$RPT/pre_route_timing.rpt" -delay_type min_max -max_paths 5
mk 35_pre_route_timing

@@PROBE_EXIT@@

# route_design died in "Phase 5.1 Global Iteration 0" on this host twice (t75d
# at 100 MHz, t75e at 12.5 MHz) with 27898 overlaps at that point -- not random
# machine jitter but a systematic route-stage failure, so route single-threaded
# and restore the thread cap afterwards for the reports/bitstream.
catch {set_param general.maxThreads 1}
route_design @@ROUTE_DIRECTIVE@@
mk 40_route_done
catch {set_param general.maxThreads 4}
@@TIMING_PARAMS@@
report_timing_summary -file "$RPT/post_route_timing.rpt" -delay_type min_max -max_paths 5
mk 50_post_timing

report_utilization -file "$RPT/util.rpt"
mk 55_post_util

report_drc -file "$RPT/drc.rpt"
mk 60_drc

write_bitstream -force $BIT
mk 70_bitstream

puts "=== done ==="
exit
"""


def write(path, text):
    with io.open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(text)


# Unique tmp prefix for THIS board project's runs.  Kill scope is derived from
# it so we never touch another project's Vivado (memory 4.2 rule ②: 永不全局
# taskkill).  A different project (UOV full-PNR) runs Vivado on the same host
# and its runner does a GLOBAL taskkill, which previously killed our synth
# parallel workers ("Parallel Worker Creation Failure: Worker N has died") and
# caused a silent synth death for t89f100.
TMP_PREFIX = "C:\\tmp_impl_board_"


def kill_orphan_vivados():
    """Kill only Vivado processes whose command line references this project's
    tmp dir prefix (C:\\tmp_impl_board_).  Never a global taskkill."""
    import locale
    enc = locale.getpreferredencoding(False)
    needle = TMP_PREFIX.lower()
    ps_cmd = ("powershell -NoProfile -Command "
              "\"Get-CimInstance Win32_Process -Filter \\\"Name='vivado.exe'\\\" "
              "| Select-Object ProcessId, CommandLine | ConvertTo-Csv -NoTypeInformation\"")
    try:
        out = subprocess.run(ps_cmd, capture_output=True, shell=True,
                             timeout=60)
    except Exception:
        return
    text = out.stdout.decode(enc, 'replace')

    import csv, io
    pids = []
    try:
        rows = list(csv.reader(io.StringIO(text)))
    except Exception:
        return
    for row in rows[1:]:
        if len(row) >= 2 and row[0].strip().isdigit():
            pid = row[0].strip()
            cmdline = (row[1] if len(row) > 1 else '').lower()
            if needle in cmdline:
                pids.append(pid)
    if not pids:
        return
    print("  killing %d orphan Vivado PID(s) scoped to %s"
          % (len(pids), TMP_PREFIX), flush=True)
    for pid in pids:
        subprocess.run(['taskkill', '/PID', pid, '/T', '/F'], capture_output=True)
        time.sleep(1)


def logtail(log_path, n=15):
    if not os.path.exists(log_path):
        return
    try:
        lines = io.open(log_path, encoding="utf-8", errors="replace").read().splitlines()
    except OSError:
        return
    print("  ---- log tail (last %d of %d lines) ----" % (n, len(lines)), flush=True)
    for ln in lines[-n:]:
        print("   | " + ln[:170], flush=True)


def params_block():
    return "\n".join([
        "catch {set_param synth.enableParallelHelperSpawn none}",
        "catch {set_param synth.elaboration.useElabCache false}",
    ])


def timing_params_block():
    if os.environ.get("IMPL_NO_MAXTHREADS"):
        return ""
    return "catch {set_param general.maxThreads 1}"


def run_vivado(tcl_path, mark_dir, timeout):
    log_path = tcl_path.replace(".tcl", ".log")
    cmd = [VIVADO, "-mode", "batch", "-nojournal", "-log", log_path,
           "-source", tcl_path]
    ascii_cwd = os.path.dirname(os.path.abspath(tcl_path))
    print("  cwd: %s" % ascii_cwd, flush=True)
    kill_orphan_vivados()
    t0 = time.time()
    seen = []
    p = subprocess.Popen(cmd, stdout=subprocess.DEVNULL,
                         stderr=subprocess.DEVNULL, cwd=ascii_cwd)
    while p.poll() is None:
        if time.time() - t0 > timeout:
            # Kill THIS run's full process tree (workers included) -- never a
            # global taskkill, and never touch another project's Vivado.
            try:
                subprocess.run(['taskkill', '/PID', str(p.pid), '/T', '/F'],
                               capture_output=True)
            except Exception:
                try:
                    p.terminate()
                except Exception:
                    pass
            try:
                p.wait(timeout=10)
            except Exception:
                pass
            print("  TIMEOUT after %.0fs (last marker: %s)"
                  % (time.time() - t0, seen[-1] if seen else "none"), flush=True)
            logtail(log_path)
            return None, seen
        try:
            files = sorted(os.listdir(mark_dir))
        except OSError:
            files = []
        for f in files:
            key = os.path.splitext(f)[0]
            if key not in seen:
                seen.append(key)
                print("  [%5.0fs] %-22s %s"
                      % (time.time() - t0, MARKS.get(key, "?"), f), flush=True)
        time.sleep(5)
    rc = p.returncode
    print("  rc=%d  time=%.0fs  markers=%d/%d"
          % (rc, time.time() - t0, len(seen), len(MARKS)), flush=True)
    if rc != 0:
        logtail(log_path)
    return rc, seen


def run(tag="", stamp=None, directive="default", placement="Explore",
         placement_sub="", route_directive=""):
    if stamp is None:
        stamp = time.strftime("%Y%m%d_%H%M%S")
    tmp      = "C:/tmp_impl_board_%s_%s" % (tag.replace("_", "-") or "run", stamp)
    tmp_core = os.path.join(tmp, "core")
    tmp_rtl  = os.path.join(tmp, "rtl")
    tmp_mark = os.path.join(tmp, "mark")
    tmp_bit  = os.path.join(tmp, "board.bit")
    for d in (tmp, tmp_core, tmp_rtl):
        os.makedirs(d, exist_ok=True)

    for f in RTL_FILES:
        shutil.copy2(os.path.join(CORE, f), os.path.join(tmp_core, f))
    for f in REAL_FILES:
        shutil.copy2(os.path.join(REAL, f), os.path.join(tmp_core, f))
    shutil.copy2(os.path.join(RTL, TOP + ".v"), os.path.join(tmp_rtl, TOP + ".v"))
    shutil.copy2(XDC_SRC, os.path.join(tmp, "board.xdc"))

    # Optional CLK_DIV override (env var): rewrite the parameter in the COPY
    # in the tmp dir (source RTL untouched).  BOARD_CLK_DIV=1 puts the whole
    # KEM datapath on the 100 MHz crystal -- the Task #89 "Route B" timing
    # closure test for the pipelined basemul accumulate path.
    clk_div = os.environ.get("BOARD_CLK_DIV")
    if clk_div:
        topv = os.path.join(tmp_rtl, TOP + ".v")
        s = io.open(topv, encoding="utf-8").read()
        s2, n = re.subn(r"(parameter\s+integer\s+CLK_DIV\s*=\s*)(\d+)",
                        r"\g<1>%s" % clk_div, s)
        if n != 1:
            raise RuntimeError("CLK_DIV param rewrite matched %d times (want 1)" % n)
        write(topv, s2)
        print("  BOARD_CLK_DIV=%s -> rewrote CLK_DIV in %s" % (clk_div, topv), flush=True)

    fs = lambda s: s.replace("\\", "/")
    # PROBE_ONLY=1: place + pre-route timing + util, then exit (skip route).
    # Cheap way to learn whether the datapath closes 100 MHz before burning an
    # hour on route_design.
    probe_exit = ("exit\n" if os.environ.get("IMPL_PROBE_ONLY") else "")
    repl = {"@@PROJ@@": fs(tmp), "@@PART@@": PART, "@@TOP@@": TOP,
            "@@MARK@@": fs(tmp_mark), "@@BIT@@": fs(tmp_bit),
            "@@DIRECTIVE@@": directive, "@@PLACEMENT@@": placement,
            "@@PLACEMENT_SUB@@": placement_sub,
            "@@ROUTE_DIRECTIVE@@": route_directive,
            "@@PROBE_EXIT@@": probe_exit,
            "@@PARAMS@@": params_block(),
            "@@TIMING_PARAMS@@": timing_params_block()}

    def subst(tpl):
        for k, v in repl.items():
            tpl = tpl.replace(k, v)
        assert "@@" not in tpl, "unsubstituted TCL token"
        assert "\\" not in tpl, "backslash in TCL text"
        return tpl

    tcl_path = os.path.join(tmp, "impl.tcl")
    write(tcl_path, subst(TCL))

    print("---- impl board : %s (synth=%s place=%s) ----" % (TOP, directive, placement),
          flush=True)
    rc, seen = run_vivado(tcl_path, tmp_mark, TIMEOUT)

    prefix = "impl_board_top_%s" % (tag or "run")
    write(os.path.join(RESULTS, prefix + ".tcl"), subst(TCL))
    got = []
    for rf in REPORTS:
        srcp = os.path.join(tmp, "rpt", rf)
        if os.path.exists(srcp):
            shutil.copy2(srcp, os.path.join(RESULTS, prefix + "_" + rf))
            got.append(rf)
    if os.path.exists(tmp_bit):
        shutil.copy2(tmp_bit, os.path.join(RESULTS, prefix + ".bit"))
        got.append("bit")
    print("  reports: %s" % (got or "NONE"), flush=True)
    return summarise(tmp)


def summarise(tmp):
    out = {}
    for tag, fname in (("synth", "pre_route_timing.rpt"),
                       ("impl", "post_route_timing.rpt")):
        tp = os.path.join(tmp, "rpt", fname)
        if not os.path.exists(tp):
            continue
        txt = io.open(tp, encoding="utf-8", errors="replace").read()
        s = re.search(r"Setup\s*:\s*(\d+)\s+Failing Endpoints,\s*"
                      r"Worst Slack\s*(-?[\d.]+)ns,\s*Total Violation\s*"
                      r"(-?[\d.]+)ns", txt)
        if s:
            wns = float(s.group(2))
            out[tag + "_wns"] = wns
            out[tag + "_setup_fails"] = int(s.group(1))
            out[tag + "_tns"] = float(s.group(3))
            denom = 10.0 - wns
            out[tag + "_fmax_mhz"] = (1000.0 / denom if denom > 0 else 0.0)
        h = re.search(r"Hold\s*:\s*(\d+)\s+Failing Endpoints,\s*"
                      r"Worst Slack\s*(-?[\d.]+)ns", txt)
        if h:
            out[tag + "_whs"] = float(h.group(2))
            out[tag + "_hold_fails"] = int(h.group(1))
    up = os.path.join(tmp, "rpt", "util.rpt")
    if os.path.exists(up):
        ut = io.open(up, encoding="utf-8", errors="replace").read()
        want = ["Slice LUTs", "LUT as Logic", "LUT as Memory", "Slice Registers",
                "Block RAM Tile", "DSPs"]
        for ln in ut.splitlines():
            for w in want:
                if w in ln:
                    nums = re.findall(r"[\d,]+", ln)
                    if nums:
                        out["util_" + w.replace(" ", "_")] = nums[0].replace(",", "")
                        break
    return out


if __name__ == "__main__":
    tag = sys.argv[1] if len(sys.argv) > 1 else "t75a"
    r = run(tag=tag)
    print("---- board summary ----")
    for k in sorted(r or {}):
        print("  %-28s %s" % (k, r[k]))
