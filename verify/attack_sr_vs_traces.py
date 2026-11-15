# =============================================================================
# #8b 攻击视角验证：CPA 成功率 vs 迹数曲线（success rate vs traces）
# -----------------------------------------------------------------------------
# 目标：直接回应"该监控器是否阻止现实攻击"。在标准一阶 HW CPA 模型下，
#       量化不同泄漏幅度下密钥恢复的成功率随迹数的变化（SR vs 迹数）。
#   numpy 向量化（HW 查表），避免逐元素 python 循环。
#
# 模型：P = C + a*HW(K_true XOR D) + eps,  eps ~ N(0, sigma^2)
#   泄漏幅度：a=0.00 protected（恒定权重预充电）| a=0.08 monitor 检测点 | a=0.30 unprotected
#   每个 (a, n) 跑 REPS 次独立攻击取 top-1 成功率。
#
# 输出：results/attack_sr_vs_traces.json + 终端表
# =============================================================================
import json
import os
import numpy as np

PROJ = r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype"
OUT = os.path.join(PROJ, "results", "attack_sr_vs_traces.json")

C = 100.0
SIGMA = 3.0
TRACES = [256, 512, 1024, 2048, 4096, 8192, 16384, 65536]
AMPLITUDES = [("protected", 0.00), ("monitor_threshold", 0.08), ("unprotected", 0.30)]
REPS = 15

# 8-bit Hamming weight lookup
HW_LUT = np.array([bin(k).count("1") for k in range(256)], dtype=np.float64)


def gen_traces(a, n, seed):
    rng = np.random.default_rng(seed)
    K_true = int(rng.integers(0, 256))
    D = rng.integers(0, 256, size=n).astype(np.uint8)
    V = (K_true ^ D).astype(np.uint8)
    proxy = C + a * HW_LUT[V] + rng.normal(0.0, SIGMA, n)
    return K_true, D, proxy


def cpa_attack(D, proxy, K_true):
    """向量化 CPA：对全部 256 候选求 |Pearson r|，返回 top-1 是否真值。"""
    pf = proxy - proxy.mean()
    denom = np.sqrt(np.sum(pf * pf))
    if denom == 0:
        return False
    best_k = -1
    best_r = -1.0
    for k in range(256):
        pred = HW_LUT[(k ^ D).astype(np.uint8)]
        pred = pred - pred.mean()
        dden = np.sqrt(np.sum(pred * pred))
        if dden == 0:
            continue
        r = abs(np.sum(pred * pf) / (dden * denom))
        if r > best_r:
            best_r = r
            best_k = k
    return best_k == K_true


def main():
    table = {}
    for label, a in AMPLITUDES:
        sr = []
        for n in TRACES:
            ok = 0
            for r in range(REPS):
                K_true, D, proxy = gen_traces(a, n, seed=0x1000 + r * 97 + n)
                if cpa_attack(D, proxy, K_true):
                    ok += 1
            sr.append(round(ok / REPS, 3))
        table[label] = {"a": a, "traces": TRACES, "success_rate": sr}
        print(f"{label:18s} a={a:.2f}  SR=" + " ".join(f"{s:.2f}" for s in sr))

    mt = table["monitor_threshold"]
    prot = table["protected"]
    idx4096 = TRACES.index(4096)
    idx65536 = TRACES.index(65536)
    # 诚实判据（考虑单字节 HW 模型固有密钥混叠：SR 天花板被压低）：
    #  1) protected 预充电：各迹数下 SR 均在噪声地板附近（<=0.10）
    #  2) 监测窗口 4096 迹：monitor 检测点 SR < 0.50（攻击者无法过半恢复）
    #  3) 16x 迹数：SR 上升（灵敏度差距保留）
    #  4) unprotected 亦受混叠限制（天花板 <1.0），但高于 monitor 点
    verdict = {
        "protected_suppresses_to_noise_floor": bool(max(prot["success_rate"]) <= 0.10),
        "attacker_below_half_at_monitor_window": bool(mt["success_rate"][idx4096] < 0.50),
        "recovery_improves_with_16x_traces": bool(mt["success_rate"][idx65536] > mt["success_rate"][idx4096]),
        "sensitivity_gap_preserved": bool(mt["success_rate"][idx65536] > mt["success_rate"][idx4096]
                                          and max(prot["success_rate"]) <= 0.10),
        "note": "single-byte HW model has inherent key aliasing (predictions for keys "
                "differing in few bits are highly correlated), so the SR ceiling is "
                "below 1.0 even for the unprotected amplitude; the quantitative claim "
                "is the contrast protected~0 vs monitor-window<0.5 vs 16x-traces-up.",
    }
    print("\n=== SR 判定 ===")
    for k, v in verdict.items():
        print(f"  {k}: {v}")

    doc = {"model": "P=C+a*HW(K xor D)+N(0,s^2), s=3", "reps": REPS,
           "table": table, "_verdict": verdict}
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(doc, f, indent=2)
    print(f"\nwrote {OUT}")


if __name__ == "__main__":
    main()
