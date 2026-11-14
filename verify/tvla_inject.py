# =============================================================================
# Side-channel leakage injection for B3 tvla_online.v (fixed-vs-random TVLA)
# -----------------------------------------------------------------------------
# Physically-motivated leakage model (standard register / DPA HW model):
#     P = c + a * HW(K_reg) + eps,  eps ~ N(0, sigma^2)
# The probe observes the Hamming weight of the secret key register -- the
# classic first-order register-leakage point. In the FIXED-key group the key
# is constant (HW = HW(K_fixed) every trace); in the RANDOM-key group the key
# varies per trace (HW ~ Binomial(8, 0.5), mean 4). The fixed-vs-random Welch
# mean shift is therefore a * (HW(K_fixed) - 4), which is NON-ZERO exactly when
# the leak amplitude a > 0 and HW(K_fixed) != 4  ->  B3 must flag it. A masked
# / protected implementation has a = 0 (key contributes nothing observable)
# -> no mean shift -> B3 must stay silent.
#
# Scenarios sweep the leak amplitude a across the |t| = 4.5 threshold to show
# B3's integer decision switches exactly where the float Welch t does.
#
# Outputs (per scenario, to OUT dir):
#   <name>.hex      -- 4096 fixed-group samples then 4096 random-group samples
#                       (8-bit quantized, one byte per line, $readmemh format)
#   <name>.json     -- {float_t, expected_leak, rtl_pred, a, mean_f, mean_r}
# =============================================================================
import json
import math
import os
import random

import numpy as np
from scipy import stats

OUT = r"C:/tmp/glpwr_1794120391/tvla"
N_LOG2 = 12
N = 1 << N_LOG2          # 4096 per group
C = 100.0                # baseline power (LSB)
SIGMA = 3.0              # noise std dev (LSB)
K_FIXED = 0xFF           # HW = 8, maximally separated from random-group mean 4


def hw(x):
    return bin(x & 0xFF).count("1")


def gen_scenario(a, seed=0xC0FFEE):
    """Generate fixed+random group samples under HW-key-register leak model."""
    rng = np.random.default_rng(seed)
    # Fixed-key group: K = K_FIXED constant -> HW = 8 -> P = c + a*8 + eps
    fixed = C + a * hw(K_FIXED) + rng.normal(0.0, SIGMA, N)
    # Random-key group: K uniform per trace -> HW ~ Binomial(8,0.5)
    Krand = rng.integers(0, 256, size=N)
    hwr = np.array([hw(int(k)) for k in Krand], dtype=float)
    rndm = C + a * hwr + rng.normal(0.0, SIGMA, N)
    # 8-bit quantize + clip
    def q(x):
        return np.clip(np.round(x), 0, 255).astype(np.uint8)
    return q(fixed), q(rndm)


def welch_t(fixed_u8, rndm_u8):
    """scipy Welch t-test (unequal variance) on the two groups."""
    t, p = stats.ttest_ind(fixed_u8.astype(float), rndm_u8.astype(float),
                           equal_var=False)
    return float(t)


def rtl_pred(fixed_u8, rndm_u8):
    """Replicate the RTL integer decision (exactly as tvla_online.v does)."""
    s1 = int(fixed_u8.sum())
    q1 = int((fixed_u8.astype(np.int64) ** 2).sum())
    s2 = int(rndm_u8.sum())
    q2 = int((rndm_u8.astype(np.int64) ** 2).sum())
    d = s1 - s2
    D = (N * (q1 + q2)) - s1 * s1 - s2 * s2
    if D == 0:
        return d != 0, d, D
    lhs = (d * d) << (N_LOG2 + 2)     # 4*n*d^2
    rhs = 81 * D
    return lhs > rhs, d, D


def main():
    os.makedirs(OUT, exist_ok=True)
    scenarios = [0.0, 0.03, 0.05, 0.07, 0.075, 0.08, 0.09, 0.12, 1.0]
    rows = []
    for a in scenarios:
        fixed, rndm = gen_scenario(a)
        t = welch_t(fixed, rndm)
        leak, d, D = rtl_pred(fixed, rndm)
        exp = abs(t) > 4.5
        name = "a%04d" % int(round(a * 10000))
        hpath = os.path.join(OUT, name + ".hex")
        with open(hpath, "w") as f:
            for v in fixed:
                f.write("%02X\n" % v)
            for v in rndm:
                f.write("%02X\n" % v)
        rec = {
            "a": a, "float_t": t, "expected_leak": exp, "rtl_pred": leak,
            "agree": bool(exp == leak), "d": int(d), "D": int(D),
            "mean_f": float(fixed.mean()), "mean_r": float(rndm.mean()),
            "hex": hpath,
        }
        with open(os.path.join(OUT, name + ".json"), "w") as f:
            json.dump(rec, f, indent=2)
        rows.append(rec)
        print(f"a={a:6.3f} |t|={abs(t):7.3f} t={t:+7.3f} "
              f"meanF={rec['mean_f']:6.2f} meanR={rec['mean_r']:6.2f} "
              f"exp={exp} rtl={leak} agree={exp == leak}")
    # summary
    print("\n=== RTL-vs-float agreement across threshold ===")
    for r in rows:
        print(f"  a={r['a']:6.3f} |t|={abs(r['float_t']):7.3f} "
              f"expected_leak={r['expected_leak']} rtl_leak={r['rtl_pred']} "
              f"agree={r['agree']}")
    all_agree = all(r["agree"] for r in rows)
    print("ALL_AGREE:", all_agree)


if __name__ == "__main__":
    main()
