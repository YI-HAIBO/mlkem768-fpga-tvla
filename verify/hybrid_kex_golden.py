# =============================================================================
# Golden model for A4 hybrid_kex (DH-Mersenne + Kyber KEM + PUF)
# -----------------------------------------------------------------------------
# Bit-exact mirror of rtl/real/hybrid_kex.v:
#   * Mersenne prime M = 2^31 - 1 reduction of products < 2^62
#   * square-and-multiply modexp, MSB-first over 31 exponent bits
#   * KDF: 15 absorb blocks, perm every 4 blocks, 2 final perms, 8x32-bit ARX
# =============================================================================
M32 = 0xFFFFFFFF
M = (1 << 31) - 1          # 0x7FFFFFFF
G = 2                       # generator


def mred(x):
    """reduce x < 2^62 mod (2^31-1)"""
    s = (x & M) + (x >> 31)
    if s >= M:
        s -= M
    if s >= M:
        s -= M
    return s


def modexp(base, e):
    """square-and-multiply, bit 30 down to 0 (RTL mirrors this order)"""
    r = 1
    for i in range(30, -1, -1):
        r = mred(r * r)
        if (e >> i) & 1:
            r = mred(r * base)
    return r


def rotl(x, n):
    return ((x << n) | (x >> (32 - n))) & M32


def perm(st):
    """ARX permutation over 8 words; sequential (blocking) semantics"""
    a, b, c, d, e, f, g, h = st
    for _ in range(4):
        a = (a + e) & M32; e = rotl(e ^ a, 16)
        b = (b + f) & M32; f = rotl(f ^ b, 12)
        c = (c + g) & M32; g = rotl(g ^ c, 8)
        d = (d + h) & M32; h = rotl(h ^ d, 7)
        e = (e + d) & M32; d = rotl(d ^ e, 13)
        f = (f + a) & M32; a = rotl(a ^ f, 9)
        g = (g + b) & M32; b = rotl(b ^ g, 11)
        h = (h + c) & M32; c = rotl(c ^ h, 5)
    return [a, b, c, d, e, f, g, h]


def kdf(ss_dh, kss_bytes, puf256, domain):
    """19 absorb blocks; perm when (i % 4) == 3; 2 final perms"""
    blocks = [ss_dh & M32]
    for j in range(8):                       # 32-byte Kyber SS -> 8 LE words
        w = sum(kss_bytes[4 * j + i] << (8 * i) for i in range(4))
        blocks.append(w)
    for j in range(8):                       # 256-bit PUF -> 8 LE words
        blocks.append((puf256 >> (32 * j)) & M32)
    blocks.append(0x4859424B)                # domain separation "HYBK"
    blocks.append(domain & M32)
    st = [0] * 8
    for i, blk in enumerate(blocks):
        st[i % 8] ^= blk
        if i % 4 == 3:
            st = perm(st)
    st = perm(st)
    st = perm(st)
    key = 0
    for j in range(8):
        key |= st[j] << (32 * j)
    return key


def priv_from_seed(seed):
    a = seed % (M - 1)
    if a == 0:
        a = 1
    return a


if __name__ == "__main__":
    import json

    puf = 0x0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF
    priv0 = priv_from_seed(0x12345678)
    priv1 = priv_from_seed(0x9ABCDEF0)
    A0 = modexp(G, priv0)          # initiator public
    A1 = modexp(G, priv1)          # responder public
    ss_dh_0 = modexp(A1, priv0)    # initiator computes B^a
    ss_dh_1 = modexp(A0, priv1)    # responder computes A^b
    assert ss_dh_0 == ss_dh_1, "DH agreement failed"

    kss = bytes(range(32))
    domain = 1
    key0 = kdf(ss_dh_0, kss, puf, domain)
    key1 = kdf(ss_dh_1, kss, puf, domain)
    assert key0 == key1, "KDF agreement failed"

    out = {
        "M": hex(M), "G": G,
        "priv0": hex(priv0), "priv1": hex(priv1),
        "A0_public": hex(A0), "A1_public": hex(A1),
        "ss_dh": hex(ss_dh_0),
        "kss_hex": kss.hex(),
        "puf": hex(puf),
        "domain": domain,
        "session_key": hex(key0)
    }
    print(json.dumps(out, indent=2))
