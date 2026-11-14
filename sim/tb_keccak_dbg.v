`timescale 1ns / 1ps
module tb_keccak_dbg;
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst_n = 0;
    reg start = 0;
    reg [1599:0] state_in;
    wire [1599:0] state_out;
    wire done;
    keccak_perm #(.WIDTH(1600)) u (
        .clk(clk),.rst_n(rst_n),.start(start),.state_in(state_in),.state_out(state_out),.done(done));

    integer i;
    initial begin
        rst_n = 0; repeat(5) @(posedge clk); rst_n = 1; repeat(2) @(posedge clk);
        state_in = 1600'd0;
        start = 1; @(posedge clk); start = 0;
        begin: w integer g; g=0; while (!done && g<100000) begin @(posedge clk); g=g+1; end end
        $display("permute(0) state_out bytes[0:7] = %02X %02X %02X %02X %02X %02X %02X %02X",
            state_out[7:0], state_out[15:8], state_out[23:16], state_out[31:24],
            state_out[39:32], state_out[47:40], state_out[55:48], state_out[63:56]);
        $display("  (reference expect: 29 0A BE 21 09 88 BC E3)");
        $finish;
    end
endmodule
