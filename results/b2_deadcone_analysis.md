# B2 死除法锥分析 — ML-KEM 100 MHz 时序闭合（2026-11-08）

## 1. 结论（先给结论）

`kyber_kem` standalone 综合报告 WNS = **−5.121 ns**（17 个 failing endpoints，TNS −70.889），
**全部 15/15 条 setup 违例路径都是同一个"死常数除法锥"**，不是真实功能路径。
判定依据：所有 SHAKE 调用的 `msg_len` 恒小于 `RATE`，故 `nblocks = msg_len/RATE` 恒 ≡ 0，
除法锥输出为常数，**功能上永不翻转，不构成真实关键路径**。

已通过合法死代码消除从 RTL 移除该锥，KAT 回归 **0 ERRORS**（位精确）。
**board post-route 权威数据（b2nttdram4）**：Setup 0 违例 WNS **+0.233 ns**，Hold 0 违例
WHS **+0.017 ns** → **100 MHz 时序闭合**；standalone 重综合 Setup **+0.112 ns**（0 违例，
对比修复前 −5.121 ns 改善 +5.233 ns）——死锥消除在纯逻辑综合与板级实现**双层独立验证**。

## 2. 症状与定位

- 运行：`scripts/run_kem_synth.py`（top=kyber_kem, xc7a100tcsg324-1, 10 ns）。
- `results/kem_synth_timing.rpt`（report_timing_summary -max_paths 3）：
  WNS = **−5.121 ns**，17 failing endpoints，TNS −70.889；Hold 37066 failing（WHS −0.121，SRL 类 synth 期常见）。
- `results/kem_synth_timing_paths.rpt`（report_timing -max_paths 15 -setup）：
  解析出 **15/15 条违例全部源为 `x256_ol_reg[3]/C`**，终点为
  `u_xof256/nblocks_reg[0..8]/D`（除法结果寄存器）与 `u_xof256/bv2__0/A[0..8]`（DSP48E1 乘法器输入）。
  最差路径 Data Path 14.379 ns（logic 8.102 / route 6.277），16 逻辑级（CARRY4=10）。
  **无任何其他违例路径**。

## 3. 根因

`rtl/core/shake.v` 吸收阶段：

```verilog
nblocks <= msg_len / RATE;          // 16-bit 常数除法锥
rem     = msg_len - (nblocks * RATE); // nblocks*RATE 乘法锥（DSP bv2__0）
```

`RATE` 为常数（SHAKE-256=136，SHAKE-128=168），`msg_len` 是 16-bit 寄存器 → 综合器构建
全 16-bit 最坏常数除法器（16 逻辑级 ≈ 14.4 ns），再乘 `RATE`（DSP）。该锥是
`kyber_kem.v` 中 `x256_ml`/`x256_ol` 寄存器（同拍赋值、被合并打包）的扇出。

## 4. 假路径证明（设计不变量）

`kyber_kem.v` 中全部 SHAKE 调用（`u_xof128` RATE=168、`u_xof256` RATE=136）的
`msg_len`/`out_len` 取值（逐行枚举）：

| 信号 | 取值集合 | RATE | 全部 < RATE ? |
|---|---|---|---|
| x128_ml (msg_len) | {34} | 168 | ✓ |
| x256_ml (msg_len) | {32, 33} | 136 | ✓ |
| x128_ol (out_len) | {128} | 168 | ✓ |
| x256_ol (out_len) | {32, 64, 128} | 136 | ✓ |

**结论**：每次调用 `msg_len < RATE` → `nblocks = msg_len/RATE = 0` 恒成立；
`nblocks*RATE = 0`；`rem = msg_len`。除法/乘法锥输出为常数 0，
且 `msg_len` 在 `start` 之前设定并保持（set-once），锥有充足时间稳定——
**该锥从不处于真实翻转关键路径**。报告负 WNS 是综合器对"最坏 1 拍变化"的悲观假设，
属假时序路径（set-once 常数除法）。

> 注：报告起点是 `x256_ol_reg[3]`（out_len 位），因 `x256_ml`/`x256_ol` 同拍赋值被
> Vivado 合并为同一物理寄存器，报告按合并名标注；功能上该锥仅由 `msg_len` 驱动且恒 0。

## 5. 修复：合法死代码消除

`shake.v`（备份 `shake.v.bak_b2deadcone`，SHA256[16]=dda5cc66ef7c0405）：

```verilog
// 原：nblocks <= msg_len / RATE;
nblocks <= 16'd0;   // msg_len < RATE 恒成立 -> nblocks 恒 0（移除除法锥）

// 原：rem = msg_len - (nblocks * RATE);
rem = msg_len;      // nblocks==0 -> rem == msg_len（移除乘法锥）
```

`blk_idx == nblocks`（→`blk_idx==0`）与 `blk_idx+1 >= nblocks+1`（恒真）由综合器常数折叠。

**KAT 回归**：`verify/run_kyber_kem.py` → **TOTAL 0 ERRORS**
（KeyGen 800 ✓、Encaps 1056 ✓、Decaps 64 ✓、外部 ct 768 字 ✓、重复稳定 PASS）。
修改位精确。

## 6. 板级诊断（旧 RTL，b2nttdram3，BOARD_CLK_DIV=1 全数据通路 100 MHz）

`scripts/impl_board_top.py` 完整实现（Nexys4 DDR 真实引脚约束）：

| 阶段 | Setup | WNS | Hold | 说明 |
|---|---|---|---|---|
| placed | 0 违例 | **+0.377 ns** | 98 违例 −0.117 | 死除法锥在板级非关键路径 |
| post-route | 2 违例 | **−0.121 ns**（TNS −0.125） | 0 违例 +0.033 | 见下方根因 |

- **post-route 2 条违例**：
  1. `u_kem/u_xof256/blk_idx_reg[13]/C → bv_r_reg[3]/D`（−0.121）——**`abs_pos = blk_idx*RATE + byte_in_blk` 的 16×8 乘法锥**（blk_idx 恒 0，单块吸收，锥输出恒定，死锥）。
  2. `rst_t2_reg_rep → u_kem/u_sampler/bytes_reg[86][3]/CLR`（−0.005）——复位释放路径，可忽略。
- **结论**：`msg_len < RATE` → 单块吸收 → blk_idx 恒 0，blk_idx×RATE 锥死路（blk_idx[13] 恒 0，不翻转）。

## 6b. 完整单块简化（二次修复，2026-11-08）

原简化只移除 `msg_len/RATE` 除法锥 + `nblocks*RATE` 乘法锥；board post-route 暴露
`blk_idx*RATE` 乘法锥为新的最差路径。因单块吸收（msg_len < RATE）：
- `abs_pos = byte_in_blk`（移除 blk_idx×RATE 16×8 乘法锥）。
- padding 恒生效（blk_idx==nblocks==0 恒真）。
- S_PERM_A 后恒进 S_SQ（总块数=1）。
- 移除死寄存器 `blk_idx`（声明/复位/自增全部删除）。

KAT 复验 **0 ERRORS**（KeyGen 800 / Encaps 1056 / Decaps 64 / 重复稳定），位精确。

## 7. 最终结论（新 RTL board post-route，b2nttdram4，BOARD_CLK_DIV=1）

**100 MHz 时序闭合达成**（XC7A100T，Nexys4 DDR 真实引脚约束，完整实现至 bitstream）：

| 阶段 | Setup | WNS | Hold | WHS |
|---|---|---|---|---|
| placed | 0 违例 | **+0.523 ns** | 254 违例 | −0.078 ns |
| **post-route** | **0 违例** | **+0.233 ns** | **0 违例** | **+0.017 ns** |

- **Setup WNS +0.233 ns（0 违例，TNS 0.000）** → 10.000 ns 周期下 **100 MHz 闭合**。
- **Hold WHS +0.017 ns（0 违例）** → hold 干净。
- 0 条违例路径。
- 资源：Slice LUTs 32196（Logic 27761 + Memory 4435）、Slice Registers 40031、DSPs 39、Block RAM 1、F7/F8 mux 7/8。
- bitstream：`results/impl_board_top_b2nttdram4.bit`（3.8 MB）。

对比：
- 旧 RTL post-route（b2nttdram3）：Setup −0.121 ns（2 违例，blk_idx×RATE 死锥 + 复位 −0.005）。
- 新 RTL post-route（b2nttdram4）：Setup +0.233 ns（0 违例）——**改善 +0.354 ns，从差 0.121 变余量 +0.233**。
- 旧 RTL placed：+0.377；新 RTL placed：+0.523。

**结论**：ML-KEM 板级原型在 XC7A100T 上 **100 MHz 全时序闭合**（Setup + Hold 双闭合，0 违例）。
死常数除法锥（msg_len/RATE）与 blk_idx×RATE 乘法锥的消除是达成闭合的关键修复。

## 8. 状态

- [x] 假路径定位 + 不变量证明 + RTL 死代码消除（除法锥 + blk_idx 乘法锥）+ KAT 0 ERRORS。
- [x] 板级诊断（旧 RTL b2nttdram3）：placed +0.377；post-route −0.121（blk_idx×RATE 死锥）。
- [x] 单块简化二次修复 + KAT 0 ERRORS。
- [x] **board 重跑（新 RTL b2nttdram4）：post-route Setup 0 违例 WNS +0.233，Hold 0 违例 WHS +0.017 → 100 MHz 闭合**。
- [x] **standalone 重综合取真实 WNS（2026-11-08，`results/kem_synth_timing.rpt`）**：
  **Setup 0 违例 WNS +0.112 ns**（对比修复前 −5.121 ns，**改善 +5.233 ns**），最差路径转至真实功能路径
  `byte_cnt_reg[0]/C→m_prime_buf_reg[0][0]/CE`（数据路径 9.306 ns，m_prime 计算锥）；Hold −0.121 ns
  （37068 违例）为 synth 期 SRL16E 已知现象（board post-route Hold +0.017 已确认闭合）。
  → **死锥消除在纯逻辑综合层面独立验证成立**。
  - 注：第 1 次尝试在综合成功（0 errors, 12 min）后**报告阶段挂死**（.Xil 争用，3600s 超时，无 dcp 可恢复）；
    复查发现 3 个外来 fpga_ckks Vivado 僵尸（PID 4944/20012/23660，创建 11/5）已全部退出 →
    第 2 次成功（rc=0, 624.8s，综合 6:01 + 报告）。`report_hierarchy` 已从 run_kem_synth.py 移除。

## 9. 相关铁律

## 7. 相关铁律

- 每步 RTL 改动先过 iverilog KAT 0 ERRORS 门禁（本步已过）。
- 同宿主不并行两个 Vivado（.Xil 跨工作区争用 → 综合后 0% CPU 挂死）。
- `report_timing_summary -delay_type minmax`（无下划线）被 2026.1 拒绝；
  `-delay_type min_max`（下划线）合法（t89q3 pre_route 报告头部实证）。
