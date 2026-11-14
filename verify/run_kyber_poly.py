"""Compile + simulate sim/tb_kyber_poly.v (kyber_poly + kyber_ntt + kyber_basemul + kyber_sampler).

Bypasses the broken bash shim (dirname/cd/head missing) by shelling out through
Python subprocess with absolute paths only.

IMPORTANT: The project path contains Chinese characters that iverilog/vvp cannot
handle in $readmemh relative-path resolution. Workaround: copy the vvp and the
golden hex files to an ASCII-only temp directory, set cwd there, and run vvp.
"""
import os, subprocess, sys, time, shutil, tempfile

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
RTL  = os.path.join(ROOT, "rtl", "core")
SIM  = os.path.join(ROOT, "sim")
IV   = r"C:\iverilog\bin\iverilog.exe"
VVP  = r"C:\iverilog\bin\vvp.exe"

# RTL sources required by tb_kyber_poly.v
RTL_FILES = ["kyber_poly.v", "kyber_ntt.v", "kyber_sampler.v"]
TB = "tb_kyber_poly.v"
HEX_FILES = ["gold_a.hex", "gold_b.hex", "gold_add.hex", "gold_sub.hex",
             "gold_mul.hex", "gold_sbytes.hex", "gold_samp.hex"]

def run(tb_rel, timeout=900):
    tb = os.path.join(SIM, tb_rel)
    if not os.path.exists(tb):
        tb = os.path.join(HERE, tb_rel)
    sources = [os.path.join(RTL, f) for f in RTL_FILES]

    # ASCII-only temp dir so vvp's $readmemh can resolve sim/gold_*.hex
    tmpdir = tempfile.mkdtemp(prefix="kyber_tb_")
    sim_dir = os.path.join(tmpdir, "sim")
    os.makedirs(sim_dir, exist_ok=True)
    tmp_vvp = os.path.join(tmpdir, "tb_kyber_poly.vvp")

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

        # Copy golden hex files to temp dir (vvp already there)
        for hf in HEX_FILES:
            src = os.path.join(SIM, hf)
            if os.path.exists(src):
                shutil.copy2(src, os.path.join(sim_dir, hf))
            else:
                print("  WARN: missing hex", hf, flush=True)

        print("\nRUN:", os.path.basename(tb_rel), flush=True)
        print("  cwd:", tmpdir, flush=True)
        t0 = time.time()
        p2 = subprocess.run([VVP, "tb_kyber_poly.vvp"], capture_output=True,
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
    ok = run(TB)
    print("\n" + ("ALL OK" if ok else "FAILED"), flush=True)
