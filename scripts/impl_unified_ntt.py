#!/usr/bin/env python3
"""
Full implementation flow (synth -> opt -> place -> route -> reports -> bitstream)
for rtl/core/unified_ntt.v. Extends scripts/synth_unified_ntt.py to answer:
does SIGN mode still meet 100 MHz *after* place & route, or only at synth level?

Adapted from synth_unified_ntt.py (2026-10-21). Same Windows/Tcl landmines apply:
  * Tcl double-quoted strings process backslash escapes -> forward-slash all paths
  * Vivado's stdout must not go through a pipe drained only at exit -> redirect
    to a file, poll markers for progress.

Usage:
    python scripts/impl_unified_ntt.py sign
    python scripts/impl_unified_ntt.py kem
    python scripts/impl_unified_ntt.py both

Reports land in results/impl_unified_ntt_<mode>_<report>.rpt
Run with `python -u` for live progress.
"""
import subprocess, os, sys, shutil, time, io, re

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
CORE      = os.path.join(PROJECT, "rtl", "core")
RESULTS   = os.path.join(PROJECT, "results")

VIVADO  = r"D:\FPGA\2026.1\Vivado\bin\vivado.bat"
PART    = "xc7a100tcsg324-1"
TIMEOUT = 3600      # per mode, seconds (impl is longer than synth)
DIRECTIVE = "default"
DUT     = "unified_ntt"

MODES = {
    "kem": ("unified_ntt_kem", dict(
        N=256, N_LAYERS=7, BW=16, Q=3329, QINV=62209,
        R_MOD=2285, SCALE_K=1441, BARRETT_M=20159, BARRETT_SH=26)),
    "sign": ("unified_ntt_sign", dict(
        N=256, N_LAYERS=8, BW=27, Q=8380417, QINV=58728449,
        R_MOD=131056, SCALE_K=49145, BARRETT_M=33587228, BARRETT_SH=48)),
}
PORT_ORDER = ["N", "N_LAYERS", "BW", "Q", "QINV", "R_MOD", "SCALE_K",
              "BARRETT_M", "BARRETT_SH"]

MARKS = {
    "00_start":        "vivado started",
    "10_project":      "project + sources + xdc loaded",
    "20_synth_done":   "synth_design finished",
    "25_opt_done":     "opt_design finished",
    "30_place_done":   "place_design finished",
    "35_presynth_util":"pre-route timing reported",
    "40_route_done":   "route_design finished",
    "50_post_timing":  "post-route timing reported",
    "55_post_util":    "post-route utilization reported",
    "60_drc":          "report_drc finished",
    "70_bitstream":    "write_bitstream finished",
}

REPORTS = ("pre_route_timing.rpt", "post_route_timing.rpt", "util.rpt", "drc.rpt")


def wrapper_src(wrap, p):
    bw = p["BW"]
    na = p["N_LAYERS"]
    l = lambda w: ("[%d:0]" % (w - 1)) if w > 1 else ""
    f = {"p_" + k: p[k] for k in PORT_ORDER}
    f["bz"] = "%d'b0" % bw
    return """\
`timescale 1ns / 1ps
`default_nettype none

module {wrap} (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire        inverse,
    output wire        busy,
    output wire        done,
    input  wire        load,
    input  wire [8:0]  load_addr,
    input  wire {bw}   load_data,
    output wire [8:0]  read_addr,
    output wire {bw}   read_data,
    input  wire        zeta_load,
    input  wire {na}   zeta_addr,
    input  wire {bw}   zeta_data
);

    // Runtime configuration interface (Task 76): tied off so the impl probe
    // synthesizes the parameter-only configuration.
    wire        cfg_tie_load = 1'b0;
    wire [2:0]  cfg_tie_addr = 3'd0;
    wire {bw}   cfg_tie_data = {bz};

    {dut} #(
        .N           ({p_N}),
        .N_LAYERS    ({p_N_LAYERS}),
        .BW          ({p_BW}),
        .Q           ({p_Q}),
        .QINV        ({p_QINV}),
        .R_MOD       ({p_R_MOD}),
        .SCALE_K     ({p_SCALE_K}),
        .BARRETT_M   ({p_BARRETT_M}),
        .BARRETT_SH  ({p_BARRETT_SH})
    ) u_ntt (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .inverse    (inverse),
        .busy       (busy),
        .done       (done),
        .load       (load),
        .load_addr  (load_addr),
        .load_data  (load_data),
        .read_addr  (read_addr),
        .read_data  (read_data),
        .zeta_load  (zeta_load),
        .zeta_addr  (zeta_addr),
        .zeta_data  (zeta_data),
        .cfg_load   (cfg_tie_load),
        .cfg_addr   (cfg_tie_addr),
        .cfg_data   (cfg_tie_data)
    );

endmodule
`default_nettype wire
""".format(dut=DUT, wrap=wrap, bw=l(bw), na=l(na), **f)


TCL = """\
# 2026-10-24: the synth helper processes (shared-memory IPC) are flaky on this
# host -- runs die silently mid-flow at a phase that moves between attempts,
# and orphan helpers from dead runs corrupt later runs.  Allowed values for
# synth.enableParallelHelperSpawn are all|none|linux|windows (NOT 0/1).
@@PARAMS@@
set PROJ "@@PROJ@@"
set RTL  "$PROJ/rtl"
set XDC  "$PROJ/one.xdc"
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
add_files "$RTL/unified_ntt.v"
add_files "$RTL/$TOP.v"
read_xdc $XDC
# Standalone probe: no board pinout, so NSTD-1/UCIO-1 are expected.  Without
# this waiver write_bitstream aborts ("Error(s) found during DRC") and the
# whole run exits rc=1 even though timing is clean.
set_property SEVERITY {Warning} [get_drc_checks {NSTD-1 UCIO-1}]
mk 10_project

synth_design -top $TOP -part $PART -directive @@DIRECTIVE@@
mk 20_synth_done

opt_design
mk 25_opt_done

place_design -directive @@PLACEMENT@@
mk 30_place_done

# Pre-route timing: tells us whether placement itself already broke timing
@@TIMING_PARAMS@@
report_timing_summary -file "$RPT/pre_route_timing.rpt" -delay_type min_max -max_paths 5
mk 35_pre_route_timing

route_design
mk 40_route_done

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


def kill_orphan_vivados():
    """Kill leftover vivado.exe processes before launching a new run.

    Each synth_design spawns helper children that own shared-memory segments;
    when a run dies the helpers survive as orphans, and their stale segments
    have been seen to corrupt the next run's IPC (silent rc=1 death mid-flow,
    2026-10-24).
    """
    import locale
    enc = locale.getpreferredencoding(False)
    for _ in range(10):
        out = subprocess.run(['tasklist', '/FI', 'IMAGENAME eq vivado.exe',
                              '/FO', 'CSV', '/NH'],
                             capture_output=True).stdout.decode(enc, 'replace').strip()
        pid = None
        for line in out.splitlines():
            for f in [f for f in line.split('"') if f.strip()]:
                if f.isdigit():
                    pid = f
                    break
            if pid:
                break
        if not pid:
            return
        subprocess.run(['taskkill', '/PID', pid, '/F'], capture_output=True)
        time.sleep(1)


def logtail(log_path, n=15):
    if not os.path.exists(log_path):
        print("  (no log at %s)" % log_path, flush=True)
        return
    try:
        lines = io.open(log_path, encoding="utf-8", errors="replace").read().splitlines()
    except OSError:
        print("  (cannot read log)", flush=True)
        return
    print("  ---- log tail (last %d of %d lines) ----" % (n, len(lines)), flush=True)
    for ln in lines[-n:]:
        print("   | " + ln[:170], flush=True)


def run_vivado(tcl_path, mark_dir, timeout):
    log_path = tcl_path.replace(".tcl", ".log")
    cmd = [VIVADO, "-mode", "batch", "-nojournal", "-log", log_path,
           "-source", tcl_path]
    # CRITICAL (2026-10-24): Vivado 2026.1 crashes with STATUS_HEAP_CORRUPTION
    # (rc=0xC0000374) during "Starting RTL Elaboration" whenever the *process
    # working directory* contains non-ASCII characters.  All project/report
    # paths below are already ASCII, but the inherited CWD of this script is
    # the Chinese project root; Vivado drops .Xil/Vivado-<pid>-<user>/ temp
    # files into the CWD and mangles the path at the MBCS boundary.  Run from
    # the ASCII scratch dir that already hosts the Tcl/log.
    ascii_cwd = os.path.dirname(os.path.abspath(tcl_path))
    print("  cmd: %s" % " ".join(cmd[:4]), flush=True)
    print("  cwd: %s" % ascii_cwd, flush=True)
    kill_orphan_vivados()
    t0 = time.time()
    seen = []
    p = subprocess.Popen(cmd, stdout=subprocess.DEVNULL,
                         stderr=subprocess.DEVNULL, cwd=ascii_cwd)
    while p.poll() is None:
        if time.time() - t0 > timeout:
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
                print("  [%5.0fs] %-24s %s"
                      % (time.time() - t0, MARKS.get(key, "?"), f), flush=True)
        time.sleep(5)
    rc = p.returncode
    print("  rc=%d  time=%.0fs  markers=%d/%d"
          % (rc, time.time() - t0, len(seen), len(MARKS)), flush=True)
    if rc != 0:
        logtail(log_path)
    return rc, seen


def params_block():
    """Vivado set_param preamble that keeps this host's flaky flow alive.

    Every line here was bought with a failed run on 2026-10-24:

    * synth.enableParallelHelperSpawn none -- synth helper children own
      shared-memory segments; orphaned helpers from dead runs corrupt the
      next run's IPC (silent rc=1 mid-flow).  Legal values are
      all|none|linux|windows (NOT 0/1).
    * synth.elaboration.useElabCache false -- with the cache on, runs hang
      after "Synthesis Optimization Runtime" and never print "Synthesis
      Optimization Complete" (t73a-t73d).

    Do NOT put general.maxThreads 1 here: KEM dies rc=1 inside
    "Cross Boundary and Area Optimization" when the whole flow is capped to
    one thread (t73f/t73g/t73h).  It belongs right before the timing reports
    only -- see timing_params_block().
    """
    return "\n".join([
        "catch {set_param synth.enableParallelHelperSpawn none}",
        "catch {set_param synth.elaboration.useElabCache false}",
    ])


def timing_params_block():
    """Cap threads for the timing engine only (applied just before reports).

    sign t73e died rc=1 inside report_timing_summary, stopped exactly at
    "Multithreading enabled for timing update using a maximum of 2 CPUs".
    Capping threads immediately before the report keeps synth/place/route
    parallel (KEM needs that) while dodging the timing-update crash.
    """
    if os.environ.get("IMPL_NO_MAXTHREADS"):
        return ""
    return "catch {set_param general.maxThreads 1}"


def run(mode, period=10.0, tag="", stamp=None):
    if stamp is None:
        stamp = time.strftime("%Y%m%d_%H%M%S")
    wrap, p = MODES[mode]
    tmp      = "C:/tmp_impl_%s_%s_%s" % (wrap, tag.replace("_", "-") or "run", stamp)
    tmp_rtl  = os.path.join(tmp, "rtl")
    tmp_mark = os.path.join(tmp, "mark")
    tmp_bit  = os.path.join(tmp, "impl.bit")
    for d in (tmp, tmp_rtl):
        os.makedirs(d, exist_ok=True)

    shutil.copy2(os.path.join(CORE, DUT + ".v"), os.path.join(tmp_rtl, DUT + ".v"))
    write(os.path.join(tmp_rtl, wrap + ".v"), wrapper_src(wrap, p))

    xdc = (
        "# standalone impl timing probe, generated by scripts/impl_unified_ntt.py\n"
        "create_clock -period %s [get_ports clk]\n"
        "set_clock_uncertainty 0.2 [get_clocks -of_objects [get_ports clk]]\n"
        "set_input_jitter [get_clocks -of_objects [get_ports clk]] 0.1\n"
        "set_false_path -from [get_ports rst_n]\n"
    ) % period
    write(os.path.join(tmp, "one.xdc"), xdc)

    fs = lambda s: s.replace("\\", "/")
    repl = {"@@PROJ@@": fs(tmp), "@@PART@@": PART, "@@TOP@@": wrap,
            "@@MARK@@": fs(tmp_mark), "@@BIT@@": fs(tmp_bit),
            "@@DIRECTIVE@@": DIRECTIVE, "@@PLACEMENT@@": "Explore",
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

    print("---- impl %s : %s ----" % (mode, wrap), flush=True)
    rc, seen = run_vivado(tcl_path, tmp_mark, TIMEOUT)

    prefix = "impl_unified_ntt_%s%s" % (mode, ("_" + tag) if tag else "")
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
    print("  reports: %s%s" % (got or "NONE",
          "" if rc is not None else "   (phase timed out, kept what existed)"),
          flush=True)

    return summarise(tmp, period)


def summarise(tmp, period):
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
            denom = period - wns
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
                "Register as Flip Flop", "DSPs", "Block RAM Tile", "BRAMs",
                "F7 Muxes", "F8 Muxes", "Bonded IOB"]
        for ln in ut.splitlines():
            for w in want:
                if w in ln:
                    nums = re.findall(r"[\d,]+", ln)
                    if nums:
                        out["util_" + w.replace(" ", "_").replace("(", "").replace(")", "")] = nums[0].replace(",", "")
                        break
    return out


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(2)
    which = sys.argv[1].lower()
    tag = sys.argv[2] if len(sys.argv) > 2 else ""
    for mode in (["kem", "sign"] if which == "both" else [which]):
        r = run(mode, tag=tag)
        print("---- %s summary ----" % mode)
        if not r:
            print("  (no timing data extracted)")
            continue
        for k in sorted(r):
            print("  %-28s %s" % (k, r[k]))
        print()
