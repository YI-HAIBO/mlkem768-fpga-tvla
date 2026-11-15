// =============================================================================
// CRYSTALS-Kyber Polynomial Operations
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec
// Ring     : Zq[X]/(X^256+1),  q = 3329
//
// Operations:
//   poly_add    : r[i] = barrett_reduce(a[i] + b[i])
//   poly_sub    : r[i] = barrett_reduce(a[i] - b[i])
//   poly_basemul_montgomery: pointwise NTT-domain multiply (64 basemul pairs)
//   poly_tomont  : r[i] = fqmul(a[i], R^2 mod q)   // R^2 = 1353
//   poly_frommont: r[i] = fqmul(a[i], 1)            // Montgomery → regular
//
// Arithmetic: same Montgomery/Barrett as kyber_ntt.v
//   R mod q = 2285,  R^2 mod q = 1353,  QINV = 62209
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module kyber_poly #(
    parameter N  = 256,
    parameter Q  = 3329,
    parameter BW = 16
)(
    input  wire                clk,
    input  wire                rst_n,

    input  wire                start,
    input  wire                op_add,      // 1 = add, 0 = sub (for poly_add/sub)
    output reg                 busy,
    output reg                 done,

    // Polynomial A load
    input  wire                a_load,
    input  wire [7:0]          a_addr,
    input  wire [BW-1:0]       a_data,

    // Polynomial B load
    input  wire                b_load,
    input  wire [7:0]          b_addr,
    input  wire [BW-1:0]       b_data,

    // Result read
    input  wire [7:0]          r_addr,
    output wire [BW-1:0]       r_data
);

    // -------------------------------------------------------------------------
    // Polynomial register files
    // -------------------------------------------------------------------------
    reg [BW-1:0] poly_a [0:N-1];
    reg [BW-1:0] poly_b [0:N-1];
    reg [BW-1:0] poly_r [0:N-1];

    // -------------------------------------------------------------------------
    // Modular arithmetic (same as kyber_ntt.v)
    // -------------------------------------------------------------------------
    function [BW-1:0] montgomery_reduce;
        input [31:0] a;
        reg [15:0]  t_low;
        reg [31:0]  t_signed;
        reg [31:0]  result;
        begin
            t_low    = (a[15:0] * 16'd62209) & 16'hFFFF;
            t_signed = { {16{t_low[15]}}, t_low };
            result   = ($signed(a) - (t_signed * 32'd3329)) >>> 16;
            montgomery_reduce = result[BW-1:0];
        end
    endfunction

    function [BW-1:0] fqmul;
        input [BW-1:0] a;
        input [BW-1:0] b;
        reg [31:0] prod;
        begin
            prod = $signed(a) * $signed(b);
            fqmul = montgomery_reduce(prod);
        end
    endfunction

    function [BW-1:0] barrett_reduce;
        input [BW-1:0] a;
        reg signed [31:0] v_a;
        reg signed [31:0] t;
        reg signed [31:0] result;
        begin
            v_a    = 32'sd20159 * $signed(a);
            t      = (v_a + 32'sd33554432) >>> 26;   // arithmetic shift
            result = $signed(a) - (t * 32'sd3329);
            barrett_reduce = result[BW-1:0];
        end
    endfunction

    // -------------------------------------------------------------------------
    // FSM for poly_add / poly_sub (coefficient-wise, 256 cycles)
    // -------------------------------------------------------------------------
    localparam [1:0] S_IDLE = 2'd0,
                     S_OP   = 2'd1,
                     S_DONE = 2'd2;

    reg [1:0]  state;
    reg [8:0]  cnt;        // 9 bits: must count to 256 to exit S_OP
    reg        add_mode;

    integer gi;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= S_IDLE;
            busy    <= 1'b0;
            done    <= 1'b0;
            cnt     <= 9'd0;
            add_mode <= 1'b0;
            for (gi = 0; gi < N; gi = gi + 1) begin
                poly_a[gi] <= {BW{1'b0}};
                poly_b[gi] <= {BW{1'b0}};
                poly_r[gi] <= {BW{1'b0}};
            end
        end else begin
            done <= 1'b0;

            // Load interfaces
            if (a_load) poly_a[a_addr] <= a_data;
            if (b_load) poly_b[b_addr] <= b_data;

            case (state)
                S_IDLE: begin
                    if (start) begin
                        busy    <= 1'b1;
                        add_mode <= op_add;
                        cnt     <= 9'd0;
                        state   <= S_OP;
                    end
                end

                S_OP: begin
                    if (cnt < N) begin
                        if (add_mode)
                            poly_r[cnt] <= barrett_reduce(poly_a[cnt] + poly_b[cnt]);
                        else
                            poly_r[cnt] <= barrett_reduce(poly_a[cnt] - poly_b[cnt]);
                        cnt <= cnt + 8'd1;
                    end else begin
                        state <= S_DONE;
                    end
                end

                S_DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    assign r_data = poly_r[r_addr];

endmodule

// =============================================================================
// kyber_basemul: Pointwise NTT-domain polynomial multiplication
// -----------------------------------------------------------------------------
// Performs 64 basemul operations on two NTT-domain polynomials.
//   For i = 0..63:
//     basemul(r[4i], r[4i+1], a[4i], a[4i+1], b[4i], b[4i+1], zetas[64+i])
//     basemul(r[4i+2], r[4i+3], a[4i+2], a[4i+3], b[4i+2], b[4i+3], -zetas[64+i])
// =============================================================================

module kyber_basemul #(
    parameter N  = 256,
    parameter Q  = 3329,
    parameter BW = 16
)(
    input  wire                clk,
    input  wire                rst_n,

    input  wire                start,
    output reg                 busy,
    output reg                 done,

    input  wire                a_load,
    input  wire [7:0]          a_addr,
    input  wire [BW-1:0]       a_data,

    input  wire                b_load,
    input  wire [7:0]          b_addr,
    input  wire [BW-1:0]       b_data,

    input  wire [7:0]          r_addr,
    output wire [BW-1:0]       r_data
);

    reg [BW-1:0] poly_a [0:N-1];
    reg [BW-1:0] poly_b [0:N-1];
    reg [BW-1:0] poly_r [0:N-1];

    // Zeta ROM (64 entries: zetas[64..127]) — same as kyber_basemul.
    function [BW-1:0] get_zeta64;
        input [5:0] zidx;
        begin
            case (zidx)
            6'd0: get_zeta64 = 16'd2226;
            6'd1: get_zeta64 = 16'd430;
            6'd2: get_zeta64 = 16'd555;
            6'd3: get_zeta64 = 16'd843;
            6'd4: get_zeta64 = 16'd2078;
            6'd5: get_zeta64 = 16'd871;
            6'd6: get_zeta64 = 16'd1550;
            6'd7: get_zeta64 = 16'd105;
            6'd8: get_zeta64 = 16'd422;
            6'd9: get_zeta64 = 16'd587;
            6'd10: get_zeta64 = 16'd177;
            6'd11: get_zeta64 = 16'd3094;
            6'd12: get_zeta64 = 16'd3038;
            6'd13: get_zeta64 = 16'd2869;
            6'd14: get_zeta64 = 16'd1574;
            6'd15: get_zeta64 = 16'd1653;
            6'd16: get_zeta64 = 16'd3083;
            6'd17: get_zeta64 = 16'd778;
            6'd18: get_zeta64 = 16'd1159;
            6'd19: get_zeta64 = 16'd3182;
            6'd20: get_zeta64 = 16'd2552;
            6'd21: get_zeta64 = 16'd1483;
            6'd22: get_zeta64 = 16'd2727;
            6'd23: get_zeta64 = 16'd1119;
            6'd24: get_zeta64 = 16'd1739;
            6'd25: get_zeta64 = 16'd644;
            6'd26: get_zeta64 = 16'd2457;
            6'd27: get_zeta64 = 16'd349;
            6'd28: get_zeta64 = 16'd418;
            6'd29: get_zeta64 = 16'd329;
            6'd30: get_zeta64 = 16'd3173;
            6'd31: get_zeta64 = 16'd3254;
            6'd32: get_zeta64 = 16'd817;
            6'd33: get_zeta64 = 16'd1097;
            6'd34: get_zeta64 = 16'd603;
            6'd35: get_zeta64 = 16'd610;
            6'd36: get_zeta64 = 16'd1322;
            6'd37: get_zeta64 = 16'd2044;
            6'd38: get_zeta64 = 16'd1864;
            6'd39: get_zeta64 = 16'd384;
            6'd40: get_zeta64 = 16'd2114;
            6'd41: get_zeta64 = 16'd3193;
            6'd42: get_zeta64 = 16'd1218;
            6'd43: get_zeta64 = 16'd1994;
            6'd44: get_zeta64 = 16'd2455;
            6'd45: get_zeta64 = 16'd220;
            6'd46: get_zeta64 = 16'd2142;
            6'd47: get_zeta64 = 16'd1670;
            6'd48: get_zeta64 = 16'd2144;
            6'd49: get_zeta64 = 16'd1799;
            6'd50: get_zeta64 = 16'd2051;
            6'd51: get_zeta64 = 16'd794;
            6'd52: get_zeta64 = 16'd1819;
            6'd53: get_zeta64 = 16'd2475;
            6'd54: get_zeta64 = 16'd2459;
            6'd55: get_zeta64 = 16'd478;
            6'd56: get_zeta64 = 16'd3221;
            6'd57: get_zeta64 = 16'd3021;
            6'd58: get_zeta64 = 16'd996;
            6'd59: get_zeta64 = 16'd991;
            6'd60: get_zeta64 = 16'd958;
            6'd61: get_zeta64 = 16'd1869;
            6'd62: get_zeta64 = 16'd1522;
            6'd63: get_zeta64 = 16'd1628;
            default: get_zeta64 = 16'd0;
            endcase
        end
    endfunction

    // Montgomery step 2: m = (P - sext(t_low)*Q) >>> 16  (return low BW bits)
    function [BW-1:0] mred2;
        input signed [31:0] P;
        input [15:0] t;
        reg signed [31:0] res;
        begin
            res = ($signed(P) - ($signed({{16{t[15]}}, t}) * 32'sd3329)) >>> 16;
            mred2 = res[BW-1:0];
        end
    endfunction

    // Pipeline stage registers
    reg [BW-1:0] r1_a0, r1_a1, r1_b0, r1_b1, r1_zeta;
    reg [8:0]    r1_wa;
    reg          r1_v;
    reg signed [31:0] r2_P00, r2_P01, r2_P10, r2_P11;
    reg [BW-1:0] r2_zeta;
    reg [8:0]    r2_wa;
    reg          r2_v;
    reg [15:0] r3_t00, r3_t01, r3_t10, r3_t11;
    reg signed [31:0] r3_P00, r3_P01, r3_P10, r3_P11;
    reg [BW-1:0] r3_zeta;
    reg [8:0]    r3_wa;
    reg          r3_v;
    reg [BW-1:0] r4_m00, r4_m01, r4_m10, r4_m11;
    reg [BW-1:0] r4_zeta;
    reg [8:0]    r4_wa;
    reg          r4_v;
    reg signed [31:0] r5_m11z;
    reg [BW-1:0] r5_s1, r5_m00;
    reg [8:0]    r5_wa;
    reg          r5_v;
    reg [15:0] r6_tz;
    reg signed [31:0] r6_m11z;
    reg [BW-1:0] r6_m00, r6_s1;
    reg [8:0]    r6_wa;
    reg          r6_v;

    // FSM
    localparam [1:0] S_IDLE = 2'd0,
                     S_OP   = 2'd1,
                     S_DONE = 2'd2;
    reg [1:0] state;
    reg [7:0] scl;        // slice counter 0..127 (feed index)
    reg [7:0] cyc;        // cycle counter in S_OP (0..133)

    wire [6:0] zidx_w = scl[7:1];                       // scl >> 1
    wire       pair_w = scl[0];                         // scl & 1
    wire [8:0] base_w = ({2'd0, zidx_w} << 2) | ({8'd0, pair_w} << 1);
    wire [BW-1:0] zv_w   = get_zeta64(zidx_w);
    wire [BW-1:0] zeta_w = pair_w ? ((Q - zv_w) & {BW{1'b1}}) : zv_w;

    integer gi;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state  <= S_IDLE;
            busy   <= 1'b0;
            done   <= 1'b0;
            scl    <= 8'd0;
            cyc    <= 8'd0;
            r1_v   <= 1'b0; r2_v <= 1'b0; r3_v <= 1'b0;
            r4_v   <= 1'b0; r5_v <= 1'b0; r6_v <= 1'b0;
            for (gi = 0; gi < N; gi = gi + 1) begin
                poly_a[gi] <= {BW{1'b0}};
                poly_b[gi] <= {BW{1'b0}};
                poly_r[gi] <= {BW{1'b0}};
            end
        end else begin
            done <= 1'b0;

            if (a_load) poly_a[a_addr] <= a_data;
            if (b_load) poly_b[b_addr] <= b_data;

            case (state)
                S_IDLE: begin
                    if (start) begin
                        busy  <= 1'b1;
                        scl   <= 8'd0;
                        cyc   <= 8'd0;
                        r1_v  <= 1'b0; r2_v <= 1'b0; r3_v <= 1'b0;
                        r4_v  <= 1'b0; r5_v <= 1'b0; r6_v <= 1'b0;
                        state <= S_OP;
                    end
                end

                S_OP: begin
                    // ---- Feed stage (capture into r1) ----
                    if (scl < 8'd128) begin
                        r1_a0  <= poly_a[base_w[7:0]];
                        r1_a1  <= poly_a[base_w[7:0] + 8'd1];
                        r1_b0  <= poly_b[base_w[7:0]];
                        r1_b1  <= poly_b[base_w[7:0] + 8'd1];
                        r1_zeta<= zeta_w;
                        r1_wa  <= base_w;
                        r1_v   <= 1'b1;
                        scl    <= scl + 8'd1;
                    end else begin
                        r1_v   <= 1'b0;   // drain: no valid feed
                    end

                    // ---- r1 -> r2: 4 parallel products ----
                    r2_P00 <= $signed(r1_a0) * $signed(r1_b0);
                    r2_P01 <= $signed(r1_a0) * $signed(r1_b1);
                    r2_P10 <= $signed(r1_a1) * $signed(r1_b0);
                    r2_P11 <= $signed(r1_a1) * $signed(r1_b1);
                    r2_zeta<= r1_zeta;
                    r2_wa  <= r1_wa;
                    r2_v   <= r1_v;

                    // ---- r2 -> r3: montgomery step 1 (t_low) ----
                    r3_t00 <= (r2_P00[15:0] * 16'd62209) & 16'hFFFF;
                    r3_t01 <= (r2_P01[15:0] * 16'd62209) & 16'hFFFF;
                    r3_t10 <= (r2_P10[15:0] * 16'd62209) & 16'hFFFF;
                    r3_t11 <= (r2_P11[15:0] * 16'd62209) & 16'hFFFF;
                    r3_P00 <= r2_P00;
                    r3_P01 <= r2_P01;
                    r3_P10 <= r2_P10;
                    r3_P11 <= r2_P11;
                    r3_zeta<= r2_zeta;
                    r3_wa  <= r2_wa;
                    r3_v   <= r2_v;

                    // ---- r3 -> r4: montgomery step 2 (m values) ----
                    r4_m00 <= mred2(r3_P00, r3_t00);
                    r4_m01 <= mred2(r3_P01, r3_t01);
                    r4_m10 <= mred2(r3_P10, r3_t10);
                    r4_m11 <= mred2(r3_P11, r3_t11);
                    r4_zeta<= r3_zeta;
                    r4_wa  <= r3_wa;
                    r4_v   <= r3_v;

                    // ---- r4 -> r5: m11*zeta (raw) + s1 = m01+m10 ----
                    r5_m11z<= $signed(r4_m11) * $signed(r4_zeta);
                    r5_s1  <= r4_m01 + r4_m10;   // 16-bit wrap, matches original
                    r5_m00 <= r4_m00;
                    r5_wa  <= r4_wa;
                    r5_v   <= r4_v;

                    // ---- r5 -> r6: t_z (montgomery step 1 of m11z) ----
                    r6_tz  <= (r5_m11z[15:0] * 16'd62209) & 16'hFFFF;
                    r6_m11z<= r5_m11z;
                    r6_m00 <= r5_m00;
                    r6_s1  <= r5_s1;
                    r6_wa  <= r5_wa;
                    r6_v   <= r5_v;

                    // ---- Terminal write from r6 ----
                    if (r6_v) begin
                        poly_r[r6_wa[7:0]] <= mred2(r6_m11z, r6_tz) + r6_m00;   // 16-bit wrap
                        poly_r[r6_wa[7:0] + 8'd1] <= r6_s1;
                    end

                    // ---- Cycle accounting ----
                    cyc <= cyc + 8'd1;
                    if (cyc >= 8'd133) begin
                        state <= S_DONE;
                    end
                end

                S_DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    assign r_data = poly_r[r_addr];

endmodule


`default_nettype wire