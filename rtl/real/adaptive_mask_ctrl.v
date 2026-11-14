// =============================================================================
// A3: Adaptive Masking-Strength Decision (AI-driven)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (A3: adaptive masking)
//
// Design goal: let the AI threat detector (ai_threat_detector / lstm_inference)
// SET the security posture of the masked datapath dynamically, instead of
// hard-wiring a single fixed masking order.
//
//   threat_level (2-bit, from AI)  ──►  ┌──────────────┐──► mask_order
//   hard_attack_flag (TVLA/probe)  ──►  │ hysteresis + │──► jitter_max
//   health_ok (TRNG/PUF)           ──►  │ rate limit   │──► remask_interval
//                                       └──────────────┘──► alert_latch
//
// Security posture mapping (mask_order: 1 = 1st-order 2 shares,
//                                          2 = 2nd-order 3 shares ISW):
//
//   threat 0 (none) : order 1, jitter_max= 4, remask_interval= 64
//   threat 1 (low)  : order 1, jitter_max= 8, remask_interval= 16
//   threat 2 (med)  : order 2, jitter_max=12, remask_interval=  4
//   threat 3 (high) : order 2, jitter_max=16, remask_interval=  1
//
// Hysteresis (anti-flip-flop and attacker-proof):
//   * escalation (up)   requires ESC_UP cycles of sustained higher threat
//   * de-escalation     requires ESC_DN cycles of sustained lower threat,
//     with ESC_DN >> ESC_UP. An attacker who can inject a few clean-looking
//     traces cannot ride the level back down to weak masking quickly.
//
// Emergency override: hard_attack_flag pins the posture to maximum
// IMMEDIATELY (combinationally, before the counters) and sets a sticky
// alert_latch that only rst_n can clear.
//
// Entropy failure: if health_ok drops, posture is forced to at least
// first-order masking (order >= 1) with default jitter, because unmasked
// operation under a broken RNG is strictly worse.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module adaptive_mask_ctrl #(
    parameter ESC_UP   = 8,     // sustained cycles needed to escalate
    parameter ESC_DN   = 256,   // sustained cycles needed to de-escalate (>> ESC_UP)
    parameter MAX_JITTER = 16    // must match jitter_ctrl MAX_DELAY
)(
    input  wire        clk,
    input  wire        rst_n,

    // ---- AI side -----------------------------------------------------------
    input  wire [1:0]  threat_level,    // 0 none, 1 low, 2 medium, 3 high
    input  wire        threat_valid,    // pulse: new AI verdict available

    // ---- hard sensors ------------------------------------------------------
    input  wire        hard_attack_flag,// TVLA fail / probing detected -> pin max
    input  wire        health_ok,       // TRNG/PUF fused health (A2)

    // ---- posture outputs ---------------------------------------------------
    output reg  [1:0]  mask_order,      // 0 none, 1 first-order, 2 second-order
    output reg  [7:0]  jitter_max,      // max jitter cycles for jitter_ctrl
    output reg  [7:0]  remask_interval, // re-mask every N cycles
    output reg         alert_latch,     // sticky alert until reset
    output reg  [1:0]  posture_level    // effective level actually applied
);

    // -------------------------------------------------------------------------
    // Posture table
    // -------------------------------------------------------------------------
    // level -> (order, jitter_max, remask_interval)
    function [1:0] level_to_order;
        input [1:0] lvl;
        begin
            case (lvl)
                2'd0: level_to_order = 2'd1;   // first-order even at peace
                2'd1: level_to_order = 2'd1;
                2'd2: level_to_order = 2'd2;   // second-order ISW
                2'd3: level_to_order = 2'd2;
                default: level_to_order = 2'd2;
            endcase
        end
    endfunction

    function [7:0] level_to_jitter;
        input [1:0] lvl;
        begin
            case (lvl)
                2'd0: level_to_jitter = 8'd4;
                2'd1: level_to_jitter = 8'd8;
                2'd2: level_to_jitter = 8'd12;
                2'd3: level_to_jitter = 8'd16;
                default: level_to_jitter = 8'd16;
            endcase
        end
    endfunction

    function [7:0] level_to_remask;
        input [1:0] lvl;
        begin
            case (lvl)
                2'd0: level_to_remask = 8'd64;
                2'd1: level_to_remask = 8'd16;
                2'd2: level_to_remask = 8'd4;
                2'd3: level_to_remask = 8'd1;
                default: level_to_remask = 8'd1;
            endcase
        end
    endfunction

    // -------------------------------------------------------------------------
    // Sticky alert latch: hard attack ever seen -> latch until reset
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            alert_latch <= 1'b0;
        else if (hard_attack_flag)
            alert_latch <= 1'b1;
    end

    // -------------------------------------------------------------------------
    // Hysteresis counter
    //   hold_cnt counts sustained cycles in the direction of the requested move
    // -------------------------------------------------------------------------
    reg [1:0]  level_q;      // currently applied level
    reg [15:0] hold_cnt;     // sustained-cycle counter
    reg [1:0]  threat_q;     // registered latest verdict

    wire want_up   = (threat_level >  level_q);
    wire want_down = (threat_level <  level_q);
    wire [15:0] threshold = want_up ? ESC_UP : ESC_DN;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            level_q    <= 2'd0;
            hold_cnt   <= 16'd0;
            threat_q   <= 2'd0;
        end else begin
            threat_q <= threat_level;

            if (hard_attack_flag) begin
                // emergency: immediate max, counter irrelevant
                level_q  <= 2'd3;
                hold_cnt <= 16'd0;
            end else if (want_up || want_down) begin
                if (hold_cnt >= threshold) begin
                    level_q  <= threat_level;   // commit the move
                    hold_cnt <= 16'd0;
                end else begin
                    hold_cnt <= hold_cnt + 16'd1;
                end
            end else begin
                hold_cnt <= 16'd0;              // level matches, no pressure
            end
        end
    end

    // -------------------------------------------------------------------------
    // Apply: emergency override and entropy-failure floor take precedence
    // -------------------------------------------------------------------------
    wire [1:0] base_level = alert_latch ? 2'd3 : level_q;

    // Entropy failure floor: never run weaker than first-order when the
    // entropy source itself is unhealthy (unmasked needs a healthy RNG).
    wire [1:0] safe_level = (level_to_order(base_level) == 2'd0 && !health_ok)
                            ? 2'd1 : base_level;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mask_order      <= 2'd1;
            jitter_max      <= 8'd4;
            remask_interval <= 8'd64;
            posture_level   <= 2'd0;
        end else begin
            posture_level   <= safe_level;
            mask_order      <= level_to_order(safe_level);
            jitter_max      <= level_to_jitter(safe_level);
            remask_interval <= level_to_remask(safe_level);
        end
    end

endmodule

`default_nettype wire
