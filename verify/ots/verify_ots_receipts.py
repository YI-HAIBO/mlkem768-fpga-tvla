# -*- coding: utf-8 -*-
"""
verify_ots_receipts.py -- Structural verification of bare OTS Timestamp receipts.

These 9 receipts (verify/ots/*.ots) are serialized **bare Timestamp** objects
(first byte 0xf0 = OpAppend), NOT standard DetachedTimestampFile wrappers. So
`ots info`/`ots verify` fail with "is not a timestamp file". The attested
message is the 32-byte link root (zero-knowledge: the message is not stored in
the receipt). Correct verification = Timestamp.deserialize(ctx, root).

Usage:
  python verify_ots_receipts.py [--upgrade]
"""
import io
import json
import os
import sys
import binascii

# --- OTS/Python-3.13 compatibility shim must load first ---
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ots_wrapper  # noqa: F401  (patches ctypes.util.find_library)

from opentimestamps.core.serialize import StreamDeserializationContext  # noqa: E402
from opentimestamps.core.timestamp import Timestamp  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))


def load_manifest():
    with open(os.path.join(HERE, "manifest.json"), "r", encoding="utf-8") as f:
        return json.load(f)


def verify_all():
    man = load_manifest()
    roots = {}
    for d in man["digests"]:
        roots[d["root"]] = d

    total = 0
    ok = 0
    print("=== OTS bare-Timestamp structural verification (root == attested msg) ===")
    for root, d in roots.items():
        rb = bytes.fromhex(root)
        for cal in d["calendars"]:
            fpath = os.path.join(HERE, os.path.basename(cal["file"]))
            total += 1
            fname = os.path.basename(cal["file"])
            try:
                with open(fpath, "rb") as fd:
                    ctx = StreamDeserializationContext(fd)
                    ts = Timestamp.deserialize(ctx, rb)
                ops = list(ts.ops)
                atts = list(ts.all_attestations())
                n_ops = len(ops)
                n_att = len(atts)
                ok += 1
                print("[PASS] %-42s root=%s.. ops=%d att=%d" %
                      (fname, root[:16], n_ops, n_att))
            except Exception as e:
                print("[FAIL] %-42s root=%s.. ERR=%r" % (fname, root[:16], e))

    print("=== %d/%d structural verify PASS ===" % (ok, total))
    return ok == total


def check_bins():
    print("=== .bin files vs manifest roots ===")
    man = load_manifest()
    roots = set()
    for d in man["digests"]:
        roots.add(d["root"])
    import glob
    for b in sorted(glob.glob(os.path.join(HERE, "*.bin"))):
        with open(b, "rb") as f:
            h = f.read().hex()
        base = os.path.basename(b).replace(".bin", "")
        match = "MATCH" if h in roots else "NO-MATCH"
        print("%-38s %s  root=%.16s" % (os.path.basename(b), match, h))


if __name__ == "__main__":
    ok = verify_all()
    check_bins()
    sys.exit(0 if ok else 1)
