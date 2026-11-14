// =============================================================================
// Second-Order Masked Logic (3-share ISW multiplication)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec
// Upgrade  : first-order (2 shares) → second-order (3 shares)
//
// Each sensitive value v is split into three shares:
//     v = share0 ^ share1 ^ share2
//
// A second-order attacker must observe all three shares simultaneously to
// recover v; observing any two leaves the third as an unknown mask.
//
// Masked AND uses the ISW (Ishai-Sahai-Wagner) algorithm. For 3 shares the
// cross terms are:
//
//   For each pair (i,j) with i<j:
//       t_ij = (a_i & b_j) ^ r_ij        (fresh random r_ij)
//       t_ji = (a_j & b_i) ^ r_ij
//
//   c_0 = (a_0 & b_0) ^ t_12 ^ t_21
//   c_1 = (a_1 & b_1) ^ t_02 ^ t_20
//   c_2 = (a_2 & b_2) ^ t_01 ^ t_10
//
// Verification:
//   c_0 ^ c_1 ^ c_2 = sum_{i,j} a_i & b_j = (a_0^a_1^a_2) & (b_0^b_1^b_2)
//
// Three fresh random words (r_01, r_02, r_12) are required per AND gate.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

// -----------------------------------------------------------------------------
// Masked register (3 shares): load with two masks, remask with two fresh masks
// -----------------------------------------------------------------------------
module masked_xor_reg_2nd #(
    parameter W = 32
)(
    input  wire         clk,
    input  wire         rst_n,

    input  wire         load,
    input  wire [W-1:0] din,          // plaintext in (only while load is high)
    input  wire [W-1:0] mask0,        // first mask for this load
    input  wire [W-1:0] mask1,        // second mask for this load

    input  wire         remask,        // re-randomise the split
    input  wire [W-1:0] remask0,      // first fresh mask for remask
    input  wire [W-1:0] remask1,      // second fresh mask for remask

    output reg  [W-1:0] share0,
    output reg  [W-1:0] share1,
    output reg  [W-1:0] share2
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            share0 <= {W{1'b0}};
            share1 <= {W{1'b0}};
            share2 <= {W{1'b0}};
        end else if (load) begin
            // v = share0 ^ share1 ^ share2 = mask0 ^ mask1 ^ (din ^ mask0 ^ mask1) = din
            share0 <= mask0;
            share1 <= mask1;
            share2 <= din ^ mask0 ^ mask1;
        end else if (remask) begin
            // Preserve v = share0 ^ share1 ^ share2 under fresh masks
            share0 <= remask0;
            share1 <= remask1;
            share2 <= (share0 ^ share1 ^ share2) ^ remask0 ^ remask1;
        end
    end

endmodule

// -----------------------------------------------------------------------------
// Masked XOR gate (3 shares): combinational, no fresh randomness needed
// -----------------------------------------------------------------------------
module masked_xor_gate_2nd #(
    parameter W = 32
)(
    input  wire [W-1:0] a0,
    input  wire [W-1:0] a1,
    input  wire [W-1:0] a2,
    input  wire [W-1:0] b0,
    input  wire [W-1:0] b1,
    input  wire [W-1:0] b2,
    output wire [W-1:0] c0,
    output wire [W-1:0] c1,
    output wire [W-1:0] c2
);
    assign c0 = a0 ^ b0;
    assign c1 = a1 ^ b1;
    assign c2 = a2 ^ b2;
endmodule

// -----------------------------------------------------------------------------
// Masked AND gate (3 shares): ISW algorithm, needs 3 fresh random words
// -----------------------------------------------------------------------------
module masked_and_gate_2nd #(
    parameter W = 32
)(
    input  wire [W-1:0] a0,
    input  wire [W-1:0] a1,
    input  wire [W-1:0] a2,
    input  wire [W-1:0] b0,
    input  wire [W-1:0] b1,
    input  wire [W-1:0] b2,

    // Fresh random masks for the ISW cross terms
    input  wire [W-1:0] r01,        // mask for cross terms (0,1) and (1,0)
    input  wire [W-1:0] r02,        // mask for cross terms (0,2) and (2,0)
    input  wire [W-1:0] r12,        // mask for cross terms (1,2) and (2,1)

    output wire [W-1:0] c0,
    output wire [W-1:0] c1,
    output wire [W-1:0] c2
);
    // ISW cross terms
    wire [W-1:0] t01 = (a0 & b1) ^ r01;
    wire [W-1:0] t10 = (a1 & b0) ^ r01;
    wire [W-1:0] t02 = (a0 & b2) ^ r02;
    wire [W-1:0] t20 = (a2 & b0) ^ r02;
    wire [W-1:0] t12 = (a1 & b2) ^ r12;
    wire [W-1:0] t21 = (a2 & b1) ^ r12;

    // Share computation
    assign c0 = (a0 & b0) ^ t12 ^ t21;
    assign c1 = (a1 & b1) ^ t02 ^ t20;
    assign c2 = (a2 & b2) ^ t01 ^ t10;

endmodule

// -----------------------------------------------------------------------------
// Masked accumulator (3 shares): AND + accumulate with re-mask on each step
// -----------------------------------------------------------------------------
module masked_accumulate_2nd #(
    parameter W = 32
)(
    input  wire         clk,
    input  wire         rst_n,

    input  wire         init,            // start a new accumulation
    input  wire [W-1:0] init_value,      // plaintext seed
    input  wire [W-1:0] init_mask0,      // first mask for init
    input  wire [W-1:0] init_mask1,      // second mask for init

    input  wire         step,            // acc = acc & operand
    input  wire [W-1:0] b0,
    input  wire [W-1:0] b1,
    input  wire [W-1:0] b2,
    input  wire [W-1:0] r01,             // ISW mask for this step
    input  wire [W-1:0] r02,
    input  wire [W-1:0] r12,
    input  wire [W-1:0] remask0,         // fresh mask for re-splitting result
    input  wire [W-1:0] remask1,

    output reg  [W-1:0] acc0,
    output reg  [W-1:0] acc1,
    output reg  [W-1:0] acc2
);
    // ISW cross terms for acc & b
    wire [W-1:0] t01 = (acc0 & b1) ^ r01;
    wire [W-1:0] t10 = (acc1 & b0) ^ r01;
    wire [W-1:0] t02 = (acc0 & b2) ^ r02;
    wire [W-1:0] t20 = (acc2 & b0) ^ r02;
    wire [W-1:0] t12 = (acc1 & b2) ^ r12;
    wire [W-1:0] t21 = (acc2 & b1) ^ r12;

    // Raw AND result (still in 3 shares before re-mask)
    wire [W-1:0] n0 = (acc0 & b0) ^ t12 ^ t21;
    wire [W-1:0] n1 = (acc1 & b1) ^ t02 ^ t20;
    wire [W-1:0] n2 = (acc2 & b2) ^ t01 ^ t10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc0 <= {W{1'b0}};
            acc1 <= {W{1'b0}};
            acc2 <= {W{1'b0}};
        end else if (init) begin
            acc0 <= init_mask0;
            acc1 <= init_mask1;
            acc2 <= init_value ^ init_mask0 ^ init_mask1;
        end else if (step) begin
            // Re-split the result under fresh masks
            acc0 <= remask0;
            acc1 <= remask1;
            acc2 <= (n0 ^ n1 ^ n2) ^ remask0 ^ remask1;
        end
    end

endmodule

`default_nettype wire