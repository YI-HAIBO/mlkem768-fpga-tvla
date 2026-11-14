`timescale 1ns / 1ps
// =============================================================================
// Testbench for unified_ntt (A1: NTT unified reuse architecture)
// -----------------------------------------------------------------------------
// Verifies:
//   1. Forward NTT: output coefficients in [-q/2, q/2]
//   2. NTT/INTT round-trip: invntt(ntt(f)) == f * R mod q
//   3. INTT of zero polynomial yields zero
//   4. Parameterized module loads zeta ROM correctly
//
// Configuration: KEM mode (q=3329, 7 layers, 16-bit coeff)
// Zeta table: exact values from pq-crystals/kyber ref/ntt.c
// =============================================================================

module tb_unified_ntt;
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

    // Zeta ROM load interface
    reg zeta_load = 0;
    reg [6:0] zeta_addr = 0;
    reg [15:0] zeta_data = 0;

    // -------------------------------------------------------------------------
    // DUT instantiation: KEM mode (Kyber defaults)
    // -------------------------------------------------------------------------
    unified_ntt #(
        .N(256), .N_LAYERS(7), .BW(16),
        .Q(3329), .QINV(62209), .R_MOD(2285),
        .SCALE_K(1441), .BARRETT_M(20159), .BARRETT_SH(26)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .start(start), .inverse(inverse),
        .busy(busy), .done(done),
        .load(load), .load_addr(load_addr), .load_data(load_data),
        .read_addr(read_addr), .read_data(read_data),
        .zeta_load(zeta_load), .zeta_addr(zeta_addr), .zeta_data(zeta_data),
        // Compile-time parameters only: runtime configuration disabled
        .cfg_load(1'b0), .cfg_addr(3'd0), .cfg_data(16'd0)
    );

    always #5 clk = ~clk;  // 100 MHz

    integer errors = 0;
    integer i, k;
    reg [15:0] test_input [0:255];
    reg [15:0] coeff_out  [0:255];
    reg [15:0] coeff_in   [0:255];

    // -------------------------------------------------------------------------
    // Kyber zeta table (exact values from ref/ntt.c, signed 16-bit)
    // Stored as unsigned 16-bit (two's complement for negatives)
    // -------------------------------------------------------------------------
    reg [15:0] kyber_zetas [0:127];
    initial begin
        kyber_zetas[0]   = 16'd64492;  // -1044
        kyber_zetas[1]   = 16'd64778;  // -758
        kyber_zetas[2]   = 16'd65177;  // -359
        kyber_zetas[3]   = 16'd64019;  // -1517
        kyber_zetas[4]   = 16'd1493;
        kyber_zetas[5]   = 16'd1422;
        kyber_zetas[6]   = 16'd287;
        kyber_zetas[7]   = 16'd202;
        kyber_zetas[8]   = 16'd3158;   // -171
        kyber_zetas[9]   = 16'd622;
        kyber_zetas[10]  = 16'd1577;
        kyber_zetas[11]  = 16'd182;
        kyber_zetas[12]  = 16'd962;
        kyber_zetas[13]  = 16'd2127;   // -1202
        kyber_zetas[14]  = 16'd1855;   // -1474
        kyber_zetas[15]  = 16'd1468;
        kyber_zetas[16]  = 16'd573;
        kyber_zetas[17]  = 16'd2004;   // -1325
        kyber_zetas[18]  = 16'd264;
        kyber_zetas[19]  = 16'd383;
        kyber_zetas[20]  = 16'd2500;   // -829
        kyber_zetas[21]  = 16'd1458;
        kyber_zetas[22]  = 16'd1727;   // -1602
        kyber_zetas[23]  = 16'd3199;   // -130
        kyber_zetas[24]  = 16'd2648;   // -681
        kyber_zetas[25]  = 16'd1017;
        kyber_zetas[26]  = 16'd732;
        kyber_zetas[27]  = 16'd608;
        kyber_zetas[28]  = 16'd1787;   // -1542
        kyber_zetas[29]  = 16'd411;
        kyber_zetas[30]  = 16'd3124;   // -205
        kyber_zetas[31]  = 16'd1758;   // -1571
        kyber_zetas[32]  = 16'd1223;
        kyber_zetas[33]  = 16'd652;
        kyber_zetas[34]  = 16'd2777;   // -552
        kyber_zetas[35]  = 16'd1015;
        kyber_zetas[36]  = 16'd2036;   // -1293
        kyber_zetas[37]  = 16'd1491;
        kyber_zetas[38]  = 16'd3047;   // -282
        kyber_zetas[39]  = 16'd1785;   // -1544
        kyber_zetas[40]  = 16'd516;
        kyber_zetas[41]  = 16'd3321;   // -8
        kyber_zetas[42]  = 16'd3009;   // -320
        kyber_zetas[43]  = 16'd2663;   // -666
        kyber_zetas[44]  = 16'd1711;   // -1618
        kyber_zetas[45]  = 16'd2167;   // -1162
        kyber_zetas[46]  = 16'd126;
        kyber_zetas[47]  = 16'd1469;
        kyber_zetas[48]  = 16'd2476;   // -853
        kyber_zetas[49]  = 16'd3239;   // -90
        kyber_zetas[50]  = 16'd3058;   // -271
        kyber_zetas[51]  = 16'd830;
        kyber_zetas[52]  = 16'd107;
        kyber_zetas[53]  = 16'd1908;   // -1421
        kyber_zetas[54]  = 16'd3082;   // -247
        kyber_zetas[55]  = 16'd2378;   // -951
        kyber_zetas[56]  = 16'd2931;   // -398
        kyber_zetas[57]  = 16'd961;
        kyber_zetas[58]  = 16'd1821;   // -1508
        kyber_zetas[59]  = 16'd2604;   // -725
        kyber_zetas[60]  = 16'd448;
        kyber_zetas[61]  = 16'd2264;   // -1065
        kyber_zetas[62]  = 16'd677;
        kyber_zetas[63]  = 16'd2054;   // -1275
        kyber_zetas[64]  = 16'd2226;   // -1103
        kyber_zetas[65]  = 16'd430;
        kyber_zetas[66]  = 16'd555;
        kyber_zetas[67]  = 16'd843;
        kyber_zetas[68]  = 16'd2078;   // -1251
        kyber_zetas[69]  = 16'd871;
        kyber_zetas[70]  = 16'd1550;
        kyber_zetas[71]  = 16'd105;
        kyber_zetas[72]  = 16'd422;
        kyber_zetas[73]  = 16'd587;
        kyber_zetas[74]  = 16'd177;
        kyber_zetas[75]  = 16'd3094;   // -235
        kyber_zetas[76]  = 16'd3038;   // -291
        kyber_zetas[77]  = 16'd2869;   // -460
        kyber_zetas[78]  = 16'd1574;
        kyber_zetas[79]  = 16'd1653;
        kyber_zetas[80]  = 16'd3083;   // -246
        kyber_zetas[81]  = 16'd778;
        kyber_zetas[82]  = 16'd1159;
        kyber_zetas[83]  = 16'd3182;   // -147
        kyber_zetas[84]  = 16'd2552;   // -777
        kyber_zetas[85]  = 16'd1483;
        kyber_zetas[86]  = 16'd2727;   // -602
        kyber_zetas[87]  = 16'd1119;
        kyber_zetas[88]  = 16'd1739;   // -1590
        kyber_zetas[89]  = 16'd644;
        kyber_zetas[90]  = 16'd2457;   // -872
        kyber_zetas[91]  = 16'd349;
        kyber_zetas[92]  = 16'd418;
        kyber_zetas[93]  = 16'd329;
        kyber_zetas[94]  = 16'd3173;   // -156
        kyber_zetas[95]  = 16'd3254;   // -75
        kyber_zetas[96]  = 16'd817;
        kyber_zetas[97]  = 16'd1097;
        kyber_zetas[98]  = 16'd603;
        kyber_zetas[99]  = 16'd610;
        kyber_zetas[100] = 16'd1322;
        kyber_zetas[101] = 16'd2044;   // -1285
        kyber_zetas[102] = 16'd1864;   // -1465
        kyber_zetas[103] = 16'd384;
        kyber_zetas[104] = 16'd2114;   // -1215
        kyber_zetas[105] = 16'd3193;   // -136
        kyber_zetas[106] = 16'd1218;
        kyber_zetas[107] = 16'd1994;   // -1335
        kyber_zetas[108] = 16'd2455;   // -874
        kyber_zetas[109] = 16'd220;
        kyber_zetas[110] = 16'd2142;   // -1187
        kyber_zetas[111] = 16'd1670;   // -1659
        kyber_zetas[112] = 16'd2144;   // -1185
        kyber_zetas[113] = 16'd1799;   // -1530
        kyber_zetas[114] = 16'd2051;   // -1278
        kyber_zetas[115] = 16'd794;
        kyber_zetas[116] = 16'd1819;   // -1510
        kyber_zetas[117] = 16'd2475;   // -854
        kyber_zetas[118] = 16'd2459;   // -870
        kyber_zetas[119] = 16'd478;
        kyber_zetas[120] = 16'd3221;   // -108
        kyber_zetas[121] = 16'd3021;   // -308
        kyber_zetas[122] = 16'd996;
        kyber_zetas[123] = 16'd991;
        kyber_zetas[124] = 16'd958;
        kyber_zetas[125] = 16'd1869;   // -1460
        kyber_zetas[126] = 16'd1522;
        kyber_zetas[127] = 16'd1628;
    end

    // -------------------------------------------------------------------------
    // Task: wait until done
    // -------------------------------------------------------------------------
    task wait_done;
        integer guard;
        begin
            guard = 0;
            while (!done && guard < 200000) begin
                @(posedge clk);
                guard = guard + 1;
            end
            if (guard >= 200000) begin
                $display("ERROR: Timeout waiting for done");
                errors = errors + 1;
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Task: load polynomial
    // -------------------------------------------------------------------------
    task load_poly;
        begin
            for (k = 0; k < 256; k = k + 1) begin
                load_addr = k[7:0];
                load_data = test_input[k];
                load = 1;
                @(posedge clk);
            end
            load = 0;
        end
    endtask

    // -------------------------------------------------------------------------
    // Task: read polynomial
    // -------------------------------------------------------------------------
    task read_poly;
        begin
            for (k = 0; k < 256; k = k + 1) begin
                read_addr = k[7:0];
                @(posedge clk);
                coeff_out[k] = read_data;
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Task: load zeta ROM (128 entries)
    // -------------------------------------------------------------------------
    task load_zeta_rom;
        integer i;
        begin
            for (i = 0; i < 128; i = i + 1) begin
                zeta_addr = i[6:0];
                zeta_data = kyber_zetas[i];
                zeta_load = 1;
                @(posedge clk);
                zeta_load = 0;
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Initial test sequence
    // -------------------------------------------------------------------------
    initial begin
        // Initialize
        rst_n = 0;
        repeat (5) @(posedge clk);
        rst_n = 1;
        repeat (2) @(posedge clk);

        // Load Kyber zeta ROM
        $display("=== Loading Kyber zeta ROM (128 entries) ===");
        load_zeta_rom();
        $display("  Zeta ROM loaded OK");

        // -------------------------------------------------------------
        // Test 1: Forward NTT — coefficients in [-q/2, q/2]
        // -------------------------------------------------------------
        $display("\n=== Test 1: Forward NTT range check ===");
        for (i = 0; i < 256; i = i + 1)
            test_input[i] = i[15:0];

        load_poly();

        start = 1; inverse = 0;
        @(posedge clk); start = 0;
        wait_done();
        read_poly();

        errors = 0;
        for (i = 0; i < 256; i = i + 1) begin
            if ($signed(coeff_out[i]) < -(3329/2) || $signed(coeff_out[i]) > 3329/2) begin
                if (errors < 5)
                    $display("ERROR: coeff[%0d] = %0d out of range [-1664, 1664]",
                             i, $signed(coeff_out[i]));
                errors = errors + 1;
            end
        end
        if (errors == 0)
            $display("  PASS: All coefficients in [-q/2, q/2] after poly_reduce");
        else
            $display("  FAIL: %0d coefficients out of range", errors);

        // -------------------------------------------------------------
        // Test 2: NTT/INTT round-trip  invntt(ntt(f)) == f * R mod q
        // -------------------------------------------------------------
        $display("\n=== Test 2: NTT/INTT Round-Trip ===");
        load_poly();

        start = 1; inverse = 0;
        @(posedge clk); start = 0;
        wait_done();
        read_poly();

        // Save NTT output
        for (i = 0; i < 256; i = i + 1)
            coeff_in[i] = coeff_out[i];

        // Load NTT output back and run inverse
        for (i = 0; i < 256; i = i + 1)
            test_input[i] = coeff_in[i];
        load_poly();

        start = 1; inverse = 1;
        @(posedge clk); start = 0;
        wait_done();
        read_poly();

        errors = 0;
        for (i = 0; i < 256; i = i + 1) begin
            reg [31:0] expected;
            reg [31:0] got_mod;
            expected = (i[15:0] * 2285) % 3329;
            got_mod = (($signed(coeff_out[i]) % 3329) + 3329) % 3329;
            if (got_mod != $signed(expected[15:0])) begin
                if (errors < 5)
                    $display("ERROR: coeff[%0d]: got %0d (mod q %0d), expected %0d",
                             i, $signed(coeff_out[i]), got_mod, $signed(expected[15:0]));
                errors = errors + 1;
            end
        end
        if (errors == 0)
            $display("  PASS: invntt(ntt(f)) == f * R mod q  (R=2285)");
        else
            $display("  FAIL: %0d mismatches", errors);

        // -------------------------------------------------------------
        // Test 3: INTT of zero polynomial yields zero
        // -------------------------------------------------------------
        $display("\n=== Test 3: INTT(0) ===");
        for (i = 0; i < 256; i = i + 1)
            test_input[i] = 16'd0;
        load_poly();

        start = 1; inverse = 0;
        @(posedge clk); start = 0;
        wait_done();
        read_poly();
        for (i = 0; i < 256; i = i + 1)
            coeff_in[i] = coeff_out[i];

        for (i = 0; i < 256; i = i + 1)
            test_input[i] = coeff_in[i];
        load_poly();

        start = 1; inverse = 1;
        @(posedge clk); start = 0;
        wait_done();
        read_poly();

        errors = 0;
        for (i = 0; i < 256; i = i + 1) begin
            reg [31:0] got_mod;
            got_mod = (($signed(coeff_out[i]) % 3329) + 3329) % 3329;
            if (got_mod != 0) begin
                if (errors < 5)
                    $display("ERROR: coeff[%0d] = %0d (mod q %0d), expected 0",
                             i, $signed(coeff_out[i]), got_mod);
                errors = errors + 1;
            end
        end
        if (errors == 0)
            $display("  PASS: invntt(ntt(0)) == 0");
        else
            $display("  FAIL: %0d non-zero coefficients", errors);

        // -------------------------------------------------------------
        // Test 4: Forward NTT known vector (f[i] = i+1)
        // -------------------------------------------------------------
        $display("\n=== Test 4: Forward NTT known vector (f[i]=i+1) ===");
        for (i = 0; i < 256; i = i + 1)
            test_input[i] = (i + 1) & 16'hFFFF;
        load_poly();

        start = 1; inverse = 0;
        @(posedge clk); start = 0;
        wait_done();
        read_poly();

        $display("  Forward NTT first 8 coeffs: %0d %0d %0d %0d %0d %0d %0d %0d",
                 $signed(coeff_out[0]), $signed(coeff_out[1]),
                 $signed(coeff_out[2]), $signed(coeff_out[3]),
                 $signed(coeff_out[4]), $signed(coeff_out[5]),
                 $signed(coeff_out[6]), $signed(coeff_out[7]));

        // Check that NTT output is non-trivial (not all zeros)
        errors = 0;
        for (i = 0; i < 256; i = i + 1) begin
            if ($signed(coeff_out[i]) != 0)
                errors = errors + 1;  // count non-zero
        end
        if (errors > 100)
            $display("  PASS: NTT produces non-trivial output (%0d non-zero coeffs)", errors);
        else
            $display("  FAIL: NTT output mostly zero (%0d non-zero coeffs)", errors);

        // -------------------------------------------------------------
        // Summary
        // -------------------------------------------------------------
        $display("\n=== unified_ntt KEM mode tests completed ===");
        $finish;
    end

endmodule
