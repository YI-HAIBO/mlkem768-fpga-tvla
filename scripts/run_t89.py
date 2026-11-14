#!/usr/bin/env python3
"""Safe driver for the board-top implementation (Task #89) on a contested host.

The stock impl_board_top.py calls kill_orphan_vivados(), which issues a global
`taskkill /PID <first vivado.exe> /F`.  On this machine FIVE other projects run
Vivado simultaneously; killing theirs makes their runners kill ours in return,
which is exactly the "synth finished, 0% CPU, never advances" hang documented
in the vivado-batch-hang-and-fake-timing skill.  We monkeypatch the kill away
and rely on the unique tmp cwd + useElabCache/parallel-helper workarounds that
are already baked into the TCL.

Usage:
    python scripts/run_t89.py
"""
import importlib.util
import os

PROJ = r"C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype"
SPEC = os.path.join(PROJ, "scripts", "impl_board_top.py")

spec = importlib.util.spec_from_file_location("ibt", SPEC)
ibt = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ibt)

# Disable the global vivado kill that triggers mutual-kill hangs with the 5
# other Vivado projects on this host.
ibt.kill_orphan_vivados = lambda: None

print("launching board_top implementation (pipelines RTL) tag=t89b", flush=True)
res = ibt.run(tag="t89b")
print("---- t89b summary ----", flush=True)
for k in sorted(res or {}):
    print("  %-28s %s" % (k, res[k]), flush=True)
