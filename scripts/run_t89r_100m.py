#!/usr/bin/env python3
"""t89q pre-route closure confirmed (+0.501 ns, 0 setup fails @100 MHz).
Full implementation (synth + place + ROUTE + post-route timing + bitstream)
with the identical Explore placement used by the successful t89q3 probe, so
the post-route number is directly comparable to the placed pre-route number.
BOARD_CLK_DIV=1 puts the whole KEM datapath on the 100 MHz crystal."""
import os, sys
HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
PROJ = os.path.abspath(os.path.join(HERE, ".."))
sys.path.insert(0, PROJ)
sys.path.insert(0, os.path.join(PROJ, "scripts"))

import impl_board_top as ibt

os.environ["BOARD_CLK_DIV"] = "1"

# t89r100c timed out at 3601s mid-route (Phase 5.2 Global Iteration 1, router
# was converging: overlaps 51130 -> 2027); t89r100f reached Phase 5.3 Global
# Iteration 2 (overlaps 48912 -> 4920, still descending) before the 7200s
# budget bit.  The default router on this 82%-LUT congested netlist needs
# ~2.5-3.5 h.  Give route_design a 4h budget.
ibt.TIMEOUT = 14400

if __name__ == "__main__":
    tag = sys.argv[1] if len(sys.argv) > 1 else "t89r100"
    # Optional argv[2]: route_design directive ("Quick"/"default"/"").
    # Legacy "cong" is ignored: -subdirective is NOT supported for
    # xc7a100tcsg324-1 (t89r100e died at place_design with Tcl 4-2310).
    RD = sys.argv[2] if len(sys.argv) > 2 else ""
    if RD == "cong":
        RD = ""
    print("launching FULL impl board_top BOARD_CLK_DIV=1 tag=%s "
          "placement=Explore route=%r (route included)"
          % (tag, RD or "default"), flush=True)
    res = ibt.run(tag=tag, directive="default", placement="Explore",
                  placement_sub="",
                  route_directive=("-directive %s" % RD if RD else ""))
    print("---- %s full-run summary ----" % tag, flush=True)
    for k, v in (res or {}).items():
        print("  %-28s %s" % (k, v), flush=True)
