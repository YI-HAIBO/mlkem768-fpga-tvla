# -*- coding: utf-8 -*-
"""
upgrade_ots_receipts.py -- Programmatic OTS upgrade for bare Timestamp receipts.

The 9 receipts are bare Timestamp objects with PendingAttestation placeholders
(no Bitcoin proof yet). This script re-queries each calendar for the upgraded
timestamp (the aggregate may have been mined since 2026-10-27), merges it, and
reports whether a real BitcoinBlockHeaderAttestation is now present.

On success, writes "<name>_upgraded.ots" (originals untouched).

Usage: python upgrade_ots_receipts.py [--timeout 30] [--only a__9cb2...]
"""
import argparse
import json
import os
import sys
import logging

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ots_wrapper  # noqa: F401

from opentimestamps.core.serialize import StreamDeserializationContext, StreamSerializationContext  # noqa: E402
from opentimestamps.core.timestamp import Timestamp  # noqa: E402
from opentimestamps.core.notary import PendingAttestation, BitcoinBlockHeaderAttestation  # noqa: E402

# reuse otsclient's remote_calendar so it shares the same compat fixes
from otsclient.cmds import remote_calendar  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))


def is_complete(ts):
    for msg, att in ts.all_attestations():
        if att.__class__ == BitcoinBlockHeaderAttestation:
            return True
    return False


def upgrade_one(fname, root_hex, timeout):
    rb = bytes.fromhex(root_hex)
    fpath = os.path.join(HERE, fname)
    with open(fpath, "rb") as fd:
        ctx = StreamDeserializationContext(fd)
        ts = Timestamp.deserialize(ctx, rb)

    # CLI pattern: find nodes that DIRECTLY hold the PendingAttestation and use
    # node.msg as the commitment, then merge the upgrade INTO that same node
    # (merging into the root fails: the calendar returns msg == node.msg != root)
    pending = []
    def directly_verified(stamp):
        if stamp.attestations:
            yield stamp
        for sub in stamp.ops.values():
            yield from directly_verified(sub)
    for node in directly_verified(ts):
        for att in node.attestations:
            if att.__class__ == PendingAttestation:
                pending.append((node, node.msg, att))

    if not pending:
        return ts, "no pending (already complete?)"

    changed = False
    notes = []
    for node, msg, att in pending:
        uri = att.uri
        try:
            cal = remote_calendar(uri)
            upgraded = cal.get_timestamp(msg, timeout=timeout)
            node.merge(upgraded)
            changed = True
            notes.append("merged from %s" % uri)
        except Exception as e:
            notes.append("FAIL %s: %r" % (uri, e))

    return ts, ("; ".join(notes)) if notes else "no calendars queried"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--timeout", type=int, default=30)
    ap.add_argument("--only", default=None)
    args = ap.parse_args()

    man = json.load(open(os.path.join(HERE, "manifest.json"), encoding="utf-8"))
    total = 0
    ok = 0
    print("=== OTS upgrade (re-query calendars for Bitcoin attestation) ===")
    for d in man["digests"]:
        root = d["root"]
        for cal in d["calendars"]:
            fname = os.path.basename(cal["file"])
            if args.only and args.only not in fname:
                continue
            total += 1
            try:
                ts, note = upgrade_one(fname, root, args.timeout)
                complete = is_complete(ts)
                atts = list(ts.all_attestations())
                n_att = len(atts)
                if complete:
                    ok += 1
                print("[%s] %-42s att=%d %s" %
                      ("COMPLETE" if complete else "pending ", fname, n_att, note))
                # write upgraded only if changed to complete
                if complete:
                    outp = os.path.join(HERE, fname.replace(".ots", "_upgraded.ots"))
                    with open(outp, "wb") as fd:
                        ts.serialize(StreamSerializationContext(fd))
                    print("        saved %s" % os.path.basename(outp))
            except Exception as e:
                print("[ERROR] %-42s %r" % (fname, e))
    print("=== %d/%d complete after upgrade ===" % (ok, total))
    return 0


if __name__ == "__main__":
    logging.basicConfig(level=logging.WARNING)
    sys.exit(main())
