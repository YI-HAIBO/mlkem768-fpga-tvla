`timescale 1ns / 1ps
// Debug testbench: dumps forward NTT and round-trip to a file for diffing.
module tb_kyber_ntt_debug;
    reg clk = 0;
    reg rst_n = 0;
    reg start = 0;
    reg inverse = 0;
    wire busy;
    wire done;

    reg load = 0;
    reg [7:0] load_addr = 0;
    reg [15:0] load_data = 0;
    reg [7:0] read_addr = 0;
    wire [15:0] read_data;

    kyber_ntt dut (.clk(clk), .rst_n(rst_n),
        .start(start), .inverse(inverse),
        .busy(busy), .done(done),
        .load(load), .load_addr(load_addr), .load_data(load_data),
        .read_addr(read_addr), .read_data(read_data));

    always #5 clk = ~clk;

    integer k;
    reg [15:0] test_input [0:255];
    reg [15:0] fwd [0:255];

    task wait_done;
        integer guard;
        begin
            guard = 0;
            while (!done && guard < 100000) begin @(posedge clk); guard = guard + 1; end
        end
    endtask

    task load_poly;
        begin
            for (k = 0; k < 256; k = k + 1) begin
                load_addr = k[7:0]; load_data = test_input[k]; load = 1; @(posedge clk);
            end
            load = 0;
        end
    endtask

    task read_poly;
        begin
            for (k = 0; k < 256; k = k + 1) begin
                read_addr = k[7:0]; @(posedge clk); fwd[k] = read_data;
            end
        end
    endtask

    integer fd;
    integer i;

    initial begin
        fd = $fopen("ntt_debug_dump.txt", "w");
        rst_n = 0; repeat (5) @(posedge clk); rst_n = 1; repeat (2) @(posedge clk);

        // Input f[i] = i (Test 2 input) and f[i] = i+1 (Test 4 input)
        // Do f[i] = i  (round trip)
        for (i = 0; i < 256; i = i + 1) test_input[i] = i[15:0];
        load_poly();
        start = 1; inverse = 0; @(posedge clk); start = 0;
        wait_done();
        read_poly();
        $fdisplay(fd, "FORWARD f[i]=i:");
        for (i = 0; i < 256; i = i + 1)
            $fdisplay(fd, "%0d %0d", i, $signed(fwd[i]));

        // Inverse on fwd
        for (i = 0; i < 256; i = i + 1) test_input[i] = fwd[i];
        load_poly();
        start = 1; inverse = 1; @(posedge clk); start = 0;
        wait_done();
        read_poly();
        $fdisplay(fd, "ROUNDTRIP invntt(ntt(f))  (expect f[i]*2285 mod 3329):");
        for (i = 0; i < 256; i = i + 1) begin
            reg [31:0] exp; reg [31:0] got_mod;
            exp = (i[15:0] * 2285) % 3329;
            got_mod = ($signed(fwd[i]) % 3329 + 3329) % 3329;
            $fdisplay(fd, "%0d %0d %0d %0s", i, $signed(fwd[i]), exp,
                      ((got_mod == exp) ? "OK" : "BAD"));
        end

        // Also dump forward of f[i] = i+1
        for (i = 0; i < 256; i = i + 1) test_input[i] = (i+1) & 16'hFFFF;
        load_poly();
        start = 1; inverse = 0; @(posedge clk); start = 0;
        wait_done();
        read_poly();
        $fdisplay(fd, "FORWARD f[i]=i+1:");
        for (i = 0; i < 256; i = i + 1)
            $fdisplay(fd, "%0d %0d", i, $signed(fwd[i]));

        $fclose(fd);
        $display("DEBUG dump written to ntt_debug_dump.txt");
        $finish;
    end
endmodule
