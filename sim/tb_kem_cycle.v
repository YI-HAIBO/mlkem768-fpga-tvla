`timescale 1ns / 1ps
`default_nettype none

// =============================================================================
// KEM stage cycle-count probe (independent verification of Table 6 inputs)
// -----------------------------------------------------------------------------
// Table 6 claims the full-coprocessor encapsulation latency is 10,204 cycles
// and the board POST (complete key-establishment path) is 352,627 cycles at
// 100 MHz.  This TB instantiates the REAL kyber_kem (ML-KEM-768) standalone
// and measures the keygen and encaps stage latencies in clock cycles, so the
// 10,204 figure can be cross-checked against a fresh, traceable measurement
// (the board figure 352,627 has an independent board-sim log already).
//
// NOTE: the standalone kyber_kem latency is EXPECTED to be <= the board-level
// full-coprocessor encapsulation latency, because the board top adds packaging
// (host-side address decode, handshake, status writeback) around the KEM core.
// The point is to confirm the SAME ORDER and a tight bound, not bit-equality.
// =============================================================================

module tb_kem_cycle;

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

    always #5 clk = ~clk;         // 100 MHz
    initial cyc = 0;
    always @(posedge clk) if (rst_n) cyc = cyc + 1;

    // load seed[0..31], msg[32..63]
    task load_kem(input [255:0] seed, input [255:0] msg);
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

    // start one op, return cycles from start-pulse to done
    task run_op(input do_keygen);
        integer c0, c1;
        begin
            @(negedge clk);
            start = 1'b1; op_keygen = do_keygen; op_encaps = !do_keygen;
            c0 = cyc;
            @(negedge clk);
            start = 1'b0; op_keygen = 1'b0; op_encaps = 1'b0;
            while (!done) @(posedge clk);
            c1 = cyc;
            @(negedge clk);
            $display("  %s: start cyc=%0d  done cyc=%0d  latency=%0d cycles",
                     do_keygen ? "keygen" : "encaps", c0, c1, c1 - c0);
        end
    endtask

    initial begin
        integer i;
        reg [255:0] seed, msg;
        seed = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
        msg  = 256'ha0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebf;

        clk = 1'b0; rst_n = 1'b0;
        start = 1'b0; op_keygen = 1'b0; op_encaps = 1'b0;
        in_load = 1'b0; in_addr = 8'h00; in_data = 8'h00;
        ct_load = 1'b0; ct_in_addr = 16'h0000; ct_in_data = 16'h0000;

        repeat (5) @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk);

        $display("=== KEM stage cycle probe (ML-KEM-768, 100 MHz) ===");
        $display("seed = %h", seed);

        // run 1
        load_kem(seed, msg);
        run_op(1'b1);   // keygen
        run_op(1'b0);   // encaps

        // run 2 (fresh keygen -> encaps)
        $display("run 2:");
        load_kem(seed, msg);
        run_op(1'b1);
        run_op(1'b0);

        $display("=== done ===");
        $finish;
    end

endmodule
