`timescale 1ns / 1ps

/**
 * IPX-AOI-Sec Phase 3 - 混合签名验证状态机
 * 作者：Dr. Haibo Yi (海博易, 深圳技术大学)
 * 日期：2026-10-06
 *
 * 功能：Ed25519 与 Dilithium 后量子签名的并行验证 FSM
 * 实现：基于 IEC 62443-4-2 EDR 3.x SL3 安全要求的混合签名协议
 */

module hybrid_signature_fsm (
    input wire        clk,
    input wire        rst_n,

    // 输入信号
    input wire [127:0] inference_request,
    input wire [127:0] puf_id,
    input wire        secure_boot_ok,
    input wire        inference_done,
    input wire [127:0] inference_result,

    // 状态输出
    output reg        fsm_secure,
    output reg        fsm_sign_valid,
    output reg        fsm_verify_valid,
    output reg        fsm_error,
    output reg        fsm_ready,

    // 内部控制
    output reg       fsm_sign_req,
    output reg       fsm_verify_req
);

// 状态定义 (8 状态)
localparam [3:0] S_IDLE    = 4'd0,
                 S_CHECK   = 4'd1,  // 检查安全启动
                 S_ED25519 = 4'd2,  // Ed25519 签名验证
                 S_DILITH = 4'd3,  // Dilithium 签名验证 (占位)
                 S_MERGE   = 4'd4, // 合并验证结果
                 S_OUTPUT  = 4'd5, // 输出结果
                 S_ERROR   = 4'd6, // 错误状态
                 S_LOCKED = 4'd7; // 系统锁定 (安全增强)

reg [3:0] state, next_state;
reg [127:0] ed25519_result, dilith_result;
reg ed25519_ok, dilith_ok;
reg fsm_sign_enabled, fsm_verify_enabled;

// ============================
// 状态寄存器 (唯一驱动源)
// ============================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
    end
    else begin
        state <= next_state;
    end
end

// ============================
// 组合逻辑：下一状态 (唯一驱动 next_state)
// ============================
always @(*) begin
    next_state = S_IDLE;

    case (state)
        S_IDLE: begin
            if (secure_boot_ok) begin
                next_state = S_CHECK;
            end else begin
                next_state = S_ERROR;
            end
        end

        S_CHECK: begin
            // 检查系统安全状态
            if (inference_done) begin
                next_state = S_ED25519;
            end else begin
                next_state = S_CHECK;
            end
        end

        S_ED25519: begin
            next_state = S_DILITH;
        end

        S_DILITH: begin
            next_state = S_MERGE;
        end

        S_MERGE: begin
            // 合并验证结果
            if (ed25519_ok && dilith_ok) begin
                next_state = S_OUTPUT;
            end else begin
                next_state = S_ERROR;
            end
        end

        S_OUTPUT: begin
            next_state = S_IDLE;
        end

        S_ERROR: begin
            next_state = S_LOCKED;
        end

        S_LOCKED: begin
            // 系统锁定，自动重启需要外部复位
            next_state = S_LOCKED;
        end

        default: next_state = S_IDLE;
    endcase
end

// ============================
// 中间结果寄存器 (唯一驱动源)
// ============================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        ed25519_result <= 128'd0;
        ed25519_ok     <= 1'b0;
        dilith_result  <= 128'd0;
        dilith_ok      <= 1'b0;
    end else begin
        case (state)
            S_ED25519: begin
                // 简化 Ed25519 验证逻辑
                // 真实实现需要连接 Ed25519 模块
                ed25519_result <= 128'h1234567890ABCDEF;  // 占位结果
                ed25519_ok     <= 1'b1;                   // 占位通过
            end

            S_DILITH: begin
                // Dilithium 签名验证占位
                dilith_result <= 128'hEXDF;
                dilith_ok     <= 1'b1;
            end

            default: begin
                // 保持
            end
        endcase
    end
end

// ============================
// 输出寄存器 (唯一驱动源)
// ============================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        fsm_secure       <= 1'b0;
        fsm_sign_valid   <= 1'b0;
        fsm_verify_valid <= 1'b0;
        fsm_error        <= 1'b0;
        fsm_ready        <= 1'b1;
        fsm_sign_enabled <= 1'b0;
        fsm_verify_enabled <= 1'b0;
        fsm_sign_req     <= 1'b0;
        fsm_verify_req   <= 1'b0;
    end else begin
        fsm_ready        <= (state == S_IDLE || state == S_OUTPUT);
        fsm_sign_enabled <= (state == S_ED25519 || state == S_DILITH);
        fsm_verify_enabled <= (state == S_MERGE || state == S_OUTPUT);
        fsm_sign_req     <= (state == S_ED25519);
        fsm_verify_req   <= (state == S_DILITH);

        // 安全/错误状态由当前状态译码，避免组合多驱动
        fsm_secure       <= (state == S_OUTPUT);
        fsm_sign_valid   <= (state == S_OUTPUT);
        fsm_verify_valid <= (state == S_OUTPUT);
        fsm_error        <= (state == S_ERROR || state == S_LOCKED);
    end
end

endmodule
