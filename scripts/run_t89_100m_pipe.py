#!/usr/bin/env python3
"""Task #89 Route C: re-run the whole-KEM 100 MHz implementation with the
PIPELINED basemul (kyber_basemul, systolic 6-stage, integrated into
rtl/core/kyber_poly.v).

t89c100 (pre-pipeline accumulate only) showed pre-route WNS = -31.593 ns with
the worst path still in basemul (poly_b_reg -> poly_r_reg, ~41.6 ns).  This run
closes the multiply/reduce chain itself via 2-3 extra pipeline stages, and is
the definitive Route C 100 MHz closure test.

New tag t89d100 -> fresh tmp dir (same tag would overwrite the tmp dir).
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

print("launching board_top implementation BOARD_CLK_DIV=1 tag=t89d100 (pipelined basemul)", flush=True)
res = ibt.run(tag="t89d100")
print("---- t89d100 summary ----", flush=True)
for k in sorted(res or {}):
    print("  %-28s %s" % (k, res[k]), flush=True)
