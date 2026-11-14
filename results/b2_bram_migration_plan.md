# B2 — 全量 poly 数组迁 BRAM（同步读改造）落地计划

> 状态：**已关闭 — 不执行（2026-11-08）**。
> 触发条件原文：若 B1+DIV=1 post-route Setup WNS >= 0（no_clock=0）→ 100 MHz 闭合，本计划**不执行**。
> **条件已满足**：board post-route Setup **0 违例 WNS +0.233 ns**（no_clock=0，b2nttdram4）→ **100 MHz 闭合**，
> 故 B2 全量 BRAM 迁移**不执行**，B3（Keccak S_RUN_THETA 拆拍）备选**亦不需要**。
> 真正瓶颈是 SHAKE 死常数除法锥（假路径），已通过合法死代码消除解决，与 BRAM 无关——
> 见 `b2_deadcone_analysis.md` §10.5 与正式报告 `kem_synth_final_report.md` §10.5。
> 依据：用户拍板「全量 poly 迁 BRAM（8%）」。只读分析已完成（2026-11-07），未改 RTL。

## 0. 动机与判断

- 现状：`board_top`（t89r100f，xc7a100tcsg324-1）post-route Setup WNS **−1.415 ns**（d2 基线，~87.6 MHz）。
  B1 已消除 rn_data→RAM 写根因（pre-route +0.096 ns），但 post-route 估算仍 ~−1.0 ns，最紧引脚 =
  **Keccak 置换 `u_kem/u_xof256/u_perm/A_reg`、`u_xof128/u_perm/A_reg`**。
- 缺口本质是**布线拥塞**（Keccak 1600 位状态 A_reg→theta XOR 树的布线延迟；pre-route 闭合 vs post-route 负
  = 布线主导）。B2 释放 **~8% LUT（~4,259 LUTRAM）** 直接解拥塞，是合理方向。
- 代价：12 个 `ram_style="block"` 数组当前全部被 Vivado 回退 LUTRAM（Synth 8-6849：BRAM 要求同步读）。
  必须把 **异步读→同步读**（注册读地址 + 数据 1 拍补偿），语义大改、KAT 回归风险高。

## 1. 12 个数组（`rtl/core/kyber_kem.v` 113–145）

| 数组 | 尺寸 | 读点数 | 写点数 |
|---|---|---|---|
| A_mat | K*K*N = 4K × BW | 2 | 1 |
| s_poly | K*N | 2 | 1 |
| e_poly | K*N | 1 | 1 |
| t_poly | K*N | 2 | 1 |
| r_poly | K*N | 1 | 1 |
| e1_poly | K*N | 1 | 1 |
| u_poly | K*N | 1 | 2 |
| u_ntt_poly | K*N | 1 | 1 |
| cu_poly | K*N | 2 | 1 |
| s_ntt_poly | K*N | 2 | 2 |
| e_ntt_poly | K*N | 1 | 1 |
| r_ntt_poly | K*N | 2 | 1 |

> 注：写点数以 `ARRAY[idx] <= data` 简单索引计（嵌套索引如 `[7:0]` 会漏计，如 s_poly/e_poly/r_poly/u_poly 的
> `[i_idx*N + coeff_cnt[7:0]] <= samp_cd`），但写口在 LUTRAM 下已工作，B2 只改**读**侧。

## 2. 17 个读点 → 消费者寄存器（全部异步读，数据当拍出）

| 数组 | 行 | 地址表达式 | 消费者 |
|---|---|---|---|
| A_mat | 1156 | `(i_idx*K + j_idx)*N + coeff_cnt[7:0]` | `bm_a_data` |
| A_mat | 1682 | `(i_idx*K + j_idx)*N + coeff_cnt[7:0]` | `bm_a_data` |
| s_poly | 1020 | `i_idx*N + coeff_cnt[7:0]` | `ntt_load_data` |
| s_poly | 2206 | `i_idx*N + coeff_cnt[7:0]` | `ntt_load_data` |
| e_poly | 1084 | `i_idx*N + coeff_cnt[7:0]` | `ntt_load_data` |
| t_poly | 1347 | `out_cnt[10:8]*N + out_cnt[7:0]` | `pk_data` |
| t_poly | 1864 | `i_idx*N + coeff_cnt[7:0]` | `bm_a_data` |
| r_poly | 1619 | `i_idx*N + coeff_cnt[7:0]` | `ntt_load_data` |
| e1_poly | 1813 | `j_idx*N + stage_cnt[7:0]` | `up0_e1` |
| u_poly | 2268 | `j_idx*N + coeff_cnt[7:0]` | `ntt_load_data` |
| u_ntt_poly | 2344 | `i_idx*N + coeff_cnt[7:0]` | `bm_b_data` |
| cu_poly | 2128 | `out_cnt[9:0]` | `ct_data` |
| cu_poly | 2167 | `out_cnt[9:0]` | `dc1_a` |
| s_ntt_poly | 1174 | `j_idx*N + coeff_cnt[7:0]` | `bm_b_data` |
| s_ntt_poly | 2332 | `i_idx*N + coeff_cnt[7:0]` | `bm_a_data` |
| e_ntt_poly | 1298 | `i_idx*N + stage_cnt[7:0]` | `tp0_e` |
| r_ntt_poly | 1694 | `i_idx*N + coeff_cnt[7:0]` | `bm_b_data` |
| r_ntt_poly | 1876 | `i_idx*N + coeff_cnt[7:0]` | `bm_b_data` |

8 个消费者：`bm_a_data`(4) `bm_b_data`(4) `ntt_load_data`(5) `pk_data`(1) `up0_e1`(1) `tp0_e`(1) `ct_data`(1) `dc1_a`(1)。

## 3. 转换步骤（每数组独立，逐项 iverilog KAT 回归）

对每个读点做：
1. **注册读地址**：`reg [ADDR_W-1:0] <arr>_<tag>_addr_r;` 在 T 拍捕获地址表达式。
2. **同步读**：T+1 拍 `消费者 <= <arr>[<arr>_<tag>_addr_r];`（或对共享消费者，按数组区分）。
3. **消费者 1 拍补偿**：所有依赖该读数据的逻辑整体后移 1 拍（FSM 阶段计数 +1，或握手延迟）。

**顺序建议（按风险从低到高）**：
1. `cu_poly`（2 读点，地址 `out_cnt[9:0]` 最简单，消费者 ct_data/dc1_a 独立）——先做，验证方法。
2. `t_poly`（pk_data）、`u_poly`、`e1_poly`、`e_ntt_poly`（up0_e1/tp0_e）。
3. `s_poly`/`e_poly`/`r_poly`/`u_poly`（ntt_load_data，共 5 读点，但 4 数组同地址型，可共享补偿）。
4. `A_mat`（bm_a_data，最大 4K×16，2 读点，喂 basemul——握手波及最大，最后做）。
5. `u_ntt`/`s_ntt`/`r_ntt`（bm_b_data，4 读点）。

**每步门禁**：`verify/run_kyber_kem.py` → KeyGen 800 / Encaps 1056 / Decaps 64 全部 **0 ERRORS** 才进下一步。

## 4. 风险

- **bm_a_data/bm_b_data 喂 `kyber_basemul`（line 485 `.a_data/.b_data`）**：1 拍补偿须同步
  `a_load`/`b_load` 时序，否则 basemul 采样到旧值（iverilog 不一定暴露，Vivado 才见——高风险）。
- 异步读→同步读若补偿不均，会出现 1 拍数据错位（自洽但错误）——**必须有 Python 黄金模型 + KAT 双门禁**。
- 全部改完后必须 `BOARD_CLK_DIV=1` 重跑 post-route 验证（不能只信 pre-route）。

## 5. 备选（B3）：若 B2 释放 LUT 后 Keccak 仍负

Keccak 内部再流水：`S_RUN_THETA` 拆两拍（theta C/D 一拍，rho+pi B 一拍），把 A_reg→XOR 树路径再砍半。
`rtl/core/keccak_perm.v` 139–162。24 轮 × 3 拍 = 72 拍/置换（原 48）。KAT 回归 + 时序重验。
