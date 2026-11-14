"""Compile + simulate sim/tb_ipx_aoi_sec_board_top.v (Nexys 4 DDR board POST).

The board top is self-contained (hardcoded seed/message, no golden hex files):
a correct ML-KEM roundtrip is proven on-chip by Encaps.ss == Decaps.ss.

Same ASCII-temp-dir workaround as run_kyber_kem.py for Chinese path issues.
"""
import os, subprocess, sys, time, shutil, tempfile

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
RTL  = os.path.join(ROOT, "rtl", "core")
SIM  = os.path.join(ROOT, "sim")
IV   = r"C:\iverilog\bin\iverilog.exe"
VVP  = r"C:\iverilog\bin\vvp.exe"

# kyber_kem 及其依赖 + 板级顶层
RTL_FILES = ["kyber_kem.v", "kyber_poly.v", "kyber_ntt.v", "kyber_sampler.v",
             "shake.v", "keccak_perm.v"]
# Path A (v3.0): the on-chip Welch t-test engine is now a real leaf of the
# board-level netlist, so it must be compiled with the POST regression too.
TVLA_RTL  = os.path.join(ROOT, "rtl", "real", "tvla_online.v")
BOARD_TOP = os.path.join(ROOT, "rtl", "ipx_aoi_sec_board_top.v")
TB = "tb_ipx_aoi_sec_board_top.v"          # CLK_DIV=1 直通 (仿真全速)
TB_DIV8 = "tb_ipx_aoi_sec_board_top_div8.v"  # CLK_DIV=8 真实板级配置冒烟


def run(tb_name=TB, timeout=900):
    sources = [os.path.join(RTL, f) for f in RTL_FILES] + [BOARD_TOP, TVLA_RTL]
    tb = os.path.join(SIM, tb_name)
    if not os.path.exists(tb):
        tb = os.path.join(HERE, tb_name)

    tmpdir = tempfile.mkdtemp(prefix="board_top_tb_")
    tmp_vvp = os.path.join(tmpdir, "tb_board.vvp")

    try:
        print("=" * 78, flush=True)
        print("COMPILE: board_top + kyber_kem RTL +", tb_name, flush=True)
        print("=" * 78, flush=True)
        cmd = [IV, "-g2012", "-o", tmp_vvp] + sources + [tb]
        print("  src:", " ".join(os.path.relpath(s, ROOT) for s in sources),
              flush=True)
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

        print("\nRUN:", tb_name, flush=True)
        t0 = time.time()
        p2 = subprocess.run([VVP, "tb_board.vvp"], capture_output=True,
                            timeout=timeout, cwd=tmpdir)
        dt2 = time.time() - t0
        so2 = p2.stdout.decode("utf-8", errors="replace")
        se2 = p2.stderr.decode("utf-8", errors="replace")
        print(so2, flush=True)
        if se2.strip():
            print("[run stderr]", se2.strip(), flush=True)
        print("vvp rc=%d in %.1fs" % (p2.returncode, dt2), flush=True)
        ok = ("BOARD_POST PASS" in so2) and ("BOARD_POST RERUN PASS" in so2)
        return ok
    finally:
        shutil.rmtree(tmpdir, ignore_errors=True)


if __name__ == "__main__":
    # 无参数   -> CLK_DIV=1 直通快速全回归
    # div8     -> CLK_DIV=8 真实板级配置 (12.5 MHz) 冒烟
    tb = TB_DIV8 if (len(sys.argv) > 1 and sys.argv[1] == "div8") else TB
    ok = run(tb)
    print("\n" + ("ALL OK" if ok else "FAILED"), flush=True)
    sys.exit(0 if ok else 1)
