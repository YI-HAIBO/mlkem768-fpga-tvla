// =============================================================================
// A5: Joint Model-Watermark + Backdoor-Trigger Detection
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (A5: watermark + backdoor scan)
//
// Design goal: ONE verification pass over the deployed model tells you BOTH
//   (a) is this model the genuine, PUF-bound original?      (watermark)
//   (b) has a trigger pattern been planted in the model's
//       trigger-detector path that flips its output?         (backdoor)
//
// Watermark audit (bit-level, no modeling shortcut):
//   * host streams back the carrier weights, one bit per cycle, over
//     wscan_valid / wscan_bit (128 carriers for a 128-bit key)
//   * expected carrier bit i = expected_key[i]
//   * report: detected pattern, mismatch count, pass/mismatch flag
//   * PASS when flipped carriers <= TOLERANCE (0 = exact)
//
// Backdoor trigger audit (running statistics, no golden vector needed):
//   * the trigger-detector input stream is sampled on trig_valid /
//     trig_sample[31:0]
//   * a 16-bucket histogram over the low 4 bits is maintained: benign
//     (near-uniform) input spreads mass evenly; a planted TRIGGER pattern
//     concentrates mass in a handful of buckets
//   * suspicion rule 1: (max-min) > RATIO_THRESH * (total/16)
//   * suspicion rule 2: one exact 32-bit sample repeats more than
//     REPEAT_LIMIT times (classic trigger-key replay)
//
// Both audits share one host command and produce a 2-bit verdict:
//   2'b00 clean / 2'b01 watermark fail (cloned or tampered model)
//   2'b10 backdoor suspect / 2'b11 both
//
// Timing: watermark = WM_WIDTH cycles; trigger window ends after the host
// stops sending samples for SCAN_IDLE_MIN cycles; then one evaluation cycle.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module watermark_backdoor_scan #(
  parameter WM_WIDTH      = 128,   // watermark key width
  parameter NBITS         = 4,     // histogram address bits (16 buckets)
  parameter TOLERANCE     = 0,     // allowed flipped watermark carriers
  parameter RATIO_THRESH  = 8,     // (max-min)/(total/16) > this => suspect
  parameter REPEAT_LIMIT  = 16,    // identical-sample repeats allowed
  parameter SCAN_IDLE_MIN = 64     // idle cycles that close the window
)(
  input  wire                    clk,
  input  wire                    rst_n,

  // ---- control -------------------------------------------------------------
  input  wire                    scan_start,        // begin a full audit
  input  wire [WM_WIDTH-1:0]     expected_key,      // PUF-derived watermark
  output reg                     scan_busy,
  output reg                     scan_done,         // pulse when audit finished

  // ---- watermark audit stream (host reads back carrier weights) -------------
  input  wire                    wscan_valid,       // one carrier bit per cycle
  input  wire                    wscan_bit,

  // ---- backdoor trigger audit stream (trigger detector samples) --------------
  input  wire                    trig_valid,
  input  wire [31:0]             trig_sample,

  // ---- watermark report -----------------------------------------------------
  output reg  [WM_WIDTH-1:0]     wm_detected,       // read-back carrier bits
  output reg  [7:0]              wm_mismatch_count, // number of flipped bits
  output wire                    watermark_ok,

  // ---- backdoor report ------------------------------------------------------
  output reg  [31:0]             hist_max_count,    // max bucket population
  output reg  [31:0]             hist_min_count,    // min bucket population
  output reg  [31:0]             repeat_top_count,  // top identical-sample count
  output wire                    backdoor_suspect,

  // ---- joint verdict --------------------------------------------------------
  output reg  [1:0]              joint_verdict      // 00/01/10/11
);

  // -------------------------------------------------------------------------
  // FSM
  // -------------------------------------------------------------------------
  localparam [3:0]
    S_IDLE    = 4'd0,
    S_WM_SCAN = 4'd1,   // watermark carrier read-back
    S_WM_EVAL = 4'd2,
    S_BD_ACC  = 4'd3,   // trigger histogram accumulation
    S_BD_EVAL = 4'd4,
    S_REPORT  = 4'd5;

  reg [3:0]  state;
  reg [15:0] idle_cnt;

  // -------------------------------------------------------------------------
  // Watermark audit state
  // -------------------------------------------------------------------------
  reg [7:0]  wm_idx;                  // carrier index (0..WM_WIDTH-1)
  reg [7:0]  wm_mismatch;
  reg [WM_WIDTH-1:0] wm_detect;

  wire wm_bit_expect = expected_key[wm_idx[6:0]];

  // -------------------------------------------------------------------------
  // Backdoor trigger histogram
  // -------------------------------------------------------------------------
  reg [31:0] hist [0:(1<<NBITS)-1];
  reg [31:0] sample_total;
  reg [31:0] last_sample;
  reg [31:0] run_count;
  reg [31:0] top_repeat;

  wire [NBITS-1:0] bucket = trig_sample[NBITS-1:0];

  integer k;

  // -------------------------------------------------------------------------
  // min/max reduction over the histogram (combinational, reads hist)
  // -------------------------------------------------------------------------
  reg [31:0] hm_max, hm_min;

  always @* begin
    hm_max = hist[0];
    hm_min = hist[0];
    for (k = 1; k < (1 << NBITS); k = k + 1) begin
      if (hist[k] > hm_max) hm_max = hist[k];
      if (hist[k] < hm_min) hm_min = hist[k];
    end
  end

  // -------------------------------------------------------------------------
  // Report flags
  // -------------------------------------------------------------------------
  wire hist_concentrated = (sample_total >= (1 << NBITS)) &&
                           ((hm_max - hm_min) >
                            (RATIO_THRESH * (sample_total >> NBITS)));
  wire replay_detected  = (repeat_top_count > REPEAT_LIMIT);

  assign watermark_ok     = (wm_mismatch_count <= TOLERANCE);
  assign backdoor_suspect = hist_concentrated | replay_detected;

  // -------------------------------------------------------------------------
  // FSM
  // -------------------------------------------------------------------------
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state            <= S_IDLE;
      scan_busy        <= 1'b0;
      scan_done        <= 1'b0;
      wm_idx           <= 8'd0;
      wm_mismatch      <= 8'd0;
      wm_detect        <= {WM_WIDTH{1'b0}};
      wm_detected      <= {WM_WIDTH{1'b0}};
      wm_mismatch_count<= 8'd0;
      hist_max_count   <= 32'd0;
      hist_min_count   <= 32'd0;
      repeat_top_count <= 32'd0;
      joint_verdict    <= 2'b00;
      sample_total     <= 32'd0;
      last_sample      <= 32'd0;
      run_count        <= 32'd0;
      top_repeat       <= 32'd0;
      idle_cnt         <= 16'd0;
      for (k = 0; k < (1 << NBITS); k = k + 1)
        hist[k] <= 32'd0;
    end else begin
      scan_done <= 1'b0;

      case (state)
        S_IDLE: begin
          if (scan_start) begin
            scan_busy   <= 1'b1;
            wm_idx      <= 8'd0;
            wm_mismatch <= 8'd0;
            wm_detect   <= {WM_WIDTH{1'b0}};
            sample_total<= 32'd0;
            last_sample <= 32'hFFFF_FFFF;   // force a run break at sample 0
            run_count   <= 32'd0;
            top_repeat  <= 32'd0;
            idle_cnt    <= 16'd0;
            for (k = 0; k < (1 << NBITS); k = k + 1)
              hist[k] <= 32'd0;
            state       <= S_WM_SCAN;
          end
        end

        S_WM_SCAN: begin
          if (wscan_valid) begin
            wm_detect[wm_idx[6:0]] <= wscan_bit;
            if (wscan_bit !== wm_bit_expect)
              wm_mismatch <= wm_mismatch + 8'd1;
            if (wm_idx == WM_WIDTH - 1)
              state <= S_WM_EVAL;
            else
              wm_idx <= wm_idx + 8'd1;
          end
        end

        S_WM_EVAL: begin
          wm_detected       <= wm_detect;
          wm_mismatch_count <= wm_mismatch;
          state             <= S_BD_ACC;
        end

        S_BD_ACC: begin
          if (trig_valid) begin
            hist[bucket]  <= hist[bucket] + 32'd1;
            sample_total  <= sample_total + 32'd1;
            if (trig_sample == last_sample) begin
              run_count <= run_count + 32'd1;
              if (run_count + 32'd1 > top_repeat)
                top_repeat <= run_count + 32'd1;
            end else begin
              last_sample <= trig_sample;
              run_count   <= 32'd1;
              if (32'd1 > top_repeat)
                top_repeat <= 32'd1;
            end
            idle_cnt <= 16'd0;
          end else begin
            // close the audit window once the host stops streaming
            if (idle_cnt >= SCAN_IDLE_MIN) begin
              idle_cnt <= 16'd0;
              state    <= S_BD_EVAL;
            end else begin
              idle_cnt <= idle_cnt + 16'd1;
            end
          end
        end

        S_BD_EVAL: begin
          hist_max_count   <= hm_max;
          hist_min_count   <= hm_min;
          repeat_top_count <= top_repeat;
          state            <= S_REPORT;
        end

        S_REPORT: begin
          joint_verdict <= {backdoor_suspect, !watermark_ok};
          scan_done     <= 1'b1;
          scan_busy     <= 1'b0;
          state         <= S_IDLE;
        end

        default: state <= S_IDLE;
      endcase
    end
  end

endmodule

`default_nettype wire
