// =============================================================================
// B3: TVLA Online Self-Test (fixed-vs-random Welch T-test, division-free)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (B3: online leakage detection)
//
// TVLA (Test Vector Leakage Assessment) is the de-facto acceptance test for
// side-channel countermeasures: run the crypto operation N times with a FIXED
// key and N times with RANDOM keys, capture one leakage sample per run, and
// Welch-compare the two groups. |t| > 4.5 means the two distributions differ
// beyond noise -> the implementation LEAKS secret-dependent information.
//
// Doing this ONLINE, inside the FPGA, means the chip reports its own leakage
// health instead of waiting for a lab oscilloscope campaign.
//
// Math (population variance, n1 = n2 = n = 2^k so every division is a shift):
//     S_i = sum of group i samples,  Q_i = sum of squares
//     mean_i = S_i / n ,  var_i = Q_i / n - mean_i^2
//     t = (mean1 - mean2) / sqrt((var1 + var2) / n)
//       = (S1 - S2) * n / sqrt(D) ,  D = n*(Q1 + Q2) - S1^2 - S2^2
//   t^2 = n * (S1 - S2)^2 / D
//   |t| > 4.5  <=>  t^2 > 20.25  <=>  4*n*d^2 > 81*D
//                          (n = 2^k:  d^2 << (k+2) > 81*D)
// D is always >= 0 (it equals n^2 * (var1 + var2)), so the comparison is a
// plain unsigned integer compare. Degenerate D == 0 (both groups constant):
// leak <=> d != 0, reported with the `degenerate` flag.
//
// Batch protocol: samples stream in continuously (sample_valid +
// sample_fixed selects the group). When BOTH groups hold n samples the
// module auto-evaluates (5-cycle integer pipeline), pulses batch_done, and
// restarts accumulation for the next batch. leak_detected is latched at each
// batch_done and held until the next evaluation -> it is always readable.
// Up to 5 samples arriving during the evaluation window are dropped; a
// continuous online deployment is expected to stall sample_valid while
// batch_ready is asserted.
//
// Parameter guard: the 64-bit evaluation path holds for N_LOG2 <= 14.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module tvla_online #(
    parameter SAMPLE_W = 6,          // leakage sample width (HW proxy, 6-bit)
    parameter N_LOG2   = 12,         // n = 2^12 = 4096 samples per group
    parameter THRESH2  = 81          // 4*T^2 for the |t| > T rule (T=4.5 -> 81)
)(
    input  wire        clk,
    input  wire        rst_n,

    // leakage sample stream (the probe point, e.g. Hamming weight of a bus)
    input  wire        sample_valid,
    input  wire [SAMPLE_W-1:0] sample,
    input  wire        sample_fixed,   // 1 -> fixed-key group, 0 -> random group

    input  wire        batch_restart,  // drop the partial batch, start clean

    output wire        batch_ready,    // both groups full, evaluating
    output reg         batch_done,     // one-cycle pulse: evaluation complete
    output reg         leak_detected,  // |t| > 4.5 (latched, always readable)
    output reg         degenerate,     // D == 0 (constant-group case)

    // observation ports (host readout / verification)
    output wire [N_LOG2:0]       cnt_fixed, cnt_random,
    output wire [N_LOG2+SAMPLE_W-1:0]     sum_fixed, sum_random,
    output wire [N_LOG2+2*SAMPLE_W-1:0]   sq_fixed, sq_random
);
    localparam integer N = (1 << N_LOG2);

    // sum width: n * (2^SAMPLE_W - 1) < 2^(N_LOG2+SAMPLE_W)
    localparam integer SUMW = N_LOG2 + SAMPLE_W;
    localparam integer SQW  = N_LOG2 + 2*SAMPLE_W;

    reg [N_LOG2:0] cf, cr;              // group counters (0..n)
    reg [SUMW-1:0] sf, sr;              // group sums
    reg [SQW-1:0]  qf, qr;              // group sums of squares

    assign cnt_fixed  = cf;
    assign cnt_random = cr;
    assign sum_fixed  = sf;
    assign sum_random = sr;
    assign sq_fixed   = qf;
    assign sq_random  = qr;

    assign batch_ready = (cf == N) && (cr == N);

    // evaluation pipeline (all 64-bit)
    localparam [2:0]
        ST_ACC = 3'd0,
        ST_E1  = 3'd1,
        ST_E2  = 3'd2,
        ST_E3  = 3'd3,
        ST_E4  = 3'd4,
        ST_E5  = 3'd5;

    reg [2:0]           cstate;
    reg signed [63:0]   d;               // S1 - S2
    reg [63:0]          e1, e2;          // S1^2, S2^2
    reg [63:0]          qq;              // Q1 + Q2
    reg [63:0]          DD;              // n*(Q1+Q2) - S1^2 - S2^2  (>= 0)
    reg [63:0]          d2, lhs, rhs;

    // |d| as an unsigned SUMW-bit value: d = S1 - S2 with |d| < 2^SUMW, so the
    // two's complement of the low SUMW bits equals the magnitude.  Squaring |d|
    // (unsigned) instead of d (signed) lets the 18x18 product fit in a single
    // DSP48E1 (25x18) instead of a 3-4 DSP signed-multiply cascade, which is the
    // critical path at 100 MHz on Artix-7.
    wire [SUMW-1:0] d_abs = d[63] ? (~d[SUMW-1:0] + 1'b1) : d[SUMW-1:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cstate <= ST_ACC;
            cf <= {(N_LOG2+1){1'b0}};
            cr <= {(N_LOG2+1){1'b0}};
            sf <= {SUMW{1'b0}};
            sr <= {SUMW{1'b0}};
            qf <= {SQW{1'b0}};
            qr <= {SQW{1'b0}};
            batch_done <= 1'b0;
            leak_detected <= 1'b0;
            degenerate <= 1'b0;
            d  <= 64'sd0;
            e1 <= 64'd0; e2 <= 64'd0;
            qq <= 64'd0; DD <= 64'd0;
            d2 <= 64'd0; lhs <= 64'd0; rhs <= 64'd0;
        end else begin
            batch_done <= 1'b0;

            // batch_restart wins over everything
            if (batch_restart) begin
                cstate <= ST_ACC;
                cf <= {(N_LOG2+1){1'b0}};
                cr <= {(N_LOG2+1){1'b0}};
                sf <= {SUMW{1'b0}};
                sr <= {SUMW{1'b0}};
                qf <= {SQW{1'b0}};
                qr <= {SQW{1'b0}};
            end else begin
                // sample accumulation (dropped while evaluating or group full)
                if (sample_valid && cstate == ST_ACC) begin
                    if (sample_fixed && cf < N) begin
                        sf <= sf + {{(SUMW-SAMPLE_W){1'b0}}, sample};
                        qf <= qf + sample * sample;
                        cf <= cf + 1'b1;
                    end else if (!sample_fixed && cr < N) begin
                        sr <= sr + {{(SUMW-SAMPLE_W){1'b0}}, sample};
                        qr <= qr + sample * sample;
                        cr <= cr + 1'b1;
                    end
                end

                case (cstate)
                    ST_ACC: if (batch_ready) cstate <= ST_E1;

                    // stage 1: d = S1 - S2 ; e1 = S1^2
                    ST_E1: begin
                        d  <= $signed({{(64-SUMW){1'b0}}, sf}) -
                             $signed({{(64-SUMW){1'b0}}, sr});
                        e1 <= sf * sf;
                        cstate <= ST_E2;
                    end

                    // stage 2: e2 = S2^2 ; qq = Q1 + Q2
                    ST_E2: begin
                        e2 <= sr * sr;
                        qq <= {32'd0, qf} + {32'd0, qr};
                        cstate <= ST_E3;
                    end

                    // stage 3: D = n*(Q1+Q2) - S1^2 - S2^2 ; d^2
                    ST_E3: begin
                        DD <= (qq << N_LOG2) - e1 - e2;
                        d2 <= d_abs * d_abs;
                        cstate <= ST_E4;
                    end

                    // stage 4: lhs = 4*n*d^2 = d^2 << (k+2); rhs = THRESH2*D
                    ST_E4: begin
                        lhs <= d2 << (N_LOG2 + 2);
                        rhs <= THRESH2 * DD;
                        cstate <= ST_E5;
                    end

                    // stage 5: decision, report, restart the next batch
                    ST_E5: begin
                        if (DD == 64'd0) begin
                            degenerate     <= 1'b1;
                            leak_detected  <= (d != 64'sd0);
                        end else begin
                            degenerate     <= 1'b0;
                            leak_detected  <= (lhs > rhs);
                        end
                        batch_done <= 1'b1;
                        // auto-restart accumulation for the next batch
                        cf <= {(N_LOG2+1){1'b0}};
                        cr <= {(N_LOG2+1){1'b0}};
                        sf <= {SUMW{1'b0}};
                        sr <= {SUMW{1'b0}};
                        qf <= {SQW{1'b0}};
                        qr <= {SQW{1'b0}};
                        cstate <= ST_ACC;
                    end

                    default: cstate <= ST_ACC;
                endcase
            end
        end
    end

endmodule

`default_nettype wire
