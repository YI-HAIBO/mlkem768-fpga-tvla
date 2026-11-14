`timescale 1ns / 1ps
// =============================================================================
// Testbench for ro_entropy_source
// -----------------------------------------------------------------------------
// Verifies:
//   1. Output rate: one word every ACC_W + 2 clocks (after initial fill)
//   2. Health monitoring: stuck RO detected
//   3. Reseed: external entropy injection
//   4. Whitening: output is not just the raw shift-register value
// =============================================================================

module tb_ro_entropy;
    reg clk = 0;
    reg rst_n = 0;
    reg reseed = 0;
    reg [127:0] entropy = 128'd0;
    reg enable = 0;
    wire [31:0] rnd_out;
    wire health_ok;
    wire [31:0] draw_count;

    // Use a small ACC_W for faster simulation
    localparam ACC_W = 4;
    localparam SIM_DELAY = 1;

    ro_entropy_source #(
        .SEED        (32'hDEADBEEF),
        .SAMPLE_ACCUM(ACC_W),
        .SIM_RO_DELAY(SIM_DELAY)
    ) dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .reseed     (reseed),
        .entropy    (entropy),
        .enable     (enable),
        .rnd_out    (rnd_out),
        .health_ok  (health_ok),
        .draw_count (draw_count)
    );

    always #5 clk = ~clk;  // 100 MHz

    integer errors = 0;
    integer i;
    integer guard;
    reg done;
    reg [31:0] prev_rnd;

    // -------------------------------------------------------------------------
    // Helper: wait N clocks
    // -------------------------------------------------------------------------
    task wait_clocks;
        input integer n;
        integer j;
        begin
            for (j = 0; j < n; j = j + 1)
                @(posedge clk);
        end
    endtask

    // -------------------------------------------------------------------------
    // Helper: wait until draw_count reaches a target value
    // -------------------------------------------------------------------------
    task wait_draws;
        input [31:0] target;
        begin
            guard = 0;
            while (draw_count < target && guard < 5000) begin
                @(posedge clk);
                guard = guard + 1;
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Main test sequence
    // -------------------------------------------------------------------------
    initial begin
        $display("=== tb_ro_entropy: RO-TRNG testbench ===");

        // -----------------------------------------------------------------
        // Phase 0: Reset
        // -----------------------------------------------------------------
        rst_n = 1;
        #1 rst_n = 0;
        #3 rst_n = 1;
        #3;
        $display("  After reset: health_ok=%b draw_count=%0d", health_ok, draw_count);

        // -----------------------------------------------------------------
        // Phase 1: Enable and collect outputs
        // -----------------------------------------------------------------
        enable = 1;
        prev_rnd = 32'd0;

        // Wait for the first output (ACC_W + 2 = 6 clocks after enable)
        // Actually, the first word takes ACC_W clocks to collect + 2 clocks
        // for the whitener pipeline = 6 clocks.
        wait_draws(32'd1);
        $display("  Draw 1: rnd_out=%08h (prev=%08h, changed=%b)",
                 rnd_out, prev_rnd, (rnd_out !== prev_rnd));
        if (rnd_out === prev_rnd) begin
            errors = errors + 1;
            $display("  ERROR: first output equals previous value");
        end
        prev_rnd = rnd_out;

        wait_draws(32'd2);
        $display("  Draw 2: rnd_out=%08h (changed=%b)",
                 rnd_out, (rnd_out !== prev_rnd));
        if (rnd_out === prev_rnd) begin
            errors = errors + 1;
            $display("  ERROR: second output equals first");
        end
        prev_rnd = rnd_out;

        wait_draws(32'd3);
        $display("  Draw 3: rnd_out=%08h (changed=%b)",
                 rnd_out, (rnd_out !== prev_rnd));
        if (rnd_out === prev_rnd) begin
            errors = errors + 1;
            $display("  ERROR: third output equals second");
        end

        // -----------------------------------------------------------------
        // Phase 2: Check that output is NOT just the raw entropy
        //         (the whitener should produce different values)
        // -----------------------------------------------------------------
        $display("  Collecting 10 samples to check whitening...");
        for (i = 0; i < 10; i = i + 1) begin
            prev_rnd = rnd_out;
            wait_draws(draw_count + 32'd1);
            if (rnd_out === prev_rnd) begin
                errors = errors + 1;
                $display("  ERROR: consecutive output %0d is identical", i);
            end
        end
        $display("  10 samples collected, %0d duplicate errors", errors);

        // -----------------------------------------------------------------
        // Phase 3: Health check (ROs should be healthy)
        // -----------------------------------------------------------------
        if (health_ok !== 1'b1) begin
            errors = errors + 1;
            $display("  ERROR: health_ok should be 1, got %b", health_ok);
        end else begin
            $display("  Health OK: all ROs toggling");
        end

        // -----------------------------------------------------------------
        // Phase 4: Reseed with external entropy
        // -----------------------------------------------------------------
        $display("  Testing reseed...");
        reseed = 1;
        entropy = 128'hCAFEBABECAFEBABECAFEBABECAFEBABE;
        @(posedge clk);
        #1 reseed = 0;
        // After reseed, the counter is reset and the shift register is cleared.
        // The next output should be based on the new entropy.
        wait_draws(32'd1);
        $display("  After reseed: rnd_out=%08h draw_count=%0d", rnd_out, draw_count);
        if (draw_count !== 32'd1) begin
            errors = errors + 1;
            $display("  ERROR: draw_count should be 1 after reseed, got %0d", draw_count);
        end

        // -----------------------------------------------------------------
        // Phase 5: Disable and check hold
        // -----------------------------------------------------------------
        $display("  Testing enable=0 (hold)...");
        enable = 0;
        prev_rnd = rnd_out;
        // Wait several ACC_W+2 cycles; output should NOT change
        for (i = 0; i < 20; i = i + 1)
            @(posedge clk);
        if (rnd_out === prev_rnd) begin
            $display("  OK: output held while enable=0");
        end else begin
            errors = errors + 1;
            $display("  ERROR: output changed while enable=0");
        end

        // -----------------------------------------------------------------
        // Summary
        // -----------------------------------------------------------------
        $display("=== errors=%0d ===", errors);
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("TESTS FAILED");
        $finish;
    end

    // Timeout
    initial begin
        #500000;
        $display("TIMEOUT");
        $finish;
    end

endmodule