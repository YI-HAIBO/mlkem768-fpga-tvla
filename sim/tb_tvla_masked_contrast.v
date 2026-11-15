// =============================================================================
// TB for #6c masked-vs-unmasked contrast through the #6a probe router.
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (B3 coverage extension: masking efficacy contrast)
//
// A secret-dependent byte v is either exposed plaintext (tap0) or split into
// two shares by masked_xor_reg (tap1 = share0, tap2 = share1). Running the
// fixed-key vs random-key Welch comparison on each probe through ONE router +
// ONE tvla_online engine must show:
//   tap0 (unmasked HW(v))          -> LEAK      (HW(v) depends on the key)
//   tap1 (masked HW(share0))       -> NO leak   (share0 = mask, key-independent)
//   tap2 (masked HW(share1))       -> NO leak   (share1 = v^mask, key-masked)
// This is the on-die "masking efficacy" contrast that a single fixed-vs-random
// test on the plaintext cannot provide.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module tb_tvla_masked_contrast;

  localparam NTAP    = 3;
  localparam TAPID_W = 2;
  localparam PROBE_W = 8;
  localparam HW_W    = 6;
  localparam SW      = 6;
  localparam NLOG2   = 12;
  localparam integer N = (1 << NLOG2);   // 4096 per group

  reg         clk, rst_n;
  reg  [NTAP*PROBE_W-1:0] probe_flat;
  reg         probe_valid, probe_fixed, tap_advance;
  wire [SW-1:0] sample;
  wire        sample_valid, sample_fixed, batch_restart;
  wire        batch_done, leak_detected, degenerate;
  wire [TAPID_W-1:0] tap_id;
  wire [NTAP-1:0] leak_result, degen_result;
  wire        report_cycle;

  tvla_probe_router #(
    .NTAP(NTAP), .TAPID_W(TAPID_W), .PROBE_W(PROBE_W),
    .HW_W(HW_W), .SAMPLE_W(SW)
  ) router(
    .clk(clk), .rst_n(rst_n),
    .probe_flat(probe_flat),
    .probe_valid(probe_valid), .probe_fixed(probe_fixed),
    .tap_advance(tap_advance),
    .sample(sample), .sample_valid(sample_valid), .sample_fixed(sample_fixed),
    .batch_restart(batch_restart),
    .batch_done(batch_done), .leak_detected(leak_detected), .degenerate(degenerate),
    .tap_id(tap_id), .leak_result(leak_result), .degen_result(degen_result),
    .report_cycle(report_cycle)
  );

  wire [NLOG2:0] cf_o, cr_o;
  tvla_online #(.SAMPLE_W(SW), .N_LOG2(NLOG2), .THRESH2(81)) engine(
    .clk(clk), .rst_n(rst_n),
    .sample_valid(sample_valid), .sample(sample), .sample_fixed(sample_fixed),
    .batch_restart(batch_restart),
    .batch_ready(), .batch_done(batch_done),
    .leak_detected(leak_detected), .degenerate(degenerate),
    .cnt_fixed(cf_o), .cnt_random(cr_o),
    .sum_fixed(), .sum_random(), .sq_fixed(), .sq_random()
  );

  // masked register: din = v (secret-dependent), mask = m (random)
  reg        mload;
  reg  [7:0] din, msk;
  wire [7:0] share0, share1;
  masked_xor_reg #(.W(8)) mreg(
    .clk(clk), .rst_n(rst_n),
    .load(mload), .din(din), .mask(msk),
    .remask(1'b0), .remask_mask(8'd0),
    .share0(share0), .share1(share1)
  );

  initial begin clk = 1'b0; forever #5 clk = ~clk; end

  integer errors = 0;
  task chk;
    input [255:0] name;
    input         cond;
    begin
      if (cond) $display("PASS %0s", name);
      else begin $display("FAIL %0s", name); errors = errors + 1; end
    end
  endtask

  function [7:0] lfsr8;
    input [7:0] x;
    begin lfsr8 = (x[0]) ? ((x >> 1) ^ 8'hB8) : (x >> 1); end
  endfunction

  reg [7:0] lv, lm;
  integer k;
  reg [7:0] vk;
  reg r0, r1, r2;

  // ---- run one tap: stream 2n samples (v from fixed or LFSR, mask LFSR) -----
  task run_tap;
    input [3:0] t;
    output      did_report;
    begin
      while (batch_restart) @(negedge clk);
      @(negedge clk);
      probe_valid = 1'b0; probe_fixed = 1'b0; tap_advance = 1'b0;
      probe_flat  = {NTAP*PROBE_W{1'b0}};
      mload = 1'b0; din = 8'd0; msk = 8'd0;
      lv <= 8'h01; lm <= 8'hA7;
      for (k = 0; k < 2*N; k = k + 1) begin
        @(negedge clk);
        // CRITICAL: clear probe_valid BEFORE the share-latch posedge, or the
        // engine samples the SAME sample twice (once here, once below).
        probe_valid = 1'b0;
        // key-dependent value vk: fixed 0xFF for the fixed group, LFSR otherwise
        if (k[0]) begin vk = 8'hFF; end
        else begin vk = lv; lv = lfsr8(lv); end
        // random mask m
        msk = lm; lm = lfsr8(lm);
        din = vk; mload = 1'b1;
        @(posedge clk);                 // masked_xor_reg latches shares (no sample)
        @(negedge clk);
        // taps: tap0 = v (plaintext), tap1 = share0, tap2 = share1
        probe_flat = {share1, share0, vk};
        probe_valid = 1'b1;
        probe_fixed = k[0];
        @(posedge clk);                 // router/engine samples ONCE here
        mload = 1'b0;
        if (k % 2048 == 0)
          $display("  [tap%0d] k=%0d cf=%0d cr=%0d s=%0d",
                   t, k, cf_o, cr_o, sample);
      end
      @(negedge clk);
      probe_valid = 1'b0;
      while (batch_done !== 1'b1) @(negedge clk);
      @(negedge clk); tap_advance = 1'b1;
      @(posedge clk); @(negedge clk);
      did_report = report_cycle;
      tap_advance = 1'b0;
    end
  endtask

  initial begin
    probe_flat  = {NTAP*PROBE_W{1'b0}};
    probe_valid = 1'b0; probe_fixed = 1'b0; tap_advance = 1'b0;
    mload = 1'b0; din = 8'd0; msk = 8'd0;
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    @(negedge clk); rst_n = 1'b1;
    $display("=== B3#6c masked-vs-unmasked contrast TB (n=%0d/group) ===", N);

    run_tap(4'd0, r0);   // tap0: plaintext HW(v)          -> expect LEAK
    run_tap(4'd1, r1);   // tap1: masked HW(share0)        -> expect NO leak
    run_tap(4'd2, r2);   // tap2: masked HW(share1)        -> expect NO leak

    $display("leak_result = %b (expect 000 = tap0 only)", leak_result);
    chk("tap0 unmasked LEAKS",       leak_result[0] === 1'b1);
    chk("tap1 masked share0 no leak", leak_result[1] === 1'b0);
    chk("tap2 masked share1 no leak", leak_result[2] === 1'b0);
    chk("full round reported", r2 === 1'b1);
    chk("no leak from masked taps", (leak_result[2:1] === 2'b00));

    if (errors == 0) $display("=== ALL TESTS PASSED (#6c masked contrast) ===");
    else             $display("=== %0d FAILURES ===", errors);
    $finish;
  end

  initial begin
    #9000000;
    $display("FAIL: timeout");
    $finish;
  end

endmodule

`default_nettype wire
