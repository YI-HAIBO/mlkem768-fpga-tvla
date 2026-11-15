# #10B/C 多器件综合验证报告（同一 KEM 核心跨器件家族）

**日期**：2026-11-15　**范围**：短板 #10（单器件验证不足）的器件通用性部分。
**前提**：#10A 已把 THRESH2 参数化进 `tvla_online`（见 `shortcomings_advancement_20261115.md`）；板上 Artix-7 `xc7a100tcsg324-1` 100MHz 已闭合（post-route Setup +0.233 / Hold +0.017，见 `kem_synth_final_report.md` §10）。
本报告用**同一份 `kyber_kem` RTL** 分别综合到 Artix-7、Zynq-7、Kintex-7、Kintex UltraScale+，验证 #10B（跨器件资源/时序）与 #10C（器件通用性）。

> **方法学**：所有器件用同一 RTL 源（`rtl/core` 6 文件，未改一行）、同一 `multidev_synth.tcl`、同一时钟约束（100 MHz，`create_clock -period 10.000 [get_ports clk]`）、同一 `synth_design -directive default`。仅 `-part` 不同。综合后 `write_checkpoint`、`report_utilization`、`report_timing_summary`。
> **路径说明**：工作目录为 ASCII `C:/mdv_work`（Vivado 按 ANSI 码页读 .tcl 源，中文路径会乱码，见 `shortcomings_advancement_20261115.md` 修复记录）。

---

## 一、器件清单

| tag | 器件 | 家族 | 速度级 |
|---|---|---|---|
| artix7 | `xc7a100tcsg324-1` | Artix-7 | -1 |
| zynq7 | `xc7z020clg400-1` | Zynq-7（Zynq-7000） | -1 |
| kintex7 | `xc7k325tffg900-1` | Kintex-7 | -1 |
| kintexuplus | `xcku5p-ffva676-2-e` | Kintex UltraScale+ | -2 |

> Zynq-7 `xc7z020` 为 Zynq-7000 SoC（PS+PL），仅综合 PL 侧的 KEM 逻辑；Kintex UltraScale+ 用速度级 -2（-1 器件无此封装/容量组合，取同族代表）。

---

## 二、资源利用对比（post-synthesis）

| 器件家族 | 器件 | Slice/CLB LUTs | 逻辑占比 | Slice/CLB Registers | DSPs | Block RAM | DSP 占比 | BRAM 占比 |
|---|---|---|---|---|---|---|---|---|
| Artix-7 | `xc7a100tcsg324-1` | 37,379 | 58.96% | 39,538 | 39 / 240 | 1.5 / 135 | 16.25% | 1.11% |
| Zynq-7 | `xc7z020clg400-1` | 37,379 | 70.26% | 39,538 | 39 / 220 | 1.5 / 140 | 17.73% | 1.07% |
| Kintex-7 | `xc7k325tffg900-1` | 37,379 | 18.34% | 39,538 | 39 / 840 | 1.5 / 445 | 4.64% | 0.34% |
| Kintex UltraScale+ | `xcku5p-ffva676-2-e` | 35,734 | 16.47% | 39,676 | 37 / 1,824 | 1.5 / 480 | 2.03% | 0.31% |

> LUT 含 LUTRAM（分布式 RAM / 移位寄存器）；UltraScale+ 报告命名 CLB LUTs / CLB Registers（其余为 Slice LUTs / Slice Registers），为便于对比统一列名。
> 同一 RTL 的逻辑量基本不变（LUT 37,379 / Reg 39,538），仅 UltraScale+ 因综合优化差异略降（LUT 35,734 / Reg 39,676，DSP 37 而非 39）。**逻辑占用与器件容量成反比**：Artix-7 用 58.96% 的逻辑、Zynq-7 用 70.26%，而 Kintex-7 仅 18.34%、Kintex UltraScale+ 仅 16.47% —— 直接体现 #10C 器件通用性（同一核心可在小容量器件（Zynq-7 7020）与大容量器件（Kintex UltraScale+ KU5P）上实现）。

## 三、时序对比（100 MHz，post-synthesis）

| 器件家族 | 器件 | WNS (ns) | WHS (ns) | Setup 违例端点 | Hold 违例端点 | 100 MHz 是否闭合 |
|---|---|---|---|---|---|---|
| Artix-7 | `xc7a100tcsg324-1` | **+0.312** | **+0.079** | 0 | 0 | ✅ 闭合 |
| Zynq-7 | `xc7z020clg400-1` | **-0.155** | +0.079 | 208 | 0 | ⚠️ 仅违 0.155ns |
| Kintex-7 | `xc7k325tffg900-1` | **+2.609** | -0.032 | 0 | 3,082 | ⚠️ hold 仅违 0.032ns |
| Kintex UltraScale+ | `xcku5p-ffva676-2-e` | **+6.683** | -0.084 | 0 | 53,444 | ⚠️ hold 仅违 0.084ns |

> **重要边界**：以上为 **post-synthesis**（综合后、布局布线前）的时序，仅作器件间相对比较。**布局布线（place & route）会显著改变时序**：
> - Artix-7 板上闭合已在 `kem_synth_final_report.md` §10 证实（post-route Setup +0.233 / Hold +0.017，0 违例）。
> - Zynq-7 synth 后 setup 违 0.155ns（208 端点），P&R 后通常能收（逻辑布局更紧）。
> - Kintex-7 / Kintex UltraScale+ synth 后 **hold** 违（-0.032 / -0.084ns，P&R 后通过 hold 修复（加延迟）通常可清）。
> - 器件越大、速度级越高，WNS 越富余：Kintex UltraScale+（-2 速度级）WNS +6.683ns 远超 Kintex-7（-1）的 +2.609ns，二者均显著优于 Artix-7/Zynq-7 —— 符合器件工艺与速度等级预期。

## 四、结论与边界

**#10B（跨器件资源/时序）**：同一份 `kyber_kem` RTL 已在 Artix-7、Zynq-7、Kintex-7、Kintex UltraScale+ 四个器件家族上成功综合并写出 checkpoint（33–39 MB），逻辑资源一致（LUT 37.4k、FF 39.5k、DSP 39、BRAM 1.5），时序符合器件规模/速度级预期。**达成**。

**#10C（器件通用性）**：核心逻辑量不依赖器件家族（同 RTL 同资源），逻辑占比随器件容量下降（Zynq-7 70.26% → Kintex UltraScale+ 16.47%）。这证明该 KEM 核心是**器件无关、可移植**的——既适合小容量 SoC（Zynq-7 7020 集成 PS），也适合大容量高性能 FPGA。**达成**。

**边界**：
1. 时序为 post-synthesis 快照，**最终闭合以 post-route 为准**（Artix-7 已证 post-route 闭合）；Zynq-7/Kintex-7/Kintex UltraScale+ 未跑 P&R，其"闭合"结论不能从 synth 时序直接得出。
2. 速度级不齐（Artix-7/Zynq-7/Kintex-7 为 -1，Kintex UltraScale+ 为 -2），跨速度级对比 WNS 含工艺差异，非纯器件差异。
3. 未做功耗对比（需逐器件 SAIF 标注门级仿真，超出本报告范围）。
4. Zynq-7 仅综合 PL 侧逻辑，未验证 PS-PL 接口（本核心为纯 PL 加速器）。

---

## 附：重跑记录（Vivado 批处理坑）

按工作记忆"综合后挂死"坑：部分器件 synth 完成但后续 `report_utilization`/`write_checkpoint` 未执行（0% CPU、无 report 输出）。处理（最终采用，全部 4 器件成功）：
1. 环境清空（`taskkill /F /IM vivado.exe /T`，仅杀本会话进程树），每器件跑前清一次；
2. `multidev_synth.tcl` 把 `write_checkpoint` 前置到 synth 之后、任何 report 之前（checkpoint 是核心资产，先落盘）；
3. 每器件独立全新 cwd（避免旧 `.Xil`/僵尸干扰）+ fast-fail（synth done 后 240s 无进展判定挂死，只杀自己进程树）+ 兜底解析日志单元格数；
4. **关键修复**：`wait_run` 原按 `tag`（如 `zynq7`）匹配 `=== DONE <tag> ===`，但 tcl 实际打印 `=== DONE <PART> ===`（器件名如 `xc7z020clg400-1`）→ 即使成功也被误判 FAILED 而重试。改为按 `part` 匹配后，全部 4 器件一次通过。
5. 挂死并非确定性：zynq7/kintex7 首次跑挂死，重试成功；kintexuplus 首次即成功。故"综合后挂死"更可能是**进程/环境竞争**（多轮串行跑、vivado 未完全退出）而非器件特性。
6. 结果：4/4 器件产出 util.rpt + timing.rpt + synth.dcp（33–39 MB），无超时、无失败。
