`timescale 1ns / 1ps

/**
 * IPX-AOI-Sec Phase 3 - 光学 PUF 控制器
 * 作者：Dr. Haibo Yi (海博易, 深圳技术大学)
 * 日期：2026-10-06
 *
 * 功能：控制光学 PUF 装置进行随机数生成与纠缠测量
 * 基于 Quadric Labs QP-500 的简化模型
 */

module optical_puf_controller (
    input wire        clk,
    input wire        rst_n,

    // 输入：来自 ATF 或系统 PUF 指令
    input wire [127:0] puf_request,
    input wire        puf_start,
    input wire [2:0]  puf_mode,     // 0: 随机数, 1: 纠缠, 2: 校准
    input wire [7:0]  puf_id,       // 设备 ID

    // 输出
    output reg [255:0] puf_output,
    output reg        puf_valid,
    output reg        error,

    // 诊断
    output reg [7:0]  puf_status,
    output reg [31:0] puf_entropy,
    output reg        puf_ready
);

// PUF 状态定义
localparam [3:0] PUF_IDLE   = 4'd0,
                 PUF_INIT  = 4'd1,
                 PUF_MEASURE = 4'd2,
                 PUF_PROCESS = 4'd3,
                 PUF_TRNG  = 4'd4,  // 真随机数生成
                 PUF_ERROR = 4'd5;

// 内部状态
reg [3:0] puf_state, next_puf_state;
reg [255:0] puf_data;
reg [63:0] counter;
reg [31:0] entropy_count;

// 生成器 (简化 PRNG，实际应为物理 PUF)
function [255:0] puf_rng;
    input [32:0] seed;
    reg [255:0] result;
    begin
        // LFSR 生成器
        result = $urandom() << 128 | $urandom();
    end
endfunction

// ============================
// 状态机 (唯一驱动源)
// ============================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        puf_state    <= PUF_IDLE;
        puf_data     <= 256'd0;
        counter      <= 64'd0;
        entropy_count <= 32'd0;
        puf_output   <= 256'd0;
        puf_valid    <= 1'b0;
        puf_status   <= 8'd0;
        puf_entropy  <= 32'd0;
        puf_ready    <= 1'b1;
    end else begin
        puf_state <= next_puf_state;

        case (puf_state)
            PUF_IDLE: begin
                puf_ready <= 1'b1;
                puf_status <= 8'd0;
                puf_valid <= 1'b0;
            end

            PUF_INIT: begin
                // 初始化 PUF 设备，ID 验证，自检
                puf_status   <= 8'd1;  // "初始化"
                counter      <= 64'd0;
                entropy_count <= 32'd0;
            end

            PUF_MEASURE: begin
                // 执行 PUF 测量
                puf_status <= 8'd2;  // "测量中"
                case (puf_mode)
                    3'd0: // 随机数模式
                        puf_data <= puf_rng(32'd0);
                    3'd1: // 纠缠模式 - 简化
                        puf_data <= puf_request ^ {128'd0, puf_id, 64'd0};
                    3'd2: // 校准模式
                        puf_data <= 256'd1;
                    default: puf_data <= 256'd0;
                endcase
                counter <= counter + 1;
            end

            PUF_PROCESS: begin
                // 处理结果，熵提取
                puf_status   <= 8'd3;  // "处理中"
                entropy_count <= entropy_count + 32'd1;
                puf_data     <= puf_data + 256'd1;  // 添加扰动
            end

            PUF_TRNG: begin
                // 生成真随机数
                puf_output  <= puf_data;
                puf_valid   <= 1'b1;
                puf_status  <= 8'd4;  // "完成", "就绪"
                puf_ready   <= 1'b1;
                entropy_count <= 32'd0;
            end

            PUF_ERROR: begin
                puf_status <= 8'd255;  // "错误"
                puf_ready  <= 1'b1;
            end

            default: begin
                // 保持
            end
        endcase
    end
end

// ============================
// 组合逻辑：下一状态 (唯一驱动 next_puf_state)
// ============================
always @(*) begin
    next_puf_state = PUF_IDLE;

    case (puf_state)
        PUF_IDLE: begin
            if (puf_start) begin
                next_puf_state = PUF_INIT;
            end else begin
                next_puf_state = PUF_IDLE;
            end
        end

        PUF_INIT: begin
            next_puf_state = PUF_MEASURE;
        end

        PUF_MEASURE: begin
            if (counter >= 64'd8) begin
                // 测量完成
                next_puf_state = PUF_PROCESS;
            end else begin
                next_puf_state = PUF_MEASURE;
            end
        end

        PUF_PROCESS: begin
            next_puf_state = PUF_TRNG;
        end

        PUF_TRNG: begin
            next_puf_state = PUF_IDLE;
        end

        PUF_ERROR: begin
            next_puf_state = PUF_IDLE;
        end

        default: next_puf_state = PUF_IDLE;
    endcase
end

// ============================
// 错误标志寄存器 (唯一驱动源)
// ============================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        error <= 1'b0;
    end else begin
        error <= (puf_state == PUF_ERROR || next_puf_state == PUF_ERROR);
    end
end

endmodule
