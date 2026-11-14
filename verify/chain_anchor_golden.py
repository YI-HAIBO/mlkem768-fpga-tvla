#!/usr/bin/env python3
"""
C1 golden model: chain-anchor audit trail.

Bit-exact Python mirror of rtl/core/chain_anchor_audit.v:

    H_i = Hash( H_{i-1} || model_id || in_digest || out || seq_i )
    L_0 = Perm(IV),   L_i = Perm( L_{i-1} ^ H_i )

The sponge state carries over between hashes, so both H and L are functions
of the *entire* history — the audit trail is one continuous hash stream.

This script verifies the construction's structural properties (chaining,
determinism, avalanche, tamper/deletion/replay detection) and documents the
reference anchors the RTL testbench cross-checks against.
"""
import sys
from io import open as _open

IV = bytes([
    0x67, 0x09, 0xE6, 0x67, 0x85, 0xAE, 0x67, 0xBB,
    0x72, 0xF3, 0x6E, 0x3C, 0x3A, 0xF5, 0x4F, 0xA5,
    0x27, 0x0E, 0x51, 0x7F, 0x8C, 0x68, 0x05, 0x9B,
    0xAB, 0xD9, 0x83, 0x1F, 0x19, 0xCD, 0xE0, 0x5B,
])


def gf256(a: int, b: int) -> int:
    acc, ai = 0, a & 0xFF
    for _ in range(8):
        if b & 1:
            acc ^= ai
        if ai & 0x80:
            ai = ((ai << 1) ^ 0x1B) & 0xFF
        else:
            ai = (ai << 1) & 0xFF
        b >>= 1
    return acc & 0xFF


def _xor(x: bytes, y: bytes) -> bytes:
    return bytes(a ^ b for a, b in zip(x, y))


def perm(state: bytes) -> bytes:
    """12 permutation rounds over the 32-byte state."""
    st = list(state)
    for r in range(12):
        nxt = [0] * 32
        for i in range(32):
            rc = (0x2B ^ ((r * 0x11) & 0xFF) ^ i) & 0xFF
            nxt[i] = (gf256(st[i] ^ st[(i + 1) & 31], 0x1F)
                      ^ st[(i + 3) & 31]
                      ^ gf256(st[(i + 17) & 31], rc))
        st = nxt
    return bytes(st)


class AuditTrail:
    """Mirror of the RTL: H chain in RAM, L chain in the root register."""

    MAX_REC = 32

    def __init__(self):
        self.records = []          # list of dicts (as committed to RAM)
        self.last_h = IV           # H of the last record (record 0's H_prev)
        self.st = perm(IV)         # sponge state carries the whole history
        self.link = self.st        # L_0 = perm(IV)

    # -- internal: absorb one 64-byte hash input ----------------------------
    def _absorb(self, blk: bytes) -> bytes:
        st = _xor(self.st, blk[:32])
        st = perm(st)
        st = _xor(st, blk[32:64])
        st = perm(st)
        return st

    def reset(self):
        self.__init__()

    def append(self, model_id: bytes, in_digest: bytes, out: bytes) -> bytes:
        assert len(model_id) == 4 and len(in_digest) == 16 and len(out) == 8
        seq = len(self.records)
        blk = (self.last_h + model_id + in_digest + out
               + bytes([seq & 0xFF, (seq >> 8) & 0xFF, 0, 0]))
        assert len(blk) == 64
        h = self._absorb(blk)
        self.records.append({
            "h_prev": self.last_h, "mid": model_id, "in": in_digest,
            "out": out, "seq": seq, "h_cur": h,
        })
        self.last_h = h
        self.st = perm(_xor(self.link, h))
        self.link = self.st
        return h

    # -- verify: replay every record against the stored root -----------------
    def verify(self, records=None) -> bool:
        recs = self.records if records is None else records
        st = perm(IV)                      # L_0
        lv = st
        prev_h = IV
        for idx, rec in enumerate(recs):
            blk = (rec["h_prev"] + rec["mid"] + rec["in"] + rec["out"]
                   + bytes([idx & 0xFF, (idx >> 8) & 0xFF, 0, 0]))
            st = _xor(st, blk[:32]); st = perm(st)
            st = _xor(st, blk[32:64]); st = perm(st)   # H^
            if st != rec["h_cur"]:
                return False
            if rec["h_prev"] != prev_h:
                return False
            if rec["seq"] != idx:
                return False
            lv = perm(_xor(lv, st))
            st = lv                  # next absorb resumes from the new L
            prev_h = rec["h_cur"]
        return lv == self.link


def check(name: str, cond: bool) -> bool:
    print(("PASS " if cond else "FAIL ") + name)
    return cond


def hexs(b: bytes) -> str:
    return b.hex()


def main() -> int:
    ok = True

    # ---- reference vector: L_0 and the first record chain -------------------
    t = AuditTrail()
    ok &= check("L_0 == perm(IV) == 9cb2622b... (matches RTL testbench)",
                t.link.hex().startswith("9cb2622b"))
    h0 = t.append(bytes([0x30, 0x30, 0x30, 0x30]),
                  bytes(range(0x40, 0x50)),
                  bytes(range(0x80, 0x88)))
    h1 = t.append(bytes([0x31, 0x31, 0x31, 0x31]),
                  bytes(range(0x41, 0x51)),
                  bytes(range(0x82, 0x8A)))
    ok &= check("H chains: H_prev(rec1) == H_cur(rec0)",
                t.records[1]["h_prev"] == t.records[0]["h_cur"])
    ok &= check("verify clean trail", t.verify())
    print("    root after 2 records: %s" % hexs(t.link))

    # ---- determinism: identical history => identical root --------------------
    t2 = AuditTrail()
    t2.append(bytes([0x30, 0x30, 0x30, 0x30]), bytes(range(0x40, 0x50)),
              bytes(range(0x80, 0x88)))
    t2.append(bytes([0x31, 0x31, 0x31, 0x31]), bytes(range(0x41, 0x51)),
              bytes(range(0x82, 0x8A)))
    ok &= check("determinism: same history => same root", t2.link == t.link)

    # ---- avalanche: one flipped input bit moves ~half the output bits --------
    import random
    rng = random.Random(1234)
    base = AuditTrail()
    for k in range(8):
        base.append(bytes(rng.getrandbits(8) for _ in range(4)),
                    bytes(rng.getrandbits(8) for _ in range(16)),
                    bytes(rng.getrandbits(8) for _ in range(8)))
    flip = AuditTrail()
    for k, rec in enumerate(base.records):
        din = rec["in"]
        if k == 3:
            b = bytearray(din); b[7] ^= 0x01
            din = bytes(b)
        flip.append(rec["mid"], din, rec["out"])
    moved = sum(bin(a ^ c).count("1")
                for a, c in zip(flip.records[7]["h_cur"],
                                base.records[7]["h_cur"]))
    total = 256
    ok &= check("avalanche: 1 input bit moves %d/256 bits of a later H (~128)"
                % moved, 80 < moved < 176)

    # ---- tamper detection ----------------------------------------------------
    t3 = AuditTrail()
    for k in range(5):
        t3.append(bytes(rng.getrandbits(8) for _ in range(4)),
                  bytes(rng.getrandbits(8) for _ in range(16)),
                  bytes(rng.getrandbits(8) for _ in range(8)))
    ok &= check("clean random trail verifies", t3.verify())

    def tampered(recs):
        return t3.verify(recs)

    r = [dict(x) for x in t3.records]
    b = bytearray(r[2]["in"]); b[5] ^= 0x20
    r[2]["in"] = bytes(b)
    ok &= check("tampered in_digest caught", not tampered(r))

    r = [dict(x) for x in t3.records]
    b = bytearray(r[1]["h_cur"]); b[10] ^= 0x80
    r[1]["h_cur"] = bytes(b)
    ok &= check("tampered H_cur caught", not tampered(r))

    r = [dict(x) for x in t3.records]
    r[3]["seq"] = 9
    ok &= check("replayed/shifted seq caught", not tampered(r))

    r = [dict(x) for x in t3.records]
    del r[2]                      # deletion: the trail skips a link
    ok &= check("deleted record caught (chain skips a link)", not tampered(r))

    r = [dict(x) for x in t3.records]
    r[0], r[1] = r[1], r[0]       # reordering
    ok &= check("reordered records caught", not tampered(r))

    # ---- GF multiplier sanity against the galois library when available ------
    try:
        import galois
        GF = galois.GF(2 ** 8, irreducible_poly=0x11B)
        good = all(int(GF(a) * GF(b)) == gf256(a, b)
                   for a in range(256) for b in range(256))
        ok &= check("gf256 matches galois GF(2^8)/0x11B on all 65536 pairs", good)
    except ImportError:
        print("SKIP gf256 vs galois (library not installed)")

    print()
    if ok:
        print("=== GOLDEN ALL PASS (chain-anchor construction) ===")
        return 0
    print("=== GOLDEN FAILURES ===")
    return 1


if __name__ == "__main__":
    sys.exit(main())
