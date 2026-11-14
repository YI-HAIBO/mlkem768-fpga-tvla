`timescale 1ns / 1ps

/**
 * Dilithium 多项式运算模块 - 简化实现
 */
module dilithium_polynomial (
    input wire clk,
    input wire rst_n,
    input wire req,
    input wire [255:0] in_a,
    input wire [255:0] in_b,
    output wire [255:0] out,
    output reg ready,
    output reg error
);

reg [255:0] a_reg, b_reg;
reg [255:0] result;
reg [7:0] coeff_count;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        a_reg <= 0;
        b_reg <= 0;
        result <= 0;
        ready <= 0;
        error <= 0;
    end
    else begin
        ready <= 1;
        
        if (req) begin
            a_reg <= in_a;
            b_reg <= in_b;
            result <= in_a + in_b;  // 简化的多项式加法
            ready <= 0;  // 单周期操作
        end
    end
end

assign out = result;

endmodule
