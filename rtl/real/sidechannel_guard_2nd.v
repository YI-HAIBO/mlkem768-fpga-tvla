// =============================================================================
// Second-Order Side-Channel Protection Guard
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec
// Upgrade  : sidechannel_guard (1st-order, 2 shares, LFSR TRNG)
//             → sidechannel_guard_2nd (2nd-order, 3 shares, RO TRNG)
//
// Architecture
//   1. ro_entropy_source  — 6 ring oscillators + 2-stage whitener
//   2. Mask collector     — collects 7 fresh 32-bit masks per operation
//   3. Control FSM        — IDLE → COLLECT → INIT → STEP → JITTER → DONE
//   4. masked_accumulate_2nd — ISW 3-share AND-accumulate
//   5. jitter_ctrl        — random delay insertion (unchanged)
//
// Mask schedule per operation (7 fresh 32-bit words):
//   m0 = init_mask0  — first mask for the initial share split of operand_a
//   m1 = init_mask1  — second mask for the initial share split
//   m2 = r01         — ISW cross-term mask for pair (0,1)
//   m3 = r02         — ISW cross-term mask for pair (0,2)
//   m4 = r12         — ISW cross-term mask for pair (1,2)
//   m5 = remask0     — fresh mask for re-splitting the AND result
//   m6 = remask1     — second fresh mask for re-splitting the AND result
//
// Operand handling:
//   operand_a_plain is the secret. It is split into 3 shares on `start`:
//     a0 = m0, a1 = m1, a2 = operand_a_plain ^ m0 ^ m1
//   operand_b is provided by the caller as 2 shares (b0, b1). The third
//   share b2 is set to 0, so b0 ^ b1 ^ b2 = b0 ^ b1 = plaintext_b.
//   This gives 2nd-order protection for operand_a and 1st-order for operand_b.
//
// The plaintext NEVER appears on an output port. A consumer that needs the
// value XORs the three shares itself — that recombination is the single point
// an attacker aims at, which is exactly what the share split spreads out.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module sidechannel_guard_2nd #(
    parameter [31:0] W              = 32,
    parameter [3:0]  MAX_DELAY      = 16,
    parameter [3:0]  SAMPLE_ACCUM   = 8,
    parameter [31:0] TRNG_SEED      = 32'h1,
    parameter [3:0]  NUM_MASKS      = 7
)(
    input  wire         clk,
    input  wire         rst_n,

    input  wire         reseed,
    input  wire [127:0] entropy,

    input  wire         start,
    input  wire [W-1:0] operand_a_plain,
    input  wire [W-1:0] operand_b0,
    input  wire [W-1:0] operand_b1,
    input  wire [15:0]   op_id,

    output wire [W-1:0] result0,
    output wire [W-1:0] result1,
    output wire [W-1:0] result2,
    output wire          result_valid,
    output wire [W-1:0] mask_o,
    output wire [15:0]   delay_o,
    output wire          trng_health
);

    // -------------------------------------------------------------------------
    // RO TRNG
    // -------------------------------------------------------------------------
    wire [31:0] rnd_word;
    wire [31:0] draw_count;
    wire        trng_health_int;

    ro_entropy_source #(
        .SEED        (TRNG_SEED),
        .SAMPLE_ACCUM(SAMPLE_ACCUM)
    ) u_trng (
        .clk        (clk),
        .rst_n      (rst_n),
        .reseed     (reseed),
        .entropy    (entropy),
        .enable     (1'b1),
        .rnd_out    (rnd_word),
        .health_ok  (trng_health_int),
        .draw_count (draw_count)
    );

    assign trng_health = trng_health_int;
    assign mask_o      = rnd_word;

    // -------------------------------------------------------------------------
    // New-word detection: compare current rnd_word with previous
    // -------------------------------------------------------------------------
    reg [31:0] rnd_prev;
    wire new_word = (rnd_word !== rnd_prev) && trng_health_int;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rnd_prev <= 32'd0;
        else
            rnd_prev <= rnd_word;
    end

    // -------------------------------------------------------------------------
    // Mask registers (7 × 32-bit)
    // -------------------------------------------------------------------------
    reg [W-1:0] m0, m1, m2, m3, m4, m5, m6;
    reg [3:0]   mask_cnt;           // how many masks collected (0..6)

    // -------------------------------------------------------------------------
    // Masked accumulator
    // -------------------------------------------------------------------------
    reg        acc_init;
    reg        acc_step;
    reg [W-1:0] acc_init_value;
    reg [W-1:0] acc_init_m0;
    reg [W-1:0] acc_init_m1;
    reg [W-1:0] acc_b0;
    reg [W-1:0] acc_b1;
    reg [W-1:0] acc_b2;
    reg [W-1:0] acc_r01;
    reg [W-1:0] acc_r02;
    reg [W-1:0] acc_r12;
    reg [W-1:0] acc_rm0;
    reg [W-1:0] acc_rm1;

    wire [W-1:0] acc0, acc1, acc2;

    masked_accumulate_2nd #(.W(W)) u_acc (
        .clk          (clk),
        .rst_n        (rst_n),
        .init         (acc_init),
        .init_value   (acc_init_value),
        .init_mask0   (acc_init_m0),
        .init_mask1   (acc_init_m1),
        .step         (acc_step),
        .b0           (acc_b0),
        .b1           (acc_b1),
        .b2           (acc_b2),
        .r01          (acc_r01),
        .r02          (acc_r02),
        .r12          (acc_r12),
        .remask0      (acc_rm0),
        .remask1      (acc_rm1),
        .acc0         (acc0),
        .acc1         (acc1),
        .acc2         (acc2)
    );

    assign result0 = acc0;
    assign result1 = acc1;
    assign result2 = acc2;

    // -------------------------------------------------------------------------
    // Jitter controller
    // -------------------------------------------------------------------------
    wire jitter_done;
    reg  run;
    reg  [15:0] op_id_r;

    jitter_ctrl #(.MAX_DELAY(MAX_DELAY)) u_jitter (
        .clk          (clk),
        .rst_n        (rst_n),
        .in_valid     (run),
        .rnd          (rnd_word[7:0]),
        .op_id        (op_id_r),
        .out_valid    (jitter_done),
        .delay_cycles (delay_o)
    );

    assign result_valid = jitter_done;

    // -------------------------------------------------------------------------
    // Control FSM
    // -------------------------------------------------------------------------
    localparam [2:0] S_IDLE     = 3'd0,
                     S_COLLECT  = 3'd1,
                     S_INIT     = 3'd2,
                     S_STEP     = 3'd3,
                     S_JITTER   = 3'd4,
                     S_DONE     = 3'd5;

    reg [2:0] state;
    reg       start_r;              // latched start

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            start_r    <= 1'b0;
            run        <= 1'b0;
            op_id_r    <= 16'd0;
            acc_init   <= 1'b0;
            acc_step   <= 1'b0;
            mask_cnt   <= 4'd0;
            m0 <= {W{1'b0}};
            m1 <= {W{1'b0}};
            m2 <= {W{1'b0}};
            m3 <= {W{1'b0}};
            m4 <= {W{1'b0}};
            m5 <= {W{1'b0}};
            m6 <= {W{1'b0}};
            acc_init_value <= {W{1'b0}};
            acc_init_m0    <= {W{1'b0}};
            acc_init_m1    <= {W{1'b0}};
            acc_b0 <= {W{1'b0}};
            acc_b1 <= {W{1'b0}};
            acc_b2 <= {W{1'b0}};
            acc_r01 <= {W{1'b0}};
            acc_r02 <= {W{1'b0}};
            acc_r12 <= {W{1'b0}};
            acc_rm0 <= {W{1'b0}};
            acc_rm1 <= {W{1'b0}};
        end else begin
            // One-shot defaults
            acc_init <= 1'b0;
            acc_step <= 1'b0;

            case (state)
                // -------------------------------------------------------------
                S_IDLE: begin
                    if (start && trng_health_int) begin
                        start_r <= 1'b1;
                        op_id_r <= op_id;
                        mask_cnt <= 4'd0;
                        state   <= S_COLLECT;
                    end
                end

                // -------------------------------------------------------------
                S_COLLECT: begin
                    // Collect NUM_MASKS fresh words from the TRNG.
                    // Each new_word pulse means rnd_word has changed to a
                    // freshly whitened value.
                    if (new_word) begin
                        case (mask_cnt)
                            4'd0: m0 <= rnd_word;
                            4'd1: m1 <= rnd_word;
                            4'd2: m2 <= rnd_word;
                            4'd3: m3 <= rnd_word;
                            4'd4: m4 <= rnd_word;
                            4'd5: m5 <= rnd_word;
                            4'd6: m6 <= rnd_word;
                            default: begin
                                // All masks collected
                                state <= S_INIT;
                            end
                        endcase
                        mask_cnt <= mask_cnt + 4'd1;
                    end
                end

                // -------------------------------------------------------------
                S_INIT: begin
                    // Split operand_a_plain into 3 shares using m0, m1:
                    //   a0 = m0, a1 = m1, a2 = plaintext ^ m0 ^ m1
                    acc_init_value <= operand_a_plain;
                    acc_init_m0    <= m0;
                    acc_init_m1    <= m1;
                    // operand_b shares: caller provides b0, b1; b2 = 0
                    acc_b0 <= operand_b0;
                    acc_b1 <= operand_b1;
                    acc_b2 <= {W{1'b0}};
                    acc_init <= 1'b1;
                    state   <= S_STEP;
                end

                // -------------------------------------------------------------
                S_STEP: begin
                    // ISW AND-accumulate: acc = acc & b
                    acc_r01 <= m2;
                    acc_r02 <= m3;
                    acc_r12 <= m4;
                    acc_rm0 <= m5;
                    acc_rm1 <= m6;
                    acc_step <= 1'b1;
                    run      <= 1'b1;
                    state    <= S_JITTER;
                end

                // -------------------------------------------------------------
                S_JITTER: begin
                    if (jitter_done) begin
                        run   <= 1'b0;
                        state <= S_DONE;
                    end
                end

                // -------------------------------------------------------------
                S_DONE: begin
                    if (!start) begin
                        start_r <= 1'b0;
                        state   <= S_IDLE;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule

`default_nettype wire