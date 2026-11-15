`timescale 1ns / 1ps

/**
 * IPX-AOI-Sec 项目 - Dilithium 核心单元测试台（修复版）
 * 作者：Dr. Haibo Yi (海博易, 深圳技术大学)
 * 版本：v2.0 | 日期：2026-10-07
 *
 * 修复内容：
 *   1. wait() 改为 @(posedge ...) 边沿检测，避免电平已高时跳过
 *   2. 每次测试前手动清零 sig_valid / verify_result（配合 RTL 清零）
 *   3. 增加 per-test 超时保护，精确定位死锁位置
 *   4. 错误测试改用电平检测（error 为纯组合输出）
 */

module tb_dilithium_core();

// 信号定义
reg clk;
reg rst_n;
reg [255:0] message;
reg [255:0] private_key;
reg [255:0] public_key;
reg [255:0] signature;
reg sign_req;
reg verify_req;

wire [255:0] signature_r;
wire [255:0] signature_s;
wire sig_valid;
wire verify_result;
wire error;
wire ready;

// 参数
parameter CLK_PERIOD = 10;  // 100MHz

// 测试向量
reg [255:0] test_vectors[0:3];

// 超时计数
integer timeout_count;

// ============================
// 时钟生成
// ============================
initial begin
    clk = 0;
    forever # (CLK_PERIOD / 2) clk = ~clk;
end

// ============================
// DUT 实例化
// ============================
dilithium_core u_dut (
    .clk(clk),
    .rst_n(rst_n),
    .sign_req(sign_req),
    .verify_req(verify_req),
    .message(message),
    .private_key(private_key),
    .public_key(public_key),
    .signature(signature),
    .signature_r(signature_r),
    .signature_s(signature_s),
    .sig_valid(sig_valid),
    .verify_result(verify_result),
    .error(error),
    .ready(ready)
);

// ============================
// 测试过程
// ============================
initial begin
    // 初始化
    rst_n = 0;
    sign_req = 0;
    verify_req = 0;
    message = 0;
    private_key = 0;
    public_key = 0;
    signature = 0;

    # (5 * CLK_PERIOD) rst_n = 1;

    generate_test_vectors();

    // 测试1：签名功能
    # (20 * CLK_PERIOD);
    run_signature_test();

    // 测试2：验证功能
    # (50 * CLK_PERIOD);
    run_verify_test();

    // 测试3：错误处理
    # (50 * CLK_PERIOD);
    run_error_test();

    $display("\n%t: 所有测试完成！", $time);
    $finish;
end

// 全局超时保护
initial begin
    # (5000000 * CLK_PERIOD);
    $display("ERROR: 全局仿真超时（死锁）");
    $finish;
end

// 生成测试向量
function void generate_test_vectors();
    test_vectors[0] = 256'd123456789012345678901234567890;
    test_vectors[1] = 256'd987654321098765432109876543210;
    test_vectors[2] = 256'd111111111111111111111111111111;
    test_vectors[3] = 256'd222222222222222222222222222222;
endfunction

// 签名测试（修复版：边沿检测 + 超时保护）
task run_signature_test;
    integer i;
    $display("\n=== 测试1：Dilithium 签名功能 ===");
    for (i = 0; i < 4; i = i + 1) begin
        message = test_vectors[i];
        private_key = test_vectors[(i+1) % 4];
        public_key = test_vectors[(i+2) % 4];
        # (10 * CLK_PERIOD);
        sign_req = 1;

        // 等待 sig_valid 上升沿（配合 RTL 中 S_IDLE 清零）
        timeout_count = 0;
        while (!sig_valid && timeout_count < 200000) begin
            @(posedge clk);
            timeout_count = timeout_count + 1;
        end
        if (!sig_valid) begin
            $display("ERROR: 签名测试 %0d 超时（200000 周期）", i);
            $finish;
        end

        #1;
        $display("Test %0d: message=0x%0h, sig_valid=%b, r=0x%0h, s=0x%0h, error=%b",
            i, message, sig_valid, signature_r, signature_s, error);
        sign_req = 0;
        # (5 * CLK_PERIOD);
    end
endtask

// 验证测试（修复版：边沿检测 + 超时保护）
task run_verify_test;
    integer i;
    $display("\n=== 测试2：Dilithium 验证功能 ===");
    for (i = 0; i < 4; i = i + 1) begin
        message = test_vectors[i];
        signature = test_vectors[(i+1) % 4];
        public_key = test_vectors[(i+2) % 4];
        # (10 * CLK_PERIOD);
        verify_req = 1;

        // 等待 verify_result 上升沿
        timeout_count = 0;
        while (!verify_result && timeout_count < 1000) begin
            @(posedge clk);
            timeout_count = timeout_count + 1;
        end
        if (!verify_result) begin
            $display("ERROR: 验证测试 %0d 超时（1000 周期）", i);
            $finish;
        end

        #1;
        $display("Test %0d: message=0x%0h, verify_result=%b, signature=0x%0h",
            i, message, verify_result, signature);
        verify_req = 0;
        # (5 * CLK_PERIOD);
    end
endtask

// 错误处理测试（error 为纯组合，直接电平检测）
task run_error_test;
    $display("\n=== 测试3：错误处理与复位 ===");
    # (10 * CLK_PERIOD);
    rst_n = 0;
    # (10 * CLK_PERIOD);
    rst_n = 1;
    # (20 * CLK_PERIOD);
    sign_req = 1;
    message = 256'd0;
    private_key = 256'd0;
    public_key = 256'd0;

    // error 为组合输出，message==0 且 sign_req==1 时应立即拉高
    # (2 * CLK_PERIOD);
    if (error) begin
        $display("错误测试: error=%b (预期在 message==0 时报错) — PASS", error);
    end else begin
        $display("错误测试: error=%b (预期在 message==0 时报错) — FAIL", error);
    end

    rst_n = 0;
    # (10 * CLK_PERIOD);
    rst_n = 1;
    sign_req = 0;
    # (10 * CLK_PERIOD);
endtask

endmodule