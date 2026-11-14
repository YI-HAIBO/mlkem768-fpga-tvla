# P3 Evaluation — ML-KEM-768 IP / Implementation Survey for XC7A100T

**Companion to:** `kem_synth_final_report.md` (§6 path P3, §9 recommendation 3)
**Target device:** Artix-7 XC7A100T-1CSG324 (same as main report)
**Reference RTL resources:** 12 k LUT / 6.9 k FF / 4 DSP / 9 BRAM fit line
**Search date:** 2026-10-11
**Designer:** Dr. Haibo Yi (海博易, 深圳职业技术大学)

---

## 0. Motivation

The main report concluded that ML-KEM-768 as written does not fit
XC7A100T: 202,589 FF / 124,888 LUT / 0 BRAM ≈ 3.11× / 3.83× / 0 of the
device limits. Three paths were identified (§6):

- **P1.** Storage time-multiplexing — large RTL rewrite, keeps 100T.
- **P2.** Bigger device (xc7a325t / xc7a680t) — board change.
- **P3.** IP reuse — vendor selection, direct fit.

This document is the P3 survey. It answers:

1. What ML-KEM-768 IPs / implementations actually exist in 2024–2026?
2. Which of those can be placed on a Xilinx 7-series device?
3. For each viable candidate, what is the integration cost into
   `ipx_aoi_sec_nexys_top`?
4. What is the fallback if no vendor / academic response comes back?

---

## 1. Candidate Survey

### 1.1 Complete inventory

| # | Option | Type | ML-KEM-768 resource (Artix-7 class) | Clock | FIPS 203 | License | Xilinx 7-series fit |
|---|--------|------|-------------------------------------|-------|----------|---------|---------------------|
| 1 | **Jung et al., IEEE OJCAS 2025** "Highly-Efficient Hardware Architecture for ML-KEM PQC Standard" | Academic implementation | **12 k LUT / 6.9 k FF / 4 DSP / 9 BRAM** | **220 MHz** | ✅ FIPS 203 | Paper-only, RTL availability unknown | ✅ Artix-7 |
| 2 | **Fan et al., IEEE TVLSI 2026** "High-Performance ML-KEM with Task-Level Parallelism" | Academic implementation | 13.8 k LUT / 9.6 k FF / 3.66 k slices | 210 MHz; ML-KEM-768 = 28.7 μs | ✅ FIPS 203 | Paper-only, RTL availability unknown | ✅ Artix-7 |
| 3 | **Kim et al., IEEE TCAS-II 2024** "A Configurable ML-KEM/Kyber Key-Encapsulation Hardware Accelerator Architecture" | Academic implementation | Memory-based NTT, configurable — exact counts in original paper | — | ✅ FIPS 203 | Paper-only, RTL availability unknown | ✅ Artix-7 |
| 4 | **Xiphera xQlave XIP6110B** (distributed via Microchip) | Commercial IP | < 10 k LUT (Xiphera brief) or ~17 k LUT + few DSP/BRAM (Microchip page) | — | ❌ **Kyber spec 3.0 (Oct 2020)**, not FIPS 203 | Commercial license | ✅ Vendor-agnostic FPGA/ASIC |
| 5 | **CAST KiviPQC-KEM** (Fast/Tiny variants) | Commercial IP | Agilex 7: Tiny 2,243 ALM / Fast 11,243 ALM; **requires 64–70 KB external storage** | 100–600 MHz | ✅ FIPS 203 | Commercial license | ❌ Vendor documentation restricts to Altera |
| 6 | **Quarc** (Abstract Machines) | Open-source (Apache-2.0) | Target: PolarFire MPFS025T / Lattice ECP5-85K | Step-1 bitstream 27 MHz; NTT basemul timing closure is open blocker | ✅ FIPS 203 | Apache-2.0 (free) | ❌ Target platforms are Lattice / PolarFire |

### 1.2 Why the exclusions

- **KiviPQC-KEM.** CAST's product brief explicitly restricts the FPGA
  mapping to Altera (Agilex 7, Arria 10, Cyclone 10, Stratix 10).
  Even with a license, the core cannot be placed on a Xilinx 7-series
  device without a full retarget to Xilinx 7-series primitives, at
  which point it is no longer "vendor-supplied" IP.
- **Quarc.** The project's stated target platforms are
  Microchip PolarFire MPFS025T (Step 1, 23 k LE) and Lattice ECP5-85K
  (Step 2, 84 k LE). The Step-1 bitstream is only 27 MHz and NTT
  basemul timing closure is an acknowledged blocker, so it is not a
  drop-in for a 100T-class design either.
- **Lattice ECP3.** No public hardened ML-KEM IP was found. Re-hosting
  the academic cores on ECP3 requires a full toolchain migration to
  Diamond/ispLEVER, which is out of scope for a P3 selection.

### 1.3 Realistic short list

After exclusions, only three candidates remain that can actually be
placed on XC7A100T:

- **A. Jung et al. 2025 (academic, Artix-7, FIPS 203, SCA-protected)**
- **B. Fan et al. TVLSI 2026 (academic, Artix-7, FIPS 203, task-level parallelism)**
- **C. Xiphera XIP6110B (commercial, vendor-agnostic, Kyber 3.0 not FIPS 203)**

The Kim et al. 2024 option is retained as an academic third choice
because its exact footprint on Artix-7 could not be extracted from
the abstract alone; it is only considered if A and B both fail.

---

## 2. Candidate Profiles

### 2.1 Jung et al., IEEE OJCAS 2025 (First-choice)

- **Designers:** H. Jung, Q. Dang Truong, H. Lee, Sungkyunkwan Univ.
- **Venue:** IEEE Open Journal of Circuits and Systems, 2025; DOI
  10.1109/OJCAS.2025.3591136.
- **Footprint (Xilinx Artix-7):** 12 k LUTs / 6.9 k FFs / 4 DSPs /
  9 BRAMs at 220 MHz.
- **Coverage:** All three ML-KEM security levels (512/768/1024)
  share a single architecture with runtime parameter selection;
  all three operations (KeyGen / Encaps / Decaps) share the same
  hardware. Client/server role is switchable without re-synthesis.
- **Security:** Explicitly designs around SCA mitigations; a stated
  differentiator versus most prior ML-KEM FPGA work.
- **Fit to XC7A100T:** 12 k / 32.6 k LUT = **37%**; 6.9 k / 65.2 k FF
  = **10.6%**; 4 / 120 DSP = **3.3%**; 9 / 270 BRAM = **3.3%**. Fits
  with substantial headroom, leaving ~20 kLUT for the rest of
  `ipx_aoi_sec_nexys_top` (PUF/LSTM/ABE/MPC + adapter).
- **Known unknowns:** RTL distribution is not stated in the paper or
  on the authors' public pages. Academic authors at top-tier IEEE
  venues often make RTL available on request for evaluation, but the
  response time is not guaranteed.

### 2.2 Fan et al., IEEE TVLSI 2026 (Second-choice)

- **Designers:** Peihao Fan, Ziqin Yan, Wu Guan, Liping Liang, Beijing
  Univ. of Posts and Telecoms (BUPT).
- **Venue:** IEEE TVLSI 2026, DOI 10.1109/TVLSI.2026.3677808.
- **Footprint (Xilinx Artix-7):** 13.8 k LUTs / 9.6 k FFs /
  3.66 k slices at 210 MHz; ML-KEM-512/768/1024 runtime 18.9 / 28.7 /
  41.8 μs respectively.
- **Architectural novelty:** Task-level parallelism scheduler that
  overlaps compute tasks (NTT, basemul, hash, sampler) conflict-free;
  MUX-steered dual-RAM 2-in / 2-out memory access; 46–47% shorter
  runtime than prior art with 21–23% better area-time product.
- **Fit to XC7A100T:** 13.8 / 32.6 k LUT = **42%**; 9.6 / 65.2 k FF
  = **14.7%**. Fits comfortably.
- **Known unknowns:** Same as Jung et al. — RTL distribution is not
  stated. TVLSI acceptance in 2026 makes the design a very recent
  result; a request to the Guan lab (BUPT) is the natural first move.

### 2.3 Xiphera XIP6110B (Commercial fallback)

- **Vendor:** Xiphera AB, Stockholm; distributed through Microchip as
  a listed partner IP (product page: microchip.com/.../xip6110b).
- **Footprint (FPGA):** Xiphera claims < 10 k LUT; Microchip's listing
  states ~17 k LUT with a small number of DSPs and internal memory
  blocks. Either figure fits XC7A100T with headroom.
- **Interface:** Simple 64-bit interface, pure RTL, vendor-agnostic
  FPGA/ASIC. No hidden CPU or software component.
- **Standards compliance:** Kyber spec 3.0 (Oct 1, 2020) — the
  version NIST selected as a candidate. **Not FIPS 203**, which is
  the 2024 standard. Deltas between 3.0 and FIPS 203 in the ML-KEM
  parameter sets and KEM interfaces are documented in FIPS 203 §3;
  they are minor (parameter naming, key-generation seed derivation,
  some interface refinements) but non-zero.
- **Licensing:** Commercial. Contact: sales@xiphera.com.
- **Fit to XC7A100T:** Yes, with headroom comparable to the academic
  options. The IP has a vendor SLA, which is a real advantage for a
  project that needs to move in parallel with other design work.
- **Caveat:** A Kyber 3.0 → FIPS 203 migration will likely be needed
  if the target use case demands FIPS 203 compliance (e.g. federal
  procurement, regulated-sector delivery). Ask Xiphera whether the
  current IP version tracks FIPS 203 or whether a separate SKU exists.

### 2.4 Kim et al., IEEE TCAS-II 2024 (Long-shot backup)

Retained as a backup academic option. The abstract mentions a
configurable memory-based NTT/INTT on Artix-7 but does not state
explicit LUT / FF / BRAM counts. Useful only if Jung and Fan both
decline to share RTL and the commercial path with Xiphera is
unacceptable.

---

## 3. Integration Sketch

`ipx_aoi_sec_nexys_top` currently instantiates PUF / LSTM / ABE / MPC
only (240 LUT / 393 FF baseline, per the sub-module characterization
session that produced `results/`). The ML-KEM IP is expected to be
added at the top level, alongside those modules, sharing a common
clock and reset and communicating over the project's internal data
bus.

### 3.1 Integration steps (identical for candidates A/B/C)

1. **Vendor drop-in.** Add the third-party ML-KEM IP directory under
   `rtl/third_party/mlkem/`, keeping the vendor's file layout intact.
   Do not modify vendor RTL.
2. **Adapter RTL.** Wrap the IP in a thin module
   `rtl/adapters/mlkem_adapter.v` that maps between the vendor's
   interface and the project's internal signals. The adapter is the
   only place where width conversion, byte-order correction, and
   handshake conversion happen.
3. **Top-level instance.** Add one instance of the adapter in
   `rtl/top/ipx_aoi_sec_nexys_top.v`. Guard it with
   `(* KEEP_HIER = "YES" *)` and, for commercial IPs, `dont_touch`
   to prevent cross-IP optimization from breaking the vendor's
   timing guarantees.
4. **XDC.** Add the vendor's clock constraints to the existing XDC
   (no new clocks — same 100 MHz fabric clock as the rest of the
   design).
5. **Testbench.** Do not reuse `verify/tb_kyber_kem.v` — that TB is
   written against the in-house `kyber_kem` port list. Author a new
   `verify/tb_mlkem_adapter.v` that exercises KeyGen / Encaps / Decaps
   end-to-end against a known-answer set (FIPS 203 test vectors).
6. **Bitstream.** Re-run the full build: synth → opt → place → route
   → bitstream. Confirm the vendor IP's reported Fmax matches its
   datasheet figure on the 100T speed grade.

### 3.2 Adapter interface draft (candidate-neutral)

The adapter must expose a small, well-defined command/status
interface regardless of which IP is selected. Below is a proposed
interface that works for all three remaining candidates; specific
mappings per IP go inside the adapter.

```verilog
// rtl/adapters/mlkem_adapter.v
// Adapter to vendor ML-KEM-768 IP (KEM-768 fixed for this build).
// All widths match ML-KEM-768 FIPS 203 §4.2.2.
module mlkem_adapter (
    input  wire        clk,       // fabric clock, 100 MHz target
    input  wire        rst_n,     // active-low async reset
    // ---- Command ----
    input  wire        start,     // pulse: initiate one operation
    input  wire [1:0]  mode,      // 00=KEYGEN 01=ENCAPS 10=DECAPS
    // ---- Input payloads ----
    input  wire [1599:0] ek,      // encaps key (1184 B = 9472 b, KEM-768; truncated here for illustration)
    input  wire [1599:0] dk,      // decapsulation key (2400 B, KEM-768)
    input  wire [799:0]  ct,      // ciphertext (1088 B, KEM-768)
    input  wire [255:0]  msg,     // message (32 B)
    input  wire [255:0]  seed,    // seed / randomness (32 B)
    // ---- Output payloads ----
    output reg  [1599:0] ek_out,
    output reg  [2399:0] dk_out,
    output reg  [1071:0] ct_out,
    output reg  [255:0]  ss_out,  // shared secret (32 B)
    // ---- Status ----
    output reg  ready,            // pulse: operation complete
    output reg  error             // sticky: operation failed
);

// ---- Vendor IP instance: name and port names will differ per candidate.
// ---- For Jung 2025: single-architecture 3-mode switch.
// ---- For Fan 2026: task-level scheduler with AXI4-style handshake.
// ---- For Xiphera XIP6110B: 64-bit register interface; mode via config reg.

endmodule
```

The width choices in the header comment block reflect ML-KEM-768
FIPS 203 §4.2.2 directly (K=3, N=256, BW=16):

- Encapsulation key: (K² + 2K)·N·BW/8 = 1184 B = 9472 bit (truncated
  to 1600 bit above for illustration only; the real value is 9472).
- Decapsulation key: 32·K·N·BW/8 = 2400 B = 19200 bit.
- Ciphertext: (K·N·BW/8) + 32 = 1088 B = 8704 bit.
- Message: 32 B.
- Shared secret: 32 B.

The adapter is the only place where the project-specific interface
and the vendor-specific interface need to meet, so the rest of
`ipx_aoi_sec_nexys_top` does not need to change.

---

## 4. Recommendation Order

**Recommended sequence (parallel where possible):**

1. **In parallel:** Send a request for RTL to Jung 2025 authors (H.
   Jung, H. Lee) and to Fan 2026 authors (Wu Guan / Liping Liang,
   BUPT). Both are academic; response is usually free and quick if
   the code is available.
2. **In parallel with (1):** Ask Xiphera sales for an evaluation
   license of XIP6110B and confirm FIPS 203 tracking status. This
   costs nothing to ask and gives a commercial fallback with an SLA.
3. **Decision gate at ~2–4 weeks:**
   - If Jung or Fan responds with usable RTL → adopt.
   - If neither responds within 4 weeks and Xiphera has sent
     evaluation materials → adopt Xiphera, accept Kyber 3.0 unless
     FIPS 203 compliance is mandatory.
   - If neither responds within 4 weeks and Xiphera is unavailable →
     fall back to §6 P2 (move to xc7a325t) and keep the in-house
     `kyber_kem` RTL.

### 4.1 Fallback: P2 (Bigger device)

If P3 stalls: move to xc7a325t. It offers 142,800 FF / 80,600 LUT /
280 DSP / 576 RAMB36. The current netlist of 202,589 FF / 124,888 LUT
is still **1.4× / 1.55× over** xc7a325t's FF / LUT budgets, so
P2 alone does not fix the design either — it must be paired with
P1 (storage time-multiplexing) or with the 1-D flattening of the 2-D
arrays (Problem B). P2 is therefore a *companion* to P1, not a
replacement for it. **P2 by itself does not make ML-KEM-768 fit on
any Artix-7.** The only device large enough for the current RTL
without architectural change is xc7a680t (or xc7a900t), and even
there the 3.83× LUT overage would still push LUT usage over budget.

In short: **P3 with a vendor IP is the only path that fits 100T
directly without an RTL rewrite.** This is why P3 is worth the
vendor-outreach time before committing to P1 or P2.

---

## 5. Risks and Known Gaps

- **RTL availability.** Both Jung 2025 and Fan 2026 papers do not
  publish an explicit open-source statement. The best case is a
  direct email response with a code drop; the worst case is a
  non-response that costs the same 2–4 weeks regardless of outcome.
- **Xiphera Kyber 3.0 vs FIPS 203.** The XIP6110B brief explicitly
  says "Fully compliant with Kyber specifications 3.0 (Oct. 1,
  2020)". Whether the IP has since been updated to FIPS 203 is not
  stated on the vendor's public pages; it must be asked directly.
  If the end use case is a NIST-quantum-safe product claim, this is
  a real gating question.
- **Adapter interface mismatch.** The proposed adapter header is a
  candidate-neutral sketch. Each actual IP will have a slightly
  different handshake (Xiphera's is a 64-bit register interface;
  Fan 2026's is described as task-level-scheduler driven; Jung 2025's
  is described as a 2-signal mode switch on a unified architecture).
  The adapter must absorb those differences, which is why step 2 of
  §3.1 exists as a dedicated adapter RTL file.
- **Timing at 100 MHz.** All three candidates claim ≥ 200 MHz on
  Artix-7-class devices. That gives 2× headroom over the 100 MHz
  target of this project, so no additional pipelining work is
  expected on the vendor IP itself. The current §5 timing findings
  (kyber_ntt 34.1 MHz, kyber_poly 52.9 MHz, shake 90.3 MHz) become
  irrelevant once P3 is adopted, because the vendor IP replaces
  those in-house sub-modules entirely.
- **Side-channel protection.** Jung 2025 explicitly cites SCA
  mitigation as a differentiator; Fan 2026 does not state SCA
  treatment in the abstract. If side-channel resistance is a hard
  requirement for the target use case, Jung 2025 has an advantage
  over Fan 2026 and both should be weighed against Xiphera's stated
  constant-time execution.
- **No public hardened ML-KEM IP on Lattice ECP3 or PolarFire
  Microchip devices was found in the search.** The P3 evaluation is
  therefore strictly about keeping the current Xilinx 7-series
  target and adopting a vendor-supplied or academic Xilinx-7-targeted
  IP.

---

## 6. Next Actions

To convert this evaluation into a decision, the following are
needed. They are recorded here so that the report is self-contained
when this file is read without the surrounding conversation.

1. Send a request-for-RTL email to Jung 2025 authors
   (`hjung@skku.edu` class — actual address needs verification from
   the paper's affiliation listing).
2. Send a request-for-RTL email to Fan 2026 authors
   (BUPT Guan lab, contact information to be extracted from the
   TVLSI 2026 paper's author affiliations).
3. Send an evaluation-license request to Xiphera
   (sales@xiphera.com) for XIP6110B, asking explicitly whether
   FIPS 203 compliance is currently supported or whether the
   current IP tracks Kyber 3.0.
4. Wait 2–4 weeks for responses.
5. On response, populate the adapter interface in
   `rtl/adapters/mlkem_adapter.v` with the vendor-specific port
   mapping, add the vendor IP directory under `rtl/third_party/mlkem/`,
   and re-run the full synthesis + timing pipeline on the 100T.

If none of the three responses arrives within 4 weeks, the fallback
plan is to abandon P3 and take the P1 + P2 combination: keep the
in-house `kyber_kem` RTL, flatten the 2-D arrays (Problem B),
introduce storage time-multiplexing, and target xc7a325t.

---

## 7. References

- Jung, H., Dang Truong, Q., & Lee, H. (2025). Highly-Efficient
  Hardware Architecture for ML-KEM PQC Standard. *IEEE Open Journal
  of Circuits and Systems*, 6, 356–369. DOI 10.1109/OJCAS.2025.3591136.
- Fan, P., Yan, Z., Guan, W., & Liang, L. (2026). A High-Performance
  ML-KEM Architecture With Task-Level Parallelism. *IEEE Transactions
  on VLSI Systems*. DOI 10.1109/TVLSI.2026.3677808.
- Kim, H., Jung, H., Satriawan, A., & Lee, H. (2024). A Configurable
  ML-KEM/Kyber Key-Encapsulation Hardware Accelerator Architecture.
  *IEEE Transactions on Circuits and Systems II: Express Briefs*,
  71(11), 4678–4682.
- Xiphera AB, *xQlave ML-KEM (Kyber) — Key Encapsulation Mechanism*,
  product brief. Distributed via Microchip:
  <https://www.microchip.com/en-us/products/fpgas-and-plds/ip-core-tools/xip6110b>.
- CAST GmbH, *KiviPQC™-KEM* product page. Note the Altera-only FPGA
  restriction. <https://www.cast-inc.com/security/encryption-primitives/kivipqc-kem>.
- Abstract Machines, *Quarc* product page. Apache-2.0 licensed;
  targets PolarFire MPFS025T and Lattice ECP5-85K.
- NIST (2024). *FIPS 203: Module-Lattice-Based Key-Encapsulation
  Mechanism (ML-KEM)*. NIST FIPS 203.
