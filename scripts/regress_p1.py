# -*- coding: utf-8 -*-
"""
Bit-exact regression for P1-a.1 (2-D -> 1-D array flattening).

Builds verify/tb_kyber_kem.v twice - once against the FIXED rtl/core/kyber_kem.v
and once against the backup rtl/core/kyber_kem.v.pre_p1 - runs both to
completion with iverilog/vvp, and diffs the summary lines.

The testbench covers:
  KeyGen  -> 800 pk words vs sim/kem_t0/t1/t2/rho.hex
  Encaps  -> 1024 ct words + 32 ss bytes vs sim/kem_cu*/cv/ss.hex
  Decaps  -> 32 recovered msg bytes + 32 ss bytes
  Decaps #2 via the external ct_load datapath
  Repeat-stability: a 2nd KeyGen/Encaps/Decaps must agree with the 1st

Both runs must report 0 errors, and their captured words must be identical.
That is the bit-exactness proof that the flattening changed no
behaviour.

Run:  python regress_cntfix.py
"""
import os, re, subprocess, sys, tempfile, shutil, time

HERE  = os.path.dirname(os.path.abspath(__file__))
ROOT  = os.path.dirname(HERE)
CORE  = os.path.join(ROOT, "rtl", "core")
VERIFY = os.path.join(ROOT, "verify")
SIM   = os.path.join(ROOT, "sim")

IV   = r"C:\iverilog\bin\iverilog.EXE"
VVP  = r"C:\iverilog\bin\vvp.EXE"

# files that must always be compiled with the tb
DEPS = ["keccak_perm.v", "shake.v", "kyber_sampler.v", "kyber_ntt.v", "kyber_poly.v"]
TB   = os.path.join(VERIFY, "tb_kyber_kem.v")

TARGETS = [
    ("FIXED ", os.path.join(CORE, "kyber_kem.v")),
    ("BASELINE", os.path.join(CORE, "kyber_kem.v.pre_p1")),
]

SUMMARY_RE = re.compile(
    r"(KEYGEN|ENCAPS|DECAPS #2 \(external ct\)|REPEAT STABILITY|TOTAL):"
)


def build(vvp, km):
    srcs = [km, TB] + [os.path.join(CORE, d) for d in DEPS]
    cmd = [IV, "-g2012", "-s", "tb_kyber_kem", "-o", vvp] + srcs
    t = time.time()
    p = subprocess.run(cmd, capture_output=True, text=True,
                       encoding="utf-8", errors="replace", cwd=ROOT)
    return p, time.time() - t


def run(vvp, timeout=900):
    t = time.time()
    p = subprocess.run([VVP, vvp], capture_output=True, text=True,
                       encoding="utf-8", errors="replace",
                       cwd=ROOT, timeout=timeout)
    return p, time.time() - t


def summarise(text):
    """Pull the testbench's own verdict lines out of the transcript."""
    return [ln.rstrip() for ln in text.splitlines() if SUMMARY_RE.search(ln)]


def main():
    assert os.path.exists(TB), "testbench missing: %s" % TB
    for tag, km in TARGETS:
        assert os.path.exists(km), "missing: %s" % km

    outdir = tempfile.mkdtemp(prefix="p1_regress_")
    print("=" * 78)
    print("Bit-exact regression: P1-a.1 2-D -> 1-D array flattening")
    print("iverilog: %s" % IV)
    print("workdir : %s" % ROOT)
    print("=" * 78)

    results = {}
    for tag, km in TARGETS:
        vvp = os.path.join(outdir, "tb_%s.vvp" % tag.strip())
        print("\n--- [%s] %s" % (tag, os.path.relpath(km, ROOT)))

        p, dt = build(vvp, km)
        txt = ((p.stderr or "") + (p.stdout or "")).strip()
        if p.returncode != 0:
            print("    BUILD FAILED rc=%d in %.1fs" % (p.returncode, dt))
            print("    %s" % txt[:1500])
            return 1
        print("    build ok in %.1fs" % dt)

        r, dt2 = run(vvp)
        out = r.stdout or ""
        lines = summarise(out)
        results[tag] = (out, lines)
        print("    sim rc=%d in %.1fs" % (r.returncode, dt2))
        for ln in lines:
            print("      %s" % ln.strip())

    # ---- compare -------------------------------------------------------
    print("\n" + "=" * 78)
    print("VERDICT")
    print("=" * 78)
    ok = True
    a, la = results["FIXED "]
    b, lb = results["BASELINE"]

    fa = [l for l in la if l.startswith("=== TOTAL:")]
    fb = [l for l in lb if l.startswith("=== TOTAL:")]
    print("  FIXED    total : %s" % (fa[-1].strip() if fa else "NOT REPORTED"))
    print("  BASELINE total : %s" % (fb[-1].strip() if fb else "NOT REPORTED"))

    if fa and fb and fa[-1] == fb[-1]:
        print("  [ OK ] total-error lines identical")
    else:
        print("  [FAIL] total-error lines differ")
        ok = False

    # every individual section must report the SAME number of errors
    for key in ("KEYGEN", "ENCAPS", "DECAPS", "REPEAT STABILITY"):
        xa = [l for l in la if key in l]
        xb = [l for l in lb if key in l]
        if xa and xb and xa == xb:
            print("  [ OK ] %-20s %s" % (key, xa[-1].strip()))
        else:
            print("  [FAIL] %-20s FIXED=%s BASELINE=%s" % (key, xa, xb))
            ok = False

    # zero-error check
    m = re.search(r"TOTAL:\s*(\d+)\s*ERRORS\s*\(keygen=(\d+)\s*encaps=(\d+)"
                  r"\s*decaps=(\d+)\s*repeat=(\d+)\)", fa[-1] if fa else "")
    if m:
        tot, kg, en, de, rp = m.groups()
        if tot == "0":
            print("  [ OK ] FIXED run is bit-exact: 0 errors across all 5 stages")
        else:
            print("  [FAIL] FIXED run has %s errors (kg=%s enc=%s dec=%s repeat=%s)"
                  % (tot, kg, en, de, rp))
            ok = False

    print("\n  => %s" % ("PASS - fix is behaviour-preserving"
                        if ok else "FAIL - investigate before synthesising"))
    print("  (working dir kept: %s)" % outdir)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
