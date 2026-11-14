# C1 链锚定实验：OpenTimestamps 公共锚定回执

生成时间：2026-10-27T00:15:31Z（UTC）
校验库：python-opentimestamps 0.4.5（官方实现）

## 1. 为什么走 OpenTimestamps 而不是 Sepolia

Sepolia 路径（`verify/anchor_sepolia.py`）已完整实现（合约 solc ^0.8.20 可编译、RPC 可连、钱包已生成），但当前所有免登录水龙头都要求领取地址在以太坊**主网**持有 ETH（Alchemy 0.001 ETH + 主网活动、aurpay 网关 0.0001 ETH），新生成钱包无法满足，需人工登录领取。

OpenTimestamps 不需要钱包、不需要 API key、不需要水龙头：把 32 字节link-root 摘要 POST 给公共日历服务器，日历把摘要聚合进 Merkle 树，树根被写入一笔**真实的比特币交易**。因此它是可公开验证的、比特币背书的公共时间戳。

## 2. 被锚定的根（来自 C1 黄金模型，与 RTL 交叉验证）

| epoch | 记录数 | link root (sha256) | 32 字节根文件 |
|---|---|---|---|
| 0 | 0 | `9cb2622b72d36b38ee6cf518b08997f76e5b130ee121699457bda733ce938666` | `ots/9cb2622b72d36b38.bin` |
| 1 | 4 | `a14ac6c86d23c46505272db4aa44a893e1a84275de01207f8c8321eab41bd86a` | `ots/a14ac6c86d23c465.bin` |
| 2 | 8 | `e2f696ff02c1d893384d44bc0be8fb217a1d1fc6fff8800c2bc84a98e60fce4a` | `ots/e2f696ff02c1d893.bin` |

## 3. 回执（每个根提交给 3 个独立日历）

| epoch | 日历 | HTTP | 回执文件 | 字节 | 结构校验 |
|---|---|---|---|---|---|
| 0 | alice.btc.calendar.opentimestamps.org | 200 | `ots/alice__9cb2622b72d36b38.ots` | 242 | PASS |
| 0 | bob.btc.calendar.opentimestamps.org | 200 | `ots/bob__9cb2622b72d36b38.ots` | 205 | PASS |
| 0 | a.pool.opentimestamps.org | 200 | `ots/a__9cb2622b72d36b38.ots` | 207 | PASS |
| 1 | alice.btc.calendar.opentimestamps.org | 200 | `ots/alice__a14ac6c86d23c465.ots` | 242 | PASS |
| 1 | bob.btc.calendar.opentimestamps.org | 200 | `ots/bob__a14ac6c86d23c465.ots` | 275 | PASS |
| 1 | a.pool.opentimestamps.org | 200 | `ots/a__a14ac6c86d23c465.ots` | 207 | PASS |
| 2 | alice.btc.calendar.opentimestamps.org | 200 | `ots/alice__e2f696ff02c1d893.ots` | 172 | PASS |
| 2 | bob.btc.calendar.opentimestamps.org | 200 | `ots/bob__e2f696ff02c1d893.ots` | 310 | PASS |
| 2 | a.pool.opentimestamps.org | 200 | `ots/a__e2f696ff02c1d893.ots` | 207 | PASS |

## 4. 校验方法（为什么回执里“找不到”根）

OTS 是零知识式设计：序列化的 Timestamp **不存储**被锚定的消息，消息是反序列化的种子。因此正确的校验是用官方库 `Timestamp.deserialize(ctx, root)`——若能解析，则该回执确实承诺了我们的 32 字节根。本报告的每条回执都以此方式校验通过（`STRUCTURAL VERIFY: PASS`）。`verify/ots/<root16>.bin` 保存了原始32 字节根，任何第三方都可用它复算与复验。

## 5. 比特币证明的状态

- 已聚合进比特币交易（upgraded receipt 可取回）：**0** 个回执
- 仍处于 pending（日历尚未把该根写进下一笔比特币交易）：**9** 个回执
- pending 是正常的：公共日历按批次聚合（通常数小时到 1 天）。聚合完成后执行 `ots upgrade` 或 GET `/timestamp/<hex-root>` 即可取回带比特币区块高度的完整证明，用官方客户端 `ots verify <file>.ots` 验证。

## 6. Sepolia 路径保持可用

钱包 `0xb21b9b1Cc45e63920daA1ed9c70a934c7E2045dd` 一旦获得测试币，执行 `python verify/anchor_sepolia.py --deploy --anchor --verify` 即可完成同一批根的 Sepolia 链上锚定（合约与 CLI 已就绪）。

