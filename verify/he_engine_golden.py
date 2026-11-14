# =============================================================================
# Golden model for B1 he_engine.v (BGV-style integer-slot HE inference)
# -----------------------------------------------------------------------------
# Bit-exact mirror of the RTL:
#   q = 2^16, p = 2^8, delta = q/p = 256, q' = 2^15, delta' = 128
#   LCG: state = state * 1664525 + 1013904223 (mod 2^32), out = state >> 16
#   keygen: draw1 -> a, draw2[0] -> s, b = (-a*s) mod 2^16
#   enc(m):  draw -> r (bit 0); c0 = b*r + 256*m mod 2^16; c1 = a*r mod 2^16
#   dec(c0, c1, sw):
#       sw=0: v = (c0 + c1*s) mod 2^16; m = ((v + 128) >> 8) & 0xFF
#       sw=1: v = (c0 + c1*s) mod 2^15; m = ((v + 64)  >> 7) & 0xFF
#   modsw(c) = ((c + 1) >> 1) & 0x7FFF
#   infer: acc_i = sum w_j * ct_ij (mod 2^16); acc0 += bias; msw both; dec sw=1
# =============================================================================
M16 = 0xFFFF
M15 = 0x7FFF


class LCG:
    def __init__(self, seed16):
        self.state = (seed16 << 16) & 0xFFFFFFFF

    def draw(self):
        self.state = (self.state * 1664525 + 1013904223) & 0xFFFFFFFF
        return self.state >> 16


def keygen(lcg):
    a = lcg.draw()
    s = lcg.draw() & 1
    b = (M16 + 1 - a) & M16 if s else 0
    return a, b, s


def enc(lcg, m, a, b):
    r = lcg.draw() & 1
    c0 = (b * r + ((m << 8) & M16)) & M16
    c1 = (a * r) & M16
    return c0, c1


def dec(c0, c1, s, switched=False):
    v = (c0 + (c1 if s else 0))
    if switched:
        v &= M15
        return ((v + 64) >> 7) & 0xFF
    v &= M16
    return ((v + 128) >> 8) & 0xFF


def modsw(c):
    return ((c + 1) >> 1) & M15


def infer(cts, weights, bias):
    acc0, acc1 = 0, 0
    for w, (c0, c1) in zip(weights, cts):
        acc0 = (acc0 + w * c0) & M16
        acc1 = (acc1 + w * c1) & M16
    acc0 = (acc0 + ((bias << 8) & M16)) & M16
    s0, s1 = modsw(acc0), modsw(acc1)
    # secret unknown here -> caller passes s separately
    return s0, s1


def infer_full(cts, weights, bias, s):
    s0, s1 = infer(cts, weights, bias)
    return dec(s0, s1, s, switched=True)


def he_add(cA, cB):
    return ((cA[0] + cB[0]) & M16, (cA[1] + cB[1]) & M16)


def he_sub(cA, cB):
    return ((cA[0] - cB[0]) & M16, (cA[1] - cB[1]) & M16)


def he_pmul(w, c):
    return ((w * c[0]) & M16, (w * c[1]) & M16)


if __name__ == "__main__":
    import json
    seed = 0x1111   # chosen so keygen yields s=1 (non-degenerate ciphertexts)
    lcg = LCG(seed)
    a, b, s = keygen(lcg)
    msgs = [10, 20, 30, 40, 50, 60, 70, 80]
    weights = [1, 2, 3, 4, 5, 6, 7, 8]
    bias = 17
    cts = [enc(lcg, m, a, b) for m in msgs]

    # inference expects plaintext result (w.x + b) mod 256
    plain = (sum(w * m for w, m in zip(weights, msgs)) + bias) & 0xFF
    m_out = infer_full(cts, weights, bias, s)

    out = {
        "seed": seed,
        "pk_a": hex(a), "pk_b": hex(b), "sk_s": s,
        "messages": msgs, "weights": weights, "bias": bias,
        "ciphertexts": [[hex(c[0]), hex(c[1])] for c in cts],
        "plain_expected": plain,
        "he_result": m_out,
        "he_ok": plain == m_out,
        # unit-op vectors
        "add_check": dec(*he_add(cts[0], cts[1]), s) == ((msgs[0] + msgs[1]) & 0xFF),
        "sub_check": dec(*he_sub(cts[2], cts[1]), s) == ((msgs[2] - msgs[1]) & 0xFF),
        "pmul_check": dec(*he_pmul(7, cts[3]), s) == ((7 * msgs[3]) & 0xFF),
        "msw_check": dec(modsw(cts[4][0]), modsw(cts[4][1]), s, switched=True) == msgs[4],
    }
    print(json.dumps(out, indent=2))
