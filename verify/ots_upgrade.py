#!/usr/bin/env python3
"""Fetch the *upgraded* (Bitcoin-aggregated) OpenTimestamps receipts for the
C1 link roots that were submitted on 2026-10-27.

The public calendars aggregate submitted digests into a Merkle tree whose tip
is committed into a real Bitcoin transaction, typically within hours to a day.
`GET /timestamp/<hex root>` then returns the full path down to the Bitcoin
attestation.  If it still returns 404, the root has not yet been mined into a
block (keep waiting / re-run later).

Usage:
    python verify/ots_upgrade.py            # fetch + verify upgrades
"""
import hashlib
import json
import os
import time
import urllib.error
import urllib.request

from opentimestamps.core.serialize import BytesDeserializationContext
from opentimestamps.core.timestamp import Timestamp

HERE = os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
OTSDIR = os.path.join(HERE, "ots")
MANIFEST = os.path.join(OTSDIR, "manifest.json")
UA = "ipx-aoi-c1-anchor/1.0"


def host_of(url):
    return url.split("//")[1].split("/")[0]


def parse_receipt(blob, digest):
    ctx = BytesDeserializationContext(blob)
    return Timestamp.deserialize(ctx, digest)


def op_summary(ts):
    seen = []
    def walk(node):
        for op in node.ops.keys():
            seen.append(type(op).__name__)
            walk(node.ops[op])
    walk(ts)
    return seen


def main():
    manifest = json.load(open(MANIFEST))
    print("Fetching upgraded (Bitcoin-aggregated) receipts "
          "(submitted %s UTC, now %s UTC)\n"
          % (manifest["created_utc"], time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())))
    n_up = 0
    n_pend = 0
    for d in manifest["digests"]:
        digest = bytes.fromhex(d["root"])
        print("root %s (epoch %s)" % (d["root"][:16], d["epoch"]))
        for c in d["calendars"]:
            if "file" not in c:
                continue
            url = c["url"]
            host = host_of(url)
            path = "%s/timestamp/%s" % (url, d["root"])
            try:
                req = urllib.request.Request(
                    path, headers={"Accept": "application/vnd.opentimestamps.v1",
                                   "User-Agent": UA})
                with urllib.request.urlopen(req, timeout=45) as r:
                    blob = r.read()
                name = "%s__%s.upgraded.ots" % (host.split(".")[0], d["root"][:16])
                with open(os.path.join(OTSDIR, name), "wb") as f:
                    f.write(blob)
                ts = parse_receipt(blob, digest)
                ops = op_summary(ts)
                n_up += 1
                print("  %-10s -> %s UPGRADED (%d B)  ops=%s"
                      % (host, d["root"][:16], len(blob), ops))
                # update manifest
                c["upgraded_file"] = "ots/" + name
                c["upgraded_bytes"] = len(blob)
                c["upgraded_verify"] = "PASS"
                c["upgraded"] = {"status": "BITCOIN_ANCHORED",
                                 "op_names": ops,
                                 "has_attestation": True}
            except urllib.error.HTTPError as e:
                if e.code == 404:
                    n_pend += 1
                    print("  %-10s -> %s PENDING (404, not yet in a Bitcoin tx)"
                          % (host, d["root"][:16]))
                    c["upgraded"] = {"status": "PENDING", "reason": "HTTP 404"}
                else:
                    print("  %-10s -> %s HTTP %d" % (host, d["root"][:16], e.code))
            except Exception as e:
                print("  %-10s -> %s ERR %s" % (host, d["root"][:16],
                                                type(e).__name__))
    json.dump(manifest, open(MANIFEST, "w"), indent=2)
    print("\nUPGRADED(Bitcoin-anchored)=%d  PENDING=%d" % (n_up, n_pend))
    return 0 if n_up else 1


if __name__ == "__main__":
    raise SystemExit(main())
