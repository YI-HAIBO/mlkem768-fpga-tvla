#!/usr/bin/env python3
"""Route C step 4 (probe): pre-route timing probe for the v_poly pipelined KEM.

t89f100 revealed that the congestion subdirective
`-subdirective {GPlace.ReduceCongestion.high DPlace.ReducePinDensity.high}`
is NOT supported on the 7-series part xc7a100tcsg324-1
([Vivado_Tcl 4-2310] The option -subdirective is not supported for part ...).
So we drop the subdirective and use plain `place_design -directive Explore`.

IMPL_PROBE_ONLY=1 stops after place + pre-route timing + pre-route util, so we
learn whether the datapath closes 100 MHz (pre-route WNS) WITHOUT burning an
hour on route_design.  If the probe shows closure, launch the full route run.
"""
import os, sys
HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
PROJ = os.path.abspath(os.path.join(HERE, ".."))
sys.path.insert(0, PROJ)
sys.path.insert(0, os.path.join(PROJ, "scripts"))

import impl_board_top as ibt

os.environ["BOARD_CLK_DIV"] = "1"
os.environ["IMPL_PROBE_ONLY"] = "1"

if __name__ == "__main__":
    print("launching board_top BOARD_CLK_DIV=1 tag=t89g probe "
          "placement=Explore (no subdirective)", flush=True)
    res = ibt.run(tag="t89g", directive="default", placement="Explore",
                  placement_sub="")
    print("---- t89g probe summary ----", flush=True)
    for k, v in (res or {}).items():
        print("  %-28s %s" % (k, v), flush=True)
