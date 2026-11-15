// =============================================================================
// TB for B2 masked_logic_3rd_dip.v (order-3 ISW masking + DIP barriers)
// -----------------------------------------------------------------------------
// T1  4-share split: rail0^rail1^rail2^rail3 == secret
// T2  masked_and_gate_3rd correctness over 64 random vectors
// T3  masked accumulate: acc = seed & o1 & o2 & o3 matches unmasked reference
// T4  DIP invariant: precharge -> all rails 0; evaluate -> rail^inv == all-ones
//     (constant Hamming weight W on every share pair during the whole step)
// T5  fault injection: force a rail non-complementary -> sticky dip_violation,
//     dip_clear releases it
// T6  probing demo: any 3 of 4 shares never equal the secret across 8 trials
// T7  masked_xor_gate_3rd correctness
// T8  no spurious dip_violation during the whole normal workload
//
// Iron rule: every DUT input is driven on the negedge.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module tb_masked_3rd_dip;

  localparam W = 32;

  reg         clk, rst_n;
  reg         init, step, dip_clear;
  reg  [W-1:0] init_value, im0, im1, im2;
  reg  [W-1:0] b0, b1, b2, b3;
  reg  [W-1:0] r01, r02, r03, r12, r13, r23;
  reg  [W-1:0] rm0, rm1, rm2;
  wire [W-1:0] drail0, dinv0, drail1, dinv1, drail2, dinv2, drail3, dinv3;
  wire         precharge, busy, done, dip_violation;

  masked_accumulate_3rd_dip #(.W(W)) dut(
    .clk(clk), .rst_n(rst_n),
    .init(init), .init_value(init_value), .im0(im0), .im1(im1), .im2(im2),
    .step(step), .b0(b0), .b1(b1), .b2(b2), .b3(b3),
    .r01(r01), .r02(r02), .r03(r03), .r12(r12), .r13(r13), .r23(r23),
    .rm0(rm0), .rm1(rm1), .rm2(rm2),
    .dip_clear(dip_clear),
    .drail0(drail0), .dinv0(dinv0),
    .drail1(drail1), .dinv1(dinv1),
    .drail2(drail2), .dinv2(dinv2),
    .drail3(drail3), .dinv3(dinv3),
    .precharge(precharge), .busy(busy), .done(done),
    .dip_violation(dip_violation)
  );

  initial begin clk = 1'b0; forever #5 clk = ~clk; end

  integer errors = 0;
  integer dip_inv_violations = 0;   // T4 counter

  task chk;
    input [255:0] name;
    input         cond;
    begin
      if (cond) $display("PASS %0s", name);
      else begin
        $display("FAIL %0s", name);
        errors = errors + 1;
      end
    end
  endtask

  // current accumulator value from the DIP rails (valid when !precharge)
  function [W-1:0] rail_value;
    begin
      rail_value = drail0 ^ drail1 ^ drail2 ^ drail3;
    end
  endfunction

  // ---- load a secret under three masks -------------------------------------
  task do_init;
    input [W-1:0] v;
    input [W-1:0] m0, m1, m2;
    begin
      @(negedge clk);
      init <= 1'b1; init_value <= v; im0 <= m0; im1 <= m1; im2 <= m2;
      @(posedge clk);
      @(negedge clk);
      init <= 1'b0;
      // one more evaluate edge so the DIP rails latch the fresh shares
      @(posedge clk);
      @(negedge clk);
    end
  endtask

  // ---- one masked accumulate step, monitoring the DIP invariant ------------
  task do_step;
    input [W-1:0] q0, q1, q2, q3;          // operand shares
    input [W-1:0] k01, k02, k03, k12, k13, k23;
    input [W-1:0] m0, m1, m2;              // re-split masks
    begin
      @(negedge clk);
      step <= 1'b1;
      b0 <= q0; b1 <= q1; b2 <= q2; b3 <= q3;
      r01 <= k01; r02 <= k02; r03 <= k03;
      r12 <= k12; r13 <= k13; r23 <= k23;
      rm0 <= m0; rm1 <= m1; rm2 <= m2;
      @(posedge clk);
      @(negedge clk);
      step <= 1'b0;
      // Wait for done, checking the DIP invariant at every negedge.
      // The rails only change on posedges: a pair sampled at negedge N
      // reflects pre_n at the posedge just before N, so the check uses the
      // precharge value sampled at the PREVIOUS negedge.
      prev_pre = precharge;
      while (done !== 1'b1) begin
        @(negedge clk);
        if (prev_pre) begin
          // the intervening posedge discharged the rails
          if ((drail0 | dinv0) !== {W{1'b0}} ||
              (drail1 | dinv1) !== {W{1'b0}} ||
              (drail2 | dinv2) !== {W{1'b0}} ||
              (drail3 | dinv3) !== {W{1'b0}}) begin
            dip_inv_violations = dip_inv_violations + 1;
            $display("   DBG precharge violation: pc=1 rails=%h %h %h %h",
                     drail0, drail1, drail2, drail3);
          end
        end else begin
          // the intervening posedge latched a complementary pair
          if ((drail0 ^ dinv0) !== {W{1'b1}} ||
              (drail1 ^ dinv1) !== {W{1'b1}} ||
              (drail2 ^ dinv2) !== {W{1'b1}} ||
              (drail3 ^ dinv3) !== {W{1'b1}}) begin
            dip_inv_violations = dip_inv_violations + 1;
            $display("   DBG eval violation: pc=0 r0=%h i0=%h r1=%h i1=%h",
                     drail0, dinv0, drail1, dinv1);
          end
        end
        prev_pre = precharge;
      end
      // rails still hold the OLD acc in the done cycle; one more edge
      // latches the new acc into the DIP barriers
      @(posedge clk);
      @(negedge clk);
    end
  endtask

  // ===========================================================================
  integer i, j;
  reg [W-1:0] seed_v, op, expected, got;
  reg [W-1:0] xa0, xa1, xa2, xa3, xb0, xb1, xb2, xb3;
  reg [W-1:0] xc0, xc1, xc2, xc3;
  reg [W-1:0] triv [0:7];
  reg [W-1:0] tmp;
  reg         prev_pre;

  // standalone gates for the unit tests
  wire [W-1:0] ua_c0, ua_c1, ua_c2, ua_c3;
  wire [W-1:0] ux_c0, ux_c1, ux_c2, ux_c3;

  masked_and_gate_3rd #(.W(W)) u_and_dut(
    .a0(xa0), .a1(xa1), .a2(xa2), .a3(xa3),
    .b0(xb0), .b1(xb1), .b2(xb2), .b3(xb3),
    .r01(r01), .r02(r02), .r03(r03),
    .r12(r12), .r13(r13), .r23(r23),
    .c0(ua_c0), .c1(ua_c1), .c2(ua_c2), .c3(ua_c3));

  masked_xor_gate_3rd #(.W(W)) u_xor_dut(
    .a0(xa0), .a1(xa1), .a2(xa2), .a3(xa3),
    .b0(xb0), .b1(xb1), .b2(xb2), .b3(xb3),
    .c0(ux_c0), .c1(ux_c1), .c2(ux_c2), .c3(ux_c3));

  initial begin
    init = 1'b0; step = 1'b0; dip_clear = 1'b0;
    init_value = {W{1'b0}}; im0 = {W{1'b0}}; im1 = {W{1'b0}}; im2 = {W{1'b0}};
    b0 = {W{1'b0}}; b1 = {W{1'b0}}; b2 = {W{1'b0}}; b3 = {W{1'b0}};
    r01 = {W{1'b0}}; r02 = {W{1'b0}}; r03 = {W{1'b0}};
    r12 = {W{1'b0}}; r13 = {W{1'b0}}; r23 = {W{1'b0}};
    rm0 = {W{1'b0}}; rm1 = {W{1'b0}}; rm2 = {W{1'b0}};
    xa0 = 0; xa1 = 0; xa2 = 0; xa3 = 0;
    xb0 = 0; xb1 = 0; xb2 = 0; xb3 = 0;
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    @(negedge clk); rst_n = 1'b1;
    $display("=== B2 masked_logic_3rd_dip testbench start ===");

    // ---------------- T1: 4-share split ----------------------------------
    do_init(32'hDEAD_BEEF, 32'h1111_1111, 32'h2222_2222, 32'h4444_4444);
    got = rail_value();
    $display("   split: value=%h shares=%h %h %h %h", got,
             drail0, drail1, drail2, drail3);
    chk("T1a rail-XOR recovers secret 0xDEADBEEF", got === 32'hDEAD_BEEF);
    chk("T1b no single rail equals the secret",
        drail0 !== 32'hDEAD_BEEF && drail1 !== 32'hDEAD_BEEF &&
        drail2 !== 32'hDEAD_BEEF && drail3 !== 32'hDEAD_BEEF);

    // ---------------- T2: masked AND gate, 64 random vectors -------------
    tmp = 1'b1;
    for (i = 0; i < 64; i = i + 1) begin
      // random shares and masks (deterministic $random seed in iverilog)
      xa0 = $random; xa1 = $random; xa2 = $random; xa3 = $random;
      xb0 = $random; xb1 = $random; xb2 = $random; xb3 = $random;
      r01 = $random; r02 = $random; r03 = $random;
      r12 = $random; r13 = $random; r23 = $random;
      #1;   // let the combinational gate settle
      if ((ua_c0 ^ ua_c1 ^ ua_c2 ^ ua_c3) !==
          ((xa0 ^ xa1 ^ xa2 ^ xa3) & (xb0 ^ xb1 ^ xb2 ^ xb3)))
        tmp = 1'b0;
    end
    chk("T2 ISW order-3 AND: 64 random vectors recombine", tmp);

    // ---------------- T7: masked XOR gate --------------------------------
    tmp = 1'b1;
    for (i = 0; i < 16; i = i + 1) begin
      xa0 = $random; xa1 = $random; xa2 = $random; xa3 = $random;
      xb0 = $random; xb1 = $random; xb2 = $random; xb3 = $random;
      #1;
      if ((ux_c0 ^ ux_c1 ^ ux_c2 ^ ux_c3) !==
          ((xa0 ^ xa1 ^ xa2 ^ xa3) ^ (xb0 ^ xb1 ^ xb2 ^ xb3)))
        tmp = 1'b0;
    end
    chk("T7 masked XOR gate: 16 random vectors recombine", tmp);

    // ---------------- T3: masked accumulate vs reference ------------------
    seed_v = 32'hFF00_FF00;
    op     = 32'hF0FF_0FF0;
    do_init(seed_v, 32'h0A0A_0A0A, 32'h0B0B_0B0B, 32'h0C0C_0C0C);
    expected = seed_v;
    // step 1: op split under masks 0x1234..  (b = op => b_i = masks, b3=op^masks)
    do_step(32'h5000_5000, 32'h6000_6000, 32'h7000_7000,
            op ^ 32'h5000_5000 ^ 32'h6000_6000 ^ 32'h7000_7000,
            32'h0001_0001, 32'h0002_0002, 32'h0003_0003,
            32'h0004_0004, 32'h0005_0005, 32'h0006_0006,
            32'h0101_0101, 32'h0202_0202, 32'h0303_0303);
    expected = expected & op;
    got = rail_value();
    $display("   step1: %h (want %h)", got, expected);
    chk("T3a accumulate step 1", got === expected);

    op = 32'hC0C0_C0C0;
    do_step(32'h1111_2222, 32'h3333_4444, 32'h5555_6666,
            op ^ 32'h1111_2222 ^ 32'h3333_4444 ^ 32'h5555_6666,
            32'h0011_0011, 32'h0022_0022, 32'h0033_0033,
            32'h0044_0044, 32'h0055_0055, 32'h0066_0066,
            32'h1000_1000, 32'h2000_2000, 32'h3000_3000);
    expected = expected & op;
    got = rail_value();
    $display("   step2: %h (want %h)", got, expected);
    chk("T3b accumulate step 2", got === expected);

    op = 32'hAAAA_AAAA;
    do_step(32'h00FF_00FF, 32'h0F00_0F00, 32'h1234_5678,
            op ^ 32'h00FF_00FF ^ 32'h0F00_0F00 ^ 32'h1234_5678,
            32'h1001_1001, 32'h2002_2002, 32'h3003_3003,
            32'h4004_4004, 32'h5005_5005, 32'h6006_6006,
            32'hABCD_0001, 32'hABCD_0002, 32'hABCD_0003);
    expected = expected & op;
    got = rail_value();
    $display("   step3: %h (want %h)", got, expected);
    chk("T3c accumulate step 3", got === expected);

    // ---------------- T4: DIP invariant (monitored inside do_step) --------
    chk("T4 DIP rails: 0 in precharge, complementary in evaluate",
        dip_inv_violations == 0);

    // ---------------- T5: fault injection into a rail ----------------------
    @(negedge clk);
    step <= 1'b1;
    b0 <= 32'hFFFF_0000; b1 <= 32'h0000_FFFF; b2 <= 32'hAAAA_AAAA;
    b3 <= 32'h5555_5555;
    r01 <= 32'h0101_0101; r02 <= 32'h0202_0202; r03 <= 32'h0303_0303;
    r12 <= 32'h0404_0404; r13 <= 32'h0505_0505; r23 <= 32'h0606_0606;
    rm0 <= 32'h1000_0001; rm1 <= 32'h1000_0002; rm2 <= 32'h1000_0003;
    @(posedge clk);
    @(negedge clk);
    step <= 1'b0;
    // wait until the barriers left the precharge phase (ST_LOAD/ST_EVAL)
    while (precharge !== 1'b0) @(negedge clk);
    // corrupt an accumulator output rail: the pair stops being complementary
    force dut.u_ba0.rail = 32'hBAD0_BEEF;
    @(negedge clk);
    @(negedge clk);
    release dut.u_ba0.rail;
    // the violation latched at the ST_EVAL -> IDLE edge; let the step settle
    repeat (3) @(negedge clk);
    chk("T5a forced rail fault raises dip_violation", dip_violation === 1'b1);
    @(negedge clk); dip_clear <= 1'b1;
    @(posedge clk);
    @(negedge clk); dip_clear <= 1'b0;
    chk("T5b dip_clear releases the sticky latch", dip_violation === 1'b0);

    // ---------------- T6: probing demo, 8 re-splits of one secret ---------
    tmp = 1'b1;
    for (i = 0; i < 8; i = i + 1) begin
      do_init(32'hCAFE_BABE, {$random}, {$random}, {$random});
      // XOR of any three shares = secret ^ remaining share != secret
      triv[i] = drail0 ^ drail1 ^ drail2;     // leaves out drail3
      $display("   T6 trial %0d: shares=%h %h %h %h", i, drail0, drail1, drail2, drail3);
      if (triv[i] === 32'hCAFE_BABE) begin
        tmp = 1'b0; $display("   T6 leak: s0^s1^s2 == secret (s3=%h)", drail3);
      end
      if ((drail1 ^ drail2 ^ drail3) === 32'hCAFE_BABE) begin
        tmp = 1'b0; $display("   T6 leak: s1^s2^s3 == secret (s0=%h)", drail0);
      end
      if ((drail0 ^ drail2 ^ drail3) === 32'hCAFE_BABE) begin
        tmp = 1'b0; $display("   T6 leak: s0^s2^s3 == secret (s1=%h)", drail1);
      end
      if ((drail0 ^ drail1 ^ drail3) === 32'hCAFE_BABE) begin
        tmp = 1'b0; $display("   T6 leak: s0^s1^s3 == secret (s2=%h)", drail2);
      end
    end
    chk("T6 no 3-of-4 share subset reveals the secret (8 trials)", tmp);
    // the triples must also vary across trials (masks actually active)
    tmp = 1'b1;
    for (i = 1; i < 8; i = i + 1)
      if (triv[i] === triv[0]) tmp = 1'b0;
    chk("T6b re-split masks are active (triples differ across trials)", tmp);

    // ---------------- T8: no spurious violation during workload -----------
    chk("T8 dip_violation silent during normal operation",
        dip_violation === 1'b0);

    // ----------------------------------------------------------------------
    if (errors == 0) $display("=== ALL TESTS PASSED (B2 masked_logic_3rd_dip) ===");
    else             $display("=== %0d FAILURES ===", errors);
    $finish;
  end

  initial begin
    #500000;
    $display("FAIL: timeout");
    $finish;
  end

endmodule

`default_nettype wire
