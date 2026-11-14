`timescale 1ns / 1ps
`default_nettype none

// =============================================================================
// Testbench: kyber_kem KeyGen + Encaps path
// Compares RTL output against golden vectors from sim/kem_*.hex
// Uses $fscanf for reliable hex file reading.
//
// Sequence:
//   1. load d0            -> seed_buf   (in_addr 0..31)
//   2. load m0            -> msg_buf    (in_addr 32..63)
//   3. KeyGen             -> pk = t0||t1||t2||rho   (800 words)
//   4. compare pk         -> vs kem_t0/t1/t2/rho    (800 checks)
//   5. Encaps             -> ct = cu0||cu1||cu2||cv (1024 words) + ss (32 B)
//   6. compare ct + ss    -> vs kem_cu0/cu1/cu2/cv/ss (1056 checks)
//   7. Decaps             -> recover m' + ss (consumes self-produced ct)
//   8. Decaps #2          -> via external ct_load datapath (receiver case)
//   9. Repeat-stability   -> KeyGen/Encaps/Decaps run #2 must match pass #1
//
// cu/cv are the COMPRESSED coefficient values (du=10 -> 0..1023, dv=4 -> 0..15),
// which is exactly what gen_kem_golden.py stores.
// =============================================================================

module tb_kyber_kem;

    reg  clk, rst_n;
    reg  start, op_keygen, op_encaps;
    wire busy, done, error;

    reg  in_load;
    reg  [7:0] in_addr, in_data;

    // Ciphertext load (feeds Decaps independently of this run's own Encaps)
    reg  ct_load;
    reg  [15:0] ct_in_addr, ct_in_data;

    wire        pk_valid;
    wire [15:0] pk_addr;
    wire [15:0] pk_data;

    wire        ct_valid;
    wire [15:0] ct_addr;
    wire [15:0] ct_data;

    wire        ss_valid;
    wire [7:0]  ss_data;

    // ---------------------------------------------------------------------
    // Golden vectors
    // ---------------------------------------------------------------------
    reg [7:0]  gold_d_bytes    [0:31];
    reg [7:0]  gold_rho_bytes  [0:31];
    reg [7:0]  gold_msg_bytes  [0:31];
    reg [7:0]  gold_ss_bytes   [0:31];
    reg [15:0] gold_t0 [0:255];
    reg [15:0] gold_t1 [0:255];
    reg [15:0] gold_t2 [0:255];
    reg [15:0] gold_cu0[0:255];
    reg [15:0] gold_cu1[0:255];
    reg [15:0] gold_cu2[0:255];
    reg [15:0] gold_cv [0:255];

    // Captures
    reg [15:0] pk_capture [0:799];
    reg [15:0] ct_capture [0:1023];
    reg [7:0]  ss_capture [0:31];

    integer errors, kg_errors, enc_errors, dec_errors, repeat_err;
    integer fd, n, i;

    // ---------------------------------------------------------------------
    // DUT
    // ---------------------------------------------------------------------
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

    // Clock
    always #5 clk = ~clk;

    // ---------------------------------------------------------------------
    // Load golden vectors using $fscanf
    // ---------------------------------------------------------------------
    initial begin
        fd = $fopen("sim/kem_d0.hex", "r");
        for (i = 0; i < 32; i = i + 1)
            n = $fscanf(fd, "%2h", gold_d_bytes[i]);
        $fclose(fd);

        fd = $fopen("sim/kem_rho.hex", "r");
        for (i = 0; i < 32; i = i + 1)
            n = $fscanf(fd, "%2h", gold_rho_bytes[i]);
        $fclose(fd);

        fd = $fopen("sim/kem_m0.hex", "r");
        for (i = 0; i < 32; i = i + 1)
            n = $fscanf(fd, "%2h", gold_msg_bytes[i]);
        $fclose(fd);

        fd = $fopen("sim/kem_t0.hex", "r");
        for (i = 0; i < 256; i = i + 1)
            n = $fscanf(fd, "%4h", gold_t0[i]);
        $fclose(fd);

        fd = $fopen("sim/kem_t1.hex", "r");
        for (i = 0; i < 256; i = i + 1)
            n = $fscanf(fd, "%4h", gold_t1[i]);
        $fclose(fd);

        fd = $fopen("sim/kem_t2.hex", "r");
        for (i = 0; i < 256; i = i + 1)
            n = $fscanf(fd, "%4h", gold_t2[i]);
        $fclose(fd);

        fd = $fopen("sim/kem_cu0.hex", "r");
        for (i = 0; i < 256; i = i + 1)
            n = $fscanf(fd, "%4h", gold_cu0[i]);
        $fclose(fd);

        fd = $fopen("sim/kem_cu1.hex", "r");
        for (i = 0; i < 256; i = i + 1)
            n = $fscanf(fd, "%4h", gold_cu1[i]);
        $fclose(fd);

        fd = $fopen("sim/kem_cu2.hex", "r");
        for (i = 0; i < 256; i = i + 1)
            n = $fscanf(fd, "%4h", gold_cu2[i]);
        $fclose(fd);

        fd = $fopen("sim/kem_cv.hex", "r");
        for (i = 0; i < 256; i = i + 1)
            n = $fscanf(fd, "%4h", gold_cv[i]);
        $fclose(fd);

        fd = $fopen("sim/kem_ss.hex", "r");
        for (i = 0; i < 32; i = i + 1)
            n = $fscanf(fd, "%2h", gold_ss_bytes[i]);
        $fclose(fd);

        // Prime the captures so any address the DUT never drives is caught.
        for (i = 0; i < 800; i = i + 1)
            pk_capture[i] = 16'hDEAD;
        for (i = 0; i < 1024; i = i + 1)
            ct_capture[i] = 16'hDEAD;
        for (i = 0; i < 32; i = i + 1)
            ss_capture[i] = 8'hFF;
    end

    // Capture pk / ct outputs
    always @(posedge clk) begin
        if (pk_valid)
            pk_capture[pk_addr] <= pk_data;
        if (ct_valid)
            ct_capture[ct_addr] <= ct_data;
    end

    // ss byte index: count ss_valid pulses in order
    reg [4:0] ss_idx;
    initial ss_idx = 0;
    always @(posedge clk) begin
        if (ss_valid) begin
            ss_capture[ss_idx] <= ss_data;
            if (ss_idx == 5'd31)
                ss_idx <= 5'd0;
            else
                ss_idx <= ss_idx + 5'd1;
        end
    end

    // State monitor
    reg [4:0] prev_st;
    always @(posedge clk) begin
        if (rst_n && dut.st !== prev_st) begin
            $display("[TB] State: %0d -> %0d at t=%0t", prev_st, dut.st, $time);
            prev_st <= dut.st;
        end
    end

    // Watchdog
    integer cycle_count;
    always @(posedge clk) begin
        if (rst_n) begin
            cycle_count <= cycle_count + 1;
            if (cycle_count > 5000000 && !done) begin
                $display("[TB] WATCHDOG: timeout after %0d cycles, st=%0d phase=%0d",
                         cycle_count, dut.st, dut.phase);
                $finish;
            end
        end
    end

    // Main test sequence
    initial begin
        clk = 0; rst_n = 0;
        start = 0; op_keygen = 0; op_encaps = 0;
        in_load = 0; in_addr = 0; in_data = 0;
        ct_load = 0; ct_in_addr = 0; ct_in_data = 0;
        errors = 0; kg_errors = 0; enc_errors = 0; dec_errors = 0;
        cycle_count = 0;
        prev_st = 5'd255;

        // Reset
        repeat (5) @(posedge clk);
        rst_n <= 1;
        repeat (2) @(posedge clk);

        // ------------------------------------------------------------------
        // Load seed d0 (in_addr 0..31)
        // ------------------------------------------------------------------
        $display("=== Loading seed ===");
        $display("[TB] gold_d_bytes[0]=%02h [1]=%02h [2]=%02h",
                 gold_d_bytes[0], gold_d_bytes[1], gold_d_bytes[2]);
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge clk);
            in_load <= 1;
            in_addr <= i[7:0];
            in_data <= gold_d_bytes[i];
        end
        @(posedge clk);
        in_load <= 0;
        @(posedge clk);
        $display("[TB] seed_buf[0]=%02h [1]=%02h [2]=%02h",
                 dut.seed_buf[0], dut.seed_buf[1], dut.seed_buf[2]);

        // ------------------------------------------------------------------
        // Load message m0 (in_addr 32..63)
        // ------------------------------------------------------------------
        $display("=== Loading message ===");
        $display("[TB] gold_msg_bytes[0]=%02h [1]=%02h [2]=%02h",
                 gold_msg_bytes[0], gold_msg_bytes[1], gold_msg_bytes[2]);
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge clk);
            in_load <= 1;
            in_addr <= i[7:0] + 8'd32;
            in_data <= gold_msg_bytes[i];
        end
        @(posedge clk);
        in_load <= 0;
        @(posedge clk);
        $display("[TB] msg_buf[0]=%02h [1]=%02h [2]=%02h",
                 dut.msg_buf[0], dut.msg_buf[1], dut.msg_buf[2]);

        // ------------------------------------------------------------------
        // KeyGen
        // ------------------------------------------------------------------
        $display("=== Starting KeyGen ===");
        @(posedge clk);
        start <= 1;
        op_keygen <= 1;
        @(posedge clk);
        start <= 0;
        op_keygen <= 0;

        $display("=== Waiting for KeyGen done ===");
        wait(done);
        repeat (2) @(posedge clk);

        // ------------------------------------------------------------------
        // Compare pk = t0 || t1 || t2 || rho
        // ------------------------------------------------------------------
        $display("=== Comparing KeyGen results ===");
        kg_errors = 0;

        for (i = 0; i < 256; i = i + 1) begin
            if (pk_capture[i] !== gold_t0[i]) begin
                $display("T0[%0d] MISMATCH: got %04h, expected %04h",
                         i, pk_capture[i], gold_t0[i]);
                kg_errors = kg_errors + 1;
                if (kg_errors > 10) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        for (i = 0; i < 256; i = i + 1) begin
            if (pk_capture[256 + i] !== gold_t1[i]) begin
                $display("T1[%0d] MISMATCH: got %04h, expected %04h",
                         i, pk_capture[256 + i], gold_t1[i]);
                kg_errors = kg_errors + 1;
                if (kg_errors > 10) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        for (i = 0; i < 256; i = i + 1) begin
            if (pk_capture[512 + i] !== gold_t2[i]) begin
                $display("T2[%0d] MISMATCH: got %04h, expected %04h",
                         i, pk_capture[512 + i], gold_t2[i]);
                kg_errors = kg_errors + 1;
                if (kg_errors > 10) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        for (i = 0; i < 32; i = i + 1) begin
            if (pk_capture[768 + i][7:0] !== gold_rho_bytes[i]) begin
                $display("RHO[%0d] MISMATCH: got %02h, expected %02h",
                         i, pk_capture[768 + i][7:0], gold_rho_bytes[i]);
                kg_errors = kg_errors + 1;
                if (kg_errors > 10) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        if (kg_errors == 0)
            $display("=== KEYGEN: ALL %0d CHECKS PASSED ===", 768 + 32);
        else
            $display("=== KEYGEN: %0d ERRORS ===", kg_errors);

        if (kg_errors != 0) begin
            $display("=== ABORTING: Encaps skipped (KeyGen failed) ===");
            $finish;
        end

        // ------------------------------------------------------------------
        // Encaps  (uses the t_poly / rho_buf produced by the KeyGen above)
        // ------------------------------------------------------------------
        $display("=== Starting Encaps ===");
        @(posedge clk);
        start <= 1;
        op_encaps <= 1;
        @(posedge clk);
        start <= 0;
        op_encaps <= 0;

        $display("=== Waiting for Encaps done ===");
        wait(done);
        repeat (2) @(posedge clk);

        // ------------------------------------------------------------------
        // Compare ct = cu0 || cu1 || cu2 || cv   and   ss
        // ------------------------------------------------------------------
        $display("=== Comparing Encaps results ===");
        enc_errors = 0;

        for (i = 0; i < 256; i = i + 1) begin
            if (ct_capture[i] !== gold_cu0[i]) begin
                $display("CU0[%0d] MISMATCH: got %04h, expected %04h",
                         i, ct_capture[i], gold_cu0[i]);
                enc_errors = enc_errors + 1;
                if (enc_errors > 20) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        for (i = 0; i < 256; i = i + 1) begin
            if (ct_capture[256 + i] !== gold_cu1[i]) begin
                $display("CU1[%0d] MISMATCH: got %04h, expected %04h",
                         i, ct_capture[256 + i], gold_cu1[i]);
                enc_errors = enc_errors + 1;
                if (enc_errors > 20) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        for (i = 0; i < 256; i = i + 1) begin
            if (ct_capture[512 + i] !== gold_cu2[i]) begin
                $display("CU2[%0d] MISMATCH: got %04h, expected %04h",
                         i, ct_capture[512 + i], gold_cu2[i]);
                enc_errors = enc_errors + 1;
                if (enc_errors > 20) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        for (i = 0; i < 256; i = i + 1) begin
            if (ct_capture[768 + i] !== gold_cv[i]) begin
                $display("CV[%0d] MISMATCH: got %04h, expected %04h",
                         i, ct_capture[768 + i], gold_cv[i]);
                enc_errors = enc_errors + 1;
                if (enc_errors > 20) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        for (i = 0; i < 32; i = i + 1) begin
            if (ss_capture[i] !== gold_ss_bytes[i]) begin
                $display("SS[%0d] MISMATCH: got %02h, expected %02h",
                         i, ss_capture[i], gold_ss_bytes[i]);
                enc_errors = enc_errors + 1;
                if (enc_errors > 20) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        if (enc_errors == 0)
            $display("=== ENCAPS: ALL %0d CHECKS PASSED ===", 1024 + 32);
        else
            $display("=== ENCAPS: %0d ERRORS ===", enc_errors);

        if (enc_errors != 0) begin
            $display("=== ABORTING: Decaps skipped (Encaps failed) ===");
            errors = kg_errors + enc_errors;
            $display("=== TOTAL: %0d ERRORS (keygen=%0d encaps=%0d decaps=0) ===",
                     errors, kg_errors, enc_errors, dec_errors);
            $finish;
        end

        // ------------------------------------------------------------------
        // Decaps  (consumes the cu_poly/cv_poly just produced by Encaps)
        //   m' must recover the original 32-byte message and ss must match.
        // ------------------------------------------------------------------
        $display("=== Starting Decaps ===");
        @(posedge clk);
        start <= 1;
        op_keygen <= 0;
        op_encaps <= 0;
        @(posedge clk);
        start <= 0;

        $display("=== Waiting for Decaps done ===");
        wait(done);
        repeat (2) @(posedge clk);

        $display("=== Comparing Decaps results ===");
        dec_errors = 0;

        // ss = SHAKE-256(m'') must equal the golden shared secret
        for (i = 0; i < 32; i = i + 1) begin
            if (ss_capture[i] !== gold_ss_bytes[i]) begin
                $display("DEC-SS[%0d] MISMATCH: got %02h, expected %02h",
                         i, ss_capture[i], gold_ss_bytes[i]);
                dec_errors = dec_errors + 1;
                if (dec_errors > 20) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        // m' (decoded) must equal the original message m0
        for (i = 0; i < 32; i = i + 1) begin
            if (dut.m_prime_buf[i] !== gold_msg_bytes[i]) begin
                $display("DEC-M[%0d] MISMATCH: got %02h, expected %02h",
                         i, dut.m_prime_buf[i], gold_msg_bytes[i]);
                dec_errors = dec_errors + 1;
                if (dec_errors > 20) begin
                    $display("Too many errors, stopping.");
                    $finish;
                end
            end
        end

        if (dec_errors == 0)
            $display("=== DECAPS: ALL %0d CHECKS PASSED ===", 32 + 32);
        else
            $display("=== DECAPS: %0d ERRORS ===", dec_errors);

        // ------------------------------------------------------------------
        // Decaps #2 : ct loaded from the OUTSIDE via ct_load (the realistic
        // receiver case).  This proves the ct_load datapath and that Decaps
        // does not secretly depend on this instance's own Encaps state.
        // ------------------------------------------------------------------
        $display("=== Loading external ct via ct_load ===");
        ct_load = 1;
        for (i = 0; i < 256; i = i + 1) begin
            @(posedge clk);
            ct_in_addr = i[15:0];
            ct_in_data = gold_cu0[i];
        end
        for (i = 0; i < 256; i = i + 1) begin
            @(posedge clk);
            ct_in_addr = i[15:0] + 16'd256;
            ct_in_data = gold_cu1[i];
        end
        for (i = 0; i < 256; i = i + 1) begin
            @(posedge clk);
            ct_in_addr = i[15:0] + 16'd512;
            ct_in_data = gold_cu2[i];
        end
        for (i = 0; i < 256; i = i + 1) begin
            @(posedge clk);
            ct_in_addr = i[15:0] + 16'd768;
            ct_in_data = gold_cv[i];
        end
        @(posedge clk);
        ct_load = 0;
        @(posedge clk);

        // Verify the ct really landed in cu_poly/cv_poly.
        // cu_poly is a FLAT 1-D array [0:K*N-1] = [0:767] (chunk j at j*256+i),
        // so cu0 -> cu_poly[i], cu1 -> cu_poly[256+i], cu2 -> cu_poly[512+i],
        // and cv -> cv_poly[i].  (The old expressions cu_poly[0][i] / [2][i]
        // were bit-selects of element 0 / 2 -> spurious X.)
        i = 0; n = 0;
        for (i = 0; i < 256; i = i + 1) begin
            if (dut.cu_poly[i] !== gold_cu0[i]) begin
                $display("CT-LOAD CU0[%0d] NOT LOADED: %04h != %04h",
                         i, dut.cu_poly[i], gold_cu0[i]);
                n = n + 1;
            end
            if (dut.cu_poly[512 + i] !== gold_cu2[i]) begin
                $display("CT-LOAD CU2[%0d] NOT LOADED: %04h != %04h",
                         i, dut.cu_poly[512 + i], gold_cu2[i]);
                n = n + 1;
            end
            if (dut.cv_poly[i] !== gold_cv[i]) begin
                $display("CT-LOAD CV[%0d] NOT LOADED: %04h != %04h",
                         i, dut.cv_poly[i], gold_cv[i]);
                n = n + 1;
            end
        end
        if (n == 0)
            $display("[TB] ct_load datapath: 768 words landed OK");
        else
            $display("[TB] ct_load datapath: %0d WORDS FAILED", n);

        $display("=== Starting Decaps #2 (external ct) ===");
        @(posedge clk);
        start <= 1;
        op_keygen <= 0;
        op_encaps <= 0;
        @(posedge clk);
        start <= 0;

        $display("=== Waiting for Decaps #2 done ===");
        wait(done);
        repeat (2) @(posedge clk);

        // Re-check ss + m' against the same golden vectors
        for (i = 0; i < 32; i = i + 1) begin
            if (ss_capture[i] !== gold_ss_bytes[i]) begin
                $display("DEC2-SS[%0d] MISMATCH: got %02h, expected %02h",
                         i, ss_capture[i], gold_ss_bytes[i]);
                dec_errors = dec_errors + 1;
            end
        end
        for (i = 0; i < 32; i = i + 1) begin
            if (dut.m_prime_buf[i] !== gold_msg_bytes[i]) begin
                $display("DEC2-M[%0d] MISMATCH: got %02h, expected %02h",
                         i, dut.m_prime_buf[i], gold_msg_bytes[i]);
                dec_errors = dec_errors + 1;
            end
        end
        $display("=== DECAPS #2 (external ct): %0d ERRORS ===", dec_errors);

        // ------------------------------------------------------------------
        // REPEAT STABILITY : re-run the full KeyGen -> Encaps -> Decaps chain
        // back-to-back (no reset, same seeds) and verify the results match.
        // Catches hidden state-leak bugs between consecutive operations.
        // ------------------------------------------------------------------
        $display("=== REPEAT STABILITY: KeyGen #2 ===");
        @(posedge clk);
        start <= 1;
        op_keygen <= 1;
        @(posedge clk);
        start <= 0;
        op_keygen <= 0;
        wait(done);
        repeat (2) @(posedge clk);

        $display("=== REPEAT STABILITY: Encaps #2 ===");
        @(posedge clk);
        start <= 1;
        op_encaps <= 1;
        @(posedge clk);
        start <= 0;
        op_encaps <= 0;
        wait(done);
        repeat (2) @(posedge clk);

        $display("=== REPEAT STABILITY: Decaps #3 (self-produced ct) ===");
        @(posedge clk);
        start <= 1;
        op_keygen <= 0;
        op_encaps <= 0;
        @(posedge clk);
        start <= 0;
        wait(done);
        repeat (2) @(posedge clk);

        // Compare against the SAME golden vectors as the first pass.
        repeat_err = 0;
        for (i = 0; i < 32; i = i + 1) begin
            if (ss_capture[i] !== gold_ss_bytes[i]) begin
                $display("REPEAT-SS[%0d] MISMATCH: got %02h, expected %02h",
                         i, ss_capture[i], gold_ss_bytes[i]);
                repeat_err = repeat_err + 1;
            end
        end
        for (i = 0; i < 32; i = i + 1) begin
            if (dut.m_prime_buf[i] !== gold_msg_bytes[i]) begin
                $display("REPEAT-M[%0d] MISMATCH: got %02h, expected %02h",
                         i, dut.m_prime_buf[i], gold_msg_bytes[i]);
                repeat_err = repeat_err + 1;
            end
        end
        if (repeat_err == 0)
            $display("=== REPEAT STABILITY: PASS (2 consecutive runs agree) ===");
        else
            $display("=== REPEAT STABILITY: %0d ERRORS ===", repeat_err);

        errors = kg_errors + enc_errors + dec_errors + repeat_err;
        $display("=== TOTAL: %0d ERRORS (keygen=%0d encaps=%0d decaps=%0d repeat=%0d) ===",
                 errors, kg_errors, enc_errors, dec_errors, repeat_err);

        $finish;
    end

endmodule

`default_nettype wire
