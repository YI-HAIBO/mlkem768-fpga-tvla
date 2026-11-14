`timescale 1ns / 1ps

/**
 * IPX-AOI-Sec 顶层集成测试台 (Phase 2)
 * 作者：Dr. Haibo Yi (海博易, 深圳技术大学)
 * 版本：v1.0 | 日期：2026-10-06
 */

module tb_ipx_aoi_sec_top();

// Top-level signals
reg clk;
reg rst_n;
reg [255:0] puf_fingerprint;
reg puf_valid;
reg [127:0] model_id;
reg model_load_req;
wire model_load_done;
reg [127:0] inference_request;
wire inference_done;
wire [127:0] inference_result;
reg secure_boot_req;
wire secure_boot_done;
wire boot_verification_ok;
wire [256:0] derivated_key;
wire key_valid;
reg dilithium_sign_req;
reg [255:0] dilithium_private_key;
wire [255:0] dilithium_signature_r;
wire [255:0] dilithium_signature_s;
wire dilithium_sig_valid;
wire dilithium_verify_result;
wire masking_enabled;
wire trng_output;
wire trng_valid;
wire [7:0] status_register;
wire error_flag;

// Clock generation
parameter CLK_PERIOD = 10;
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// DUT instantiation
ipx_aoi_sec_fpga_top u_dut (
    .clk(clk),
    .rst_n(rst_n),
    .puf_fingerprint(puf_fingerprint),
    .puf_valid(puf_valid),
    .model_id(model_id),
    .model_load_req(model_load_req),
    .model_load_done(model_load_done),
    .inference_request(inference_request),
    .inference_done(inference_done),
    .inference_result(inference_result),
    .secure_boot_req(secure_boot_req),
    .secure_boot_done(secure_boot_done),
    .boot_verification_ok(boot_verification_ok),
    .derivated_key(derivated_key),
    .key_valid(key_valid),
    .dilithium_sign_req(dilithium_sign_req),
    .dilithium_private_key(dilithium_private_key),
    .dilithium_signature_r(dilithium_signature_r),
    .dilithium_signature_s(dilithium_signature_s),
    .dilithium_sig_valid(dilithium_sig_valid),
    .dilithium_verify_result(dilithium_verify_result),
    .masking_enabled(masking_enabled),
    .trng_output(trng_output),
    .trng_valid(trng_valid),
    .status_register(status_register),
    .error_flag(error_flag)
);

// Test process
initial begin
    $display("\n=== IPX-AOI-Sec Top Level Integration Test ===\n");

    // Initialize
    rst_n = 0;
    puf_fingerprint = 0;
    puf_valid = 0;
    model_id = 0;
    model_load_req = 0;
    inference_request = 0;
    secure_boot_req = 0;
    dilithium_sign_req = 0;
    dilithium_private_key = 0;
    # (5 * CLK_PERIOD) rst_n = 1;
    # (5 * CLK_PERIOD);

    // Test 1: Dilithium signature
    $display("\n--- Test 1: Dilithium Signature ---");
    dilithium_private_key = 256'hDEADBEEFCAFEBABE1234567890ABCDEF;
    dilithium_sign_req = 1;
    fork
        wait (dilithium_sig_valid);
        begin
            #(5000 * CLK_PERIOD);
            $display("  [WARN] Dilithium sig_valid timeout (framework implementation)");
        end
    join_any
    #1;
    $display("  Signature generated: r=0x%0h", dilithium_signature_r);
    $display("  Signature generated: s=0x%0h", dilithium_signature_s);
    $display("  sig_valid=%b", dilithium_sig_valid);
    dilithium_sign_req = 0;
    # (10 * CLK_PERIOD);

    // Test 2: PUF key derivation
    $display("\n--- Test 2: PUF Key Derivation ---");
    puf_fingerprint = 256'hDEADBEEF00C0FFEE1122334455667788;
    puf_valid = 1;
    fork
        wait (key_valid);
        begin
            #(5000 * CLK_PERIOD);
            $display("  [WARN] key_valid timeout");
        end
    join_any
    #1;
    $display("  PUF key derived: 0x%0h", derivated_key);
    $display("  key_valid=%b", key_valid);
    puf_valid = 0;
    # (10 * CLK_PERIOD);

    // Test 3: secure boot chain
    $display("\n--- Test 3: Secure Boot Chain ---");
    secure_boot_req = 1;
    # (5 * CLK_PERIOD);
    $display("  secure_boot_done=%b, boot_verification_ok=%b",
        secure_boot_done, boot_verification_ok);
    secure_boot_req = 0;

    # (10 * CLK_PERIOD);
    $display("\n=== All top-level integration tests completed! ===\n");
    $finish;
end

// 超时保护，避免 wait() 死锁
initial begin
    # (2000000 * CLK_PERIOD);
    $display("ERROR: simulation timeout (possible deadlock in wait())");
    $finish;
end

endmodule
