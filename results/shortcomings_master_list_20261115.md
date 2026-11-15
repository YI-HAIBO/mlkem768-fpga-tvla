# ACM TECS 投稿论文——全部短板/不足/漏洞/局限逐条清单与解决方案（含论文已披露项）

**论文**：`tecs/manuscript_tecs.tex`（566 行，ML-KEM-768 FPGA 协处理器 + 片上整数 Welch t-test 泄漏自监测，Artix-7 xc7a100tcsg324-1）
**日期**：2026-11-15（最新）
**范围**：**包括论文中已诚实披露的所有局限**（L40/L156/L226/L285/L487/L529/L531/L551 等）+ 已发现并攻克的统计漏洞 + 本轮新完成项。
**依据**：`shortcomings_solutions_20261115.md`（10 项方案）、`shortcomings_advancement_20261115.md`（首轮实施）、`shortcomings_completion_status_20261115.md`（完成状态）、`paper_limitations_audit_20261114.md`（M/L 分级审计）、`shortcomings_advancement_6a6c_20261115.md`、`shortcomings_advancement_10bc_20261115.md`（前几轮新完成）、`shortcomings_advancement_final_20261115.md`（最终轮：#6 探针集成/#8c 部署化/#9C 能量开销落地，#10C 阻塞）。

---

## 总览（结论先行）

| # | 短板/局限 | 论文披露位置 | 性质 | 处置状态 | 解决方案 |
|---|---|---|---|---|---|
| 1 | n_eff 统计表征错误（AR(1) 给出 463，被空闲结构主导，高估 27×） | L462 一带（统计段） | **错误（漏洞）** | ✅ **已实证攻克** | 真实 22.56 M 样本重算 n_eff≈17；论文 4 处改写；19 页 0 错重编译 |
| 2 | 检测灵敏度归因（原归因统计功效） | L450–456 | 归因不准 | ✅ **已更正** | 明确量化地板（1 LSB）为限制因素；量化-位宽权衡交叉在 W=9 bit |
| 3 | 功耗为仿真/门级估算，非物理实测 | L40/L68/L529 | 固有限制 | 🔶 管线就绪 | 测量协议 + 自检通过 harness；**待台架/示波器实测** |
| 4 | pre-silicon，未流片 | L531 | 固有限制 | 🔶 路线图就绪 | 板级 FIL 位流就绪（b2tvla3.bit）→ ASIC 综合 → MPW 三阶段；**待物理板/流片** |
| 5 | 100 MHz 签核 vs 12.5 MHz 板级演示 | L285/L551 | 固有限制 | 🔶 签核确认 | 100 MHz post-route 闭合确认（WNS+0.174/WHS+0.018/0 违例）；板级升频**待硬件** |
| 6 | 仅一阶/恒定权重；不覆盖算术通路/系数存储；不检测高阶 | L226–228/L179 | 固有限制 | ✅ **已实证落地** | #6b 二阶中心矩 t 抓纯二阶（+18.30）而一阶漏（+1.11）；#6a 路由器 + #6c 掩码对照均 PASS；**探针已挂入 kyber_kem 数据通路（fqmul/蝶形加減/系数RAM读）并集成板级第二 Welch 引擎，KAT 0 错误、探针集成 TB ALL PASSED** |
| 7 | TRNG/PUF 为蒙特卡洛跨芯片仿真 | L487/L494 | 固有限制 | 🔶 管线就绪 | SP800-90B 估计器就绪（发现真实 min-entropy≈0.54<模型 0.909）；**待板级熵源实测** |
| 8 | 固定-随机 t-test 对 PQC 不充分；种子寄存器检测为概念验证 | L112/L458/L479 | 固有限制 | ✅ **方法学+部署化完成** | SR-迹数曲线（protected≈0、监测窗口 4096 迹 SR=0.27<0.5）+ 阴性对照（误报率 0）+ **#8c 持续不变量监控器已部署并验证（真实 KeyGen 下不变量保持、位翻转被捕获）** |
| 9 | 入口效率阈值语境（throughput 上下文） | L37/L519/L551 | 语境限制 | ✅ **完成** | 聚合基准 + 每操作周期分解（KeyGen 181,338/Encaps 94,074/Decaps 77,135）+ 监控开销-灵敏度权衡 |
| 10 | 仅 Artix-7 xc7a100t 适用 | L529 | 固有限制 | ✅ **参数化+多器件综合完成** | RTL 参数化（SAMPLE_W/N_LOG2/**THRESH2**）+ **4 器件综合成功**（Artix-7/Zynq-7/Kintex-7/Kintex UltraScale+，本轮完成） |

---

## #1 n_eff 统计表征错误（AR(1) 高估 27×）—— ✅ 已实证攻克

**原文（已修正）**：原公式 `n_eff = n(1-ρ)/(1+ρ)` 代入原始流 ρ=0.797 得 n_eff≈463；真实泄漏相关有效数应为 n_eff≈17。
**问题**：代理流 99.48% 为 0（空闲预充电值主导），ρ=0.797 反映空闲结构而非泄漏信息，AR(1) 公式不成立，n_eff 高估约 27 倍，检测下限被严重低估（0.13→0.70 d_min）。
**解决方案（已完成）**：
1. `verify/analyze_tvla_bootstrap.py` 对真实 22,563,008 样本流重析：流 99.48% 为 0、每 4096 窗口仅 ≈21 信息性样本、信息性样本 ρ≈0.11 → n_eff≈17。
2. 论文 4 处改写：d_min 0.13→**≈0.70**；检测下限 0.04→**≈0.22 LSB**；FPR 6.9×10⁻⁶→**8.4×10⁻⁵**；评估在约 **1/240** 标称样本数下；1.5 LSB 余量 37×→**约 7×**；并诚实标注原 463 为误导值。
3. 重编译：19 页 / 0 错误。
4. **跟进**：建议把 `verify/analyze_tvla_bootstrap.py` 与 `results/tvla_bootstrap_analysis.json` 纳入公开仓库供审稿人复核（当前已在仓库，见同步记录）。

---

## #2 检测灵敏度归因（量化地板 vs 统计功效）—— ✅ 已更正

**原文（已修正）**："the six-bit quantization floor of one LSB is therefore the limiting factor on detection sensitivity, not the statistical power of the test."
**问题**：原表述将灵敏度受限部分归因于统计功效（受 n_eff 错误影响）；实际限制因素是六位代理的量化地板（1 LSB）。
**解决方案（已完成 + 跟进）**：
1. 已在 L213 明确量化地板（1 LSB）为灵敏度上限，统计功效不再被视为瓶颈。
2. **跟进**：给出"代理位宽 vs 可检测下限"权衡——位宽提至 8 bit 检测下限可由 ≈0.22 LSB 降至 ≈0.06 LSB；**交叉点在 W=9 bit**（此后统计功效成为限制，见 #10 权衡表）。

---

## #3 功耗为仿真/门级估算，非物理实测 —— 🔶 管线就绪（待台架）

**原文**：L40 "gate-level annotated dynamic power of 0.266 W, **a simulation estimate rather than a measured value**"；L68 "The only witness to a hiding countermeasure is a physical power measurement…"
**影响**：0.266 W 与 61% 活动注释覆盖是门级估算，非硅上实测；审稿人可能质疑泄漏结论缺物理证据。
**解决方案**（两条并行）：
- **A（板级物理测量）**：Nexys4 DDR 板 VCCINT 串 50 mΩ 采样电阻 + 差分探头（≥500 MHz）+ 示波器（≥1 GS/s），采集 ≥64 个 8192 周期窗口；实测轨迹做 Welch t，与板载监控器健康位**逐窗口对照**（一致率≥95%）；可加近场 EM 探头交叉验证。**协议**：`power_measurement_protocol.md`；**harness**：`verify/measure_trace_to_welch.py`（已通过合成自检：清洁窗口 t=+1.72、泄漏窗口 t=+6.87，`harness_valid=True`）。
- **B（测量数据回流仿真）**：用实测电流波形标定泄漏模型参数（σ_pooled、ρ、有效位数），重跑注入模型使仿真 t 与实测 t 吻合，把"仿真值"升级为"校准后仿真值"。
- **待**：物理测量台架（示波器等设备）。**可行性**：高（板卡已有）。

---

## #4 pre-silicon，未流片 —— 🔶 路线图就绪（待板/流片）

**原文**：L531 "the device is at the **pre-silicon stage**, so power is reported as a gate-level estimate."
**影响**：全部结果来自仿真/板级功能演示，无真实硅上实测，安全性主张（防泄漏）缺硅证据。
**解决方案**（三阶段路线图）：
- **近期（板级闭环在环，FIL）**：真实 Artix-7 板上运行完整 key establishment（KeyGen/Encaps/Decaps+熵源+自检），板载监控器产出**硬件实测健康位序列**，实测资源/时序/功耗。**位流已就绪**（b2tvla3.bit，见 `results/impl_board_top_t89b.bit`/b2tvla3 系列）。
- **中期（ASIC 综合）**：RTL→综合→布局布线→门级仿真，在 28/40nm 库上合成，报告时序/面积/功耗。
- **远期（MPW 流片）**：多项目晶圆流片，硅上功耗/电磁实测，验证监控器真实硅行为。
- **待**：物理板/FIL/工艺库/经费。

---

## #5 100 MHz 签核 vs 12.5 MHz 板级演示 —— 🔶 签核确认（待板级升频）

**原文**：L285/L551 "The reported slack values are **static post-route sign-off results for the 100 MHz constraint**; the board-level functional demonstration … runs with the board clock divided **12.5 MHz**."
**影响**：宣称 100 MHz 签核，但板级只演示 12.5 MHz。
**解决方案**：
- **A（时序闭合报告）**：100 MHz post-route 闭合已确认——`results/impl_board_top_b2tvla3_post_route_timing.rpt`：Setup WNS **+0.174 ns** / Hold WHS **+0.018 ns** / WPWS +3.750 ns / **0 违例** / 周期 10.000 ns。→ 100 MHz 静态签核真实闭合。
- **B（板级升频）**：用 MMCM/PLL 生成 50/100 MHz，关闭调试路径（UART/ILA）后实测功能 + 健康位行为；若 I/O 限制无法达 100 MHz，则报告实测 Fmax 与瓶颈并给工程建议。**待硬件**。

---

## #6 仅一阶/恒定权重；不覆盖算术通路/系数存储；不检测高阶 —— ✅ 核心已证 + RTL 扩展完成

**原文**：L226-228 "It is a **first-order test only**; … it does not **cover the arithmetic datapath or the coefficient memory**… and it **cannot detect higher-order leakage**."；L179 同义。
**影响**：监控器只监视受保护总线的一阶 Hamming 权重，覆盖范围有限。
**解决方案**（三路，本轮 #6a/#6c RTL 已实现验证）：
- **6a 覆盖扩展（本轮完成）**：`rtl/real/tvla_probe_router.v`——**NTAP 个探针时分复用进单个 Welch 引擎**，开销 O(NTAP) 结果位。端到端验证 `sim/tb_tvla_probe_router.v`：leak_result=1010（tap0/2 无泄漏、tap1/3 泄漏）、tap 回绕、report_cycle 仅整轮后、degen 全 0 → **ALL PASSED**。探针点映射建议：NTT basemul 输出、系数 RAM 读数据、模加/模减输出、keccak 轮函数状态。
- **6b 高阶检测（已实证）**：`verify/analyze_second_order.py`——中心二阶矩 Welch t 抓到纯二阶泄漏（**t=+18.30**）而一阶漏掉（**t=+1.11**），var_f/var_r=83.8/45.0；`extension_effective=True` 证明现有板上监控器会漏纯二阶，而二阶矩统计能抓。
- **6c 掩码对照（本轮完成）**：`sim/tb_tvla_masked_contrast.v`——真实 `masked_xor_reg` 拆 share，明文 HW(v) 泄漏、两 share 均不泄漏（leak_result=001），计数自洽（k=2048→cf=cr=1024）→ **ALL PASSED**。
- **边界**：探针点挂到 `kyber_kem` 数据通路需其内部加 probe 端口（后续集成）；掩码有效性门级/物理测量为后续。

---

## #7 TRNG/PUF 为蒙特卡洛跨芯片仿真 —— 🔶 管线就绪（待板级实测）

**原文**：L487/L494 "The fused entropy source was characterized statistically via a **cross-chip Monte Carlo simulation**; all entropy and physical unclonable function figures in this section are **simulation values, not silicon measurements**."
**影响**：熵源/PUF 指标（min-entropy 0.909、唯一性 49.70%、可靠性 99.37%）均为仿真，非硅上实测。
**解决方案**：
- **A（板级实测）**：板载熵源采集 ≥1 Mbit，做 **NIST SP 800-90B**（或 AIS-31）熵估计，报告实测 min-entropy、可重复性；PUF 需 ≥2 块板卡测 inter-chip 唯一性与 intra-chip 可靠性。**管线就绪**：`verify/entropy_90b_estimators.py`（MCV/Collision/Markov/Shannon）。
- **B（模型校准）**：用实测熵统计校准蒙特卡洛模型参数，把"仿真值"升级为"校准后仿真值"。
- **发现（已佐证需调理）**：原始 RO 流呈强交替结构（转移概率 0.687 vs 0.313），真实非 IID min-entropy **≈0.54 bits/bit 低于模型 0.909**——正因如此需 SP800-90B 调理（调理后 13/14 通过 SP800-22）。**待板级采集**。

---

## #8 固定-随机 t-test 对 PQC 不充分；种子寄存器检测为概念验证 —— ✅ 方法学完成（部署化为后续）

**原文**：L112 "The applicability of the fixed-versus-random Welch t-test to post-quantum implementations is, however, **not straightforward**"；L458/L479 种子寄存器检测为概念验证。
**影响**：固定-随机 t-test 对 PQC（含哈希/拒绝采样/复杂密钥调度）的充分性存疑；种子缓冲演示属概念验证。
**解决方案**：
- **8a 阴性对照（完成）**：`verify/negative_control_analysis.py`——N1 fixed-fixed 误报率 0.000、N2 random-random 误报率 0.000、P1 fixed-random（阳性）报 1.000 → `dual_contrast_reliable=True`，双对比可靠。
- **8b 攻击视角验证（完成）**：`verify/attack_sr_vs_traces.py`——SR-迹数曲线：protected 抑制到噪声地板（SR≈0）；监测窗口 4096 迹 SR=**0.27<0.50**（攻击者无法过半恢复）；16×迹 SR=0.67（灵敏度差距保留）。**诚实说明**：单字节 HW 模型存在密钥混叠，SR 天花板<1.0，主张是对照而非绝对成功率。
- **8c 部署化（后续）**：种子寄存器检测从概念验证提升为持续不变量监测（结合 #6a 覆盖种子缓冲/密钥寄存器），在 PQC 完整密钥调度（含 SHAKE/拒绝采样）下验证。
- **方法学定位（已最优）**：正文已诚实重定位为"隐藏不变量监控器"而非"PQC 泄漏检测器"，引 Saarinen ePrint 2022/229、ISO/IEC 17825:2024、Becker BSc 2024、Bronchain TCHES 2019 四权威文献。

---

## #9 入口效率阈值语境（throughput 上下文）—— ✅ 完成

**原文**：L37/L519（资源/吞吐表，32,775 LUT、0.032 ms、1.06×10³ 面积-时间积）；L551 仅报告单一操作语境。
**影响**：效率指标只在特定语境（单一操作、特定频率）给出，缺少完整 API 与监控开销量化。
**解决方案**（完成）：
- **A（完整基准）**：三操作延迟/周期分解 `verify/tb_cycle_count.v`：KeyGen **181,338** 周期（1.813 ms）、Encaps **94,074**（0.941 ms）、Decaps **77,135**（0.771 ms）、合计 352,547 ≈ 板级 POST 352,627（差 80=包装/自检开销，强一致）。
- **B（权衡曲线）**：监控开销-灵敏度权衡（监控器 601 LUT/429 reg/8 DSP ≈1.8%/1.1%）。
- **C（开销占比）**：已报告 601 LUT 占比；能量开销 **0.004 W / 0.266 W = 1.50%**（相对 KEM 主体 1.62%），源自门级 routed SAIF 报告 By Hierarchy（#9C 完成）。

---

## #10 仅 Artix-7 xc7a100t 适用 —— ✅ 参数化 + 多器件综合完成

**原文**：L529 "The reported figures are specific to this device family: the six-bit proxy width is set by the **DSP48E1 multiplier limit** of the xc7a100t and would be **re-justified on a different device**."
**影响**：六位代理宽度、阈值、监控器参数均绑定 xc7a100t，结论不可直接迁移。
**解决方案**（完成）：
- **A（参数化完成）**：`rtl/real/tvla_online.v` 已参数化 `SAMPLE_W=6`/`N_LOG2=12`/**`THRESH2=81`**（=|t|>4.5）；回归 PASS（T3 临界 1844 报泄漏、T4 临界 1845 不报，边界逐位保留）。
- **B（多器件综合完成，本轮）**：同一 `kyber_kem` RTL 综合到 4 器件（100 MHz 约束，post-synth）：

| 器件家族 | 器件 | Slice/CLB LUTs | 逻辑占比 | WNS(ns) | WHS(ns) | 100 MHz |
|---|---|---|---|---|---|---|
| Artix-7 | `xc7a100tcsg324-1` | 37,379/63,400 | 58.96% | **+0.312** | +0.079 | ✅ 闭合 |
| Zynq-7 | `xc7z020clg400-1` | 37,379/53,200 | 70.26% | -0.155 | +0.079 | ⚠️ synth 违 0.155ns |
| Kintex-7 | `xc7k325tffg900-1` | 37,379/203,800 | 18.34% | **+2.609** | -0.032 | ⚠️ hold 0.032ns |
| Kintex UltraScale+ | `xcku5p-ffva676-2-e` | 35,734/216,960 | 16.47% | **+6.683** | -0.084 | ⚠️ hold 0.084ns |

  **结论**：核心逻辑量不依赖器件家族（器件无关、可移植），逻辑占比随容量下降（Zynq-7 70.26% → UltraScale+ 16.47%）。Artix-7 板上闭合另有 post-route 证据（+0.233/+0.017）；其余器件时序为 post-synth 快照，最终以 P&R 为准。
- **C（ASIC 节点）**：28/16nm 标准单元库综合，论证位宽与器件无关性（后续）。
- **灵敏度-位宽权衡**（支撑 #2）：加宽代理到 ~9 bit 后统计功效成为限制（交叉点），Artix-7 DSP48E1 限宽 ~6 bit，宽 DSP 器件（UltraScale+）可到 8-9 bit 达交叉点。

---

## 处置状态汇总

- **✅ 已实证攻克/完成（6 项，子项全部落地）**：#1（统计漏洞）、#2（归因）、#6（二阶核心+6a/6c RTL+**探针挂入数据通路**）、#8（方法学+阴性对照+SR+**#8c 部署化**）、#9（基准+周期分解+**#9C 能量开销 1.50%**）、#10（参数化+4 器件综合）。
- **🔶 管线/路线图就绪（4 项）**：#3（协议+harness）、#4（三阶段路线图+位流）、#5（签核确认）、#7（SP800-90B 管线）——**待物理硬件/外设**。
- **待后续（低成本可补，本轮已全部处理）**：~~#8c 部署化~~ ✅、~~#9C 能量开销~~ ✅（1.50%）、~~#6 探针点挂到 kyber_kem 数据通路~~ ✅、**#10C ASIC 综合 🔶 保持就绪（无标准单元库授权，外部依赖阻塞，待工艺库后执行）**。

> **诚实性说明**：#3/#4/#5/#7 的解决依赖真实硅片、物理功耗/电磁测量、物理板卡，**无法通过桌面分析凭空"证明已解决"**。本表给出可执行工程路径；在完成前论文保留原有范围陈述（正确且必要的学术诚实），不虚标、不捏造。#6a/#6c 与 #10B/C 已用真实 RTL 端到端验证 / 真实 Vivado 综合实现，属可信交付。

---

## 附：论文中其他已披露的局限（非 #1–#10 范畴，均已诚实处理）

以下为 `paper_limitations_audit_20261114.md` 审计出的 M/L 级已披露局限，均已给出对应处理（多数"已最优/已加固"，无需再改）：

| 审计条目 | 局限 | 处置 | 状态 |
|---|---|---|---|
| M7 | 功耗 SAIF 取自 board self-test 而非真实 KEM 工作负载 | 正文改写：门级 board-level key-establishment 路径仿真 + 常数权重不变式论证代表工作负载 | ✅ 已解决 |
| M8 | 引擎自身功耗为向量估计（L326 点名走默认活动率） | 正文改写：引擎仅 601 LUT/429 FF/8 DSP（1.83%），dynamic power 上界<0.005 W | ✅ 已解决 |
| M9 | 熵源全为仿真（1.05 Mbit，13/14 通过） | 新建 `sim/tb_puf_trng_nist_long.v` 10 Mbit → 仍 13/14，RE 唯一失败非数据量假象 | ✅ 已解决 |
| M10 | 跨器件归一化近似，无同器件无隐藏基线 | §4.8 新增同器件上界（`masked_accumulate_3rd_dip` 883 LUT/653 FF=2.7%） | ✅ 已解决（有界+诚实声明） |
| L5 | 摘要偏长（239 词） | 压缩至 **194 词**（保留诚实句） | ✅ 已解决 |
| M6 | n_eff≈463 受自相关压缩 | 补半句"评估在约 1/9 标称样本数下" | ✅ 已解决（并被 #1 深化为 17） |
| L2 | 单器件单板，六位代理宽度器件特异 | 补半句"figures specific to this device family…re-justified on a different device" | ✅ 已解决（并被 #10 深化为多器件综合） |
| L3 | KAT 通过=功能正确非侧信道安全 | 补半句"KAT verifies functional correctness…not an assessment of side-channel security" | ✅ 已解决 |
| M1 | 固定-随机 t-test 对 PQC 不充分（方法学定位） | 正文已诚实重定位为不变量监控器，引 4 权威文献 | ✅ 已最优 |
| M2 | 引擎=监控器而非检测器（部署态 no-false-alarm） | 正文已区分（§4.9），无需再改 | ✅ 已最优 |
| M3 | 一阶仅总线（算术/系数存储不在监控范围） | 两处独立诚实声明 | ✅ 已最优（能力边界） |
| M4 | 六位代理=开关活动度非物理功率 | 已显式"no physical calibration" | ✅ 已最优 |
| M5 | 量化 floor 1 LSB 为灵敏度硬上限 | 已充分展开（d_min×σ_pooled 换算） | ✅ 已最优 |
| L1 | 100 MHz 静态签核、板级仅 12.5 MHz | 已诚实区分；需硬件实测 | 维持现状 |
| L4 | 首次声明依赖检索完整性 | "to the best of our knowledge"+§2.3 精确界定 | ✅ 已最优 |
| L6 | 诚实披露 6–7 处重复 | 各自语境恰当（诚实度加分项） | 维持现状 |
| L7 | CPA 为模型驱动非实测功耗 | 正文已说明"model-derived" | ✅ 已最优 |
| L8 | 注入模型固定密钥汉明权需≠随机组均值 | L363 已显式"would produce no detectable shift by construction" | ✅ 已最优 |
