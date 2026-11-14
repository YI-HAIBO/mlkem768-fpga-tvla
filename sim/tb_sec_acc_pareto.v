// =============================================================================
// C2 — sec_acc_pareto testbench
// Verifies: feasibility filter, non-dominated (Pareto) sort, min-area selection,
// no-solution flag, illegal-command latch, and register map.
// The golden model verify/sec_acc_pareto_golden.py recomputes each budget
// independently; this TB hard-codes the hand-derived expected values so the two
// must agree.
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
    wire [3:0]  sel_idx, feasible_cnt, pareto_cnt;
    wire        no_solution;

    localparam [11:0] R_MAXAREA = 12'hF00;
    localparam [11:0] R_MAXAREAH= 12'hF03;
    localparam [11:0] R_MINACC  = 12'hF01;
    localparam [11:0] R_MINSEC  = 12'hF02;
    localparam [11:0] R_SELIDX  = 12'hF10;
    localparam [11:0] R_FEASCNT = 12'hF11;
    localparam [11:0] R_PARSCNT = 12'hF12;
    localparam [11:0] R_NOSOL   = 12'hF13;

    localparam [3:0] C_RESET    = 4'h0;
    localparam [3:0] C_BUDGET   = 4'h1;
    localparam [3:0] C_OPTIMIZE = 4'h2;
    localparam [3:0] C_READ     = 4'h3;

    sec_acc_pareto u0 (
        .clk(clk), .rst_n(rst_n),
        .cmd_valid(cmd_valid), .cmd(cmd),
        .busy(busy), .done(done), .error(error),
        .wr_valid(wr_valid), .wr_addr(wr_addr), .wr_data(wr_data),
        .rd_valid(rd_valid), .rd_addr(rd_addr), .rd_data(rd_data),
        .sel_idx(sel_idx), .feasible_cnt(feasible_cnt),
        .pareto_cnt(pareto_cnt), .no_solution(no_solution)
    );

    integer errors = 0;
    reg [255:0] name;
    reg cond;
    reg [15:0] ma;
    reg [7:0]  mnacc, mnsec, dv;

    task chk;
        input [255:0] tag;
        input         c;
        begin
            if (c) $display("PASS %0s", tag);
            else begin
                $display("FAIL %0s", tag);
                errors = errors + 1;
            end
        end
    endtask

    task wait_done;
        integer t;
        begin
            t = 0;
            while (!done && t < 50) begin
                @(posedge clk);
                t = t + 1;
            end
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

    // one full budget + optimize, checking all four outputs
    task run_budget;
        input [255:0] name;
        input [15:0]  ma;
        input [7:0]   mnacc;
        input [7:0]   mnsec;
        input [3:0]   exp_sel;
        input [3:0]   exp_feas;
        input [3:0]   exp_pareto;
        input         exp_nosol;
        reg [7:0] tmp;
        begin
            run_cmd(C_RESET);
            write_reg(R_MAXAREA,  ma[7:0]);
            write_reg(R_MAXAREAH, ma[15:8]);
            write_reg(R_MINACC,   mnacc);
            write_reg(R_MINSEC,   mnsec);
            run_cmd(C_OPTIMIZE);
            $display("  %0s -> sel=%0d feas=%0d pareto=%0d nosol=%b  | exp sel=%0d feas=%0d pareto=%0d nosol=%b",
                     name, sel_idx, feasible_cnt, pareto_cnt, no_solution,
                     exp_sel, exp_feas, exp_pareto, exp_nosol);
            chk({name, " sel_idx"},        sel_idx == exp_sel);
            chk({name, " feasible_cnt"},   feasible_cnt == exp_feas);
            chk({name, " pareto_cnt"},     pareto_cnt == exp_pareto);
            chk({name, " no_solution"},    no_solution === exp_nosol);
            // register map echoes the same values
            read_reg(R_SELIDX,  tmp);
            chk({name, " regmap sel"},  tmp === {4'b0, exp_sel});
            read_reg(R_NOSOL,   tmp);
            chk({name, " regmap nosol"}, tmp === {7'b0, exp_nosol});
            read_reg(R_MAXAREA,  tmp);
            chk({name, " regmap maxarea"}, tmp === ma[7:0]);
            read_reg(R_MAXAREAH, tmp);
            chk({name, " regmap maxarea_h"}, tmp === ma[15:8]);
            read_reg(R_MINSEC,   tmp);
            chk({name, " regmap minsec"},   tmp === mnsec);
        end
    endtask

    initial begin
        $display("=== C2 sec_acc_pareto testbench ===");
        // ---- reset -----------------------------------------------------------
        rst_n = 1'b0;
        @(negedge clk); @(negedge clk);
        rst_n = 1'b1;
        @(negedge clk); @(negedge clk);
        chk("T1 busy low after reset",        busy === 1'b0);
        chk("T1 done low after reset",        done === 1'b0);
        chk("T1 error low after reset",       error === 1'b0);
        chk("T1 no_solution low after reset", no_solution === 1'b0);

        // T2: wide budget, everything feasible except 4,5,6 (area>200)
        //     feasible={0,1,2,3,7}; 7 dominated by 1 -> pareto={0,1,2,3}; min area=0
        run_budget("T2 wide",   16'd200, 8'd0, 8'd0,   4'd0,  4'd5, 4'd4, 1'b0);

        // T3: accuracy floor 180 -> only config 5 (acc185, area240) qualifies
        run_budget("T3 acc180", 16'd300, 8'd180, 8'd0,  4'd5,  4'd1, 4'd1, 1'b0);

        // T4: acc>=200 & sec>=100 -> only config 6 (acc210, sec140)
        run_budget("T4 acc200 sec100", 16'd1000, 8'd200, 8'd100, 4'd6, 4'd1, 4'd1, 1'b0);

        // T5: sec>=80 & area<=500 -> {3,4,5,6} all Pareto; min area = 3
        run_budget("T5 sec80",  16'd500, 8'd100, 8'd80, 4'd3,  4'd4, 4'd4, 1'b0);

        // T6: area budget below the cheapest config -> no solution
        run_budget("T6 noarea", 16'd50,  8'd0,  8'd0,   4'd15, 4'd0, 4'd0, 1'b1);

        // T7: security floor above every config (max sec=140) -> no solution
        run_budget("T7 nosec",  16'd1000, 8'd0,  8'd255, 4'd15, 4'd0, 4'd0, 1'b1);

        // T8: dominance filter — config 7 (acc140,area135) feasible but dominated
        //     by config 1 (acc150,area130); feasible=3, pareto=2, sel=0
        run_budget("T8 dom",    16'd135, 8'd0,  8'd0,   4'd0,  4'd3, 4'd2, 1'b0);

        // ---- T9: illegal command latches error (sticky) ---------------------
        run_cmd(4'h7);
        chk("T9 illegal command latches error", error === 1'b1);

        $display("=== %s (%0d failures) ===",
                 (errors == 0) ? "ALL TESTS PASSED" : "FAILURES", errors);
        $finish;
    end

    initial begin
        forever #5 clk = !clk;
    end

endmodule
