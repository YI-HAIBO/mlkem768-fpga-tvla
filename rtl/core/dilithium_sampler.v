`timescale 1ns / 1ps

/**
 * Dilithium 采样模块 - 生成满足特定分布的多项式
 * 简化实现：用线性同余生成器产生 32 个 8 位随机系数,拼成 256 位输出
 */
module dilithium_sampler (
    input wire clk,
    input wire rst_n,
    input wire req,
    output wire [255:0] out,
    output reg ready,
    output reg error
);

reg [31:0] rng_state;
reg [7:0]  coeffs [0:31];
reg [5:0]  coeff_idx;
reg        in_progress;

integer i;
reg [255:0] out_vec;

// 线性同余生成器
function [31:0] lcg_step;
    input [31:0] state;
    lcg_step = (state * 1664525) + 1013904223;
endfunction

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rng_state   <= 32'd0;
        coeff_idx   <= 6'd0;
        ready       <= 1'b0;
        error       <= 1'b0;
        in_progress <= 1'b0;
    end
    else begin
        ready <= 1'b0;
        if (!in_progress) begin
            if (req) begin
                rng_state   <= 32'd12345;  // 初始化随机种子
                coeff_idx   <= 6'd0;
                in_progress <= 1'b1;
            end
        end
        else begin
            coeffs[coeff_idx] <= rng_state[7:0];
            rng_state         <= lcg_step(rng_state);
            coeff_idx         <= coeff_idx + 6'd1;
            if (coeff_idx == 6'd31) begin
                in_progress <= 1'b0;
                ready       <= 1'b1;
            end
        end
    end
end

// 组合输出 32 个系数
always @(*) begin
    for (i = 0; i < 32; i = i + 1) begin
        out_vec[i*8 +: 8] = coeffs[i];
    end
end

assign out = out_vec;

endmodule
