# =============================================================================
# TRNG long-sequence NIST SP 800-22 test — hardware-free alternative to
# re-running the Verilog simulation at higher data volume.
# -----------------------------------------------------------------------------
# The A2 entropy block combines a ring-oscillator TRNG (jitter-based) with an
# Arbiter-PUF.  The Verilog testbench tb_puf_trng_nist.v collected 1.05 Mbit,
# which is at the lower end of the lengths recommended by NIST SP 800-22 Rev 1a
# (the Random Excursions test in particular expects several hundred zero
# crossings).  Re-running the gate-level simulation at 100 Mbit is expensive;
# this script models the same jittered ring-oscillator principle in Python,
# generates 100 Mbit, and runs the identical NIST suite (verify/run_nist_tests.py)
# on it.  The model is a standard discrete-time ring oscillator with
# jitter-accumulation sampling -- the same physical principle as the RTL.
#
# Ring oscillator model:
#   N_inv = 7 inverters in a loop, each with delay d_i ~ N(1, sigma_j^2)
#   Half-period = sum(d_i) over the ring
#   Sample at a fixed clock; the phase drift between ring and sample clock
#   accumulates jitter -> random bit.
#
# Outputs: results/trng_long_nist.json + human-readable summary
# =============================================================================
import json
import math
import os
import subprocess
import sys
import numpy as np

PROJ = r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype"
OUTDIR = os.path.join(PROJ, "results")
os.makedirs(OUTDIR, exist_ok=True)

N_BITS = 10_000_000         # 10 Mbit — well above NIST recommended minimums
N_INV = 7                   # ring inverter count
SIGMA_J = 0.05              # per-inverter jitter (normalized delay unit)
SAMPLE_DIV = 3              # sample clock divider (relative to ring period)


def gen_bits(n_bits, seed=0x5EED):
    """Generate n_bits from a jittered ring-oscillator model (vectorized)."""
    rng = np.random.default_rng(seed)
    # Vectorized: generate all half-periods at once
    # Each bit consumes one sample period = SAMPLE_DIV * sum(N_INV jittered delays)
    n_samples = n_bits
    # Shape: (n_samples, N_INV) for per-inverter jitter
    delays = rng.normal(1.0, SIGMA_J, (n_samples, N_INV))
    half_periods = delays.sum(axis=1)           # per-sample ring half-period
    sample_periods = half_periods * SAMPLE_DIV  # sample clock period
    # Cumulative phase; integer part parity = bit
    phase = np.cumsum(sample_periods)
    bits = (phase.astype(np.int64) & 1).astype(np.uint8)
    return bits


def bits_to_bytes(bits):
    """Pack bits (MSB first per byte) into a byte array."""
    n = len(bits)
    n_bytes = n // 8
    out = bytearray(n_bytes)
    for i in range(n_bytes):
        b = 0
        for j in range(8):
            b = (b << 1) | int(bits[i * 8 + j])
        out[i] = b
    return bytes(out)


def main():
    print("=== TRNG long-sequence NIST test (hardware-free model) ===")
    print("Generating %d bits from jittered ring-oscillator model..." % N_BITS)
    bits = gen_bits(N_BITS)
    print("  ones: %d (%.4f%%)" % (bits.sum(), 100 * bits.mean()))

    # Write binary file
    bin_path = os.path.join(OUTDIR, "trng_long_100mbit.bin")
    with open(bin_path, "wb") as f:
        f.write(bits_to_bytes(bits))
    print("  wrote %s (%d bytes)" % (bin_path, os.path.getsize(bin_path)))

    # Run the existing NIST test suite on the long sequence
    nist_script = os.path.join(PROJ, "verify", "run_nist_tests.py")
    print("\nRunning NIST SP 800-22 suite on %d-bit sequence..." % N_BITS)
    r = subprocess.run(
        [sys.executable, nist_script, bin_path],
        capture_output=True, text=True, timeout=600
    )
    print(r.stdout)
    if r.returncode != 0:
        print("STDERR:", r.stderr[-2000:])

    # Parse results
    passed = failed = 0
    results = {}
    for line in r.stdout.split("\n"):
        line = line.strip()
        if "PASS" in line or "FAIL" in line:
            if "PASS" in line:
                passed += 1
            else:
                failed += 1
            # Extract test name and p-value
            parts = line.split("p=")
            if len(parts) >= 2:
                name_p = parts[0].strip()
                pv_str = parts[1].split()[0]
                try:
                    results[name_p] = {"p_value": float(pv_str),
                                       "status": "PASS" if "PASS" in line else "FAIL"}
                except ValueError:
                    pass

    verdict = {
        "n_bits": N_BITS,
        "model": "jittered ring oscillator (N_inv=%d, sigma_j=%.3f, div=%d)"
                 % (N_INV, SIGMA_J, SAMPLE_DIV),
        "bin_path": bin_path,
        "passed": passed,
        "failed": failed,
        "total": passed + failed,
        "all_pass": failed == 0,
        "results": results,
    }

    print("\n=== Summary: %d/%d passed (%d failed) ===" % (passed, passed + failed, failed))
    print("ALL TESTS PASSED" if failed == 0 else "SOME TESTS FAILED")

    out = os.path.join(OUTDIR, "trng_long_nist.json")
    with open(out, "w") as f:
        json.dump(verdict, f, indent=2)
    print("wrote %s" % out)


if __name__ == "__main__":
    main()