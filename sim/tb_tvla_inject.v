// =============================================================================
// tb_tvla_inject.v -- stream pre-generated leakage samples into B3 tvla_online
// and report leak_detected.  The sample stream is produced by
// verify/tvla_inject.py (physically-motivated HW-key-register leak model).
// Hex file (via +define+FFILE) holds 4096 fixed-group then 4096 random-group
// 8-bit samples ($readmemh format).
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module tb_tvla_inject;
    localparam SAMPLE_W = 8;
    localparam N_LOG2   = 12;
    localparam N        = (1 << N_LOG2);
    localparam NSAMP    = 2 * N;

    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg sample_valid = 1'b0;
    reg [SAMPLE_W-1:0] sample = 8'd0;
    reg sample_fixed = 1'b0;
    reg batch_restart = 1'b0;

    wire batch_ready, batch_done, leak_detected, degenerate;
    wire [N_LOG2:0] cnt_fixed, cnt_random;
    wire [N_LOG2+SAMPLE_W-1:0] sum_fixed, sum_random;
    wire [N_LOG2+2*SAMPLE_W-1:0] sq_fixed, sq_random;

    tvla_online #(.SAMPLE_W(SAMPLE_W), .N_LOG2(N_LOG2)) dut (
        .clk(clk), .rst_n(rst_n),
        .sample_valid(sample_valid), .sample(sample), .sample_fixed(sample_fixed),
        .batch_restart(batch_restart),
        .batch_ready(batch_ready), .batch_done(batch_done),
        .leak_detected(leak_detected), .degenerate(degenerate),
        .cnt_fixed(cnt_fixed), .cnt_random(cnt_random),
        .sum_fixed(sum_fixed), .sum_random(sum_random),
        .sq_fixed(sq_fixed), .sq_random(sq_random)
    );

    reg [SAMPLE_W-1:0] mem [0:NSAMP-1];
    reg [255:0] fname;
    integer i;
    integer waited;

    always #5 clk = ~clk;   // 100 MHz

    initial begin
        if (!$value$plusargs("file=%s", fname)) begin
            $display("TB_INJECT: ERROR missing +file=<hex path> plusarg");
            $fatal;
        end
        $readmemh(fname, mem);
        // reset
        #10 rst_n = 1'b0;
        #30 rst_n = 1'b1;
        #20;

        // stream fixed group then random group (negedge drive per project rule)
        for (i = 0; i < NSAMP; i = i + 1) begin
            @(negedge clk);
            sample = mem[i];
            sample_fixed = (i < N) ? 1'b1 : 1'b0;
            sample_valid = 1'b1;
        end
        @(negedge clk);
        sample_valid = 1'b0;

        // wait for evaluation (5-cycle pipeline) -> batch_done pulse
        waited = 0;
        while (!batch_done && waited < 64) begin
            @(posedge clk);
            waited = waited + 1;
        end

        if (!batch_done) begin
            $display("TB_INJECT: ERROR batch_done never asserted");
            $fatal;
        end

        $display("TB_INJECT: batch_done=1 leak_detected=%b degenerate=%b cnt_fixed=%0d cnt_random=%0d",
                 leak_detected, degenerate, cnt_fixed, cnt_random);
        $display("TB_INJECT_RESULT: leak=%b deg=%b",
                 leak_detected, degenerate);
        #10 $finish;
    end

endmodule
