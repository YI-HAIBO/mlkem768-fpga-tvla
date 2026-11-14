#!/usr/bin/env python3
"""C4 golden model — PUF-bound unclonable model weights.

Independent reimplementation of rtl/core/puf_model_bind.v:
  prf(s) = 12 rounds of  AES-MixColumn + AddRoundConstant + RotateLeft1
  id     = prf(die_seed)
  ks(i)  = byte (i & 3) of prf(id ^ i)
  seal   enc[i] = w[i] ^ ks(i),  tag = id & 0xFF
  open   w[i]   = enc[i] ^ ks(i)          (XOR is its own inverse)
  verify tag_in_ram == id & 0xFF
"""
import sys

NB = 32

RC = [0xE8, 0x96, 0x6C, 0x1B]   # byte 0..3, from the RTL concatenation


def gf(a, b):
    """GF(2^8) multiply, modulus 0x11B — shift method, same as B4/C3."""
    acc, ai = 0, a & 0xFF
    for _ in range(8):
        if b & 1:
            acc ^= ai
        ai = ((ai << 1) ^ 0x1B) & 0xFF if ai & 0x80 else (ai << 1) & 0xFF
        b >>= 1
    return acc & 0xFF


def prf(s):
    """12-round PRF over a 32-bit word."""
    x = s & 0xFFFFFFFF
    for r in range(12):
        rb = (x >> 0) & 0xFF
        b = []
        for q in range(4):
            y0 = (x >> (8 * q)) & 0xFF
            y1 = (x >> (8 * ((q + 1) % 4))) & 0xFF
            y2 = (x >> (8 * ((q + 2) % 4))) & 0xFF
            y3 = (x >> (8 * ((q + 3) % 4))) & 0xFF
            b.append(gf(0x02, y0) ^ gf(0x03, y1) ^ y2 ^ y3)
        x = sum(b[q] << (8 * q) for q in range(4)) & 0xFFFFFFFF
        rc = 0
        for q in range(4):
            rc |= ((RC[q] ^ (r & 0xFF)) & 0xFF) << (8 * q)
        x ^= rc
        x = ((x << 1) | (x >> 31)) & 0xFFFFFFFF   # rotate left by 1
    return x


def chip_id(die_seed):
    return prf(die_seed & 0xFFFFFFFF)


def ks_byte(cid, i):
    return (prf((cid ^ i) & 0xFFFFFFFF) >> (8 * (i & 3))) & 0xFF


class Chip:
    """A chip = a die_seed plus the weights blob it currently holds."""
    def __init__(self, die_seed):
        self.die = die_seed & 0xFFFFFFFF
        self.cid = chip_id(self.die)
        self.ram = [0] * NB
        self.tag = 0
        self.verify_fail = False

    def seal(self, weights):
        assert len(weights) == NB
        self.ram = [(weights[i] ^ ks_byte(self.cid, i)) & 0xFF for i in range(NB)]
        self.tag = self.cid & 0xFF

    def open(self):
        # in-place XOR, exactly as the RTL C_OPEN does: ram <- ram ^ keystream
        for i in range(NB):
            self.ram[i] = (self.ram[i] ^ ks_byte(self.cid, i)) & 0xFF
        return list(self.ram)

    def verify(self):
        self.verify_fail = (self.tag != (self.cid & 0xFF))
        return not self.verify_fail


def check(name, cond):
    print(("PASS " if cond else "FAIL ") + name)
    return cond


def main():
    ok = True
    DIE_A = 0x11223344
    DIE_B = 0x55667788
    DIE_C = 0xFFFFFFFF
    W = [i for i in range(NB)]                       # plaintext weights 0x00..0x1F

    print("  die_A=0x%08x  id_A=0x%08x  tag_A=0x%02x" % (DIE_A, chip_id(DIE_A), chip_id(DIE_A) & 0xFF))
    print("  die_B=0x%08x  id_B=0x%08x  tag_B=0x%02x" % (DIE_B, chip_id(DIE_B), chip_id(DIE_B) & 0xFF))

    # ---- 1. PRF behaviour --------------------------------------------------
    ok &= check("prf is deterministic", prf(DIE_A) == chip_id(DIE_A))
    ok &= check("prf is not the identity", prf(0x12345678) != 0x12345678)
    ok &= check("prf is injective on a 4096 sample",
                len({prf(x) for x in range(4096)}) == 4096)
    # avalanche: flipping one bit of the seed must move roughly half the bits
    avg = sum(bin(prf(DIE_A) ^ prf(DIE_A ^ (1 << b))).count("1") for b in range(32)) / 32.0
    print("  PRF avalanche: %d.0 bits changed of 32 (ideal 16)" % avg)
    ok &= check("PRF avalanche near 16 bits", 10 <= avg <= 22)

    # ---- 2. identities differ per chip -------------------------------------
    ok &= check("id(A) != id(B)", chip_id(DIE_A) != chip_id(DIE_B))
    ok &= check("id(A) != id(C)", chip_id(DIE_A) != chip_id(DIE_C))
    ok &= check("keystream(A,i) != keystream(B,i) for all i",
                all(ks_byte(chip_id(DIE_A), i) != ks_byte(chip_id(DIE_B), i) for i in range(NB)))

    # ---- 3. seal / open roundtrip -----------------------------------------
    a = Chip(DIE_A)
    a.seal(W)
    ct = list(a.ram)                            # ciphertext snapshot
    diff = sum(1 for i in range(NB) if ct[i] != W[i])
    print("  ciphertext differs from plaintext at %d/%d positions" % (diff, NB))
    ok &= check("ciphertext differs from plaintext on a majority", diff > NB // 2)
    ok &= check("ciphertext is not the all-zero blob", any(ct[i] != 0 for i in range(NB)))
    dec = a.open()
    ok &= check("seal then open recovers the weights", dec == W)
    ok &= check("open is in-place: ram now holds the plaintext", a.ram == W)
    ok &= check("a second open destroys the plaintext (XOR not a one-way door)",
                a.open() != W)
    ok &= check("tag stored on seal == id(A)&0xFF", a.tag == chip_id(DIE_A) & 0xFF)
    ok &= check("verify passes on the sealing chip", a.verify() is True)
    ok &= check("verify_fail clear on the sealing chip", a.verify_fail is False)

    # ---- 4. determinism: sealing twice gives the same ciphertext -----------
    a2 = Chip(DIE_A)
    a2.seal(W)
    ok &= check("sealing twice gives identical ciphertext",
                a2.ram == ct and a2.tag == (chip_id(DIE_A) & 0xFF))
    # a fresh chip with the same die and the same copied blob reads it back fine
    a3 = Chip(DIE_A)
    a3.ram, a3.tag = list(ct), (chip_id(DIE_A) & 0xFF)
    ok &= check("same-die chip opens a copied blob correctly", a3.open() == W)

    # ---- 5. COPY-OUT: clone the sealed blob onto a different chip ----------
    b = Chip(DIE_B)
    b.ram, b.tag = list(ct), (chip_id(DIE_A) & 0xFF)   # physically copied file
    stolen = b.open()
    ok &= check("copy-out: opened weights are NOT the original", stolen != W)
    changed = sum(1 for i in range(NB) if stolen[i] != W[i])
    print("  copy-out: %d/%d bytes differ from the original" % (changed, NB))
    ok &= check("copy-out: a large majority of bytes differ", changed >= NB // 2)
    ok &= check("copy-out: verify_fail latches on the foreign chip", b.verify() is False)
    ok &= check("copy-out: verify_fail is sticky-readable", b.verify_fail is True)

    # ---- 6. a foreign tag alone is detected even without opening -----------
    c = Chip(DIE_C)
    c.tag = chip_id(DIE_A) & 0xFF
    ok &= check("foreign tag alone is rejected", c.verify() is False)

    # ---- 7. the same die seed always gives the same identity --------------
    ok &= check("identity stable across re-seeds",
                chip_id(DIE_A) == chip_id(DIE_A) == chip_id(DIE_A ^ 0))

    # ---- 8. edge: zero die seed ------------------------------------------
    z = Chip(0)
    z.seal(W)
    ok &= check("zero die seed still roundtrips", z.open() == W)
    ok &= check("zero die seed identity is not zero", chip_id(0) != 0)

    print("=== GOLDEN %s ===" % ("ALL PASS" if ok else "FAILURES"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
