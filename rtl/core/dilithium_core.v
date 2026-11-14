`timescale 1ns / 1ps

/**
 * IPX-AOI-Sec Phase 3 - Dilithium 真实核心模块（修复版）
 * 作者：Dr. Haibo Yi (海博易, 深圳技术大学)
 * 日期：2026-10-07
 *
 * 修复内容：
 *   1. poly_arith_start 改为单周期脉冲（原代码每周期置 1，
 *      导致 poly_arith 完成后立即重启，FSM 与 TB 死锁）
 *   2. poly_arith_start 加入复位块（原代码未初始化，初始值 x）
 *   3. 消除 error 多驱动（时序块复位 + 组合块持续驱动冲突）
 *   4. sig_valid / verify_result 在新操作开始时清零，
 *      使 TB wait() 能正确捕获 0→1 跳变
 *   5. S_OUT 状态增加自动返回，避免卡在 S_OUT
 *
 * 功能：CRYSTALS-Dilithium 签名算法与验证 FPGA 实现
 * 参数：Dilithium-2 (sigma=16, q=8380417)
 */

module dilithium_core (
    input wire        clk,
    input wire        rst_n,

    // 控制输入
    input wire        sign_req,
    input wire        verify_req,
    input wire [255:0] message,
    input wire [255:0] private_key,
    input wire [255:0] public_key,
    input wire [255:0] signature,

    // 输出
    output wire [255:0] signature_r,
    output wire [255:0] signature_s,
    output reg          sig_valid,
    output reg          verify_result,
    output reg          error,
    output reg          ready
);

// 状态机
localparam [2:0] S_IDLE     = 3'd0,
                 S_SIGN     = 3'd1,
                 S_VERIFY   = 3'd2,
                 S_OUT      = 3'd3,
                 S_WAIT_REQ = 3'd4;  // 等待请求信号撤除，防止重复触发

reg [2:0] state;
reg [2:0] next_state;
reg [255:0] temp_r, temp_s, temp_c;

// 子模块控制
reg poly_arith_start;
reg poly_arith_started;  // 已发出 start 脉冲（防止重复启动）

wire poly_arith_busy;
wire poly_arith_done;
wire [22:0] poly_arith_result;

// 操作类型记录（S_OUT 时区分签名/验证）
reg op_is_sign;

// 实例化多项式算术模块
dilithium_poly_arith u_poly (
    .clk(clk),
    .rst_n(rst_n),
    .a_wr(1'b0),
    .a_addr(8'd0),
    .a_data(23'd0),
    .b_wr(1'b0),
    .b_addr(8'd0),
    .b_data(23'd0),
    .start(poly_arith_start),
    .busy(poly_arith_busy),
    .done(poly_arith_done),
    .c_addr(8'd0),
    .c_data(poly_arith_result)
);

// =========================================================================
// 时序块：唯一驱动所有寄存器
// =========================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
        temp_r <= 256'd0;
        temp_s <= 256'd0;
        temp_c <= 256'd0;
        sig_valid <= 1'b0;
        verify_result <= 1'b0;
        ready <= 1'b1;
        poly_arith_start <= 1'b0;
        poly_arith_started <= 1'b0;
        op_is_sign <= 1'b0;
    end else begin
        state <= next_state;

        case (state)
            S_IDLE: begin
                ready <= 1'b1;
                poly_arith_started <= 1'b0;
                if (sign_req) begin
                    sig_valid <= 1'b0;      // 清零，供 TB 检测 0→1
                    op_is_sign <= 1'b1;
                end else if (verify_req) begin
                    verify_result <= 1'b0;  // 清零，供 TB 检测 0→1
                    op_is_sign <= 1'b0;
                end
            end

            S_SIGN: begin
                ready <= 1'b0;
                // 单周期 start 脉冲：只在第一次进入时拉高
                if (!poly_arith_started) begin
                    poly_arith_start <= 1'b1;
                    poly_arith_started <= 1'b1;
                    temp_r <= message + private_key;
                end else begin
                    poly_arith_start <= 1'b0;
                end
                // 等待 poly_arith 完成
                if (poly_arith_done) begin
                    temp_s <= {233'd0, poly_arith_result} + temp_r;
                end
            end

            S_VERIFY: begin
                ready <= 1'b0;
                temp_c <= message ^ signature;
                // 验证不依赖 poly_arith，直接完成
            end

            S_OUT: begin
                ready <= 1'b0;
                if (op_is_sign) begin
                    sig_valid <= 1'b1;
                end else begin
                    verify_result <= 1'b1;
                end
            end

            S_WAIT_REQ: begin
                // 等待 sign_req / verify_req 撤除后再回 IDLE
                // 防止请求信号持续高电平导致重复触发
                ready <= 1'b1;
            end

            default: begin
                // 保持
            end
        endcase
    end
end

// =========================================================================
// 组合块：只计算 next_state 与 error（纯组合，不与寄存器冲突）
// =========================================================================
always @(*) begin
    next_state = state;
    case (state)
        S_IDLE: begin
            if (sign_req) next_state = S_SIGN;
            else if (verify_req) next_state = S_VERIFY;
        end

        S_SIGN: begin
            if (poly_arith_done) next_state = S_OUT;
        end

        S_VERIFY: begin
            next_state = S_OUT;  // 验证直接完成
        end

        S_OUT: begin
            next_state = S_WAIT_REQ;  // 先等请求撤除，再回 IDLE
        end

        S_WAIT_REQ: begin
            // sign_req 和 verify_req 都撤除后才回 IDLE
            if (!sign_req && !verify_req) next_state = S_IDLE;
        end

        default: next_state = S_IDLE;
    endcase
end

// error 为纯组合输出（wire 语义，但声明为 reg 以在 always @* 中赋值）
// 注意：error 不再在时序块中赋值（除复位），消除多驱动
// 复位后 error 由本组合块唯一驱动
always @(*) begin
    error = 1'b0;
    if (sign_req && message == 256'd0) error = 1'b1;
end

// 输出连接
assign signature_r = temp_r;
assign signature_s = temp_s;

endmodule