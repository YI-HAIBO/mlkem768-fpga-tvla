# NTT coeff[] 迁 BRAM 改造方案（用户拍板方向，2026-11-07）

## 0. 背景与目标

B1+DIV=1 post-route（`results/impl_board_top_t89r100f_b1d_post_route_timing.rpt`）：
- WNS **−1.618 ns**（clk 10.000 ns，未闭合 100 MHz），1217 违例端点，TNS −343.115。
- **最差路径**：`u_kem/u_ntt/addr_b_reg_reg[2]/C -> u_kem/u_ntt/pb_reg[13]/D`，
  Data Path 11.357 ns（logic 1.514 / **route 9.843 = 86.7% 布线**），5 逻辑级（LUT6+MUXF7×2+MUXF8×2）。
- 根因：`kyber_ntt.v` 的 `coeff[256]×16` **异步读**（`pb <= coeff[addr_b_reg]` 等）综合成 256:1 MUX，
  地址位 `addr_b_reg[2]` **扇出 = 999**，布线 7.874 ns（源 X40Y42 → 目标 X1Y103/X11Y119/X33Y85，横跨芯片）。
- 利用率：Slice LUT 51,754/63,400 = **81.63%**；**Block RAM 仅 1.5/135 片（1.11%）**——BRAM 几乎未用。

**目标**：把 `coeff[]` 迁到 BRAM（同步读），消除 999 扇出异步读 MUX，用足 BRAM 余量，
争取 pre/post-route 闭合 100 MHz（需把最差路径 11.357 ns 降到 <10.0 ns，即削 ≥1.618 ns）。

## 1. 关键约束（Vivado BRAM 推断，硬性）

1. **所有读必须同步**：`coeff[]` 的每个读都要 `dout <= mem[addr]`（`always @(posedge clk)`）。
   任一组合读（`assign d = coeff[a]`）都会阻止 BRAM 推断。
2. **写口 ≤ 2**：BRAM 最多 2 个独立写端口（True Dual-Port）。
3. **无复位清零**：reset 分支**不能**清空数组内容（BRAM 无复位）。当前 reset 里
   `for (gi...) coeff[gi] <= 0` 必须移除（依赖"每次 start 前完整 load 256 个 coeff"）。
4. 读/写地址可由组合逻辑（mux）驱动，但越简单越易推断。

## 2. 现状（`rtl/core/kyber_ntt.v`，改造前）

| 项 | 现状 | 问题 |
|---|---|---|
| `coeff[0:255]×16` | `reg [BW-1:0] coeff [0:N-1]` | 组合读 → LUT/mux，扇出 999 |
| 蝶形读 | `pa<=coeff[addr_a_reg]` (P1), `pb<=coeff[addr_b_reg]` (P1) | 2 个异步读口 |
| reduce/scale 读 | `rin<=coeff[cnt]` (rph0) | 2 个异步读口（同一位置） |
| read_data | `assign read_data = coeff[read_addr]` | 1 个异步读口 |
| 写口 | load / 蝶形A / 蝶形B / reduce-scale = **4 个** | >2，需合并 |
| 蝶形 FSM | 7 相 ADDR→READ→SUB→M0→M1→M2a→M2b | 同步读需 +2 相 |
| reduce/scale | 5 相 rph0..rph4 | 同步读需 +1 相 |
| reset | `for(gi...) coeff[gi]<=0` | 阻止 BRAM |

## 3. 设计（TDP BRAM，2 端口）

### 3.1 端口划分

**端口 A（数据通路，读+写）**：
- 读地址：`(state==S_BUTTER) ? addr_a_reg : ((state==S_REDUCE||state==S_SCALE) ? cnt : read_addr)`
- 写地址：`(state==S_BUTTER&&P7) ? addr_a_reg : cnt`（reduce/scale 写回）
- 读输出：`dout_a`（蝶形 pa / reduce/scale rin / read_data 共用）

**端口 B（蝶形 B + load，读+写）**：
- 读地址：`addr_b_reg`（蝶形）
- 写地址：`load ? load_addr : addr_b_reg`（load / 蝶形写 B）
- 读输出：`dout_b`（蝶形 pb）

**分时性检查**（同端口不同拍激活）：
- 端口 A 读：蝶形读 A（P1）/ reduce 读（rph0）/ scale 读（rph0）/ read_data 读（S_IDLE）→ 状态互斥 ✓
- 端口 A 写：蝶形写 A（P7）/ reduce 写（rph5）/ scale 写（rph5）→ 状态互斥 ✓
- 端口 B 读：蝶形读 B（P1）✓
- 端口 B 写：load 写（S_IDLE, load=1）/ 蝶形写 B（P8）→ 状态互斥 ✓
- 同拍：端口 A 读 read_data（S_IDLE）+ 端口 B 写 load（S_IDLE, load=1）→ 不同端口 ✓

### 3.2 蝶形 FSM：7 → 9 相

```
P0 ADDR   : addr_a_reg<=A; addr_b_reg<=B; zv_reg<=get_zeta(zeta_cnt);
            last_butter<=(j_cnt+1==len); j_cnt<=j_cnt+1
P1 READ_WAIT: (端口A/B 在 P0 沿锁存地址 A/B；dout 在 P1 沿后=coeff[A]/coeff[B])
P2 CAP    : pa<=dout_a; pb<=dout_b          // = coeff[A], coeff[B]
P3 SUB    : xd_reg<=pb-pa; sum_reg<=pa+pb
P4 M0     : prod<=bf_m0; if(inv){s_reg<=sum_reg; v_a<=bf_va;}
P5 M1     : t_low<=m1_w; bar_t_reg<=(v_a+2^25)>>>26
P6 M2a    : mont_diff_r<=mont_diff; bar_mul_r<=bar_t_reg*3329
P7 M2b    : coeff[addr_a_reg]<= (inv?bar_res:fwd_a)   // 写 A（端口 A）
P8 M2c    : coeff[addr_b_reg]<= (inv?mont_res:fwd_b)  // 写 B（端口 B）
           last_butter ? (state<=S_NEXT_BLOCK) : (butter_ph<=0)
```
- 读 A/B 同拍（P2 CAP，双端口），写 A/B 分拍（P7/P8，单写口约束）。
- 逻辑链与原 7 相完全同构（只是整体右移 2 拍），bit-exact 保持。
- 吞吐：9 相/蝶形，约 -22%（时序闭合优先，KEM 整体可接受）。

### 3.3 reduce/scale FSM：5 → 6 相

```
S_REDUCE:
  rph0 : (读地址=cnt，端口A；cnt_d<=cnt；dout_a 在 rph0 沿后=coeff[cnt])
  rph1 : rin<=dout_a                       // = coeff[cnt_d]
  rph2 : s_reg<=rin; v_a<=rd_va
  rph3 : bar_t_reg<=(v_a+2^25)>>>26
  rph4 : bar_mul_r<=bar_t_reg*3329
  rph5 : coeff[cnt_d]<=bar_res; cnt<=cnt+1; 完成/继续
S_SCALE 同理（用 sc_m0w / mont 链）。
```
- 写回用 `cnt_d`（rph0 打拍的 cnt），读同步 1 拍。
- rph0 结束时检查 cnt<N 继续，否则转 DONE（注意 rph5 的判断）。

### 3.4 read_data 同步化

```
// 端口 A 读地址在 S_IDLE = read_addr（外部输入）
always @(posedge clk) read_data <= dout_a;   // 同步读 1 拍
```
- **对外语义变化**：read_data 从"组合 = coeff[read_addr]"变"同步 = 1 拍后 coeff[read_addr]"。
- kyber_kem 所有 `ntt_ra` 由**阻塞**改**非阻塞**（消除两个 always 块竞争 read_addr 的 race），
  且 read_data 消费需补偿（见 §4）。

### 3.5 reset 清零移除 + load 完整性前提

- 移除 reset 分支的 `for(gi...) coeff[gi]<=0`。
- **前提**：每次 NTT start 前必须**完整 load 256 个 coeff**。已核对全部 9 个 load 调用点
  （S_KG_A/S_KG_SNTT/S_KG_ENTT/S_ENC_RNTT/S_ENC_U/S_ENC_V/S_DEC_SNTT/S_DEC_UNTT/S_DEC_M）
  均为 `coeff_cnt` 0..255 完整循环。KAT 回归作为最终裁判。

## 4. kyber_kem.v 补偿（read_data 同步化波及）

### 4.1 全部 `ntt_ra` 驱动：阻塞 → 非阻塞
9 处消费点的 `ntt_ra = <idx> + 8'd1`（阻塞）→ `ntt_ra <= <idx> + 8'd2`（非阻塞），
初始 prime（ntt_dn 检测拍）`ntt_ra <= 8'd1`，启动拍（ntt_st=1）`ntt_ra <= 8'd0`。

### 4.2 消费点补偿
- **模式 A（rn_data/rn_data_p 2 级流水，6 处）**：捕获链不变；写回条件 `coeff_cnt>=9'd2`→`>=9'd1`；
  `ntt_ra` prime 由 `coeff_cnt+1`→`coeff_cnt+2`（非阻塞）。逐周期 trace 验证写回对齐。
- **模式 B（up0_ntt/mp0_ntt/vp0_ntt 1 级捕获，3 处）**：`ntt_ra` prime `stage_cnt+1`→`stage_cnt+2`（非阻塞）；
  捕获链加 1 拍延迟（用打拍的 stage_cnt_d 作索引）。逐周期 trace 验证。

## 5. 风险与备选

| 风险 | 缓解 |
|---|---|
| Vivado 不推断 BRAM（地址 mux 太复杂 / 多写口） | 端口地址 mux 尽量简单；若失败，回退 `.bak_prebram` |
| 时序不改善（BRAM 读数据输出布线仍长） | 若 pre-route 仍负，转 B2 12 数组 / B3 Keccak 拆 theta |
| kyber_kem 补偿错位（最易错） | 逐周期 trace + KAT 0 ERRORS 铁律 |
| reset 移除后 load 不完整 → 读到垃圾 | 确认 9 个 load 调用均完整；KAT 把关 |
| 蝶形 9 相吞吐 -22% | 时序优先；KEM 吞吐可接受 |

## 6. 实施步骤（每步 iverilog KAT 0 ERRORS 门禁）

1. 改 `kyber_ntt.v`：写口合并 + 蝶形 9 相 + reduce/scale 6 相 + read_data 同步 + reset 移除。
2. 改 `kyber_kem.v`：ntt_ra 非阻塞 + 补偿（§4）。
3. `verify/run_kyber_kem.py` KAT 回归 → 迭代至 0 ERRORS。
4. Vivado 综合（全新 cwd，只杀自己进程树）→ 看 BRAM 推断 + pre-route 时序。
5. 若 pre-route WNS>0 → place + route 出权威 post-route；否则回退或转 B2。

## 7. 备份
- `rtl/core/kyber_ntt.v.bak_prebram`（2026-11-07 19:48）
- `rtl/core/kyber_kem.v.bak_prebram`（2026-11-07 19:48）
