# =============================================================================
# #6b 二阶泄漏检测演示（higher-order / second-order leakage detection）
# -----------------------------------------------------------------------------
# 目标：展示"一阶 Welch t 会漏掉、二阶（中心二阶矩）t 能抓到"的二阶泄漏，
#       证明论文 L226-228 "cannot detect higher-order leakage" 这一局限有可落地
#       的解决方案 —— 在整数引擎中增加中心二阶矩统计（二阶 Welch t）。
#
# 高阶泄漏模型（异方差，纯二阶：两群均值相同、方差不同）：
#     P = C + N(0, sigma^2 * (1 + beta*HW(V)))     (零均值，方差随 HW 变化)
#   固定密钥组：V=K_fixed 恒定 -> HW 恒定 -> 方差恒定
#   随机密钥组：V 逐样本随机 -> HW~Binomial(8,0.5) -> 方差 = sigma^2*(1+beta*HW)
#   => 两群均值都 = C（一阶 t 应≈0），但方差不同（二阶 t 应显著）
#
# 场景：
#   S1  一阶泄漏（均值漂移）P = C + a*HW + N(0,sigma^2), a=0.30, K=0xFF(HW=8)
#        -> 一阶 t 显著（监控器能抓）        [一阶能力对照]
#   S2  纯二阶泄漏（异方差）beta=1.0, K=0xFF(HW=8)
#        -> 一阶 t≈0（漏掉），二阶 t 显著（抓到）  [核心：局限可解]
#   S4  无泄漏  P = C + N(0,sigma^2)        -> 一阶/二阶 t 均≈0（阴性对照）
#
# 一阶统计：原样样本 Welch t（= 现有 tvla_online 的一阶对比）
# 二阶统计：中心化后取平方，再做 Welch t（标准二阶/中心矩统计量）
#
# 输出：results/second_order_analysis.json + 终端摘要
# =============================================================================
import json
import os
import numpy as np
from scipy import stats

PROJ = r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype"
OUT = os.path.join(PROJ, "results", "second_order_analysis.json")

C = 100.0
SIGMA = 3.0
N = 4096
K_FIXED = 0xFF          # HW = 8, 与随机群均值 4 最大化分离
HW_FIXED = 8


def hw(x):
    return bin(x & 0xFF).count("1")


def gen_first_order(a, seed=0xC0FFEE):
    """P = C + a*HW(V) + N(0,sigma^2). 固定群 HW=8 恒定，随机群 HW~Bin."""
    rng = np.random.default_rng(seed)
    fixed = C + a * HW_FIXED + rng.normal(0.0, SIGMA, N)
    Vr = rng.integers(0, 256, size=N)
    hwr = np.array([hw(int(v)) for v in Vr], dtype=float)
    rndm = C + a * hwr + rng.normal(0.0, SIGMA, N)
    def q(x):
        return np.clip(np.round(x), 0, 255).astype(np.uint8)
    return q(fixed), q(rndm)


def gen_second_order(beta, seed=0xC0FFEE):
    """P = C + N(0, sigma^2*(1+beta*HW(V))). 纯二阶（均值同、方差异）。"""
    rng = np.random.default_rng(seed)
    sig_f = SIGMA * np.sqrt(1.0 + beta * HW_FIXED)
    fixed = C + rng.normal(0.0, sig_f, N)
    Vr = rng.integers(0, 256, size=N)
    hwr = np.array([hw(int(v)) for v in Vr], dtype=float)
    sig_r = SIGMA * np.sqrt(1.0 + beta * hwr)
    rndm = C + rng.normal(0.0, sig_r, N)
    def q(x):
        return np.clip(np.round(x), 0, 255).astype(np.uint8)
    return q(fixed), q(rndm)


def gen_none(seed=0xC0FFEE):
    rng = np.random.default_rng(seed)
    fixed = C + rng.normal(0.0, SIGMA, N)
    rndm = C + rng.normal(0.0, SIGMA, N)
    def q(x):
        return np.clip(np.round(x), 0, 255).astype(np.uint8)
    return q(fixed), q(rndm)


def t_first_order(fx, rx):
    t, p = stats.ttest_ind(fx.astype(float), rx.astype(float), equal_var=False)
    return float(t)


def t_second_order(fx, rx):
    """中心化平方的 Welch t（标准二阶 / 中心矩统计量）。"""
    fx = fx.astype(float); rx = rx.astype(float)
    sq_f = (fx - fx.mean()) ** 2
    sq_r = (rx - rx.mean()) ** 2
    t, p = stats.ttest_ind(sq_f, sq_r, equal_var=False)
    return float(t)


def main():
    scenarios = [
        ("S1_first_order", gen_first_order(0.30), "一阶泄漏 a=0.30"),
        ("S2_second_order", gen_second_order(1.00), "纯二阶泄漏 beta=1.0"),
        ("S4_none", gen_none(), "无泄漏（阴性对照）"),
    ]
    rows = []
    for name, (fx, rx), desc in scenarios:
        t1 = t_first_order(fx, rx)
        t2 = t_second_order(fx, rx)
        rec = {
            "scenario": name, "desc": desc,
            "t_first_order": t1, "first_order_flags": bool(abs(t1) > 4.5),
            "t_second_order": t2, "second_order_flags": bool(abs(t2) > 4.5),
            "mean_f": float(fx.mean()), "mean_r": float(rx.mean()),
            "var_f": float(fx.var(ddof=1)), "var_r": float(rx.var(ddof=1)),
        }
        rows.append(rec)
        print(f"{name:18s} | t1={t1:+7.2f} flag1={rec['first_order_flags']} | "
              f"t2={t2:+7.2f} flag2={rec['second_order_flags']} | "
              f"varF={rec['var_f']:6.1f} varR={rec['var_r']:6.1f}")

    s1, s2, s4 = rows
    verdict = {
        "first_order_catches_first_order": bool(s1["first_order_flags"]),
        "first_order_misses_second_order": bool(not s2["first_order_flags"]),
        "second_order_catches_second_order": bool(s2["second_order_flags"]),
        "second_order_silent_on_none": bool(not s4["second_order_flags"]),
        "extension_effective": bool(not s2["first_order_flags"] and s2["second_order_flags"]),
    }
    print("\n=== 二阶扩展判定 ===")
    for k, v in verdict.items():
        print(f"  {k}: {v}")

    doc = {"model": "S1: P=C+a*HW+N(0,s^2); S2: P=C+N(0,s^2(1+b*HW)); "
                    "S4: P=C+N(0,s^2); s=3, n=4096, 8-bit", "rows": rows,
           "_verdict": verdict}
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(doc, f, indent=2)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()
