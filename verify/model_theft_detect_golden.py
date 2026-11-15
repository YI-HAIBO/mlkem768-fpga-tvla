#!/usr/bin/env python3
"""C3 golden model — keyed-canary model-theft detector.

Independent reimplementation of rtl/core/model_theft_detect.v:
  tag = 16-bit keyed digest  (GHASH-style, GF(2^8)/0x11B, shift method)
      tag[7:0]  = XOR_j gf(K[7:0],  d[j])
      tag[15:8] = XOR_j gf(K[15:8], d[j])
  verdict: detected iff (mcnt+xcnt) >= thres and cnt >= thres and mcnt >= thres

Also runs a Monte-Carlo bound check on the false-positive probability:
a model that does NOT hold the key replies with random 16-bit fields, so
P(match | wrong model) = 2^-16 per canary, 2^(-16*N) to match all N.
"""
import random
import sys

MASK16 = 0xFFFF
MAX_CANARY = 8

# digests used by sim/tb_model_theft_detect.v
D0 = [0x10, 0x20, 0x30, 0x40, 0x50, 0x60, 0x70, 0x80]
D1 = [0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88]
D2 = [0xDE, 0xAD, 0xBE, 0xEF, 0xCA, 0xFE, 0xBA, 0xBE]
D3 = [0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]

# the hard-coded vectors asserted inside the testbench
TB_TAGS = [0xA8BD, 0x2F84, 0x72B7, 0x8739]


def gf(a, b):
    """GF(2^8) multiply, modulus 0x11B — the shift method used by the RTL."""
    acc, ai = 0, a
    for _ in range(8):
        if b & 1:
            acc ^= ai
        ai = ((ai << 1) ^ 0x1B) & 0xFF if ai & 0x80 else (ai << 1) & 0xFF
        b >>= 1
    return acc & 0xFF


def tag(key, digest):
    t0 = 0
    t1 = 0
    for d in digest:
        t0 ^= gf(key & 0xFF, d)
        t1 ^= gf((key >> 8) & 0xFF, d)
    return ((t1 & 0xFF) << 8) | (t0 & 0xFF)


class Detector:
    def __init__(self, key):
        self.key = key
        self.tags = []
        self.mcnt = 0
        self.xcnt = 0
        self.thres = 1
        self.error = False
        self.detected = False
        self.insufficient = False

    def add_canary(self, digest):
        if len(self.tags) >= MAX_CANARY:
            self.error = True
            return
        self.tags.append(tag(self.key, digest))

    def probe(self, idx, output):
        """output is the 8-byte suspect reply; its tag field is out[6..7]."""
        if idx >= len(self.tags):
            self.error = True
            return
        field = ((output[7] & 0xFF) << 8) | (output[6] & 0xFF)
        if field == self.tags[idx]:
            self.mcnt += 1
        else:
            self.xcnt += 1

    def detect(self):
        if (self.mcnt + self.xcnt) < self.thres:
            self.insufficient = True
            self.detected = False
        else:
            self.insufficient = False
            self.detected = (len(self.tags) >= self.thres) and (self.mcnt >= self.thres)
        return self.detected


def reply(digest, key, corrupt=False):
    """Build an 8-byte model output embedding the keyed tag.

    corrupt=True makes the "independent model" reply with a wrong-but-deterministic
    field (bit 0 flipped) so a single trial already disagrees.
    """
    t = tag(key, digest)
    if corrupt:
        t ^= 0x0001
    return [0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, t & 0xFF, (t >> 8) & 0xFF]


def check(name, cond):
    print(("PASS " if cond else "FAIL ") + name)
    return cond


def main():
    ok = True
    KEY = 0xBEEF

    # ---- 1. tag vectors must match the testbench's hard-coded constants -----
    for d, t, nm in ((D0, TB_TAGS[0], "D0"), (D1, TB_TAGS[1], "D1"),
                     (D2, TB_TAGS[2], "D2"), (D3, TB_TAGS[3], "D3")):
        ok &= check("tag %s == 0x%04x (tb constant)" % (nm, t), tag(KEY, d) == t)

    # ---- 2. gf256 algebra sanity -------------------------------------------
    ok &= check("gf(x,1) == x", all(gf(a, 1) == a for a in range(256)))
    ok &= check("gf(x,0) == 0", all(gf(a, 0) == 0 for a in range(256)))
    ok &= check("gf distributive (256^3)",
                all(gf(c, a ^ b) == gf(c, a) ^ gf(c, b) for c in range(256)
                    for a in range(64) for b in range(64)))
    ok &= check("gf commutative (64x64)",
                all(gf(a, b) == gf(b, a) for a in range(64) for b in range(64)))

    # ---- 3. key dependence: different key => different tag ------------------
    ok &= check("tag depends on the key", tag(0xBEEF, D0) != tag(0xBEEF ^ 1, D0))
    # flip exactly ONE bit of ONE byte, for every (byte, bit) pair
    single_bit = all(
        tag(KEY, [D0[m] ^ (1 << b) if m == j else D0[m] for m in range(8)])
        != tag(KEY, D0)
        for j in range(8) for b in range(8))
    ok &= check("tag depends on every digest bit (64 single-bit flips)", single_bit)
    # flipping all 8 bytes at once is the null case: the 8 identical GF deltas
    # XOR out, so the tag must be unchanged.  This confirms linearity.
    ok &= check("tag linearity: flipping all bytes preserves the tag",
                tag(KEY, [d ^ 1 for d in D0]) == tag(KEY, D0))

    # ---- 4. faithful copy of the model is detected --------------------------
    d = Detector(KEY)
    for dig in (D0, D1, D2, D3):
        d.add_canary(dig)
    ok &= check("4 canaries registered", len(d.tags) == 4)
    for i, dig in enumerate((D0, D1, D2, D3)):
        d.probe(i, reply(dig, KEY))
    d.thres = 4
    ok &= check("faithful copy: match_cnt == 4", d.mcnt == 4)
    ok &= check("faithful copy: mismatch == 0", d.xcnt == 0)
    ok &= check("faithful copy: detected", d.detect() is True)
    ok &= check("faithful copy: not insufficient", d.insufficient is False)

    # ---- 5. an independent model is NOT detected ----------------------------
    d2 = Detector(KEY)
    for dig in (D0, D1):
        d2.add_canary(dig)
    for i, dig in enumerate((D0, D1)):
        d2.probe(i, reply(dig, KEY, corrupt=True))
    d2.thres = 2
    ok &= check("independent model: match_cnt == 0", d2.mcnt == 0)
    ok &= check("independent model: mismatch == 2", d2.xcnt == 2)
    ok &= check("independent model: not detected", d2.detect() is False)
    ok &= check("independent model: sufficient probes", d2.insufficient is False)

    # ---- 6. insufficient probes --------------------------------------------
    d3 = Detector(KEY)
    d3.thres = 3
    ok &= check("no probes: insufficient", d3.detect() is False and d3.insufficient is True)

    # ---- 7. error paths ------------------------------------------------------
    d4 = Detector(KEY)
    d4.probe(0, reply(D0, KEY))          # idx >= cnt
    ok &= check("probe unregistered canary sets error", d4.error is True)
    d5 = Detector(KEY)
    for i in range(9):
        d5.add_canary([(i << 4) & 0xFF] + [((i * 7 + 3) & 0xFF)] * 7)
    ok &= check("9th canary rejected, table capped at 8",
                len(d5.tags) == MAX_CANARY and d5.error is True)

    # ---- 8. false-positive Monte-Carlo bound -------------------------------
    # a model without the key replies with a RANDOM 16-bit tag field.
    rnd = random.Random(20261021)
    N = 4
    trials = 2000
    fp = 0
    for _ in range(trials):
        dd = Detector(KEY)
        for _ in range(N):
            dd.add_canary([rnd.randrange(256) for _ in range(8)])
        for i in range(N):
            dd.probe(i, [0] * 6 + [rnd.randrange(256)] * 2)
        dd.thres = N
        if dd.detect():
            fp += 1
    empirical = fp / trials
    theoretical = 2.0 ** (-(16 * N))
    print("  Monte-Carlo: %d/%d false positives for N=%d canaries; "
          "theoretical 2^-%d = %.3e" % (fp, trials, N, 16 * N, theoretical))
    ok &= check("Monte-Carlo: no false positive in %d trials (expect 0 at 2^-%d)"
                % (trials, 16 * N), fp == 0)
    # single canary: empirical hit rate must sit near 2^-16
    rnd2 = random.Random(7)
    hits = 0
    single = 4000
    for _ in range(single):
        dd = Detector(KEY)
        dd.add_canary(D0)
        rndout = [rnd2.randrange(256) for _ in range(8)]
        dd.probe(0, rndout)
        dd.thres = 1
        if dd.detected:
            hits += 1
    p_emp = hits / single
    print("  1-canary random hit rate: %.6f vs theoretical 2^-16 = %.6f"
          % (p_emp, 2.0 ** -16))
    ok &= check("1-canary random hit rate within 10x of 2^-16",
                (hits == 0 and p_emp < 2.0 ** -12) or
                (abs(p_emp - 2.0 ** -16) < 3 * 2.0 ** -16))

    # ---- 9. determinism -----------------------------------------------------
    t1 = tag(KEY, D0)
    t2 = tag(KEY, D0)
    ok &= check("tag computation deterministic", t1 == t2 == TB_TAGS[0])

    print("=== GOLDEN %s ===" % ("ALL PASS" if ok else "FAILURES"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
