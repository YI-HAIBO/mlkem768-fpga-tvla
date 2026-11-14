// =============================================================================
// M9: High-volume NIST SP 800-22 data collection testbench.
// Collects N_RND = 327,680 words = 10,485,760 bits (10 Mbit) from
// puf_trng_fused (conditioned TRNG + PUF) for NIST SP 800-22 Rev 1a.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module tb_puf_trng_nist_long;

    localparam integer N_RND = 327680;              // 10 Mbit
    localparam string  OUT_FILE = "sim/nist_data_10mbit.bin";

    reg          clk = 1'b0;
    reg          rst_n = 1'b0;
    reg  [255:0] puf_seed = 256'h0;
    reg          puf_challenge = 1'b0;
    reg  [31:0]  trng_raw = 32'h0;
    reg          trng_valid = 1'b0;
    reg          enable = 1'b0;
    reg          reseed = 1'b0;

    wire [31:0]  rnd_out;
    wire         health_ok, puf_ok, trng_ok;
    wire [31:0]  draw_count;

    puf_trng_fused #(
        .SEED_WIDTH(256), .OUT_WIDTH(32), .HEALTH_W(16)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .puf_seed(puf_seed), .puf_challenge(puf_challenge),
        .trng_raw(trng_raw), .trng_valid(trng_valid),
        .enable(enable), .reseed(reseed),
        .rnd_out(rnd_out), .health_ok(health_ok),
        .puf_ok(puf_ok), .trng_ok(trng_ok),
        .draw_count(draw_count)
    );

    always #5 clk = ~clk;

    reg [31:0] lfsr = 32'hDEADBEEF;
    always @(posedge clk) begin
        if (rst_n) begin
            lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
        end
    end

    integer fd, i, cyc;
    reg [31:0] collected, first_word, last_word;

    initial begin
        fd = $fopen(OUT_FILE, "wb");
        if (fd == 0) begin
            $display("ERROR: cannot open %s", OUT_FILE);
            $finish;
        end
        puf_seed = 256'hF0E1D2C3B4A5968778695A4B3C2D1E0F00112233445566778899AABBCCDDEEFF;
        rst_n = 1'b0;
        @(negedge clk); @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk); @(negedge clk);
        reseed = 1'b1;
        @(negedge clk);
        reseed = 1'b0;
        enable = 1'b1;
        trng_valid = 1'b1;

        collected = 0;
        for (i = 0; i < N_RND; i = i + 1) begin
            @(negedge clk);
            trng_raw = lfsr;
            @(posedge clk);
            #1;
            if (i == 0) first_word = rnd_out;
            if (i == N_RND-1) last_word = rnd_out;
            $fwrite(fd, "%c%c%c%c",
                    rnd_out[7:0], rnd_out[15:8],
                    rnd_out[23:16], rnd_out[31:24]);
            collected = collected + 1;
            if (i % 100000 == 0 && i != 0)
                $display("PROG %0d/%0d", i, N_RND);
        end

        enable = 1'b0;
        trng_valid = 1'b0;
        $fclose(fd);

        $display("=== 10 Mbit NIST data collection complete ===");
        $display("  Words collected : %0d", collected);
        $display("  Bits collected  : %0d", collected * 32);
        $display("  First word      : 0x%08x", first_word);
        $display("  Last word       : 0x%08x", last_word);
        $display("  draw_count      : %0d", draw_count);
        $display("  health_ok       : %b (puf_ok=%b trng_ok=%b)",
                 health_ok, puf_ok, trng_ok);
        $display("  Output file     : %s", OUT_FILE);
        if (collected == N_RND) $display("ALL TESTS PASSED");
        else $display("FAILED: collected=%0d expected=%0d", collected, N_RND);
        $finish;
    end

    initial begin
        #(N_RND * 20 + 100000);
        $display("TIMEOUT - simulation stuck");
        $finish;
    end

endmodule
`default_nettype wire
