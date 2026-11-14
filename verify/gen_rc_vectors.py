"""gen_rc_vectors.py — authoritative Keccak-f[1600] golden + RC generator.

Fixes the RC typos found in both rtl/core/keccak_perm.v (rounds 22,23) and
verify/keccak_model.py (rounds 21,22).  Round constants are generated from the
FIPS 202 LFSR (8-bit, 0x71 polynomial) so they are never hand-typed wrong.

Outputs:
  1. Corrected 24-entry RC list (printed + written to rc24.txt for reference)
  2. Self-test of a clean permutation model against hashlib (must PASS)
  3. Verilog `get_rc` case block matching the corrected RC
  4. Golden 1600-bit states for keccak_perm tests (zero-input, single-bit)
  5. SHAKE-128/256 golden byte vectors for the sponge testbench
"""

import hashlib

MASK64 = (1 << 64) - 1

# ---- rho offsets r[x][y], x=col, y=row (canonical FIPS 202) -------------
R = [
    [0, 36, 3, 41, 18],
    [1, 44, 10, 45, 2],
    [62, 6, 43, 15, 61],
    [28, 55, 25, 21, 56],
    [27, 20, 39, 8, 14],
]


def _rol(x, n):
    n %= 64
    if n == 0:
        return x & MASK64
    return ((x << n) | (x >> (64 - n))) & MASK64


# ---- round constants via LFSR (authoritative) ----------------------------
def gen_rc():
    rc = []
    lfsr = 0x01
    for _ in range(24):
        val = 0
        for j in range(7):
            if lfsr & 1:
                val ^= 1 << ((1 << j) - 1)
            if lfsr & 0x80:
                lfsr = ((lfsr << 1) ^ 0x71) & 0xFF
            else:
                lfsr = (lfsr << 1) & 0xFF
        rc.append(val)
    return rc


RC = gen_rc()


def permute(lanes):
    A = list(lanes)
    for rnd in range(24):
        C = [A[x] ^ A[x + 5] ^ A[x + 10] ^ A[x + 15] ^ A[x + 20] for x in range(5)]
        D = [C[(x + 4) % 5] ^ _rol(C[(x + 1) % 5], 1) for x in range(5)]
        tA = [A[x + 5 * y] ^ D[x] for y in range(5) for x in range(5)]
        B = [0] * 25
        for c in range(5):
            for r in range(5):
                src = c + 5 * r
                dst = r + 5 * ((2 * c + 3 * r) % 5)
                B[dst] = _rol(tA[src], R[c][r])
        nA = [0] * 25
        for x in range(5):
            for y in range(5):
                dst = x + 5 * y
                nA[dst] = B[dst] ^ ((~B[((x + 1) % 5) + 5 * y] & MASK64)
                                    & B[((x + 2) % 5) + 5 * y])
        nA[0] ^= RC[rnd]
        A = nA
    return A


def lanes_to_bytes(lanes):
    out = bytearray(200)
    for gi in range(25):
        out[8 * gi:8 * gi + 8] = (lanes[gi] & MASK64).to_bytes(8, "little")
    return bytes(out)


def bytes_to_lanes(b):
    return [int.from_bytes(b[8 * gi:8 * gi + 8], "little") for gi in range(25)]


def _sponge(msg, rate, outlen, pad):
    S = [0] * 25
    ml = len(msg)
    nb = ml // rate
    for i in range(nb):
        blk = bytearray(rate)
        blk[:rate] = msg[i * rate:(i + 1) * rate]
        ln = bytes_to_lanes(bytes(blk) + b"\x00" * (200 - rate))
        S = permute([S[j] ^ ln[j] for j in range(25)])
    rem = ml - nb * rate
    blk = bytearray(rate)
    blk[:rem] = msg[nb * rate:]
    blk[rem] = pad
    blk[-1] ^= 0x80
    ln = bytes_to_lanes(bytes(blk) + b"\x00" * (200 - rate))
    S = permute([S[j] ^ ln[j] for j in range(25)])
    out = bytearray()
    while len(out) < outlen:
        out += lanes_to_bytes(S)[:rate]
        if len(out) < outlen:
            S = permute(S)
    return bytes(out[:outlen])


def shake128(msg, n):
    return _sponge(msg, 168, n, 0x1F)


def shake256(msg, n):
    return _sponge(msg, 136, n, 0x1F)


def selftest():
    ok = True
    cases = [
        ("shake128 empty", b"", 32, "128"),
        ("shake128 abc", b"abc", 32, "128"),
        ("shake256 empty", b"", 32, "256"),
        ("shake256 abc", b"abc", 64, "256"),
    ]
    for name, msg, n, kind in cases:
        ref = (hashlib.shake_128(msg) if kind == "128" else hashlib.shake_256(msg)).digest(n)
        got = (shake128 if kind == "128" else shake256)(msg, n)
        good = ref == got
        ok = ok and good
        print("  %-16s %s" % (name, "OK" if good else "MISMATCH"))
    return ok


def print_rc_block():
    print("\n// ---- corrected get_rc case block (paste into keccak_perm.v) ----")
    for r in range(24):
        print("                5'd%-2d: get_rc = 64'h%016x;" % (r, RC[r]))


def print_perm_vectors():
    print("\n// ---- keccak_perm golden (zero input) ----")
    zero = permute([0] * 25)
    print("  // " + lanes_to_bytes(zero).hex())
    for gi in range(25):
        print("        64'h%016x%s" % (zero[gi], "," if gi < 24 else ""))
    print("\n// ---- keccak_perm golden (single bit lane0.bit0) ----")
    single = permute([1] + [0] * 24)
    print("  // " + lanes_to_bytes(single).hex())
    for gi in range(25):
        print("        64'h%016x%s" % (single[gi], "," if gi < 24 else ""))


def print_shake_vectors():
    print("\n// ---- SHAKE-128('') first 32 bytes ----")
    print("  // " + shake128(b"", 32).hex())
    print("\n// ---- SHAKE-128('abc') first 32 bytes ----")
    print("  // " + shake128(b"abc", 32).hex())
    print("\n// ---- SHAKE-256('') first 32 bytes ----")
    print("  // " + shake256(b"", 32).hex())
    print("\n// ---- SHAKE-256('abc') first 64 bytes ----")
    print("  // " + shake256(b"abc", 64).hex())


if __name__ == "__main__":
    print("RC (LFSR-generated, %d entries):" % len(RC))
    for i in range(0, 24, 4):
        print("  " + "  ".join("r%-2d=%016x" % (i + k, RC[i + k]) for k in range(4)))
    ok = selftest()
    print("Keccak model selftest:", "PASS" if ok else "FAIL")
    with open("verify/rc24.txt", "w", encoding="utf-8") as f:
        f.write(" ".join("%016x" % v for v in RC))
    print_rc_block()
    print_perm_vectors()
    print_shake_vectors()
