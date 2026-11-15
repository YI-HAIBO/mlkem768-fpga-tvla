// =============================================================================
// B3 extension (#6a): TVLA probe router - time-division multiplexing of
// multiple on-die leakage probe points through a single tvla_online engine.
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (B3: online leakage detection, coverage extension)
//
// The single-probe tvla_online engine samples one internal datapath. To cover
// MORE datapaths (NTT basemul output, coefficient RAM read data, adder output,
// ...) without duplicating the whole Welch accumulator per probe, this router
// time-multiplexes NTAP probe points through ONE downstream tvla_online:
//   - tap_id selects which probe is routed to the engine (HW(probe) sample)
//   - the external control (KEM sequencer / test controller) streams the
//     fixed-key and random-key runs for the selected probe, then pulses
//     tap_advance once the 2n samples for that tap are complete
//   - on tap_advance the router latches the engine's verdict into
//     leak_result[tap_id], advances tap_id (wrapping -> report_cycle pulse),
//     and pulses batch_restart so the engine starts the next tap clean
//
// This keeps the resource overhead to O(NTAP) result bits + O(log NTAP) tap
// counter instead of O(NTAP) full Welch accumulators.
//
// Probe value model: the probe is a raw data word (PROBE_W bits); its leakage
// proxy is the Hamming weight, computed here (combinational popcount). HW_W
// must hold ceil(log2(PROBE_W+1)) values; SAMPLE_W feeds the downstream engine.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module tvla_probe_router #(
    parameter NTAP     = 4,
    parameter TAPID_W  = 2,          // ceil(log2(NTAP))
    parameter PROBE_W  = 32,         // raw probe data width
    parameter HW_W     = 6,          // hamming-weight output width (>= log2(PROBE_W+1))
    parameter SAMPLE_W = 6           // must match downstream tvla_online.SAMPLE_W
)(
    input  wire clk,
    input  wire rst_n,

    // flattened probes: probe_flat[tap*PROBE_W +: PROBE_W] is tap #tap
    input  wire [NTAP*PROBE_W-1:0] probe_flat,
    input  wire        probe_valid,  // streamed with the currently-selected tap
    input  wire        probe_fixed,  // 1 -> fixed-key group, 0 -> random group

    // external control: pulse once the current tap's 2n samples are complete
    input  wire        tap_advance,

    // to downstream tvla_online
    output reg  [SAMPLE_W-1:0] sample,
    output reg         sample_valid,
    output reg         sample_fixed,
    output reg         batch_restart,
    input  wire        batch_done,      // from tvla_online
    input  wire        leak_detected,   // from tvla_online
    input  wire        degenerate,      // from tvla_online

    // router status
    output reg  [TAPID_W-1:0] tap_id,
    output reg  [NTAP-1:0] leak_result,    // per-tap latched leak verdict
    output reg  [NTAP-1:0] degen_result,   // per-tap latched degenerate verdict
    output reg         report_cycle        // one-cycle pulse: full NTAP round done
);

    // ---- combinational popcount (no $countones dependency) ------------------
    function [HW_W-1:0] popcount;
        input [PROBE_W-1:0] v;
        integer i;
        reg [HW_W-1:0] c;
        begin
            c = {HW_W{1'b0}};
            for (i = 0; i < PROBE_W; i = i + 1)
                c = c + v[i];
            popcount = c;
        end
    endfunction

    // selected probe slice (variable base index, Verilog-2001)
    wire [PROBE_W-1:0] sel = probe_flat[tap_id*PROBE_W +: PROBE_W];

    always @(*) begin
        sample       = popcount(sel);
        sample_valid = probe_valid;
        sample_fixed = probe_fixed;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tap_id       <= {TAPID_W{1'b0}};
            leak_result  <= {NTAP{1'b0}};
            degen_result <= {NTAP{1'b0}};
            batch_restart <= 1'b0;
            report_cycle  <= 1'b0;
        end else begin
            batch_restart <= 1'b0;
            report_cycle  <= 1'b0;
            if (tap_advance) begin
                // latch the verdict for the tap that just finished
                leak_result[tap_id]  <= leak_detected;
                degen_result[tap_id] <= degenerate;
                // clean start for the next tap's batch
                batch_restart <= 1'b1;
                if (tap_id == NTAP-1) begin
                    tap_id       <= {TAPID_W{1'b0}};
                    report_cycle <= 1'b1;    // full round complete
                end else begin
                    tap_id <= tap_id + 1'b1;
                end
            end
        end
    end

endmodule

`default_nettype wire
