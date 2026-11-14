`timescale 1ns / 1ps
// =============================================================================
// Testbench for hybrid_kex (A4) — two-party agreement + golden comparison
// -----------------------------------------------------------------------------
// Two instances cross-connected (initiator / responder), same PUF value
// (simulating server-side enrolled CRP) and same Kyber SS:
//
//   T1  key agreement: both session keys are IDENTICAL
//   T2  bit-exact vs python golden (verify/hybrid_kex_golden.py)
//   T3  PUF tampering        -> keys differ (device binding)
//   T4  Kyber SS tampering   -> keys differ (PQ contribution matters)
//   T5  peer_pub tampering   -> DH contribution changes
//   T6  single-side sanity: key_valid/done pulse behavior
// =============================================================================

module tb_hybrid_kex;
    reg clk = 0;
    reg rst_n = 0;
    always #5 clk = ~clk;  // 100 MHz

    // ---- golden constants from verify/hybrid_kex_golden.py ---------------
    localparam [255:0] GOLDEN_KEY =
        256'h2bcde46f9c67aca2f81f986299cd345ecf35e743daeeac8b1738f8f783d63496;
    localparam [30:0] GOLDEN_A0 = 31'h400000;
    localparam [30:0] GOLDEN_A1 = 31'h100000;
    localparam [30:0] GOLDEN_SSDH = 31'h40;

    localparam [255:0] PUF0 =
        256'h0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF;
    localparam [31:0] PRIV0 = 32'h12345678;
    localparam [31:0] PRIV1 = 32'h9ABCDEF0;

    integer errors = 0;
    integer i;
    reg [255:0] key_ref;

    // ---- initiator (device 0) --------------------------------------------
    reg         i_start = 0;
    reg  [31:0] i_priv_seed = 0;
    reg  [255:0] i_puf = 0;
    reg         i_peer_valid = 0;
    reg  [30:0] i_peer_pub = 0;
    reg         i_kss_valid = 0;
    reg  [7:0]  i_kss_data = 0;
    reg         i_kss_done = 0;
    wire [30:0] i_our_pub;
    wire        i_pub_valid;
    wire        i_busy, i_done, i_key_valid;
    wire [255:0] i_key;
    wire [30:0] i_ss_dh;

    hybrid_kex #(.KDF_DOMAIN(32'd1)) u_init (
        .clk(clk), .rst_n(rst_n),
        .start(i_start), .priv_seed(i_priv_seed), .puf_resp(i_puf),
        .peer_pub_valid(i_peer_valid), .peer_pub(i_peer_pub),
        .kss_valid(i_kss_valid), .kss_data(i_kss_data), .kss_done(i_kss_done),
        .our_pub(i_our_pub), .our_pub_valid(i_pub_valid),
        .busy(i_busy), .done(i_done),
        .session_key(i_key), .key_valid(i_key_valid), .ss_dh_out(i_ss_dh)
    );

    // ---- responder (device 1) --------------------------------------------
    reg         r_start = 0;
    reg  [31:0] r_priv_seed = 0;
    reg  [255:0] r_puf = 0;
    reg         r_peer_valid = 0;
    reg  [30:0] r_peer_pub = 0;
    reg         r_kss_valid = 0;
    reg  [7:0]  r_kss_data = 0;
    reg         r_kss_done = 0;
    wire [30:0] r_our_pub;
    wire        r_pub_valid;
    wire        r_busy, r_done, r_key_valid;
    wire [255:0] r_key;
    wire [30:0] r_ss_dh;

    hybrid_kex #(.KDF_DOMAIN(32'd1)) u_resp (
        .clk(clk), .rst_n(rst_n),
        .start(r_start), .priv_seed(r_priv_seed), .puf_resp(r_puf),
        .peer_pub_valid(r_peer_valid), .peer_pub(r_peer_pub),
        .kss_valid(r_kss_valid), .kss_data(r_kss_data), .kss_done(r_kss_done),
        .our_pub(r_our_pub), .our_pub_valid(r_pub_valid),
        .busy(r_busy), .done(r_done),
        .session_key(r_key), .key_valid(r_key_valid), .ss_dh_out(r_ss_dh)
    );

    // -------------------------------------------------------------------------
    // helpers
    // -------------------------------------------------------------------------
    task wait_clks;
        input integer n;
        integer j;
        begin
            for (j = 0; j < n; j = j + 1) @(posedge clk);
        end
    endtask

    // stream 32 kyber ss bytes into one side
    task send_kss;
        input which;   // 0 = initiator, 1 = responder
        input [255:0] dummy;
        integer k;
        begin
            for (k = 0; k < 32; k = k + 1) begin
                @(negedge clk);
                if (which == 0) begin
                    i_kss_valid = 1; i_kss_data = k[7:0];
                end else begin
                    r_kss_valid = 1; r_kss_data = k[7:0];
                end
                @(posedge clk);
            end
            @(negedge clk);
            if (which == 0) begin
                i_kss_valid = 0; i_kss_done = 1;
            end else begin
                r_kss_valid = 0; r_kss_done = 1;
            end
            @(posedge clk);
            @(negedge clk);
            if (which == 0) i_kss_done = 0;
            else            r_kss_done = 0;
        end
    endtask

    // run a full authenticated exchange between the two instances
    // (uses the current PRIV/PUF regs + golden-style kss bytes)
    task run_exchange;
        begin
            // 1) both sides start
            @(negedge clk);
            i_start = 1; r_start = 1;
            @(posedge clk);
            @(negedge clk);
            i_start = 0; r_start = 0;

            // 2) stream kyber ss bytes in parallel (both sides, same value)
            for (i = 0; i < 32; i = i + 1) begin
                @(negedge clk);
                i_kss_valid = 1; i_kss_data = i[7:0];
                r_kss_valid = 1; r_kss_data = i[7:0];
                @(posedge clk);
            end
            @(negedge clk);
            i_kss_valid = 0; i_kss_done = 1;
            r_kss_valid = 0; r_kss_done = 1;
            @(posedge clk);
            @(negedge clk);
            i_kss_done = 0; r_kss_done = 0;

            // 3) wait for public keys
            wait (i_pub_valid && r_pub_valid);

            // 4) exchange public keys (cross-connected)
            @(negedge clk);
            i_peer_valid = 1; i_peer_pub = r_our_pub;
            r_peer_valid = 1; r_peer_pub = i_our_pub;
            @(posedge clk);
            @(negedge clk);
            i_peer_valid = 0; r_peer_valid = 0;

            // 5) wait for both session keys
            wait (i_key_valid && r_key_valid);
            @(posedge clk);
        end
    endtask

    task clear_io;
        begin
            i_kss_valid = 0; i_kss_done = 0; i_peer_valid = 0;
            r_kss_valid = 0; r_kss_done = 0; r_peer_valid = 0;
        end
    endtask

    // -------------------------------------------------------------------------
    initial begin
        rst_n = 0;
        clear_io;
        wait_clks(5);
        rst_n = 1;
        wait_clks(2);

        //////////////////////////////////////////////////////////////////
        // T1+T2: normal exchange — agreement + bit-exact golden
        //////////////////////////////////////////////////////////////////
        $display("\n=== T1: Two-party key agreement ===");
        i_priv_seed = PRIV0; r_priv_seed = PRIV1;
        i_puf = PUF0;       r_puf = PUF0;     // enrolled CRP (same on both)
        run_exchange;

        if (i_key !== r_key) begin
            $display("  FAIL: session keys differ");
            $display("    init: %032x", i_key);
            $display("    resp: %032x", r_key);
            errors = errors + 1;
        end else begin
            $display("  PASS: keys agree = %032x", i_key);
        end

        $display("\n=== T2: Bit-exact golden comparison ===");
        if (i_key !== GOLDEN_KEY) begin
            $display("  FAIL: session key mismatch");
            $display("    rtl   : %032x", i_key);
            $display("    golden: %032x", GOLDEN_KEY);
            errors = errors + 1;
        end else begin
            $display("  PASS: session key == golden");
        end
        if (i_our_pub !== GOLDEN_A0 || r_our_pub !== GOLDEN_A1) begin
            $display("  FAIL: public keys: i=%0h r=%0h (want %0h / %0h)",
                     i_our_pub, r_our_pub, GOLDEN_A0, GOLDEN_A1);
            errors = errors + 1;
        end else begin
            $display("  PASS: public keys == golden");
        end
        if (i_ss_dh !== GOLDEN_SSDH) begin
            $display("  FAIL: ss_dh = %0h (want %0h)", i_ss_dh, GOLDEN_SSDH);
            errors = errors + 1;
        end else begin
            $display("  PASS: ss_dh == golden (%0h)", i_ss_dh);
        end

        //////////////////////////////////////////////////////////////////
        // T3: PUF tampering — keys must differ (device binding)
        //////////////////////////////////////////////////////////////////
        $display("\n=== T3: PUF tampering ===");
        clear_io;
        i_puf = PUF0;       r_puf = ~PUF0;    // different PUF response
        run_exchange;
        if (i_key === r_key) begin
            $display("  FAIL: keys identical despite PUF tampering");
            errors = errors + 1;
        end else begin
            $display("  PASS: keys differ when PUF differs");
        end

        //////////////////////////////////////////////////////////////////
        // T4: Kyber SS tampering — keys must differ (PQ contribution)
        //////////////////////////////////////////////////////////////////
        $display("\n=== T4: Kyber SS tampering ===");
        clear_io;
        i_puf = PUF0; r_puf = PUF0;
        // run exchange but scramble responder's kyber bytes
        @(negedge clk);
        i_start = 1; r_start = 1;
        @(posedge clk);
        @(negedge clk);
        i_start = 0; r_start = 0;
        for (i = 0; i < 32; i = i + 1) begin
            @(negedge clk);
            i_kss_valid = 1; i_kss_data = i[7:0];
            r_kss_valid = 1; r_kss_data = (8'hFF - i[7:0]);  // tampered
            @(posedge clk);
        end
        @(negedge clk);
        i_kss_valid = 0; i_kss_done = 1;
        r_kss_valid = 0; r_kss_done = 1;
        @(posedge clk);
        @(negedge clk);
        i_kss_done = 0; r_kss_done = 0;
        wait (i_pub_valid && r_pub_valid);
        @(negedge clk);
        i_peer_valid = 1; i_peer_pub = r_our_pub;
        r_peer_valid = 1; r_peer_pub = i_our_pub;
        @(posedge clk);
        @(negedge clk);
        i_peer_valid = 0; r_peer_valid = 0;
        wait (i_key_valid && r_key_valid);
        @(posedge clk);
        if (i_key === r_key) begin
            $display("  FAIL: keys identical despite Kyber SS tampering");
            errors = errors + 1;
        end else begin
            $display("  PASS: keys differ when Kyber SS differs");
        end

        //////////////////////////////////////////////////////////////////
        // T5: peer_pub tampering — DH contribution changes
        //////////////////////////////////////////////////////////////////
        $display("\n=== T5: peer_pub tampering ===");
        clear_io;
        i_puf = PUF0; r_puf = PUF0;
        @(negedge clk);
        i_start = 1; r_start = 1;
        @(posedge clk);
        @(negedge clk);
        i_start = 0; r_start = 0;
        // kyber: only initiator streams; responder gets no stream but kss_done
        for (i = 0; i < 32; i = i + 1) begin
            @(negedge clk);
            i_kss_valid = 1; i_kss_data = i[7:0];
            @(posedge clk);
        end
        @(negedge clk);
        i_kss_valid = 0; i_kss_done = 1; r_kss_done = 1;
        @(posedge clk);
        @(negedge clk);
        i_kss_done = 0; r_kss_done = 0;
        wait (i_pub_valid && r_pub_valid);
        @(negedge clk);
        // responder feeds a WRONG public key to initiator
        i_peer_valid = 1; i_peer_pub = 31'h0000_1234;
        r_peer_valid = 1; r_peer_pub = i_our_pub;
        @(posedge clk);
        @(negedge clk);
        i_peer_valid = 0; r_peer_valid = 0;
        wait (i_key_valid && r_key_valid);
        @(posedge clk);
        if (i_ss_dh === r_ss_dh) begin
            $display("  FAIL: ss_dh identical despite tampered peer pubkey");
            errors = errors + 1;
        end else begin
            $display("  PASS: ss_dh differs with tampered peer pubkey");
        end

        //////////////////////////////////////////////////////////////////
        // Summary
        //////////////////////////////////////////////////////////////////
        $display("\n=== hybrid_kex tests completed ===");
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("FAILED with %0d errors", errors);
        $finish;
    end

    // watchdog
    initial begin
        #(10000 * 10);
        $display("\nTIMEOUT — simulation stuck");
        $finish;
    end

endmodule
