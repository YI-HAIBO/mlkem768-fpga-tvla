#!/usr/bin/env python3
"""Plan A: phys_opt_design + route from the placed checkpoint, zero RTL change.

Same CLI as route_from_dcp.py so it can be launched by supervise_route.py.
phys_opt_design replicates high-fanout registers (e.g. rn_data_reg[9], fo=73)
and retimes to shorten the long register->RAM write routes that caused the
-1.415 ns post-route WNS at 100 MHz.

Usage:
    python scripts/route_physopt.py <placed.dcp> <tag> [directive] [timeout]
"""
import os, sys, time, shutil, io

WORKSPACE = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14"
PROJECT   = os.path.join(WORKSPACE, "调研FPGA大模型安全", "研发", "ipx_aoi_fpga_prototype")
RESULTS   = os.path.join(PROJECT, "results")

sys.path.insert(0, PROJECT)
sys.path.insert(0, os.path.join(PROJECT, "scripts"))
import impl_board_top as ibt

ibt.MARKS.update({
    "00_start":       "vivado started",
    "10_open_dcp":    "placed checkpoint opened",
    "20_physopt_done": "phys_opt_design finished",
    "40_route_done":  "route_design finished",
    "50_post_timing": "post-route timing reported",
    "55_post_util":   "post-route utilization reported",
    "60_drc":         "report_drc finished",
    "70_bitstream":   "write_bitstream finished",
})

# phys_opt directive knob: "" = default; e.g. "AggressiveExplore".
PHYSOPT_DIRECTIVE = os.environ.get("PHYSOPT_DIRECTIVE", "")
# extra phys_opt flags from env, e.g. "-force_replication_on_nets".
PHYSOPT_EXTRA = os.environ.get("PHYSOPT_EXTRA", "")

# Plan A target: the 16 high-fanout register->distributed-RAM write-data nets
# that dominate the post-route WNS (-1.415 ns @ 100 MHz).  Each
# u_kem/rn_data[i] (i=0..15) is driven by u_kem/rn_data_reg[i] with fo=73
# (1 driver + 73 RAMD64E write-data loads).  Replicating these drivers is the
# ONLY phys_opt optimization that bypasses the "no negative slack -> skip"
# gate (the placed design has pre-route WNS=+0.501 ns, so default/directive
# phys_opt is a NO-OP).  Override the index list with PHYSOPT_REPL.
PHYSOPT_REPL = os.environ.get(
    "PHYSOPT_REPL",
    "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15")


def build_physopt_cmd():
    """Return the phys_opt_design command line (Tcl) for Plan A."""
    repl = PHYSOPT_REPL.strip()
    if repl:
        idx = [x.strip() for x in repl.split(",") if x.strip()]
        nets = " ".join("u_kem/rn_data[%s]" % i for i in idx)
        # get_nets is evaluated inside Vivado Tcl; braces keep the names literal.
        return "phys_opt_design -force_replication_on_nets [get_nets {%s}]" % nets
    physopt_cmd = "phys_opt_design"
    if PHYSOPT_DIRECTIVE:
        physopt_cmd += " -directive %s" % PHYSOPT_DIRECTIVE
    if PHYSOPT_EXTRA:
        physopt_cmd += " %s" % PHYSOPT_EXTRA.strip()
    return physopt_cmd

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

# Plan A: phys_opt_design to shorten the long register->RAM write routes.
# Default includes high-fanout register replication; knob for more aggression.
@@PHYSOPT_CMD@@
mk 20_physopt_done

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


def route_physopt(dcp, tag, route_directive="", timeout=7200):
    if not route_directive or route_directive == "default":
        rd = ""
    else:
        rd = "-directive %s" % route_directive
    physopt_cmd = build_physopt_cmd()
    stamp = time.strftime("%Y%m%d_%H%M%S")
    tmp   = "C:/tmp_impl_board_physopt-%s_%s" % (tag.replace("_", "-") or "route", stamp)
    tmp_mark = os.path.join(tmp, "mark")
    tmp_bit  = os.path.join(tmp, "board.bit")
    os.makedirs(tmp_mark, exist_ok=True)

    fs = lambda s: s.replace("\\", "/")
    repl = {"@@PROJ@@": fs(tmp), "@@DCP@@": fs(dcp),
            "@@MARK@@": fs(tmp_mark), "@@BIT@@": fs(tmp_bit),
            "@@ROUTE_DIRECTIVE@@": rd,
            "@@PHYSOPT_CMD@@": physopt_cmd,
            "@@PARAMS@@": ibt.params_block(),
            "@@TIMING_PARAMS@@": ibt.timing_params_block()}
    tcl = TCL
    for k, v in repl.items():
        tcl = tcl.replace(k, v)
    assert "@@" not in tcl and "\\" not in tcl

    tcl_path = os.path.join(tmp, "route.tcl")
    ibt.write(tcl_path, tcl)
    print("---- physopt+route: %s (dcp=%s directive=%s physopt=%s) ----"
          % (tag, dcp, rd or "default", physopt_cmd), flush=True)
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


class _Tee(object):
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
        print("route_physopt start: tag=%s dcp=%s directive=%s timeout=%s physopt=%s"
              % (tag, dcp, directive or "default", timeout,
                 build_physopt_cmd()), flush=True)
        res, rc = route_physopt(dcp, tag, directive, timeout)
        print("---- %s physopt+route summary (rc=%d) ----" % (tag, rc), flush=True)
        for k, v in (res or {}).items():
            print("  %-28s %s" % (k, v), flush=True)
    except SystemExit:
        raise
    except Exception:
        print("FATAL traceback:\n" + traceback.format_exc(), flush=True)
        sys.exit(1)
