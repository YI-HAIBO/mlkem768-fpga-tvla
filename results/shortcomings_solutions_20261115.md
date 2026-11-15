# ACM TECS 投稿论文——短板/不足/漏洞/局限清单与逐条解决方案

**论文**：`manuscript_tecs.tex`（ML-KEM-768 FPGA 协处理器，片上整数 Welch t-test 泄漏自监测，Artix-7 xc7a100tcsg324-1）
**日期**：2026-11-15
**范围**：含论文中已诚实披露的所有局限（"包括在论文中已披露的"）。

---

## 总览

| # | 短板/局限 | 性质 | 处置状态 | 解决方案 |
|---|---|---|---|---|
| 1 | n_eff 统计表征错误（AR(1) 给出 463，被空闲结构主导，高估 27×） | **错误（漏洞）** | ✅ **已实证攻克** | 已完成：基于真实 22.56 M 样本重算 n_eff≈17，论文 4 处改写 |
| 2 | 检测灵敏度归因（原归因于统计功效） | 归因不准 | ✅ **已更正** | 已完成：明确量化地板（1 LSB）为限制因素 |
| 3 | 功耗为仿真/门级估算，非物理实测 | 固有限制 | 待工程 | 板级物理功耗测量 + 仿真标定（A/B） |
| 4 | pre-silicon，未流片 | 固有限制 | 待工程 | 板级闭环在环 → ASIC 综合 → MPW 流片（三阶段） |
| 5 | 100 MHz 签核 vs 12.5 MHz 板级演示 | 固有限制 | 待工程 | 时序闭合报告附表 + 板级升频实测 |
| 6 | 仅一阶/恒定权重不变量；不覆盖算术通路/系数存储；不检测高阶 | 固有限制 | 待工程 | 架构扩展：抽头复用 + 二阶矩检测 + 掩码对照（6a/6b/6c） |
| 7 | TRNG/PUF 为蒙特卡洛跨芯片仿真 | 固有限制 | 待工程 | 板级熵源实测（NIST SP 800-90B / AIS-31）+ 模型校准 |
| 8 | 固定-随机 t-test 对 PQC 不充分；种子寄存器检测为概念验证 | 固有限制 | 待工程 | 对照扩展 + 攻击视角验证 + 部署化（8a/8b/8c） |
| 9 | 入口效率阈值语境（throughput 上下文） | 语境限制 | 待补充 | 完整三操作基准 + 监控开销-灵敏度权衡曲线 |
| 10 | 仅 Artix-7 xc7a100t 适用 | 固有限制 | 待工程 | 监控器参数化 + 多器件/多节点综合 |

> 说明：#1、#2 为**已发现并实证攻克的统计漏洞**（上一轮完成）；#3–#10 为论文中**已诚实披露的真实固有限制**，非错误，其解决方案为具体工程/方法学路径（需硅/物理测量/架构扩展，不可用 desk-work 捏造结论替代）。

---

## #1 n_eff 统计表征错误（AR(1) 高估 27×）—— ✅ 已实证攻克

**原文（已修正）**：原公式 `n_eff = n(1-ρ)/(1+ρ)` 代入原始流 ρ=0.797 得 n_eff≈463；真实泄漏相关有效数应为 n_eff≈17。

**问题**：代理流 99.48% 为 0（空闲预充电值主导），ρ=0.797 反映的是空闲结构而非泄漏信息，AR(1) 公式在此不成立，n_eff 被高估约 27 倍，导致检测下限被严重低估（0.13→0.70 d_min）。

**解决方案（已完成）**：
1. 新建 `verify/analyze_tvla_bootstrap.py`，对真实 22,563,008 样本流（`results/proxy_rand.txt`）重新分析：流 99.48% 为 0、每 4096 窗口仅 ≈21 个信息性样本、信息性样本 ρ≈0.11 → 泄漏相关 n_eff≈17。
2. 论文 4 处改写（行 213/446/462/537）：d_min 0.13→**≈0.70**；检测下限 0.04→**≈0.22 LSB**；FPR 6.9×10⁻⁶→**8.4×10⁻⁵**；评估在约 **1/240** 标称样本数下；1.5 LSB 演示余量 37×→**约 7×**；并诚实标注原 AR(1) 463 为误导值。
3. 重编译通过：19 页 / 0 错误 / 0 undefined / 0 Overfull。
4. **跟进建议**：将 `verify/analyze_tvla_bootstrap.py` 与 `results/tvla_bootstrap_analysis.json` 纳入公开仓库 `verify/` 目录（当前不在 833 文件仓库内），作为可复现统计证据供审稿人复核。

---

## #2 检测灵敏度归因（量化地板 vs 统计功效）—— ✅ 已更正

**原文（已修正）**："the six-bit quantization floor of one LSB is therefore the limiting factor on detection sensitivity, not the statistical power of the test."

**问题**：原表述将灵敏度受限部分归因于统计功效（受 n_eff 错误影响）；实际限制因素是六位代理的量化地板（1 LSB）。

**解决方案（已完成 + 跟进）**：
1. 已在行 213 明确量化地板（1 LSB）为灵敏度上限，统计功效不再被视为瓶颈。
2. **跟进建议**：给出"proxy 位宽 vs 可检测下限"灵敏度-位数曲线——若位宽提升至 8 bit（需换 DSP 资源更宽的器件，见 #10），检测下限可由 ≈0.22 LSB 降至 ≈0.06 LSB（按 d_min·σ_pooled 近似缩放），量化说明位宽扩展的直接收益。

---

## #3 功耗为仿真/门级估算，非物理实测 —— 待工程

**原文**：L40 "gate-level annotated dynamic power of 0.266 W, **a simulation estimate rather than a measured value**"；L68 "The only witness to a hiding countermeasure is a physical power measurement, which a deployed node does not possess."

**影响**：0.266 W 与 61% 活动注释覆盖是门级估算，非硅上实测；审稿人可能质疑泄漏结论缺少物理证据。

**解决方案**（两条并行路径）：
- **A（板级物理测量，近期可行）**：在 Nexys4 DDR 板 VCCINT 供电通路串入 50 mΩ 采样电阻（或利用板载电流监测），用差分探头 + 示波器（≥500 MHz 带宽、≥1 GS/s）采集 8192 周期窗口的电流/功耗波形；对实测轨迹做 Welch t，与板载整数监控器健康位**逐窗口对照**，验证"监控器所见 = 物理泄漏所见"。可加做近场 EM 探头扫描作交叉验证。产出：实测动态功耗（替代 0.266 W 估算）+ 实测 t 序列 + 一致性判定。
- **B（测量数据回流仿真）**：用实测电流波形标定泄漏模型参数（σ_pooled、ρ、有效位数），重跑注入模型，使仿真 t 与实测 t 吻合（calibration loop），把"仿真值"升级为"校准后仿真值"。

**落地**：板级测量台架 + 扩展实测章节/技术报告。**可行性**：高（板卡已有，仅需测量台架）。

---

## #4 pre-silicon，未流片 —— 待工程

**原文**：L531 "the device is at the **pre-silicon stage**, so power is reported as a gate-level estimate."

**影响**：全部结果来自仿真/板级功能演示，无真实硅上实测，安全性主张（防泄漏）缺硅证据。

**解决方案**（三阶段路线图）：
- **近期（板级闭环在环，FIL）**：在真实 Artix-7 板上运行完整 key establishment（KeyGen/Encaps/Decaps + 熵源 + 自检），板载监控器产出**硬件实测健康位序列**，并实测资源/时序/功耗；从"功能演示"升级为"闭环在环验证"。
- **中期（ASIC 综合）**：以标准单元 ASIC 流程（RTL→综合→布局布线→门级仿真）在 28nm/40nm 库上合成，报告时序/面积/功耗，论证 tape-out readiness。
- **远期（MPW 流片）**：参加多项目晶圆流片，获取硅上功耗/电磁实测，验证监控器在真实硅上的行为与灵敏度。

**落地**：板级 FIL 报告 → ASIC 综合报告 → MPW 流片计划。**可行性**：板级高、ASIC 中、MPW 需经费/时间。

---

## #5 100 MHz 签核 vs 12.5 MHz 板级演示 —— 待工程

**原文**：L285/L551 "The reported slack values are **static post-route sign-off results for the 100 MHz constraint**; the board-level functional demonstration ... runs with the board clock divided **12.5 MHz**."

**影响**：宣称 100 MHz 签核，但板级只演示 12.5 MHz，审稿人可能认为 100 MHz 未在硬件上验证。

**解决方案**：
- **A（时序闭合报告）**：在 Vivado 中约束 100 MHz 并给出正式 sign-off 附表（setup/hold WNS、TNS、最大可达频率 Fmax），确认 100 MHz 静态闭合真实成立（已静态闭合，需固化为正式附表）。
- **B（板级升频）**：板级演示时钟由 12.5 MHz 提升——用 MMCM/PLL 生成 50/100 MHz，关闭调试路径（UART/ILA）后实测功能正确 + 健康位行为；若 I/O/时钟域布线受限无法达 100 MHz，则报告实测 Fmax 与瓶颈，并给出达 100 MHz 的工程建议（降低扇出、调整流水级、收紧 I/O 约束）。

**落地**：时序闭合附表 + 板级升频实测。**可行性**：高（P&R 已闭合 100 MHz；板级受 I/O 约束，可优化）。

---

## #6 仅一阶/恒定权重不变量；不覆盖算术通路/系数存储；不检测高阶泄漏 —— 待工程

**原文**：L226-228 "It is a **first-order test only**; it does not certify any arithmetic masking (none is used), it does not **cover the arithmetic datapath or the coefficient memory** that lie outside the monitored buses, and it **cannot detect higher-order leakage**."

**影响**：监控器只监视受保护总线的一阶 Hamming 权重，覆盖范围有限。

**解决方案**（三路架构扩展）：
- **6a 覆盖扩展**：增加代理抽头——在算术通路（NTT/乘法器输出）与系数/密钥共享存储（分布式 RAM 数据口）各加一个 Hamming 权重代理，与现有总线代理**时分复用**进同一监控器（或增至 2–3 路并行监控器）；报告每路 |t| 与健康位。
- **6b 高阶检测**：在整数引擎中增加二阶统计——对代理样本计算中心二阶矩（或成对乘积），构造"二阶 Welch t"（在 (X−mean)² 上做固定-随机对比），检测二阶泄漏；给出高阶 t 判据与仿真验证。
- **6c 掩码对照**：引入一阶布尔/算术掩码变体（可选，本设计为隐藏型），在掩码-未掩码对比下检验监控器；或将监控器扩展为"共享-共享"对照。

**落地**：RTL 扩展 + 门级仿真验证 + 论文扩展章节。**可行性**：中高（RTL 工作量适中，架构天然支持抽头复用）。

---

## #7 TRNG/PUF 为蒙特卡洛跨芯片仿真 —— 待工程

**原文**：L487/L494 "The fused entropy source was characterized statistically via a **cross-chip Monte Carlo simulation**; all entropy and physical unclonable function figures in this section are **simulation values, not silicon measurements**."

**影响**：熵源/PUF 指标（0.909 bits/bit min-entropy、唯一性 49.70%、可靠性 99.37%）均为仿真，非硅上实测。

**解决方案**：
- **A（板级实测）**：在真实板卡上运行板载熵源，采集 ≥1 Mbit 输出，做 **NIST SP 800-90B**（或 AIS-31）熵估计，报告实测 min-entropy、可重复性；PUF 需 ≥2 块板卡测 inter-chip Hamming distance（唯一性）与 intra-chip 可靠性。
- **B（模型校准）**：用实测熵统计校准蒙特卡洛模型参数，使仿真与实测熵率一致，把"仿真值"升级为"校准后仿真值"。

**落地**：板级熵测试台架 + 标准测试数据。**可行性**：高（板卡已有熵源，仅需采集 + 标准测试）。

---

## #8 固定-随机 t-test 对 PQC 不充分；种子寄存器检测为概念验证 —— 待工程

**原文**：L112 "The applicability of the fixed-versus-random Welch t-test to post-quantum implementations is, however, **not straightforward**"；L458/L479 "a **conceptual validation** of the engine's response, not the ..."（种子寄存器检测）。

**影响**：固定-随机 t-test 对 PQC（含哈希/拒绝采样/复杂密钥调度）的充分性存疑；种子缓冲演示属概念验证，未作为部署机制。

**解决方案**：
- **8a 对照扩展**：增加"固定-固定（不同种子）"与"随机-随机"作为基线/阴性对照，隔离非泄漏差异；采用固定-vs-随机 + 固定-vs-固定**双对比**，降低误报/漏报风险。
- **8b 攻击视角验证**：用 CPA/模板/深度学习辅助 SCA（CNN 分类器）在代理流上量化密钥恢复可行性与所需迹数，直接回应"该监控器是否阻止现实攻击"；给出攻击成功率 vs 迹数曲线。
- **8c 部署化**：把种子寄存器检测从概念验证提升为**部署为持续不变量监测**（结合 #6a 覆盖种子缓冲/密钥寄存器），并在 PQC 完整密钥调度（含 SHAKE/拒绝采样）下验证。

**落地**：仿真 SCA + 板级验证。**可行性**：中高（仿真数据已具备，需补充攻击脚本）。

---

## #9 入口效率阈值语境（throughput 上下文）—— 待补充

**原文**：L37/L519（资源/吞吐表，本工作 32,775 LUT、0.032 ms、1.06×10³ 面积-时间积）；L551 仅报告单一操作语境。

**影响**：效率指标只在特定语境（单一操作、特定频率）给出，缺少完整 API 与监控开销量化。

**解决方案**：
- **A（完整基准）**：报告 ML-KEM-768 三操作（KeyGen/Encaps/Decaps）各自的延迟/吞吐/能量，与同类实现做**同设备同工艺**对比；补充每操作的周期数与时钟周期。
- **B（权衡曲线）**：给出监控开销-灵敏度权衡曲线（监控器 LUT/DSP/能量 vs 可检测下限），显式量化"每增加一单位灵敏度所需资源"，供读者选工作点。
- **C（开销占比）**：明确监控器开销占比（已报告 601 LUT / 429 reg / 8 DSP ≈ 1.8% / 1.1%），补充**能量开销百分比**与监控器对 Fmax 的影响。

**落地**：完整基准表 + 权衡曲线。**可行性**：高（仿真数据齐备）。

---

## #10 仅 Artix-7 xc7a100t 适用 —— 待工程

**原文**：L529 "The reported figures are specific to this device family: the six-bit proxy width is set by the **DSP48E1 multiplier limit** of the xc7a100t and would be **re-justified on a different device**."

**影响**：六位代理宽度、阈值、监控器参数均绑定 xc7a100t，结论不可直接迁移。

**解决方案**：
- **A（参数化）**：把监控器参数化（proxy 位宽、每群样本数 n、阈值 4.5、DSP 可用性），RTL 用 generate/parameter 支持任意器件。
- **B（多器件综合）**：在 Zynq-7000 / Kintex-7 / UltraScale+ 上综合-布局-布线，报告 Fmax/面积/功耗；对每器件重新论证 proxy 位宽（UltraScale+ DSP 位宽更大，可提升至 8–10 bit，检测下限更低，见 #2 跟进）。
- **C（ASIC 节点）**：在 28/16nm 标准单元库上综合，论证位宽与器件无关性。

**落地**：参数化 RTL + 多器件综合表。**可行性**：高（Vivado 多器件支持）。

---

## 汇总：处置状态

- **✅ 已实证攻克/更正（2 项）**：#1 统计漏洞（n_eff 17 vs 463）、#2 灵敏度归因（量化地板）——已在论文落地并重编译。
- **⏳ 需工程/测量（7 项）**：#3 物理功耗、#4 硅验证、#5 板级升频、#6 覆盖/高阶、#7 熵源实测、#8 PQC 方法学、#10 多器件——给出具体三阶段/多路径路线图。
- **📊 需补充基准数据（1 项）**：#9 完整基准与权衡曲线——仿真数据已具备，可快速补齐。

> **诚实性说明**：#3–#10 的解决依赖真实硅片、物理功耗/电磁测量、架构扩展或新方法学，**无法通过桌面分析凭空"证明已解决"**。本表给出的是可执行的工程路径；在完成前，论文保留其原有范围陈述（这是正确且必要的学术诚实），不虚标、不捏造。
