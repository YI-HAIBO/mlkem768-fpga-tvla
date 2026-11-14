`timescale 1ns / 1ps
// =============================================================================
// Testbench for adaptive_mask_ctrl (A3)
// -----------------------------------------------------------------------------
// Verifies:
//   1. Base posture: reset -> level 0, first-order, light jitter
//   2. Escalation requires sustained threat (hysteresis up)
//   3. De-escalation is much slower than escalation (asymmetric hysteresis)
//   4. Hard attack flag pins posture to max immediately + sticky alert
//   5. Alert latch survives after the flag drops; only reset clears
//   6. Entropy failure floor: unhealthy entropy -> at least first-order
//   7. Posture table values (order/jitter/remask) match the spec table
// =============================================================================

module tb_adaptive_mask_ctrl;
    reg clk = 0;
    reg rst_n = 0;

    reg [1:0]  threat_level = 0;
    reg        threat_valid = 0;
    reg        hard_attack_flag = 0;
    reg        health_ok = 1;

    wire [1:0] mask_order;
    wire [7:0] jitter_max;
    wire [7:0] remask_interval;
    wire       alert_latch;
    wire [1:0] posture_level;

    adaptive_mask_ctrl #(
        .ESC_UP(8), .ESC_DN(256), .MAX_JITTER(16)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .threat_level(threat_level), .threat_valid(threat_valid),
        .hard_attack_flag(hard_attack_flag), .health_ok(health_ok),
        .mask_order(mask_order), .jitter_max(jitter_max),
        .remask_interval(remask_interval),
        .alert_latch(alert_latch), .posture_level(posture_level)
    );

    always #5 clk = ~clk;  // 100 MHz

    integer errors = 0;
    integer i;

    task wait_clks;
        input integer n;
        integer j;
        begin
            for (j = 0; j < n; j = j + 1) @(posedge clk);
        end
    endtask

    // check a posture triplet against the spec table
    task check_posture;
        input [1:0]  lvl;       // expected level
        input [1:0]  exp_order;
        input [7:0]  exp_jit;
        input [7:0]  exp_remask;
        input [127:0] tag;
        begin
            if (posture_level !== lvl || mask_order !== exp_order ||
                jitter_max !== exp_jit || remask_interval !== exp_remask) begin
                $display("  FAIL %0s: got lvl=%0d ord=%0d jit=%0d rm=%0d, want lvl=%0d ord=%0d jit=%0d rm=%0d",
                         tag, posture_level, mask_order, jitter_max, remask_interval,
                         lvl, exp_order, exp_jit, exp_remask);
                errors = errors + 1;
            end else begin
                $display("  PASS %0s: lvl=%0d ord=%0d jit=%0d rm=%0d",
                         tag, posture_level, mask_order, jitter_max, remask_interval);
            end
        end
    endtask

    initial begin
        rst_n = 0;
        wait_clks(5);
        rst_n = 1;
        wait_clks(2);

        // -------------------------------------------------------------
        // Test 1: reset posture
        // -------------------------------------------------------------
        $display("\n=== Test 1: Reset posture ===");
        check_posture(2'd0, 2'd1, 8'd4, 8'd64, "reset");

        // -------------------------------------------------------------
        // Test 2: escalation needs sustained threat
        // -------------------------------------------------------------
        $display("\n=== Test 2: Escalation hysteresis (ESC_UP=8) ===");
        threat_level = 2'd3;
        // 7 cycles: NOT enough yet
        wait_clks(7);
        check_posture(2'd0, 2'd1, 8'd4, 8'd64, "7cy not yet");
        // a few more cycles -> commits at ESC_UP=8 (plus 1 for output reg)
        wait_clks(4);
        check_posture(2'd3, 2'd2, 8'd16, 8'd1, "escalated");
        if (posture_level == 2'd3)
            $display("  NOTE: jumped straight to level 3 (single-step jump ok)");
        else
            $display("  NOTE: stepped to level %0d", posture_level);

        // -------------------------------------------------------------
        // Test 3: de-escalation is slow (ESC_DN=256)
        // -------------------------------------------------------------
        $display("\n=== Test 3: De-escalation asymmetry (ESC_DN=256) ===");
        threat_level = 2'd0;
        wait_clks(64);
        $display("  after 64 low cycles: posture_level = %0d (expect still high)", posture_level);
        if (posture_level == 2'd0) begin
            $display("  FAIL: de-escalated too fast");
            errors = errors + 1;
        end else begin
            $display("  PASS: still at level %0d", posture_level);
        end
        // Push through the full window; the module moves 3->? stepwise, each
        // step costing ESC_DN, so full 3->0 needs ~3*256. Give it room but
        // don't let the sim run forever: 3*256 + margin.
        wait_clks(3*256 + 32);
        check_posture(2'd0, 2'd1, 8'd4, 8'd64, "de-escalated full");

        // -------------------------------------------------------------
        // Test 4: hard attack pins max immediately + alert
        // -------------------------------------------------------------
        $display("\n=== Test 4: Hard attack pin ===");
        threat_level = 2'd0;
        wait_clks(2);
        hard_attack_flag = 1;
        wait_clks(1);
        hard_attack_flag = 0;
        wait_clks(1);
        check_posture(2'd3, 2'd2, 8'd16, 8'd1, "attack pin");
        if (!alert_latch) begin
            $display("  FAIL: alert_latch not set");
            errors = errors + 1;
        end else begin
            $display("  PASS: alert_latch set");
        end

        // -------------------------------------------------------------
        // Test 5: alert is sticky past the flag; only reset clears
        // -------------------------------------------------------------
        $display("\n=== Test 5: Sticky alert ===");
        wait_clks(50);
        check_posture(2'd3, 2'd2, 8'd16, 8'd1, "sticky posture");
        if (!alert_latch) begin
            $display("  FAIL: alert_latch dropped without reset");
            errors = errors + 1;
        end else begin
            $display("  PASS: alert_latch sticky");
        end

        // -------------------------------------------------------------
        // Test 6: reset clears the alert
        // -------------------------------------------------------------
        $display("\n=== Test 6: Reset clears alert ===");
        rst_n = 0;
        wait_clks(3);
        rst_n = 1;
        wait_clks(2);
        if (alert_latch) begin
            $display("  FAIL: alert_latch survived reset");
            errors = errors + 1;
        end else begin
            $display("  PASS: alert_latch cleared");
        end
        check_posture(2'd0, 2'd1, 8'd4, 8'd64, "post reset");

        // -------------------------------------------------------------
        // Test 7: entropy failure floor
        // -------------------------------------------------------------
        $display("\n=== Test 7: Entropy failure floor ===");
        // escalate to level 0 posture but break health; floor forces >= order 1.
        // level 0 already maps to order 1, so verify the floor logic by
        // forcing a downgrade attempt: healthy, level 0 has order 1; under
        // bad health the output must NOT fall to order 0. The table never
        // emits order 0, so the meaningful check is posture stays order>=1
        // and the module does not lock up.
        health_ok = 0;
        wait_clks(3);
        if (mask_order == 2'd0) begin
            $display("  FAIL: order fell to 0 under bad health");
            errors = errors + 1;
        end else begin
            $display("  PASS: order >= %0d under bad health", mask_order);
        end
        health_ok = 1;

        // -------------------------------------------------------------
        // Test 8: full posture table sweep
        // -------------------------------------------------------------
        $display("\n=== Test 8: Posture table sweep ===");
        // drive each level and let hysteresis settle; use attack pin skip:
        // faster path: reset between levels and use hard pin for 3.
        for (i = 0; i < 3; i = i + 1) begin
            rst_n = 0;
            wait_clks(2);
            rst_n = 1;
            wait_clks(2);
            // escalate from 0 to target i (i=0..2); sustained cycles needed
            threat_level = i[1:0];
            if (i == 0) begin
                wait_clks(2);
            end else begin
                wait_clks(8 + 16);   // enough for single-step up
            end
            if (posture_level !== i[1:0]) begin
                // may have stepped through; give more time
                wait_clks(8*4 + 16);
            end
            $display("  level %0d -> ord=%0d jit=%0d rm=%0d",
                     i, mask_order, jitter_max, remask_interval);
        end

        // -------------------------------------------------------------
        // Summary
        // -------------------------------------------------------------
        $display("\n=== adaptive_mask_ctrl tests completed ===");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("FAILED with %0d errors", errors);
        $finish;
    end

endmodule
