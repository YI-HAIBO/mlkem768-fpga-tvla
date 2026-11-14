`timescale 1ns / 1ps

/**
 * IPX-AOI-Sec Phase 3 - Dilithium 真实多项式算术核
 * 作者：Dr. Haibo Yi (海博易, 深圳技术大学)
 * 日期：2026-10-06
 *
 * 功能：Z_q 上 256 系数多项式负循环卷积（多项式乘法）
 *   c[k] = SUM_{i=0..255} a[i] * b[(k-i) mod 256]  (mod q)
 *   q = 8380417 (Dilithium 模数, 23-bit)
 *
 * 接口：系数经 a_wr/b_wr 顺序写入，start 启动，done 脉冲表示完成，
 *       结果经 c_addr/c_data 读取。
 *
 * 实现：每周期一次 MAC，常数模缩减（%q），共 256*257 ~= 66k 周期。
 *       Phase 4 优化点：常数模乘改 Barrett/Montgomery、循环卷积改 NTT。
 */

module dilithium_poly_arith (
    input  wire        clk,
    input  wire        rst_n,

    // 系数写入接口
    input  wire        a_wr,
    input  wire [7:0]  a_addr,
    input  wire [22:0] a_data,
    input  wire        b_wr,
    input  wire [7:0]  b_addr,
    input  wire [22:0] b_data,

    // 控制
    input  wire        start,
    output reg         busy,
    output reg         done,

    // 结果读取
    input  wire [7:0]  c_addr,
    output wire [22:0] c_data
);

// Dilithium 模数 q = 8380417
localparam [22:0] Q = 23'd8380417;

reg [22:0] mem_a [0:255];
reg [22:0] mem_b [0:255];
reg [22:0] mem_c [0:255];

reg        computing;
reg [7:0]  k;      // 输出系数下标 0..255
reg [8:0]  i;      // 内层累加下标 0..256
reg [23:0] acc;    // 累加器 (保持 < 2q)

wire [7:0]  bidx  = k - i[7:0];            // (k-i) mod 256，8 位自然回绕
wire [22:0] pa    = mem_a[i[7:0]];
wire [22:0] pb    = mem_b[bidx];
wire [45:0] prod  = pa * pb;               // 23x23 -> 46 位全积
wire [45:0] pm    = prod % Q;              // 常数取模（Phase 4 改 Barrett）
wire [23:0] sum   = acc + {1'b0, pm[22:0]};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        computing <= 1'b0;
        k <= 8'd0;
        i <= 9'd0;
        acc <= 24'd0;
        busy <= 1'b0;
        done <= 1'b0;
    end else begin
        done <= 1'b0;

        // 系数写入（与计算互斥使用）
        if (a_wr) mem_a[a_addr] <= a_data;
        if (b_wr) mem_b[b_addr] <= b_data;

        if (start && !computing) begin
            computing <= 1'b1;
            busy <= 1'b1;
            k <= 8'd0;
            i <= 9'd0;
            acc <= 24'd0;
        end else if (computing) begin
            if (i < 9'd256) begin
                acc <= (sum >= {1'b0, Q}) ? (sum - {1'b0, Q}) : sum;
                i <= i + 9'd1;
            end else begin
                mem_c[k] <= acc[22:0];
                acc <= 24'd0;
                i <= 9'd0;
                if (k == 8'd255) begin
                    computing <= 1'b0;
                    busy <= 1'b0;
                    done <= 1'b1;
                end else begin
                    k <= k + 8'd1;
                end
            end
        end
    end
end

assign c_data = mem_c[c_addr];

endmodule
