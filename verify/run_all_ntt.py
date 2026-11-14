"""Run all three NTT verification suites and save their logs.

Usage:  python run_all_ntt.py
Writes: golden_sign_ntt.log, golden_kem_ntt.log, golden_sign_model.log
"""
import io, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
PY = sys.executable

TARGETS = [
    (["run_tb.py", "sim/tb_unified_ntt_sign.v"], "golden_sign_ntt.log"),
    (["run_tb.py", "sim/tb_unified_ntt.v"], "golden_kem_ntt.log"),
    ([ "verify_sign_model.py" ], "golden_sign_model.log"),
]

rc_all = 0
for args, log in TARGETS:
    cmd = [PY, os.path.join(HERE, args[0])] + list(args[1:])
    p = subprocess.run(cmd, capture_output=True, timeout=1800)
    txt = (p.stdout + p.stderr).decode("utf-8", "replace")
    n_pass = txt.count("PASS")
    n_fail = txt.count("FAIL:") + txt.count("VERDICT: FAIL")
    n_bad = txt.count("\ufffd")
    # the only non-ASCII text is the Chinese workspace path echoed by vvp at
    # $finish; keep the saved log pure ASCII
    txt = txt.replace("\ufffd", "?")
    with open(os.path.join(HERE, log), "w", encoding="utf-8", newline="\n") as fh:
        fh.write(txt)
    ok = (p.returncode == 0 and n_fail == 0 and n_pass > 0)
    rc_all |= 0 if ok else 1
    print("%-22s %6d B  PASS=%-3d FAIL=%d  mojibake=%d  rc=%d  %s"
          % (log, len(txt), n_pass, n_fail, n_bad, p.returncode,
             "OK" if ok else "PROBLEM"))
    print("-" * 72)
    print(txt)
    print("=" * 72)

print("OVERALL: %s" % ("ALL PASS" if rc_all == 0 else "SOME SUITE FAILED"))
sys.exit(rc_all)
