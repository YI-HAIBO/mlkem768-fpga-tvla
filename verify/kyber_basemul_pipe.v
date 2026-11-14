`default_nettype none

// =============================================================================
// kyber_basemul_pipe — systolic pipelined pointwise NTT-domain multiplication
//
// Route C (Task 89 closure): the original kyber_basemul computed the whole
// basemul (4 chained fqmul) in ONE cycle -> ~41.6 ns combinational path
// (poly_b_reg -> poly_r_reg), which did NOT close 100 MHz (pre-route WNS
// -31.593 ns, t89c100).
//
// This version splits the basemul arithmetic into a 6-stage systolic pipeline
// that processes ONE 2-element slice per cycle. Each stage contains at most
// ONE multiplier level + small logic, so the per-stage path is well under
// 10 ns (100 MHz). Throughput: 1 slice/cycle, 128 slices (64 zeta idx x 2
// pairs), + 6-cycle latency = 134 cycles (vs 64 before). The module interface
// is IDENTICAL to kyber_basemul; the KEM FSM waits on `done` and is agnostic
// to the longer latency.
//
// Slice indexing (slice s = 0..127):
//   zeta_idx = s >> 1   (0..63),  pair = s & 1  (0 = +zeta, 1 = -zeta)
//   base     = 4*zeta_idx + 2*pair
//   a0=a[base], a1=a[base+1], b0=b[base], b1=b[base+1]
//   zeta     = pair==0 ? zetas[64+zeta_idx] : (Q - zetas[64+zeta_idx])
//   r0 = fqmul(fqmul(a1,b1),zeta) + fqmul(a0,b0)   (mod 2^BW)
//   r1 = fqmul(a0,b1) + fqmul(a1,b0)               (mod 2^BW)
//   write poly_r[base]=r0, poly_r[base+1]=r1
//
// Pipeline stages (each = 1 register):
//   r1: a0,a1,b0,b1,zeta,wa,valid      (feed: array read + zeta mux)
//   r2: P00,P01,P10,P11,zeta,wa,valid  (4 parallel 16x16 products)
//   r3: t00,t01,t10,t11,P00..P11,...   (montgomery step 1: t_low)
//   r4: m00,m01,m10,m11,zeta,wa,valid  (montgomery step 2: m values)
//   r5: m11z_raw (m11*zeta), s1, m00, wa, valid
//   r6: t_z (m11z_raw[15:0]*62209), m11z_raw, m00, s1, wa, valid
//   write: r0 = mred2(m11z_raw,t_z) + m00; r1 = s1
// =============================================================================
module kyber_basemul_pipe #(
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
