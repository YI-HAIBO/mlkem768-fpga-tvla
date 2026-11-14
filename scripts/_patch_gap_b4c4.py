# -*- coding: utf-8 -*-
"""One-shot patch of docs/gap_analysis_sci_q1.md: fill the two 待填 cells with
the real B4/C4 Vivado numbers and refresh the 本次更新 bullets.

Single script (not parallel Edit calls) because parallel edits to the same file
race and silently drop updates (see user memory).
"""
import os
import io

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
P = os.path.join(ROOT, "docs", "gap_analysis_sci_q1.md")

PAIRS = [
    # 1. B4 row
    ("| B4 mpc_private_infer | ✅ | ✅ | ✅ 待填 | ❌ | ❌ |",
     "| B4 mpc_private_infer | ✅ | ✅ | ✅ **24,847 LUT / 2,645 FF**"
     "（WNS −0.822 ns，0 DSP） | ❌ | ❌ |"),
    # 2. C4 row
    ("| C4 puf_model_bind | ✅ | ✅ **10/10 + 24/24 黄金** | ✅ 待填 | ⚠️ 仿真攻击模型 | ❌ |",
     "| C4 puf_model_bind | ✅ | ✅ **10/10 + 24/24 黄金** | ✅ **13,178 LUT / 32,845 FF**"
     "（WNS +4.412 ns，>100 MHz） | ⚠️ 仿真攻击模型 | ❌ |"),
    # 3. negative-WNS module list gains B4
    ("> 注意：综合级 WNS 为负的模块（A2/A4/A5/B3/C1/C2）是**辅助/协处理器**，",
     "> 注意：综合级 WNS 为负的模块（A2/A4/A5/B3/B4/C1/C2）是**辅助/协处理器**，"),
    # 4. add directive + dissolution note after the existing note block
    ("> 这与主数据通道（unified_ntt / kyber_kem）100 MHz 收敛是两个问题。",
     "> 这与主数据通道（unified_ntt / kyber_kem）100 MHz 收敛是两个问题。\n"
     "> B4/C4 在 `default` 指令下会在 `synth_design` 打印完成信息之后**静默挂死**"
     "（Vivado 2026.1 的 `.Xil` 争用 / synthesis helper 被外部 runner 杀死所致），\n"
     "> 改用 `-directive RuntimeOptimized` 后分别在 240 s / 270 s 正常收敛；"
     "其余 10 个模块仍用 `default` 指令。\n"
     "> 另：B4/C4 的 **LUT as Memory = 0** —— 其 256 B 共享区 / 模型阵列被综合成"
     "寄存器 + 大 mux 树（C4 含 32,504 FDRE + MUXF7 4,404 + MUXF8 2,184），\n"
     "> 与 C1 修复前同一病因，属**已识别、尚未优化**的资源项（不影响功能正确性），列在 §7。"),
    # 5. refresh the 本次更新 bullets
    ("  资源/时序/功耗见 `results/synth_innovations_summary.md`：A3=26 LUT（最小）、\n"
     "  C2=216、A2=249、B1=531、C3=706、B3=601、B2=883、A4=2,465、A5=2,583、\n"
     "  C1=6,983（修复后）、B4/C4 见表。",
     "  资源/时序/功耗见 `results/synth_innovations_summary.md`：A3=26 LUT（最小）、\n"
     "  C2=216、A2=249、B1=531、C3=706、B3=601、B2=883、A4=2,465、A5=2,583、\n"
     "  C1=6,983（RAM 修复后）、**C4=13,178**、**B4=24,847** —— **12/12 全部有实测数字**，"
     "无待填项。\n"
     "- **B4/C4 综合挂死已定位并绕过**：根因不是设计，是本机并行运行的其他项目"
     "（hedge / fpga_ckks / tvla）的 runner 执行全局 `taskkill /F /IM vivado.exe`，\n"
     "  杀掉本项目的 synthesis helper，主进程阻塞在死对端（报告打完、0% CPU、永不返回）。"
     "隔离 runner（独立 cwd + 只杀自己的进程树 + fast-fail 重试）见\n"
     "  `scripts/synth_b4c4_isolated.py`，本次实际生效的是换 `RuntimeOptimized` 指令。"),
]


def main():
    txt = io.open(P, encoding="utf-8").read()
    for old, new in PAIRS:
        n = txt.count(old)
        if n != 1:
            raise SystemExit("MATCH FAIL (%d) for: %r" % (n, old[:60]))
        txt = txt.replace(old, new)
    io.open(P, "w", encoding="utf-8").write(txt)
    print("patched %d edits: %s" % (len(PAIRS), P))
    print("待填 remaining:", txt.count("待填"))


if __name__ == "__main__":
    main()
