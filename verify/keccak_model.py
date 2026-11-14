"""keccak_model.py — clean, hashlib-verified Keccak-f[1600] / SHAKE model.

Convention (FIPS 202):
    state bit A[x, y, z] lives at linear position w*(5*y + x) + z
    => lane index gi = x + 5*y,  x = column (0..4), y = row (0..4)
    => lane gi holds 64 bits, little-endian within the lane.

This module exists because verify/keccak_ref.py carries two bugs
(a mangled rho-offset table and a non-canonical pi mapping) and produced
wrong golden vectors.  Every function here is checked against
hashlib.shake_128 / shake_256 by selftest() below.
"""

import hashlib

MASK64 = (1 << 64) - 1

# rho offsets r[x][y] — x = column, y = row.  Canonical FIPS 202 table.
R = [
    # y=0      y=1      y=2      y=3      y=4
    [0,        36,      3,       41,      18],   # x=0
    [1,        44,      10,      45,      2 ],   # x=1
    [62,       6,       43,      15,      61],   # x=2
    [28,       55,      25,      21,      56],   # x=3
    [27,       20,      39,      8,       14],   # x=4
]

RC = [
    0x0000000000000001, 0x0000000000008082, 0x800000000000808A, 0x8000000080008000,
    0x000000000000808B, 0x0000000080000001, 0x8000000080008081, 0x8000000000008009,
    0x000000000000008A, 0x0000000000000088, 0x0000000080008009, 0x000000008000000A,
    0x000000008000808B, 0x800000000000008B, 0x8000000000008089, 0x8000000000008003,
    0x8000000000008002, 0x8000000000000080, 0x800000008000800A, 0x800000008000000A,
    0x8000000080008081, 0x8000000080008009, 0x000000000000008B, 0x800000008000800B,
]


def _rol(x, n):
    n %= 64
    if n == 0:
        return x & MASK64
    return ((x << n) | (x >> (64 - n))) & MASK64


def permute(lanes):
    """Keccak-p[1600, 24] on a list of 25 lane ints, lane gi = x + 5*y."""
    A = list(lanes)
    for rnd in range(24):
        # ---- theta ----
        C = [A[x] ^ A[x + 5] ^ A[x + 10] ^ A[x + 15] ^ A[x + 20] for x in range(5)]
        D = [C[(x + 4) % 5] ^ _rol(C[(x + 1) % 5], 1) for x in range(5)]
        # D is indexed by column; A'[x,y] = A[x,y] ^ D[x]
        # note the loop order: list index must be x + 5*y
        tA = [A[x + 5 * y] ^ D[x] for y in range(5) for x in range(5)]

        # ---- rho + pi ----
        # canonical: B[x, y] = ROT( A[(x+3y) mod 5, x], r[(x+3y) mod 5, x] )
        # equivalent form used by the RTL:
        #   source lane  = c + 5*r   (c = column, r = row)
        #   dest   lane  = r + 5*((2c + 3r) mod 5)
        B = [0] * 25
        for c in range(5):
            for r in range(5):
                src = c + 5 * r
                dst = r + 5 * ((2 * c + 3 * r) % 5)
                B[dst] = _rol(tA[src], R[c][r])

        # ---- chi ----
        nA = [0] * 25
        for x in range(5):
            for y in range(5):
                dst = x + 5 * y
                nA[dst] = B[dst] ^ ((~B[((x + 1) % 5) + 5 * y] & MASK64)
                                    & B[((x + 2) % 5) + 5 * y])
        # ---- iota ----
        nA[0] ^= RC[rnd]
        A = nA
    return A


def lanes_to_bytes(lanes):
    out = bytearray(200)
    for gi in range(25):
        out[8 * gi:8 * gi + 8] = (lanes[gi] & MASK64).to_bytes(8, "little")
    return bytes(out)


def bytes_to_lanes(b):
    assert len(b) == 200
    return [int.from_bytes(b[8 * gi:8 * gi + 8], "little") for gi in range(25)]


def _sponge(msg, rate, outlen, pad_byte):
    """Generic Keccak sponge.  rate in bytes."""
    S = [0] * 25
    # absorb
    ml = len(msg)
    nb = ml // rate
    for i in range(nb):
        blk = bytearray(rate)
        blk[:rate] = msg[i * rate:(i + 1) * rate]
        ln = bytes_to_lanes(bytes(blk) + b"\x00" * (200 - rate))
        S = permute([S[j] ^ ln[j] for j in range(25)])
    # pad final block
    rem = ml - nb * rate
    blk = bytearray(rate)
    blk[:rem] = msg[nb * rate:]
    blk[rem] = pad_byte
    blk[-1] ^= 0x80
    ln = bytes_to_lanes(bytes(blk) + b"\x00" * (200 - rate))
    S = permute([S[j] ^ ln[j] for j in range(25)])
    # squeeze
    out = bytearray()
    while len(out) < outlen:
        out += lanes_to_bytes(S)[:rate]
        if len(out) < outlen:
            S = permute(S)
    return bytes(out[:outlen])


def shake128(msg, outlen):
    return _sponge(msg, 168, outlen, 0x1F)


def shake256(msg, outlen):
    return _sponge(msg, 136, outlen, 0x1F)


def selftest():
    """Validate the model against hashlib.  Returns list of (name, ok)."""
    results = []
    for name, msg, n in [
        ("shake128 empty 32B", b"", 32),
        ("shake128 abc 32B", b"abc", 32),
        ("shake128 200B 64B", bytes(range(200)), 64),
        ("shake256 empty 32B", b"", 32),
        ("shake256 abc 64B", b"abc", 64),
        ("shake256 200B 64B", bytes(range(200)), 64),
    ]:
        theirs = hashlib.shake_128(msg).digest(n) if "128" in name \
            else hashlib.shake_256(msg).digest(n)
        ours = shake128(msg, n) if "128" in name else shake256(msg, n)
        results.append((name, ours == theirs))
    return results


if __name__ == "__main__":
    ok = True
    for name, good in selftest():
        print("  %-24s %s" % (name, "OK" if good else "MISMATCH"))
        ok = ok and good
    print("keccak_model selftest:", "PASS" if ok else "FAIL")
