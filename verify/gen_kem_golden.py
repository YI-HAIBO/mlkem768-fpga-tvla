"""
Generate KEM golden vectors for RTL verification.
Runs kem_ref.keygen/encaps/decaps with fixed seed and dumps:
  - sk_bytes, pk_bytes, ct_bytes, ss_bytes
  - intermediate polynomials (s, e, t, r, e1, e2, u, v) as .hex files
  - A matrix entries
"""
import sys, os, hashlib, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kem_ref as K

def poly_to_hex(poly, name, outdir):
    """Dump 256 signed int16 coeffs as 512 hex bytes (big-endian per coeff)."""
    path = os.path.join(outdir, f"{name}.hex")
    with open(path, "w") as f:
        for x in poly:
            v = x & 0xFFFF
            f.write(f"{v:04x}")
    return path

def main():
    outdir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "sim")
    os.makedirs(outdir, exist_ok=True)

    random.seed(20261007)
    d0 = random.randbytes(32)
    pk, sk = K.keygen(d0)
    m0 = random.randbytes(32)
    ct, ss_e = K.encaps(pk, m0)
    ss_d, m_rec = K.decaps(sk, ct)

    t, rho = pk
    d, s, rho_sk = sk

    # Dump scalar seeds
    with open(os.path.join(outdir, "kem_d0.hex"), "w") as f:
        f.write(d0.hex())
    with open(os.path.join(outdir, "kem_m0.hex"), "w") as f:
        f.write(m0.hex())
    with open(os.path.join(outdir, "kem_rho.hex"), "w") as f:
        f.write(rho.hex())
    with open(os.path.join(outdir, "kem_sigma.hex"), "w") as f:
        f.write(hashlib.shake_256(d0).digest(64)[32:].hex())

    # Dump t (public key poly, NTT domain)
    for i in range(K.K):
        poly_to_hex(t[i], f"kem_t{i}", outdir)

    # Dump s (secret, regular domain)
    for i in range(K.K):
        poly_to_hex(s[i], f"kem_s{i}", outdir)

    # Dump ct components
    cu, cv = ct
    for i in range(K.K):
        poly_to_hex(cu[i], f"kem_cu{i}", outdir)
    poly_to_hex(cv, f"kem_cv", outdir)

    # Dump ss
    with open(os.path.join(outdir, "kem_ss.hex"), "w") as f:
        f.write(ss_e.hex())

    # Dump expected recovered message
    with open(os.path.join(outdir, "kem_mrec.hex"), "w") as f:
        f.write(m_rec.hex())

    print("KEM golden vectors generated.")
    print(f"  ss_e = {ss_e.hex()}")
    print(f"  ss_d = {ss_d.hex()}")
    print(f"  round-trip: {'PASS' if ss_e == ss_d else 'FAIL'}")

if __name__ == "__main__":
    main()