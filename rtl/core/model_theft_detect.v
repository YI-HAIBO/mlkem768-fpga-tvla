// =============================================================================
// C3 — Model Extraction (Theft) Detector, hardware-accelerated
// -----------------------------------------------------------------------------
// A model-extraction attack feeds many inputs to the protected model and tries
// to fit a copy of it.  Detecting the copy requires a property the legitimate
// owner has and the attacker cannot guess: a keyed signature that the model
// itself publishes.
//
// Construction:
//   * the owner holds a secret key K[15:0], never exposed on any pin;
//   * for each canary input the owner pre-computes a 16-bit tag
//         tag[7:0]  = XOR_j gf256(K[7:0],  digest[j])
//         tag[15:8] = XOR_j gf256(K[15:8], digest[j])      (digest = 8 bytes)
//   * the protected model is instructed to embed tag in out[6:0]/out[7:0]
//     (the two low bytes of its 8-byte result).  Out of the 64 output bits the
//     owner therefore "burns" 16 as a canary — exactly the precision/area
//     trade-off C2 schedules.
//
// Detection:
//   * feed each canary digest to the SUSPECT model, capture its 8-byte output;
//   * recompute the expected tag on-chip from K and the digest;
//   * a full 16-bit match means the suspect model reproduces the keyed
//     signature, which a genuinely independent model cannot do without the key.
//   * verdict: detected iff enough canaries exist and match_cnt >= threshold.
//
// False-positive bound: a random model matches one canary with probability
// 2^-16; requiring all N to match gives 2^(-16*N).  8 canaries -> 2^-128.
// There is no symmetric cost on the legitimate model — it always emits its tag,
// so the detector never fires against the owner.
// =============================================================================
module model_theft_detect (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        cmd_valid,
    input  wire [3:0]  cmd,
    output reg         busy,
    output reg         done,
    output reg         error,          // illegal cmd / table full / bad index (sticky)
    // single-port byte memory: RAM for digests/outputs, >=0xF00 for registers
    input  wire        wr_valid,
    input  wire [11:0] wr_addr,
    input  wire [7:0]  wr_data,
    input  wire        rd_valid,
    input  wire [11:0] rd_addr,
    output wire [7:0]  rd_data,
    output reg  [4:0]  canary_cnt,
    output reg  [7:0]  match_cnt,
    output reg  [7:0]  mismatch_cnt,
    output reg         detected,       // theft verdict
    output reg         insufficient    // not enough probes to judge
);

    localparam [3:0]
        C_RESET      = 4'h0,
        C_SET_KEY    = 4'h1,
        C_ADD_CANARY = 4'h2,
        C_PROBE      = 4'h3,
        C_DETECT     = 4'h4;

    localparam [11:0]
        R_KEY0      = 12'hF00,
        R_KEY1      = 12'hF01,
        R_IDX       = 12'hF10,
        R_THRES     = 12'hF11,
        R_CANARYCNT = 12'hF12,
        R_MATCHCNT  = 12'hF13,
        R_MISMATCH  = 12'hF14,
        R_VERDICT   = 12'hF15;

    // ---- memory layout ------------------------------------------------------
    // 0x000..0x007  canary input digest  (8 bytes)
    // 0x010..0x017  suspect model output (8 bytes; out[6..7] is the tag field)
    localparam [11:0] DIGEST_BASE = 12'h000;
    localparam [11:0] OUT_BASE    = 12'h010;
    localparam        MAX_CANARY  = 5'd8;

    // ---- secret key, canary table, counters ---------------------------------
    reg [15:0] key;
    reg [15:0] ctag [0:7];
    reg [7:0]  ram  [0:4095];
    reg [4:0]  cnt;
    reg [7:0]  mcnt, xcnt;
    reg [7:0]  idx, thres;
    integer    k;

    // ---- GF(2^8) multiplier, 0x11B (shift method verified in B4) ----------
    function [7:0] gf256;
        input [7:0] a, b;
        reg  [7:0] acc, ai;
        integer j;
        begin
            acc = 8'd0;
            ai  = a;
            for (j = 0; j < 8; j = j + 1) begin
                if (b[j]) acc = acc ^ ai;
                if (ai[7]) ai = (ai << 1) ^ 8'h1B;
                else       ai = ai << 1;
                ai = ai & 8'hFF;
            end
            gf256 = acc;
        end
    endfunction

    // ---- tag computation (combinational, reads digest RAM) ------------------
    reg [15:0] tag_c;
    always @(*) begin
        tag_c = 16'd0;
        for (k = 0; k < 8; k = k + 1) begin
            tag_c[7:0]  = tag_c[7:0]  ^ gf256(key[7:0],  ram[DIGEST_BASE + k]);
            tag_c[15:8] = tag_c[15:8] ^ gf256(key[15:8], ram[DIGEST_BASE + k]);
        end
    end

    // ---- register map read ---------------------------------------------------
    reg [7:0] rd_mux;
    assign rd_data = rd_mux;
    always @(*) begin
        rd_mux = 8'd0;
        if (rd_valid) begin
            if      (rd_addr == R_KEY0)      rd_mux = key[7:0];
            else if (rd_addr == R_KEY1)      rd_mux = key[15:8];
            else if (rd_addr == R_IDX)       rd_mux = idx;
            else if (rd_addr == R_THRES)     rd_mux = thres;
            else if (rd_addr == R_CANARYCNT) rd_mux = {3'b0, canary_cnt};
            else if (rd_addr == R_MATCHCNT)  rd_mux = match_cnt;
            else if (rd_addr == R_MISMATCH)  rd_mux = mismatch_cnt;
            else if (rd_addr == R_VERDICT)   rd_mux = {5'b0, detected, insufficient};
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key <= 16'd0;
            idx <= 8'd0; thres <= 8'd1;
            cnt <= 5'd0; mcnt <= 8'd0; xcnt <= 8'd0;
            busy <= 1'b0; done <= 1'b0; error <= 1'b0;
            canary_cnt <= 5'd0; match_cnt <= 8'd0; mismatch_cnt <= 8'd0;
            detected <= 1'b0; insufficient <= 1'b0;
            for (k = 0; k < 8; k = k + 1) begin
                ctag[k] <= 16'd0;
                ram[DIGEST_BASE + k] <= 8'd0;
                ram[OUT_BASE + k]     <= 8'd0;
            end
        end else begin
            if (wr_valid) begin
                if (wr_addr < 12'hF00)
                    ram[wr_addr[11:0]] <= wr_data;
                else if (wr_addr == R_KEY0)  key[7:0]  <= wr_data;
                else if (wr_addr == R_KEY1)  key[15:8] <= wr_data;
                else if (wr_addr == R_IDX)   idx  <= wr_data;
                else if (wr_addr == R_THRES) thres <= wr_data;
            end

            if (cmd_valid && !busy) begin
                case (cmd)
                    C_RESET: begin
                        cnt<=5'd0; mcnt<=8'd0; xcnt<=8'd0; idx<=8'd0; thres<=8'd1;
                        canary_cnt<=5'd0; match_cnt<=8'd0; mismatch_cnt<=8'd0;
                        detected<=1'b0; insufficient<=1'b0; error<=1'b0; done<=1'b1;
                    end
                    C_SET_KEY: begin
                        done <= 1'b1;
                    end
                    C_ADD_CANARY: begin
                        if (cnt < MAX_CANARY) begin
                            ctag[cnt]    <= tag_c;
                            cnt          <= cnt + 5'd1;
                            canary_cnt   <= cnt + 5'd1;
                        end else begin
                            error <= 1'b1;
                        end
                        done <= 1'b1;
                    end
                    C_PROBE: begin
                        // suspect tag field = out[6..7]; expected = ctag[idx]
                        if (idx >= cnt) begin
                            error <= 1'b1;
                        end else if ({ram[OUT_BASE + 7], ram[OUT_BASE + 6]} === ctag[idx]) begin
                            mcnt         <= mcnt + 8'd1;
                            match_cnt    <= mcnt + 8'd1;
                        end else begin
                            xcnt           <= xcnt + 8'd1;
                            mismatch_cnt   <= xcnt + 8'd1;
                        end
                        done <= 1'b1;
                    end
                    C_DETECT: begin
                        if ((mcnt + xcnt) < thres) begin
                            insufficient <= 1'b1;
                            detected     <= 1'b0;
                        end else begin
                            insufficient <= 1'b0;
                            detected     <= (cnt >= thres) && (mcnt >= thres);
                        end
                        done <= 1'b1;
                    end
                    default: begin
                        error <= 1'b1;
                    end
                endcase
            end else if (!cmd_valid) begin
                done <= 1'b0;
            end
        end
    end

endmodule
