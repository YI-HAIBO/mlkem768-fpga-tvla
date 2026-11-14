#!/usr/bin/env python3
"""Task #89 Route C step 2: congestion-mitigation re-run of the 100 MHz whole-KEM
implementation with the pipelined basemul, using a more aggressive placement
directive to try to let route_design converge.

t89d100 (pipelined basemul, place=Explore) still timed out in route (Route
35-447 congestion, 82% LUT utilisation on xc7a100t).  This run tests whether
`place_design -directive AggressiveExplore` (deeper placement search) clears
the congestion enough for route to finish, giving a real post-route WNS as the
baseline for the next timing step (fqmul/barrett multiply-chain segmentation).

New tag t89e100 -> fresh tmp dir.
"""
import importlib.util
import os

os.environ["BOARD_CLK_DIV"] = "1"

PROJ = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype"
SPEC = os.path.join(PROJ, "scripts", "impl_board_top.py")

spec = importlib.util.spec_from_file_location("ibt", SPEC)
ibt = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ibt)

ibt.kill_orphan_vivados = lambda: None

print("launching board_top BOARD_CLK_DIV=1 tag=t89e100 placement=AggressiveExplore", flush=True)
res = ibt.run(tag="t89e100", placement="AggressiveExplore")
print("---- t89e100 summary ----", flush=True)
for k in sorted(res or {}):
    print("  %-28s %s" % (k, res[k]), flush=True)
