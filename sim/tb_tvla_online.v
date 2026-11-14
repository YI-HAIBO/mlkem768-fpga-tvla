// =============================================================================
// TB for B3 tvla_online.v (TVLA fixed-vs-random Welch T-test, online)
// -----------------------------------------------------------------------------
// Streams (golden: verify/tvla_golden.py, n = 4096/group, |t| > 4.5 = leak):
//   T1 lfsr(0x01) vs lfsr(0x5A)                t= +0.0014 -> NO leak
//   T2 const 0xFF vs lfsr(0x5A)                t=110.45   -> leak
//   T3 board: F = 2048x0 + 2048x2
//             R = 2252x0 + 1844x2              t= +4.5190 -> leak   (borderline!)
//   T4 board: R = 2251x0 + 1845x2              t= +4.4968 -> NO leak (borderline!)
//   T5 const 0x00 vs const 0x00                D = 0, d = 0 -> degenerate, no leak
//   T6 const 0x7F vs const 0x00                D = 0, d != 0 -> degenerate, leak
//   T7 two consecutive auto-restarted batches (continuous online operation)
//   T8 batch_restart mid-batch resets accumulators
//
// The bench keeps a 64-bit mirror of the accumulators and recomputes the
// integer decision with the RTL formula; every batch cross-checks the
// observation ports AND the decision. Iron rule: drive on negedges, sample
// one-cycle pulses on the negedge after the posedge that set them.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module tb_tvla_online;

  localparam SW     = 8;
  localparam NLOG2  = 12;
  localparam integer N = (1 << NLOG2);         // 4096 per group
  localparam SUMW   = NLOG2 + SW;              // 20
  localparam SQW    = NLOG2 + 2*SW;            // 28

  reg         clk, rst_n;
  reg         sample_valid, sample_fixed, batch_restart;
  reg  [SW-1:0] sample;
  wire        batch_ready, batch_done, leak_detected, degenerate;
  wire [NLOG2:0]  cnt_fixed, cnt_random;
  wire [SUMW-1:0] sum_fixed, sum_random;
  wire [SQW-1:0]  sq_fixed, sq_random;

  tvla_online #(.SAMPLE_W(SW), .N_LOG2(NLOG2)) dut(
    .clk(clk), .rst_n(rst_n),
    .sample_valid(sample_valid), .sample(sample),
    .sample_fixed(sample_fixed), .batch_restart(batch_restart),
    .batch_ready(batch_ready), .batch_done(batch_done),
    .leak_detected(leak_detected), .degenerate(degenerate),
    .cnt_fixed(cnt_fixed), .cnt_random(cnt_random),
    .sum_fixed(sum_fixed), .sum_random(sum_random),
    .sq_fixed(sq_fixed), .sq_random(sq_random)
  );

  initial begin clk = 1'b0; forever #5 clk = ~clk; end

  integer errors = 0;

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

  // ---- 8-bit Galois LFSR (taps 0xB8), mirrors tvla_golden.py --------------
  function [7:0] lfsr8;
    input [7:0] x;
    begin
      lfsr8 = (x[0]) ? ((x >> 1) ^ 8'hB8) : (x >> 1);
    end
  endfunction

  reg [7:0] lf, lr;                // LFSR states for fixed/random groups

  // ---- mirror accumulators (64-bit arithmetic) ----------------------------
  reg [SUMW-1:0] msf, msr;
  reg [SQW-1:0]  mqf, mqr;
  reg [SUMW-1:0] snap_sf, snap_sr;  // observation-port snapshot (pre-clear)
  reg [SQW-1:0]  snap_qf, snap_qr;
  reg            snap_ready;
  reg [63:0]     md, me1, me2, mqq, mDD, md2, mlhs, mrhs;
  reg            m_leak, m_degen;

  task mirror_reset;
    begin
      msf <= {SUMW{1'b0}}; msr <= {SUMW{1'b0}};
      mqf <= {SQW{1'b0}};  mqr <= {SQW{1'b0}};
    end
  endtask

  task mirror_add;
    input fixed;
    input [SW-1:0] v;
    begin
      if (fixed) begin
        msf <= msf + v;
        mqf <= mqf + v * v;
      end else begin
        msr <= msr + v;
        mqr <= mqr + v * v;
      end
    end
  endtask

  // ---- finish a batch: stop streaming, snapshot ports, wait for done ------
  task finish_batch;
    begin
      @(negedge clk);
      // BLOCKING: must take effect before the next posedge so the RTL does
      // not capture one extra trailing sample.
      sample_valid = 1'b0;
      // the observation ports are still valid now: clearing happens in
      // ST_E5, five posedges after batch_ready
      snap_ready = batch_ready;
      snap_sf = sum_fixed; snap_sr = sum_random;
      snap_qf = sq_fixed;  snap_qr = sq_random;
      if (!snap_ready) begin
        while (batch_ready !== 1'b1) @(negedge clk);
        snap_sf = sum_fixed; snap_sr = sum_random;
        snap_qf = sq_fixed;  snap_qr = sq_random;
      end
      while (batch_done !== 1'b1) @(negedge clk);
      // batch_done is high for this one negedge; accumulators already cleared
    end
  endtask

  // ---- compare RTL against the mirror --------------------------------------
  task check_mirror;
    input [255:0] name;
    begin
      // recompute the integer decision from the mirror sums
      md  = $signed({{(64-SUMW){1'b0}}, msf}) -
            $signed({{(64-SUMW){1'b0}}, msr});
      me1 = {32'd0, msf} * {32'd0, msf};
      me2 = {32'd0, msr} * {32'd0, msr};
      mqq = {32'd0, mqf} + {32'd0, mqr};
      mDD = (mqq << NLOG2) - me1 - me2;
      md2 = md * md;
      mlhs = md2 << (NLOG2 + 2);
      mrhs = 81 * mDD;
      if (mDD == 64'd0) begin
        m_degen = 1'b1;
        m_leak  = (md != 64'sd0);
      end else begin
        m_degen = 1'b0;
        m_leak  = (mlhs > mrhs);
      end
      if (leak_detected !== m_leak || degenerate !== m_degen ||
          snap_sf !== msf || snap_sr !== msr ||
          snap_qf !== mqf || snap_qr !== mqr) begin
        $display("   mirror mismatch for %0s: rtl leak=%b degen=%b sf=%h sr=%h qf=%h qr=%h | mir leak=%b degen=%b",
                 name, leak_detected, degenerate,
                 snap_sf, snap_sr, snap_qf, snap_qr, m_leak, m_degen);
        errors = errors + 1;
      end else $display("PASS %0s (mirror: sums/decision match, leak=%b)",
                        name, m_leak);
    end
  endtask

  // ---- batch drivers -------------------------------------------------------
  integer k;
  reg [7:0] fsamp, rsamp;

  // mode 0 = LFSR/LFSR, 1 = const/LFSR, 2 = borderline, 3 = const/const
  task run_batch;
    input [1:0] mode;
    input [7:0] fc, rc;              // constants for modes 1 and 3
    input [12:0] twos;               // mode 2
    begin
      mirror_reset();
      @(negedge clk);
      batch_restart <= 1'b0;
      // CRITICAL: clear stale sample/sample_fixed from the previous batch.
      // NBA would leave them at their old values until the posedge, and the
      // RTL captures on that posedge -> one stale sample injected per batch.
      sample_valid = 1'b0;
      sample_fixed  = 1'b0;
      sample       = 8'd0;
      if (mode == 3'd0 || mode == 3'd1) begin lf <= 8'h01; lr <= 8'h5A; end
      for (k = 0; k < 2*N; k = k + 1) begin
        @(negedge clk);
        // BLOCKING assignments: the RTL samples on posedge; NBA would make the
        // RTL read the *previous* cycle's value (one-cycle offset vs mirror).
        if (k == 0) sample_valid = 1'b1;
        sample_fixed  = k[0];
        // fixed-group sample
        if (mode == 3'd0) begin
          fsamp = lf; lf = lfsr8(lf);
        end else if (mode == 3'd1) begin
          fsamp = fc;
        end else if (mode == 3'd2) begin
          fsamp = (k/2 < 2048) ? 8'd0 : 8'd2;    // fixed: 2048 zeros, 2048 twos
        end else begin
          fsamp = fc;
        end
        // random-group sample
        if (mode == 3'd0 || mode == 3'd1) begin
          rsamp = lr; lr = lfsr8(lr);
        end else if (mode == 3'd2) begin
          rsamp = (k/2 < (N - twos)) ? 8'd0 : 8'd2;
        end else begin
          rsamp = rc;
        end
        sample = k[0] ? fsamp : rsamp;
        mirror_add(k[0], k[0] ? fsamp : rsamp);
      end
      finish_batch();
    end
  endtask

  // ===========================================================================
  initial begin
    sample_valid = 1'b0; sample_fixed = 1'b0; batch_restart = 1'b0;
    sample = 8'd0;
    rst_n = 1'b0;
    repeat (3) @(posedge clk);
    @(negedge clk); rst_n = 1'b1;
    $display("=== B3 tvla_online testbench start (n=%0d/group) ===", N);

    // ---- T1: lfsr vs lfsr, identical law ------------------------------------
    run_batch(3'd0, 8'd0, 8'd0, 13'd0);
    check_mirror("T1 lfsr-vs-lfsr (t=0.0014, no leak)");
    chk("T1 decision = no leak", leak_detected === 1'b0);

    // ---- T2: constant fixed group -------------------------------------------
    run_batch(3'd1, 8'hFF, 8'd0, 13'd0);
    check_mirror("T2 constFF-vs-lfsr (t=110, leak)");
    chk("T2 decision = leak", leak_detected === 1'b1);

    // ---- T3: borderline, twos = 1844, t = +4.5190 ----------------------------
    run_batch(3'd2, 8'd0, 8'd0, 13'd1844);
    check_mirror("T3 borderline 1844 (t=4.5190)");
    chk("T3 borderline ABOVE threshold -> leak", leak_detected === 1'b1);

    // ---- T4: borderline, twos = 1845, t = +4.4968 ----------------------------
    run_batch(3'd2, 8'd0, 8'd0, 13'd1845);
    check_mirror("T4 borderline 1845 (t=4.4968)");
    chk("T4 borderline BELOW threshold -> no leak", leak_detected === 1'b0);

    // ---- T5: both groups constant equal (D = 0, d = 0) ------------------------
    run_batch(3'd3, 8'd0, 8'd0, 13'd0);
    check_mirror("T5 const0-vs-const0");
    chk("T5 degenerate, no leak",
        degenerate === 1'b1 && leak_detected === 1'b0);

    // ---- T6: constant groups differ (D = 0, d != 0) --------------------------
    run_batch(3'd3, 8'h7F, 8'd0, 13'd0);
    check_mirror("T6 const7F-vs-const0");
    chk("T6 degenerate, leak",
        degenerate === 1'b1 && leak_detected === 1'b1);

    // ---- T7: continuous online operation, two auto-restarted batches ---------
    run_batch(3'd0, 8'd0, 8'd0, 13'd0);
    check_mirror("T7a continuous batch 1");
    // no restart between batches: the module must have auto-cleared
    run_batch(3'd0, 8'd0, 8'd0, 13'd0);
    check_mirror("T7b continuous batch 2");
    chk("T7 continuous operation stable (no leak)",
        leak_detected === 1'b0);

    // ---- T8: batch_restart drops a partial batch ------------------------------
    mirror_reset();
    @(negedge clk);
    batch_restart <= 1'b0;
    sample_valid = 1'b0;
    sample_fixed  = 1'b0;
    sample       = 8'd0;
    for (k = 0; k < 100; k = k + 1) begin
      @(negedge clk);
      if (k == 0) sample_valid = 1'b1;
      sample_fixed  = k[0];
      sample       = {k[7:0]};
      mirror_add(k[0], {k[7:0]});
    end
    @(negedge clk);
    batch_restart <= 1'b1;
    @(posedge clk);
    @(negedge clk);
    batch_restart <= 1'b0;
    sample_valid  = 1'b0;
    chk("T8 batch_restart clears counters and sums",
        cnt_fixed === {(NLOG2+1){1'b0}} && cnt_random === {(NLOG2+1){1'b0}} &&
        sum_fixed === {SUMW{1'b0}} && sq_fixed === {SQW{1'b0}});

    // ---------------------------------------------------------------------------
    if (errors == 0) $display("=== ALL TESTS PASSED (B3 tvla_online) ===");
    else             $display("=== %0d FAILURES ===", errors);
    $finish;
  end

  initial begin
    #2000000;
    $display("FAIL: timeout");
    $finish;
  end

endmodule

`default_nettype wire
