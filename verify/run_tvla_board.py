# -*- coding: utf-8 -*-
"""Compile + simulate sim/tb_board_top_tvla.v (Path A integration proof)."""
import os, subprocess, sys, time, shutil, tempfile

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
CORE = os.path.join(ROOT, "rtl", "core")
REAL = os.path.join(ROOT, "rtl", "real")
RTL  = os.path.join(ROOT, "rtl")
SIM  = os.path.join(ROOT, "sim")
IV   = r"C:\iverilog\bin\iverilog.exe"
VVP  = r"C:\iverilog\bin\vvp.exe"

CORE_FILES = ["kyber_kem.v", "kyber_poly.v", "kyber_ntt.v", "kyber_sampler.v",
              "shake.v", "keccak_perm.v"]


def run(timeout=900):
    sources = ([os.path.join(CORE, f) for f in CORE_FILES]
               + [os.path.join(RTL, "ipx_aoi_sec_board_top.v"),
                  os.path.join(REAL, "tvla_online.v"),
                  os.path.join(REAL, "tvla_probe_router.v")])
    tb = os.path.join(SIM, "tb_board_top_tvla.v")
    tmpdir = tempfile.mkdtemp(prefix="tvla_board_")
    vvp = os.path.join(tmpdir, "tb.vvp")
    try:
        cmd = [IV, "-g2012", "-o", vvp] + sources + [tb]
        p = subprocess.run(cmd, capture_output=True, timeout=timeout)
        se = p.stderr.decode("utf-8", "replace")
        if p.stdout.strip(): print(p.stdout.decode("utf-8", "replace").strip())
        if se.strip(): print("[compile stderr]", se.strip())
        if p.returncode != 0:
            print("COMPILE FAILED rc=%d" % p.returncode); return False
        print("COMPILE OK")
        p2 = subprocess.run([VVP, "tb.vvp"], capture_output=True,
                            timeout=timeout, cwd=tmpdir)
        so = p2.stdout.decode("utf-8", "replace")
        se2 = p2.stderr.decode("utf-8", "replace")
        print(so)
        if se2.strip(): print("[run stderr]", se2.strip())
        return "TVLA_BOARD_INTEGRATION PASS" in so
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


if __name__ == "__main__":
    ok = run()
    print("\n" + ("ALL OK" if ok else "FAILED"))
    sys.exit(0 if ok else 1)
