`timescale 1ns / 1ps
`default_nettype none

// =============================================================================
// tb_kyber_proxy.v -- dump the on-chip 6-bit Hamming-weight power proxy that the
// tvla_online engine would consume, directly from kyber_kem output buses.
//
// The proxy logic is copied verbatim from ipx_aoi_sec_board_top.v:
//   sc_mon_byte = ss_valid ? ss_data : ct_valid ? ct_data : pk_valid ? pk_data : 0
//   sc_hw       = popcount(sc_mon_byte)
//   tvla_sample = {2'b0, sc_hw}            (6-bit, matches SAMPLE_W=6)
//
// Two groups are produced:
//   * FIXED-secret group  -> proxy_fixed.txt  (one fixed seed, repeated runs)
//   * RANDOM-secret group -> proxy_rand.txt   (M random seeds, concatenated)
//
// proxy_rand.txt is ALSO the on-device proxy stream used for the autocorrelation
// / effective-sample-size analysis (Gap-to-Q1 item G6). proxy_fixed.txt vs the
// first 4096 samples of proxy_rand.txt form the unprotected fixed-vs-random TVLA
// (Gap-to-Q1 item G4).
// =============================================================================

module tb_kyber_proxy;

    reg  clk, rst_n;
    reg  start, op_keygen, op_encaps;
    wire busy, done, error;

    reg  in_load;
    reg  [7:0] in_addr, in_data;

    reg  ct_load;
    reg  [15:0] ct_in_addr, ct_in_data;

    wire        pk_valid;  wire [15:0] pk_addr;  wire [15:0] pk_data;
    wire        ct_valid;  wire [15:0] ct_addr;  wire [15:0] ct_data;
    wire        ss_valid;  wire [7:0]  ss_data;

    // ---- golden fixed seed/message (for the fixed-secret group) ----
    reg [7:0] gold_d [0:31];
    reg [7:0] gold_m [0:31];
    integer   fi, fi_i, n;

    // ---- proxy logic (identical to board top) ----
    wire [7:0] sc_mon_byte =
          ss_valid ? ss_data
        : ct_valid ? ct_data
        : pk_valid ? pk_data
        : 8'h00;

    reg [3:0] sc_hw;
    integer bi;
    always @(*) begin
        sc_hw = 4'd0;
        for (bi = 0; bi < 8; bi = bi + 1)
            sc_hw = sc_hw + sc_mon_byte[bi];
    end
    wire [5:0] tvla_sample = {2'b0, sc_hw};

    // ---- dump files ----
    integer fd_f, fd_r;
    reg     run_is_fixed;

    // ---- DUT ----
    kyber_kem #(
        .K(3), .N(256), .Q(3329), .BW(16), .ETA(2),
        .DU(10), .DV(4), .R_MOD(2285),
        .SEED_B(32), .MSG_B(32), .SS_B(32)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .start(start), .op_keygen(op_keygen), .op_encaps(op_encaps),
        .busy(busy), .done(done), .error(error),
        .in_load(in_load), .in_addr(in_addr), .in_data(in_data),
        .ct_load(ct_load), .ct_in_addr(ct_in_addr), .ct_data_in(ct_in_data),
        .pk_valid(pk_valid), .pk_addr(pk_addr), .pk_data(pk_data),
        .ct_valid(ct_valid), .ct_addr(ct_addr), .ct_data(ct_data),
        .ss_valid(ss_valid), .ss_data(ss_data)
    );

    always #5 clk = ~clk;

    // capture proxy on every busy cycle into the active group file
    always @(posedge clk) begin
        if (rst_n && busy) begin
            if (run_is_fixed)
                $fwrite(fd_f, "%0d\n", tvla_sample);
            else
                $fwrite(fd_r, "%0d\n", tvla_sample);
        end
    end

    // one full KeyGen -> Encaps -> Decaps run under a given seed/message
    task run_one;
        input reg is_fixed;
        reg [7:0] sd [0:31];
        reg [7:0] sm [0:31];
        integer k;
        begin
            if (is_fixed) begin
                for (k = 0; k < 32; k = k + 1) begin
                    sd[k] = gold_d[k];
                    sm[k] = gold_m[k];
                end
            end else begin
                for (k = 0; k < 32; k = k + 1) begin
                    sd[k] = $random & 8'hFF;
                    sm[k] = $random & 8'hFF;
                end
            end

            // load seed (in_addr 0..31)
            for (k = 0; k < 32; k = k + 1) begin
                @(posedge clk);
                in_load <= 1'b1; in_addr <= k[7:0]; in_data <= sd[k];
            end
            @(posedge clk); in_load <= 1'b0;
            // load message (in_addr 32..63)
            for (k = 0; k < 32; k = k + 1) begin
                @(posedge clk);
                in_load <= 1'b1; in_addr <= k[7:0] + 8'd32; in_data <= sm[k];
            end
            @(posedge clk); in_load <= 1'b0;

            // KeyGen
            @(posedge clk); start <= 1'b1; op_keygen <= 1'b1;
            @(posedge clk); start <= 1'b0; op_keygen <= 1'b0;
            wait (done); repeat (2) @(posedge clk);

            // Encaps
            @(posedge clk); start <= 1'b1; op_encaps <= 1'b1;
            @(posedge clk); start <= 1'b0; op_encaps <= 1'b0;
            wait (done); repeat (2) @(posedge clk);

            // Decaps (self-produced ct)
            @(posedge clk); start <= 1'b1;
            @(posedge clk); start <= 1'b0;
            wait (done); repeat (2) @(posedge clk);
        end
    endtask

    integer runs;
    initial begin
        clk = 1'b0; rst_n = 1'b0;
        start = 1'b0; op_keygen = 1'b0; op_encaps = 1'b0;
        in_load = 1'b0; in_addr = 8'd0; in_data = 8'd0;
        ct_load = 1'b0; ct_in_addr = 16'd0; ct_in_data = 16'd0;
        run_is_fixed = 1'b0;

        fd_f = $fopen("proxy_fixed.txt", "w");
        fd_r = $fopen("proxy_rand.txt", "w");

        // load golden fixed seed + message
        fi = $fopen("sim/kem_d0.hex", "r");
        for (fi_i = 0; fi_i < 32; fi_i = fi_i + 1)
            n = $fscanf(fi, "%2h", gold_d[fi_i]);
        $fclose(fi);
        fi = $fopen("sim/kem_m0.hex", "r");
        for (fi_i = 0; fi_i < 32; fi_i = fi_i + 1)
            n = $fscanf(fi, "%2h", gold_m[fi_i]);
        $fclose(fi);

        repeat (5) @(posedge clk);
        rst_n <= 1'b1;
        repeat (2) @(posedge clk);

        // ---- FIXED-secret group: 3 repeated runs (same seed) -> >=4096 samples
        run_is_fixed = 1'b1;
        for (runs = 0; runs < 3; runs = runs + 1)
            run_one(1'b1);

        // ---- RANDOM-secret group: 64 distinct seeds -> long representative stream
        run_is_fixed = 1'b0;
        for (runs = 0; runs < 64; runs = runs + 1)
            run_one(1'b0);

        $fclose(fd_f);
        $fclose(fd_r);
        $display("PROXY_DUMP_DONE fixed_runs=3 random_runs=64");
        $finish;
    end

    // watchdog
    integer wd;
    always @(posedge clk) begin
        if (rst_n) begin
            wd <= wd + 1;
            if (wd > 20000000) begin
                $display("PROXY_DUMP_TIMEOUT wd=%0d", wd);
                $finish;
            end
        end
    end

endmodule

`default_nettype wire
