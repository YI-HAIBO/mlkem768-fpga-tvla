"""Bash-shim-free runner: compile + simulate a unified_ntt testbench with iverilog.

Usage: run_tb.py <tb.v> [<tb.v> ...]
Runs each against rtl/core/unified_ntt.v with -g2012 and streams the simulation
output.  Bypasses the broken bash shim (dirname/cd/head missing) by shelling out
through Python subprocess with absolute paths only.
"""
import os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
RTL = os.path.join(ROOT, "rtl", "core", "unified_ntt.v")
IV   = r"C:\iverilog\bin\iverilog.exe"
VVP  = r"C:\iverilog\bin\vvp.exe"

def run(tb_rel, timeout=900):
    tb = os.path.join(ROOT, tb_rel)
    out_vvp = os.path.join(HERE, os.path.splitext(os.path.basename(tb_rel))[0] + ".vvp")
    print("=" * 78)
    print("COMPILE:", os.path.relpath(tb, ROOT))
    print("=" * 78)
    def _r(cmd, timeout=timeout):
        p = subprocess.run(cmd, capture_output=True, timeout=timeout)
        def dec(b):
            return b.decode("utf-8", errors="replace")
        return p.returncode, dec(p.stdout), dec(p.stderr)

    rc, so, se = _r([IV, "-g2012", "-o", out_vvp, RTL, tb])
    if so.strip():
        print(so.strip())
    if se.strip():
        print("[compile stderr]", se.strip())
    if rc != 0:
        print("COMPILE FAILED (rc=%d)" % rc)
        return False
    print("\nRUN:", os.path.basename(tb_rel))
    rc2, so2, se2 = _r([VVP, out_vvp])
    print(so2)
    if se2.strip():
        print("[run stderr]", se2.strip())
    print("vvp rc=%d" % rc2)
    return rc2 == 0

if __name__ == "__main__":
    tbs = sys.argv[1:] or ["sim/tb_unified_ntt.v", "sim/tb_unified_ntt_sign.v"]
    ok = True
    for tb in tbs:
        ok &= run(tb)
    print("\nALL OK" if ok else "\nSOME FAILED")
