# Path A post-integration gate-level power re-measurement (b2tvla3)

## Why this exists
`results/gl_power_routed_io_annot.rpt` (0.254 W dynamic / 0.352 W total /
62% nets matched / High) was produced by `scripts/glpwr/run_routed_power.tcl`
from the **pre-integration** `b2nttdram4` `placed.dcp`.  Its On-Chip
Components show 40,031 registers and 39 DSPs.  After Path A the paper's
Table III (`tab:resource`) reports 40,296 registers and 42 DSPs (b2tvla3),
so the old power number no longer described the design the paper reports.

## What was re-run
`scripts/glpwr/run_routed_power.tcl` recipe, with only three paths changed:
  - DCP  : `C:/tmp_impl_board_b2tvla3_20261109_204816/placed.dcp`  (contains u_tvla)
  - SAIF : `C:/tmp/glpwr_1794120391/power_activity_v5.saif`       (existing board POST activity file)
  - OUT  : `C:/tmp/glpwr_b2tvla3_power`

Vivado batch, rc=0, 491 s.  Sanity prints inside the run:
  - `TVLA_CELLS: 881`  (assessment engine present in the netlist)
  - `DSP_CELLS: 42`    (= Table III)
  - `gl_routed.dcp` written (24 MB) -- supplies the routed checkpoint b2tvla3
    previously lacked.

## Results (post-integration, routed)
| Quantity | pre-integration (old) | post-integration (b2tvla3) |
|---|---|---|
| Design State | routed | routed |
| Dynamic power | 0.254 W | **0.266 W** |
| Device static | 0.098 W | 0.098 W |
| Total on-chip | 0.352 W | **0.364 W** |
| Design Nets Matched | 62% (52268/84550) | **61% (52215/85959)** |
| Overall confidence | High | **High** |
| Registers / DSPs | 40031 / 39 | **40296 / 42** |

Additional evidence from the same run:
  - `gl_power_b2tvla3_routed_baseline.rpt` : vectorless, 0.562 W dynamic.
  - `gl_power_b2tvla3_routed_timing.rpt`  : Setup WNS 0.174 ns / Hold WHS
    0.018 ns, **0 failing endpoints** -- identical to Section IV-D.
  - `gl_power_b2tvla3_routed_util.rpt`    : 32,775 LUT / 40,296 FF / 42 DSP /
    3 RAMB18 -- identical to Table III.

## Honesty notes carried into the manuscript
  - The SAIF activity file was generated from a gate-level POST simulation of
    the board self-test on the earlier (pre-integration) netlist; on the new
    routed checkpoint, nets without a matching activity record -- including
    the newly instantiated `u_tvla` logic -- retain the Vivado default
    activity rate.  The manuscript states this explicitly in Section `sec:power`.
  - The vectorless column of Table `tab:power` (0.023 W) is the early
    default-low-activity estimate used as the comparison baseline; it is not
    the `-no_propagation` worst-case baseline of the routed checkpoint.
  - Figure 3 (`fig3_power.pdf`): the routed bar is the post-integration
    sign-off value 0.266 W; the three earlier bars are intermediate estimates
    from the gate-level power flow.  Stated in Section `sec:power`.
  - No board current measurement was performed; all figures are gate-level
    estimates.

## Files updated
  - `paper_mlkem_tvla/tcas1/manuscript_tcas1.tex` (abstract, contribution 4,
    Section sec:power, Table tab:power, conclusion)
  - `paper_mlkem_tvla/make_figs.py` + `paper_mlkem_tvla/tcas1/fig/fig3_power.pdf`
