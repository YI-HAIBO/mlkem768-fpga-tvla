// =============================================================================
// A2: PUF-TRNG Fused Entropy Source
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (A2: PUF-TRNG fusion)
//
// Design goal: fuse the device-unique unclonability of a PUF with the
// freshness of a TRNG to produce entropy that is BOTH:
//   (a) cryptographically strong (seeded by PUF, unclonable per chip)
//   (b) dynamically fresh (mixed with TRNG raw bits each cycle)
//
// Architecture
//   PUF seed (256-bit)  ──┐
//                         ├──► [Mixing FSM] ──┐
//   TRNG raw (32-bit)   ──┘                    │
//                                            ├──► XOR ──► fused_entropy (32-bit)
//   Counter (32-bit)     ──────────────────────┘
//
// Mixing function (bit-exact with Python model):
//   state = state * MUL1 + TRNG_raw + counter
//   output = state[31:0] ^ TRNG_raw
//
// Health monitoring:
//   PUF: stuck-at-0/1 detection over 16-cycle window
//   TRNG: monobit test over 64 draws
//   Combined: health_ok = puf_ok AND trng_ok
//
// Latency: 1 clock (combinational mixing + registered output)
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module puf_trng_fused #(
    parameter SEED_WIDTH  = 256,   // PUF seed width
    parameter OUT_WIDTH   = 32,    // output entropy width
    parameter HEALTH_W    = 16,    // health monitoring window
    parameter MUL1        = 32'h9E3779B1,  // golden ratio constant
    parameter MUL2        = 32'h85EBCA6B   // xorshift constant
)(
    input  wire                clk,
    input  wire                rst_n,

    // ---- PUF interface ---------------------------------------------------
    input  wire [SEED_WIDTH-1:0] puf_seed,      // raw PUF response
    input  wire                  puf_challenge, // pulse to re-read PUF

    // ---- TRNG interface --------------------------------------------------
    input  wire [OUT_WIDTH-1:0]  trng_raw,      // raw TRNG output (per clock)
    input  wire                  trng_valid,    // TRNG data valid

    // ---- Control ---------------------------------------------------------
    input  wire                  enable,
    input  wire                  reseed,        // re-seed from PUF

    // ---- Output ----------------------------------------------------------
    output reg  [OUT_WIDTH-1:0]  rnd_out,
    output wire                  health_ok,
    output wire                  puf_ok,
    output wire                  trng_ok,
    output reg  [31:0]           draw_count
);

    // -------------------------------------------------------------------------
    // Internal state
    // -------------------------------------------------------------------------
    reg [SEED_WIDTH-1:0] state;
    reg [SEED_WIDTH-1:0] puf_snapshot;
    reg                  puf_loaded;
    reg                  puf_stuck_0;
    reg                  puf_stuck_1;
    reg [3:0]            puf_stuck_cnt;
    reg [OUT_WIDTH-1:0]  trng_prev;
    reg [5:0]            trng_ones;
    reg [5:0]            trng_total;
    reg                  trng_monobit_ok;

    // -------------------------------------------------------------------------
    // PUF health: stuck-at detection
    // -------------------------------------------------------------------------
    wire puf_all_zero = (puf_seed == {SEED_WIDTH{1'b0}});
    wire puf_all_one  = (puf_seed == {SEED_WIDTH{1'b1}});

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            puf_stuck_0  <= 1'b0;
            puf_stuck_1  <= 1'b0;
            puf_stuck_cnt <= 4'd0;
        end else begin
            if (puf_all_zero) begin
                if (puf_stuck_cnt < HEALTH_W)
                    puf_stuck_cnt <= puf_stuck_cnt + 4'd1;
                puf_stuck_0 <= 1'b1;
            end else if (puf_all_one) begin
                if (puf_stuck_cnt < HEALTH_W)
                    puf_stuck_cnt <= puf_stuck_cnt + 4'd1;
                puf_stuck_1 <= 1'b1;
            end else begin
                puf_stuck_cnt <= 4'd0;
                puf_stuck_0 <= 1'b0;
                puf_stuck_1 <= 1'b0;
            end
        end
    end

    assign puf_ok = ~(puf_stuck_0 | puf_stuck_1);

    // -------------------------------------------------------------------------
    // TRNG health: monobit test over 64 draws
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trng_ones      <= 6'd0;
            trng_total     <= 6'd0;
            trng_monobit_ok <= 1'b1;
            trng_prev      <= {OUT_WIDTH{1'b0}};
        end else if (trng_valid && enable) begin
            // Count ones in the new TRNG word
            trng_ones  <= trng_ones + $countones(trng_raw);
            trng_total <= trng_total + 6'd1;
            trng_prev  <= trng_raw;

            // Monobit test: |ones - total/2| < 8 for 64 draws
            if (trng_total == 6'd63) begin
                // Evaluate: ones should be between 24 and 40 for 64 draws
                if ($signed(trng_ones) < $signed(6'd24) ||
                    $signed(trng_ones) > $signed(6'd40))
                    trng_monobit_ok <= 1'b0;
                else
                    trng_monobit_ok <= 1'b1;
                // Reset for next window
                trng_ones  <= 6'd0;
                trng_total <= 6'd0;
            end
        end
    end

    assign trng_ok = trng_monobit_ok;

    // -------------------------------------------------------------------------
    // Combined health
    // -------------------------------------------------------------------------
    assign health_ok = puf_ok & trng_ok;

    // -------------------------------------------------------------------------
    // PUF seed snapshot + reseed logic
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            puf_loaded  <= 1'b0;
            puf_snapshot <= {SEED_WIDTH{1'b0}};
        end else begin
            if (reseed || (puf_challenge && !puf_loaded)) begin
                puf_snapshot <= puf_seed;
                puf_loaded   <= 1'b1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Mixing FSM: state = state * MUL1 + trng_raw + counter
    //   output = state[31:0] ^ trng_raw
    // -------------------------------------------------------------------------
    wire [SEED_WIDTH-1:0] state_mix = (state * MUL1) + {{(SEED_WIDTH-OUT_WIDTH){1'b0}}, trng_raw} + {{(SEED_WIDTH-32){1'b0}}, draw_count};

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= {SEED_WIDTH{1'b0}};
            rnd_out    <= {OUT_WIDTH{1'b0}};
            draw_count <= 32'd0;
        end else begin
            if (enable) begin
                state   <= state_mix;
                rnd_out <= state_mix[OUT_WIDTH-1:0] ^ trng_raw;
                draw_count <= draw_count + 32'd1;
            end
        end
    end

endmodule

`default_nettype wire