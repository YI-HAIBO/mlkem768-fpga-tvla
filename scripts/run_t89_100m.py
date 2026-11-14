#!/usr/bin/env python3
"""Task #89 Route B: put the WHOLE KEM datapath on the 100 MHz crystal
(BOARD_CLK_DIV=1) and re-run the full implementation, to prove the pipelined
basemul accumulate path closes 100 MHz post-route.

Contrast with the earlier board runs: t75d (pre-pipeline, CLK_DIV=1) showed
20,346 setup violations with the basemul accumulate path at ~44 ns; the board
demo was therefore clocked at 12.5 MHz (t75e/f, t89a/b).  This run is the
definitive post-pipeline 100 MHz closure test.

The global vivado kill is disabled (host runs 5 other Vivado projects; see
scripts/run_t89.py for the rationale).

Usage:
    python scripts/run_t89_100m.py
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

print("launching board_top implementation BOARD_CLK_DIV=1 tag=t89c100", flush=True)
res = ibt.run(tag="t89c100")
print("---- t89c100 summary ----", flush=True)
for k in sorted(res or {}):
    print("  %-28s %s" % (k, res[k]), flush=True)
