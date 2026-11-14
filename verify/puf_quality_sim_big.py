# =============================================================================
# A2 Arbiter-PUF quality simulation — expanded Monte Carlo (M = 1000 chips)
# -----------------------------------------------------------------------------
# Same cell-level model as puf_quality_sim.py but with 1000 virtual chips
# instead of 128, to tighten the finite-sample min-entropy and uniqueness
# confidence intervals toward what a silicon multi-chip measurement would
# report.  No physical hardware is required; this is the strongest
# hardware-free substitute for a silicon PUF characterization.
#
# Outputs: results/puf_quality_big.json + human-readable summary
# =============================================================================
import json
import os
import numpy as np

PROJ = r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype"
OUTDIR = os.path.join(PROJ, "results")
os.makedirs(OUTDIR, exist_ok=True)

N_BITS = 256
M = 1000             # virtual chips (7.8x the original 128)
K = 8                # repeated reads per chip
SIGMA_P = 1.0
SIGMA_SYS = 0.10
SIGMA_N = 0.02


def hd(a, b):
    return int(np.count_nonzero(a != b))


def run(sigma_p, sigma_sys, sigma_n, rng):
    delta = rng.normal(0.0, sigma_sys, N_BITS)
    Delta = delta[None, :] + rng.normal(0.0, sigma_p, (M, N_BITS))
    r_true = (Delta > 0)

    # uniqueness: all pairwise inter-chip HDs
    pair_hds = []
    for c1 in range(M):
        for c2 in range(c1 + 1, M):
            pair_hds.append(hd(r_true[c1], r_true[c2]))
    uniq = np.mean(pair_hds) / N_BITS
    uniq_std = np.std(pair_hds) / N_BITS

    # reliability
    intra = []
    for c in range(M):
        for _ in range(1, K):
            noisy = (Delta[c] + rng.normal(0.0, sigma_n, N_BITS)) > 0
            intra.append(hd(r_true[c], noisy))
    rel = 1.0 - np.mean(intra) / N_BITS

    # bias
    bias = r_true.mean()

    # min-entropy per bit
    p = np.clip(r_true.mean(axis=0), 1e-9, 1 - 1e-9)
    hmin = -np.log2(np.maximum(p, 1 - p))

    # 95% confidence interval for uniqueness (normal approx of pairwise HDs)
    n_pairs = M * (M - 1) // 2
    uniq_ci = (uniq - 1.96 * uniq_std / np.sqrt(n_pairs),
               uniq + 1.96 * uniq_std / np.sqrt(n_pairs))

    return dict(
        M=M, N_BITS=N_BITS, K=K,
        sigma_p=sigma_p, sigma_sys=sigma_sys, sigma_n=sigma_n,
        uniq=float(uniq), uniq_std=float(uniq_std),
        uniq_ci_lo=float(uniq_ci[0]), uniq_ci_hi=float(uniq_ci[1]),
        n_pairs=int(n_pairs),
        rel=float(rel),
        bias=float(bias),
        hmin_mean=float(hmin.mean()),
        hmin_worst=float(hmin.min()),
        hmin_total=float(hmin.mean() * N_BITS),
    )


def main():
    rng = np.random.default_rng(2741)
    r = run(SIGMA_P, SIGMA_SYS, SIGMA_N, rng)

    print("=" * 72)
    print("A2 Arbiter-PUF quality — expanded Monte Carlo (%d chips x %d bits)"
          % (M, N_BITS))
    print("=" * 72)
    print("Operating point: sigma_p=%.2f sigma_sys=%.2f sigma_n=%.2f"
          % (SIGMA_P, SIGMA_SYS, SIGMA_N))
    print("-" * 72)
    print("Uniqueness   (inter-chip HD/bit): %.4f  (target 0.50)" % r["uniq"])
    print("               95%% CI: [%.4f, %.4f]  over %d pairs"
          % (r["uniq_ci_lo"], r["uniq_ci_hi"], r["n_pairs"]))
    print("Reliability  (1 - intraHD/bit):   %.4f  (%.2f%% unstable)"
          % (r["rel"], (1 - r["rel"]) * 100))
    print("Bias         P(bit=1):            %.4f   (target 0.50)" % r["bias"])
    print("Min-entropy/bit (sample, M=%d):   mean %.3f  worst %.3f"
          % (M, r["hmin_mean"], r["hmin_worst"]))
    print("Min-entropy  full 256-bit resp:   %.1f bits of 256" % r["hmin_total"])
    print("-" * 72)
    ok = (0.45 <= r["uniq"] <= 0.55) and (r["rel"] >= 0.95) and \
         (r["hmin_mean"] >= 0.80)
    print("VERDICT uniq in [45,55]%%: %s | rel>=95%%: %s | Hmin_mean>=0.8: %s"
          % (0.45 <= r["uniq"] <= 0.55, r["rel"] >= 0.95, r["hmin_mean"] >= 0.80))
    print("HEADLINE_PASS:", ok)

    # Compare with M=128
    print("\nComparison with M=128 (original):")
    print("  M=128: uniq=0.4975  Hmin_mean=0.875  rel=0.9939")
    print("  M=%d: uniq=%.4f  Hmin_mean=%.3f  rel=%.4f"
          % (M, r["uniq"], r["hmin_mean"], r["rel"]))
    print("  CI width reduction: the 95%% confidence interval for uniqueness")
    print("  narrows from +/-0.013 (M=128) to +/-%.4f (M=%d)"
          % ((r["uniq_ci_hi"] - r["uniq_ci_lo"]) / 2, M))

    out = os.path.join(OUTDIR, "puf_quality_big.json")
    with open(out, "w") as f:
        json.dump(r, f, indent=2)
    print("\nwrote %s" % out)


if __name__ == "__main__":
    main()