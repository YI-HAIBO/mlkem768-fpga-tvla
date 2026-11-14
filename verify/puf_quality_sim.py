# =============================================================================
# A2 Arbiter-PUF quality simulation (uniqueness / reliability / min-entropy)
# -----------------------------------------------------------------------------
# puf_key.v consumes a 256-bit physical Arbiter-PUF array response
# (puf_seed[255:0]). The array is an analog delay-mismatch device: response
# bits are set by per-chip process variation, so uniqueness/min-entropy CANNOT
# be verified in RTL (no process variation there) -- a cell-level Monte-Carlo
# model across VIRTUAL CHIPS is the strongest hardware-free evidence.
#
# Cell model (standard arbiter PUF, one bit = one challenge):
#     Delta_{c,i} = delta_i + P_{c,i}          delay difference
#       delta_i  ~ N(0, sigma_sys^2)   systematic layout bias of bit i
#       P_{c,i}  ~ N(0, sigma_p^2)     process variation of chip c on bit i
#     read noise: eps_{c,i,k} ~ N(0, sigma_n^2)
#     response  r_{c,i,k} = 1 if (Delta_{c,i} + eps_{c,i,k}) > 0 else 0
#
# Metrics (per operating point):
#   Uniqueness  = inter-chip HD / 256  (target ~0.50)
#   Reliability = 1 - intra-chip HD/256 (target >= 95%, published PUFs 95-99%)
#   Bias        = P(bit=1)             (target ~0.50)
#   MinEntropy  = -log2(max(p_i,1-p_i)) per bit, averaged over the M-chip sample
# =============================================================================
import numpy as np

N_BITS = 256
M = 128          # virtual chips (>=8 required; 128 for tighter statistics)
K = 8            # repeated reads per chip
SIGMA_P = 1.0


def hd(a, b):
    return int(np.count_nonzero(a != b))


def run(sigma_p, sigma_sys, sigma_n, rng):
    delta = rng.normal(0.0, sigma_sys, N_BITS)
    Delta = delta[None, :] + rng.normal(0.0, sigma_p, (M, N_BITS))
    r_true = (Delta > 0)

    # uniqueness
    pair_hds = []
    for c1 in range(M):
        for c2 in range(c1 + 1, M):
            pair_hds.append(hd(r_true[c1], r_true[c2]))
    uniq = np.mean(pair_hds) / N_BITS

    # reliability (re-reads with noise)
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
    return dict(uniq=float(uniq), rel=float(rel), bias=float(bias),
                hmin_mean=float(hmin.mean()), hmin_worst=float(hmin.min()),
                hmin_total=float(hmin.mean() * N_BITS))


def main():
    print("=" * 66)
    print("A2 Arbiter-PUF quality (cell-level Monte Carlo, %d chips x %d bits)"
          % (M, N_BITS))
    print("=" * 66)

    # --- Operating point sweep: read noise sigma_n (reliability) ------------
    print("\n[S1] Reliability vs read noise (sigma_p=%.2f sigma_sys=%.2f)"
          % (SIGMA_P, 0.10))
    print("   sigma_n  reliability   intraHD%%   Hmin_mean  uniq")
    for sn in [0.01, 0.02, 0.05, 0.10]:
        rng = np.random.default_rng(0xA2 + int(sn * 1000))
        r = run(SIGMA_P, 0.10, sn, rng)
        print("    %.2f      %.4f       %.3f%%    %.3f     %.4f"
              % (sn, r["rel"], (1 - r["rel"]) * 100, r["hmin_mean"], r["uniq"]))

    # --- Systematic bias sweep (min-entropy / uniqueness) ------------------
    print("\n[S2] Min-entropy vs systematic bias (sigma_p=%.2f sigma_n=%.2f)"
          % (SIGMA_P, 0.02))
    print("   sigma_sys  Hmin_mean  Hmin_worst  uniq")
    for ss in [0.0, 0.05, 0.10, 0.20]:
        rng = np.random.default_rng(0xA2 + int(ss * 100))
        r = run(SIGMA_P, ss, 0.02, rng)
        print("     %.2f       %.3f      %.3f      %.4f"
              % (ss, r["hmin_mean"], r["hmin_worst"], r["uniq"]))

    # --- Headline operating point -------------------------------------------
    print("\n[S0] HEADLINE operating point: sigma_p=%.2f sigma_sys=%.2f "
          "sigma_n=%.2f" % (SIGMA_P, 0.10, 0.02))
    rng = np.random.default_rng(0xA2)
    r = run(SIGMA_P, 0.10, 0.02, rng)
    print("-" * 66)
    print("Uniqueness   (inter-chip HD/bit): %.4f   (target 0.50)" % r["uniq"])
    print("Reliability  (1 - intraHD/bit):   %.4f  (%.2f%% unstable)"
          % (r["rel"], (1 - r["rel"]) * 100))
    print("Bias         P(bit=1):            %.4f   (target 0.50)" % r["bias"])
    print("Min-entropy/bit (sample, M=%d):   mean %.3f  worst %.3f"
          % (M, r["hmin_mean"], r["hmin_worst"]))
    print("Min-entropy  full 256-bit resp:   %.1f bits of 256" % r["hmin_total"])
    print("-" * 66)
    ok = (0.45 <= r["uniq"] <= 0.55) and (r["rel"] >= 0.95) and \
         (r["hmin_mean"] >= 0.80)
    print("VERDICT uniq in [45,55]%%: %s | rel>=95%%: %s | Hmin_mean>=0.8: %s"
          % (0.45 <= r["uniq"] <= 0.55, r["rel"] >= 0.95, r["hmin_mean"] >= 0.80))
    print("HEADLINE_PASS:", ok)
    print()
    print("Note: min-entropy is the FINITE-SAMPLE estimate over M chips (what a")
    print("multi-chip measurement would report). The model-true value is higher")
    print("(mean ~0.93 for sigma_sys=0.1); finite M=128 sets a ~0.85 floor.")
    return r


if __name__ == "__main__":
    main()
