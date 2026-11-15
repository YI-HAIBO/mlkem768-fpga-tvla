// =============================================================================
// TB for #6a tvla_probe_router.v (multi-probe time-division router) + real
// tvla_online engine. End-to-end: NTAP=4 probes through ONE Welch engine.
//   tap0, tap2 : both groups from an LFSR (same law)   -> NO leak
//   tap1, tap3 : fixed const vs LFSR                   -> leak
// Verifies: correct probe routing, per-tap verdict latch, tap wrap -> report_cycle.
// Iron rule: drive on negedges; sample pulses on the negedge after the posedge.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module tb_tvla_probe_router;

  localparam NTAP    = 4;
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

  tvla_online #(.SAMPLE_W(SW), .N_LOG2(NLOG2), .THRESH2(81)) engine(
    .clk(clk), .rst_n(rst_n),
    .sample_valid(sample_valid), .sample(sample), .sample_fixed(sample_fixed),
    .batch_restart(batch_restart),
    .batch_ready(), .batch_done(batch_done),
    .leak_detected(leak_detected), .degenerate(degenerate),
    .cnt_fixed(), .cnt_random(),
    .sum_fixed(), .sum_random(), .sq_fixed(), .sq_random()
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

  // 8-bit Galois LFSR (taps 0xB8), mirrors tvla_golden.py
  function [7:0] lfsr8;
    input [7:0] x;
    begin lfsr8 = (x[0]) ? ((x >> 1) ^ 8'hB8) : (x >> 1); end
  endfunction

  reg [7:0] lfa, lfb;
  integer k, tap;
  reg [7:0] fsamp, rsamp;
  reg r0, r1, r2, r3;   // per-tap report_cycle captures

  // ---- run one tap: stream 2n samples, wait batch_done, advance -------------
  task run_tap;
    input [3:0] t;
    output      did_report;
    begin
      // wait for any pending batch_restart to clear before streaming
      while (batch_restart) @(negedge clk);
      @(negedge clk);
      probe_valid = 1'b0;
      probe_fixed = 1'b0;
      probe_flat  = {NTAP*PROBE_W{1'b0}};
      if (t == 0 || t == 2) begin lfa <= 8'h01; lfb <= 8'h5A; end
      else                  begin lfb <= 8'h5A; end
      for (k = 0; k < 2*N; k = k + 1) begin
        @(negedge clk);
        if (k == 0) probe_valid = 1'b1;
        probe_fixed = k[0];
        if (t == 0 || t == 2) begin
          // both groups LFSR (same law) -> no leak
          fsamp = lfa; lfa = lfsr8(lfa);
          rsamp = lfb; lfb = lfsr8(lfb);
        end else begin
          // fixed const vs LFSR -> leak
          fsamp = 8'hFF;
          rsamp = lfb; lfb = lfsr8(lfb);
        end
        probe_flat = (k[0] ? fsamp : rsamp) << (t*PROBE_W);
      end
      @(negedge clk);
      probe_valid = 1'b0;
      while (batch_done !== 1'b1) @(negedge clk);
      @(negedge clk); tap_advance = 1'b1;
      @(posedge clk); @(negedge clk);
      did_report = report_cycle;      // for the last tap this is the wrap pulse
      tap_advance = 1'b0;
    end
  endtask

  initial begin
    probe_flat  = {NTAP*PROBE_W{1'b0}};
    probe_valid = 1'b0; probe_fixed = 1'b0; tap_advance = 1'b0;
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    @(negedge clk); rst_n = 1'b1;
    $display("=== B3#6a tvla_probe_router TB (NTAP=%0d, n=%0d/group) ===", NTAP, N);

    // tap0 no-leak, tap1 leak, tap2 no-leak, tap3 leak
    run_tap(4'd0, r0);
    run_tap(4'd1, r1);
    run_tap(4'd2, r2);
    run_tap(4'd3, r3);

    $display("leak_result = %b (expect 1010)", leak_result);
    $display("degen_result= %b", degen_result);
    chk("tap0 no leak",  leak_result[0] === 1'b0);
    chk("tap1 leak",     leak_result[1] === 1'b1);
    chk("tap2 no leak",  leak_result[2] === 1'b0);
    chk("tap3 leak",     leak_result[3] === 1'b1);
    chk("tap wrapped to 0", tap_id === 0);
    chk("degen all 0",   degen_result === 4'b0000);
    chk("report_cycle pulsed after full round", r3 === 1'b1);
    chk("no report mid-round", (r0 === 1'b0) && (r1 === 1'b0) && (r2 === 1'b0));

    if (errors == 0) $display("=== ALL TESTS PASSED (#6a probe router) ===");
    else             $display("=== %0d FAILURES ===", errors);
    $finish;
  end

  initial begin
    #12000000;   // generous for 4 taps x 8192 samples
    $display("FAIL: timeout");
    $finish;
  end

endmodule

`default_nettype wire
