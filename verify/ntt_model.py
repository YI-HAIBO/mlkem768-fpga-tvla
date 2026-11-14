"""
Bit-exact model of unified_ntt.v (A1) + Dilithium SIGN-mode derivation.

Ground truth is the published pq-crystals reference NTT tables, which this model
is required to reproduce exactly:

  Kyber    ref/ntt.c : zetas[128], k=1, len=128->2  (7 layers),  f = 1441
  Dilithium ref/ntt.c: zetas[256], k=0 then ++k, len=128->1 (8 layers), f = 41978

Both use NO modular reduction after add/sub inside the butterfly (deferred
reduction); the RTL additionally runs a final barrett pass (S_REDUCE).

The model tracks the absolute maximum of every intermediate so the hardware bit
width can be sized from measured data rather than guessed.
"""
import math
import random
from collections import Counter

# ---------------------------------------------------------------------------
# fixed-width helpers (two's complement)
# ---------------------------------------------------------------------------
def trunc(v, n):
    v &= (1 << n) - 1
    return v - (1 << n) if v >= (1 << (n - 1)) else v


def sext(v, n):
    return v if v < (1 << (n - 1)) else v - (1 << n)


# ---------------------------------------------------------------------------
# published reference tables (ground truth)
# ---------------------------------------------------------------------------
KYBER_ZETAS = [
    -1044, -758, -359, -1517, 1493, 1422, 287, 202,
    -171, 622, 1577, 182, 962, -1202, -1474, 1468,
    573, -1325, 264, 383, -829, 1458, -1602, -130,
    -681, 1017, 732, 608, -1542, 411, -205, -1571,
    1223, 652, -552, 1015, -1293, 1491, -282, -1544,
    516, -8, -320, -666, -1618, -1162, 126, 1469,
    -853, -90, -271, 830, 107, -1421, -247, -951,
    -398, 961, -1508, -725, 448, -1065, 677, -1275,
    -1103, 430, 555, 843, -1251, 871, 1550, 105,
    422, 587, 177, -235, -291, -460, 1574, 1653,
    -246, 778, 1159, -147, -777, 1483, -602, 1119,
    -1590, 644, -872, 349, 418, 329, -156, -75,
    817, 1097, 603, 610, 1322, -1285, -1465, 384,
    -1215, -136, 1218, -1335, -874, 220, -1187, -1659,
    -1185, -1530, -1278, 794, -1510, -854, -870, 478,
    -108, -308, 996, 991, 958, -1460, 1522, 1628,
]
assert len(KYBER_ZETAS) == 128

DILITHIUM_ZETAS = [
     0,    25847, -2608894,  -518909,   237124,  -777960,  -876248,   466468,
 1826347,  2353451,  -359251, -2091905,  3119733, -2884855,  3111497,  2680103,
 2725464,  1024112, -1079900,  3585928,  -549488, -1119584,  2619752, -2108549,
-2118186, -3859737, -1399561, -3277672,  1757237,   -19422,  4010497,   280005,
 2706023,    95776,  3077325,  3530437, -1661693, -3592148, -2537516,  3915439,
-3861115, -3043716,  3574422, -2867647,  3539968,  -300467,  2348700,  -539299,
-1699267, -1643818,  3505694, -3821735,  3507263, -2140649, -1600420,  3699596,
  811944,   531354,   954230,  3881043,  3900724, -2556880,  2071892, -2797779,
-3930395, -1528703, -3677745, -3041255, -1452451,  3475950,  2176455, -1585221,
-1257611,  1939314, -4083598, -1000202, -3190144, -3157330, -3632928,   126922,
 3412210,  -983419,  2147896,  2715295, -2967645, -3693493,  -411027, -2477047,
 -671102, -1228525,   -22981, -1308169,  -381987,  1349076,  1852771, -1430430,
-3343383,   264944,   508951,  3097992,    44288, -1100098,   904516,  3958618,
-3724342,    -8578,  1653064, -3249728,  2389356,  -210977,   759969, -1316856,
  189548, -3553272,  3159746, -1851402, -2409325,  -177440,  1315589,  1341330,
 1285669, -1584928,  -812732, -1439742, -3019102, -3881060, -3628969,  3839961,
 2091667,  3407706,  2316500,  3817976, -3342478,  2244091, -2446433, -3562462,
  266997,  2434439, -1235728,  3513181, -3520352, -3759364, -1197226, -3193378,
  900702,  1859098,   909542,   819034,   495491, -1613174,   -43260,  -522500,
 -655327, -3122442,  2031748,  3207046, -3556995,  -525098,  -768622, -3595838,
  342297,   286988, -2437823,  4108315,  3437287, -3342277,  1735879,   203044,
 2842341,  2691481, -2590150,  1265009,  4055324,  1247620,  2486353,  1595974,
-3767016,  1250494,  2635921, -3548272, -2994039,  1869119,  1903435, -1050970,
-1333058,  1237275, -3318210, -1430225,  -451100,  1312455,  3306115, -1962642,
-1279661,  1917081, -2546312, -1374803,  1500165,   777191,  2235880,  3406031,
 -542412, -2831860, -1671176, -1846953, -2584293, -3724270,   594136, -3776993,
-2013608,  2432395,  2454455,  -164721,  1957272,  3369112,   185531, -1207385,
-3183426,   162844,  1616392,  3014001,   810149,  1652634, -3694233, -1799107,
-3038916,  3523897,  3866901,   269760,  2213111,  -975884,  1717735,   472078,
 -426683,  1723600, -1803090,  1910376, -1667432, -1104333,  -260646, -3833893,
-2939036, -2235985,  -420899, -2286327,   183443,  -976891,  1612842, -3545687,
 -554416,  3919660,   -48306, -1362209,  3937738,  1400424,  -846154,  1976782,
]
assert len(DILITHIUM_ZETAS) == 256


def schoolbook(a, b, q, n=256):
    """Negacyclic convolution in Z_q[x]/(x^n+1) -- the gold standard."""
    c = [0] * (2 * n)
    for i in range(n):
        ai = a[i] % q
        if ai:
            for j in range(n):
                c[i + j] += ai * (b[j] % q)
    return [(c[k] - c[k + n]) % q for k in range(n)]


# ---------------------------------------------------------------------------
class RTLNTT:
    """Exact replica of unified_ntt.v arithmetic and stage traversal."""

    def __init__(self, q, bw, layers, bm, bsh, scale_k):
        self.q, self.BW, self.N, self.L = q, bw, 256, layers
        self.SH = bsh
        self.R = pow(2, bw, q)
        self.Rinv = pow(self.R, -1, q)
        self.QINV = pow(q, -1, 1 << bw)
        self.M = bm
        self.ADD = 1 << (bsh - 1)
        self.scale_k = scale_k
        self.overflow = []      # (stage, value) pairs that did not fit BW
        self.bad_barrett = []   # barrett() outputs that left [-q/2, q/2]

    # -- instrumentation -----------------------------------------------------
    def _fit(self, v, stage):
        hi = (1 << (self.BW - 1)) - 1
        lo = -(1 << (self.BW - 1))
        if v > hi or v < lo:
            self.overflow.append((stage, v))
        return trunc(v, self.BW)

    # -- RTL arithmetic ------------------------------------------------------
    def mont_reduce(self, a):
        t = ((a & ((1 << self.BW) - 1)) * self.QINV) & ((1 << self.BW) - 1)
        t_s = sext(t, self.BW)
        r = (a - t_s * self.q) >> self.BW          # >>> BW, arithmetic
        return trunc(r, self.BW)

    def fqmul(self, a, b):
        return self.mont_reduce(sext(a, self.BW) * sext(b, self.BW))

    def barrett(self, a):
        av = sext(a, self.BW)
        v = self.M * av
        t = sext((v + self.ADD) >> self.SH, 8)     # RTL bar_t_reg: signed 8-bit
        r = trunc(av - t * self.q, self.BW)
        if abs(r) > (self.q - 1) // 2 + 1:
            self.bad_barrett.append((av, r))
        return r

    # -- forward : len 2^(log2N-1) -> 2, zeta 1..2^L-1 ----------------------
    def ntt(self, zetas, a, inline_reduce=False):
        a = [self._fit(sext(x, self.BW), 'load') for x in a]
        k = 1
        length = self.N >> 1
        nblk = 1
        per_layer_max = []
        for li in range(self.L):
            for b in range(nblk):
                z = sext(zetas[k], self.BW); k += 1
                st = b * (length << 1)
                for j in range(length):
                    x = sext(a[st + j], self.BW)
                    y = sext(a[st + j + length], self.BW)
                    t = self.fqmul(z, y)
                    sa, sd = x + t, x - t
                    if inline_reduce:
                        sa, sd = self.barrett(sa), self.barrett(sd)
                    a[st + j] = self._fit(sa, 'fwd layer %d' % li)
                    a[st + j + length] = self._fit(sd, 'fwd layer %d' % li)
            length >>= 1
            nblk <<= 1
            per_layer_max.append(max(abs(sext(v, self.BW)) for v in a))
        # RTL S_REDUCE pass
        a = [self.barrett(x) for x in a]
        return a, per_layer_max

    # -- inverse : len 2^(log2N-L) -> 2^(log2N-1), zeta 2^L-1 -> 1 --------
    #   RTL init for 7 layers is len=2/nblk=64; the correct general form is
    #   len = N>>L, nblk = (N>>1)/(N>>L)  ->  2/64 for L=7, 1/128 for L=8.
    def invntt_raw(self, zetas, a):
        """The inverse transform only -- NO final scaling."""
        a = [self._fit(sext(x, self.BW), 'load') for x in a]
        k = (1 << self.L) - 1
        length = self.N >> self.L
        nblk = (self.N >> 1) // length
        per_layer_max = []
        for li in range(self.L):
            for b in range(nblk):
                z = sext(zetas[k], self.BW); k -= 1
                st = b * (length << 1)
                for j in range(length):
                    x = sext(a[st + j], self.BW)
                    y = sext(a[st + j + length], self.BW)
                    a[st + j] = self._fit(self.barrett(x + y), 'inv layer %d' % li)
                    a[st + j + length] = self._fit(
                        self.fqmul(z, sext(y - x, self.BW)), 'inv layer %d' % li)
            length <<= 1
            nblk >>= 1
            per_layer_max.append(max(abs(sext(v, self.BW)) for v in a))
        return a, per_layer_max

    def invntt(self, zetas, a):
        """RTL behaviour: inverse transform followed by the S_SCALE pass."""
        raw, per_layer_max = self.invntt_raw(zetas, a)
        return [self.fqmul(x, self.scale_k) for x in raw], per_layer_max


def derive_scale(ntt, zetas, f=None, inline_reduce=False):
    """Find k so that invntt_raw(ntt(f)) * k == f*R (mod q) for all f.

    Let C = (invntt_raw(ntt(e0)))[0]; the NTT pair is a proper inverse, so
    invntt_raw(ntt(f))[i] == C * f[i] (mod q).  The final scale pass computes
    mont_reduce(raw * k) = raw * k * R^-1, so we need k = R^2 * C^-1 (mod q).
    """
    e0 = [0] * 256
    e0[0] = 1
    fwd, _ = ntt.ntt(zetas, e0, inline_reduce=inline_reduce)
    raw, _ = ntt.invntt_raw(zetas, fwd)
    C = raw[0] % ntt.q
    # sanity: e0 must map back to a pure delta (C at index 0, 0 elsewhere)
    offdiag = [i for i in range(256) if i and (raw[i] % ntt.q) != 0]
    if C == 0 or offdiag:
        raise ValueError("NTT pair not a clean inverse: C=%s offdiag=%s"
                         % (C, offdiag[:8]))
    k = (ntt.R * ntt.R % ntt.q) * pow(C, -1, ntt.q) % ntt.q
    return k, k, 256, 256
