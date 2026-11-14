// =============================================================================
// Ring-Oscillator True Random Number Generator (RO-TRNG)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec
// Replaces : lfsr_trng (LFSR-based portable stand-in)
//
// Function
//   6 ring oscillators with coprime stage counts (3,5,7,11,15,31) sample
//   phase jitter at the system clock edge. The XOR of all six synchronized
//   RO outputs delivers one entropy bit per clock. Bits are accumulated in
//   an 8-bit shift register and emitted as a byte every 8 clocks.
//
//   A 2-stage multiply-xorshift whitener (same constants as lfsr_trng:
//   MUL1 = 0x9E3779B1, MUL2 = 0x85EBCA6B) removes bias before the byte is
//   presented to the consumer.
//
// Pipeline (latency = ACC_W + 2 clocks per word)
//   Stage 0: collect ACC_W entropy bits in shift_reg
//   Stage 1: raw = shift_reg ^ counter, then wh1 = raw * MUL1  (registered)
//   Stage 2: wh2 = wh1 ^ (wh1>>15); wh3 = wh2 * MUL2; wh4 = wh3 ^ (wh3>>13)
//
// Health monitoring
//   Each RO output is checked for stuck-at-0 / stuck-at-1 over a 16-clock
//   window. A stuck RO means the entropy bit is not random and the module
//   asserts health_ok = 0.
//
// Simulation note
//   In zero-delay simulation the ROs do not oscillate. A #1 inertial delay
//   per inverter makes them run at ~500/N MHz so the module is testable.
//   In synthesis the #1 is ignored and the RO runs at the fabric LUT delay.
//   Set parameter SIM_RO_DELAY to 0 to model ideal hardware (no sim delay).
//
// Production note
//   This is still a stand-in. A certified design replaces the RO array with
//   a vendor TRNG IP (e.g. Xilinx 7-series TRNG) and passes NIST SP 800-90B.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module ro_entropy_source #(
    parameter [31:0] SEED        = 32'h1,
    parameter [7:0]  NUM_RO      = 6,
    parameter [7:0]  RO_STAGES_0 = 3,
    parameter [7:0]  RO_STAGES_1 = 5,
    parameter [7:0]  RO_STAGES_2 = 7,
    parameter [7:0]  RO_STAGES_3 = 11,
    parameter [7:0]  RO_STAGES_4 = 15,
    parameter [7:0]  RO_STAGES_5 = 31,
    parameter [7:0]  SAMPLE_ACCUM = 8,
    parameter [7:0]  HEALTH_WINDOW = 16,
    parameter         SIM_RO_DELAY = 1
)(
    input  wire         clk,
    input  wire         rst_n,

    input  wire         reseed,
    input  wire [127:0] entropy,

    input  wire         enable,

    output reg  [31:0]  rnd_out,
    output wire         health_ok,
    output wire [31:0]  draw_count
);

    localparam [31:0] MUL1 = 32'h9E3779B1;
    localparam [31:0] MUL2 = 32'h85EBCA6B;
    localparam ACC_W = SAMPLE_ACCUM;

    // -------------------------------------------------------------------------
    // Ring oscillators (6 ROs with coprime odd stage counts)
    // -------------------------------------------------------------------------
    wire [NUM_RO-1:0] ro_out;

    // RO 0: 3 stages
    wire [RO_STAGES_0-1:0] ro0_chain;
    generate
        if (SIM_RO_DELAY) begin : ro0_sim
            assign #1 ro0_chain[0] = ~ro0_chain[RO_STAGES_0-1];
        end else begin : ro0_ideal
            assign    ro0_chain[0] = ~ro0_chain[RO_STAGES_0-1];
        end
        genvar k0;
        for (k0 = 1; k0 < RO_STAGES_0; k0 = k0 + 1) begin : ro0_stage
            if (SIM_RO_DELAY)
                assign #1 ro0_chain[k0] = ~ro0_chain[k0-1];
            else
                assign    ro0_chain[k0] = ~ro0_chain[k0-1];
        end
    endgenerate
    assign ro_out[0] = ro0_chain[RO_STAGES_0-1];

    // RO 1: 5 stages
    wire [RO_STAGES_1-1:0] ro1_chain;
    generate
        if (SIM_RO_DELAY) begin : ro1_sim
            assign #1 ro1_chain[0] = ~ro1_chain[RO_STAGES_1-1];
        end else begin : ro1_ideal
            assign    ro1_chain[0] = ~ro1_chain[RO_STAGES_1-1];
        end
        genvar k1;
        for (k1 = 1; k1 < RO_STAGES_1; k1 = k1 + 1) begin : ro1_stage
            if (SIM_RO_DELAY)
                assign #1 ro1_chain[k1] = ~ro1_chain[k1-1];
            else
                assign    ro1_chain[k1] = ~ro1_chain[k1-1];
        end
    endgenerate
    assign ro_out[1] = ro1_chain[RO_STAGES_1-1];

    // RO 2: 7 stages
    wire [RO_STAGES_2-1:0] ro2_chain;
    generate
        if (SIM_RO_DELAY) begin : ro2_sim
            assign #1 ro2_chain[0] = ~ro2_chain[RO_STAGES_2-1];
        end else begin : ro2_ideal
            assign    ro2_chain[0] = ~ro2_chain[RO_STAGES_2-1];
        end
        genvar k2;
        for (k2 = 1; k2 < RO_STAGES_2; k2 = k2 + 1) begin : ro2_stage
            if (SIM_RO_DELAY)
                assign #1 ro2_chain[k2] = ~ro2_chain[k2-1];
            else
                assign    ro2_chain[k2] = ~ro2_chain[k2-1];
        end
    endgenerate
    assign ro_out[2] = ro2_chain[RO_STAGES_2-1];

    // RO 3: 11 stages
    wire [RO_STAGES_3-1:0] ro3_chain;
    generate
        if (SIM_RO_DELAY) begin : ro3_sim
            assign #1 ro3_chain[0] = ~ro3_chain[RO_STAGES_3-1];
        end else begin : ro3_ideal
            assign    ro3_chain[0] = ~ro3_chain[RO_STAGES_3-1];
        end
        genvar k3;
        for (k3 = 1; k3 < RO_STAGES_3; k3 = k3 + 1) begin : ro3_stage
            if (SIM_RO_DELAY)
                assign #1 ro3_chain[k3] = ~ro3_chain[k3-1];
            else
                assign    ro3_chain[k3] = ~ro3_chain[k3-1];
        end
    endgenerate
    assign ro_out[3] = ro3_chain[RO_STAGES_3-1];

    // RO 4: 15 stages
    wire [RO_STAGES_4-1:0] ro4_chain;
    generate
        if (SIM_RO_DELAY) begin : ro4_sim
            assign #1 ro4_chain[0] = ~ro4_chain[RO_STAGES_4-1];
        end else begin : ro4_ideal
            assign    ro4_chain[0] = ~ro4_chain[RO_STAGES_4-1];
        end
        genvar k4;
        for (k4 = 1; k4 < RO_STAGES_4; k4 = k4 + 1) begin : ro4_stage
            if (SIM_RO_DELAY)
                assign #1 ro4_chain[k4] = ~ro4_chain[k4-1];
            else
                assign    ro4_chain[k4] = ~ro4_chain[k4-1];
        end
    endgenerate
    assign ro_out[4] = ro4_chain[RO_STAGES_4-1];

    // RO 5: 31 stages
    wire [RO_STAGES_5-1:0] ro5_chain;
    generate
        if (SIM_RO_DELAY) begin : ro5_sim
            assign #1 ro5_chain[0] = ~ro5_chain[RO_STAGES_5-1];
        end else begin : ro5_ideal
            assign    ro5_chain[0] = ~ro5_chain[RO_STAGES_5-1];
        end
        genvar k5;
        for (k5 = 1; k5 < RO_STAGES_5; k5 = k5 + 1) begin : ro5_stage
            if (SIM_RO_DELAY)
                assign #1 ro5_chain[k5] = ~ro5_chain[k5-1];
            else
                assign    ro5_chain[k5] = ~ro5_chain[k5-1];
        end
    endgenerate
    assign ro_out[5] = ro5_chain[RO_STAGES_5-1];

    // -------------------------------------------------------------------------
    // 2-FF synchronizer per RO
    // -------------------------------------------------------------------------
    reg [NUM_RO-1:0] sync1, sync2;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync1 <= {NUM_RO{1'b0}};
            sync2 <= {NUM_RO{1'b0}};
        end else begin
            sync1 <= ro_out;
            sync2 <= sync1;
        end
    end
    wire [NUM_RO-1:0] ro_sync = sync2;

    // -------------------------------------------------------------------------
    // Entropy bit: XOR of all synchronized RO outputs
    // -------------------------------------------------------------------------
    wire entropy_bit = ^ro_sync;

    // -------------------------------------------------------------------------
    // Health monitoring: each RO must toggle within HEALTH_WINDOW clocks
    // -------------------------------------------------------------------------
    reg  [NUM_RO-1:0]              ro_prev;
    wire [NUM_RO-1:0]              ro_stuck;
    reg  [HEALTH_WINDOW-1:0]       ro_hist [0:NUM_RO-1];

    genvar h;
    generate
        for (h = 0; h < NUM_RO; h = h + 1) begin : health
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    ro_hist[h] <= {HEALTH_WINDOW{1'b0}};
                end else begin
                    ro_hist[h] <= {ro_hist[h][HEALTH_WINDOW-2:0],
                                   (ro_sync[h] !== ro_prev[h])};
                end
            end
            assign ro_stuck[h] = (ro_hist[h] == {HEALTH_WINDOW{1'b0}});
        end
    endgenerate

    assign health_ok = !(|ro_stuck);

    // -------------------------------------------------------------------------
    // Entropy collection: shift register
    // -------------------------------------------------------------------------
    reg [ACC_W-1:0] shift_reg;
    reg [3:0]       bit_count;
    reg             word_ready;      // set when shift_reg is full

    // -------------------------------------------------------------------------
    // Whitener pipeline (2 stages)
    // -------------------------------------------------------------------------
    // Stage 1: wh1 = raw * MUL1
    reg [31:0] wh1_r;
    // Stage 2: wh4 = ((wh1 ^ (wh1>>15)) * MUL2) ^ ((... ) >> 13)
    wire [31:0] wh2 = wh1_r ^ (wh1_r >> 15);
    wire [31:0] wh3 = wh2 * MUL2;
    wire [31:0] wh4 = wh3 ^ (wh3 >> 13);

    // The raw 32-bit value to whiten: entropy word XORed with draw counter
    wire [31:0] raw_word = {{(32-ACC_W){1'b0}}, shift_reg} ^ counter;

    // -------------------------------------------------------------------------
    // Draw control
    // -------------------------------------------------------------------------
    reg [31:0] counter;
    reg [127:0] ent_r;

    wire [31:0] next_count = reseed ? 32'd0
                                       : (enable ? counter + 32'd1 : counter);
    wire [127:0] next_ent   = reseed ? entropy : ent_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg  <= {ACC_W{1'b0}};
            bit_count  <= 4'd0;
            word_ready <= 1'b0;
            counter    <= 32'd0;
            rnd_out    <= 32'd0;
            wh1_r      <= 32'd0;
            ent_r      <= 128'd0;
            ro_prev    <= {NUM_RO{1'b0}};
        end else begin
            ent_r   <= next_ent;
            ro_prev <= ro_sync;

            if (reseed) begin
                shift_reg  <= {ACC_W{1'b0}};
                bit_count  <= 4'd0;
                word_ready <= 1'b0;
                counter    <= 32'd0;
                rnd_out    <= 32'd0;
                wh1_r      <= 32'd0;
            end else if (enable) begin
                // Shift in the new entropy bit
                shift_reg <= {shift_reg[ACC_W-2:0], entropy_bit};

                if (bit_count == ACC_W - 1) begin
                    // This clock: shift_reg becomes full (ACC_W bits).
                    // The raw word for THIS draw uses the PREVIOUS shift_reg
                    // (before this clock's shift) XORed with the current counter.
                    // wh1_r is registered one clock later, then wh4 follows.
                    bit_count <= 4'd0;
                    counter   <= counter + 32'd1;
                    word_ready <= 1'b1;
                    // wh1_r will capture raw_word on the NEXT clock edge
                end else begin
                    bit_count <= bit_count + 4'd1;
                    word_ready <= 1'b0;
                end

                // Stage 1 of whitener: register raw_word * MUL1
                // raw_word uses the shift_reg BEFORE this clock's shift
                // (i.e. the entropy word that was just completed).
                wh1_r <= raw_word * MUL1;
            end else begin
                word_ready <= 1'b0;
            end

            // Output the whitened result when stage 2 is ready
            if (word_ready) begin
                rnd_out <= wh4;
            end
        end
    end

    assign draw_count = counter;

endmodule

`default_nettype wire