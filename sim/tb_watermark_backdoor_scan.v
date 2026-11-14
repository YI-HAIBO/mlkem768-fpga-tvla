`timescale 1ns / 1ps
// =============================================================================
// Testbench for watermark_backdoor_scan (A5)
// -----------------------------------------------------------------------------
//   T1 clean model    : exact watermark + uniform trigger stream -> 00
//   T2 watermark fail : 4 flipped carriers                      -> 01
//   T3 backdoor       : trigger mass in one bucket              -> 10
//   T4 both           : flipped watermark + concentrated trigger-> 11
//   T5 trigger replay : identical sample repeated 32x           -> 10
//   T6 pulse behavior : scan_done one-cycle pulse, busy/release
// =============================================================================

module tb_watermark_backdoor_scan;
    reg clk = 0;
    reg rst_n = 0;
    always #5 clk = ~clk;

    reg         scan_start = 0;
    reg [127:0] expected_key = 0;
    reg         wscan_valid = 0;
    reg         wscan_bit = 0;
    reg         trig_valid = 0;
    reg [31:0]  trig_sample = 0;

    wire        scan_busy, scan_done;
    wire [127:0] wm_detected;
    wire [7:0]  wm_mismatch_count;
    wire        watermark_ok;
    wire [31:0] hist_max_count, hist_min_count, repeat_top_count;
    wire        backdoor_suspect;
    wire [1:0]  joint_verdict;

    watermark_backdoor_scan #(
      .WM_WIDTH(128), .NBITS(4), .TOLERANCE(0),
      .RATIO_THRESH(8), .REPEAT_LIMIT(16), .SCAN_IDLE_MIN(64)
    ) dut (
      .clk(clk), .rst_n(rst_n),
      .scan_start(scan_start), .expected_key(expected_key),
      .scan_busy(scan_busy), .scan_done(scan_done),
      .wscan_valid(wscan_valid), .wscan_bit(wscan_bit),
      .trig_valid(trig_valid), .trig_sample(trig_sample),
      .wm_detected(wm_detected), .wm_mismatch_count(wm_mismatch_count),
      .watermark_ok(watermark_ok),
      .hist_max_count(hist_max_count), .hist_min_count(hist_min_count),
      .repeat_top_count(repeat_top_count), .backdoor_suspect(backdoor_suspect),
      .joint_verdict(joint_verdict)
    );

    integer errors = 0;
    integer i;

    task wait_clks;
        input integer n;
        integer j;
        begin
            for (j = 0; j < n; j = j + 1) @(posedge clk);
        end
    endtask

    // stream the 128 watermark carrier bits; bit i of key unless flipped
    task stream_wm;
        input [127:0] key;
        input integer flips;      // number of carriers to flip (from the top)
        integer b;
        begin
            for (b = 0; b < 128; b = b + 1) begin
                @(negedge clk);
                wscan_valid = 1;
                wscan_bit = (b < flips) ? ~key[b] : key[b];
                @(posedge clk);
            end
            @(negedge clk);
            wscan_valid = 0;
        end
    endtask

    // stream N trigger samples with a given pattern
    //   mode 0: uniform pseudo-random (benign)
    //   mode 1: all in bucket 5 (concentrated)
    //   mode 2: same value repeated (replay)
    task stream_trig;
        input integer n;
        input integer mode;
        integer b;
        begin
            for (b = 0; b < n; b = b + 1) begin
                @(negedge clk);
                trig_valid = 1;
                case (mode)
                  0: trig_sample = (b * 7919) + 13;      // pseudo-random-ish
                  1: trig_sample = 32'h0000_0005;       // all land in bucket 5
                  2: trig_sample = 32'hDEAD_BEEF;       // identical
                  default: trig_sample = b;
                endcase
                @(posedge clk);
            end
            @(negedge clk);
            trig_valid = 0;
        end
    endtask

    task run_audit;
        input [127:0] key;
        input integer wm_flips;
        input integer trig_n;
        input integer trig_mode;
        begin
            @(negedge clk);
            scan_start = 1;
            expected_key = key;
            @(posedge clk);
            @(negedge clk);
            scan_start = 0;
            // watermark stream
            stream_wm(key, wm_flips);
            // trigger stream
            stream_trig(trig_n, trig_mode);
            // wait idle window + eval + report
            wait (scan_done);
            @(posedge clk);
        end
    endtask

    task check;
        input [1:0] exp_verdict;
        input [127:0] tag;
        begin
            if (joint_verdict !== exp_verdict) begin
                $display("  FAIL %s: verdict=%b expected=%b", tag, joint_verdict, exp_verdict);
                errors = errors + 1;
            end else begin
                $display("  PASS %s: verdict=%b  wm_mismatch=%0d  max/min=%0d/%0d  repeat=%0d",
                         tag, joint_verdict, wm_mismatch_count,
                         hist_max_count, hist_min_count, repeat_top_count);
            end
        end
    endtask

    initial begin
        rst_n = 0;
        wait_clks(5);
        rst_n = 1;
        wait_clks(2);

        ////////////////////////////////////////////////////////////////
        $display("\n=== T1: Clean model ===");
        run_audit(128'hF0E1D2C3B4A5968778695A4B3C2D1E0F, 0, 256, 0);
        check(2'b00, "clean");

        ////////////////////////////////////////////////////////////////
        $display("\n=== T2: Watermark mismatch (4 flipped carriers) ===");
        run_audit(128'hF0E1D2C3B4A5968778695A4B3C2D1E0F, 4, 256, 0);
        check(2'b01, "wm-fail");

        ////////////////////////////////////////////////////////////////
        $display("\n=== T3: Backdoor trigger concentration ===");
        run_audit(128'hF0E1D2C3B4A5968778695A4B3C2D1E0F, 0, 256, 1);
        check(2'b10, "backdoor");

        ////////////////////////////////////////////////////////////////
        $display("\n=== T4: Both watermark fail + trigger ===");
        run_audit(128'hF0E1D2C3B4A5968778695A4B3C2D1E0F, 3, 256, 1);
        check(2'b11, "both");

        ////////////////////////////////////////////////////////////////
        $display("\n=== T5: Trigger-key replay (32 identical samples) ===");
        run_audit(128'hF0E1D2C3B4A5968778695A4B3C2D1E0F, 0, 48, 2);
        check(2'b10, "replay");

        ////////////////////////////////////////////////////////////////
        $display("\n=== T6: scan_done is a one-cycle pulse ===");
        @(negedge clk);
        scan_start = 1;
        expected_key = 128'h0;
        @(posedge clk);
        @(negedge clk);
        scan_start = 0;
        stream_wm(128'h0, 0);
        stream_trig(32, 0);
        // observe done pulse
        begin : pulse_check
            reg seen;
            seen = 0;
            // after idle window, scan_done must pulse exactly once
            wait (scan_done);
            seen = 1;
            // scan_done is high for exactly one clock period; sample it on
            // the next negedge (post-NBA read at posedge would see stale 1)
            @(posedge clk);
            @(negedge clk);
            if (scan_done !== 1'b0) begin
                $display("  FAIL: scan_done did not deassert after one cycle");
                errors = errors + 1;
            end else begin
                $display("  PASS: scan_done one-cycle pulse");
            end
            if (scan_busy !== 1'b0) begin
                $display("  FAIL: scan_busy did not release");
                errors = errors + 1;
            end else
                $display("  PASS: scan_busy released");
        end

        ////////////////////////////////////////////////////////////////
        $display("\n=== watermark_backdoor_scan tests completed ===");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("FAILED with %0d errors", errors);
        $finish;
    end

    initial begin
        #(20000 * 10);
        $display("\nTIMEOUT — simulation stuck");
        $finish;
    end

endmodule
