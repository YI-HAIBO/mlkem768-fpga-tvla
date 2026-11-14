// =============================================================================
// C2 — Security/Accuracy Pareto Joint Optimizer (on-chip operating-point picker)
// -----------------------------------------------------------------------------
// Edge AI chips have three coupled knobs:
//   * quant_bits  (precision)      -> higher  => better accuracy, MORE leakage
//   * mask_order  (side-chan sec)  -> higher  => better security, MORE area/latency
//   * (implied)   area             -> the resource cost we must stay under
//
// The three pull against each other, so a single (quant, order) pair can never
// be "best" in all three.  This module holds a small ROM of pre-characterized
// candidate configurations and, given a budget (max_area, min_acc, min_sec),
// returns the Pareto-optimal operating point that is *cheapest* on the frontier.
//
// Algorithm (bit-exact, mirrored by verify/sec_acc_pareto_golden.py):
//   1. feasible[k] = area[k]<=max_area && acc[k]>=min_acc && sec[k]>=min_sec
//   2. k is Pareto  <=>  no OTHER feasible j strictly dominates k on
//                        (acc up, sec up, area down)
//   3. among Pareto-feasible, pick MIN area (tie-break: lowest index)
//
// The computation is purely combinatorial (ROM + budget -> frontier); the
// clocked half only latches the result on C_OPTIMIZE so the register map stays
// stable for reading.  Blocking assignments in the combinational block update
// feas_c[] before pareto_c[] reads it, avoiding the NBA same-edge race.
// =============================================================================
module sec_acc_pareto (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        cmd_valid,
    input  wire [3:0]  cmd,
    output reg         busy,
    output reg         done,
    output reg         error,         // illegal command (sticky)
    // budget / result registers (12-bit addr, >=0xF00 is the reg map)
    input  wire        wr_valid,
    input  wire [11:0] wr_addr,
    input  wire [7:0]  wr_data,
    input  wire        rd_valid,
    input  wire [11:0] rd_addr,
    output wire [7:0]  rd_data,
    // result outputs (also readable via reg map)
    output reg  [3:0]  sel_idx,      // selected config index (15 = none)
    output reg  [3:0]  feasible_cnt,
    output reg  [3:0]  pareto_cnt,
    output reg         no_solution
);

    localparam [3:0]
        C_RESET   = 4'h0,
        C_BUDGET  = 4'h1,
        C_OPTIMIZE= 4'h2,
        C_READ    = 4'h3;

    localparam [11:0]
        R_MAXAREA = 12'hF00,
        R_MAXAREAH= 12'hF03,   // max_area high byte (max_area is 16-bit)
        R_MINACC  = 12'hF01,
        R_MINSEC  = 12'hF02,
        R_SELIDX  = 12'hF10,
        R_FEASCNT = 12'hF11,
        R_PARSCNT = 12'hF12,
        R_NOSOL   = 12'hF13;

    localparam NCFG = 4'd8;

    // ---- candidate ROM: {quant, order, acc_q8, sec_q8, area} -----------------
    // Hand-built so the frontier is non-trivial: config 7 (q5/o1, acc140) is
    // dominated by config 1 (q5/o1, acc150) on identical axes with smaller area.
    reg [3:0] rom_quant [0:7];
    reg [3:0] rom_order [0:7];
    reg [7:0] rom_acc   [0:7];
    reg [7:0] rom_sec   [0:7];
    reg [15:0]rom_area  [0:7];

    // ---- budget registers ----------------------------------------------------
    reg [15:0] max_area;
    reg [7:0]  min_acc;
    reg [7:0]  min_sec;

    // ---- combinatorial frontier computation ---------------------------------
    reg [0:7]  feas_c;
    reg [0:7]  pareto_c;
    reg [3:0]  fcnt_c, pcnt_c;
    reg [3:0]  sel_c;
    reg        nosol_c;
    integer i, j;
    reg        dom;
    always @(*) begin
        // step 1: feasibility filter
        fcnt_c = 4'd0;
        pcnt_c = 4'd0;
        for (i = 0; i < NCFG; i = i + 1) begin
            if (rom_area[i] <= max_area &&
                rom_acc[i]  >= min_acc  &&
                rom_sec[i]  >= min_sec) begin
                feas_c[i] = 1'b1;
                fcnt_c = fcnt_c + 4'd1;
            end else begin
                feas_c[i] = 1'b0;
            end
        end
        // step 2: non-dominated sort (reads feas_c[] just written above)
        for (i = 0; i < NCFG; i = i + 1) begin
            if (feas_c[i]) begin
                dom = 1'b0;
                for (j = 0; j < NCFG; j = j + 1) begin
                    if (j != i && feas_c[j]) begin
                        if ((rom_acc[j]  >= rom_acc[i]) &&
                            (rom_sec[j]  >= rom_sec[i]) &&
                            (rom_area[j] <= rom_area[i]) &&
                            ((rom_acc[j]  > rom_acc[i]) ||
                             (rom_sec[j]  > rom_sec[i]) ||
                             (rom_area[j] < rom_area[i])))
                            dom = 1'b1;
                    end
                end
                if (!dom) begin
                    pareto_c[i] = 1'b1;
                    pcnt_c = pcnt_c + 4'd1;
                end else begin
                    pareto_c[i] = 1'b0;
                end
            end else begin
                pareto_c[i] = 1'b0;
            end
        end
        // step 3: min-area Pareto point (lowest index)
        sel_c   = 4'd15;
        nosol_c = 1'b1;
        for (i = 0; i < NCFG; i = i + 1) begin
            if (pareto_c[i]) begin
                if (nosol_c || rom_area[i] < rom_area[sel_c])
                    sel_c = i[3:0];
                    nosol_c = 1'b0;
            end
        end
    end

    // ---- register map read ----------------------------------------------------
    reg [7:0] rd_mux;
    assign rd_data = rd_mux;
    always @(*) begin
        rd_mux = 8'd0;
        if (rd_valid) begin
            if      (rd_addr == R_MAXAREA) rd_mux = max_area[7:0];
            else if (rd_addr == R_MAXAREAH) rd_mux = max_area[15:8];
            else if (rd_addr == R_MINACC)  rd_mux = min_acc;
            else if (rd_addr == R_MINSEC)  rd_mux = min_sec;
            else if (rd_addr == R_SELIDX)  rd_mux = {4'b0, sel_idx};
            else if (rd_addr == R_FEASCNT) rd_mux = {4'b0, feasible_cnt};
            else if (rd_addr == R_PARSCNT) rd_mux = {4'b0, pareto_cnt};
            else if (rd_addr == R_NOSOL)   rd_mux = {7'b0, no_solution};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rom_quant[0]<=4'd4; rom_order[0]<=4'd1; rom_acc[0]<=8'd120; rom_sec[0]<=8'd40; rom_area[0]<=16'd100;
            rom_quant[1]<=4'd5; rom_order[1]<=4'd1; rom_acc[1]<=8'd150; rom_sec[1]<=8'd40; rom_area[1]<=16'd130;
            rom_quant[2]<=4'd6; rom_order[2]<=4'd1; rom_acc[2]<=8'd175; rom_sec[2]<=8'd40; rom_area[2]<=16'd160;
            rom_quant[3]<=4'd4; rom_order[3]<=4'd2; rom_acc[3]<=8'd125; rom_sec[3]<=8'd90; rom_area[3]<=16'd180;
            rom_quant[4]<=4'd5; rom_order[4]<=4'd2; rom_acc[4]<=8'd160; rom_sec[4]<=8'd90; rom_area[4]<=16'd210;
            rom_quant[5]<=4'd6; rom_order[5]<=4'd2; rom_acc[5]<=8'd185; rom_sec[5]<=8'd90; rom_area[5]<=16'd240;
            rom_quant[6]<=4'd7; rom_order[6]<=4'd3; rom_acc[6]<=8'd210; rom_sec[6]<=8'd140; rom_area[6]<=16'd350;
            rom_quant[7]<=4'd5; rom_order[7]<=4'd1; rom_acc[7]<=8'd140; rom_sec[7]<=8'd40; rom_area[7]<=16'd135;
            max_area  <= 16'd0;
            min_acc   <= 8'd0;
            min_sec   <= 8'd0;
            busy      <= 1'b0;
            done      <= 1'b0;
            error     <= 1'b0;
            sel_idx   <= 4'd0;
            feasible_cnt <= 4'd0;
            pareto_cnt   <= 4'd0;
            no_solution  <= 1'b0;
        end else begin
            if (wr_valid) begin
                if      (wr_addr == R_MAXAREA) max_area[7:0] <= wr_data;
                else if (wr_addr == R_MAXAREAH) max_area[15:8] <= wr_data;
                else if (wr_addr == R_MINACC)  min_acc  <= wr_data;
                else if (wr_addr == R_MINSEC)  min_sec  <= wr_data;
            end

            if (cmd_valid && !busy) begin
                case (cmd)
                    C_RESET: begin
                        max_area<=16'd0; min_acc<=8'd0; min_sec<=8'd0;
                        sel_idx<=4'd0; feasible_cnt<=4'd0; pareto_cnt<=4'd0;
                        no_solution<=1'b0; error<=1'b0; done<=1'b1;
                    end
                    C_BUDGET: begin
                        done <= 1'b1;
                    end
                    C_OPTIMIZE: begin
                        // latch the combinatorial frontier result
                        sel_idx     <= sel_c;
                        feasible_cnt<= fcnt_c;
                        pareto_cnt  <= pcnt_c;
                        no_solution <= nosol_c;
                        done <= 1'b1;
                    end
                    C_READ: begin
                        done <= 1'b1;
                    end
                    default: begin
                        error <= 1'b1;
                    end
                endcase
            end else if (!cmd_valid) begin
                done <= 1'b0;
            end
        end
    end

endmodule
