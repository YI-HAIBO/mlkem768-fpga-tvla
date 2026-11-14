# 12 个创新模块 Vivado 综合结果（2026-10-25）

器件 xc7a100tcsg324-1（Artix-7 100T），synth directive default，时钟约束 10 ns（clk 端口存在时）。
LUT/FF/DSP/BRAM 为综合后利用率，WNS 为 10 ns 约束下的最差负松弛，Power 为 vectorless pre-layout 估计。

| 模块 | 顶层 | 状态 | LUT | FF | DSP | BRAM | WNS (ns) | Power (W) |
|---|---|:---:|---:|---:|---:|---:|---:|---:|
| A2 | `puf_trng_fused` | OK | 249 | 107 | 3 | 0 | -2.421 | 0.143 |
| A3 | `adaptive_mask_ctrl` | OK | 26 | 28 | 0 | 0 | 6.073 | 0.092 |
| A4 | `hybrid_kex` | OK | 2465 | 1380 | 8 | 0 | -11.157 | 0.158 |
| A5 | `watermark_backdoor_scan` | OK | 2583 | 1030 | 0 | 0 | -15.655 | 0.113 |
| B1 | `he_engine` | OK | 531 | 521 | 4 | 0 | 0.126 | 0.103 |
| B2 | `masked_accumulate_3rd_dip` | OK | 883 | 653 | 0 | 0 | 4.207 | 0.154 |
| B3 | `tvla_online` | OK | 601 | 429 | 8 | 0 | -0.498 | 0.123 |
| B4 | `mpc_private_infer` | OK | 24847 | 2645 | 0 | 0 | -0.822 | 0.357 |
| C1 | `chain_anchor_audit` | OK | 6983 | 1109 | 4 | 0 | -4.176 | 0.185 |
| C2 | `sec_acc_pareto` | OK | 216 | 45 | 0 | 0 | -0.969 | 0.093 |
| C3 | `model_theft_detect` | OK | 706 | 265 | 0 | 0 | 4.722 | 0.095 |
| C4 | `puf_model_bind` | OK | 13178 | 32845 | 0 | 0 | 4.412 | 0.192 |
