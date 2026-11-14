#!/usr/bin/env python3
"""Generic pre-route timing probe runner: place + pre-route timing + util.

Usage:
    IMPL_PROBE_ONLY=1 python scripts/run_probe.py <tag>

place_design -directive Explore (no subdirective -- unsupported on xc7a100t).
BOARD_CLK_DIV=1 puts the whole KEM datapath on the 100 MHz crystal.
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
    tag = sys.argv[1] if len(sys.argv) > 1 else "probe"
    print("launching board_top BOARD_CLK_DIV=1 tag=%s probe placement=Explore"
          % tag, flush=True)
    res = ibt.run(tag=tag, directive="default", placement="Explore",
                  placement_sub="")
    print("---- %s probe summary ----" % tag, flush=True)
    for k, v in (res or {}).items():
        print("  %-28s %s" % (k, v), flush=True)
