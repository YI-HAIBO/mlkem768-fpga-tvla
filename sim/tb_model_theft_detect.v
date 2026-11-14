// =============================================================================
// C3 — model_theft_detect testbench
//
// The TB carries its OWN gf256 + tag implementation (an independent code path
// from the DUT) and asserts it against values hard-coded from
// verify/model_theft_detect_golden.py, so the three implementations must agree.
// =============================================================================
`timescale 1ns / 1ps
module tb;

    reg         clk = 1'b0;
    reg         rst_n = 1'b0;
    reg         cmd_valid = 1'b0;
    reg  [3:0]  cmd = 4'h0;
    wire        busy, done, error;
    reg         wr_valid = 1'b0;
    reg  [11:0] wr_addr = 12'd0;
    reg  [7:0]  wr_data = 8'd0;
    reg         rd_valid = 1'b0;
    reg  [11:0] rd_addr = 12'd0;
    wire [7:0]  rd_data;
    wire [4:0]  canary_cnt;
    wire [7:0]  match_cnt, mismatch_cnt;
    wire        detected, insufficient;

    localparam [11:0] DIGEST_BASE = 12'h000;
    localparam [11:0] OUT_BASE    = 12'h010;
    localparam [11:0] R_KEY0 = 12'hF00, R_KEY1 = 12'hF01;
    localparam [11:0] R_IDX  = 12'hF10, R_THRES = 12'hF11;
    localparam [11:0] R_CANARYCNT = 12'hF12, R_MATCHCNT = 12'hF13;
    localparam [11:0] R_MISMATCH = 12'hF14, R_VERDICT = 12'hF15;
    localparam [3:0] C_RESET = 4'h0, C_SET_KEY = 4'h1;
    localparam [3:0] C_ADD_CANARY = 4'h2, C_PROBE = 4'h3, C_DETECT = 4'h4;

    localparam [15:0] KEY = 16'hBEEF;

    // gold vectors from verify/model_theft_detect_golden.py
    localparam [15:0] T0 = 16'ha8bd;
    localparam [15:0] T1 = 16'h2f84;
    localparam [15:0] T2 = 16'h72b7;
    localparam [15:0] T3 = 16'h8739;

    model_theft_detect u0 (
        .clk(clk), .rst_n(rst_n),
        .cmd_valid(cmd_valid), .cmd(cmd),
        .busy(busy), .done(done), .error(error),
        .wr_valid(wr_valid), .wr_addr(wr_addr), .wr_data(wr_data),
        .rd_valid(rd_valid), .rd_addr(rd_addr), .rd_data(rd_data),
        .canary_cnt(canary_cnt), .match_cnt(match_cnt),
        .mismatch_cnt(mismatch_cnt), .detected(detected),
        .insufficient(insufficient)
    );

    integer errors = 0;
    reg [255:0] name;
    reg cond;
    reg [7:0]  dv;
    integer i, k;

    // ---- independent GF(2^8) + tag ------------------------------------------
    function [7:0] gf;
        input [7:0] a, b;
        reg  [7:0] acc, ai;
        integer j;
        begin
            acc = 8'd0; ai = a;
            for (j = 0; j < 8; j = j + 1) begin
                if (b[j]) acc = acc ^ ai;
                if (ai[7]) ai = (ai << 1) ^ 8'h1B;
                else       ai = ai << 1;
                ai = ai & 8'hFF;
            end
            gf = acc;
        end
    endfunction

    function [15:0] mktag;
        input [7:0] d0, d1, d2, d3, d4, d5, d6, d7;
        reg [15:0] t;
        integer j;
        begin
            t = 16'd0;
            t = t ^ {gf(KEY[15:8],d0), gf(KEY[7:0],d0)};
            t = t ^ {gf(KEY[15:8],d1), gf(KEY[7:0],d1)};
            t = t ^ {gf(KEY[15:8],d2), gf(KEY[7:0],d2)};
            t = t ^ {gf(KEY[15:8],d3), gf(KEY[7:0],d3)};
            t = t ^ {gf(KEY[15:8],d4), gf(KEY[7:0],d4)};
            t = t ^ {gf(KEY[15:8],d5), gf(KEY[7:0],d5)};
            t = t ^ {gf(KEY[15:8],d6), gf(KEY[7:0],d6)};
            t = t ^ {gf(KEY[15:8],d7), gf(KEY[7:0],d7)};
            mktag = t;
        end
    endfunction

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
            while (!done && t < 60) begin @(posedge clk); t = t + 1; end
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

    task load_digest;
        input [7:0] d0, d1, d2, d3, d4, d5, d6, d7;
        begin
            write_reg(DIGEST_BASE + 8'd0, d0);
            write_reg(DIGEST_BASE + 8'd1, d1);
            write_reg(DIGEST_BASE + 8'd2, d2);
            write_reg(DIGEST_BASE + 8'd3, d3);
            write_reg(DIGEST_BASE + 8'd4, d4);
            write_reg(DIGEST_BASE + 8'd5, d5);
            write_reg(DIGEST_BASE + 8'd6, d6);
            write_reg(DIGEST_BASE + 8'd7, d7);
        end
    endtask

    // write an 8-byte suspect output whose tag field [6..7] is the given tag
    task load_output;
        input [15:0] t;
        begin
            write_reg(OUT_BASE + 8'd0, 8'hAA);
            write_reg(OUT_BASE + 8'd1, 8'hBB);
            write_reg(OUT_BASE + 8'd2, 8'hCC);
            write_reg(OUT_BASE + 8'd3, 8'hDD);
            write_reg(OUT_BASE + 8'd4, 8'hEE);
            write_reg(OUT_BASE + 8'd5, 8'hFF);
            write_reg(OUT_BASE + 8'd6, t[7:0]);
            write_reg(OUT_BASE + 8'd7, t[15:8]);
        end
    endtask

    task add_canary;
        input [7:0] d0, d1, d2, d3, d4, d5, d6, d7;
        begin
            load_digest(d0, d1, d2, d3, d4, d5, d6, d7);
            run_cmd(C_ADD_CANARY);
        end
    endtask

    task probe;
        input [7:0]  idx;
        input [15:0] t;
        begin
            write_reg(R_IDX, idx);
            load_output(t);
            run_cmd(C_PROBE);
        end
    endtask

    task do_reset;
        begin
            run_cmd(C_RESET);
        end
    endtask

    initial begin
        $display("=== C3 model_theft_detect testbench ===");
        rst_n = 1'b0;
        @(negedge clk); @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk); @(negedge clk);

        // ---- T1: reset ------------------------------------------------------
        chk("T1 busy low",      busy === 1'b0);
        chk("T1 error low",     error === 1'b0);
        chk("T1 canary_cnt 0",  canary_cnt === 5'd0);
        chk("T1 match 0",       match_cnt === 8'd0);
        chk("T1 mismatch 0",    mismatch_cnt === 8'd0);
        chk("T1 detected low",  detected === 1'b0);
        chk("T1 insufficient low", insufficient === 1'b0);

        // ---- T2: TB's own tag must equal the golden hard-coded vectors -----
        chk("T2 mktag D0", mktag(8'h10,8'h20,8'h30,8'h40,8'h50,8'h60,8'h70,8'h80) === T0);
        chk("T2 mktag D1", mktag(8'h11,8'h22,8'h33,8'h44,8'h55,8'h66,8'h77,8'h88) === T1);
        chk("T2 mktag D2", mktag(8'hDE,8'hAD,8'hBE,8'hEF,8'hCA,8'hFE,8'hBA,8'hBE) === T2);
        chk("T2 mktag D3", mktag(8'h01,8'h02,8'h03,8'h04,8'h05,8'h06,8'h07,8'h08) === T3);

        // ---- T3: load key + register 4 canaries -----------------------------
        write_reg(R_KEY0, KEY[7:0]);
        write_reg(R_KEY1, KEY[15:8]);
        run_cmd(C_SET_KEY);
        read_reg(R_KEY0, dv);
        chk("T3 key0 readable", dv === KEY[7:0]);
        read_reg(R_KEY1, dv);
        chk("T3 key1 readable", dv === KEY[15:8]);

        add_canary(8'h10,8'h20,8'h30,8'h40,8'h50,8'h60,8'h70,8'h80);
        add_canary(8'h11,8'h22,8'h33,8'h44,8'h55,8'h66,8'h77,8'h88);
        add_canary(8'hDE,8'hAD,8'hBE,8'hEF,8'hCA,8'hFE,8'hBA,8'hBE);
        add_canary(8'h01,8'h02,8'h03,8'h04,8'h05,8'h06,8'h07,8'h08);
        chk("T3 canary_cnt == 4", canary_cnt === 5'd4);
        read_reg(R_CANARYCNT, dv);
        chk("T3 regmap canary_cnt", dv === 8'd4);

        // ---- T4: a faithful copy replies with the right tags -> theft -------
        probe(8'd0, T0);
        probe(8'd1, T1);
        probe(8'd2, T2);
        probe(8'd3, T3);
        chk("T4 match_cnt == 4",      match_cnt === 8'd4);
        chk("T4 mismatch_cnt == 0",   mismatch_cnt === 8'd0);
        read_reg(R_MATCHCNT,  dv);
        chk("T4 regmap match_cnt",    dv === 8'd4);
        read_reg(R_MISMATCH,  dv);
        chk("T4 regmap mismatch_cnt", dv === 8'd0);

        write_reg(R_THRES, 8'd4);
        run_cmd(C_DETECT);
        chk("T4 detected",       detected === 1'b1);
        chk("T4 not insufficient", insufficient === 1'b0);
        read_reg(R_VERDICT, dv);
        chk("T4 regmap verdict {det,insuff}", dv === 8'b00000010);

        // ---- T5: an independent model cannot reproduce the tags -------------
        do_reset;
        write_reg(R_KEY0, KEY[7:0]);
        write_reg(R_KEY1, KEY[15:8]);
        run_cmd(C_SET_KEY);
        add_canary(8'h10,8'h20,8'h30,8'h40,8'h50,8'h60,8'h70,8'h80);
        add_canary(8'h11,8'h22,8'h33,8'h44,8'h55,8'h66,8'h77,8'h88);
        probe(8'd0, T0 ^ 16'h0001);   // every bit pattern except the true tag
        probe(8'd1, T1 ^ 16'hFFFF);
        chk("T5 match_cnt == 0",      match_cnt === 8'd0);
        chk("T5 mismatch_cnt == 2",   mismatch_cnt === 8'd2);
        write_reg(R_THRES, 8'd2);
        run_cmd(C_DETECT);
        chk("T5 not detected (independent model)", detected === 1'b0);
        chk("T5 sufficient probes",   insufficient === 1'b0);

        // ---- T6: too few probes -> insufficient, no verdict -----------------
        do_reset;
        chk("T6 reset clears detected",   detected === 1'b0);
        chk("T6 reset clears insufficient", insufficient === 1'b0);
        write_reg(R_THRES, 8'd3);
        run_cmd(C_DETECT);
        chk("T6 insufficient with no probes", insufficient === 1'b1);
        chk("T6 no verdict without probes",   detected === 1'b0);

        // ---- T7: probe an unregistered canary -> sticky error --------------
        write_reg(R_IDX, 8'd5);
        load_output(T0);
        run_cmd(C_PROBE);
        chk("T7 probe idx>=cnt latches error", error === 1'b1);

        // ---- T8: canary table overflow -> sticky error ----------------------
        do_reset;
        for (i = 0; i < 9; i = i + 1) begin
            load_digest(8'hA0+i, 8'hB0+i, 8'hC0+i, 8'hD0+i,
                        8'hE0+i, 8'hF0+i, 8'h00+i, 8'h10+i);
            run_cmd(C_ADD_CANARY);
        end
        chk("T8 canary_cnt capped at 8", canary_cnt === 5'd8);
        chk("T8 overflow latches error", error === 1'b1);
        read_reg(R_CANARYCNT, dv);
        chk("T8 regmap canary_cnt 8", dv === 8'd8);

        // ---- T9: partial match below threshold -> not detected -------------
        do_reset;
        write_reg(R_KEY0, KEY[7:0]);
        write_reg(R_KEY1, KEY[15:8]);
        run_cmd(C_SET_KEY);
        add_canary(8'h10,8'h20,8'h30,8'h40,8'h50,8'h60,8'h70,8'h80);
        add_canary(8'h11,8'h22,8'h33,8'h44,8'h55,8'h66,8'h77,8'h88);
        probe(8'd0, T0);            // correct
        probe(8'd1, T1 ^ 16'h0001); // wrong
        write_reg(R_THRES, 8'd2);
        run_cmd(C_DETECT);
        chk("T9 match=1 < thres=2 -> not detected", detected === 1'b0);
        chk("T9 sufficient probes",   insufficient === 1'b0);

        // ---- T10: illegal command latches error ----------------------------
        run_cmd(4'h7);
        chk("T10 illegal command latches error", error === 1'b1);

        $display("=== %s (%0d failures) ===",
                 (errors == 0) ? "ALL TESTS PASSED" : "FAILURES", errors);
        $finish;
    end

    initial begin
        forever #5 clk = !clk;
    end

endmodule
