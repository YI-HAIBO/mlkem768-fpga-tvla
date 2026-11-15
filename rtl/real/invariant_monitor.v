// =============================================================================
// #8c deployment: continuous invariant monitor for a secret register
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (B3: online leakage detection, deployment item 8c)
//
// The seed-register detection demonstrated earlier (verify/attack_sr_vs_traces.py)
// was a conceptual, data-flow-level check.  This module turns it into a REAL,
// synthesizable, continuously-running invariant monitor: it asserts that a
// monitored register (e.g. a seed / secret-key register) only changes when the
// enclosing datapath legitimately updates it (`update`), and stays bit-constant
// otherwise.  Any spurious change while the monitor is enabled and not in an
// update phase raises a sticky `violation` -- a hardware witness of tampering
// or a datapath bug in the secret state.
//
// Protocol:
//   enable == 0 : monitor idle -- it tracks `value` into `ref` (no judgement),
//                 so the monitor can be armed across an arbitrary load phase.
//   enable == 1 && update == 0 : INVARIANT CHECK -- if value != ref, latch
//                 violation = 1 (sticky).  Otherwise ref is held.
//   enable == 1 && update == 1 : LEGAL UPDATE -- ref <= value (new baseline),
//                 no judgement (the datapath is allowed to write the secret).
//
// Usage against kyber_kem: arm after the seed buffer has been streamed in
// (enable = KEM busy, update = the in_load&is_seed strokes), monitor each
// seed_buf[i] byte.  During KeyGen/Encaps/Decaps the seed buffer is read-only,
// so the invariant holds (violation stays 0); a forced/illegal write is caught.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module invariant_monitor #(
    parameter W = 8           // monitored register width
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,     // 1 = monitor armed / judging
    input  wire        update,     // 1 = legal update phase (accept new baseline)
    input  wire [W-1:0] value,     // monitored signal
    output reg         violation   // sticky invariant-violation flag
);

    reg [W-1:0] ref_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ref_reg    <= {W{1'b0}};
            violation <= 1'b0;
        end else begin
            if (!enable) begin
                // idle: track the current value, no judgement
                ref_reg <= value;
            end else if (update) begin
                // legal write: adopt the new baseline
                ref_reg <= value;
            end else begin
                // invariant check: the secret must not change on its own
                if (value !== ref_reg) violation <= 1'b1;
            end
        end
    end

endmodule

`default_nettype wire
