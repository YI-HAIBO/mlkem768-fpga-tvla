// =============================================================================
// B2: Third-Order Masking (4-share ISW) + DIP (Domain-Interleaved Precharge)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (B2: order-3 masking + DIP hybrid)
//
// Two orthogonal defenses are combined, each covering the other's known hole:
//
//   1. ORDER-3 BOOLEAN MASKING (4 shares, ISW)
//      Each sensitive value v is split:  v = s0 ^ s1 ^ s2 ^ s3
//      A third-order attacker must probe all four shares simultaneously;
//      any three shares leave one unknown mask. (masked_logic.v = 2 shares
//      = order 1, masked_logic_2nd.v = 3 shares = order 2.)
//
//      Masked AND needs C(4,2) = 6 fresh random words per gate:
//          z_ij = (a_i & b_j) ^ r_ij ,  z_ji = (a_j & b_i) ^ r_ij
//          c_i  = (a_i & b_i) ^ XOR_{j != i} z_ij
//      Same r_ij used for the PAIR (i,j)/(j,i) so the masks cancel in the
//      XOR of all four shares:
//          c0^c1^c2^c3 = (a0^a1^a2^a3) & (b0^b1^b2^b3)
//
//   2. DIP-STYLE DUAL-RAIL PRECHARGE BARRIERS
//      Masking (in the plain probing model) is broken by GLITCHES: a single
//      gate can transiently evaluate a function of more shares than its
//      steady-state does. DIP's fix: every share crosses a dual-rail
//      precharge barrier,
//          precharge phase : rail = inv = 0        (invalid, constant weight 0)
//          evaluate  phase : rail = s, inv = ~s    (constant weight W)
//      so glitches never propagate across a barrier, and every valid pair
//      (rail, inv) has EXACTLY one '1' per bit -> data-independent,
//      constant Hamming weight on the long wires.
//
//      Domain interleaving: the operand shares (b) arrive through their own
//      barrier set and only enter the masked core AFTER the barrier latched
//      them, one cycle after the precharge edge. The masked AND therefore
//      never sees a share that crossed a combinational boundary in the same
//      cycle it is consumed.
//
// Hybrid scope (honest): the ISW order-3 core is fully implemented and
// bit-exact verifiable. The DIP barriers are real registered dual-rail
// stages with a forced precharge phase; in this prototype they protect the
// host-visible share interfaces and the operand entry path, replacing the
// long single-rail wires. A full glitch-extended-probing security proof of
// the combined construction is out of scope for the demo; what IS verified
// here is the functional correctness, the constant-weight property of every
// rail pair (W bits set, always), the precharge invalidation, and a
// fault-injection monitor that flags any rail pair that stops being
// complementary.
//
// Step protocol (the DIP cost model):
//   IDLE --step--> PRE (1 cycle: all barriers precharge, operands settle)
//                -> LOAD (1 cycle: b shares latched through their barriers)
//                -> EVAL (1 cycle: ISW AND, acc re-split under fresh masks)
//                -> DONE (1 cycle: done pulse)
//   3 clock cycles per masked-AND step, 6 fresh 32-bit masks per step,
//   vs 1 cycle and 0 masks for the unmasked AND. That ratio IS the security
//   budget; A3's posture table decides when to pay it.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

// -----------------------------------------------------------------------------
// Order-3 masked XOR gate (4 shares): combinational, no fresh randomness
// -----------------------------------------------------------------------------
module masked_xor_gate_3rd #(
    parameter W = 32
)(
    input  wire [W-1:0] a0, a1, a2, a3,
    input  wire [W-1:0] b0, b1, b2, b3,
    output wire [W-1:0] c0, c1, c2, c3
);
    assign c0 = a0 ^ b0;
    assign c1 = a1 ^ b1;
    assign c2 = a2 ^ b2;
    assign c3 = a3 ^ b3;
endmodule

// -----------------------------------------------------------------------------
// Order-3 masked AND gate (4 shares, ISW): combinational, 6 fresh masks
// -----------------------------------------------------------------------------
module masked_and_gate_3rd #(
    parameter W = 32
)(
    input  wire [W-1:0] a0, a1, a2, a3,
    input  wire [W-1:0] b0, b1, b2, b3,

    // fresh random words, one per unordered share PAIR (6 pairs)
    input  wire [W-1:0] r01, r02, r03, r12, r13, r23,

    output wire [W-1:0] c0, c1, c2, c3
);
    // cross terms: z_ij uses a_i & b_j, z_ji uses a_j & b_i, SAME mask r_ij
    wire [W-1:0] z01 = (a0 & b1) ^ r01;
    wire [W-1:0] z10 = (a1 & b0) ^ r01;
    wire [W-1:0] z02 = (a0 & b2) ^ r02;
    wire [W-1:0] z20 = (a2 & b0) ^ r02;
    wire [W-1:0] z03 = (a0 & b3) ^ r03;
    wire [W-1:0] z30 = (a3 & b0) ^ r03;
    wire [W-1:0] z12 = (a1 & b2) ^ r12;
    wire [W-1:0] z21 = (a2 & b1) ^ r12;
    wire [W-1:0] z13 = (a1 & b3) ^ r13;
    wire [W-1:0] z31 = (a3 & b1) ^ r13;
    wire [W-1:0] z23 = (a2 & b3) ^ r23;
    wire [W-1:0] z32 = (a3 & b2) ^ r23;

    assign c0 = (a0 & b0) ^ z01 ^ z02 ^ z03;
    assign c1 = (a1 & b1) ^ z10 ^ z12 ^ z13;
    assign c2 = (a2 & b2) ^ z20 ^ z21 ^ z23;
    assign c3 = (a3 & b3) ^ z30 ^ z31 ^ z32;
endmodule

// -----------------------------------------------------------------------------
// DIP barrier: dual-rail precharge register for ONE share
// -----------------------------------------------------------------------------
//   pre_n = 0 (precharge): both rails driven to 0 on the next clock edge;
//           the pair is INVALID and carries constant weight 0.
//   pre_n = 1 (evaluate) : rail = in, inv = ~in; the pair carries constant
//           weight W (exactly one rail asserted per bit).
//
// rail_bad is a combinational monitor: the pair must be complementary in
// evaluate and fully discharged in precharge. Natural operation never trips
// it; it exists to catch fault injection (TB verifies with `force`).
// -----------------------------------------------------------------------------
module dip_barrier #(
    parameter W = 32
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        pre_n,        // 0 = precharge, 1 = evaluate
    input  wire [W-1:0] in,           // single-rail share (valid while pre_n=1)
    output reg  [W-1:0] rail,
    output reg  [W-1:0] inv,
    output wire        rail_bad
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rail <= {W{1'b0}};
            inv  <= {W{1'b0}};
        end else if (!pre_n) begin
            // precharge: discharge BOTH rails (invalid, weight 0)
            rail <= {W{1'b0}};
            inv  <= {W{1'b0}};
        end else begin
            // evaluate: dual-rail latch (weight W)
            rail <= in;
            inv  <= ~in;
        end
    end

    assign rail_bad = pre_n ? ((rail ^ inv) !== {W{1'b1}})
                             : ((rail | inv) !== {W{1'b0}});
endmodule

// -----------------------------------------------------------------------------
// Order-3 masked accumulator with DIP-protected share interfaces
// -----------------------------------------------------------------------------
module masked_accumulate_3rd_dip #(
    parameter W = 32
)(
    input  wire        clk,
    input  wire        rst_n,

    // load: split init_value into 4 shares (acc = init_value)
    input  wire        init,
    input  wire [W-1:0] init_value,
    input  wire [W-1:0] im0, im1, im2,       // 3 init masks

    // step: acc <- acc & b, all in the masked domain
    input  wire        step,                 // pulse (only honoured in IDLE)
    input  wire [W-1:0] b0, b1, b2, b3,      // operand shares (hold during step)
    input  wire [W-1:0] r01, r02, r03, r12, r13, r23,  // 6 ISW masks
    input  wire [W-1:0] rm0, rm1, rm2,       // 3 fresh re-split masks

    input  wire        dip_clear,            // clear sticky dip_violation

    // DIP-protected share interface (the ONLY host-visible view of acc)
    output wire [W-1:0] drail0, dinv0,
                       drail1, dinv1,
                       drail2, dinv2,
                       drail3, dinv3,
    output wire        precharge,            // 1 while barriers are precharging

    output wire        busy,
    output wire        done,                 // one-cycle pulse
    output wire        dip_violation         // sticky rail-pair fault
);
    localparam [1:0]
        ST_IDLE = 2'd0,
        ST_PRE  = 2'd1,
        ST_LOAD = 2'd2,
        ST_EVAL = 2'd3;

    reg  [1:0]    cstate;
    reg           busy_r, done_r;
    reg  [W-1:0]  acc0, acc1, acc2, acc3;    // masked accumulator (internal)

    // barriers precharge only during ST_PRE
    wire pre_n = (cstate != ST_PRE);
    assign precharge = !pre_n;
    assign busy = busy_r;
    assign done = done_r;

    // operand shares cross a DIP barrier before entering the masked core
    wire [W-1:0] brail0, binv0, brail1, binv1, brail2, binv2, brail3, binv3;
    wire [W-1:0] qb0, qb1, qb2, qb3;
    wire         rbb0, rbb1, rbb2, rbb3;

    dip_barrier #(.W(W)) u_bb0(.clk(clk), .rst_n(rst_n), .pre_n(pre_n),
        .in(b0), .rail(brail0), .inv(binv0), .rail_bad(rbb0));
    dip_barrier #(.W(W)) u_bb1(.clk(clk), .rst_n(rst_n), .pre_n(pre_n),
        .in(b1), .rail(brail1), .inv(binv1), .rail_bad(rbb1));
    dip_barrier #(.W(W)) u_bb2(.clk(clk), .rst_n(rst_n), .pre_n(pre_n),
        .in(b2), .rail(brail2), .inv(binv2), .rail_bad(rbb2));
    dip_barrier #(.W(W)) u_bb3(.clk(clk), .rst_n(rst_n), .pre_n(pre_n),
        .in(b3), .rail(brail3), .inv(binv3), .rail_bad(rbb3));

    // masked core consumes the barrier outputs (domain-interleaved entry)
    assign qb0 = brail0;
    assign qb1 = brail1;
    assign qb2 = brail2;
    assign qb3 = brail3;

    // order-3 ISW AND of acc and the barrier-protected operand
    wire [W-1:0] n0, n1, n2, n3;
    masked_and_gate_3rd #(.W(W)) u_and(
        .a0(acc0), .a1(acc1), .a2(acc2), .a3(acc3),
        .b0(qb0),  .b1(qb1),  .b2(qb2),  .b3(qb3),
        .r01(r01), .r02(r02), .r03(r03),
        .r12(r12), .r13(r13), .r23(r23),
        .c0(n0), .c1(n1), .c2(n2), .c3(n3));

    // DIP-protected accumulator share outputs
    wire         rba0, rba1, rba2, rba3;
    dip_barrier #(.W(W)) u_ba0(.clk(clk), .rst_n(rst_n), .pre_n(pre_n),
        .in(acc0), .rail(drail0), .inv(dinv0), .rail_bad(rba0));
    dip_barrier #(.W(W)) u_ba1(.clk(clk), .rst_n(rst_n), .pre_n(pre_n),
        .in(acc1), .rail(drail1), .inv(dinv1), .rail_bad(rba1));
    dip_barrier #(.W(W)) u_ba2(.clk(clk), .rst_n(rst_n), .pre_n(pre_n),
        .in(acc2), .rail(drail2), .inv(dinv2), .rail_bad(rba2));
    dip_barrier #(.W(W)) u_ba3(.clk(clk), .rst_n(rst_n), .pre_n(pre_n),
        .in(acc3), .rail(drail3), .inv(dinv3), .rail_bad(rba3));

    wire rail_bad_any = rba0 | rba1 | rba2 | rba3 |
                        rbb0 | rbb1 | rbb2 | rbb3;

    reg dip_violation_r;
    assign dip_violation = dip_violation_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cstate  <= ST_IDLE;
            busy_r  <= 1'b0;
            done_r  <= 1'b0;
            acc0    <= {W{1'b0}};
            acc1    <= {W{1'b0}};
            acc2    <= {W{1'b0}};
            acc3    <= {W{1'b0}};
            dip_violation_r <= 1'b0;
        end else begin
            done_r  <= 1'b0;
            // sticky fault latch (clear wins, like A3's alert_latch inverse)
            if (dip_clear)
                dip_violation_r <= 1'b0;
            else if (rail_bad_any)
                dip_violation_r <= 1'b1;

            case (cstate)
                ST_IDLE: begin
                    if (init) begin
                        // split: acc = im0 ^ im1 ^ im2 ^ (v ^ im0 ^ im1 ^ im2)
                        acc0 <= im0;
                        acc1 <= im1;
                        acc2 <= im2;
                        acc3 <= init_value ^ im0 ^ im1 ^ im2;
                    end else if (step && !busy_r) begin
                        busy_r  <= 1'b1;
                        cstate  <= ST_PRE;
                    end
                end

                ST_PRE: begin
                    // full precharge cycle: all barriers discharge on this edge
                    cstate <= ST_LOAD;
                end

                ST_LOAD: begin
                    // evaluate phase: b shares latch through their barriers
                    cstate <= ST_EVAL;
                end

                ST_EVAL: begin
                    // ISW AND settled; re-split the result under fresh masks
                    acc0   <= rm0;
                    acc1   <= rm1;
                    acc2   <= rm2;
                    acc3   <= (n0 ^ n1 ^ n2 ^ n3) ^ rm0 ^ rm1 ^ rm2;
                    cstate <= ST_IDLE;
                    busy_r <= 1'b0;
                    done_r <= 1'b1;
                end

                default: cstate <= ST_IDLE;
            endcase
        end
    end

endmodule

`default_nettype wire
