`timescale 1ns / 1ps

/**
 * IPX-AOI-Sec Phase 3.2 - 1-bit 量化 LSTM 推理引擎（真实权重版）
 * 作者：Dr. Haibo Yi (海博易, 深圳技术大学)
 * 日期：2026-10-07
 *
 * 更新内容：
 *   1. 新增权重加载接口（w_addr / w_data / w_wr / w_load_done）
 *      — 真实权重可从外部 Flash / BRAM / Host 端逐字写入
 *   2. 实现真实的 LSTM 门计算（输入门/遗忘门/输出门/候选门）
 *   3. 新增 weights_loaded 标志，未加载权重时拒绝推理
 *   4. 仿真可用 $readmemh 从 .hex 文件预载权重
 *
 * 功能：1-bit 量化 LSTM 单元，用于侧信道异常检测
 *   - 输入门 i、遗忘门 f、输出门 o、候选门 g
 *   - 1-bit 权重 + XNOR-Count 累加（二值化网络标准做法）
 *   - anomaly_score = 异常计数，anomaly_detected = 阈值判决
 */

module lstm_inference (
    input wire        clk,
    input wire        rst_n,
    input wire        start,
    output reg        busy,
    output reg        done,

    // 输入特征 (时序数据流)
    input wire [0:0]  x_in,
    input wire        x_valid,
    output reg        x_ready,

    // 权重加载接口（真实权重从此端口写入）
    input wire [15:0] w_addr,       // 权重地址：[15:12]=门选择, [11:7]=输入索引, [6:0]=隐藏索引
    input wire [0:0]  w_data,       // 1-bit 权重值
    input wire        w_wr,         // 写使能
    input wire        w_load_done,  // 权重加载完成标志（host 拉高一次）
    output reg        weights_loaded, // 权重已就绪

    // 输出检测
    output reg [1:0] anomaly_score,
    output reg       anomaly_detected,
    output reg       inference_ready
);

// 模块参数 (可配置)
parameter [7:0] INPUT_SIZE  = 8'd32;   // 输入特征维度
parameter [7:0] HIDDEN_SIZE = 8'd16;   // 隐藏单元数量
parameter [7:0] TIME_STEPS  = 8'd10;   // 时间步数

// 权重地址编码
localparam [3:0] GATE_IF  = 4'd0,  // 输入门 x 权重
                 GATE_OF  = 4'd1,  // 输出门 x 权重
                 GATE_CF  = 4'd2,  // 候选门 x 权重
                 GATE_GF  = 4'd3,  // 遗忘门 x 权重
                 GATE_IFH = 4'd4,  // 输入门 h 权重
                 GATE_OFH = 4'd5,  // 输出门 h 权重
                 GATE_CFH = 4'd6,  // 候选门 h 权重
                 GATE_GFH = 4'd7;  // 遗忘门 h 权重

// 权重内存 (1-bit)
reg [0:0] w_if [0:INPUT_SIZE-1][0:HIDDEN_SIZE-1];
reg [0:0] w_of [0:INPUT_SIZE-1][0:HIDDEN_SIZE-1];
reg [0:0] w_cf [0:INPUT_SIZE-1][0:HIDDEN_SIZE-1];
reg [0:0] w_gf [0:INPUT_SIZE-1][0:HIDDEN_SIZE-1];

reg [0:0] w_ifh [0:HIDDEN_SIZE-1][0:HIDDEN_SIZE-1];
reg [0:0] w_ofh [0:HIDDEN_SIZE-1][0:HIDDEN_SIZE-1];
reg [0:0] w_cfh [0:HIDDEN_SIZE-1][0:HIDDEN_SIZE-1];
reg [0:0] w_gfh [0:HIDDEN_SIZE-1][0:HIDDEN_SIZE-1];

// 隐藏状态 (1-bit)
reg [0:0] h [0:HIDDEN_SIZE-1];
reg [0:0] c [0:HIDDEN_SIZE-1];

// 输入缓冲（移位寄存器，缓存 INPUT_SIZE 个 1-bit 输入）
reg [0:0] x_buf [0:INPUT_SIZE-1];

// 计算累加器
reg [12:0] acc_i, acc_f, acc_o, acc_g; // 门输出累加器
reg [12:0] anomaly_counter;             // 异常计数器

// 遍历索引
reg [7:0] x_idx;   // 输入维度索引
reg [7:0] h_idx;   // 隐藏维度索引
reg [7:0] t_step;  // 时间步

// 状态机
localparam [3:0] S_IDLE     = 4'd0,
                 S_READ_X   = 4'd1,
                 S_COMPUTE_F = 4'd2,
                 S_COMPUTE_I = 4'd3,
                 S_COMPUTE_O = 4'd4,
                 S_COMPUTE_G = 4'd5,
                 S_UPDATE_C = 4'd6,
                 S_UPDATE_H = 4'd7,
                 S_OUTPUT   = 4'd8;

reg [3:0] state;
reg [3:0] next_state;

// 异常检测阈值（超过此计数则判定异常）
localparam [12:0] ANOMALY_THRESHOLD = 13'd8;

// =========================================================================
// 权重加载（独立时序块）
// =========================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        weights_loaded <= 1'b0;
    end else begin
        if (w_load_done) begin
            weights_loaded <= 1'b1;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 复位时不清空权重（保留已加载值）
    end else if (w_wr) begin
        case (w_addr[15:12])
            GATE_IF:  w_if [w_addr[11:7]][w_addr[6:0]] <= w_data;
            GATE_OF:  w_of [w_addr[11:7]][w_addr[6:0]] <= w_data;
            GATE_CF:  w_cf [w_addr[11:7]][w_addr[6:0]] <= w_data;
            GATE_GF:  w_gf [w_addr[11:7]][w_addr[6:0]] <= w_data;
            GATE_IFH: w_ifh[w_addr[11:7]][w_addr[6:0]] <= w_data;
            GATE_OFH: w_ofh[w_addr[11:7]][w_addr[6:0]] <= w_data;
            GATE_CFH: w_cfh[w_addr[11:7]][w_addr[6:0]] <= w_data;
            GATE_GFH: w_gfh[w_addr[11:7]][w_addr[6:0]] <= w_data;
            default: ; // 忽略无效门编号
        endcase
    end
end

// =========================================================================
// 时序块：唯一驱动所有状态寄存器
// =========================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
        busy <= 1'b0;
        done <= 1'b0;
        x_ready <= 1'b0;
        anomaly_score <= 2'd0;
        anomaly_detected <= 1'b0;
        inference_ready <= 1'b1;
        acc_i <= 13'd0;
        acc_f <= 13'd0;
        acc_o <= 13'd0;
        acc_g <= 13'd0;
        anomaly_counter <= 13'd0;
        x_idx <= 8'd0;
        h_idx <= 8'd0;
        t_step <= 8'd0;
    end else begin
        state <= next_state;
        done <= (next_state == S_IDLE && state == S_OUTPUT);
        busy <= (next_state != S_IDLE && next_state != S_OUTPUT);
        inference_ready <= (state == S_OUTPUT);

        case (state)
            S_IDLE: begin
                x_ready <= 1'b1;  // 空闲时准备好接收输入
                anomaly_counter <= 13'd0;
                t_step <= 8'd0;
                if (start && weights_loaded) begin
                    x_ready <= 1'b1;
                    x_idx <= 8'd0;
                end
            end

            S_READ_X: begin
                if (x_valid) begin
                    x_buf[x_idx] <= x_in;
                    x_idx <= x_idx + 1;
                    if (x_idx == INPUT_SIZE - 1) begin
                        x_idx <= 8'd0;
                        h_idx <= 8'd0;
                        acc_f <= 13'd0;
                        acc_i <= 13'd0;
                        acc_o <= 13'd0;
                        acc_g <= 13'd0;
                    end
                end
            end

            // 遗忘门：acc_f += popcount(x XNOR w_gf) + popcount(h XNOR w_gfh)
            S_COMPUTE_F: begin
                if (x_idx < INPUT_SIZE) begin
                    // XNOR-Count：x 与权重同号则 +1
                    if (x_buf[x_idx] == w_gf[x_idx][h_idx])
                        acc_f <= acc_f + 1;
                    x_idx <= x_idx + 1;
                end else if (h_idx < HIDDEN_SIZE) begin
                    if (h[h_idx] == w_gfh[h_idx][h_idx])
                        acc_f <= acc_f + 1;
                    h_idx <= h_idx + 1;
                end else begin
                    // 归一化：超过半数则激活
                    if (acc_f > (INPUT_SIZE + HIDDEN_SIZE) / 2)
                        acc_f <= 13'd1;
                    else
                        acc_f <= 13'd0;
                end
            end

            // 输入门：acc_i += popcount(x XNOR w_if) + popcount(h XNOR w_ifh)
            S_COMPUTE_I: begin
                if (x_idx < INPUT_SIZE) begin
                    if (x_buf[x_idx] == w_if[x_idx][h_idx])
                        acc_i <= acc_i + 1;
                    x_idx <= x_idx + 1;
                end else if (h_idx < HIDDEN_SIZE) begin
                    if (h[h_idx] == w_ifh[h_idx][h_idx])
                        acc_i <= acc_i + 1;
                    h_idx <= h_idx + 1;
                end else begin
                    if (acc_i > (INPUT_SIZE + HIDDEN_SIZE) / 2)
                        acc_i <= 13'd1;
                    else
                        acc_i <= 13'd0;
                end
            end

            // 输出门：acc_o += popcount(x XNOR w_of) + popcount(h XNOR w_ofh)
            S_COMPUTE_O: begin
                if (x_idx < INPUT_SIZE) begin
                    if (x_buf[x_idx] == w_of[x_idx][h_idx])
                        acc_o <= acc_o + 1;
                    x_idx <= x_idx + 1;
                end else if (h_idx < HIDDEN_SIZE) begin
                    if (h[h_idx] == w_ofh[h_idx][h_idx])
                        acc_o <= acc_o + 1;
                    h_idx <= h_idx + 1;
                end else begin
                    if (acc_o > (INPUT_SIZE + HIDDEN_SIZE) / 2)
                        acc_o <= 13'd1;
                    else
                        acc_o <= 13'd0;
                end
            end

            // 候选门：acc_g += popcount(x XNOR w_cf) + popcount(h XNOR w_cfh)
            S_COMPUTE_G: begin
                if (x_idx < INPUT_SIZE) begin
                    if (x_buf[x_idx] == w_cf[x_idx][h_idx])
                        acc_g <= acc_g + 1;
                    x_idx <= x_idx + 1;
                end else if (h_idx < HIDDEN_SIZE) begin
                    if (h[h_idx] == w_cfh[h_idx][h_idx])
                        acc_g <= acc_g + 1;
                    h_idx <= h_idx + 1;
                end else begin
                    if (acc_g > (INPUT_SIZE + HIDDEN_SIZE) / 2)
                        acc_g <= 13'd1;
                    else
                        acc_g <= 13'd0;
                end
            end

            // 细胞状态更新：c = f & c | i & g
            S_UPDATE_C: begin
                c[h_idx] <= (acc_f[0] & c[h_idx]) | (acc_i[0] & acc_g[0]);
                h_idx <= h_idx + 1;
                if (h_idx == HIDDEN_SIZE - 1) begin
                    h_idx <= 8'd0;
                end
            end

            // 隐藏状态更新：h = o & tanh(c) → 1-bit: h = o & c
            S_UPDATE_H: begin
                h[h_idx] <= acc_o[0] & c[h_idx];
                // 异常计数：h 为 1 视为异常特征
                if (acc_o[0] & c[h_idx])
                    anomaly_counter <= anomaly_counter + 1;
                h_idx <= h_idx + 1;
                if (h_idx == HIDDEN_SIZE - 1) begin
                    h_idx <= 8'd0;
                    t_step <= t_step + 1;
                end
            end

            S_OUTPUT: begin
                anomaly_score <= anomaly_counter[1:0];
                anomaly_detected <= (anomaly_counter >= ANOMALY_THRESHOLD) ? 1'b1 : 1'b0;
            end

            default: begin
                // 保持
            end
        endcase
    end
end

// =========================================================================
// 组合块：只计算 next_state
// =========================================================================
always @(*) begin
    next_state = state;
    case (state)
        S_IDLE:
            if (start && weights_loaded) next_state = S_READ_X;

        S_READ_X:
            if (x_idx == INPUT_SIZE - 1 && x_valid) next_state = S_COMPUTE_F;

        S_COMPUTE_F:
            if (x_idx >= INPUT_SIZE && h_idx >= HIDDEN_SIZE) next_state = S_COMPUTE_I;

        S_COMPUTE_I:
            if (x_idx >= INPUT_SIZE && h_idx >= HIDDEN_SIZE) next_state = S_COMPUTE_O;

        S_COMPUTE_O:
            if (x_idx >= INPUT_SIZE && h_idx >= HIDDEN_SIZE) next_state = S_COMPUTE_G;

        S_COMPUTE_G:
            if (x_idx >= INPUT_SIZE && h_idx >= HIDDEN_SIZE) next_state = S_UPDATE_C;

        S_UPDATE_C:
            if (h_idx == HIDDEN_SIZE - 1) next_state = S_UPDATE_H;

        S_UPDATE_H: begin
            if (h_idx == HIDDEN_SIZE - 1) begin
                if (t_step >= TIME_STEPS - 1)
                    next_state = S_OUTPUT;
                else
                    next_state = S_READ_X;
            end
        end

        S_OUTPUT:
            next_state = S_IDLE;

        default:
            next_state = S_IDLE;
    endcase
end

// 仿真用：从 hex 文件预载权重（仅 simulation，综合时被忽略）
// synthesis translate_off
initial begin
    // 权重默认全 0（等价于随机初始化的退化情况）
    // 真实使用时通过 w_addr/w_data/w_wr 端口加载，或取消下行注释使用 $readmemh
    // $readmemh("lstm_weights.hex", w_if);
end
// synthesis translate_on

endmodule