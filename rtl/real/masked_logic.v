// =============================================================================
// Module 3 sub-core : masked register and masked combinational gates
// -----------------------------------------------------------------------------
// Project : IPX-AOI-Sec
//
// Bit-exact with behavioral/m3_sidechannel.py:
//   split_secret(v, m)  ->  (m, v ^ m)
//   masked_xor(a0,a1,b0,b1,mask)
//   masked_and(a0,a1,b0,b1,r1,r2)
//
// The plaintext NEVER appears on a port. The only outputs are the two
// shares; a downstream consumer recombines with XOR when it genuinely needs
// the value, and that recombination point is the single place where a
// power-trace attacker has a target - which is exactly what the share split
// is meant to spread out.
//
// masked AND (first order, two random words r1 and r2):
//     c0 = a0&b0                            ^ (r1 ^ r2)
//     c1 = a0&b1 ^ a1&b0 ^ a1&b1            ^ (r1 ^ r2)
// Expanding c0^c1 cancels the mask and leaves
//     a0&b0 ^ a0&b1 ^ a1&b0 ^ a1&b1 == (a0^a1) & (b0^b1)
//
// masked XOR takes a SINGLE mask written to both shares. Passing two
// different random words leaves a stray r0^r1 term in the result - that was a
// real bug in the first Python version.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none


// -----------------------------------------------------------------------------
// Masked register: splits on load, can re-mask without changing the value
// -----------------------------------------------------------------------------
module masked_xor_reg #(
    parameter W = 32
)(
    input  wire         clk,
    input  wire         rst_n,

    input  wire         load,        // split din into the two shares now
    input  wire [W-1:0] din,         // plaintext in (only while load is high)
    input  wire [W-1:0] mask,        // mask for this load

    input  wire         remask,      // re-randomise the split
    input  wire [W-1:0] remask_mask, // mask for the re-split

    output reg  [W-1:0] share0,
    output reg  [W-1:0] share1
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            share0 <= {W{1'b0}};
            share1 <= {W{1'b0}};
        end else if (load) begin
            share0 <= mask;
            share1 <= din ^ mask;
        end else if (remask) begin
            // value = share0 ^ share1 must be preserved
            share0 <= remask_mask;
            share1 <= (share0 ^ share1) ^ remask_mask;
        end
    end

endmodule


// -----------------------------------------------------------------------------
// Masked XOR gate: combinational, single mask on both shares
// -----------------------------------------------------------------------------
module masked_xor_gate #(
    parameter W = 32
)(
    input  wire [W-1:0] a0,
    input  wire [W-1:0] a1,
    input  wire [W-1:0] b0,
    input  wire [W-1:0] b1,
    input  wire [W-1:0] mask,
    output wire [W-1:0] c0,
    output wire [W-1:0] c1
);
    assign c0 = a0 ^ b0 ^ mask;
    assign c1 = a1 ^ b1 ^ mask;
endmodule


// -----------------------------------------------------------------------------
// Masked AND gate: combinational, two random words
// -----------------------------------------------------------------------------
module masked_and_gate #(
    parameter W = 32
)(
    input  wire [W-1:0] a0,
    input  wire [W-1:0] a1,
    input  wire [W-1:0] b0,
    input  wire [W-1:0] b1,
    input  wire [W-1:0] r1,
    input  wire [W-1:0] r2,
    output wire [W-1:0] c0,
    output wire [W-1:0] c1
);
    wire [W-1:0] msk = r1 ^ r2;
    assign c0 = (a0 & b0)                            ^ msk;
    assign c1 = (a0 & b1) ^ (a1 & b0) ^ (a1 & b1)    ^ msk;
endmodule


// -----------------------------------------------------------------------------
// Masked accumulator: register + AND in one clock, result re-masked
// -----------------------------------------------------------------------------
module masked_accumulate #(
    parameter W = 32
)(
    input  wire         clk,
    input  wire         rst_n,

    input  wire         init,        // start a new accumulation
    input  wire [W-1:0] init_value,  // plaintext seed
    input  wire [W-1:0] init_mask,

    input  wire         step,        // acc = acc & operand
    input  wire [W-1:0] b0,
    input  wire [W-1:0] b1,
    input  wire [W-1:0] r1,
    input  wire [W-1:0] r2,
    input  wire [W-1:0] remask_mask,

    output reg  [W-1:0] acc0,
    output reg  [W-1:0] acc1
);

    wire [W-1:0] n0 = (acc0 & b0) ^ (r1 ^ r2);
    wire [W-1:0] n1 = (acc0 & b1) ^ (acc1 & b0) ^ (acc1 & b1) ^ (r1 ^ r2);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc0 <= {W{1'b0}};
            acc1 <= {W{1'b0}};
        end else if (init) begin
            acc0 <= init_mask;
            acc1 <= init_value ^ init_mask;
        end else if (step) begin
            // Re-split the RESULT under a fresh mask, rather than keeping the
            // gate's c0 as share0. Keeping c0 gave
            //     acc0^acc1 = n0 ^ (n0^n1) ^ remask_mask = n1 ^ remask_mask
            // i.e. the recomputed value was the result XORed with the mask.
            // The datapath still "worked" (a single AND then compare), which
            // is why only the end-to-end recombination check exposed it.
            acc0 <= remask_mask;
            acc1 <= (n0 ^ n1) ^ remask_mask;
        end
    end

endmodule


// -----------------------------------------------------------------------------
// Jitter controller: random delay insertion
//
// Masking hides the amplitude; jitter destroys the timing correlation an
// attacker uses to align traces and locate round boundaries. The delay
// depends on both the random byte and the operation id, so two identical
// operations do not always get the same delay (that uniformity would itself
// become a distinguishing feature).
// -----------------------------------------------------------------------------
module jitter_ctrl #(
    parameter MAX_DELAY = 16
)(
    input  wire        clk,
    input  wire        rst_n,

    input  wire        in_valid,
    input  wire [7:0]  rnd,        // random byte from the TRNG
    input  wire [15:0] op_id,      // operation index

    output reg         out_valid,  // pulse once the delay has elapsed
    output reg  [15:0] delay_cycles
);

    localparam CW = 16;            // counter width

    reg [CW-1:0] target;
    reg [CW-1:0] cnt;
    reg          running;
    reg [2:0]    cstage;           // 0=idle 1=snapshot 2=multiply 3=modulo
    reg [7:0]    rnd_r;            // snapshot of rnd on the in_valid edge
    reg [15:0]   op_id_r;          // snapshot of op_id on the same edge
    reg [23:0]   raw_r;            // registered multiply result
    reg [23:0]   modv_r;           // registered modulo result

    // delay = (op_id*7 + rnd*3) mod (MAX_DELAY+1), as in the Python model.
    // The multiplies plus the constant modulo are 17 logic levels deep and do
    // not fit one 10 ns Artix-7 clock, so the datapath is split into three
    // registered stages (snapshot -> multiply -> modulo). rnd_r/op_id_r hold
    // the SAME operand values the original single-cycle design consumed, so
    // the produced delay value is unchanged; only its latency grows by three
    // clocks (immaterial for a random-delay block).
    //
    // The modulo itself uses the identity 2^8 = 256 = 15*17 + 1, i.e.
    // 2^8 == 1 (mod 17), so a 24-bit value mod 17 equals the sum of its three
    // 8-bit digits mod 17. That trades a 24-bit divider for two 8-bit adds
    // plus a 10-bit modulo, which is several logic levels shallower and is
    // what buys real timing margin on Artix-7. Guarded by a generate so any
    // other MAX_DELAY keeps the plain (still correct) modulo.
    wire [23:0] modv;

    generate
        if (MAX_DELAY + 1 == 17) begin : g_mod17
            wire [9:0] digit_sum = raw_r[23:16] + raw_r[15:8] + raw_r[7:0];
            assign modv = digit_sum % (MAX_DELAY + 1);
        end else begin : g_mod_generic
            assign modv = raw_r % (MAX_DELAY + 1);
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            target       <= {(CW-1){1'b0}};
            cnt          <= {(CW-1){1'b0}};
            running      <= 1'b0;
            out_valid    <= 1'b0;
            delay_cycles <= {(CW-1){1'b0}};
            cstage       <= 3'd0;
            rnd_r        <= 8'd0;
            op_id_r      <= 16'd0;
            raw_r        <= 24'd0;
            modv_r       <= 24'd0;
        end else begin
            out_valid <= 1'b0;
            case (cstage)
                3'd0: begin
                    if (in_valid && !running) begin
                        // snapshot the operands exactly as they appear this clock
                        rnd_r   <= rnd;
                        op_id_r <= op_id;
                        cstage  <= 3'd1;
                    end else if (running) begin
                        if (cnt >= target) begin
                            running   <= 1'b0;
                            out_valid <= 1'b1;
                        end else begin
                            cnt <= cnt + 1'b1;
                        end
                    end
                end

                3'd1: begin
                    // stage 1: the two multiplies and the add
                    raw_r  <= (op_id_r * 16'd7) + (rnd_r * 24'd3);
                    cstage <= 3'd2;
                end

                3'd2: begin
                    // stage 2: the constant modulo
                    modv_r <= modv;
                    cstage <= 3'd3;
                end

                3'd3: begin
                    // stage 3: start the delay counter
                    target       <= modv_r[CW-1:0];
                    delay_cycles <= modv_r[CW-1:0];
                    cnt          <= {(CW-1){1'b0}};
                    running      <= 1'b1;
                    cstage       <= 3'd0;
                end

                default: cstage <= 3'd0;
            endcase
        end
    end

endmodule


`default_nettype wire
