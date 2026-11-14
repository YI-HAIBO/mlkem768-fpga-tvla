#!/usr/bin/env python3
"""Produce the C1 ledger link-roots to be anchored on-chain (Task #90).

The roots come from the *same* Python golden model that was cross-checked
against the RTL (`verify/chain_anchor_golden.py`), and the RTL testbench
`sim/tb_chain_anchor_audit.v` reproduces them in hardware semantics.  Three
epochs are emitted:

  epoch 0 : L_0, the root of the empty ledger (must equal perm(IV))
  epoch 1 : root after 4 records
  epoch 2 : root after 8 records

Prints one 64-hex-char root per line (and writes verify/anchor_roots.json),
ready for `verify/anchor_sepolia.py --anchor <root>`.
"""
import json
import os

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
STATE = os.path.join(HERE, "anchor_roots.json")


def build():
    import importlib.util
    p = os.path.join(HERE, "chain_anchor_golden.py")
    spec = importlib.util.spec_from_file_location("cag", p)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    t = m.AuditTrail()
    roots = [{"epoch": 0, "records": 0, "root": t.link.hex()}]
    for n in (4, 8):
        while len(t.records) < n:
            i = len(t.records)
            t.append(bytes([0x30 + i] * 4),
                     bytes((j + 0x40 + i) & 0xFF for j in range(16)),
                     bytes((j + 0x80 + i) & 0xFF for j in range(8)))
        assert t.verify(), "golden verify failed after %d records" % n
        roots.append({"epoch": len(roots), "records": n, "root": t.link.hex()})
    return roots


def main():
    roots = build()
    json.dump(roots, open(STATE, "w"), indent=2)
    for r in roots:
        print(r["root"])
    print("\nwrote %s" % STATE)


if __name__ == "__main__":
    main()
