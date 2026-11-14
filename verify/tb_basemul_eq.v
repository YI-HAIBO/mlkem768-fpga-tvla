`timescale 1ns / 1ps
`default_nettype none

// Equivalence TB: kyber_basemul (original, 1-cycle) vs kyber_basemul_pipe
// (systolic 6-stage). Feed both with identical random a/b coefficients,
// assert start, wait for done, compare all 256 r[] outputs bit-for-bit.
module tb_basemul_eq;

    reg clk, rst_n;
    integer i;
    integer errors, iter, k, nerr;

    // DUT 1: original
    reg  s1_start, s1_bs, s1_dn;
    reg  s1_a_load, s1_b_load;
    reg [7:0] s1_a_addr, s1_b_addr, s1_r_addr;
    reg [15:0] s1_a_data, s1_b_data;
    wire [15:0] s1_r_data;

    // DUT 2: pipelined
    reg  s2_start, s2_bs, s2_dn;
    reg  s2_a_load, s2_b_load;
    reg [7:0] s2_a_addr, s2_b_addr, s2_r_addr;
    reg [15:0] s2_a_data, s2_b_data;
    wire [15:0] s2_r_data;

    kyber_basemul #(.N(256), .Q(3329), .BW(16)) dut_old (
        .clk(clk), .rst_n(rst_n),
        .start(s1_start), .busy(s1_bs), .done(s1_dn),
        .a_load(s1_a_load), .a_addr(s1_a_addr), .a_data(s1_a_data),
        .b_load(s1_b_load), .b_addr(s1_b_addr), .b_data(s1_b_data),
        .r_addr(s1_r_addr), .r_data(s1_r_data)
    );

    kyber_basemul_pipe #(.N(256), .Q(3329), .BW(16)) dut_new (
        .clk(clk), .rst_n(rst_n),
        .start(s2_start), .busy(s2_bs), .done(s2_dn),
        .a_load(s2_a_load), .a_addr(s2_a_addr), .a_data(s2_a_data),
        .b_load(s2_b_load), .b_addr(s2_b_addr), .b_data(s2_b_data),
        .r_addr(s2_r_addr), .r_data(s2_r_data)
    );

    always #5 clk = ~clk;

    // Wait N clock edges
    task wait_clk(input integer n);
        integer c;
        begin
            for (c = 0; c < n; c = c + 1) @(posedge clk);
        end
    endtask

    integer seed;
    initial begin
        clk = 0; rst_n = 0;
        s1_start = 0; s1_a_load = 0; s1_b_load = 0; s1_a_addr = 0; s1_b_addr = 0; s1_r_addr = 0; s1_a_data = 0; s1_b_data = 0;
        s2_start = 0; s2_a_load = 0; s2_b_load = 0; s2_a_addr = 0; s2_b_addr = 0; s2_r_addr = 0; s2_a_data = 0; s2_b_data = 0;
        errors = 0;
        seed = 32'h5eed1234;

        wait_clk(2);
        rst_n = 1;
        wait_clk(2);

        for (iter = 0; iter < 24; iter = iter + 1) begin
            // Load 256 random a and b into both
            for (i = 0; i < 256; i = i + 1) begin
                s1_a_data = $random(seed) & 16'hFFFF;
                s1_b_data = $random(seed) & 16'hFFFF;
                s1_a_addr = i; s1_b_addr = i; s1_a_load = 1; s1_b_load = 1;
                s2_a_data = s1_a_data; s2_b_data = s1_b_data;
                s2_a_addr = i; s2_b_addr = i; s2_a_load = 1; s2_b_load = 1;
                @(posedge clk);
            end
            s1_a_load = 0; s1_b_load = 0; s2_a_load = 0; s2_b_load = 0;

            // Start both
            @(posedge clk);
            s1_start <= 1; s2_start <= 1;
            @(posedge clk);
            s1_start <= 0; s2_start <= 0;

            // Wait for both done (latch each one-cycle done pulse separately)
            k = 0;
            nerr = 0;
            while (((nerr & 3) != 3) && k < 400) begin
                @(posedge clk);
                #1;
                if (s1_dn) nerr = nerr | 1;
                if (s2_dn) nerr = nerr | 2;
                k = k + 1;
            end
            if ((nerr & 3) != 3) begin
                $display("[EQ] iter %0d TIMEOUT waiting done (latch=%0d old_dn=%b new_dn=%b)",
                         iter, nerr, s1_dn, s2_dn);
                errors = errors + 1;
            end else begin
                // Compare all 256 outputs
                nerr = 0;
                for (i = 0; i < 256; i = i + 1) begin
                    s1_r_addr = i; s2_r_addr = i;
                    #1;
                    if (s1_r_data !== s2_r_data) begin
                        if (nerr < 12) $display("[EQ] iter %0d r[%0d]: old=%04h new=%04h  MISMATCH", iter, i, s1_r_data, s2_r_data);
                        nerr = nerr + 1;
                    end
                end
                if (nerr > 0) begin
                    $display("[EQ] iter %0d : %0d MISMATCHES", iter, nerr);
                    errors = errors + 1;
                end else begin
                    $display("[EQ] iter %0d : PASS (256/256)", iter);
                end
            end
        end

        if (errors == 0)
            $display("=== EQUIVALENCE: ALL PASS (%0d iters) ===", 24);
        else
            $display("=== EQUIVALENCE: %0d FAILURES ===", errors);
        $finish;
    end

endmodule

`default_nettype wire
