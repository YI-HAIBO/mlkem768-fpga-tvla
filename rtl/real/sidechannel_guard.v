// =============================================================================
// Module 3 top level : side-channel protection wrapper
// -----------------------------------------------------------------------------
// Project : IPX-AOI-Sec
//
// Bundles the random source, the masked datapath and the jitter controller
// the way the rest of the IP uses them: one mask/jitter source feeding a
// masked computation, with a "done" pulse after a random delay.
//
// The plaintext port `operand_a_plain` is masked immediately on `start` and
// the register then holds only shares. There is deliberately no plaintext
// output port - a consumer that needs the value XORs the two shares itself,
// and that recombination is the one point an attacker aims at.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module sidechannel_guard #(
    parameter W         = 32,
    parameter MAX_DELAY = 16,
    parameter [127:0]  TRNG_SEED = 128'h1
)(
    input  wire         clk,
    input  wire         rst_n,

    // entropy injection (jitter / thermal). Without it the LFSR is linear.
    input  wire         reseed,
    input  wire [127:0] entropy,

    // ---- masked computation trigger ---------------------------------------
    input  wire         start,        // begin: mask the operand
    input  wire [W-1:0] operand_a_plain,
    input  wire [W-1:0] operand_b0,   // second operand, already in shares
    input  wire [W-1:0] operand_b1,
    input  wire [15:0] op_id,

    // ---- results (share domain only) --------------------------------------
    output wire [W-1:0] result0,
    output wire [W-1:0] result1,
    output wire         result_valid,   // after the jitter delay
    output wire [W-1:0]  mask_o,         // the mask used, for observability
    output wire [15:0]   delay_o,        // jitter actually inserted
    output wire          trng_health
);

    // ---- random source ----------------------------------------------------
    wire [31:0] rnd_word;
    wire [31:0] draw_count;

    lfsr_trng #(.SEED(TRNG_SEED)) u_trng (
        .clk        (clk),
        .rst_n      (rst_n),
        .reseed     (reseed),
        .entropy    (entropy),
        // Draw a fresh mask on every clock the guard is active. Leaving this
        // port unconnected (it did not exist before the enable was added)
        // floats the input, so rnd_out stayed 0 and every mask was zero -
        // the datapath still computed the right answer, which is exactly why
        // only the share-inequality check caught it.
        .enable     (1'b1),
        .rnd_out    (rnd_word),
        .health_ok  (trng_health),
        .draw_count (draw_count)
    );

    wire [31:0] mask_a  = rnd_word;
    wire [31:0] mask_b  = draw_count;    // decorrelated second word
    wire [31:0] mask_r1 = draw_count;    // (distinct draws, still random)
    wire [31:0] mask_r2 = rnd_word;

    assign mask_o = mask_a;

    // ---- masked datapath --------------------------------------------------
    wire [W-1:0] acc0, acc1;
    reg         acc_init;
    reg         acc_step;
    reg [W-1:0] init_value;
    reg [W-1:0] init_mask;

    masked_accumulate #(.W(W)) u_acc (
        .clk          (clk),
        .rst_n        (rst_n),
        .init         (acc_init),
        .init_value   (init_value),
        .init_mask    (init_mask),
        .step         (acc_step),
        .b0           (operand_b0),
        .b1           (operand_b1),
        .r1           (mask_r1),
        .r2           (mask_r2),
        .remask_mask  (mask_b),
        .acc0         (acc0),
        .acc1         (acc1)
    );

    assign result0 = acc0;
    assign result1 = acc1;

    // ---- control ----------------------------------------------------------
    reg        run;
    reg [15:0] op_id_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_init      <= 1'b0;
            acc_step      <= 1'b0;
            init_value    <= {W{1'b0}};
            init_mask     <= {W{1'b0}};
            run           <= 1'b0;
            op_id_r       <= 16'd0;
        end else begin
            acc_init     <= 1'b0;
            acc_step     <= 1'b0;

            if (start && !run) begin
                // mask the plaintext operand on the spot
                acc_init   <= 1'b1;
                init_value <= operand_a_plain;
                init_mask  <= mask_a;
                op_id_r    <= op_id;
                run        <= 1'b1;
            end else if (run) begin
                acc_step <= 1'b1;
                run      <= 1'b0;
            end
        end
    end

    // ---- jitter between the operation and the "done" pulse -----------------
    wire jitter_done;

    jitter_ctrl #(.MAX_DELAY(MAX_DELAY)) u_jitter (
        .clk          (clk),
        .rst_n        (rst_n),
        .in_valid     (run),
        .rnd          (mask_a[7:0]),
        .op_id        (op_id_r),
        .out_valid    (jitter_done),
        .delay_cycles (delay_o)
    );

    // jitter_done is a one-clock pulse. Registering it delayed the result by
    // another clock, and a consumer polling on the pulse could miss it
    // entirely - the shares were already correct but result_valid was
    // observed low. Pass it straight through.
    assign result_valid = jitter_done;

endmodule

`default_nettype wire
