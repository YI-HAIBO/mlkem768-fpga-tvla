`timescale 1ns / 1ps
// =============================================================================
// Testbench: SHAKE-128 (RATE=168) / SHAKE-256 (RATE=136) vs Python hashlib
// Fixed golden files: sim/<tag>_msg.hex, sim/<tag>_out.hex
// =============================================================================
module tb_shake;
    reg clk = 0;
    always #5 clk = ~clk;

    reg rst_n = 0;
    integer errors;
    integer i, k;

    // ---------------- SHAKE-256 (RATE=136) ----------------
    reg s256_start=0; reg [15:0] s256_msg_len=0, s256_out_len=0;
    reg s256_wr=0; reg [15:0] s256_waddr=0; reg [7:0] s256_wdata=0;
    reg [15:0] s256_raddr=0; wire [7:0] s256_rdata;
    reg s256_done;
    shake #(.RATE(136),.MAX_IN(256),.MAX_OUT(512)) u256 (
        .clk(clk),.rst_n(rst_n),.start(s256_start),.msg_len(s256_msg_len),.out_len(s256_out_len),
        .wr_en(s256_wr),.wr_addr(s256_waddr),.wr_data(s256_wdata),
        .rd_addr(s256_raddr),.rd_data(s256_rdata),.busy(),.done(s256_done));

    // ---------------- SHAKE-128 (RATE=168) ----------------
    reg s128_start=0; reg [15:0] s128_msg_len=0, s128_out_len=0;
    reg s128_wr=0; reg [15:0] s128_waddr=0; reg [7:0] s128_wdata=0;
    reg [15:0] s128_raddr=0; wire [7:0] s128_rdata;
    reg s128_done;
    shake #(.RATE(168),.MAX_IN(256),.MAX_OUT(512)) u128 (
        .clk(clk),.rst_n(rst_n),.start(s128_start),.msg_len(s128_msg_len),.out_len(s128_out_len),
        .wr_en(s128_wr),.wr_addr(s128_waddr),.wr_data(s128_wdata),
        .rd_addr(s128_raddr),.rd_data(s128_rdata),.busy(),.done(s128_done));

    reg [7:0] g_msg  [0:255];
    reg [7:0] g_out  [0:511];

    task run_s256;
        input [8*8-1:0] tag;
        input [15:0] mlen;
        input [15:0] olen;
        integer g;
        begin
            s256_msg_len = mlen; s256_out_len = olen;
            for (i=0;i<mlen;i=i+1) begin s256_waddr=i[15:0]; s256_wdata=g_msg[i]; s256_wr=1; @(posedge clk); end
            s256_wr=0;
            s256_start=1; @(posedge clk); s256_start=0;
            g=0; while (!s256_done && g<100000) begin @(posedge clk); g=g+1; end
            if (g>=100000) begin $display("TIMEOUT s256 %s", tag); errors=errors+1; end
            for (i=0;i<olen;i=i+1) begin
                s256_raddr=i[15:0]; @(posedge clk);
                if (s256_rdata != g_out[i]) begin
                    if (errors<8) $display("S256 %s [%0d] got %02X exp %02X", tag, i, s256_rdata, g_out[i]);
                    errors=errors+1;
                end
            end
        end
    endtask

    task run_s128;
        input [8*8-1:0] tag;
        input [15:0] mlen;
        input [15:0] olen;
        integer g;
        begin
            s128_msg_len = mlen; s128_out_len = olen;
            for (i=0;i<mlen;i=i+1) begin s128_waddr=i[15:0]; s128_wdata=g_msg[i]; s128_wr=1; @(posedge clk); end
            s128_wr=0;
            s128_start=1; @(posedge clk); s128_start=0;
            g=0; while (!s128_done && g<100000) begin @(posedge clk); g=g+1; end
            if (g>=100000) begin $display("TIMEOUT s128 %s", tag); errors=errors+1; end
            for (i=0;i<olen;i=i+1) begin
                s128_raddr=i[15:0]; @(posedge clk);
                if (s128_rdata != g_out[i]) begin
                    if (errors<8) $display("S128 %s [%0d] got %02X exp %02X", tag, i, s128_rdata, g_out[i]);
                    errors=errors+1;
                end
            end
        end
    endtask

    initial begin
        errors = 0;
        rst_n = 0; repeat(5) @(posedge clk); rst_n = 1; repeat(2) @(posedge clk);
        $display("=== SHAKE verification ===");

        // SHAKE-256 cases
        $readmemh("sim/s256a_msg.hex", g_msg); $readmemh("sim/s256a_out.hex", g_out); run_s256("s256a", 16'd0,  16'd32);
        $readmemh("sim/s256b_msg.hex", g_msg); $readmemh("sim/s256b_out.hex", g_out); run_s256("s256b", 16'd3,  16'd64);
        $readmemh("sim/s256c_msg.hex", g_msg); $readmemh("sim/s256c_out.hex", g_out); run_s256("s256c", 16'd200, 16'd128);
        $readmemh("sim/s256d_msg.hex", g_msg); $readmemh("sim/s256d_out.hex", g_out); run_s256("s256d", 16'd64, 16'd256);
        // SHAKE-128 cases
        $readmemh("sim/s128a_msg.hex", g_msg); $readmemh("sim/s128a_out.hex", g_out); run_s128("s128a", 16'd0,  16'd32);
        $readmemh("sim/s128b_msg.hex", g_msg); $readmemh("sim/s128b_out.hex", g_out); run_s128("s128b", 16'd3,  16'd64);
        $readmemh("sim/s128c_msg.hex", g_msg); $readmemh("sim/s128c_out.hex", g_out); run_s128("s128c", 16'd200, 16'd168);
        $readmemh("sim/s128d_msg.hex", g_msg); $readmemh("sim/s128d_out.hex", g_out); run_s128("s128d", 16'd80, 16'd256);

        if (errors==0) $display("ALL SHAKE TESTS PASSED");
        else $display("TOTAL SHAKE ERRORS: %0d", errors);
        $finish;
    end
endmodule
