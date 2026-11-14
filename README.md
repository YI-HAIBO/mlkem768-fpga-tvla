# ML-KEM-768 FPGA Coprocessor with On-Chip Leakage Self-Assessment

Verilog RTL, testbenches, golden reference models, simulation data, and
power-analysis reports supporting the paper:

> "An ML-KEM-768 FPGA Coprocessor with an On-Chip Integer Welch $t$-Test
> Leakage Self-Assessment Engine" (ACM Transactions on Embedded Computing
> Systems).

The coprocessor targets a Xilinx Artix-7 (xc7a100tcsg324-1, Nexys4 DDR)
device and shares one pipelined number-theoretic transform across ML-KEM-768
key generation, encapsulation, and decapsulation. The long key-dependent
buses are protected by a data-independent precharge hiding countermeasure,
and a pure-integer on-chip Welch $t$-test engine continuously certifies the
constant-weight invariant of that countermeasure.

## What is published here

Only **code and data** are published, per the paper's Data Availability
statement. The repository contains:

- `rtl/`        — Verilog RTL (core KEM/SIGN/NTT datapaths in `rtl/core`,
                  security-IP blocks in `rtl/real`, and the three top-level
                  wrapper files `ipx_aoi_sec_board_top.v`,
                  `ipx_aoi_sec_fpga_top.v`, `ipx_aoi_sec_nexys_top.v`).
- `sim/`        — Icarus Verilog testbenches and the gate-level simulation
                  data, including `tb_puf_trng_nist_long.v` (10 Mbit NIST
                  data collection) and `nist_data_10mbit.bin`.
- `verify/`     — golden reference models (Python), known-answer vectors,
                  the NIST test suite, and on-chip TVLA / CPA analyses
                  (`run_nist_tests.py`, `golden_nist_10mbit.log`,
                  `analyze_tvla_b.py`).
- `scripts/`    — Vivado synthesis / implementation / power Tcl and Python
                  drivers (`scripts/glpwr/` runs the gate-level SAIF power
                  flow).
- `constrains/` — XDC timing and board constraints.
- `results/`    — synthesis / implementation / power reports and the JSON /
                  markdown data files that back the numbers in the paper
                  (`cpa_protect.json`, `tvla_b_analysis.json`,
                  `dip_precharge_verify.json`, `puf_quality_big.json`,
                  `trng_10mbit_conditioned_nist.json`,
                  `gl_power_b2tvla3_routed_*.rpt`, and the 10 Mbit NIST log).

Compiled gate-level netlists (`.dcp`, `.bit`) and large simulation binaries
are intentionally **not** included; they are regenerable from the RTL with
Vivado and Icarus Verilog using the scripts in `scripts/`.

## Quick start

```bash
# syntax / parse check the RTL with Icarus Verilog
iverilog -g2012 -t null -D LINT rtl/core/kyber_kem.v

# compile and run a testbench
iverilog -g2012 -o build/tb tb_puf_trng_nist_long.v rtl/real/puf_trng_fused.v
vvp build/tb

# re-run the NIST suite on the 10 Mbit conditioned output
python verify/run_nist_tests.py sim/nist_data_10mbit.bin

# gate-level power (requires Vivado)
python scripts/glpwr/run_gl_sim.py
```

## Data availability

All simulation and power-analysis data that support the findings of the
paper are in `results/` and `sim/`. No proprietary data or credentials are
included in this repository.
