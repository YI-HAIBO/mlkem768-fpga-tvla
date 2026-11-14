`timescale 1ns / 1ps

// =============================================================================
// Gate-level testbench for ipx_aoi_sec_board_top (netlist, no RTL hierarchy).
//
// The RTL TB (sim/tb_ipx_aoi_sec_board_top.v) references RTL internals
// (dut.st == dut.S_DONE), which do NOT exist in the synthesised netlist.
// This TB instead drives clk/rst_n/sw/btn and waits on the observable
// top-level output test_led (LED[0] = POST pass) with a cycle watchdog.
//
// DUT instance name is `dut` so scripts/vcd_to_saif.py (dut_scope="dut")
// extracts the switching activity window.  $dumpvars(0, dut) covers the whole
// ML-KEM POST (KeyGen -> Encaps -> Decaps) -- load + compute + readout.
//
// One POST only (no BTN0 re-run): the power window just needs a representative
// KEM round, and a second round would double the gate-level sim cost.
//
// POST detection uses a DETERMINISTIC polling loop (not fork/wait): a stuck
// netlist (X-propagation) must NOT be able to hang the TB silently.
// =============================================================================

module tb_gl_board;

    reg         clk;
    reg         rst_n;
    reg  [15:0] test_sw;
    reg  [4:0]  test_btn;
    wire [15:0] test_led;

    integer cyc;

    // DUT -- the synthesised netlist top (name preserved by -flatten_hierarchy none)
    ipx_aoi_sec_board_top dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .test_led (test_led),
        .test_sw  (test_sw),
        .test_btn (test_btn)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    initial cyc = 0;
    always @(posedge clk) cyc = cyc + 1;

    // internal observables (nets preserved in the netlist top)
    wire dut_busy = dut.busy;
    wire dut_done = dut.done;

    initial begin
        $dumpfile("gl_board.vcd");
        $dumpvars(0, dut);

        clk      = 1'b0;
        rst_n    = 1'b0;
        test_sw  = 16'h0000;
        test_btn = 5'b00000;

        repeat (5) @(negedge clk);
        rst_n = 1'b1;

        // Deterministic POST polling: exit when LED[0] (post_pass) asserts,
        // or when the watchdog (700k cycles) expires.
        // (X on LED[0] keeps the loop alive, so a stuck netlist -> TIMEOUT.)
        // Path A: host group select.  First half of the POST fills the
        // fixed-key group, second half fills the random-key group, so the
        // on-chip Welch engine completes at least one full evaluation and
        // its integer/DSP pipeline toggles are captured in the SAIF.
        // test_sw[15] stays 0 -> LED[0] is still post_pass (POST detection
        // above is unaffected); test_sw[1] (batch_restart) stays 0.
        test_sw[0] = 1'b1;
        while (cyc < 700000 && test_led[0] !== 1'b1) begin
            @(negedge clk);
            if (cyc > 176000) test_sw[0] = 1'b0;
            if (cyc % 50000 == 0)
                $display("GL_BOARD_POST probe cyc=%0d led=%04h busy=%b done=%b",
                         cyc, test_led, dut_busy, dut_done);
        end

        if (test_led[0] === 1'b1)
            $display("GL_BOARD_POST done  cyc=%0d led=%04h", cyc, test_led);
        else
            $display("GL_BOARD_POST TIMEOUT cyc=%0d led=%04h", cyc, test_led);

        $finish;
    end

endmodule
