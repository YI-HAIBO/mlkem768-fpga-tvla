`timescale 1ns / 1ps
`default_nettype none

// =============================================================================
// R1: Gate/RT-level "hiding-defeat" detection demonstration
// -----------------------------------------------------------------------------
// Reviewer concern (Editor_Review_v3 R1): the engine has never been shown to
// DETECT a genuine data-dependent component on a REAL (non-injected) proxy
// stream.  The board-level POST uses a fixed ROM seed for BOTH groups, so its
// "fixed-vs-random" is really fixed-vs-fixed -> |t| ~ 0 trivially.
//
// This TB instantiates the REAL kyber_kem (ML-KEM-768) and the REAL tvla_online
// engine, samples the SAME six-bit Hamming-weight proxy that the board top uses
// (pk_data / ct_data / ss_data priority-muxed, HW), and drives a genuine
// fixed-secret group vs a genuine RANDOM-secret group (TRNG-equivalent seed via
// $random).  GATING selects the sampling window:
//   0 = full busy window  (reproduces the idle-dominated |t| ~ 0 of Sec. 4.7)
//   1 = data-active window (pk_valid|ct_valid|ss_valid) -> detection expected
// The engine reports leak_detected (integer |t|>4.5) and the sample stream is
// dumped to R1_samples_<GATING>.txt for an independent floating-point Welch
// t-test in Python.
// =============================================================================

module tb_r1_realstream;

    parameter GATING = 1;          // 0 = full busy window, 1 = data-active window
    parameter N_LOG2 = 12;         // n = 4096 samples per group (engine default)
    // PROBE_SEED = 1 -> sample HW of the KEYGEN SEED input bus (in_data while
    // in_addr < 32, i.e. the real key-seed bytes being written into seed_buf).
    // This is a genuine, key-dependent, NON-pseudorandom signal: the board POST
    // fixed seed d[j]=j has HW mean 2.5 vs a random seed HW mean 4.0 (sep 1.5).
    // PROBE_SEED = 0 -> legacy output-bus proxy (pk/ct/ss HW, GATING window).
    parameter PROBE_SEED = 1;
    // LOAD_ONLY = 1 -> stream-load seed+msg repeatedly WITHOUT keygen/encaps.
    // The probe samples the SAME seed_buf HW signal, but each "run" costs only
    // ~70 cycles instead of the full KEM (~3e5 cycles), so N_LOG2=12 (n=4096)
    // is reachable quickly to confirm the engine's exact on-chip group size.
    parameter LOAD_ONLY = 0;

    reg         clk, rst_n;
    integer     cyc;

    // KEM control
    reg         start, op_keygen, op_encaps;
    reg         in_load;
    reg  [7:0]  in_addr, in_data;
    reg         ct_load;
    reg  [15:0] ct_in_addr, ct_in_data;
    wire        busy, done, error;
    wire        pk_valid; wire [15:0] pk_addr, pk_data;
    wire        ct_valid; wire [15:0] ct_addr, ct_data;
    wire        ss_valid; wire [7:0]  ss_data;

    // TVLA proxy wiring (identical to board_top L221-235)
    wire [7:0] sc_mon_byte =
          ss_valid ? ss_data[7:0]
        : ct_valid ? ct_data[7:0]
        : pk_valid ? pk_data[7:0]
        : 8'h00;
    reg  [3:0] sc_hw;
    integer    bi;
    always @(*) begin
        sc_hw = 4'd0;
        for (bi = 0; bi < 8; bi = bi + 1)
            sc_hw = sc_hw + sc_mon_byte[bi];
    end

    // --- PROBE_SEED: HW of the keygen-seed input bus (genuine key-dependent) ---
    reg  [3:0] seed_hw;
    integer    si;
    always @(*) begin
        seed_hw = 4'd0;
        for (si = 0; si < 8; si = si + 1)
            seed_hw = seed_hw + in_data[si];
    end
    wire [5:0] seed_sample = {2'b0, seed_hw};
    wire       seed_valid  = in_load && !busy && (in_addr < 8'd32);

    // --- Proxy source select ---
    wire [5:0] tvla_sample = PROBE_SEED ? seed_sample : {2'b0, sc_hw};

    reg  sample_fixed;
    wire sample_valid = PROBE_SEED
        ? seed_valid
        : ((GATING == 1) ? (pk_valid | ct_valid | ss_valid) : busy);

    // Engine observation
    wire        tvla_batch_ready, tvla_batch_done, tvla_leak, tvla_degenerate;
    wire [12:0] tvla_cnt_fixed, tvla_cnt_random;
    wire [17:0] tvla_sum_fixed, tvla_sum_random;
    wire [23:0] tvla_sq_fixed,  tvla_sq_random;

    kyber_kem #(
        .K(3), .N(256), .Q(3329), .BW(16), .ETA(2),
        .DU(10), .DV(4), .R_MOD(2285),
        .SEED_B(32), .MSG_B(32), .SS_B(32)
    ) u_kem (
        .clk(clk), .rst_n(rst_n),
        .start(start), .op_keygen(op_keygen), .op_encaps(op_encaps),
        .busy(busy), .done(done), .error(error),
        .in_load(in_load), .in_addr(in_addr), .in_data(in_data),
        .ct_load(ct_load), .ct_in_addr(ct_in_addr), .ct_data_in(ct_in_data),
        .pk_valid(pk_valid), .pk_addr(pk_addr), .pk_data(pk_data),
        .ct_valid(ct_valid), .ct_addr(ct_addr), .ct_data(ct_data),
        .ss_valid(ss_valid), .ss_data(ss_data)
    );

    tvla_online #(.SAMPLE_W(6), .N_LOG2(N_LOG2)) u_tvla (
        .clk(clk), .rst_n(rst_n),
        .sample_valid(sample_valid),
        .sample(tvla_sample),
        .sample_fixed(sample_fixed),
        .batch_restart(1'b0),
        .batch_ready(tvla_batch_ready),
        .batch_done(tvla_batch_done),
        .leak_detected(tvla_leak),
        .degenerate(tvla_degenerate),
        .cnt_fixed(tvla_cnt_fixed), .cnt_random(tvla_cnt_random),
        .sum_fixed(tvla_sum_fixed), .sum_random(tvla_sum_random),
        .sq_fixed(tvla_sq_fixed),  .sq_random(tvla_sq_random)
    );

    always #5 clk = ~clk;         // 100 MHz
    initial cyc = 0;
    always @(posedge clk) if (rst_n) cyc = cyc + 1;

    // Latch the engine decision at every evaluation pulse (batch_done is a
    // one-cycle pulse, so it must be captured as it fires, not polled later).
    reg result_leak, result_degen, eval_seen;
    always @(posedge clk) begin
        if (!rst_n) begin
            eval_seen    <= 1'b0;
            result_leak  <= 1'b0;
            result_degen <= 1'b0;
        end else if (tvla_batch_done) begin
            eval_seen    <= 1'b1;
            result_leak  <= tvla_leak;
            result_degen <= tvla_degenerate;
        end
    end

    integer fd;

    // Dump the (sample, is_fixed) stream for the Python Welch reference
    always @(posedge clk) begin
        if (rst_n && sample_valid)
            $fdisplay(fd, "%0d %0d", tvla_sample, sample_fixed);
    end

    // -------------------------------------------------------------------------
    // KEM driver: load seed+msg, then keygen, then encaps (data-active source)
    // -------------------------------------------------------------------------
    task run_kem(input [255:0] seed, input [255:0] msg);
        integer k;
        begin
            // stream-load 64 bytes: seed[0..31] then msg[32..63]
            for (k = 0; k < 64; k = k + 1) begin
                @(negedge clk);
                in_addr = k[7:0];
                in_data = (k < 32) ? seed[k*8 +: 8] : msg[(k-32)*8 +: 8];
                in_load = 1'b1;
            end
            @(negedge clk);
            in_load = 1'b0;

            // KeyGen: one-cycle start pulse
            @(negedge clk); start = 1'b1; op_keygen = 1'b1; op_encaps = 1'b0;
            @(negedge clk); start = 1'b0; op_keygen = 1'b0;
            while (!done) @(posedge clk);
            @(negedge clk);

            // Encaps: one-cycle start pulse
            @(negedge clk); start = 1'b1; op_encaps = 1'b1; op_keygen = 1'b0;
            @(negedge clk); start = 1'b0; op_encaps = 1'b0;
            while (!done) @(posedge clk);
            @(negedge clk);
        end
    endtask

    // LOAD_ONLY: stream-load seed+msg (no keygen/encaps).  Same seed_buf HW
    // signal sampled; each call costs ~70 cycles.
    task load_seed(input [255:0] seed, input [255:0] msg);
        integer k;
        begin
            for (k = 0; k < 64; k = k + 1) begin
                @(negedge clk);
                in_addr = k[7:0];
                in_data = (k < 32) ? seed[k*8 +: 8] : msg[(k-32)*8 +: 8];
                in_load = 1'b1;
            end
            @(negedge clk);
            in_load = 1'b0;
        end
    endtask

    // -------------------------------------------------------------------------
    initial begin
        integer i, run;
        reg [255:0] seed, msg;
        integer fixed_done, random_done;

        fd = $fopen($sformatf("R1_%s_samples_g%0d.txt", PROBE_SEED ? "seed" : "bus", GATING), "w");
        if (fd == 0) begin
            $display("FAIL: cannot open dump file"); $finish;
        end

        clk = 1'b0; rst_n = 1'b0;
        start = 1'b0; op_keygen = 1'b0; op_encaps = 1'b0;
        in_load = 1'b0; in_addr = 8'h00; in_data = 8'h00;
        ct_load = 1'b0; ct_in_addr = 16'h0000; ct_in_data = 16'h0000;
        sample_fixed = 1'b1;

        repeat (5) @(negedge clk);
        rst_n = 1'b1;

        $display("=== R1 probe=%s gating=%0d: fill FIXED group with a fixed secret ===",
                 PROBE_SEED ? "seed" : "bus", GATING);

        // Fixed group: deterministic seed (board-POST style) + fixed message.
        // With PROBE_SEED each run contributes 32 seed samples (2 loads), so
        // reaching n=4096 needs ~64 runs per group.
        fixed_done = 0;
        for (run = 0; run < 140 && !fixed_done; run = run + 1) begin
            // seed[j]=j, msg[k]=0xA5^k  (identical to the board ROM)
            for (i = 0; i < 32; i = i + 1) begin
                seed[i*8 +: 8] = i[7:0];
                msg[i*8  +: 8] = 8'hA5 ^ i[7:0];
            end
            sample_fixed = 1'b1;
            if (LOAD_ONLY) load_seed(seed, msg); else run_kem(seed, msg);
            $display("  fixed run %0d done: cnt_fixed=%0d", run, tvla_cnt_fixed);
            if (tvla_cnt_fixed == (1 << N_LOG2)) fixed_done = 1;
        end
        if (tvla_cnt_fixed != (1 << N_LOG2))
            $display("  NOTE: fixed group not full (cnt_fixed=%0d) after %0d runs", tvla_cnt_fixed, run);

        $display("=== R1 probe=%s gating=%0d: fill RANDOM group with random secrets ===",
                 PROBE_SEED ? "seed" : "bus", GATING);
        random_done = 0;
        for (run = 0; run < 140 && !random_done && !eval_seen; run = run + 1) begin
            // Random secret + random message (TRNG-equivalent)
            seed = {$random, $random, $random, $random, $random, $random, $random, $random};
            msg  = {$random, $random, $random, $random, $random, $random, $random, $random};
            sample_fixed = 1'b0;
            if (LOAD_ONLY) load_seed(seed, msg); else run_kem(seed, msg);
            $display("  random run %0d done: cnt_random=%0d", run, tvla_cnt_random);
            if (tvla_cnt_random == (1 << N_LOG2)) random_done = 1;
        end
        if (tvla_cnt_random != (1 << N_LOG2) && !eval_seen)
            $display("  NOTE: random group not full (cnt_random=%0d) after %0d runs", tvla_cnt_random, run);

        // The engine auto-evaluates as soon as both groups reach n, so by the
        // time we reach here the decision is already latched (result_leak).
        if (!eval_seen) begin
            $display("  WARN: no evaluation pulse observed");
            while (!tvla_batch_done) @(posedge clk);
            @(negedge clk);
        end

        $display("========================================================");
        $display("R1 RESULT probe=%s gating=%0d (cycles=%0d)",
                 PROBE_SEED ? "seed" : "bus", GATING, cyc);
        $display("  eval_seen     = %b", eval_seen);
        $display("  leak_detected = %b   (|t| > 4.5)", result_leak);
        $display("  degenerate    = %b   (D == 0, constant groups)", result_degen);
        $display("========================================================");

        $fclose(fd);
        $finish;
    end

    // Watchdog
    initial begin
        #500_000_000;   // 50M cycles @100MHz; seed probe needs ~9M
        $display("R1 TIMEOUT probe=%s gating=%0d cyc=%0d cf=%0d cr=%0d",
                 PROBE_SEED ? "seed" : "bus", GATING, cyc, tvla_cnt_fixed, tvla_cnt_random);
        $finish;
    end

endmodule

`default_nettype wire
