"""Compile + simulate verify/tb_kyber_kem.v (kyber_kem KeyGen/Encaps/Decaps).

Same ASCII-temp-dir workaround as run_kyber_poly.py for Chinese path issues.
"""
import os, subprocess, sys, time, shutil, tempfile

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
RTL  = os.path.join(ROOT, "rtl", "core")
SIM  = os.path.join(ROOT, "sim")
IV   = r"C:\iverilog\bin\iverilog.exe"
VVP  = r"C:\iverilog\bin\vvp.exe"

RTL_FILES = ["kyber_kem.v", "kyber_poly.v", "kyber_ntt.v", "kyber_sampler.v",
             "shake.v", "keccak_perm.v"]
TB = "tb_kyber_kem.v"
HEX_FILES = ["kem_d0.hex", "kem_m0.hex", "kem_rho.hex", "kem_t0.hex",
             "kem_t1.hex", "kem_t2.hex", "kem_cu0.hex", "kem_cu1.hex",
             "kem_cu2.hex", "kem_cv.hex", "kem_ss.hex"]

def run(timeout=600):
    tb = os.path.join(HERE, TB)
    if not os.path.exists(tb):
        tb = os.path.join(SIM, TB)
    sources = [os.path.join(RTL, f) for f in RTL_FILES]

    tmpdir = tempfile.mkdtemp(prefix="kyber_kem_tb_")
    sim_dir = os.path.join(tmpdir, "sim")
    os.makedirs(sim_dir, exist_ok=True)
    tmp_vvp = os.path.join(tmpdir, "tb_kyber_kem.vvp")

    try:
        print("=" * 78, flush=True)
        print("COMPILE:", os.path.relpath(tb, ROOT), flush=True)
        print("=" * 78, flush=True)

        cmd = [IV, "-g2012", "-o", tmp_vvp] + sources + [tb]
        print("  src:", " ".join(os.path.relpath(s, ROOT) for s in sources), flush=True)
        t0 = time.time()
        p = subprocess.run(cmd, capture_output=True, timeout=timeout)
        dt = time.time() - t0
        so = p.stdout.decode("utf-8", errors="replace")
        se = p.stderr.decode("utf-8", errors="replace")
        if so.strip():
            print(so.strip(), flush=True)
        if se.strip():
            print("[compile stderr]", se.strip(), flush=True)
        if p.returncode != 0:
            print("COMPILE FAILED (rc=%d, %.1fs)" % (p.returncode, dt), flush=True)
            return False
        print("COMPILE OK in %.1fs" % dt, flush=True)

        for hf in HEX_FILES:
            src = os.path.join(SIM, hf)
            if os.path.exists(src):
                shutil.copy2(src, os.path.join(sim_dir, hf))
            else:
                print("  WARN: missing hex", hf, flush=True)

        print("\nRUN:", TB, flush=True)
        print("  cwd:", tmpdir, flush=True)
        t0 = time.time()
        p2 = subprocess.run([VVP, "tb_kyber_kem.vvp"], capture_output=True,
                            timeout=timeout, cwd=tmpdir)
        dt2 = time.time() - t0
        so2 = p2.stdout.decode("utf-8", errors="replace")
        se2 = p2.stderr.decode("utf-8", errors="replace")
        print(so2, flush=True)
        if se2.strip():
            print("[run stderr]", se2.strip(), flush=True)
        print("vvp rc=%d in %.1fs" % (p2.returncode, dt2), flush=True)
        return p2.returncode == 0
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)

if __name__ == "__main__":
    ok = run()
    print("\n" + ("ALL OK" if ok else "FAILED"), flush=True)
