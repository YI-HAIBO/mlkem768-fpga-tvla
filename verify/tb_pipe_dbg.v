`timescale 1ns / 1ps
`default_nettype none
module tb_pipe_dbg;
    reg clk, rst_n;
    integer i;
    reg  s_start, s_bs, s_dn;
    reg  s_a_load, s_b_load;
    reg [7:0] s_a_addr, s_b_addr, s_r_addr;
    reg [15:0] s_a_data, s_b_data;
    wire [15:0] s_r_data;

    kyber_basemul_pipe #(.N(256), .Q(3329), .BW(16)) dut (
        .clk(clk), .rst_n(rst_n),
        .start(s_start), .busy(s_bs), .done(s_dn),
        .a_load(s_a_load), .a_addr(s_a_addr), .a_data(s_a_data),
        .b_load(s_b_load), .b_addr(s_b_addr), .b_data(s_b_data),
        .r_addr(s_r_addr), .r_data(s_r_data)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0;
        s_start = 0; s_a_load = 0; s_b_load = 0;
        s_a_addr = 0; s_b_addr = 0; s_r_addr = 0;
        s_a_data = 0; s_b_data = 0;
        #20 rst_n = 1;
        @(posedge clk);
        for (i = 0; i < 256; i = i + 1) begin
            s_a_data = (i * 16'd17) & 16'hFFFF;
            s_b_data = (i * 16'd29 + 16'd7) & 16'hFFFF;
            s_a_addr = i[7:0]; s_b_addr = i[7:0]; s_a_load = 1; s_b_load = 1;
            @(posedge clk);
        end
        s_a_load = 0; s_b_load = 0;
        $display("[dbg] loaded", $time);
        @(posedge clk);
        s_start <= 1;
        @(posedge clk);
        s_start <= 0;
        // dump state for 150 cycles
        for (i = 0; i < 150; i = i + 1) begin
            @(posedge clk);
            if (i % 5 == 0 || dut.state != 1)
                $display("[dbg] cyc=%0d st=%0d scl=%0d busy=%b done=%b r6v=%b r6wa=%0d",
                         i, dut.state, dut.scl, s_bs, s_dn, dut.r6_v, dut.r6_wa);
        end
        $finish;
    end
endmodule
`default_nettype wire
