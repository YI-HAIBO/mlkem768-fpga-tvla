"""Compile + simulate sim/tb_kem_probe_integration.v (#6a probe datapath check).

Copies all RTL sources + TB into an ASCII temp dir (iverilog cannot handle the
Chinese project path), compiles with -g2012, simulates with vvp, prints report.
"""
import os, subprocess, time, shutil, tempfile

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
RTL_CORE = os.path.join(ROOT, "rtl", "core")
RTL_REAL = os.path.join(ROOT, "rtl", "real")
SIM = os.path.join(ROOT, "sim")
IV   = r"C:\iverilog\bin\iverilog.exe"
VVP  = r"C:\iverilog\bin\vvp.exe"

CORE_FILES = ["kyber_kem.v", "kyber_poly.v", "kyber_ntt.v", "kyber_sampler.v",
              "shake.v", "keccak_perm.v"]
REAL_FILES = ["tvla_online.v", "tvla_probe_router.v"]
TB = "tb_kem_probe_integration.v"


def run(timeout=900):
    tb = os.path.join(SIM, TB)
    if not os.path.exists(tb):
        tb = os.path.join(HERE, TB)

    tmpdir = tempfile.mkdtemp(prefix="kem_probe_")
    tmp_vvp = os.path.join(tmpdir, "tb.vvp")
    try:
        # copy all sources into ASCII tmpdir
        local = []
        for f in CORE_FILES:
            src = os.path.join(RTL_CORE, f)
            dst = os.path.join(tmpdir, f)
            shutil.copy2(src, dst)
            local.append(dst)
        for f in REAL_FILES:
            src = os.path.join(RTL_REAL, f)
            dst = os.path.join(tmpdir, f)
            shutil.copy2(src, dst)
            local.append(dst)
        local.append(os.path.join(tmpdir, TB))
        shutil.copy2(tb, os.path.join(tmpdir, TB))

        print("=" * 78, flush=True)
        print("COMPILE:", TB, flush=True)
        cmd = [IV, "-g2012", "-o", tmp_vvp] + local
        t0 = time.time()
        p = subprocess.run(cmd, capture_output=True, timeout=timeout)
        so = p.stdout.decode("utf-8", errors="replace")
        se = p.stderr.decode("utf-8", errors="replace")
        if so.strip():
            print(so.strip(), flush=True)
        if se.strip():
            print("[compile stderr]", se.strip(), flush=True)
        if p.returncode != 0:
            print("COMPILE FAILED rc=%d (%.1fs)" % (p.returncode, time.time() - t0), flush=True)
            return False
        print("COMPILE OK (%.1fs)" % (time.time() - t0), flush=True)

        print("\nRUN:", TB, flush=True)
        t0 = time.time()
        p2 = subprocess.run([VVP, "tb.vvp"], capture_output=True,
                            timeout=timeout, cwd=tmpdir)
        so2 = p2.stdout.decode("utf-8", errors="replace")
        se2 = p2.stderr.decode("utf-8", errors="replace")
        print(so2, flush=True)
        if se2.strip():
            print("[run stderr]", se2.strip(), flush=True)
        print("vvp rc=%d in %.1fs" % (p2.returncode, time.time() - t0), flush=True)
        return p2.returncode == 0
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


if __name__ == "__main__":
    ok = run()
    print("\n" + ("ALL OK" if ok else "FAILED"), flush=True)
