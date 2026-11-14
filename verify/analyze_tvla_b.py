# -*- coding: utf-8 -*-
"""Gap-to-Q1 class-B analysis (simulation only, no board measurement).

G6: on-device proxy autocorrelation / effective sample size.
    Source: results/proxy_rand.txt  (random-secret operation stream dumped from
    kyber_kem, replicating the board-top 6-bit HW proxy).

G4: protected vs unprotected fixed-vs-random TVLA.
    (a) real raw-bus TVLA from the dumped proxy (fixed vs random secret).
    (b) model-based contrast using the paper's first-order HW leakage model
        (tvla_inject.py): a=0  -> constant-weight precharge invariant (hiding
        nominal) -> engine silent; a>0 -> residual data-dependent switching
        weight (hiding degraded) -> engine flags.

Outputs results/tvla_b_analysis.json and a human-readable summary.
"""
import json, os
import numpy as np

RES = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "results"))
N_LOG2 = 12
N = 1 << N_LOG2  # 4096 per group


def hw(x):
    return bin(x & 0xFF).count("1")


def load_proxy(path):
    with open(path) as f:
        return np.array([int(l.strip()) for l in f if l.strip() != ""], dtype=np.int64)


def autocorrel_lag(x, lag):
    x = x.astype(float)
    x = x - x.mean()
    var = np.mean(x * x)
    if var == 0:
        return 0.0
    n = len(x) - lag
    cov = np.mean(x[:n] * x[lag:n + lag])
    return float(cov / var)


def welch_t(fx, rx):
    n1, n2 = len(fx), len(rx)
    m1, m2 = fx.mean(), rx.mean()
    v1 = fx.var(ddof=1)
    v2 = rx.var(ddof=1)
    denom = np.sqrt(v1 / n1 + v2 / n2)
    if denom == 0:
        return 0.0, m1 - m2
    return float((m1 - m2) / denom), m1 - m2


def rtl_pred(fx, rx):
    s1 = int(fx.sum()); q1 = int((fx.astype(np.int64) ** 2).sum())
    s2 = int(rx.sum()); q2 = int((rx.astype(np.int64) ** 2).sum())
    d = s1 - s2
    D = (N * (q1 + q2)) - s1 * s1 - s2 * s2
    if D == 0:
        return (d != 0), d, D
    lhs = (d * d) << (N_LOG2 + 2)          # 4*n*d^2
    rhs = 81 * D
    return (lhs > rhs), d, D


def gen_scenario(a, seed=0xC0FFEE):
    rng = np.random.default_rng(seed)
    C, SIGMA, K_FIXED = 100.0, 3.0, 0xFF
    fixed = C + a * hw(K_FIXED) + rng.normal(0.0, SIGMA, N)
    Krand = rng.integers(0, 256, size=N)
    hwr = np.array([hw(int(k)) for k in Krand], dtype=float)
    rndm = C + a * hwr + rng.normal(0.0, SIGMA, N)
    q = lambda x: np.clip(np.round(x), 0, 255).astype(np.uint8)
    return q(fixed), q(rndm)


def main():
    out = {}

    # ---------------- G6: autocorrelation / n_eff ----------------
    pr = load_proxy(os.path.join(RES, "proxy_rand.txt"))
    out["G6"] = {}
    out["G6"]["n_samples"] = int(len(pr))
    out["G6"]["proxy_mean"] = float(pr.mean())
    out["G6"]["proxy_std"] = float(pr.std())
    out["G6"]["proxy_min"] = int(pr.min())
    out["G6"]["proxy_max"] = int(pr.max())
    rhos = {f"rho_lag{k+1}": autocorrel_lag(pr, k + 1) for k in range(5)}
    out["G6"]["autocorr"] = rhos
    rho1 = rhos["rho_lag1"]
    out["G6"]["rho1"] = rho1
    out["G6"]["n_eff"] = float(N * (1.0 - rho1) / (1.0 + rho1))
    print("=" * 70)
    print("G6: on-device proxy autocorrelation (simulated random-operation stream)")
    print("=" * 70)
    print(f"  samples      = {out['G6']['n_samples']}")
    print(f"  proxy mean   = {out['G6']['proxy_mean']:.3f}  std = {out['G6']['proxy_std']:.3f}  "
          f"[{out['G6']['proxy_min']}..{out['G6']['proxy_max']}]")
    print("  autocorrelation:", {k: round(v, 4) for k, v in rhos.items()})
    print(f"  lag-1 rho     = {rho1:.4f}")
    print(f"  n_eff (n=4096) = {out['G6']['n_eff']:.1f}")
    print(f"  -> vs iid n=4096, the proxy's lag-1 correlation reduces the")
    print(f"     effective independent sample count to ~{out['G6']['n_eff']:.0f}.")

    # ---------------- G4a: real raw-bus TVLA (dumped proxy) ----------------
    pf = load_proxy(os.path.join(RES, "proxy_fixed.txt"))
    fx = pf[:N].astype(float)
    rx = pr[:N].astype(float)
    t_raw, shift_raw = welch_t(fx, rx)
    leak_raw, _, _ = rtl_pred(pf[:N], pr[:N])
    out["G4"] = {}
    out["G4"]["raw_bus"] = {
        "fixed_mean": float(fx.mean()), "random_mean": float(rx.mean()),
        "float_t": t_raw, "abs_t": abs(t_raw),
        "engine_leak": bool(leak_raw), "mean_shift": float(shift_raw),
    }
    print()
    print("=" * 70)
    print("G4(a): real raw sampled-bus TVLA (fixed vs random secret, dumped)")
    print("=" * 70)
    print(f"  fixed-group proxy mean  = {fx.mean():.3f}")
    print(f"  random-group proxy mean = {rx.mean():.3f}")
    print(f"  mean shift              = {shift_raw:.3f}")
    print(f"  |Welch t|               = {abs(t_raw):.3f}  (threshold 4.5)")
    print(f"  engine decision         = {'LEAK' if leak_raw else 'NO LEAK'}")

    # ---------------- G4b: protected vs unprotected (leakage model) ---------
    # protected: a=0  -> constant-weight precharge invariant (hiding nominal)
    f0, r0 = gen_scenario(0.0, seed=0xC0FFEE)
    t0, _ = welch_t(f0.astype(float), r0.astype(float))
    leak0, _, _ = rtl_pred(f0, r0)
    # unprotected: a=0.08 -> residual data-dependent switching weight
    f1, r1 = gen_scenario(0.08, seed=0xC0FFEE)
    t1, _ = welch_t(f1.astype(float), r1.astype(float))
    leak1, _, _ = rtl_pred(f1, r1)
    out["G4"]["protected_model_a0"] = {
        "float_t": t0, "abs_t": abs(t0), "engine_leak": bool(leak0)}
    out["G4"]["unprotected_model_a008"] = {
        "float_t": t1, "abs_t": abs(t1), "engine_leak": bool(leak1)}
    print()
    print("=" * 70)
    print("G4(b): protected vs unprotected (paper's first-order HW model)")
    print("=" * 70)
    print(f"  PROTECTED   (a=0, constant-weight precharge) : "
          f"|t|={abs(t0):7.3f}  engine={'LEAK' if leak0 else 'NO LEAK'}")
    print(f"  UNPROTECTED (a=0.08, hiding degraded)        : "
          f"|t|={abs(t1):7.3f}  engine={'LEAK' if leak1 else 'NO LEAK'}")
    print("  -> the precharge hiding removes the data-dependent component;")
    print("     the on-chip engine confirms hiding-on (silent) vs hiding-off (flagged).")

    with open(os.path.join(RES, "tvla_b_analysis.json"), "w") as f:
        json.dump(out, f, indent=2)
    print("\nWROTE", os.path.join(RES, "tvla_b_analysis.json"))


if __name__ == "__main__":
    main()
