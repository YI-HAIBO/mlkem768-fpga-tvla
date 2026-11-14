#!/usr/bin/env python3
"""C1 链锚定实验（Task #90）：把 chain_anchor_audit 模块算出的链根（link root，
32 字节）发布到以太坊 Sepolia 测试网，并读回验证。

锚定方式：部署一个极简的 ChainAnchorRegistry 合约（Solidity，本地 solc 编译），
随后对每个根调用 anchor(root, epoch)。读回 anchoredAt[root] 与 Anchored 事件
作为回证证据。

运行前提（全部外部动作，脚本自身无法完成）：
  1. 钱包 `c:/tmp/c1_anchor_wallet.json` 里有 Sepolia 测试网 ETH
     （水龙头：https://sepoliafaucet.com / https://www.alchemy.com/faucets/
      ethereum-sepolia，任选其一，向脚本输出的 address 领取 0.05–0.1 ETH 即可）。
  2. 网络可访问公共 RPC（默认 https://ethereum-sepolia-rpc.publicnode.com）。

用法：
  python anchor_sepolia.py --check           # 只查余额与合约是否存在
  python anchor_sepolia.py --deploy          # 部署 registry（一次）
  python anchor_sepolia.py --anchor <hex>    # 锚定一个 32 字节根（可重复）
  python anchor_sepolia.py --verify <hex>    # 读回锚定时间戳
  python anchor_sepolia.py --list            # 列出本实验已锚定的根

产出：anchor_state.json + anchor_report.md（写入 verify/）
"""
import argparse
import json
import os
import sys
import time

from web3 import Web3
from eth_account import Account

KEY_PATH = "c:/tmp/c1_anchor_wallet.json"
STATE_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "anchor_state.json")
REPORT_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "anchor_report.md")

RPC_FALLBACKS = [
    "https://ethereum-sepolia-rpc.publicnode.com",
    "https://rpc.sepolia.org",
    "https://sepolia.gateway.tenderly.co",
]

SOL_SRC = r"""
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// Minimal ledger-anchor registry for the C1 chain_anchor_audit module.
/// Stores the FPGA-computed link root on-chain with a timestamp, so the
/// ledger's integrity can be contested/proved against a public chain.
contract ChainAnchorRegistry {
    mapping(bytes32 => uint64) public anchoredAt;
    mapping(bytes32 => uint64) public anchoredEpoch;
    event Anchored(bytes32 indexed root, uint64 epoch, address indexed by);

    function anchor(bytes32 root, uint64 epoch) external {
        require(root != bytes32(0), "zero root");
        require(anchoredAt[root] == 0, "already anchored");
        anchoredAt[root] = uint64(block.timestamp);
        anchoredEpoch[root] = epoch;
        emit Anchored(root, epoch, msg.sender);
    }

    function verify(bytes32 root) external view returns (uint64 ts, uint64 epoch) {
        return (anchoredAt[root], anchoredEpoch[root]);
    }
}
"""


def get_w3():
    for url in RPC_FALLBACKS:
        try:
            w3 = Web3(Web3.HTTPProvider(url, request_kwargs={"timeout": 15}))
            if w3.is_connected():
                print("  RPC connected: %s" % url)
                return w3
        except Exception as e:
            print("  RPC failed %s: %s" % (url, e))
    raise RuntimeError("no reachable Sepolia RPC")


def get_account():
    if not os.path.exists(KEY_PATH):
        raise RuntimeError(
            "wallet missing: %s (generate first)" % KEY_PATH)
    w = json.load(open(KEY_PATH))
    return Account.from_key(w["key"]), w["address"]


def load_state():
    if os.path.exists(STATE_PATH):
        return json.load(open(STATE_PATH))
    return {"contract": None, "roots": {}, "chain_id": None}


def save_state(st):
    json.dump(st, open(STATE_PATH, "w"), indent=2)


def deploy(w3, acct):
    st = load_state()
    if st.get("contract"):
        print("  contract already deployed: %s" % st["contract"])
        return st["contract"]
    try:
        from solcx import compile_source, install_solc
        try:
            install_solc("0.8.20")
        except Exception:
            pass
        comp = compile_source(SOL_SRC, output_values=["abi", "bin"])
        _, data = comp.popitem()
        abi, binhex = data["abi"], data["bin"]
    except Exception as e:
        print("  solcx unavailable (%s); falling back to hand-assembled "
              "bytecode is NOT trustable -- aborting deploy." % e)
        raise
    nonce = w3.eth.get_transaction_count(acct.address)
    tx = {
        "from": acct.address,
        "nonce": nonce,
        "gas": 300_000,
        "gasPrice": w3.eth.gas_price,
        "data": bytes.fromhex(binhex),
        "chainId": w3.eth.chain_id,
    }
    signed = acct.sign_transaction(tx)
    h = w3.eth.send_raw_transaction(signed.raw_transaction)
    rc = w3.eth.wait_for_transaction_receipt(h, timeout=120)
    if rc["status"] != 1:
        raise RuntimeError("deploy tx failed: %s" % h.hex())
    addr = rc["contractAddress"]
    st["contract"] = addr
    st["abi"] = abi
    st["chain_id"] = w3.eth.chain_id
    st["deploy_tx"] = h.hex()
    st["deploy_block"] = rc["blockNumber"]
    save_state(st)
    print("  deployed ChainAnchorRegistry at %s (block %d, tx %s)" % (
        addr, rc["blockNumber"], h.hex()))
    return addr


def get_contract(w3, st):
    if not st.get("contract") or "abi" not in st:
        raise RuntimeError("registry not deployed; run --deploy first")
    return w3.eth.contract(
        address=Web3.to_checksum_address(st["contract"]), abi=st["abi"])


def anchor(w3, acct, root_hex):
    st = load_state()
    c = get_contract(w3, st)
    root = bytes.fromhex(root_hex.removeprefix("0x"))
    assert len(root) == 32, "root must be 32 bytes"
    epoch = st["roots"].get(root_hex, {}).get("epoch", len(st["roots"]))
    nonce = w3.eth.get_transaction_count(acct.address)
    tx = c.functions.anchor(root, epoch).build_transaction({
        "from": acct.address, "nonce": nonce, "gas": 120_000,
        "gasPrice": w3.eth.gas_price, "chainId": w3.eth.chain_id,
    })
    signed = acct.sign_transaction(tx)
    h = w3.eth.send_raw_transaction(signed.raw_transaction)
    rc = w3.eth.wait_for_transaction_receipt(h, timeout=120)
    if rc["status"] != 1:
        raise RuntimeError("anchor tx failed: %s" % h.hex())
    ts = w3.eth.get_block(rc["blockNumber"])["timestamp"]
    st["roots"][root_hex] = {
        "tx": h.hex(), "block": rc["blockNumber"], "ts": ts, "epoch": epoch,
    }
    save_state(st)
    print("  anchored %s at block %d (epoch %d, tx %s)" % (
        root_hex, rc["blockNumber"], epoch, h.hex()))


def verify(w3, root_hex):
    st = load_state()
    c = get_contract(w3, st)
    root = bytes.fromhex(root_hex.removeprefix("0x"))
    ts, epoch = c.functions.verify(root).call()
    return ts, epoch


def write_report(st):
    rows = []
    for rhex, r in sorted(st["roots"].items()):
        rows.append("| `%s` | %d | %d | %d | [`%s`](https://sepolia.etherscan.io/tx/%s) |"
                     % (rhex, r["epoch"], r["block"], r["ts"], r["tx"][:16] + "...", r["tx"]))
    body = "\n".join(rows) if rows else "| - | - | - | - | - |"
    md = """# C1 链锚定实验报告（Sepolia 测试网）

**合约**: [`%s`](https://sepolia.etherscan.io/address/%s)
（ChainAnchorRegistry，solidity ^0.8.20）
**部署交易**: [`%s`](https://sepolia.etherscan.io/tx/%s)（区块 %d）
**锚定时间**: %s

| 链根 (link root, 32B) | epoch | 区块 | 时间戳 (Unix) | 交易 |
|---|---:|---:|---:|---|
%s

## 说明

- 每个链根由 FPGA 设计 `chain_anchor_audit` 的黄金模型/RTL 在一轮 C_VERIFY 后产出
  （link[] 链在 PBKDF2 风格双链结构里的最终 32 字节摘要，见
  `docs/innovation_C1_chain_anchor.md`）。
- 合约 `anchoredAt[root] != 0` 即公开可验证该根在时间戳之前已存在，
  提供「账本在 t 时刻的内容承诺」这一受限但公开的抗窜改证据。
- 限制：合约不验证根本身的计算正确性（验证在 FPGA 侧完成），只提供存在性承诺。
""" % (st["contract"], st["contract"], st.get("deploy_tx", ""),
       st.get("deploy_tx", ""), st.get("deploy_block", "?"),
       time.strftime("%Y-%m-%d %H:%M:%S"), body)
    open(REPORT_PATH, "w").write(md)
    print("  report -> %s" % REPORT_PATH)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--deploy", action="store_true")
    ap.add_argument("--anchor", metavar="HEX32")
    ap.add_argument("--verify", metavar="HEX32")
    ap.add_argument("--list", action="store_true")
    args = ap.parse_args()

    w3 = get_w3()
    acct, addr = get_account()
    print("wallet: %s" % addr)
    bal = w3.eth.get_balance(addr)
    print("balance: %.4f SEP" % (bal / 1e18))
    st = load_state()
    if args.check:
        print("contract: %s" % (st.get("contract") or "NOT DEPLOYED"))
        return 0
    if bal == 0:
        print("!! wallet has 0 SEP -- fund it from a Sepolia faucet first")
        return 1
    if args.deploy:
        deploy(w3, acct)
    st = load_state()
    if args.anchor:
        anchor(w3, acct, args.anchor)
        st = load_state()
    if args.verify:
        ts, ep = verify(w3, args.verify)
        print("  verify: ts=%s epoch=%s" % (ts, ep))
    if args.list:
        for rhex, r in st["roots"].items():
            print("  %s epoch=%d block=%d" % (rhex, r["epoch"], r["block"]))
    write_report(st)
    return 0


if __name__ == "__main__":
    sys.exit(main())
