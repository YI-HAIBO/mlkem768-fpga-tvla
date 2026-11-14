#!/usr/bin/env python3
"""Route-only retry of the 100 MHz board_top from a placed checkpoint.

The host's other project (uov sweep, xc7a200t) launches vivado.exe at
irregular intervals with a GLOBAL taskkill, which kills our route_design
mid-run.  A full attempt costs ~20 min of synth+place before route even
starts; this script opens the placed.dcp saved by impl_board_top.run() and
redoes ONLY route_design + post-route reports + bitstream, so each retry
costs route time alone (~15-50 min depending on directive).

Usage:
    python scripts/route_from_dcp.py <placed.dcp> <tag> [directive] [timeout]

directive: "" / "default" (full router) or "Quick" (fewer iterations, fits a
shorter kill-free window).  timeout defaults to 7200 s.
Reports land in results/impl_board_top_<tag>_<report>.rpt (+ .bit).
"""
import os, sys, time, shutil, io, re

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
RESULTS   = os.path.join(PROJECT, "results")

sys.path.insert(0, PROJECT)
sys.path.insert(0, os.path.join(PROJECT, "scripts"))
import impl_board_top as ibt

ibt.MARKS.update({
    "00_start":      "vivado started",
    "10_open_dcp":   "placed checkpoint opened",
    "40_route_done": "route_design finished",
    "50_post_timing": "post-route timing reported",
    "55_post_util":  "post-route utilization reported",
    "60_drc":        "report_drc finished",
    "70_bitstream":  "write_bitstream finished",
})

TCL = """\
@@PARAMS@@
set PROJ "@@PROJ@@"
set DCP  "@@DCP@@"
set RPT  "$PROJ/rpt"
set MARK "@@MARK@@"
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

open_checkpoint $DCP
mk 10_open_dcp

# route single-threaded (see impl_board_top.py: route_design died in Phase
# 5.1 Global Iteration 0 with 27898 overlaps under multi-threaded routing).
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


def route_run(dcp, tag, route_directive="", timeout=7200):
    if not route_directive or route_directive == "default":
        rd = ""
    else:
        rd = "-directive %s" % route_directive
    stamp    = time.strftime("%Y%m%d_%H%M%S")
    tmp      = "C:/tmp_impl_board_route-%s_%s" % (tag.replace("_", "-") or "route", stamp)
    tmp_mark = os.path.join(tmp, "mark")
    tmp_bit  = os.path.join(tmp, "board.bit")
    os.makedirs(tmp_mark, exist_ok=True)

    fs = lambda s: s.replace("\\", "/")  # os.path.join injects backslashes
    repl = {"@@PROJ@@": fs(tmp), "@@DCP@@": fs(dcp),
            "@@MARK@@": fs(tmp_mark), "@@BIT@@": fs(tmp_bit),
            "@@ROUTE_DIRECTIVE@@": rd,
            "@@PARAMS@@": ibt.params_block(),
            "@@TIMING_PARAMS@@": ibt.timing_params_block()}
    tcl = TCL
    for k, v in repl.items():
        tcl = tcl.replace(k, v)
    assert "@@" not in tcl and "\\" not in tcl

    tcl_path = os.path.join(tmp, "route.tcl")
    ibt.write(tcl_path, tcl)
    print("---- route-only: %s (dcp=%s directive=%s) ----"
          % (tag, dcp, rd or "default"), flush=True)
    rc, seen = ibt.run_vivado(tcl_path, tmp_mark, timeout)

    prefix = "impl_board_top_%s" % (tag or "route")
    got = []
    for rf in ("post_route_timing.rpt", "util.rpt", "drc.rpt"):
        srcp = os.path.join(tmp, "rpt", rf)
        if os.path.exists(srcp):
            shutil.copy2(srcp, os.path.join(RESULTS, prefix + "_" + rf))
            got.append(rf)
    if os.path.exists(tmp_bit):
        shutil.copy2(tmp_bit, os.path.join(RESULTS, prefix + ".bit"))
        got.append("bit")
    print("  reports: %s" % (got or "NONE"), flush=True)
    return ibt.summarise(tmp), rc


def wns_of(tag):
    """Parse the post-route WNS line from a copied results report, if any."""
    p = os.path.join(RESULTS, "impl_board_top_%s_post_route_timing.rpt" % tag)
    if not os.path.exists(p):
        return None
    txt = io.open(p, encoding="utf-8", errors="replace").read()
    s = re.search(r"Setup\s*:\s*(\d+)\s+Failing Endpoints,\s*"
                  r"Worst Slack\s*(-?[\d.]+)ns", txt)
    if not s:
        return None
    return (int(s.group(1)), float(s.group(2)))


class _Tee(object):
    """Tee stdout to a log in Temp so a detached (no-console) spawn is still
    monitorable: C:\\Users\\Yi\\AppData\\Local\\Temp\\route_<tag>.log."""

    def __init__(self, tag):
        self._orig = sys.stdout
        try:
            self._fh = io.open(
                r"C:\Users\Yi\AppData\Local\Temp\route_%s.log" % tag,
                "a", encoding="utf-8")
        except Exception:
            self._fh = None

    def write(self, s):
        try:
            self._orig.write(s)
        except Exception:
            pass
        if self._fh:
            try:
                self._fh.write(s)
                self._fh.flush()
            except Exception:
                pass

    def flush(self):
        try:
            self._orig.flush()
        except Exception:
            pass
        if self._fh:
            try:
                self._fh.flush()
            except Exception:
                pass


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(2)
    dcp = sys.argv[1]
    tag = sys.argv[2]
    sys.stdout = _Tee(tag)
    import traceback
    try:
        directive = sys.argv[3] if len(sys.argv) > 3 else ""
        timeout = int(sys.argv[4]) if len(sys.argv) > 4 else 7200
        if not os.path.exists(dcp):
            print("ERROR: checkpoint not found: %s" % dcp)
            sys.exit(1)
        print("route_from_dcp start: tag=%s dcp=%s directive=%s timeout=%s"
              % (tag, dcp, directive or "default", timeout), flush=True)
        res, rc = route_run(dcp, tag, directive, timeout)
        print("---- %s route-only summary (rc=%d) ----" % (tag, rc), flush=True)
        for k, v in (res or {}).items():
            print("  %-28s %s" % (k, v), flush=True)
    except SystemExit:
        raise
    except Exception:
        print("FATAL traceback:\n" + traceback.format_exc(), flush=True)
        sys.exit(1)
