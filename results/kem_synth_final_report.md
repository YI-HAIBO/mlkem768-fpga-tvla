# ML-KEM-768 (Kyber) FPGA Synthesis Report

**Device:** Artix-7 XC7A100T-1CSG324  
**Tool:** Vivado v2026.1 (win64) Build 6511674  
**Date:** 2026-10-15 (updated: device-budget correction, xc7a200t P2 attempt)  
**Designer:** Dr. Haibo Yi (海博易, 深圳职业技术大学)

---

## 1. Device Resources Available

**CORRECTED 2026-10-15.** This table was originally filled in with
**xc7a50t** figures (32,600 LUT / 65,200 FF / 120 DSP / 270 BRAM) while
the design targets **xc7a100t**.  Every "x times over budget" verdict in
this report that was derived from it is wrong and has been corrected
throughout.  The figures below were read from the same Vivado 2026.1
installation — `get_property` and the `report_utilization` *Available*
column agree exactly (`results/device_budget_probe.log`).

| Resource        | xc7a50t | **xc7a100t (target)** | xc7a200t |
|-----------------|---------|------------------------|----------|
| Slice LUTs      | 32,600  | **63,400**             | 134,600  |
| Slice FFs       | 65,200  | **126,800**            | 269,200  |
| DSP48E1         | 120     | **240**                | 740      |
| Block RAM tile  | 75      | **135**                | 365      |
| Slices          | 8,150   | **15,850**             | 33,650   |

`xc7a325t` and `xc7a680t` **do not exist** in Vivado 2026.1 — the
Artix-7 family stops at `xc7a200t` (`get_parts -regexp {^xc7a.*}`, 32
packages, `results/p2_part_probe.log`).  `xc7a200t` is the largest
Artix-7 and is the only candidate for P2.

---

## 2. Sub-Module Synthesis Results

Each sub-module was synthesized standalone on the target FPGA.

| Module          | LUTs   | FFs    | DSPs | Notes                                       |
|-----------------|--------|--------|------|---------------------------------------------|
| `keccak_perm`   | 2,769  | 3,222  | 0    | Keccak-f1600 permutation core               |
| `shake`         | 10,414 | 11,069 | 2    | SHAKE256 + SHAKE128 (2× keccak_perm)        |
| `kyber_sampler` | 1,388  | 1,819  | 0    | CBD noise sampler                           |
| `kyber_ntt`     | 28,668 | 4,212  | 13   | Forward NTT + inverse INTT, 256-point       |
| `kyber_poly`    | 4,387  | 12,360 | 4    | Polynomial arith + basemul (3×256×16 regs)  |
| `kyber_kem`     | see §3 | see §3 | see §3 | **Synthesizes; pre-P1 netlist is 1.97× the LUT budget** |

Timing reports for these modules are in §5 below.

---

## 3. Full-Top `kyber_kem` — Actual Outcome

The full-top module **does synthesize to completion**: 0 errors,
"Synthesis finished with 0 errors, 32,786 critical warnings and
108 warnings." What fails is that the resulting netlist is far too
large to fit the device.

### 3.1 Actual netlist primitive counts (from Vivado synthesis report)

**Pre-P1 numbers (original, superseded):**

| Primitive | Count   | Role                    |
|-----------|---------|-------------------------|
| FDRE      | 154,223 | Simple flip-flop (FF)   |
| FDCE      | 48,336  | Sync-reset flip-flop    |
| FDPE      | 30      | Async-reset flip-flop   |
| LD        | 9 → **0** | **Latch** (bug, see §4) — removed by the 2026-10-11 fix |
| LUT6      | 70,452  | 6-input LUT             |
| MUXF7     | 36,735  | 7:1 mux                 |
| MUXF8     | 17,701  | 8:1 mux                 |
| IBUF/OBUF | 49 / 78 | I/O buffers             |
| **RAMB**  | **0**   | **No Block RAM used**   |

- **FF total = 202,589 = 1.60× the 126,800 FF limit.**
- **LUT6 + MUXF7 + MUXF8 = 124,888 = 1.97× the 63,400 LUT limit.**
- **Block RAM used: 0.** All polynomial storage dissolved to distributed registers.
- Netlist check: `multi_driven_nets = 16,393 warnings` — a hard correctness
  blocker caused by the latch bug (§4).

**Post-P1-c numbers (2026-10-12 full-top re-synthesis, `results/kem_p1_synth_util.rpt`):**

| Resource       | Count   | Budget  | Utilisation | Status |
|---------------|---------|---------|-------------|--------|
| Slice FFs     | 39,738  | 126,800 | 31.4%       | **FITS** ✅ |
| Total LUTs    | 58,852  | 63,400  | 92.8%       | **FITS**, but above the ~80% routing-closure comfort ceiling ⚠️ |
| — Logic LUTs  | 54,404  | —       | —           | combinational logic |
| — LUTRAMs     | 4,448   | —       | —           | polynomial arrays (distributed RAM) |
| Block RAM tile| 0       | 135     | 0%          | unused — arrays infer as LUTRAM |
| DSP48E1       | 61      | 240     | 25.4%       | fits ✅ |

*Timing (post-synthesis, 100 MHz / 10 ns `clk` constraint):*
*WNS = −59.476 ns (16,951 / 117,845 endpoints failing), WHS = −0.083 ns.*
*The critical path matches the pre-P1 sub-module analysis (§5): the unrolled*
*NTT butterfly dominates at ~29 ns, and the top-level FSM adds the*
*polynomial-array read latency on top.*

- **FF dropped from 202,589 → 39,738 (−80%).** The polynomial arrays are
  no longer dissolved into flip-flops; they are now inferred as distributed
  RAM (LUTRAM).
- **LUT dropped from 124,888 → 58,852 (−53%).** Now 92.8% of the 63,400
  budget — inside budget, but above the ~80% where routing usually closes.
- **Synthesis finished with 0 errors** (was 2 errors after P1-b; 0 before P1).
- **`Synth 8-7186` = 0** (was 101).  **`Synth 8-4767` = 1** (was 20;
  the sole remaining is `round.B_reg` in `keccak_perm.v`; after the
  P1-c async-reset fix its reason changed to "read address port stuck
  at constant" — benign, `B` is a combinational temp array inside the
  Keccak round, not a storage RAM).
- **40 × `Synth 8-6849`** "Infeasible attribute `ram_style = "block"` …
  trying to implement using LUTRAM": the arrays match a RAM template
  (hence LUTRAM inference succeeds) but not a *Block* RAM template.
  The `ram_style` attribute is honoured as "try BRAM first" and falls
  back to LUTRAM when the shape does not fit a RAMB36/RAMB18 tile.

### 3.2 Runtime comparison

| Run | Directive | Elapsed | Outcome |
|-----|-----------|---------|---------|
| Pre-annotation | (default) | 18:38 wall | Completed, 0 errors |
| With `(* ram_style = "block" *)` | (default) | 47 min wall | Completed, 0 errors, identical footprint + 101 spurious warnings |
| After Problem-A fix | RuntimeOptimized | 18:06 to end of synthesis | Completed, 0 errors; 8-6090 × 5 and 8-327 × 1 cleared |
| **After P1-a.1 + P1-b** | RuntimeOptimized | ~10 min | Completed, **2 errors** (cv_poly 8-2914, cu_poly 8-4767); 19/20 arrays → RAM; FF 202,589 → 52,014 |
| **After P1-c (final)** | RuntimeOptimized | **332 s (5.5 min)** | Completed, **0 errors**; FF 39,738 (31.4%), LUT 58,852 (92.8%) |
| **After P1-c + keccak fix** | RuntimeOptimized | 271 s | Completed, **0 errors, 47 warnings**; FF 39,748; `round.B_reg` 8-4767 remains but reason changed to "read address port stuck at constant" (benign) |

The BRAM annotation **doubled runtime with zero effect on the design**.

The Problem-A fix did not change resource footprint — it only redirects
`for`-loop indices onto elaboration-time `integer` variables, which
Vivado unrolls and eliminates.  It also did not change the conclusion:
the pre-P1 design is still 1.60× over the FF limit and 1.97× over the LUT limit.
What it did remove is the latch hazard that made the netlist
unimplementable.

The P1 path (flatten → remove async resets → merge write ports) brought
FF from 202,589 to 39,738 — a **−80% reduction** that puts FF at 31.4%
of the 126,800 budget.  LUT dropped 53% to 92.8% of 63,400 — inside budget
but above the routing-closure comfort mark; the residual is
dominated by `kyber_ntt` (28,565 LUTs, 48% of total), not by the
polynomial arrays (4,448 LUTRAMs, 7.6%).

---

### 3.3 P2 retarget attempt — xc7a200t (2026-10-14 / 2026-10-15)

Retargeting the identical post-P1 netlist to the largest Artix-7
(`xc7a200tfbg484-1`, -1 grade, same timing grade as the 100T part)
was attempted twice — project mode (`scripts/run_kem_synth_p2.py`)
and project-less (`scripts/run_kem_synth_p2b.py`) — and both gave the
same result:

- Synthesis itself is clean: `Synthesis finished with 0 errors, 0
  critical warnings and 47 warnings`; regression guards all quiet
  (8-7186 / 8-2914 / 8-6090 / 8-327 = 0, and the single 8-4767 is the
  known benign `keccak_perm` `round.B_reg` read-address-stuck case).
- Vivado 2026.1 then **hangs** at `Synthesis Optimization Runtime`,
  immediately before `Synthesis Optimization Complete` and `Translating
  synthesized netlist`, so `report_utilization` and `report_timing_summary`
  are never reached and no reports are written.  Reproduced 3 of 3 times,
  every time with the log stopping at the same line and almost the same
  elapsed time (00:05:28, 00:05:28, 00:05:30).  The host is an i5-14600KF
  with 68 GB RAM and 46 GB of free virtual address space, so this is not
  memory pressure, and it is not a project-mode artifact — the identical
  flow on `xc7a100tcsg324-1` completes in 5.5 min.  Treat it as a Vivado
  2026.1 bug on this netlist/part combination, not a design problem.

Useful data harvested from the logs before the hang (pre-optimization,
so an upper bound on the mapped figures):

| Primitive class              | Count | xc7a200t budget | Share |
|------------------------------|-------|-----------------|-------|
| FDCE + FDRE + FDPE (FF)      | 39,748 | 269,200         | 14.8% |
| LUT1–LUT6 + MUXF7 + MUXF8    | 76,045 | 134,600         | 56.5% |
| DSP48E1                      | 61    | 740             | 8.2%  |
| CARRY4                       | 988   | —               | —     |

Both xc7a200t runs produced byte-identical primitive counts, which is the
expected result: the 100T and 200T share the same Artix-7 fabric logic.
**P2 is unnecessary on resource grounds** (§1) and is not currently
achievable with this tool release (§3.3).

---

## 4. Root Causes (three distinct problems)

### Problem A — the counter is broken (real RTL bug) — **FIXED 2026-10-11**

`coeff_cnt` and `byte_cnt` were written by **both** blocking `=`
(inside `for` loops that fill memory) **and** non-blocking `<=`
(the control-path assignments) inside the **same** `always` block;
`load_cnt` had the same defect across three `always` blocks.

- `kyber_kem.v:388` — reset branch used blocking `coeff_cnt = 0`
  inside a nested `for`, while the else-branch used non-blocking.
- Also at L924, L1358, L1482, L1839 (`coeff_cnt`) and L1947 (`byte_cnt`).

Vivado reported:
- `Synth 8-6090` × 5 — "written by both blocking and non-blocking
  assignments, entire logic could be removed"
- `Synth 8-327` — **infers a latch for `coeff_cnt`**
- Netlist: **9 latch (LD) cells**, 16,393 multi-driven nets

**This is a correctness bug, not a style issue.** Any latch in a
clocked design is a timing violation under XDC and defeats
implementation.

**Resolution.** The fix does *not* split the `always` block.  It
introduces three module-scope `integer` loop iterators — `lc`, `lb`,
`ll` — and retargets all 11 `for` loops onto them.  After the change
`coeff_cnt` / `byte_cnt` / `load_cnt` have **zero** for-loop headers
and **zero** blocking assignments left (85 / 42 / 1 non-blocking
writes respectively), and each iterator is written only by loop
control.  Splitting the block would have been riskier: it would have
had to duplicate the reset/`ct_load` guard logic and race the FSM's
own decompress stage.

The now-redundant `<reg> <= 0;` statements after each loop were left
in place deliberately — harmless, and removing them adds edit surface
with no warning-closure benefit.

Verified in `results/kem_cntfix_synth_summary.txt`:

| warning / condition | before | after |
|---|---|---|
| Synth 8-6090 | 5 | **0** |
| Synth 8-327 (latch) | 1 | **0** |
| `inferring latch for variable` | 1 | **0** |

Full regression in `scripts/regress_cntfix.py`: `verify/tb_kyber_kem.v`
built against the fixed file and against `rtl/core/kyber_kem.v.pre_cntfix`
gives identical results — KeyGen 800/800, Encaps 1056/1056, Decaps 0,
Decaps #2 (external `ct_load`) 0, repeat-stability PASS, **TOTAL 0 ERRORS**.
The fix is behaviour-preserving.


### Problem B — 2D array storage cannot be inferred as Block RAM — **FIXED 2026-10-12 (P1-a.1 + P1-b + P1-c)**

The polynomial storage was declared as packed 2D arrays:

```verilog
reg [BW-1:0] s_poly [0:K-1][0:N-1];   // K=3, N=256
```

Adding `(* ram_style = "block" *)` in front of these declarations
produces **101 × `Synth 8-7186`**:

```
WARNING: [Synth 8-7186] Applying attribute ram_style = "block" is
ignored, object 's_poly[0][0]' is not inferred as ram due to
incorrect usage [kyber_kem.v:114]
```

Followed by `Synth 8-4767`:

```
WARNING: [Synth 8-4767] Trying to implement RAM 'A_mat_reg' in
registers. Block RAM or DRAM implementation is not possible;
see log for reasons.
```

**Xilinx only infers Block RAM from 1-D memory arrays with a single
symbolic index that drives both the address ports.** A packed
2-D array `[K-1][N-1]` decomposes into K separate N-wide 1-D
arrays at elaboration and does not match the supported template.

Fix — **applied**: flatten to a single 1-D array with explicit address
arithmetic,

```verilog
(* ram_style = "block" *) reg [BW-1:0] s_poly [0:K*N-1];
// access: s_poly[i*N + j]
```

`scripts/flatten_2d_arrays.py` did this mechanically for all 11 two-D
arrays: **36** access sites rewritten (`X[a][b]` → `X[a*N + b]`) and
12 declarations annotated (`A_mat` was already 1-D, attribute only).
The index expressions included nested slices, e.g.
`t_poly[out_cnt[10:8]][out_cnt[7:0]]`, so the scanner had to be
bracket-depth-aware, comment-aware and string-aware; a plain
`NAME[^[]+` regex would have matched only 3 of the 36 sites.

**Bit-exact regression passed** (`scripts/regress_p1.py`, iverilog +
`verify/tb_kyber_kem.v`): the flattened file and the
`rtl/core/kyber_kem.v.pre_p1` backup both report
`TOTAL: 0 ERRORS (keygen=0 encaps=0 decaps=0 repeat=0)` — KeyGen
800/800, Encaps 1056/1056, Decaps 0 errors, repeat-stability PASS.

**Flattening alone was necessary but not sufficient.** The full-top
re-synthesis after P1-a.1 revealed a second layer of blockers
(`Synth 8-4767` rose from 1 to 20 once the 101 × `8-7186` shape
warnings cleared):

**P1-b — asynchronous reset sensitivity (2026-10-12).** All three
`always` blocks used `@(posedge clk or negedge rst_n)`, and two of them
bulk-cleared arrays in the reset branch with `for` loops (up to 1,024
write ports in a single reset cycle).  Vivado reports:
`1: RAM is sensitive to asynchronous reset signal. this RTL style is not
supported.`  Fix: all three blocks → `@(posedge clk)` (synchronous
reset); reset-branch array clears deleted (dead code — every array is
written before it is read); the `t_poly` KeyGen phase-7 bulk write was
serialised to one coefficient per cycle (256 cycles instead of 1).
`scripts/fix_bram_template.py`, 5 anchored edits, bit-exact regression
`scripts/regress_p1b.py` PASS.

**P1-c — dual write ports on cu_poly / cv_poly (2026-10-12).** After
P1-b, synthesis finished but with 2 hard errors:
`Synth 8-2914 Unsupported RAM template` (cv_poly) and
`Synth 8-4767 Invalid write to RAM / No valid clock` (cu_poly, dissolved
into 12,288 FFs).  Root cause: both arrays were written by **two
separate `always` blocks** (the standalone `ct_load` block and the FSM's
`S_ENC_COMP` state) — two write ports, which Vivado's BRAM template does
not support.  Fix (`scripts/fix_bram_2port.py`, 5 anchored edits):
the `ct_load` block was deleted and its writes merged into the FSM's
`S_IDLE` state; address expressions simplified from
`out_cnt[9:8]*N + out_cnt[7:0]` to the equivalent bit-select
`out_cnt[9:0]`.  Also fixed `keccak_perm.v`: async reset → synchronous
(removed the dead `A[25]` clear loop).  Bit-exact regression
`scripts/regress_p1c.py` PASS.

**Full-top re-synthesis after P1-c** (`results/kem_p1_synth_util.rpt`):
0 errors, FF 39,738 (31.4% of 126,800), LUT 58,852 (92.8% of 63,400),
LUTRAM 4,448, BRAM 0.  The arrays infer as **distributed RAM (LUTRAM)**,
not Block RAM — the `ram_style = "block"` attribute is honoured as a
hint but falls back to LUTRAM (40 × `Synth 8-6849`) because the arrays'
port structure does not match a RAMB36/RAMB18 tile.  The FF explosion is
nevertheless eliminated (−80%), which was the primary blocker.

For K=3, N=256, BW=16 → 3×256×16 = 12,288 bits = ~1.1 BRAM36 per
polynomial. That is legal for one polynomial, but the totals in
§5 still exceed the device.

### Problem C — the poly add/sub datapath is never driven

The 8 signals previously flagged as "undriven wires"
(`poly_add`, `poly_ald`, `poly_aa`, `poly_ad`, `poly_bld`, `poly_ba`,
`poly_bd`, `poly_ra`) are wired to the `kyber_poly` instance at
L252–256 but are only assigned in a reset (L429) and never in the
FSM proper. This is an **unimplemented poly add/sub data path**,
not dead wire. Deleting the declarations would break the instance
ports. The correct fix is to add FSM logic that drives them — or
to explicitly comment out the instance for now.

---

## 5. Timing Reports (sub-modules, 100 MHz / 10 ns period, `kem.xdc`)

All 5 sub-modules synthesise cleanly; the timing picture below is from
`report_timing_summary -setup` after synthesis (delay type = max only).
Hold analysis was skipped because I/O paths are unconstrained in
standalone synthesis, producing spurious hold numbers.

| Module          | WNS (ns) | Critical path (ns) | Fmax (MHz) | Endpoints failing / total | 100 MHz setup |
|-----------------|----------|---------------------|------------|----------------------------|---------------|
| `keccak_perm` (2-way pipeline) | **+6.466** | 3.534 | 104.3 | 0 / 6,443 | ✅ Meets |
| `shake` (absorb pipeline)     | **+1.083** | 8.581 | 111.9 | 0 / 22,770 | ✅ **Closed** |
| `kyber_sampler` | **+4.455** | 5.545 | 96.2 | 0 / 817 | ✅ Meets |
| `kyber_ntt`     | **−19.329** | 29.329 | **34.1** | 5,202 / 8,422 | ❌ 19.33 ns over |
| `kyber_poly`    | **−8.888** | 18.888 | **52.9** | 4,096 / 8,334 | ❌ 8.89 ns over |

`Fmax = 1000 / (10.0 − WNS)`. Positive WNS means the module fits inside
the 100 MHz cycle; negative WNS means it needs a slower clock.

**`shake` 1.07 ns gap — diagnosed and closed (2026-10-17):**

The first cut at this gap was wrong. The report originally recommended
"a small pipeline stage in `keccak_perm`'s state register". `keccak_perm`
was re-synthesised with a 2-way round pipeline (A[] → θ/ρ/π → B[] →
χ/ι, 48 cycles for 24 rounds) and `shake` re-synthesised with it:
**WNS stayed at exactly −1.074 ns.** That falsified the diagnosis.

`report_timing_summary -max_paths` on the failing design names the real
critical path:

```
Source:      blk_idx_reg[15]/C     ->   Destination: state_reg[1536]/D
Delay:       11.074 ns, 11 logic levels
             (DSP48E1=1 LUT4=1 LUT5=2 LUT6=3 MUXF7=2 MUXF8=2)
```

i.e. `blk_idx * RATE` → `in_ram` address mux → byte read → padding mux
→ 168-way byte-select into the 1600-bit state. Entirely inside the
SHAKE **byte-marshal wrapper**, with no round logic on it. The fix
splits absorb into two cycles (`S_ABS_PREP` computes and registers the
byte `bv_r`; `S_ABS_WR` XORs `bv_r` into state).

| | Before | After (absorb pipeline) |
|---|---|---|
| WNS @ 100 MHz | **−1.074 ns** | **+1.083 ns** |
| Failing setup endpoints | 1,600 / 17,972 | **0 / 22,770** |
| Critical path | 11.074 ns (11 levels) | 8.581 ns (8 levels) |
| Slice LUTs | 10,414 | 9,758 |
| Slice Registers | 11,069 | 12,638 |
| Cost | — | 2 cycles/byte absorb, 8 extra LUTs/bit of state |

Function re-verified after the change: `tb_keccak_pipeline.v` runs 6 KAT
cases (Keccak-f[1600] zero-state + bit-0 against `hashlib`-derived
vectors, SHAKE-128 and SHAKE-256 on `""` and `"abc"`) — 6/6 PASS.
`keccak_perm`'s own WNS moved +6.577 → +6.466 ns with the pipeline
register added, still 6.5 ns of headroom.

Hold note: the pipelined `shake` reports WHS −0.049 ns / 3,204
hold-failing endpoints. This is a post-synthesis-only artifact (the
report comes from `synth_design` with no place-and-route), and hold is
normally closed by `phys_opt_design`/P&R. It is not a functional issue
and does not appear in the original non-pipelined design.

**Interpretation:**

- **`keccak_perm`, `shake` and `kyber_sampler` now all meet 100 MHz.**
  Three of five sub-modules have zero failing setup endpoints. The
  Keccak/SHAKE cryptographic half of ML-KEM is timing-clean.
- **`kyber_ntt` needs ~34 MHz** — the 29.3 ns critical path is far
  beyond a 10 ns cycle. This is the unrolled 7-layer butterfly with a
  Montgomery multiply per stage. Even on a 200 MHz-class target device
  the module needs retiming or per-layer pipelining. **This single
  module is what makes the whole ML-KEM-768 design infeasible at
  realistic clock rates on a small FPGA.**
- **`kyber_poly` needs ~53 MHz** — mostly the `basemul` 3×256×16 FF
  register file adding read/write setup paths. Same fix as `kyber_ntt`
  (pipeline) or a wider clock.
- **`kyber_ntt` needs ~34 MHz** — the 29.3 ns critical path is far
  beyond a 10 ns cycle. This is the unrolled 7-layer butterfly with a
  Montgomery multiply per stage. Even on a 200 MHz-class target device
  the module needs retiming or per-layer pipelining. **This single
  module is what makes the whole ML-KEM-768 design infeasible at
  realistic clock rates on a small FPGA.**
- **`kyber_poly` needs ~53 MHz** — mostly the `basemul` 3×256×16 FF
  register file adding read/write setup paths. Same fix as `kyber_ntt`
  (pipeline) or a wider clock.

**Two Vivado 2026.1 flags that broke earlier runs** (recorded here so
the workflow is reproducible):

- `report_timing_summary -warn_on_timing` → renamed `-warn_on_violation`
- `report_timing_summary -delay_type minmax` → renamed `-delay_type min_max`

---

## 6. Storage Demand vs. Device Capacity

For ML-KEM-768 (K=3, N=256, BW=16), the 17 polynomial arrays hold:

```
A_mat      :  K*K*N = 2,304 words
K-major polys (s,e,t,r,e1,u,u_ntt,cu,s_ntt,e_ntt,r_ntt)  :  11 × 768 = 8,448 words
N-only polys (e2, v, acc, cv, m_prime, cv_poly)          :  6 × 256   = 1,536 words
                                                              ----------
                                                         ≈ 12,288 words ≈ 196,608 bits ≈ 24 KB
```

The device has 135 BRAM tiles = 135 × 36 Kb = **4,860 Kb ≈ 607 KB
of block-RAM capacity in total** (bit→byte divide by 8).
24 KB of storage is **less than 5% of available BRAM**:
`⌈24 KB / 4.5 KB per RAMB36⌉ = 6 BRAM = 4.4% of 135 tiles`.
**Storage capacity is therefore not the blocker.**

**The blocker was Problem B only** — now fixed (§4). The 2-D packed
arrays (`reg [BW-1:0] X [0:K-1][0:N-1]`) do not match the BRAM
inference template, so Vivado dissolved them into distributed
registers (101 × `Synth 8-7186` + `Synth 8-4767`, 0 BRAM in the
netlist, §3.1). **Fixing P1 required three successive stages**
(flatten → remove async resets → merge write ports), after which the
arrays infer as distributed RAM and the FF count drops 80%.

**Post-P1-c reality check (2026-10-12):** the arrays land on LUTRAM,
not BRAM.  40 × `Synth 8-6849` marks `ram_style = "block"` as
infeasible and falls back to LUTRAM.  The arrays' multi-read-port
structure (each polynomial is read in several FSM states) does not match
a RAMB36/RAMB18 tile, which supports at most 1 write + 1 read port.
Moving them to true BRAM would require either explicit BRAM
instantiation or a single-read-port restructuring — both significant
RTL rewrites.  However, **the primary blocker (FF explosion) is
resolved**: 202,589 → 39,738 FF, 31.4% of the 126,800 budget.

The remaining issue is **LUT utilisation at 92.8% of the 63,400 budget**
— legal, but well above the ~80% mark where routing usually still closes.
That pressure is dominated by combinational logic, not memory:

| Source | LUTs | Share |
|--------|------|-------|
| `kyber_ntt` | 28,565 | 48.5% |
| `shake` (×2 instances) | 14,976 | 25.4% |
| top-level FSM + glue | 7,919 | 13.5% |
| `kyber_basemul` | 5,797 | 9.9% |
| `kyber_sampler` | 1,595 | 2.7% |
| **LUTRAM (poly arrays)** | **4,448** | **7.6%** |

Even if all LUTRAMs moved to BRAM (freeing 4,448 LUTs), the design
would still be 54,404 LUTs = 85.8% of budget.  **The LUT pressure is an
NTT / SHAKE architecture question, not a memory-mapping problem.**

Real-world Kyber-on-FPGA designs do use storage time-multiplexing,
but that is because they target smaller devices where BRAM capacity
is the constraint. **On XC7A100T, 135 BRAM tiles is more than enough
for 24 KB of polynomial storage; time-multiplexing is not needed.**

**Applied 2026-10-11 → 2026-10-12** (P1-a.1 → P1-b → P1-c):
the actual edit surface was **36** access sites across 11 arrays
(`cu_poly` alone had 9), plus 3 always-block sensitivity fixes,
2 bulk-write serialisations, 1 write-port merge and 1 address
simplification pass.  All three stages are bit-exact regression clean.
The §3.1 pre-fix figures (202,589 FF / 124,888 LUT / 0 BRAM) have been
superseded by the post-P1-c re-synthesis (39,738 FF / 58,852 LUT /
4,448 LUTRAM / 0 BRAM).

**Conclusion: after P1 the design fits xc7a100t — FF 31.4%, LUT 92.8%,
DSP 25.4%, BRAM 0%.**  LUT is inside budget but above the comfort zone.
Three realistic paths forward:

| Path | Effort | Fits 100T? |
|------|--------|------------|
| **P1. Flatten + async-reset + write-port merge** | **DONE 2026-10-12.** 3 stages, 0 synthesis errors, bit-exact at every step | **FF 31.4% (39,738 / 126,800); LUT 92.8% (58,852 / 63,400); DSP 25.4%.** Arrays are LUTRAM, not BRAM — the FF explosion is gone; the LUT pressure is architectural (NTT 48%, SHAKE 25%) |
| **P2. Bigger device** (xc7a200t: 134,600 LUT / 269,200 FF / 740 DSP / 365 BRAM — xc7a325t and xc7a680t do not exist) | Board change | **Resources are trivial** (pre-opt FF 14.8%, LUT+MUXF 56.5%, §3.3) — **but not needed**, and currently **blocked**: Vivado 2026.1 hangs deterministically on this netlist/part (§3.3) |
| **P3. IP reuse** (Jung 2025 / Fan 2026 / Xiphera XIP6110B, per `p3_ip_evaluation.md`) | Vendor outreach | Yes, direct — but P1+P2 is achievable entirely in-house |
| **P4. NTT/SHAKE LUT reduction** — pipeline the NTT butterfly, share the zeta ROM, or retime | Large RTL rewrite | **Preferred route.** Freeing ~8K LUTs takes 58,852 → ~51,000 ≈ 80%, into comfortable routing-closure territory. Targets: `kyber_ntt` 28,565 LUT, `shake` ×2 14,976 LUT |

---

## 7. Key Sub-Module Findings

### `kyber_ntt` — 28,668 LUTs, 45.2% of device; Fmax 34.1 MHz
7 Cooley-Tukey layers + 7 Gentleman-Sande layers, 13 DSP48E1 for
Montgomery multiplication.  The critical path is **29.3 ns** — this
module needs ~34 MHz and requires per-butterfly pipelining for any
100 MHz+ target. `-directive AreaOptimized_high` hangs in
Vivado 2026.1 on this module; `-directive RuntimeOptimized` completes
it in ~175 s.

**Corrected LUT attribution (2026-10-17 netlist recount).**  The 28,668
LUTs are NOT dominated by the coefficient register file.  Parsing
`nttvar_V0_netlist.v` per-instance and bucketing every cell whose
connections mention `coeff_reg`:

| Cell     | Total | touching `coeff_reg` | % of that cell |
|----------|------:|---------------------:|---------------:|
| LUT6     | 22,429 | 6,366 | 28.4 |
| LUT5     |  3,773 |   323 |  8.6 |
| LUT4     |  1,108 |   271 | 24.5 |
| LUT3     |  2,647 | 1,312 | 49.6 |
| LUT2     |    483 |     0 |  0.0 |
| LUT1     |     23 |     0 |  0.0 |
| DSP48E1  |     13 |     0 |  0.0 |
| **TOTAL**| 30,476 | **8,272** | **27.1** |

So the coefficient-file address multiplexing costs **8,272 of 30,476
cells (~27%)** — meaning **~73% of the module is address generation,
arithmetic and routing that a register file cannot replace.**  The
earlier "84% register file / 9.5% datapath" reading conflated three
different quantities: the §7.1 V1b ΔLUT (1,088 — the read-MUX that
collapses when the address is frozen), the V3 ΔLUT (1,789 — the
arithmetic alone), and this instance-bucket total (8,272 — the whole
coefficient path).  They are not additive and none of them is 84%.

Note also that `coeff[]` is **not** inferred as RAM of any kind — the
module reports `Block RAM Tile 0`, `LUT as Memory 0`, and the netlist
contains no RAMB/SRL16 primitives.  The 256×16 array compiles to plain
F7/F8 MUX trees, which is exactly why the read address lands on the
critical path.

#### 7.1 Critical-path anatomy — where the 28.99 ns actually goes

`report_timing -max_paths 1` on the failing design gives a single path
of **33 logic levels, 28.992 ns**, `len_reg[0]/C → coeff_reg[129][6]/D`,
carrying **3 × DSP48E1 + 14 × CARRY4**.  Summing the printed cell
delays:

| Stage | Components | Delay |
|-------|-----------|------:|
| `len_reg` → `block_start_reg` address adder tree (33 cells, ~8 ns routed) | 3 DSP48E1 (0.513 ns each) + 14 CARRY4 (0.121 ns each) + ~17 LUTs | 15.33 ns |
| 256:1 read MUX into `coeff_reg[129]` | LUT6 ×5, MUXF7 ×2, LUT2 ×2 | 8.87 ns |
| routing between the two blocks | — | 1.42 ns |
| **Total** | | **28.99 ns** |

Two conclusions follow.

**First, this is not primarily a "coefficient file is too big" problem.**
The address/routing adder tree costs 15.33 ns; the read MUX costs
8.87 ns.  Even a perfect RAM with 2.4 ns tco would leave ~20 ns of
adder tree and routing, which still misses 100 MHz.  The real problem
is that **one cycle carries address generation, register-file access,
Montgomery multiplication, and Barrett reduction end to end.**

**Second, the fix is a 2-cycle-per-butterfly pipeline, not a bigger
device.**  Splitting into

```
cycle N   :  compute (block_start, j_cnt, len) -> coeff_addr pair -> read coeff
cycle N+1 :  fqmul + barrett_reduce on the registered pair -> write back
```

drops each stage to roughly 11–12 ns — close to, but still above, the
10 ns target, so a third register after the reduction is likely needed
to close it.  The coefficient-file rewrite to RAM is orthogonal and
only worth doing for area.

The DSP/CARRY asymmetry is the smoking gun for *why* the adder tree is
so expensive: this module has **3 DSP48E1 and 14 CARRY4** on a path that
is mostly index arithmetic, and the device has **240 DSPs of which the
whole design uses 19**.  The address multiplications are being done in
the LUT fabric with cascaded CARRY4s instead of the abundant DSP block
RAM.  Moving the three `len*2` / `block_start` products into DSPs is a
small, high-leverage edit.

**Why the register file cannot be a 1-cycle RAM.**  One butterfly reads
two addresses (`block_start+j_cnt` and `+j_cnt+len`) *and* writes both
in the same cycle — 2 reads + 2 writes, which exceeds the 1R+1W of a
dual-port BRAM.  That is the hard structural reason Vivado rejects
`ram_style="block"` on `coeff[]` (`Synth 8-7186`): the access pattern
is incompatible, not the addressability.

#### 7.2 LUT Attribution via 5-variant RTL diff (`scripts/probe_ntt_variants.py`)

The 28,485 LUTs came from a single monolithic `kyber_ntt.v` — no
attribution was possible from one synthesis. To locate the cost, five
RTL variants were synthesised side-by-side on the same device and
directive (`RuntimeOptimized`, `xc7a100tcsg324-1`, standalone
`synth_design` + `write_verilog -force -nolib` for netlist attribution):

| Tag | Variant | LUTs (util) | LUTs (net) | Δ vs V0 | Interpretation |
|-----|---------|-------------|-------------|---------|-----------------|
| V0  | baseline                       | 28,485 | 30,463 |      —  | 7-layer forward + 7-layer inverse NTT |
| V1  | `read_data = 16'd0`            |    121 |    157 | -99.5% | **INVALID** — freezing the only observable output dead-code-eliminates the whole array |
| V1b | `read_data = coeff[8'd1]`      | 27,820 | 30,485 |  -2.3% | Freezes the read address; the 256:1 read MUX folds (−1,088 netlist LUTs), net effect −665 util LUTs |
| V2  | `(* ram_style="distributed" *)` on `coeff[]` | 28,485 | 30,463 |   0.0% | Redundant: Vivado already inferred the 256×16 array as LUTRAM; the attribute changed nothing |
| V3  | butterfly / reduce / scale writes pass-through | 26,696 | 27,574 |  -9.5% | **Modular-arithmetic datapath = 1,789 LUTs + 13 DSPs** |
| V4  | `N = 256 → N = 16`             |  1,690 |  1,925 | -93.7% | Coefficient array + address decode scales with N |

The V1→V1b distinction matters: with `read_data` tied to a constant
the coeff array becomes unobservable from the module ports, so
Vivado deletes everything.  `coeff[8'd1]` keeps the array live and
measures the read-MUX cost cleanly.  In V1b the `read_data` bucket
(1,088 netlist LUTs in V0) disappears entirely, but Vivado
redistributes ~1,100 LUTs to the `p_4_out` and `state` buckets, so
the netlist total barely moves (+22).  The util report, which
reflects post-optimisation LUT sharing, shows the real saving of
−665 LUTs (−2.3%).

**Per-name bucket attribution from the V0 netlist** (38,127 primitive
names, matched by substring against the synthed net):

| Bucket | LUTs | FFs | Share of V0 LUTs |
|--------|-----:|-----:|------------------:|
| `coeff`              | 25,571 | 4,096 | 84.0%  |
| `p_1_out` (fqmul/mtg/barrett output) | 1,148 |    — | 3.8%   |
| `read_data` (256:1 read MUX)          | 1,088 |    — | 3.6%   |
| `FSM_sequential` / `state`            |   139 |   68 | 0.5%   |
| `cnt` / `j_cnt` / `block_cnt`         |   238 |  138 | 0.8%   |
| `zeta` / `zeta_cnt` (ROM + counter)   |    30 |    7 | 0.1%   |
| **Other / unattributed**              | ~2,260 | ~920 | ~7% |

**Reads**:
1. **The coefficient register file is 84% of the module.** The
   256×16 = 4,096-bit array (4,096 FFs + address decode + write MUX
   + read MUX) accounts for 25,571 of 30,463 netlist LUTs. This is
   because Vivado maps the 256-deep array to LUTRAM (distributed
   RAM, `(* ram_style="distributed" *)` is redundant — V2 proves it),
   and the multi-read/hazard-free pattern of the butterfly
   (`coeff[block_start+j_cnt]`, `coeff[block_start+j_cnt+len]`) forces
   additional fan-in/fan-out logic for the address MUX.
2. **Modular arithmetic is small**: removing fqmul / montgomery /
   barrett / modadd / modsub costs only −2,889 LUTs (−9.5%) and 13
   DSPs.  The butterflies themselves use the 13 DSPs for the
   Montgomery multiply; the LUT logic is glue (barrett reduction,
   mod-add/subtract, address select).
3. **The external read-MUX is cheap**: V1b (frozen read address)
   saves only 665 util LUTs (−2.3%).  The 256:1 `read_data` output
   MUX is 1,088 netlist LUTs, but folding it away only redistributes
   logic — the real saving is ~2.3%.
4. **The zeta ROM is negligible**: 128 × 14-bit ROM mapped to LUTs
   (`get_zeta`) is 1,792 LUTs per Vivado's own ROM inference report
   (V1b/V2/V4), but the netlist bucket shows only ~15 LUTs because
   the ROM is folded into the address-decode fabric — a discrepancy
   between Vivado's ROM report and the actual netlist.
5. **Scaling is roughly linear in N** (V4: −93.7% for N=16, ~16×
   smaller): the array cost dominates, and shrinking N is the most
   effective lever.

**Recommended next actions** (in priority order):
- **R1 (best ROI).** Pipeline the butterfly and share a single
  coefficient register across layers: replaces the 256×16 static
  array with a streaming datapath, cutting coeff LUTs ~20× while
  keeping full 7-layer NTT semantics. Estimated saving: 20–25K LUTs.
- **R2.** Explicit BRAM instantiation (`RAMB36E1` primitive) for the
  coefficient array, with a single-read / single-write port structure.
  Requires restructuring the read-during-write pattern in S_BUTTER.
  Estimated saving: 4–8K LUTs + moves 4,096 FFs off the slice fabric.
- **R3.** Freeze `read_addr` when the external consumer isn't active
  (V1b-style). Only helps if the module's read port is truly idle most
  of the time; otherwise the read MUX is needed for observability.
  Estimated saving: ~1K LUTs.
- **R4.** Accept the current cost. The 28,485 LUTs fit xc7a100t
  (45% of budget) — tight but not blocking. The real bottleneck is
  the 29.3 ns critical path; pipelining (R1) fixes both.


#### 7.3 Functional verification gate — PASSED (2026-10-18)

Before any of the R1–R4 area/timing rewrites are believed, the module must
be shown bit-exact against a golden model.  That gate is now green.

**Golden model** (`verify/gen_ntt_vectors.py`): the zeta table is parsed
out of the RTL itself and the NTT/INTT pair is validated by the
ring-homomorphism oracle — `T(a*b)` equals the pairwise basemul of `T(a)`
and `T(b)` — 9216/9216 coordinates, plus the identity
`prod_k (X^2 − 17^(2k+1)) = X^256 + 1` and the round-trip scale factor
2285 (= 2^16 mod 3329).  (A DFT oracle cannot work here: 17 has order 256
in Z_3329, so X^256+1 has no roots in Z_q and the transform is not an
evaluation map over Z_q.)

**RTL KAT** (`verify/tb_kyber_ntt.v`, generated by `verify/emit_tb_ntt.py`,
run with `iverilog -g2012` against `rtl/core/kyber_ntt.v`): **15/15 PASS** —

| Tests | Vector pair | Result |
|-------|-------------|--------|
| 0–4   | X → NTT (RAND/ZERO/POS/NEG/EXT) | 5/5 PASS |
| 5–9   | X → INTT (inverse on the raw polynomial) | 5/5 PASS |
| 10–14 | NTT → RT (round trip, invntt of ntt(x) = 2285·x) | 5/5 PASS |

**The module under test was correct all along; the bench had two bugs**
(both fixed, both instructive):

1. *Input-drive race* (symptom: test 0 passed, tests 1–9 failed,
   exactly one coefficient lost per load).  `load/load_addr/load_data`
   were driven with blocking assignments in a loop whose
   `@(posedge clk)` followed immediately; iverilog could schedule the
   bench's continuation — already setting iteration i+1's `load_addr` —
   before the DUT's always block sampled its inputs at that same posedge,
   so the DUT wrote coeff[1] when the bench meant coeff[0].  The loss only
   bit when the load was preceded by a `#1`-terminated read-back phase.
   Fix: drive every DUT input off negedge clk (5 ns setup margin, no
   scheduling-order dependency).
2. *Vector-pairing error* (symptom: all inverse tests 256/256 differ).
   The golden set defines `INTT_t = invntt(X_t)`, not
   `invntt(NTT_t)`; loading `NTT_t` and expecting `INTT_t` compares
   against the wrong vector.  Fix: emit the round-trip vectors `RT_t =
   invntt(ntt(X_t))` as well and test both X→INTT and NTT→RT.

**Rule going forward:** any BRAM/pipeline variant of `kyber_ntt` must
pass this bench before its synthesis numbers are believed.

### `kyber_poly` — highest FF count (12,360); Fmax 52.9 MHz
`kyber_basemul` holds 3 × 256 × 16-bit arrays (12,288 FFs).
The critical path is **18.9 ns**, `poly_a_reg[183][1]/C → poly_r_reg[0][13]/D`,
carrying **27 × CARRY4 and only 9 × DSP48E1**.  A modular polynomial
multiply whose carry propagation spans 27 cascaded CARRY4 chains but
uses fewer than 10 DSPs is an architecture smell: the reduction and
the Montgomery step should be DSP-bound, not carry-chain-bound.  This
module alone uses 9.7% of the device's FF budget — and `kyber_kem`
instantiates it inside an FSM that would otherwise hold the 24 KB of
polynomial storage. The FF pressure in the top module is the sum of
this module plus its ~24 KB of storage arrays.

### `shake` — 2 DSPs
SHAKE128 + SHAKE256 wrappers, 2 DSP48 for the absorb/squeeze math.

---

## 8. File Index

| File | Description |
|------|-------------|
| `kem_synth_final_report.md` | This report |
| `synth_sub_{keccak_perm,shake,kyber_sampler,kyber_ntt3,kyber_poly}_util.rpt` | Per-module utilization (resource characterization) |
| `sub_timing_{keccak_perm,shake,kyber_sampler,kyber_ntt,kyber_poly}_timing.rpt` | Per-module WNS/WHS timing reports |
| `sub_timing_{keccak_perm,shake,kyber_sampler,kyber_ntt,kyber_poly}_util.rpt` | Per-module utilization captured during the timing runs |
| `sub_timing_retry.txt` | Machine-readable summary of the retry run (kyber_ntt + kyber_poly) |
| `_final_cleanup.log` | Diagnostic-artifact cleanup log (10 temp files removed, 6 report names normalized to `.rpt`) |
| `synth_submodules_summary.txt` | Machine-readable per-module resource summary |
| `synth_sub_kyber_kem.log` | Full-top synthesis log (pre-annotation) |
| `kem_synth.log` | Full-top synthesis log (original attempt) |
| `kem_bram_synth.log` | Full-top synthesis log (with `ram_style` annotation, 101 ignored-attr warnings) |
| `kem_bram_diag.txt` | Warning-ID tally + object list for the annotation run |
| `kem_bram_recover.txt` | Netlist primitive table + BRAM=0 evidence |
| `kem_bram_synth_summary.txt` | Machine-readable summary of the annotation run |
| `rtl/core/kyber_kem.v.pre_bram` | Backup before annotation experiment (annotation now reverted) |
| `rtl/core/kyber_kem.v.pre_cntfix` | Backup before the Problem-A counter fix (93,582 B, CRLF) |
| `rtl/core/kyber_kem.v.pre_p1` | Backup before the P1 flattening (93,434 B, CRLF) |
| `rtl/core/kyber_kem.v.pre_p1b` | Backup before the P1-b async-reset fix (93,854 B, CRLF) |
| `rtl/core/kyber_kem.v.pre_p1c` | Backup before the P1-c write-port merge (95,112 B, CRLF) |
| `kem_cntfix_synth.log` | Full-top synthesis log **after** the Problem-A fix |
| `kem_cntfix_synth_summary.txt` | Warning-closure proof: 8-6090 5→0, 8-327 1→0, latches 1→0 |
| `kem_p1_synth.log` | Full-top synthesis log **after P1-c** (0 errors, 47 warnings) |
| `kem_p1c_synth.log` | Full-top synthesis log **after P1-c + keccak_perm fix** (0 errors, 47 warnings; `round.B_reg` reason → "read address stuck at constant") |
| `kem_p1_synth_util.rpt` | Post-P1-c utilisation: FF 39,738 / LUT 58,852 / LUTRAM 4,448 |
| `kem_p1_synth_summary.txt` | Machine-readable summary of the P1-c run |
| `kem_p1_synth_prims.txt` | Primitive-count probe (all zero — `get_cells` filter issue in 2026.1; use util.rpt instead) |
| `p3_ip_evaluation.md` | P3 IP / implementation survey (Jung 2025, Fan 2026, Xiphera XIP6110B) with integration sketch, adapter draft, and fallback-to-P2 analysis |
| `device_budget_probe.log` | **Authoritative device budgets** — get_property + report_utilization 'Available' for xc7a50t/xc7a100t/xc7a200t; the source of the §1 correction |
| `p2_part_probe.log` | `get_parts` proof that xc7a325t / xc7a680t do not exist; xc7a200t has 32 packages |
| `p2_part_list.txt` | All 32 xc7a200t packages with IOB counts |
| `kem_p2_synth.log` | P2 attempt 1, project mode, xc7a200t: synthesis clean, then hangs (§3.3) |
| `kem_p2b_synth.log` | P2 attempt 2, project-less, xc7a200t: identical clean synthesis, identical hang |
| `kem_p2b_synth_summary.txt` | Harvested regression guards + pre-opt cell usage (FF 39,748 / LUT+MUXF 76,045 / DSP 61) |
| `kem_p2b_run_console.txt` | Driver console output for the project-less run (rc=1, elapsed 638.6 s) |
| `kill_p2.log` / `kill_p2b.log` | The hung Vivado process trees killed after each P2 attempt |
| `nttvar_V0_alllogs.txt` … `nttvar_V4_alllogs.txt` (+ V1b) | Per-variant synthesis logs (probe_ntt_variants.py) |
| `nttvar_V{0,1,1b,2,3,4}_util.rpt` | Per-variant report_utilization (hierarchical) |
| `nttvar_V{0,1,1b,2,3,4}_netlist.v` | Per-variant write_verilog -force -nolib netlist (name-bucket attribution source) |
| `nttvar_V{0,1,1b,2,3,4}_synth.log` | Per-variant synth log excerpts |
| `nttvar_analysis.txt` | Consolidated 6-variant LUT attribution table (analyzer output) |

Scripts driving the above (`scripts/`):

| File | Description |
|------|-------------|
| `fix_cnt_loops.py` | Problem-A fix: 11 for-loops → `integer` iterators `lc`/`lb`/`ll`; dry-run by default, `--apply` to write; EOL-preserving |
| `regress_cntfix.py` | Bit-exact regression: builds `verify/tb_kyber_kem.v` against fixed + backup RTL, compares all 5 stages |
| `run_kem_synth_cntfix.py` | Full-top re-synthesis with the corrected 2026.1 flags (`-delay_type min_max`, no `-warn_on_timing`) |
| `harvest_cntfix.py` | Parses the synth log into `kem_cntfix_synth_summary.txt` when `report_utilization` cannot finish |
| `flatten_2d_arrays.py` | **P1-a.1 fix**: 36 two-D accesses → `X[a*N + b]`, 12 declarations flattened + `ram_style`; comment/string-aware bracket-depth scanner; idempotent, dry-run by default, `--diff`/`--apply`, EOL-preserving |
| `regress_p1.py` | Bit-exact regression for the P1 flattening: fixed RTL vs `kyber_kem.v.pre_p1`, compares all 5 stages |
| `fix_bram_template.py` | **P1-b fix**: 3 always blocks → `@(posedge clk)`; async-reset array clears deleted; `t_poly` phase-7 bulk write serialised to 256 cycles |
| `regress_p1b.py` | Bit-exact regression for P1-b: fixed RTL vs `kyber_kem.v.pre_p1b` |
| `fix_bram_2port.py` | **P1-c fix**: standalone `ct_load` always block deleted, writes merged into FSM `S_IDLE`; address expressions simplified to bit-selects; `keccak_perm.v` async reset → synchronous |
| `regress_p1c.py` | Bit-exact regression for P1-c: fixed RTL vs `kyber_kem.v.pre_p1c` |
| `run_kem_synth_p1.py` | Full-top re-synthesis driver for the P1 path (primitive-count probe moved before `report_utilization` to survive report hangs) |
| `probe_p2_parts.py` | `get_parts` / `get_property` probe that disproved xc7a325t and xc7a680t and captured the real xc7a200t budget |
| `list_p2_packages.py` | Enumerated all 32 xc7a200t packages with their IOB counts |
| `run_kem_synth_p2.py` | P2 project-mode synthesis driver on xc7a200tfbg484-1 |
| `run_kem_synth_p2b.py` | P2 project-less synthesis driver on xc7a200tfbg484-1 (RTL copied to an ASCII temp dir to dodge the Chinese-path mangle) |
| `probe_device_budget.py` | Trivial one-FF synthesis per part to read the utilization engine's Available column — basis of the §1 correction |
| `probe_ntt_variants.py` | **§7.1 probe**: synthesises 5 RTL variants of `kyber_ntt` (baseline, read_data=0, read_addr=const, ram_style=distributed, arith pass-through, N=16) and harvests per-variant util.rpt / netlist.v / logs; each variant lives in its own Vivado tag dir; V1 was renamed V1b in-flight to fix the DCE trap |
| `nttvar_analyze.py` | Analyzer-only rerun of the 5-variant attribution: re-parses `nttvar_V{0..4}_*` artefacts under `results/` into the §7.1 tables without spending another Vivado hour |


---

## 9. Recommendations

1. ~~**Fix the counter bug first** (Problem A).~~ **DONE 2026-10-11.**
   `Synth 8-6090` 5 → 0, `Synth 8-327` 1 → 0, inferred latches 1 → 0,
   netlist LD cells 9 → 0, bit-exact regression clean (0 errors).  See
   §4 Problem A for the approach taken — dedicated `integer` loop
   iterators rather than splitting the `always` block.

2. ~~**Do not rely on `(* ram_style = "block" *)` on the 2-D arrays.**~~
   **DONE 2026-10-12 (P1-a.1 + P1-b + P1-c applied and re-synthesised).**
   The attribute alone is ignored by the compiler (Problem B, 101
   warnings); flattening to 1-D with explicit address arithmetic is
   necessary but *not sufficient* — three successive fixes were needed:
   (a) flatten 2-D → 1-D (36 access sites), (b) remove async-reset
   sensitivity from all 3 always blocks, (c) merge dual write ports on
   `cu_poly`/`cv_poly` into the FSM.  Full-top re-synthesis: **0 errors**,
   `Synth 8-7186` 101 → 0, `Synth 8-4767` 20 → 1 (keccak_perm, fixed in
   source), FF 202,589 → **39,738** (31.4% of 126,800), LUT 124,888 →
   **58,852** (92.8% of the real 63,400 — inside budget, see the §1 correction).

3. **Post-P1 verdict: the design fits xc7a100t (FF 31.4%, LUT 92.8%).**
   The arrays infer as
   LUTRAM (distributed RAM), not BRAM — 40 × `Synth 8-6849` marks
   `ram_style = "block"` as infeasible because the multi-read-port
   structure does not match a RAMB36/RAMB18 tile.  This is acceptable:
   the FF explosion (the original blocker) is gone and LUT is inside
   budget but at 92.8%, above the ~80% where routing usually closes.
   The LUT pressure is **48% NTT + 25% SHAKE + 10% basemul** — an
   architecture question, not a memory or device-size question.
   Options, in order of effort:
   - **P4 (preferred):** reduce LUT so the design sits comfortably
     inside xc7a100t — target ≤51,000 LUT (80%) by freeing ~8K from
     the NTT zeta ROM / butterfly pipeline or the two SHAKE instances.
   - **P2 (only if P4 fails):** xc7a200t — the largest Artix-7; resources
     are trivial (pre-opt FF 14.8% / LUT+MUXF 56.5%, §3.3).  Board change
     only, no RTL work.  But it is not currently achievable: Vivado 2026.1
     hangs on this netlist/part, so a different tool release or a vendor
     fix is needed first.
   - **P3:** vendor IP (see `p3_ip_evaluation.md`).  Not needed —
     the design already fits xc7a100t on resources.

4. **`kyber_ntt` and `kyber_poly` need pipeline retiming before any
   100 MHz+ target is achievable** (§5). `kyber_ntt` critical path is
   29.3 ns; without restructuring the 7-layer butterfly the design
   can only run at ~34 MHz.

5. **For `kyber_ntt` on any device**: use `-directive RuntimeOptimized`
   to work around Vivado 2026.1's `AreaOptimized_high` hang on this
   module (independent of DSP count).

6. **`shake` 100 MHz gap — CLOSED (2026-10-17).** Item 6 below was
   originally written on a wrong hypothesis and is corrected here.
   Adding a pipeline stage to `keccak_perm` did **not** help
   (WNS unchanged at −1.074 ns), because the violating path never
   touches round logic. The real path is the SHAKE byte-marshal chain
   `blk_idx_reg → (blk_idx*RATE) → in_ram → padding mux → state`;
   splitting absorb into `S_ABS_PREP`/`S_ABS_WR` closed it at
   **WNS +1.083 ns, 0 failing endpoints** (full detail in §5).

7. **The P1 workflow is reproducible**: each stage has a dedicated
   script (`flatten_2d_arrays.py` → `fix_bram_template.py` →
   `fix_bram_2port.py`), each with an anchored single-hit edit, a
   `.pre_p1*` backup, and a bit-exact iverilog regression
   (`regress_p1*.py`).  All three regressions report `TOTAL: 0 ERRORS`
   across KeyGen 800/800, Encaps 1056/1056, Decaps 0, repeat-stability
   PASS.

---

## 10. Board-Level 100 MHz Timing Closure (B2, 2026-11-08)

### 10.1 Outcome

**ML-KEM-768 board prototype (`board_top`, Artix-7 xc7a100tcsg324-1, Nexys4
DDR, 10.000 ns real-pin clock) closes at 100 MHz.** Full implementation
(place + route + DRC + bitstream, `BOARD_CLK_DIV=1` so `clk_slow` = `clk`):

| Stage | Setup | WNS | Hold | WHS |
|---|---|---|---|---|
| placed | 0 viol. | **+0.523 ns** | 254 viol. | −0.078 ns |
| **post-route** | **0 viol.** | **+0.233 ns** | **0 viol.** | **+0.017 ns** |

- Setup: 0 failing endpoints, WNS **+0.233 ns**, TNS 0.000 ns (10.000 ns clock).
- Hold: 0 failing endpoints, WHS **+0.017 ns**, THS 0.000 ns.
- Pulse-width: 0 failing, WPWS +3.750 ns.
- Worst paths now land on the Keccak permutation (`u_perm/A_reg`, real
  functional path) — no dead-cone artifacts remain.
- Resources: Slice LUTs 32,196 (Logic 27,761 + Memory 4,435) = **50.8% of
  63,400**; Slice Registers 40,031 (31.6% of 126,800); DSPs 39; Block RAM 1;
  F7/F8 mux 7/8.
- Bitstream: `results/impl_board_top_b2nttdram4.bit` (3.8 MB).

### 10.2 The real bottleneck: a dead constant-divider cone (false path)

Standalone `kyber_kem` synthesis reported WNS **−5.121 ns** with 17 failing
endpoints; path analysis showed **15/15 violating paths all originate from
`x256_ol_reg[3]/C`** and terminate at `u_xof256/nblocks_reg[*]/D` and the
DSP `bv2__0/A[*]` (`nblocks*RATE` multiply) — i.e. **a single dead cone, not
a functional path**.

Root cause in `rtl/core/shake.v`:
```verilog
nblocks <= msg_len / RATE;            // 16-bit constant divider cone
rem     = msg_len - (nblocks * RATE); // nblocks*RATE DSP multiply
```

**Design invariant proof**: every SHAKE call site in `kyber_kem.v` has
`msg_len < RATE` (x128: 34<168; x256: 32,33<136) and `out_len < RATE`
(128<168; 32,64,128<136) ⇒ `nblocks ≡ 0` and the cone output is constant.
The tool pessimistically times a set-once constant divide at one-cycle worst
case; it never flips functionally. **False path.**

### 10.3 Fix: legal dead-code elimination (two passes)

1. Remove the `msg_len/RATE` divider + `nblocks*RATE` multiplier
   (`nblocks <= 0`, `rem = msg_len`).
2. Board run exposed the sibling `blk_idx*RATE` multiply as the new worst
   path (`abs_pos = blk_idx*RATE + byte_in_blk`). Because `msg_len < RATE`
   implies **single-block absorption** (`blk_idx ≡ 0`): simplify to
   `abs_pos = byte_in_blk`, padding always active, `S_PERM_A → S_SQ` always,
   and delete the dead `blk_idx` register entirely.

Each pass gated by the iverilog KAT regression: **TOTAL 0 ERRORS**
(KeyGen 800, Encaps 1056, Decaps 64, external ct 768 words, repeat-stable),
bit-exact.

### 10.4 Comparison (board post-route, same constraints)

| Run | RTL | post-route Setup WNS | verdict |
|---|---|---|---|
| b2nttdram3 | old (dead cone present) | **−0.121 ns** (2 viol.: `blk_idx*RATE` cone −0.121, reset −0.005) | ✗ |
| **b2nttdram4** | **new (dead cone removed)** | **+0.233 ns** (0 viol.) | ✓ |

Improvement **+0.354 ns** (from −0.121 to +0.233). Placed WNS improved
+0.377 → +0.523. **Setup and Hold both closed at 100 MHz.**

**Standalone (pure logic synthesis) confirmation** — the same dead-cone
elimination independently verified at the synth level (no place/route):

| Standalone | Setup WNS | viol. | note |
|---|---|---|---|
| old (dead cone) | **−5.121 ns** | 17 | all from `x256_ol → msg_len/RATE` |
| **new (eliminated)** | **+0.112 ns** | **0** | worst path now `byte_cnt_reg → m_prime_buf` (9.306 ns) |

Improvement **+5.233 ns**; `check_timing`: no_clock=0 / loops=0 (constraints
fully effective). (Hold −0.121 ns is the known synth-stage SRL16E artifact;
board post-route Hold is +0.017 ns, clean.)

### 10.5 Why not BRAM migration

The suspected NTT `coeff[]` BRAM migration (B2) was **not** the bottleneck —
the distributed-RAM version already removed the NTT async mux, and the true
violating path was the SHAKE dead cone, unrelated to BRAM. Decision:
**keep distributed RAM**, close timing by dead-cone elimination. (Full
analysis: `results/b2_deadcone_analysis.md`.)
