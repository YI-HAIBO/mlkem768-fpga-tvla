# =============================================================================
# CPA key-recovery contrast: protected vs unprotected, and sensitivity gap
# -----------------------------------------------------------------------------
# Standard first-order CPA on the Hamming-weight model of a secret key byte.
#   Sensitive intermediate V = K_true XOR D_i   (D_i known to the attacker)
#   Proxy:  P = c + a * HW(V) + eps,  eps ~ N(0, sigma^2)
#
# Three scenarios, all with n = 4096 traces per attack (the same sample count
# as the on-chip assessment window per group):
#   protected    a = 0.00  constant-weight precharge -> CPA must fail
#   unprotected  a = 0.30  no countermeasure          -> CPA must succeed
#   degraded     a = 0.08  the amplitude at which the on-chip Welch t-test
#                           flags leakage (|t| = 6.18, Section IV-E).  CPA on
#                           4096 traces cannot recover the key; 65,536 traces
#                           are required.  This quantifies the sensitivity gap:
#                           the monitor warns before key recovery is practical.
#
# Outputs: results/cpa_protect.json + human-readable summary
# =============================================================================
import json
import os
import numpy as np

PROJ = r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype"
OUTDIR = os.path.join(PROJ, "results")
os.makedirs(OUTDIR, exist_ok=True)

C = 100.0                # baseline power (LSB)
SIGMA = 3.0              # noise std dev (LSB)
N_TRACES = 4096          # traces per attack (matches n per TVLA group)
N_DEGRADED = 65536       # traces needed for CPA at the monitor's detection point


def hw(x):
    return bin(x & 0xFF).count("1")


def gen_traces(a, n_traces, seed=0xC0FFEE):
    """Generate (data, proxy) pairs; returns (K_true, D, proxy)."""
    rng = np.random.default_rng(seed)
    K_true = int(rng.integers(0, 256))
    D = rng.integers(0, 256, size=n_traces)
    V = K_true ^ D
    proxy = C + a * np.array([hw(int(v)) for v in V], dtype=float) \
        + rng.normal(0.0, SIGMA, n_traces)
    return K_true, D.astype(np.uint8), proxy


def cpa_attack(D, proxy):
    """Rank all 256 key candidates by max |Pearson r|."""
    pf = proxy - proxy.mean()
    denom = np.sqrt(np.sum(pf * pf))
    if denom == 0:
        return [(k, 0.0) for k in range(256)]
    ranks = []
    for k in range(256):
        pred = np.array([hw(k ^ int(d)) for d in D], dtype=float)
        pred = pred - pred.mean()
        dden = np.sqrt(np.sum(pred * pred))
        r = np.sum(pred * pf) / (dden * denom) if dden > 0 else 0.0
        ranks.append((k, r))
    ranks.sort(key=lambda t: -abs(t[1]))
    return ranks


def summarize(name, K_true, ranks):
    rank_of_true = next(i for i, (k, _) in enumerate(ranks) if k == K_true)
    return {
        "name": name,
        "true_key": int(K_true),
        "rank_of_true": int(rank_of_true),
        "top1_correct": bool(ranks[0][0] == K_true),
        "best_r": float(abs(ranks[0][1])),
        "second_r": float(abs(ranks[1][1])) if len(ranks) > 1 else 0.0,
        "true_r": float(abs(ranks[rank_of_true][1])),
        "top5": [(int(k), float(abs(r))) for k, r in ranks[:5]],
    }


def main():
    results = {}

    # 1. Protected (a = 0): CPA must fail
    K_true, D, proxy = gen_traces(0.0, N_TRACES)
    results["protected"] = summarize("protected (a=0.00, n=4096)", K_true, cpa_attack(D, proxy))

    # 2. Unprotected (a = 0.30): CPA must succeed
    K_true, D, proxy = gen_traces(0.30, N_TRACES)
    results["unprotected"] = summarize("unprotected (a=0.30, n=4096)", K_true, cpa_attack(D, proxy))

    # 3. Degraded at the monitor's detection point (a = 0.08)
    K_true, D, proxy = gen_traces(0.08, N_TRACES)
    r4096 = summarize("degraded (a=0.08, n=4096)", K_true, cpa_attack(D, proxy))
    results["degraded_n4096"] = r4096

    K_true, D, proxy = gen_traces(0.08, N_DEGRADED, seed=0xDEADBEEF)
    r65536 = summarize("degraded (a=0.08, n=65536)", K_true, cpa_attack(D, proxy))
    results["degraded_n65536"] = r65536

    # Sensitivity gap: trace ratio needed for CPA at the monitor's detection point
    gap_ratio = N_DEGRADED / N_TRACES

    for name, s in results.items():
        print(f"{name:32s} rank={s['rank_of_true']:3d}  top1={s['top1_correct']}  "
              f"true_r={s['true_r']:.4f}  best_r={s['best_r']:.4f}")

    verdict = {
        "cpa_fails_protected": bool(not results["protected"]["top1_correct"]),
        "cpa_recovers_unprotected": bool(results["unprotected"]["top1_correct"]),
        "cpa_fails_at_monitor_threshold": bool(not results["degraded_n4096"]["top1_correct"]),
        "cpa_succeeds_with_16x_traces": bool(results["degraded_n65536"]["top1_correct"]),
        "trace_gap_ratio": float(gap_ratio),
        "contrast_holds": bool(
            not results["protected"]["top1_correct"]
            and results["unprotected"]["top1_correct"]
        ),
        "sensitivity_gap_holds": bool(
            not results["degraded_n4096"]["top1_correct"]
            and results["degraded_n65536"]["top1_correct"]
        ),
    }
    results["_verdict"] = verdict

    print("\n=== CPA contrast verdict ===")
    print(f"  CPA fails on protected (a=0.00):        {verdict['cpa_fails_protected']}")
    print(f"  CPA recovers on unprotected (a=0.30):   {verdict['cpa_recovers_unprotected']}")
    print(f"  CPA fails at monitor threshold (a=0.08): {verdict['cpa_fails_at_monitor_threshold']}")
    print(f"  CPA succeeds with {gap_ratio:.0f}x traces at a=0.08:   {verdict['cpa_succeeds_with_16x_traces']}")
    print(f"  CONTRAST HOLDS:       {verdict['contrast_holds']}")
    print(f"  SENSITIVITY GAP HOLDS: {verdict['sensitivity_gap_holds']}")

    out = os.path.join(OUTDIR, "cpa_protect.json")
    with open(out, "w") as f:
        json.dump(results, f, indent=2)
    print(f"\nwrote {out}")


if __name__ == "__main__":
    main()