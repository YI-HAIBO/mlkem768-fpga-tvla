# -*- coding: utf-8 -*-
"""Compile + simulate verify/tb_kyber_proxy.v, dump on-chip proxy streams.

Outputs (copied to results/):
  proxy_fixed.txt  -- fixed-secret group proxy samples
  proxy_rand.txt   -- random-secret group proxy samples (also G6 autocorrelation stream)
"""
import os, subprocess, sys, time, shutil, tempfile

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
CORE = os.path.join(ROOT, "rtl", "core")
SIM  = os.path.join(ROOT, "sim")
RES  = os.path.join(ROOT, "results")
IV   = r"C:\iverilog\bin\iverilog.exe"
VVP  = r"C:\iverilog\bin\vvp.exe"

RTL_FILES = ["kyber_kem.v", "kyber_poly.v", "kyber_ntt.v", "kyber_sampler.v",
             "shake.v", "keccak_perm.v"]
TB = os.path.join(HERE, "tb_kyber_proxy.v")
HEX_FILES = ["kem_d0.hex", "kem_m0.hex", "kem_rho.hex", "kem_t0.hex",
             "kem_t1.hex", "kem_t2.hex", "kem_cu0.hex", "kem_cu1.hex",
             "kem_cu2.hex", "kem_cv.hex", "kem_ss.hex"]


def run(timeout=1200):
    tmpdir = tempfile.mkdtemp(prefix="kyber_proxy_")
    sim_dir = os.path.join(tmpdir, "sim")
    os.makedirs(sim_dir, exist_ok=True)
    tmp_vvp = os.path.join(tmpdir, "tb_kyber_proxy.vvp")
    sources = [os.path.join(CORE, f) for f in RTL_FILES]
    try:
        cmd = [IV, "-g2012", "-o", tmp_vvp] + sources + [TB]
        print("COMPILE:", flush=True)
        p = subprocess.run(cmd, capture_output=True, timeout=timeout)
        so = p.stdout.decode("utf-8", "replace")
        se = p.stderr.decode("utf-8", "replace")
        if so.strip(): print(so.strip(), flush=True)
        if se.strip(): print("[compile stderr]", se.strip(), flush=True)
        if p.returncode != 0:
            print("COMPILE FAILED rc=%d" % p.returncode, flush=True); return False
        print("COMPILE OK", flush=True)

        for hf in HEX_FILES:
            src = os.path.join(SIM, hf)
            if os.path.exists(src):
                shutil.copy2(src, os.path.join(sim_dir, hf))
            else:
                print("  WARN missing hex", hf, flush=True)

        print("RUN:", flush=True)
        t0 = time.time()
        p2 = subprocess.run([VVP, "tb_kyber_proxy.vvp"], capture_output=True,
                            timeout=timeout, cwd=tmpdir)
        print(p2.stdout.decode("utf-8", "replace"), flush=True)
        if p2.stderr.decode("utf-8", "replace").strip():
            print("[run stderr]", p2.stderr.decode("utf-8", "replace").strip(), flush=True)
        print("vvp rc=%d in %.1fs" % (p2.returncode, time.time() - t0), flush=True)

        # copy outputs to results/
        for name in ["proxy_fixed.txt", "proxy_rand.txt"]:
            sp = os.path.join(tmpdir, name)
            if os.path.exists(sp):
                shutil.copy2(sp, os.path.join(RES, name))
                print("COPIED", os.path.join(RES, name),
                      os.path.getsize(os.path.join(RES, name)), "bytes", flush=True)
            else:
                print("MISSING", name, flush=True)
        return p2.returncode == 0
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


if __name__ == "__main__":
    ok = run()
    print("\n" + ("ALL OK" if ok else "FAILED"), flush=True)
    sys.exit(0 if ok else 1)
