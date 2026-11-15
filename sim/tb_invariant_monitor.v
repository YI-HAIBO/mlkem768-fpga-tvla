`timescale 1ns / 1ps
`default_nettype none

// =============================================================================
// #8c unit testbench: invariant_monitor
// -----------------------------------------------------------------------------
// Phase-scoped checks (sample the sticky violation at the END of each phase):
//   P1 idle (enable=0)              -> tracks value, no judgement  -> 0
//   P2 armed + constant             -> violation stays 0           -> 0
//   P3 armed + spurious change      -> violation latches 1 (sticky)-> 1
//   reset
//   P4 legal update (update=1)      -> new baseline accepted, then constant -> 0
//   P5 armed + spurious change      -> violation latches 1 again   -> 1
// =============================================================================

module tb_invariant_monitor;

    reg         clk, rst_n;
    reg         enable, update;
    reg  [7:0]  value;
    wire        violation;

    invariant_monitor #(.W(8)) dut (
        .clk(clk), .rst_n(rst_n),
        .enable(enable), .update(update),
        .value(value), .violation(violation)
    );

    integer errors, phase;
    reg [3:0] expected;

    task check_phase;
        input [3:0] exp;
        begin
            @(posedge clk); #1;
            $display("  P%0d @t=%0t violation=%0b (exp %0b)", phase, $time, violation, exp);
            if (violation !== exp) begin
                $display("    FAIL: P%0d", phase);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 0; rst_n = 0;
        enable = 0; update = 0; value = 8'h00;
        errors = 0;

        #100 rst_n = 1;
        #40;

        // P1: idle tracking
        phase = 1;
        value = 8'h12; enable = 0; update = 0;
        #200; check_phase(4'd0);

        // P2: armed, constant -> no violation
        phase = 2;
        enable = 1; update = 0; value = 8'h12;
        #200; check_phase(4'd0);

        // P3: spurious change -> sticky violation
        phase = 3;
        value = 8'h99;
        #200; check_phase(4'd1);

        // reset, then P4: set inputs DURING reset so that after release the
        // monitor is idle (enable=0) tracking value=0xAA -> ref_reg=0xAA,
        // then arm and hold constant -> no violation (clean re-arm)
        rst_n = 0; enable = 0; update = 0; value = 8'hAA; #60;
        rst_n = 1; #60;
        phase = 4;
        enable = 1; update = 0;                   // armed, constant 0xAA
        #200; check_phase(4'd0);

        // P5: spurious change again
        phase = 5;
        value = 8'h55;
        #200; check_phase(4'd1);

        $display("=== invariant_monitor unit test ===");
        if (errors == 0)
            $display("RESULT: INVARIANT_MONITOR UNIT PASS (all phases)");
        else
            $display("RESULT: FAILED (%0d errors)", errors);
        $finish;
    end

    always #5 clk = ~clk;

endmodule

`default_nettype wire
