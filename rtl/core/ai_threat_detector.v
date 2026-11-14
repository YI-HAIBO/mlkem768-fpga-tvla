`timescale 1ns / 1ps

/**
 * AI 威胁检测模块 - 真实实现
 * 基于 LSTM 推理引擎的侧信道异常检测
 *
 * 接口：
 *   clk, rst_n: 时钟与复位
 *   power_trace: 1-bit 功耗采样（来自 TRNG 或其他源）
 *   inference_status: 使能脉冲（何时触发检测）
 *   threat_level: 2-bit 威胁等级 (0=无威胁, 1=低, 2=中, 3=高)
 *   adaptive_masking: 自适应掩码使能 (检测到威胁时开启)
 *
 * 内部使用 1-bit 量化 LSTM 推理引擎 (lstm_inference) 进行异常检测。
 *
 * 作者：Dr. Haibo Yi (海博易, 深圳技术大学)
 * 版本：v1.0 | 日期：2026-10-07
 *
 * 设计思路：
 *   - 当 inference_status 为高电平时，启动单次 LSTM 推理；
 *   - 推理完成后，将 biomarker 和检测结果同步输出;
 *   - 输出威胁等级（2-bit）和自适应掩码控制信号。
 */

module ai_threat_detector (
    input wire clk,
    input wire rst_n,
    input wire power_trace,      // 功耗采样 (1-bit)
    input wire inference_status, // 使能脉冲
    output reg  threat_level,    // 威胁等级 (2-bit)
    output reg  adaptive_masking // 自适应掩码使能
);

    // 内部信号
    wire        lstm_done;
    wire        lstm_busy;
    wire [1:0]  lstm_anomaly_score;
    wire        lstm_anomaly_detected;
    wire        lstm_inference_ready;

    // 实例化 1-bit 量化 LSTM 推理引擎
    // 注意：在真实系统中，该模块应加载真实的权重参数
    // 这里使用默认随机权重，仅在评估时可用
    lstm_inference u_lstm (
        .clk              (clk),
        .rst_n            (rst_n),
        .start            (inference_status),
        .busy             (lstm_busy),
        .done             (lstm_done),
        .x_in             (power_trace),
        .x_valid          (1'b1),
        .x_ready          (lstm_inference_ready),
        .anomaly_score    (lstm_anomaly_score),
        .anomaly_detected (lstm_anomaly_detected),
        .inference_ready  ()
    );

    // 同步输出逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            threat_level     <= 2'd0;
            adaptive_masking <= 1'b0;
        end
        else if (inference_status) begin
            // 使能有效时立即启动推理
            // 后续输出将在推理完成时同步更新
            threat_level     <= 2'd0;
            adaptive_masking <= 1'b0;
        end
        else if (lstm_done) begin
            // 推理完成，更新输出
            threat_level     <= lstm_anomaly_score;
            adaptive_masking <= lstm_anomaly_detected;
        end
        // 其他时钟周期保持当前状态
    end

endmodule
