`timescale 1ns / 1ps

/**
 * IPX-AOI-Sec FPGA 顶层安全模块 - Nexys 4 DDR 板载演示版
 * 作者：Dr. Haibo Yi (海博易, 深圳技术大学)
 * 版本：v2.0 | 日期：2026-10-07
 *
 * I/O 策略：
 *   - 仅使用 Nexys 4 DDR 板载外设（LED/开关/按钮），共 39 个 I/O
 *   - 所有系统级宽端口转为内部寄存器，由开关驱动
 *   - 结果通过 LED 输出
 */

module ipx_aoi_sec_nexys_top (
    // 系统时钟与复位
    input wire             clk,           // 100MHz clock from E3
    input wire             rst_n,         // CPU reset from C12 (active low)

    // Nexys 4 DDR 板载外设
    output reg  [15:0]     test_led,      // 16 LEDs
    input      [15:0]      test_sw,       // 16 slide switches
    input      [4:0]       test_btn       // 5 push buttons
);

    // =====================================================================
    // 内部系统信号（原顶层端口，此处转为内部）
    // =====================================================================
    reg  [15:0]      puf_fingerprint;
    reg              puf_valid;
    reg  [7:0]       model_id;
    reg              model_load_req;
    wire             model_load_done;
    reg  [7:0]       inference_request;
    wire             inference_done;
    wire [7:0]       inference_result;
    reg              secure_boot_req;
    wire             secure_boot_done;
    wire             boot_verification_ok;
    wire [15:0]      derivated_key;
    wire             key_valid;
    reg              dilithium_sign_req;
    reg  [15:0]      dilithium_private_key;
    wire [15:0]      dilithium_signature_r;
    wire [15:0]      dilithium_signature_s;
    wire             dilithium_sig_valid;
    wire             dilithium_verify_result;
    wire             masking_enabled;
    wire             trng_output;
    wire             trng_valid;
    wire [7:0]       status_register;
    wire             error_flag;

    // =====================================================================
    // 输入寄存器化（由开关/按钮驱动）
    // =====================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            puf_fingerprint     <= 16'd0;
            puf_valid           <= 1'b0;
            model_id            <= 8'd0;
            model_load_req      <= 1'b0;
            inference_request   <= 8'd0;
            secure_boot_req     <= 1'b0;
            dilithium_sign_req  <= 1'b0;
            dilithium_private_key <= 16'd0;
        end else begin
            // 开关直接映射到系统输入
            puf_fingerprint     <= test_sw[15:0];
            model_id            <= test_sw[7:0];
            inference_request   <= test_sw[7:0];
            dilithium_private_key <= test_sw[15:0];

            // 按钮产生单周期脉冲
            puf_valid           <= test_btn[0];
            model_load_req      <= test_btn[1];
            secure_boot_req     <= test_btn[2];
            dilithium_sign_req  <= test_btn[3];
        end
    end

    // =====================================================================
    // 内部信号 — 与原始顶层完全相同的内部逻辑
    // =====================================================================

    // -- M1: puf_key 适配 --
    wire [127:0] aes_key;
    wire [31:0]  puf_fingerprint_int;
    wire         kdf_done;
    wire         kdf_start;
    wire [31:0]  puf_context;

    assign kdf_start   = puf_valid;
    assign puf_context = {24'd0, model_id};

    // -- M2: secure_boot_chain 适配 --
    wire        boot_valid;
    wire        boot_error;
    wire        system_ready;
    wire [7:0]  boot_step;
    wire [3:0]  boot_reason;
    wire        bootloader_verified;
    wire        kernel_verified;
    wire [127:0] bootloader_hash;
    wire [255:0] bootloader_sig;
    wire [127:0] kernel_hash;
    wire [255:0] kernel_sig;

    assign bootloader_hash = {120'd0, model_id};
    assign bootloader_sig  = {248'd0, model_id, model_id[7:0]};
    assign kernel_hash     = {120'd0, inference_request};
    assign kernel_sig      = {248'd0, inference_request, inference_request[7:0]};

    // -- M3: sidechannel_guard 适配 --
    wire         guard_start;
    wire [31:0]  guard_operand;
    wire [31:0]  guard_operand_b0;
    wire [31:0]  guard_operand_b1;
    wire [15:0]  guard_op_id;
    wire [31:0]  m3_result0;
    wire [31:0]  m3_result1;
    wire         m3_result_valid;
    wire [31:0]  m3_mask_o;
    wire [15:0]  m3_delay_o;
    wire         m3_trng_health;

    assign guard_start       = inference_done;
    assign guard_operand     = {24'd0, inference_result};
    assign guard_operand_b0  = {24'd0, inference_result};
    assign guard_operand_b1  = {24'd0, inference_result};
    assign guard_op_id       = {8'd0, model_id};

    // -- Phase 3 新模块信号 --
    wire        ntt_start;
    wire        ntt_busy;
    wire        ntt_done;
    wire [7:0]  ntt_a_addr;
    wire [22:0] ntt_a_data;
    wire        ntt_a_wr;
    wire [7:0]  ntt_b_addr;
    wire [22:0] ntt_b_data;
    wire        ntt_b_wr;
    wire [7:0]  ntt_c_addr;
    wire [22:0] ntt_c_data;
    wire [1:0]  ntt_mode;
    wire [22:0] ntt_omega_k;

    wire        lstm_start;
    wire        lstm_busy;
    wire        lstm_done;
    wire [0:0]  lstm_x_in;
    wire        lstm_x_valid;
    wire        lstm_x_ready;
    wire [1:0]  lstm_anomaly_score;
    wire        lstm_anomaly_detected;
    wire        lstm_inference_ready;

    wire        abe_start;
    wire        abe_busy;
    wire        abe_done;
    wire [7:0]  abe_attr_id;
    wire [127:0] abe_message;
    wire [63:0] abe_policy_attrs;
    wire [127:0] abe_master_key;
    wire [127:0] abe_encrypted_data;
    wire [127:0] abe_decrypted_data;
    wire        abe_decryption_ok;
    wire        abe_encryption_ok;

    wire        mpc_start;
    wire        mpc_busy;
    wire        mpc_done;
    wire [1:0]  mpc_protocol;
    wire [127:0] mpc_secret;
    wire [3:0]  mpc_num_participants;
    wire [127:0] mpc_message;
    wire [127:0] mpc_result;
    wire        mpc_computation_ok;
    wire        mpc_sharding_ok;
    wire        mpc_reconstruction_ok;

    // AI 威胁检测内部信号
    wire        ai_power_trace;
    wire        ai_threat_level;
    wire        ai_adaptive_masking;

    // 错误信号
    wire        dilithium_error;
    wire        fsm_error_wire;
    wire        temp_error;

    // =====================================================================
    // M1 : PUF 密钥派生
    // =====================================================================
    puf_key u_m1 (
        .clk            (clk),
        .rst_n          (rst_n),
        .puf_seed       ({112'd0, puf_fingerprint}),
        .puf_context    (puf_context),
        .kdf_start      (kdf_start),
        .aes_key        (aes_key),
        .puf_fingerprint(puf_fingerprint_int),
        .kdf_done       (kdf_done),
        .key_valid      (key_valid)
    );

    assign derivated_key = aes_key[15:0];

    // =====================================================================
    // M2 : 安全启动链
    // =====================================================================
    secure_boot_chain u_m2 (
        .clk                   (clk),
        .rst_n                 (rst_n),
        .bootloader_hash       (bootloader_hash),
        .bootloader_sig        (bootloader_sig),
        .kernel_hash           (kernel_hash),
        .kernel_sig            (kernel_sig),
        .boot_valid            (boot_valid),
        .boot_error            (boot_error),
        .boot_step             (boot_step),
        .boot_reason           (boot_reason),
        .bootloader_verified   (bootloader_verified),
        .kernel_verified       (kernel_verified),
        .system_ready          (system_ready)
    );

    assign secure_boot_done     = boot_valid;
    assign boot_verification_ok = system_ready;
    assign model_load_done      = system_ready;

    // =====================================================================
    // M3 : 侧信道防护
    // =====================================================================
    sidechannel_guard #(
        .W        (32),
        .MAX_DELAY(16)
    ) u_m3 (
        .clk              (clk),
        .rst_n            (rst_n),
        .reseed           (1'b0),
        .entropy          (128'd0),
        .start            (guard_start),
        .operand_a_plain  (guard_operand),
        .operand_b0       (guard_operand_b0),
        .operand_b1       (guard_operand_b1),
        .op_id            (guard_op_id),
        .result0          (m3_result0),
        .result1          (m3_result1),
        .result_valid     (m3_result_valid),
        .mask_o           (m3_mask_o),
        .delay_o          (m3_delay_o),
        .trng_health      (m3_trng_health)
    );

    assign masking_enabled = m3_result_valid;
    assign trng_output     = m3_mask_o[0];
    assign trng_valid      = m3_result_valid;

    // =====================================================================
    // Dilithium 后量子密码核心
    // =====================================================================
    dilithium_core u_dilithium (
        .clk        (clk),
        .rst_n      (rst_n),
        .sign_req   (dilithium_sign_req),
        .verify_req (1'b0),
        .message    (256'd0),
        .private_key({240'd0, dilithium_private_key}),
        .public_key (256'd0),
        .signature  (256'd0),
        .signature_r(dilithium_signature_r),
        .signature_s(dilithium_signature_s),
        .sig_valid  (dilithium_sig_valid),
        .verify_result(dilithium_verify_result),
        .error      (dilithium_error),
        .ready      ()
    );

    // =====================================================================
    // 混合签名验证状态机
    // =====================================================================
    hybrid_signature_fsm u_hybrid_sig (
        .clk            (clk),
        .rst_n          (rst_n),
        .inference_request({120'd0, inference_request}),
        .puf_id         ({120'd0, model_id}),
        .secure_boot_ok (boot_verification_ok),
        .inference_done (inference_done),
        .inference_result({120'd0, inference_result}),
        .fsm_secure    (),
        .fsm_sign_valid (),
        .fsm_verify_valid(),
        .fsm_error     (fsm_error_wire),
        .fsm_ready     (),
        .fsm_sign_req  (),
        .fsm_verify_req()
    );

    // =====================================================================
    // OP-PUF 控制器
    // =====================================================================
    optical_puf_controller u_op_puf (
        .clk        (clk),
        .rst_n      (rst_n),
        .puf_request({120'd0, inference_request}),
        .puf_start  (1'b0),
        .puf_mode   (3'd0),
        .puf_id     (8'd0),
        .puf_output (),
        .puf_valid  (),
        .error      (temp_error),
        .puf_status (),
        .puf_entropy(),
        .puf_ready  ()
    );

    // =====================================================================
    // Phase 3 新模块接入
    // =====================================================================
    assign ntt_start     = dilithium_sign_req;
    assign ntt_mode      = 2'd2;
    assign ntt_omega_k   = 23'd0;
    assign ntt_a_addr    = 8'd0;
    assign ntt_a_data    = 23'd0;
    assign ntt_a_wr      = 1'b0;
    assign ntt_b_addr    = 8'd0;
    assign ntt_b_data    = 23'd0;
    assign ntt_b_wr      = 1'b0;

    dilithium_ntt u_ntt (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (ntt_start),
        .busy       (ntt_busy),
        .done       (ntt_done),
        .a_addr     (ntt_a_addr),
        .a_data     (ntt_a_data),
        .a_wr       (ntt_a_wr),
        .b_addr     (ntt_b_addr),
        .b_data     (ntt_b_data),
        .b_wr       (ntt_b_wr),
        .c_addr     (ntt_c_addr),
        .c_data     (ntt_c_data),
        .mode       (ntt_mode),
        .omega_k    (ntt_omega_k)
    );

    assign lstm_start    = inference_done;
    assign lstm_x_in     = inference_request[0:0];
    assign lstm_x_valid  = inference_done;

    lstm_inference u_lstm (
        .clk              (clk),
        .rst_n            (rst_n),
        .start            (lstm_start),
        .busy             (lstm_busy),
        .done             (lstm_done),
        .x_in             (lstm_x_in),
        .x_valid          (lstm_x_valid),
        .x_ready          (lstm_x_ready),
        .anomaly_score    (lstm_anomaly_score),
        .anomaly_detected (lstm_anomaly_detected),
        .inference_ready  (lstm_inference_ready)
    );

    assign abe_start        = inference_done;
    assign abe_attr_id      = model_id;
    assign abe_message      = {120'd0, inference_request};
    assign abe_policy_attrs = {56'd0, model_id};
    assign abe_master_key   = {112'd0, aes_key[15:0]};

    abe_engine u_abe (
        .clk            (clk),
        .rst_n          (rst_n),
        .start          (abe_start),
        .busy           (abe_busy),
        .done           (abe_done),
        .attr_valid     (1'b1),
        .attr_id        (abe_attr_id),
        .attr_ready     (),
        .message        (abe_message),
        .msg_valid      (1'b1),
        .policy_attrs   (abe_policy_attrs),
        .policy_valid   (1'b1),
        .master_key     (abe_master_key),
        .key_valid      (key_valid),
        .encrypted_data (abe_encrypted_data),
        .decrypted_data (abe_decrypted_data),
        .decryption_ok  (abe_decryption_ok),
        .encryption_ok  (abe_encryption_ok)
    );

    assign mpc_start          = inference_done;
    assign mpc_protocol       = 2'd0;
    assign mpc_secret         = {120'd0, inference_request};
    assign mpc_num_participants = 4'd3;

    mpc_communication u_mpc (
        .clk                (clk),
        .rst_n              (rst_n),
        .start              (mpc_start),
        .busy               (mpc_busy),
        .done               (mpc_done),
        .protocol           (mpc_protocol),
        .secret             (mpc_secret),
        .secret_valid       (1'b1),
        .num_participants   (mpc_num_participants),
        .participants_ready (1'b1),
        .mpc_message        (mpc_message),
        .mpc_ready          (),
        .mpc_result         (mpc_result),
        .computation_ok     (mpc_computation_ok),
        .sharding_ok        (mpc_sharding_ok),
        .reconstruction_ok  (mpc_reconstruction_ok)
    );

    // =====================================================================
    // AI 威胁检测模块
    // =====================================================================
    ai_threat_detector u_ai_threat (
        .clk              (clk),
        .rst_n            (rst_n),
        .power_trace      (ai_power_trace),
        .threat_level     (ai_threat_level),
        .adaptive_masking (ai_adaptive_masking),
        .inference_status (inference_done)
    );

    // =====================================================================
    // 输出连接
    // =====================================================================
    assign inference_done   = kdf_done;
    assign inference_result = aes_key[7:0];
    assign status_register  = {ai_threat_level, boot_step[6:0]};
    assign error_flag       = dilithium_error | fsm_error_wire | temp_error | boot_error;

    // =====================================================================
    // LED 输出映射
    // =====================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            test_led <= 16'd0;
        end else begin
            // LED[15:12] : 系统状态
            // LED[11:8]  : 推理结果
            // LED[7:4]   : Dilithium 签名
            // LED[3:0]   : 诊断信号
            test_led <= {
                key_valid,           // LED[15]
                secure_boot_done,    // LED[14]
                boot_verification_ok,// LED[13]
                error_flag,          // LED[12]
                inference_result[7:4], // LED[11:8]
                dilithium_signature_r[3:0], // LED[7:4]
                dilithium_sig_valid, // LED[3]
                masking_enabled,     // LED[2]
                trng_valid,          // LED[1]
                inference_done       // LED[0]
            };
        end
    end

endmodule