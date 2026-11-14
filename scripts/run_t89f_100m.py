#!/usr/bin/env python3
"""Route C step 3: v_poly pipeline + congestion mitigation at 100 MHz.
Uses the pipelined kyber_kem.v (7-stage flowing v_poly pipeline) with
BOARD_CLK_DIV=1 and an explicit congestion-reduction placement subdirective.
"""
import os, sys
HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
PROJ = os.path.abspath(os.path.join(HERE, ".."))
sys.path.insert(0, PROJ)
sys.path.insert(0, os.path.join(PROJ, "scripts"))

import impl_board_top as ibt

os.environ["BOARD_CLK_DIV"] = "1"

# Congestion subdirective from place_design -help (GPlace + DPlace pin density).
SUB = " -subdirective {GPlace.ReduceCongestion.high DPlace.ReducePinDensity.high}"

if __name__ == "__main__":
    print("launching board_top BOARD_CLK_DIV=1 tag=t89f100 placement=Explore+ReduceCongestion",
          flush=True)
    res = ibt.run(tag="t89f100", directive="default", placement="Explore",
                  placement_sub=SUB)
    print("---- t89f100 summary ----", flush=True)
    for k, v in (res or {}).items():
        print("  %-28s %s" % (k, v), flush=True)
