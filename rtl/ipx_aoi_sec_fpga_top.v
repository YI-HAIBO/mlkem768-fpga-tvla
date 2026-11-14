`timescale 1ns / 1ps

/**
 * IPX-AOI-Sec FPGA 顶层安全模块 (Phase 4 集成版)
 * 作者：Dr. Haibo Yi (海博易, 深圳技术大学)
 * 版本：v2.0 | 日期：2026-10-06
 *
 * Phase 4 合并说明：
 *   - 替换 Phase 2 的 3 个桩（module1_puf_key / secure_boot_chain /
 *     sidechannel_guard）为 A 线已通过 172 项验证的真实实现，拷贝于
 *     rtl/real/（源：研发/rtl/）。
 *   - 新增接入 Phase 3 的四个模块：dilithium_ntt / lstm_inference /
 *     abe_engine / mpc_communication。
 *   - ai_threat_detector 仍为桩（A 线无真实 LSTM 推理引擎对应实现）。
 *
 * 接口适配：真实模块的端口与旧桩不同，顶层内部用适配线网桥接，
 * 顶层端口列表保持不变（兼容 tb_ipx_aoi_sec_fpga_top.v）。
 */

module ipx_aoi_sec_fpga_top (
    // 系统时钟
    input wire clk,
    input wire rst_n,

    // PUF 输入
    input wire [255:0] puf_fingerprint,
    input wire puf_valid,

    // 模型加载接口
    input wire [127:0] model_id,
    input wire model_load_req,
    output wire model_load_done,

    // 推理请求接口
    input wire [127:0] inference_request,
    output wire inference_done,
    output wire [127:0] inference_result,

    // 安全启动链控制
    input wire secure_boot_req,
    output wire secure_boot_done,
    output wire boot_verification_ok,

    // 密钥管理
    output wire [256:0] derivated_key,
    output wire key_valid,

    // Dilithium 后量子签名接口
    input wire dilithium_sign_req,
    input wire [255:0] dilithium_private_key,
    output wire [255:0] dilithium_signature_r,
    output wire [255:0] dilithium_signature_s,
    output wire dilithium_sig_valid,
    output wire dilithium_verify_result,

    // ML-KEM (Kyber-768) 后量子密钥封装接口
    input wire kem_start,
    input wire kem_op_keygen,
    input wire kem_op_encaps,
    output wire kem_busy,
    output wire kem_done,
    output wire kem_error,
    output wire kem_pk_valid,
    output wire kem_ct_valid,
    output wire kem_ss_valid,
    output wire [7:0] kem_ss_data,

    // 侧信道防护控制
    output wire masking_enabled,
    output wire trng_output,
    output wire trng_valid,

    // 诊断与监控
    output wire [7:0] status_register,
    output wire error_flag
);

    // =====================================================================
    // 内部信号
    // =====================================================================

    // -- M1: puf_key (真实) 适配 --
    wire [127:0] aes_key;
    wire [31:0]  puf_fingerprint_int;
    wire         kdf_done;
    wire         kdf_start;
    wire [31:0]  puf_context;

    // puf_valid 作为 KDF 启动脉冲；上下文取自 model_id 低 32 位
    assign kdf_start   = puf_valid;
    assign puf_context = model_id[31:0];

    // -- M2: secure_boot_chain (真实) 适配 --
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

    // 签名输入由 model_id / inference_request 派生（真实系统中来自 flash）
    assign bootloader_hash = model_id;
    assign bootloader_sig  = {model_id, model_id};
    assign kernel_hash     = inference_request;
    assign kernel_sig      = {inference_request, inference_request};

    // -- M3: sidechannel_guard (真实) 适配 --
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

    // 推理完成时触发掩码计算；操作数取自推理结果
    assign guard_start       = inference_done;
    assign guard_operand     = inference_result[31:0];
    assign guard_operand_b0  = inference_result[63:32];
    assign guard_operand_b1  = inference_result[95:64];
    assign guard_op_id       = model_id[15:0];

    // -- Phase 3 新模块信号 --
    // dilithium_ntt
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

    // lstm_inference
    wire        lstm_start;
    wire        lstm_busy;
    wire        lstm_done;
    wire [0:0]  lstm_x_in;
    wire        lstm_x_valid;
    wire        lstm_x_ready;
    wire [1:0]  lstm_anomaly_score;
    wire        lstm_anomaly_detected;
    wire        lstm_inference_ready;

    // abe_engine
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

    // mpc_communication
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

    // -- ML-KEM (Kyber-768) 后量子密钥封装 --
    wire        kem_start_int;
    wire        kem_op_keygen_int;
    wire        kem_op_encaps_int;
    wire        kem_in_load;
    wire [7:0]  kem_in_addr;
    wire [7:0]  kem_in_data;
    wire        kem_ct_load;
    wire [15:0] kem_ct_in_addr;
    wire [15:0] kem_ct_data_in;
    wire [15:0] kem_pk_addr;
    wire [15:0] kem_pk_data;
    wire [15:0] kem_ct_addr;
    wire [15:0] kem_ct_data;
    wire [7:0]  kem_ss_data_int;

    // -- AI 威胁检测（真实实现）内部信号 --
    // 功耗采样
    wire        ai_power_trace;
    // 输出信号
    wire        ai_threat_level;
    wire        ai_adaptive_masking;

    // -- 错误信号 --
    wire        dilithium_error;
    wire        fsm_error_wire;
    wire        temp_error;

    // =====================================================================
    // M1 : PUF 密钥派生（真实 puf_key）
    // =====================================================================
    puf_key u_m1 (
        .clk            (clk),
        .rst_n          (rst_n),
        .puf_seed       (puf_fingerprint),
        .puf_context    (puf_context),
        .kdf_start      (kdf_start),
        .aes_key        (aes_key),
        .puf_fingerprint(puf_fingerprint_int),
        .kdf_done       (kdf_done),
        .key_valid      (key_valid)
    );

    // derivated_key 顶层为 257 位，真实密钥 128 位，高位补零
    assign derivated_key = {129'd0, aes_key};

    // =====================================================================
    // M2 : 安全启动链（真实 secure_boot_chain）
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
    // M3 : 侧信道防护（真实 sidechannel_guard）
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

    // 掩码使能 = 掩码结果有效；TRNG 输出取自掩码
    assign masking_enabled = m3_result_valid;
    assign trng_output     = {96'd0, m3_mask_o};
    assign trng_valid      = m3_result_valid;

    // =====================================================================
    // Dilithium 后量子密码核心 (Phase 2)
    // =====================================================================
    dilithium_core u_dilithium (
        .clk        (clk),
        .rst_n      (rst_n),
        .sign_req   (dilithium_sign_req),
        .verify_req (1'b0),
        .message    (256'd0),
        .private_key(dilithium_private_key),
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
    // 混合签名验证状态机 (Phase 3)
    // =====================================================================
    hybrid_signature_fsm u_hybrid_sig (
        .clk            (clk),
        .rst_n          (rst_n),
        .inference_request(inference_request),
        .puf_id         (model_id),
        .secure_boot_ok (boot_verification_ok),
        .inference_done (inference_done),
        .inference_result(inference_result),
        .fsm_secure    (),
        .fsm_sign_valid (),
        .fsm_verify_valid(),
        .fsm_error     (fsm_error_wire),
        .fsm_ready     (),
        .fsm_sign_req  (),
        .fsm_verify_req()
    );

    // =====================================================================
    // OP-PUF 控制器 (Phase 3)
    // =====================================================================
    optical_puf_controller u_op_puf (
        .clk        (clk),
        .rst_n      (rst_n),
        .puf_request(inference_request),
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

    // -- dilithium_ntt：多项式乘法协处理器 --
    assign ntt_start     = dilithium_sign_req;
    assign ntt_mode      = 2'd2;          // 乘法模式
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

    // -- lstm_inference：1-bit 量化异常检测 --
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

    // -- abe_engine：基于属性的加密引擎 --
    assign abe_start        = inference_done;
    assign abe_attr_id      = model_id[7:0];
    assign abe_message      = inference_request;
    assign abe_policy_attrs = {56'd0, model_id[7:0]};
    assign abe_master_key   = {128'd0, aes_key};

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

    // -- mpc_communication：安全多方计算通信模块 --
    assign mpc_start          = inference_done;
    assign mpc_protocol       = 2'd0;        // Shamir SSS
    assign mpc_secret         = inference_request;
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
    // ML-KEM (Kyber-768) 后量子密钥封装 (Task 59)
    // =====================================================================
    // KeyGen 由 kem_start + kem_op_keygen 触发；
    //   seed 取自 PUF 指纹低 32 位，message 取自 model_id 低 32 位。
    // Encaps 由 kem_start + kem_op_encaps 触发；
    //   message 取自 inference_request 低 32 位。

    assign kem_start_int    = kem_start;
    assign kem_op_keygen_int = kem_op_keygen;
    assign kem_op_encaps_int = kem_op_encaps;
    assign kem_in_load      = kem_start;
    assign kem_in_addr      = 8'd0;
    assign kem_in_data      = kem_op_keygen ? puf_fingerprint[7:0]
                                            : model_id[7:0];
    assign kem_ct_load      = 1'b0;         // 顶层暂不接 Decaps
    assign kem_ct_in_addr   = 16'd0;
    assign kem_ct_data_in   = 16'd0;

    kyber_kem #(
        .K    (3),
        .N    (256),
        .Q    (3329),
        .BW   (16),
        .ETA  (2),
        .DU   (10),
        .DV   (4),
        .R_MOD(2285),
        .SEED_B(32),
        .MSG_B (32),
        .SS_B  (32)
    ) u_kem (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (kem_start_int),
        .op_keygen  (kem_op_keygen_int),
        .op_encaps  (kem_op_encaps_int),
        .busy       (kem_busy),
        .done       (kem_done),
        .error      (kem_error),
        .in_load    (kem_in_load),
        .in_addr    (kem_in_addr),
        .in_data    (kem_in_data),
        .ct_load    (kem_ct_load),
        .ct_in_addr (kem_ct_in_addr),
        .ct_data_in (kem_ct_data_in),
        .pk_valid   (kem_pk_valid),
        .pk_addr    (kem_pk_addr),
        .pk_data    (kem_pk_data),
        .ct_valid   (kem_ct_valid),
        .ct_addr    (kem_ct_addr),
        .ct_data    (kem_ct_data),
        .ss_valid   (kem_ss_valid),
        .ss_data    (kem_ss_data)
    );

    // =====================================================================
    // AI 威胁检测模块（桩，A 线无真实 LSTM 引擎对应）
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
    assign inference_result = {m3_result1, m3_result0, aes_key[63:0]};
    assign status_register  = {kem_ss_valid, kem_done, kem_busy,
                               kem_pk_valid, kem_ct_valid,
                               kem_error, kem_op_keygen, kem_op_encaps};
    assign error_flag       = dilithium_error | fsm_error_wire | temp_error
                             | boot_error | kem_error;

endmodule