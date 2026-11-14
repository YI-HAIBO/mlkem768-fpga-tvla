// =============================================================================
// C4 — puf_model_bind testbench
//
// Expected vectors are hard-coded from verify/puf_model_bind_golden.py, so the
// RTL and the Python PRF must agree bit-for-bit.
//   die_A = 0x11223344 -> id = 0x614270F9, tag = 0xF9
//   die_B = 0x55667788 -> id = 0xF58A7E23, tag = 0x23
//   plaintext W[i] = i  (0x00..0x1F)
//   ciphertext CT (32 bytes) listed below
// =============================================================================
`timescale 1ns / 1ps
module tb;

    reg         clk = 1'b0;
    reg         rst_n = 1'b0;
    reg         cmd_valid = 1'b0;
    reg  [3:0]  cmd = 4'h0;
    wire        busy, done, error, verify_fail;
    wire [31:0] id;
    reg         wr_valid = 1'b0;
    reg  [11:0] wr_addr = 12'd0;
    reg  [7:0]  wr_data = 8'd0;
    reg         rd_valid = 1'b0;
    reg  [11:0] rd_addr = 12'd0;
    wire [7:0]  rd_data;

    localparam [11:0] W_BASE = 12'h000;
    localparam [11:0] TAG_A  = 12'h020;
    localparam [11:0] R_DIE0 = 12'hF00, R_ID0 = 12'hF04;
    localparam [11:0] R_SEALTAG = 12'hF10, R_STATUS = 12'hF11, R_N = 12'hF12;
    localparam [3:0] C_RESET = 4'h0, C_SET_DIE = 4'h1, C_ID = 4'h2;
    localparam [3:0] C_SEAL = 4'h3, C_OPEN = 4'h4, C_VERIFY = 4'h4 + 1;

    localparam [31:0] DIE_A = 32'h11223344;
    localparam [31:0] DIE_B = 32'h55667788;
    localparam [31:0] ID_A  = 32'h614270F9;
    localparam [31:0] ID_B  = 32'hF58A7E23;
    localparam [7:0]  TAG_A_VAL = 8'hF9;

    // ciphertext produced by die_A over plaintext W[i]=i
    // ciphertext produced by die_A over plaintext W[i]=i
    localparam [7:0] CT0 = 8'hF3;  localparam [7:0] CT1 = 8'hCD;
    localparam [7:0] CT2 = 8'h66;  localparam [7:0] CT3 = 8'h37;
    localparam [7:0] CT4 = 8'hA4;  localparam [7:0] CT5 = 8'h1F;
    localparam [7:0] CT6 = 8'h3C;  localparam [7:0] CT7 = 8'hA8;
    localparam [7:0] CT8 = 8'h6A;  localparam [7:0] CT9 = 8'h6B;
    localparam [7:0] CT10= 8'HE5;  localparam [7:0] CT11= 8'h0B;
    localparam [7:0] CT12= 8'h3D;  localparam [7:0] CT13= 8'hB9;
    localparam [7:0] CT14= 8'hBF;  localparam [7:0] CT15= 8'h94;
    localparam [7:0] CT16= 8'h17;  localparam [7:0] CT17= 8'h3C;
    localparam [7:0] CT18= 8'h83;  localparam [7:0] CT19= 8'hC6;
    localparam [7:0] CT20= 8'h40;  localparam [7:0] CT21= 8'hEE;
    localparam [7:0] CT22= 8'HD9;  localparam [7:0] CT23= 8'h59;
    localparam [7:0] CT24= 8'h8E;  localparam [7:0] CT25= 8'h9A;
    localparam [7:0] CT26= 8'h00;  localparam [7:0] CT27= 8'hFA;
    localparam [7:0] CT28= 8'HD9;  localparam [7:0] CT29= 8'h48;
    localparam [7:0] CT30= 8'h5A;  localparam [7:0] CT31= 8'h65;

    // what die_B recovers from die_A's ciphertext (first 8 bytes)
    localparam [7:0] WRONG0 = 8'h60; localparam [7:0] WRONG1 = 8'h4C;
    localparam [7:0] WRONG2 = 8'HD9; localparam [7:0] WRONG3 = 8'h7D;
    localparam [7:0] WRONG4 = 8'h64; localparam [7:0] WRONG5 = 8'h48;
    localparam [7:0] WRONG6 = 8'hDD; localparam [7:0] WRONG7 = 8'h79;

    function [7:0] ct_of;
        input [4:0] n;
        begin
            case (n)
                5'd0: ct_of=CT0;  5'd1: ct_of=CT1;  5'd2: ct_of=CT2;  5'd3: ct_of=CT3;
                5'd4: ct_of=CT4;  5'd5: ct_of=CT5;  5'd6: ct_of=CT6;  5'd7: ct_of=CT7;
                5'd8: ct_of=CT8;  5'd9: ct_of=CT9;  5'd10: ct_of=CT10; 5'd11: ct_of=CT11;
                5'd12: ct_of=CT12; 5'd13: ct_of=CT13; 5'd14: ct_of=CT14; 5'd15: ct_of=CT15;
                5'd16: ct_of=CT16; 5'd17: ct_of=CT17; 5'd18: ct_of=CT18; 5'd19: ct_of=CT19;
                5'd20: ct_of=CT20; 5'd21: ct_of=CT21; 5'd22: ct_of=CT22; 5'd23: ct_of=CT23;
                5'd24: ct_of=CT24; 5'd25: ct_of=CT25; 5'd26: ct_of=CT26; 5'd27: ct_of=CT27;
                5'd28: ct_of=CT28; 5'd29: ct_of=CT29; 5'd30: ct_of=CT30; 5'd31: ct_of=CT31;
            endcase
        end
    endfunction
    puf_model_bind u0 (
        .clk(clk), .rst_n(rst_n),
        .cmd_valid(cmd_valid), .cmd(cmd),
        .busy(busy), .done(done), .error(error),
        .wr_valid(wr_valid), .wr_addr(wr_addr), .wr_data(wr_data),
        .rd_valid(rd_valid), .rd_addr(rd_addr), .rd_data(rd_data),
        .id(id), .verify_fail(verify_fail)
    );

    integer errors = 0;
    integer i;
    integer nwrong;
    reg [7:0] dv;

    task chk;
        input [255:0] tag;
        input         c;
        begin
            if (c) $display("PASS %0s", tag);
            else begin $display("FAIL %0s", tag); errors = errors + 1; end
        end
    endtask

    task wait_done;
        integer t;
        begin
            t = 0;
            while (!done && t < 120) begin @(posedge clk); t = t + 1; end
        end
    endtask

    task write_reg;
        input [11:0] a;
        input [7:0]  d;
        begin
            @(negedge clk);
            wr_valid = 1'b1; wr_addr = a; wr_data = d;
            @(posedge clk);
            @(negedge clk);
            wr_valid = 1'b0;
        end
    endtask

    task read_reg;
        input  [11:0] a;
        output [7:0]  d;
        begin
            @(negedge clk);
            rd_valid = 1'b1; rd_addr = a;
            @(posedge clk);
            @(negedge clk);
            rd_valid = 1'b0;
            d = rd_data;
        end
    endtask

    task run_cmd;
        input [3:0] c;
        begin
            @(negedge clk);
            cmd_valid = 1'b1; cmd = c;
            @(posedge clk);
            @(negedge clk);
            cmd_valid = 1'b0;
            wait_done;
        end
    endtask

    task set_die;
        input [31:0] s;
        begin
            write_reg(R_DIE0 + 8'd0, s[7:0]);
            write_reg(R_DIE0 + 8'd1, s[15:8]);
            write_reg(R_DIE0 + 8'd2, s[23:16]);
            write_reg(R_DIE0 + 8'd3, s[31:24]);
            run_cmd(C_SET_DIE);
            // id is registered one cycle after C_SET_DIE
            @(posedge clk);
        end
    endtask

    task load_weights;
        begin
            for (i = 0; i < 32; i = i + 1)
                write_reg(W_BASE + i[11:0], i[7:0]);
        end
    endtask

    // read the 32-byte blob and compare to the CT constant
    task chk_ct;
        input [255:0] tag;
        reg ok;
        begin
            ok = 1'b1;
            for (i = 0; i < 32; i = i + 1) begin
                read_reg(W_BASE + i[11:0], dv);
                if (dv !== ct_of(i[4:0])) begin
                    ok = 1'b0;
                    $display("   mismatch byte %0d: got %h exp %h", i, dv, ct_of(i[4:0]));
                end
            end
            chk(tag, ok);
        end
    endtask

    task chk_plain;
        input [255:0] tag;
        reg ok;
        begin
            ok = 1'b1;
            for (i = 0; i < 32; i = i + 1) begin
                read_reg(W_BASE + i[11:0], dv);
                if (dv !== i[7:0]) begin
                    ok = 1'b0;
                    $display("   mismatch byte %0d: got %h exp %h", i, dv, i[7:0]);
                end
            end
            chk(tag, ok);
        end
    endtask

    initial begin
        $display("=== C4 puf_model_bind testbench ===");
        rst_n = 1'b0;
        @(negedge clk); @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk); @(negedge clk);

        // ---- T1: reset ------------------------------------------------------
        chk("T1 busy low",        busy === 1'b0);
        chk("T1 error low",       error === 1'b0);
        chk("T1 verify_fail low", verify_fail === 1'b0);
        chk("T1 id zero",         id === 32'd0);

        // ---- T2: identity of die A -----------------------------------------
        set_die(DIE_A);
        chk("T2 id == prf(die_A) == 0x614270F9", id === ID_A);
        read_reg(R_ID0 + 8'd0, dv);
        chk("T2 regmap id byte0", dv === ID_A[7:0]);
        read_reg(R_ID0 + 8'd3, dv);
        chk("T2 regmap id byte3", dv === ID_A[31:24]);
        read_reg(R_DIE0 + 8'd2, dv);
        chk("T2 regmap die byte2", dv === DIE_A[23:16]);

        // ---- T3: seal the weights ------------------------------------------
        load_weights;
        run_cmd(C_SEAL);
        chk_ct("T3 ciphertext == golden CT");
        read_reg(TAG_A, dv);
        chk("T3 seal tag == id[7:0] == 0xF9", dv === TAG_A_VAL);
        read_reg(R_SEALTAG, dv);
        chk("T3 regmap seal tag", dv === TAG_A_VAL);

        // ---- T4: open roundtrip --------------------------------------------
        run_cmd(C_OPEN);
        chk_plain("T4 seal->open recovers plaintext");
        read_reg(R_STATUS, dv);
        chk("T4 verify_fail clear", dv === 8'd0);
        run_cmd(C_VERIFY);
        chk("T4 C_VERIFY passes on own chip", verify_fail === 1'b0);
        chk("T4 verify_fail not latched", verify_fail === 1'b0);

        // ---- T5: determinism — seal twice, identical ciphertext -----------
        load_weights;
        run_cmd(C_SEAL);
        chk_ct("T5 re-seal is deterministic");

        // ---- T6: COPY-OUT onto a different chip ----------------------------
        // snapshot CT, move the blob to die_B, open, must not recover W
        set_die(DIE_B);
        chk("T6 id(B) == 0xF58A7E23", id === ID_B);
        for (i = 0; i < 32; i = i + 1)
            write_reg(W_BASE + i[11:0], ct_of(i[4:0]));
        run_cmd(C_OPEN);
        // count how many of the 32 bytes differ from the original plaintext
        nwrong = 0;
        for (i = 0; i < 32; i = i + 1) begin
            read_reg(W_BASE + i[11:0], dv);
            if (dv !== i[7:0]) nwrong = nwrong + 1;
        end
        $display("   copy-out: %0d/32 bytes differ from the original", nwrong);
        chk("T6 foreign chip recovers NO byte of the plaintext", nwrong == 32);
        // the wrong output must match the golden prediction byte-for-byte
        for (i = 0; i < 8; i = i + 1) begin
            read_reg(W_BASE + i[11:0], dv);
            if (i == 0) chk("T6 wrong byte 0 == 0x60", dv === WRONG0);
            if (i == 1) chk("T6 wrong byte 1 == 0x4C", dv === WRONG1);
            if (i == 2) chk("T6 wrong byte 2 == 0xD9", dv === WRONG2);
            if (i == 3) chk("T6 wrong byte 3 == 0x7D", dv === WRONG3);
            if (i == 4) chk("T6 wrong byte 4 == 0x64", dv === WRONG4);
            if (i == 5) chk("T6 wrong byte 5 == 0x48", dv === WRONG5);
            if (i == 6) chk("T6 wrong byte 6 == 0xDD", dv === WRONG6);
            if (i == 7) chk("T6 wrong byte 7 == 0x79", dv === WRONG7);
        end

        // ---- T7: C_VERIFY detects the foreign blob -------------------------
        run_cmd(C_VERIFY);
        chk("T7 foreign blob latches verify_fail", verify_fail === 1'b1);
        read_reg(R_STATUS, dv);
        chk("T7 regmap status verify_fail", dv === 8'd1);

        // ---- T8: return to die A, verify clears ---------------------------
        set_die(DIE_A);
        for (i = 0; i < 32; i = i + 1)
            write_reg(W_BASE + i[11:0], ct_of(i[4:0]));
        run_cmd(C_VERIFY);
        chk("T8 same-die blob clears verify_fail", verify_fail === 1'b0);
        run_cmd(C_OPEN);
        chk_plain("T8 own blob opens to plaintext");

        // ---- T9: illegal command latches error ----------------------------
        run_cmd(4'h7);
        chk("T9 illegal command latches error", error === 1'b1);

        // ---- T10: reset clears the sticky error ---------------------------
        run_cmd(C_RESET);
        chk("T10 reset clears error", error === 1'b0);
        chk("T10 reset clears verify_fail", verify_fail === 1'b0);
        read_reg(R_N, dv);
        chk("T10 regmap counter readable", dv === 8'd0);

        $display("=== %s (%0d failures) ===",
                 (errors == 0) ? "ALL TESTS PASSED" : "FAILURES", errors);
        $finish;
    end

    initial begin
        forever #5 clk = !clk;
    end

endmodule
