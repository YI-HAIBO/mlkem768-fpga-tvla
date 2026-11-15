`timescale 1ns / 1ps
`default_nettype none
module tb_pipe_min;
    reg clk, rst_n;
    integer i;
    integer errors;
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
        errors = 0;
        #20 rst_n = 1;
        @(posedge clk);
        // load 256 identical coefficients
        for (i = 0; i < 256; i = i + 1) begin
            s_a_data = $random & 16'hFFFF;
            s_b_data = $random & 16'hFFFF;
            s_a_addr = i; s_b_addr = i; s_a_load = 1; s_b_load = 1;
            @(posedge clk);
        end
        s_a_load = 0; s_b_load = 0;
        $display("[min] loaded, start", $time);
        @(posedge clk);
        s_start <= 1;
        @(posedge clk);
        s_start <= 0;
        $display("[min] start asserted, waiting done...", $time);
        // wait for done up to 300 cycles
        errors = 0;
        for (i = 0; i < 300; i = i + 1) begin
            @(posedge clk);
            if (s_dn && !errors) begin
                $display("[min] DONE at cycle %0d time %0t", i, $time);
                errors = 1;
            end
        end
        if (!errors) $display("[min] TIMEOUT waiting done");
        // read back a few
        for (i = 0; i < 8; i = i + 1) begin
            s_r_addr = i;
            #1;
            $display("[min] r[%0d]=%04h", i, s_r_data);
        end
        $finish;
    end
endmodule
`default_nettype wire
