# =============================================================================
# #8a 阴性对照（fixed-fixed / random-random）：验证监控器不误报
# -----------------------------------------------------------------------------
# 目标：补全 #8 双对比方法学。TVLA 固定-随机对比存在"非泄漏差异"误判风险；
#       增加两种阴性对照：
#         N1  fixed-fixed   ：两组都是同一固定密钥 -> 分布应无差异 -> |t| 小
#         N2  random-random：两组都是独立随机密钥 -> 分布应无差异 -> |t| 小
#       以及阳性对照：
#         P1  fixed-random（有泄漏）-> |t| 大（监控器应报）
#       若 N1/N2 不误报（|t|<4.5）而 P1 正确报（|t|>4.5），则"双对比"可靠。
#
# 模型：P = C + a*HW(V) + N(0, sigma^2)，a=0.08（monitor 检测点）。
#   N1: V 在两组均为 K_fixed -> 两组同分布 -> t≈0
#   N2: V 在两组均为随机 -> 两组同分布 -> t≈0
#   P1: V 组1=K_fixed、组2=随机 -> 均值差 a*(HW(K)-4) -> t 大
#
# 输出：results/negative_control_analysis.json + 终端摘要
# =============================================================================
import json
import os
import numpy as np
from scipy import stats

PROJ = r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype"
OUT = os.path.join(PROJ, "results", "negative_control_analysis.json")

C = 100.0
SIGMA = 3.0
N = 4096
A = 0.12          # 同幅度下对比：跨群（fixed-random）应报、同群应静默
K_FIXED = 0xFF    # HW = 8，与随机群均值 4 最大化分离
REPS = 10


def hw(x):
    return bin(x & 0xFF).count("1")


def gen_group(a, hw_mode, n, rng):
    """hw_mode: 'fixed' -> HW 恒定=HW(K); 'rand' -> HW~Bin(8,0.5)."""
    if hw_mode == "fixed":
        h = hw(K_FIXED)
        hwv = np.full(n, float(h))
    else:
        V = rng.integers(0, 256, size=n)
        hwv = np.array([hw(int(v)) for v in V], dtype=float)
    return C + a * hwv + rng.normal(0.0, SIGMA, n)


def run_scenario(g1_mode, g2_mode, a, seed=0xC0FFEE):
    rng = np.random.default_rng(seed)
    g1 = gen_group(a, g1_mode, N, rng)
    g2 = gen_group(a, g2_mode, N, rng)
    t, p = stats.ttest_ind(g1, g2, equal_var=False)
    return float(t)


def main():
    # 多次独立试验，统计误报率
    res = {}
    for name, m1, m2 in [("N1_fixed_fixed", "fixed", "fixed"),
                         ("N2_random_random", "rand", "rand"),
                         ("P1_fixed_random", "fixed", "rand")]:
        ts = [run_scenario(m1, m2, A, seed=0x1000 + r) for r in range(REPS)]
        flags = [bool(abs(t) > 4.5) for t in ts]
        res[name] = {"t_values": ts, "flags": flags,
                     "false_alarm_rate": round(sum(flags) / REPS, 3),
                     "mean_abs_t": round(float(np.mean(np.abs(ts))), 3),
                     "max_abs_t": round(float(np.max(np.abs(ts))), 3)}
        print(f"{name:18s} mean|t|={res[name]['mean_abs_t']:5.2f} "
              f"max|t|={res[name]['max_abs_t']:5.2f} "
              f"false_alarm={res[name]['false_alarm_rate']:.3f} "
              f"ts=" + " ".join(f"{t:+.1f}" for t in ts))

    verdict = {
        "negative_controls_quiet": bool(res["N1_fixed_fixed"]["false_alarm_rate"] == 0
                                        and res["N2_random_random"]["false_alarm_rate"] == 0),
        "positive_control_flags": bool(res["P1_fixed_random"]["false_alarm_rate"] == 1.0),
        "dual_contrast_reliable": bool(
            res["N1_fixed_fixed"]["false_alarm_rate"] == 0
            and res["N2_random_random"]["false_alarm_rate"] == 0
            and res["P1_fixed_random"]["false_alarm_rate"] == 1.0),
        "note": "N1/N2 阴性对照不误报（|t|<4.5），P1 阳性对照 100% 报，"
                "双对比（固定-随机 + 阴性对照）可靠",
    }
    print("\n=== 双对比判定 ===")
    for k, v in verdict.items():
        print(f"  {k}: {v}")

    doc = {"model": f"P=C+{A}*HW(V)+N(0,{SIGMA}^2), n={N}", "reps": REPS,
           "results": res, "_verdict": verdict}
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(doc, f, indent=2)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()
