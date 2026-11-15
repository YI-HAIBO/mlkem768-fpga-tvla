# #6a/#6c 覆盖扩展实现报告（探针时分复用 + 掩码-未掩码对照）

**日期**：2026-11-15　**范围**：短板 #6（仅一阶/不覆盖/无高阶）的 RTL 架构部分。
**前提**：#6b 二阶检测核心已证（`verify/analyze_second_order.py`，二阶中心矩 t 抓到纯二阶泄漏 +18.30 而一阶漏掉 +1.11）。
本报告补齐 #6a（探针覆盖扩展）与 #6c（掩码-未掩码对照）的 RTL 实现与验证。

---

## 一、#6a 探针时分复用路由器（`rtl/real/tvla_probe_router.v`）

**动机**：单探针 `tvla_online` 只能测一个数据通路。要覆盖更多通路（NTT basemul 输出、系数 RAM 读数据、加法器输出、keccak 轮函数……），若每探针复制一套 Welch 累加器则资源爆炸。本模块把 **NTAP 个探针时分复用进单个统计引擎**，开销仅 O(NTAP) 结果位 + O(log NTAP) 计数器。

**接口**：
- `probe_flat[NTAP*PROBE_W-1:0]`：NTAP 个原始数据字展平；`tap_id` 选通当前片
- 内部组合 popcount（不依赖 `$countones`，避免 -g2012 依赖）→ HW 代理样本
- `tap_advance`：外部在每 tap 的 2n 样本完成后脉冲 → 路由器锁存 `leak_result[tap_id]`、递增 `tap_id`（回绕 → `report_cycle` 脉冲）、给下游 `batch_restart`
- `leak_result[N] / degen_result[N]`：每 tap 锁存的泄漏/退化判定

**端到端验证**（`sim/tb_tvla_probe_router.v`，NTAP=4，n=4096/组，真实 `tvla_online` 引擎）：

| tap | 样本 | 期望 | 结果 |
|---|---|---|---|
| 0 | 两组同分布 LFSR | 无泄漏 | ✅ no leak |
| 1 | 固定 0xFF vs LFSR | 泄漏 | ✅ leak |
| 2 | 两组同分布 LFSR | 无泄漏 | ✅ no leak |
| 3 | 固定 0xFF vs LFSR | 泄漏 | ✅ leak |

**结果**：`leak_result=1010`（仅 tap1/tap3 泄漏）、tap 回绕到 0、`report_cycle` 只在整轮后脉冲（r0=r1=r2=0, r3=1）、`degen_result=0000`。**ALL TESTS PASSED**。

**探针点映射建议**（挂到 KEM 数据通路，需 `kyber_kem` 内部加 probe 端口，属后续集成）：

| 探针点 | 数据类型 | HW 含义 |
|---|---|---|
| NTT basemul 输出 | 16-bit 乘积 | 乘法数据相关泄漏 |
| 系数 RAM 读数据 | 12-bit 系数 | 存储访问泄漏 |
| 模加/模减输出 | 12-bit | 算术通路泄漏 |
| keccak 轮函数状态 | 64-bit | 置换泄漏 |

---

## 二、#6c 掩码-未掩码对照（`sim/tb_tvla_masked_contrast.v`）

**动机**：固定-随机 t-test 在明文通路给出"是否泄漏"，但无法回答"掩码是否真的抑制"。掩码-未掩码对照把同一密钥相关字节 **明文** 与 **两 share** 分别送探针，用同一统计引擎比较。

**构造**：`masked_xor_reg #(.W(8))` 把 v（密钥相关字节）拆为 `share0=m`、`share1=v^m`（m 随机 LFSR）。三个探针经 #6a 路由器进真实 `tvla_online`：

| tap | 探针 | 期望 | 结果 |
|---|---|---|---|
| 0 | 明文 HW(v) | **泄漏**（HW(v) 依赖密钥） | ✅ leak |
| 1 | 掩码 HW(share0)=HW(m) | 无泄漏（m 独立于密钥） | ✅ no leak |
| 2 | 掩码 HW(share1)=HW(v^m) | 无泄漏（v^m 被 m 掩蔽） | ✅ no leak |

**结果**：`leak_result=001`（仅 tap0 明文泄漏），计数自洽（k=2048 → cf=cr=1024）。**ALL TESTS PASSED**。

> 修复记录：初版 TB 每样本被引擎采样 2 次（share 锁存 posedge 时 `probe_valid` 仍是上一拍 1），导致提前 batch 满、`batch_done` 脉冲错过 → 超时。修复：样本循环起始清 `probe_valid`，只在该样本采样拍置 1。

---

## 三、结论与边界

- **#6a 探针覆盖扩展**：核心架构件（探针路由器）已实现并端到端验证；探针点映射已给出。**待**：`kyber_kem` 内部加 probe 端口、板级/门级实测。
- **#6c 掩码对照**：对照框架已实现并验证（明文漏、两 share 均不漏）。**待**：真实一阶掩码有效性需门级/物理测量（本 RTL 验证的是统计引擎+对照接线的正确性，非硅片掩码有效性）。
- 二者与 #6b 二阶检测共同构成"一阶+高阶+覆盖"的完整在线泄漏评估框架。
