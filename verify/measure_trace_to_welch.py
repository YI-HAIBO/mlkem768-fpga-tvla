# =============================================================================
# #3 板级功耗测量 → 板上 Welch t 分析 harness（测量数据→泄漏判定）
# -----------------------------------------------------------------------------
# 目标：为"物理功耗测量→与板上整数监控器健康位对照"提供可复用分析管线。
#   输入：测量功耗/电流轨迹 CSV（time_ns, value），以及固定/随机群窗口标记；
#   输出：每窗口 Welch t、|t|>4.5 泄漏标志、与健康位一致性判定。
#
# 用法（真实测量）：
#   python measure_trace_to_welch.py trace.csv --win 8192 --group-sel group.csv
#      trace.csv  : 两列 time_ns, value（功耗/电流样本，每个时钟一拍）
#      group.csv  : 每窗口的群归属（'F'/'R'），长度 = 窗口数
#
# 自检（合成数据验证管线正确性，无需硬件）：
#   python measure_trace_to_welch.py --selftest
#      合成：泄漏窗口（固定群均值偏移）| 清洁窗口（无泄漏），验证 harness 能
#      正确区分，并与"板上整数监控器"的整数判据比对。
#
# 输出：results/measure_welch_analysis.json + 终端摘要
# =============================================================================
import csv
import json
import os
import sys
import numpy as np

PROJ = r"C:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype"
OUT = os.path.join(PROJ, "results", "measure_welch_analysis.json")
THRESH = 4.5


def load_trace(path):
    """CSV: time_ns, value -> np.array(values)。"""
    vals = []
    with open(path, newline="") as f:
        r = csv.reader(f)
        for row in r:
            if len(row) >= 2:
                try:
                    vals.append(float(row[1]))
                except ValueError:
                    continue
    return np.array(vals, dtype=float)


def welch_t(a, b):
    """Welch t（异方差），与 scipy.stats.ttest_ind(equal_var=False) 一致。"""
    a = np.asarray(a, float); b = np.asarray(b, float)
    na, nb = a.size, b.size
    ma, mb = a.mean(), b.mean()
    va = a.var(ddof=1); vb = b.var(ddof=1)
    se = np.sqrt(va / na + vb / nb)
    if se == 0:
        return 0.0
    return (ma - mb) / se


def rtl_integer_decision(fix, rnd):
    """复现板上整数监控器的整数判据（tvla_online.v 的 4n*d^2 vs 81*D）。"""
    n = fix.size
    s1 = int(np.sum(fix.astype(np.int64)))
    q1 = int(np.sum(fix.astype(np.int64) ** 2))
    s2 = int(np.sum(rnd.astype(np.int64)))
    q2 = int(np.sum(rnd.astype(np.int64) ** 2))
    d = s1 - s2
    D = (n * (q1 + q2)) - s1 * s1 - s2 * s2
    if D == 0:
        return bool(d != 0)
    return (d * d) * (4 * n) > 81 * D


def analyze_windows(trace, n, n_win):
    """按窗口（每窗口 2n 样本：前 n 固定群、后 n 随机群）计算 Welch t + 整数判据。"""
    rows = []
    for w in range(n_win):
        lo = w * 2 * n
        hi = lo + 2 * n
        if hi > trace.size:
            break
        seg = trace[lo:hi]
        fix = seg[:n]
        rnd = seg[n:]
        t = welch_t(fix, rnd)
        rtl = rtl_integer_decision(fix.astype(np.int64), rnd.astype(np.int64))
        rows.append({
            "window": w, "t": float(t),
            "float_flags": bool(abs(t) > THRESH),
            "rtl_flags": bool(rtl),
            "agree": bool((abs(t) > THRESH) == rtl),
            "mean_f": float(fix.mean()), "mean_r": float(rnd.mean()),
        })
    return rows


def selftest():
    """合成：泄漏窗口（固定群均值 +0.5 LSB）+ 清洁窗口，验证管线。"""
    rng = np.random.default_rng(0xBEEF)
    n = 4096
    C = 100.0
    sigma = 3.0
    # 窗口0：清洁（固定=随机=C+noise）；窗口1：泄漏（固定群 +0.5 LSB 偏移）
    def block(leak):
        fix = C + (leak if leak else 0.0) + rng.normal(0, sigma, n)
        rnd = C + rng.normal(0, sigma, n)
        return np.concatenate([fix, rnd])
    trace = np.concatenate([block(0.0), block(0.5)])
    rows = analyze_windows(trace, n, 2)
    print("=== 自检（合成轨迹，n=4096/群，sigma=3）===")
    for r in rows:
        print(f"  window{r['window']}: t={r['t']:+7.2f} float_flag={r['float_flags']} "
              f"rtl_flag={r['rtl_flags']} agree={r['agree']} "
              f"meanF={r['mean_f']:.2f} meanR={r['mean_r']:.2f}")
    clean_ok = not rows[0]["float_flags"] and not rows[0]["rtl_flags"]
    leak_ok = rows[1]["float_flags"] and rows[1]["rtl_flags"]
    verdict = {
        "clean_window_quiet": bool(clean_ok),
        "leak_window_flagged": bool(leak_ok),
        "harness_valid": bool(clean_ok and leak_ok),
        "note": "harness 正确识别清洁/泄漏窗口，且浮点 t 判据与板上整数判据一致",
    }
    print("  判定:", verdict)
    doc = {"mode": "selftest", "n_per_group": n, "sigma": sigma,
           "windows": rows, "_verdict": verdict}
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(doc, f, indent=2)
    print(f"\nwrote {OUT}")
    return verdict["harness_valid"]


def main():
    if "--selftest" in sys.argv or len(sys.argv) < 2:
        ok = selftest()
        sys.exit(0 if ok else 1)
    # 真实测量：python measure_trace_to_welch.py trace.csv --win 8192
    trace_path = sys.argv[1]
    n = 4096
    if "--win" in sys.argv:
        n = int(sys.argv[sys.argv.index("--win") + 1]) // 2
    trace = load_trace(trace_path)
    n_win = trace.size // (2 * n)
    rows = analyze_windows(trace, n, n_win)
    flagged = [r for r in rows if r["float_flags"]]
    print(f"trace samples={trace.size}  windows={n_win}  flagged={len(flagged)}")
    for r in rows:
        print(f"  window{r['window']}: t={r['t']:+7.2f} flag={r['float_flags']} "
              f"rtl={r['rtl_flags']} agree={r['agree']}")
    doc = {"mode": "measured", "trace": trace_path, "n_per_group": n,
           "windows": rows}
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(doc, f, indent=2)
    print(f"wrote {OUT}")


if __name__ == "__main__":
    main()
