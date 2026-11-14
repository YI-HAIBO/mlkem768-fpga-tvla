#!/usr/bin/env python3
"""
NIST SP 800-22 Rev 1a randomness test suite for A2 puf_trng_fused output.

Reads the binary file collected by sim/tb_puf_trng_nist.v and runs the
statistical tests. Significance level alpha = 0.01.

Usage: python verify/run_nist_tests.py [binary_file]
"""
import sys
import math
import struct

try:
    import numpy as np
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False

# ============================================================
# Helper functions
# ============================================================

def read_bits(path):
    """Read binary file and return a list of bits (MSB first per byte)."""
    with open(path, 'rb') as f:
        data = f.read()
    bits = []
    for byte in data:
        for i in range(7, -1, -1):
            bits.append((byte >> i) & 1)
    return bits


def igamma(s, x):
    """Incomplete gamma function (regularized)."""
    if x < 0:
        return 0.0
    if x == 0:
        return 0.0
    # Use series expansion for small x, continued fraction for large x
    if x < s + 1:
        # Series expansion
        term = 1.0 / s
        total = term
        n = 0
        while True:
            n += 1
            term *= x / (s + n)
            total += term
            if abs(term) < 1e-15 * abs(total) or n > 1000:
                break
        return total * math.exp(-x + s * math.log(x) - math.lgamma(s))
    else:
        # Continued fraction
        b = x + 1 - s
        c = 1e30
        d = 1.0 / b
        h = d
        for i in range(1, 1000):
            an = -i * (i - s)
            b += 2
            d = an * d + b
            if abs(d) < 1e-30:
                d = 1e-30
            c = b + an / c
            if abs(c) < 1e-30:
                c = 1e-30
            d = 1.0 / d
            delta = d * c
            h *= delta
            if abs(delta - 1) < 1e-15:
                break
        return 1.0 - math.exp(-x + s * math.log(x) - math.lgamma(s)) * h


def erf(x):
    """Error function."""
    return math.erf(x)


def p_value_ks(z):
    """KS test p-value for a single z."""
    # Not used directly; NIST uses igamma
    pass


# ============================================================
# Test 1: Frequency (Monobit) Test
# ============================================================
def test_monobit(bits):
    n = len(bits)
    ones = sum(bits)
    zeros = n - ones
    s_obs = abs(ones - zeros)
    s_ref = s_obs / math.sqrt(n)
    p_value = math.erfc(s_ref / math.sqrt(2))
    return p_value, {"ones": ones, "zeros": zeros, "s_obs": s_obs}


# ============================================================
# Test 2: Frequency Test within a Block
# ============================================================
def test_block_frequency(bits, block_size=128):
    n = len(bits)
    num_blocks = n // block_size
    if num_blocks == 0:
        return 0.0, {"error": "not enough blocks"}
    chi_sq = 0.0
    for i in range(num_blocks):
        block = bits[i * block_size:(i + 1) * block_size]
        ones = sum(block)
        pi = ones / block_size
        chi_sq += 4 * block_size * (pi - 0.5) ** 2
    p_value = igamma(num_blocks / 2.0, chi_sq / 2.0)
    return p_value, {"num_blocks": num_blocks, "chi_sq": chi_sq}


# ============================================================
# Test 3: Runs Test
# ============================================================
def test_runs(bits):
    n = len(bits)
    ones = sum(bits)
    pi = ones / n
    # Pre-test: frequency test must pass
    if abs(pi - 0.5) >= 2.0 / math.sqrt(n):
        return 0.0, {"pi": pi, "failed_pretest": True}
    # Count runs
    runs = 1
    for i in range(1, n):
        if bits[i] != bits[i - 1]:
            runs += 1
    p_value = math.erfc(abs(runs - 2 * n * pi * (1 - pi)) /
                        (2 * math.sqrt(2 * n) * pi * (1 - pi)))
    return p_value, {"runs": runs, "pi": pi}


# ============================================================
# Test 4: Longest Run of Ones in a Block
# ============================================================
def test_longest_run(bits):
    n = len(bits)
    if n < 128:
        return 0.0, {"error": "n too small"}
    # Use block size 128 (for n >= 128)
    if n < 6272:
        block_size = 8
        k = 3
        v = [1, 2, 3, 4]
        pi = [0.21484375, 0.3671875, 0.23046875, 0.1875]
    elif n < 750000:
        block_size = 128
        k = 5
        v = [4, 5, 6, 7, 8, 9]
        pi = [0.1174035788, 0.2424805547, 0.2499739620,
              0.1752694093, 0.1015900424, 0.1134894528]
    else:
        block_size = 10000
        k = 6
        v = [10, 11, 12, 13, 14, 15, 16]
        pi = [0.0882, 0.2092, 0.2485, 0.1933, 0.1208, 0.0675, 0.0725]

    num_blocks = n // block_size
    if num_blocks == 0:
        return 0.0, {"error": "not enough blocks"}

    freq = [0] * (k + 1)
    for i in range(num_blocks):
        block = bits[i * block_size:(i + 1) * block_size]
        longest = 0
        current = 0
        for b in block:
            if b == 1:
                current += 1
                if current > longest:
                    longest = current
            else:
                current = 0
        if longest >= v[0]:
            idx = min(longest - v[0], k)
        else:
            idx = 0
        # Clamp to valid range
        if longest < v[0]:
            idx = 0
        elif longest >= v[k]:
            idx = k
        else:
            idx = longest - v[0]
        freq[idx] += 1

    chi_sq = sum((freq[i] - num_blocks * pi[i]) ** 2 /
                 (num_blocks * pi[i]) for i in range(k + 1))
    p_value = igamma(k / 2.0, chi_sq / 2.0)
    return p_value, {"num_blocks": num_blocks, "freq": freq, "chi_sq": chi_sq}


# ============================================================
# Test 5: Binary Matrix Rank Test
# ============================================================
def test_matrix_rank(bits):
    n = len(bits)
    rows, cols = 32, 32
    block_size = rows * cols
    num_blocks = n // block_size
    if num_blocks < 1:
        return 0.0, {"error": "not enough data"}

    def matrix_rank(matrix):
        """Compute rank of binary matrix using Gaussian elimination."""
        m = [row[:] for row in matrix]
        rank = 0
        for col in range(cols):
            # Find pivot
            pivot = -1
            for row in range(rank, rows):
                if m[row][col] == 1:
                    pivot = row
                    break
            if pivot == -1:
                continue
            # Swap
            m[rank], m[pivot] = m[pivot], m[rank]
            # Eliminate
            for row in range(rows):
                if row != rank and m[row][col] == 1:
                    for c in range(cols):
                        m[row][c] ^= m[rank][c]
            rank += 1
        return rank

    full_rank = 0
    near_full = 0
    other = 0
    for i in range(num_blocks):
        block = bits[i * block_size:(i + 1) * block_size]
        matrix = []
        for r in range(rows):
            matrix.append(block[r * cols:(r + 1) * cols])
        rank = matrix_rank(matrix)
        if rank == 32:
            full_rank += 1
        elif rank == 31:
            near_full += 1
        else:
            other += 1

    n_blocks = num_blocks
    p_value = igamma(1.0, (full_rank - 0.2888 * n_blocks) ** 2 /
                     (0.2888 * n_blocks)) + \
        igamma(1.0, (near_full - 0.5776 * n_blocks) ** 2 /
               (0.5776 * n_blocks))
    p_value = min(p_value, 1.0)
    return p_value, {"full_rank": full_rank, "near_full": near_full,
                     "other": other, "num_blocks": n_blocks}


# ============================================================
# Test 6: Discrete Fourier Transform (Spectral) Test
# ============================================================
def test_dft(bits):
    n = len(bits)
    # Convert to +/-1
    x = [2 * b - 1 for b in bits]
    n_half = n // 2
    threshold = math.sqrt(math.log(1 / 0.05) * n)

    if HAS_NUMPY:
        # Use numpy FFT for O(n log n)
        x_arr = np.array(x, dtype=np.float64)
        spectrum = np.fft.fft(x_arr)
        modulus = np.abs(spectrum[:n_half])
        count = int(np.sum(modulus < threshold))
    else:
        # Pure Python DFT - use a subset to keep runtime reasonable
        max_n = min(n, 65536)  # limit to 64K samples
        n_half = max_n // 2
        threshold = math.sqrt(math.log(1 / 0.05) * max_n)
        count = 0
        for k in range(n_half):
            real = 0.0
            imag = 0.0
            for j in range(max_n):
                angle = -2.0 * math.pi * k * j / max_n
                real += x[j] * math.cos(angle)
                imag += x[j] * math.sin(angle)
            modulus = math.sqrt(real * real + imag * imag)
            if modulus < threshold:
                count += 1

    # Expected count: 95% of n_half should be BELOW threshold
    np_ = n_half * 0.95
    p_value = math.erfc(abs(count - np_) /
                        (math.sqrt(2 * n_half * 0.95 * 0.05)))
    return p_value, {"count_below": count, "expected": np_,
                     "threshold": threshold}


# ============================================================
# Test 7: Non-overlapping Template Matching Test
# ============================================================
def test_non_overlapping(bits, template=None):
    """Non-overlapping template matching test."""
    if template is None:
        template = [0, 0, 0, 0, 0, 0, 0, 0, 1]  # 9-bit template
    n = len(bits)
    m = len(template)
    block_size = 1032  # NIST recommends >= 1032 for m=9
    num_blocks = n // block_size
    if num_blocks < 1:
        return 0.0, {"error": "not enough data"}

    # Count non-overlapping matches per block
    counts = []
    for i in range(num_blocks):
        block = bits[i * block_size:(i + 1) * block_size]
        count = 0
        j = 0
        while j <= len(block) - m:
            if block[j:j + m] == template:
                count += 1
                j += m  # non-overlapping
            else:
                j += 1
        counts.append(count)

    # Theoretical mean and std
    mean = (block_size - m + 1) / (2 ** m)
    std = math.sqrt(block_size * ((1 / 2 ** m) - (m + 1) / 2 ** (2 * m)))
    if std == 0:
        return 0.0, {"error": "std is zero"}

    chi_sq = sum((c - mean) ** 2 / std ** 2 for c in counts)
    p_value = igamma(num_blocks / 2.0, chi_sq / 2.0)
    return p_value, {"mean": mean, "std": std, "chi_sq": chi_sq,
                     "num_blocks": num_blocks}


# ============================================================
# Test 8: Overlapping Template Matching Test
# ============================================================
def test_overlapping_template(bits):
    n = len(bits)
    m = 9  # template length
    block_size = 1032
    num_blocks = n // block_size
    if num_blocks < 1:
        return 0.0, {"error": "not enough data"}

    template = [1] * m  # all-ones template
    # Count overlapping matches per block
    counts = []
    for i in range(num_blocks):
        block = bits[i * block_size:(i + 1) * block_size]
        count = 0
        for j in range(len(block) - m + 1):
            if block[j:j + m] == template:
                count += 1
        counts.append(count)

    # Chi-square with 6 degrees of freedom (using NIST probabilities)
    k = 5
    pi = [0.364091, 0.185659, 0.093577, 0.045230, 0.020143, 0.008265,
          0.003003, 0.001001, 0.000315, 0.000092]
    # Group counts > k into last bin
    freq = [0] * (k + 1)
    for c in counts:
        if c <= k:
            freq[c] += 1
        else:
            freq[k] += 1

    # Renormalize pi for the grouped bins
    pi_grouped = pi[:k] + [sum(pi[k:])]
    total_pi = sum(pi_grouped)
    pi_grouped = [p / total_pi for p in pi_grouped]

    chi_sq = sum((freq[i] - num_blocks * pi_grouped[i]) ** 2 /
                 (num_blocks * pi_grouped[i]) for i in range(k + 1))
    p_value = igamma(k / 2.0, chi_sq / 2.0)
    return p_value, {"freq": freq, "chi_sq": chi_sq,
                     "num_blocks": num_blocks}


# ============================================================
# Test 9: Maurer's Universal Statistical Test
# ============================================================
def test_universal(bits):
    n = len(bits)
    if n < 1010 * 6:  # Need enough data
        return 0.0, {"error": "n too small"}
    L = 6  # block length
    Q = 640  # number of initialization blocks
    K = n // L - Q  # number of test blocks
    if K < 1:
        return 0.0, {"error": "not enough blocks"}

    # Build table of L-bit blocks
    blocks = []
    for i in range(n // L):
        block = 0
        for j in range(L):
            block = (block << 1) | bits[i * L + j]
        blocks.append(block)

    # Initialize table
    table = {}
    for i in range(Q):
        table[blocks[i]] = i + 1

    # Compute sum of log distances
    total = 0.0
    for i in range(Q, Q + K):
        if blocks[i] in table:
            dist = i + 1 - table[blocks[i]]
            total += math.log2(dist)
        table[blocks[i]] = i + 1

    fn = total / K
    # Theoretical values for L=6
    expected = 5.2177052
    variance = 2.954
    c = 0.7186  # correction factor
    sigma = math.sqrt(variance / K) * c
    p_value = math.erfc(abs(fn - expected) / (math.sqrt(2) * sigma))
    return p_value, {"fn": fn, "expected": expected, "K": K}


# ============================================================
# Test 10: Linear Complexity Test
# ============================================================
def test_linear_complexity(bits):
    n = len(bits)
    block_size = 500
    num_blocks = n // block_size
    if num_blocks < 1:
        return 0.0, {"error": "not enough data"}

    # Berlekamp-Massey algorithm
    def berlekamp_massey(s):
        n = len(s)
        c = [0] * n
        b = [0] * n
        c[0] = 1
        b[0] = 1
        L = 0
        m = 1
        bb = 1
        for i in range(n):
            # Compute discrepancy
            d = s[i]
            for j in range(1, L + 1):
                d ^= c[j] & s[i - j]
            if d == 0:
                m += 1
            elif 2 * L <= i:
                temp = c[:]
                for j in range(n - m):
                    if i - m + 1 + j < n:
                        c[m + j] ^= b[j]
                L = i + 1 - L
                b = temp
                m = 1
                bb = d
            else:
                for j in range(n - m):
                    if i - m + 1 + j < n:
                        c[m + j] ^= b[j]
                m += 1
        return L

    k = 6
    pi = [0.010417, 0.03125, 0.104167, 0.21875, 0.328125,
          0.21875, 0.104167]
    # NIST uses: mean = block_size/2 + correction
    mean = block_size / 2.0

    freq = [0] * (k + 1)
    for i in range(num_blocks):
        block = bits[i * block_size:(i + 1) * block_size]
        L = berlekamp_massey(block)
        # Compute T statistic
        t = (-1) ** (block_size) * (L - mean) + 2.0 / 9.0
        # Assign to bins
        if t <= -3.5:
            freq[0] += 1
        elif t <= -2.5:
            freq[1] += 1
        elif t <= -1.5:
            freq[2] += 1
        elif t <= -0.5:
            freq[3] += 1
        elif t <= 0.5:
            freq[4] += 1
        elif t <= 1.5:
            freq[5] += 1
        else:
            freq[6] += 1

    chi_sq = sum((freq[i] - num_blocks * pi[i]) ** 2 /
                 (num_blocks * pi[i]) for i in range(k + 1))
    p_value = igamma(k / 2.0, chi_sq / 2.0)
    return p_value, {"freq": freq, "chi_sq": chi_sq,
                     "num_blocks": num_blocks}


# ============================================================
# Test 11: Serial Test
# ============================================================
def test_serial(bits, m=16):
    n = len(bits)
    if n < m:
        return 0.0, {"error": "n too small"}

    def count_patterns(bits, m):
        """Count occurrences of all m-bit patterns (circular)."""
        counts = {}
        extended = bits + bits[:m - 1]  # circular extension
        for i in range(n):
            pattern = tuple(extended[i:i + m])
            counts[pattern] = counts.get(pattern, 0) + 1
        return counts

    def psi_sq(bits, m):
        counts = count_patterns(bits, m)
        total = sum(v * v for v in counts.values())
        return (2 ** m / n) * total - n

    psi_m = psi_sq(bits, m)
    psi_m1 = psi_sq(bits, m - 1)
    psi_m2 = psi_sq(bits, m - 2)

    d1 = psi_m - psi_m1
    d2 = psi_m - 2 * psi_m1 + psi_m2

    p1 = igamma(2 ** (m - 2), d1 / 2.0)
    p2 = igamma(2 ** (m - 3), d2 / 2.0)
    return p1, {"psi_m": psi_m, "d1": d1, "d2": d2, "p1": p1, "p2": p2}


# ============================================================
# Test 12: Approximate Entropy Test
# ============================================================
def test_approximate_entropy(bits, m=10):
    n = len(bits)
    if n < m + 1:
        return 0.0, {"error": "n too small"}

    def phi(bits, m):
        extended = bits + bits[:m - 1]
        counts = {}
        for i in range(n):
            pattern = tuple(extended[i:i + m])
            counts[pattern] = counts.get(pattern, 0) + 1
        total = 0.0
        for c in counts.values():
            p_i = c / n
            total += p_i * math.log(p_i)
        return total

    phi_m = phi(bits, m)
    phi_m1 = phi(bits, m + 1)
    chi_sq = 2 * n * (math.log(2) - phi_m + phi_m1)
    p_value = igamma(2 ** (m - 1), chi_sq / 2.0)
    return p_value, {"chi_sq": chi_sq, "ap_en": phi_m - phi_m1}


# ============================================================
# Test 13: Cumulative Sums (Cusums) Test
# ============================================================
def test_cusum(bits):
    n = len(bits)
    x = [2 * b - 1 for b in bits]

    # Forward
    s = [0] * (n + 1)
    for i in range(n):
        s[i + 1] = s[i] + x[i]
    z_max = max(abs(v) for v in s[1:])

    # Compute p-value
    # P(Z >= z_max) using the formula from NIST SP 800-22:
    # p = 1 - sum_{k=-K}^{K} [Phi((4k+1)*z) - Phi((4k-1)*z)]
    z = z_max / math.sqrt(n)

    def norm_cdf(x):
        return 0.5 * (1.0 + math.erf(x / math.sqrt(2.0)))

    total = 0.0
    for k in range(-100, 101):
        total += norm_cdf((4 * k + 1) * z) - norm_cdf((4 * k - 1) * z)
    p_value = 1.0 - abs(total)
    p_value = max(0.0, min(1.0, p_value))
    return p_value, {"z_max": z_max, "z_normalized": z}


# ============================================================
# Test 14: Random Excursions Test
# ============================================================
def test_random_excursions(bits):
    """Random excursions test - uses NIST chi-square approach with proper
    probabilities for states -4..-1, 1..4."""
    n = len(bits)
    x = [2 * b - 1 for b in bits]
    s = [0] * (n + 1)
    for i in range(n):
        s[i + 1] = s[i] + x[i]

    # Find cycles (from one zero crossing to the next)
    cycles = []
    current_cycle = []
    for i in range(1, n + 1):
        if s[i] == 0:
            if current_cycle:
                cycles.append(current_cycle)
            current_cycle = []
        else:
            current_cycle.append(s[i])
    if current_cycle:
        cycles.append(current_cycle)

    num_cycles = len(cycles)

    # For truly random data, the number of zero crossings should be
    # approximately n/pi. If it's drastically lower, the cumulative sum
    # has long excursions, indicating long-range correlation.
    expected_cycles = n / math.pi
    cycle_ratio = num_cycles / expected_cycles if expected_cycles > 0 else 0

    if num_cycles < 500:
        return 0.0, {"error": "num_cycles < 500 (%d)" % num_cycles,
                     "num_cycles": num_cycles,
                     "expected_cycles": expected_cycles,
                     "cycle_ratio": cycle_ratio}

    # NIST chi-square test for each state
    states = [-4, -3, -2, -1, 1, 2, 3, 4]
    min_p = 1.0
    all_pass = True
    for state in states:
        # Count how many cycles have this state at least once
        count = sum(1 for cycle in cycles if state in cycle)
        expected_prob = 0.5 ** abs(state)
        expected = num_cycles * expected_prob
        std = math.sqrt(num_cycles * expected_prob * (1 - expected_prob))
        if std > 0:
            z = abs(count - expected) / std
            p = math.erfc(z / math.sqrt(2))
        else:
            p = 1.0
        if p < 0.01:
            all_pass = False
        min_p = min(min_p, p)

    return min_p, {"num_cycles": num_cycles,
                     "expected_cycles": expected_cycles,
                     "cycle_ratio": cycle_ratio,
                     "all_states_pass": all_pass}


# ============================================================
# Main
# ============================================================
def main():
    if len(sys.argv) > 1:
        data_file = sys.argv[1]
    else:
        data_file = "sim/nist_data.bin"

    print("=== NIST SP 800-22 Randomness Test Suite ===")
    print("  Data file: %s" % data_file)

    bits = read_bits(data_file)
    n = len(bits)
    print("  Bits: %d (%.2f Mbit)" % (n, n / 1e6))
    print("  Significance level: alpha = 0.01")
    print()

    tests = [
        ("1. Frequency (Monobit)", lambda: test_monobit(bits)),
        ("2. Block Frequency (m=128)", lambda: test_block_frequency(bits, 128)),
        ("3. Runs", lambda: test_runs(bits)),
        ("4. Longest Run of Ones", lambda: test_longest_run(bits)),
        ("5. Binary Matrix Rank (32x32)", lambda: test_matrix_rank(bits)),
        ("6. Discrete Fourier Transform", lambda: test_dft(bits)),
        ("7. Non-overlapping Template", lambda: test_non_overlapping(bits)),
        ("8. Overlapping Template", lambda: test_overlapping_template(bits)),
        ("9. Maurer's Universal", lambda: test_universal(bits)),
        ("10. Linear Complexity", lambda: test_linear_complexity(bits)),
        ("11. Serial (m=16)", lambda: test_serial(bits, 16)),
        ("12. Approximate Entropy (m=10)", lambda: test_approximate_entropy(bits, 10)),
        ("13. Cumulative Sums", lambda: test_cusum(bits)),
        ("14. Random Excursions", lambda: test_random_excursions(bits)),
    ]

    passed = 0
    failed = 0
    for name, test_fn in tests:
        try:
            p_value, details = test_fn()
            status = "PASS" if p_value >= 0.01 else "FAIL"
            if status == "PASS":
                passed += 1
            else:
                failed += 1
            detail_str = ""
            if "error" in details:
                detail_str = " (%s)" % details["error"]
            elif "chi_sq" in details:
                detail_str = " (chi_sq=%.2f)" % details["chi_sq"]
            print("  %-35s p=%.6f  %s%s" % (name, p_value, status, detail_str))
        except Exception as e:
            print("  %-35s ERROR: %s" % (name, str(e)))
            failed += 1

    print()
    print("=== Summary: %d/%d passed (%d failed) ===" %
          (passed, len(tests), failed))
    if failed == 0:
        print("ALL TESTS PASSED")
    else:
        print("SOME TESTS FAILED")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
