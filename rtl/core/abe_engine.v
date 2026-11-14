`timescale 1ns / 1ps

// =============================================================================
// ABE Engine - 修复版
// -----------------------------------------------------------------------------
// 修复内容：消除 encrypted_data / decrypted_data / encryption_ok 的多驱动问题
// 原因：always @(posedge clk) 和 always @(*) 同时驱动同一 reg，
//       Vivado 报 CRITICAL WARNING（常数 GND 覆盖寄存器驱动）。
// 修复方案：组合逻辑只驱动 next_state 与内部 wire，寄存器更新全部移入
//           时序块；输出寄存器由 next_* 组合值在时序沿打入。
// =============================================================================

module abe_engine(
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg busy,
    output reg done,

    input wire attr_valid,
    input wire [7:0] attr_id,
    output reg attr_ready,

    input wire [127:0] message,
    input wire msg_valid,

    input wire [63:0] policy_attrs,
    input wire policy_valid,

    input wire [127:0] master_key,
    input wire key_valid,

    output reg [127:0] encrypted_data,
    output reg [127:0] decrypted_data,
    output reg decryption_ok,
    output reg encryption_ok
);

parameter [7:0] MAX_ATTRS = 8'd16;

localparam [3:0] S_IDLE = 4'd0,
                 S_LOAD_ATTR = 4'd1,
                 S_LOAD_POL  = 4'd2,
                 S_COMPUTE_PK = 4'd3,
                 S_COMPUTE_SK = 4'd4,
                 S_ENCRYPT    = 4'd5,
                 S_DECRYPT    = 4'd6,
                 S_OUTPUT     = 4'd7;

reg [3:0] state;
reg [3:0] next_state;

reg [7:0] attr_count;
reg [7:0] policy_attrs_count;
reg [7:0] user_attrs [0:7];
reg [7:0] policy [0:7];
reg [127:0] temp_key;
reg [127:0] temp_key_pub;

// 组合逻辑计算的下一拍值（仅 wire，不与寄存器冲突）
reg [127:0] next_encrypted;
reg [127:0] next_decrypted;
reg         next_encryption_ok;
reg         next_decryption_ok;
reg [127:0] next_temp_key;
reg [127:0] next_temp_key_pub;
reg [7:0]   next_attr_count;
reg [7:0]   next_policy_attrs_count;

// =========================================================================
// 时序块：唯一驱动所有寄存器
// =========================================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= S_IDLE;
        busy <= 1'b0;
        done <= 1'b0;
        decryption_ok <= 1'b0;
        encryption_ok <= 1'b0;
        attr_count <= 8'd0;
        policy_attrs_count <= 8'd0;
        attr_ready <= 1'b1;
        encrypted_data <= 128'd0;
        decrypted_data <= 128'd0;
        temp_key <= 128'd0;
        temp_key_pub <= 128'd0;
    end else begin
        state <= next_state;
        busy <= (next_state != S_IDLE && next_state != S_OUTPUT);
        done <= (next_state == S_OUTPUT);
        attr_count <= next_attr_count;
        policy_attrs_count <= next_policy_attrs_count;
        temp_key <= next_temp_key;
        temp_key_pub <= next_temp_key_pub;
        encrypted_data <= next_encrypted;
        decrypted_data <= next_decrypted;
        encryption_ok <= next_encryption_ok;
        decryption_ok <= next_decryption_ok;
    end
end

// =========================================================================
// 组合块：只计算 next_* 值，不直接驱动输出寄存器
// =========================================================================
always @(*) begin
    // 默认值：保持当前状态
    next_state = state;
    next_encrypted = encrypted_data;
    next_decrypted = decrypted_data;
    next_encryption_ok = 1'b0;
    next_decryption_ok = 1'b0;
    next_temp_key = temp_key;
    next_temp_key_pub = temp_key_pub;
    next_attr_count = attr_count;
    next_policy_attrs_count = policy_attrs_count;

    case (state)
        S_IDLE: begin
            next_attr_count = 8'd0;
            next_policy_attrs_count = 8'd0;
            if (start) next_state = S_LOAD_ATTR;
        end
        S_LOAD_ATTR: begin
            if (attr_valid && attr_count < MAX_ATTRS) begin
                user_attrs[attr_count] = attr_id;
                next_attr_count = attr_count + 1;
                if (attr_count >= MAX_ATTRS - 1)
                    next_state = S_LOAD_POL;
                else
                    next_state = S_LOAD_ATTR;
            end
        end
        S_LOAD_POL: begin
            if (policy_valid && policy_attrs_count < 8) begin
                policy[policy_attrs_count] = policy_attrs[policy_attrs_count*8 +: 8];
                next_policy_attrs_count = policy_attrs_count + 1;
                if (policy_attrs_count >= 7)
                    next_state = S_COMPUTE_PK;
                else
                    next_state = S_LOAD_POL;
            end
        end
        S_COMPUTE_PK: begin
            next_temp_key = message ^ master_key;
            next_state = S_COMPUTE_SK;
        end
        S_COMPUTE_SK: begin
            next_temp_key_pub = temp_key ^ {120'd0, user_attrs[0]};
            next_state = S_ENCRYPT;
        end
        S_ENCRYPT: begin
            next_encrypted = temp_key ^ {120'd0, policy[0]};
            next_encryption_ok = 1'b1;
            next_state = S_DECRYPT;
        end
        S_DECRYPT: begin
            next_decrypted = encrypted_data ^ temp_key_pub;
            next_decryption_ok = (next_decrypted == temp_key);
            next_state = S_OUTPUT;
        end
        S_OUTPUT: begin
            next_state = S_IDLE;
        end
        default: begin
            next_state = S_IDLE;
        end
    endcase
end

endmodule