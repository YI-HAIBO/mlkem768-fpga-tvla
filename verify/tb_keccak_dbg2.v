// tb_keccak_dbg2.v — minimal keccak_perm FSM debug (no shake, no VCD)
`timescale 1ns / 1ps
`default_nettype none
module tb_keccak_dbg2;
    reg clk = 0;
    always #5 clk = ~clk;

    reg rst_n = 0;
    reg start = 0;
    reg [1599:0] state_in = 1600'd0;
    wire [1599:0] state_out;
    wire done;

    keccak_perm #(.WIDTH(1600)) u_dut (
        .clk(clk), .rst_n(rst_n), .start(start),
        .state_in(state_in), .state_out(state_out), .done(done));

    // peek into DUT internals via hierarchical reference
    wire [2:0] st = u_dut.st;
    wire [4:0] rnd = u_dut.rnd;

    integer cyc;
    initial begin
        cyc = 0;
        rst_n = 0; start = 0;
        repeat (4) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);
        // pulse start high for one FULL cycle, de-assert at negedge
        start = 1;
        @(posedge clk);          // DUT samples start=1
        @(negedge clk);          // de-assert safely at negedge
        start = 0;
        // now monitor
        for (cyc = 0; cyc < 80; cyc = cyc + 1) begin
            @(posedge clk);
            $display("cyc=%0d st=%0d rnd=%0d done=%b", cyc, st, rnd, done);
            if (done) begin
                $display("DONE at cyc=%0d state_out[63:0]=%h", cyc, state_out[63:0]);
                $finish;
            end
        end
        $display("STUCK: FSM never reached DONE in 80 cycles (st=%0d rnd=%0d)", st, rnd);
        $finish;
    end
endmodule
`default_nettype wire
