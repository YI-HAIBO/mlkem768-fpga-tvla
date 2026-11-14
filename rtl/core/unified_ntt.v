// =============================================================================
// unified_ntt.v - Parameterized NTT/INTT for Unified Reuse Architecture (A1)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec  (A1: NTT unified reuse)
//
// Design goal: a SINGLE synthesizable NTT core that can be configured at
// compile-time (parameters, reset defaults) or RUNTIME (Task 76: cfg_* ports
// + zeta ROM reload) for different lattice algorithms, sharing the exact same
// 8-phase butterfly pipeline, 5-phase reduce pipeline and 6-phase scale
// pipeline.
//
// Configurations supported:
//   KEM  : q=3329,    7 layers, BW=16 native  (SCALE_K=1441, QINV=62209)
//   SIGN : q=8380417, 8 layers, BW=27         (SCALE_K=49145, QINV=58728449)
//
// Runtime dual-mode switching (Task 76)
// --------------------------------------
// A single physical instance fixed to the widest datapath (BW=27, N_LAYERS=8)
// can run BOTH algorithms: the cfg_* port pair loads Q / QINV / SCALE_K /
// BARRETT_M / BARRETT_SH / N_LAYERS into registers (write while idle), and the
// zeta ROM is reloaded via the existing zeta_load interface.  KEM constants
// must be re-derived for the 2^27 Montgomery radix (see verify/kem27_model.py):
//   QINV27=61403905, SCALE_K27=2811, R=2^27 mod 3329 = 2435,
//   zeta27[i] = zeta16[i] * 2^11 mod 3329.
// Reset values of the config registers equal the compile-time parameters, so
// wrappers that tie cfg_load low behave EXACTLY like the original
// parameter-only core (dilithium_ntt.v and both legacy TBs rely on this).
//   cfg_addr encoding: 0=Q 1=QINV 2=SCALE_K 3=BARRETT_M
//                      4=BARRETT_SH (low 6b) 5=N_LAYERS (low 4b, 1..8)
//
// Architecture:
//   8-phase butterfly : ADDR -> READ -> SUB -> M0 -> M1 -> M2a1 -> M2a2 -> M2b
//   5-phase reduce    : READ -> M1' -> M2a -> M2b -> M2c+WRITE
//   6-phase scale     : READ -> M0  -> M1  -> M2a1 -> M2a2 -> M2b+WRITE
//
// Timing notes:
//   * The original single-phase Montgomery reduction carried 14 logic levels
//     on the SIGN configuration; splitting multiply/subtract into M2a1/M2a2
//     (Task 58 follow-up) fixed the synthesis-level path.
//   * Post-route (Task 73) the remaining -0.338 ns / 285-endpoint path ran
//     state[2] (fanout 954) -> LUT2 -> DSP48E1 cascade -> shared `prod`.
//     The butterfly M0 product and the INTT-scale M0 product now land in
//     SEPARATE registers (prod_bf / prod_sc); every DSP48E1 input is driven
//     straight from a flop, and the only state-dependent select left on the
//     datapath is the low-fanout (state==S_SCALE) 54-bit output mux
//     `prod_sel`.  fsm state bits now only drive register enables.
//
// Bit-width policy: the modular-multiplication product and all wide
// intermediate arithmetic are carried on W_WIDTH = 2*BW bits.  For KEM (BW=16)
// that is 32 bits (unchanged from the original); for SIGN (BW=27) it is 54
// bits, which holds the 27x27 Montgomery product and the Barrett term
// M*a (M = floor(2^48/q) ~ 2^25, a up to 2^26 -> product ~ 2^52).  The runtime
// KEM configuration keeps M=20159/SH=26: M*a <= 2^26*2^14 << 2^53.
//
// Zeta ROM: (1 << N_LAYERS) entries, loaded via zeta_load/zeta_addr/zeta_data
// ports.  Depth is parameterised (128 for a 7-layer KEM instance, 256 for the
// dual-mode / SIGN instance) and address width is N_LAYERS bits.  The ROM must
// be loaded before the first start; for runtime switching, reload it while
// idle.
//
// Verified:
//   - KEM mode (default params): bit-exact match with kyber_ntt.v KAT
//   - SIGN mode (Dilithium/ML-DSA params): bit-exact round-trip + poly_mul
//     against the pq-crystals reference (see verify/ and tb_unified_ntt_sign.v)
//   - Dual mode (tb_unified_ntt_dual.v): one BW=27 instance runs KEM
//     (cfg-loaded 2^27-radix constants) and SIGN back-to-back
//   - Round-trip: INTT(NTT(x)) = x * R mod q for both forward and inverse
//   - Zero polynomial: NTT(0) = 0, INTT(0) = 0
//
// NOTE: montgomery_reduce / fqmul / barrett_reduce below are reference
// implementations kept for documentation; the pipelined datapath implements
// the same arithmetic with the split M2a1/M2a2 registers and with the runtime
// configuration registers (they are NOT called by the FSM).
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module unified_ntt #(
    parameter integer N          = 256,   // polynomial size (must be power of 2)
    parameter integer N_LAYERS   = 7,     // NTT layers (log2(N) or log2(N)-1)
    parameter integer BW         = 16,    // coefficient bit-width (signed)
    parameter integer Q          = 3329,  // modulus (Kyber q=3329)
    parameter integer QINV       = 62209, // q^{-1} mod 2^16 (Kyber)
    parameter integer R_MOD      = 2285,  // R mod q (Montgomery form of 1)
    parameter integer SCALE_K    = 1441,  // INTT final scale (R^2 * N^{-1} mod q)
    parameter integer BARRETT_M  = 20159, // Barrett constant (ceil(2^26 / q))
    parameter integer BARRETT_SH = 26     // Barrett shift amount
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // Operation control
    input  wire                  start,
    input  wire                  inverse,     // 0 = forward NTT, 1 = inverse INTT
    output reg                   busy,
    output reg                   done,

    // Coefficient load interface
    input  wire                  load,
    input  wire [7:0]            load_addr,
    input  wire [BW-1:0]         load_data,

    // Coefficient read interface (combinational)
    input  wire [7:0]            read_addr,
    output wire [BW-1:0]         read_data,

    // Zeta ROM load interface (idle phase only)
    input  wire                  zeta_load,
    input  wire [N_LAYERS-1:0]   zeta_addr,
    input  wire [BW-1:0]         zeta_data,

    // Runtime configuration interface (Task 76, write while idle).
    // Reset values = the compile-time parameters above.
    input  wire                  cfg_load,
    input  wire [2:0]            cfg_addr,
    input  wire [BW-1:0]         cfg_data
);

    // -------------------------------------------------------------------------
    // Derived parameters
    // -------------------------------------------------------------------------
    localparam integer LOGN         = $clog2(N);               // = 8 for N=256
    localparam integer ZETA_DEPTH   = 1 << N_LAYERS;           // 128 (KEM) / 256 (SIGN)
    localparam integer W_WIDTH      = 2 * BW;                  // product / wide-ARITH width
    localparam integer SH_W         = 6;                       // BARRETT_SH reg width (<=48)
    localparam integer NL_W         = 4;                       // N_LAYERS reg width (<=8)
    // Reference-only Barrett rounding constant for the barrett_reduce()
    // function below (the pipelined datapath uses the runtime bar_add wire).
    localparam signed [W_WIDTH-1:0] BARRETT_ADD = 1 << (BARRETT_SH - 1);

    // -------------------------------------------------------------------------
    // Storage arrays
    // -------------------------------------------------------------------------
    reg [BW-1:0] coeff [0:N-1];
    reg [BW-1:0] zeta_rom [0:ZETA_DEPTH-1];

    // Zeta ROM: loadable register array, zeroed at reset
    integer zi;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (zi = 0; zi < ZETA_DEPTH; zi = zi + 1)
                zeta_rom[zi] <= {BW{1'b0}};
        end else if (zeta_load) begin
            zeta_rom[zeta_addr] <= zeta_data;
        end
    end

    // -------------------------------------------------------------------------
    // Runtime configuration registers (reset = compile-time parameter).
    // Every arithmetic constant below is taken from these registers, so a
    // dual-mode board can switch KEM<->SIGN without resynthesis.  Wrappers
    // that tie cfg_load low see the parameter-only behaviour of the
    // historical core.
    // -------------------------------------------------------------------------
    reg [BW-1:0]   q_r, qinv_r, scale_k_r, bm_r;
    reg [SH_W-1:0] sh_r;
    reg [NL_W-1:0] nl_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q_r       <= Q[BW-1:0];
            qinv_r    <= QINV[BW-1:0];
            scale_k_r <= SCALE_K[BW-1:0];
            bm_r      <= BARRETT_M[BW-1:0];
            sh_r      <= BARRETT_SH[SH_W-1:0];
            nl_r      <= N_LAYERS[NL_W-1:0];
        end else if (cfg_load) begin
            case (cfg_addr)
                3'd0: q_r       <= cfg_data;
                3'd1: qinv_r    <= cfg_data;
                3'd2: scale_k_r <= cfg_data;
                3'd3: bm_r      <= cfg_data;
                3'd4: sh_r      <= cfg_data[SH_W-1:0];
                3'd5: nl_r      <= cfg_data[NL_W-1:0];
                default: ;
            endcase
        end
    end

    // Signed (positive) 54-bit views of the runtime constants.  Zero-extension
    // is correct because every constant is positive and < 2^BW; casting the
    // unsigned regs straight into a signed multiply would otherwise reinterpret
    // the MSB as a sign bit.
    wire signed [W_WIDTH-1:0] q_se  = {{(W_WIDTH-BW){1'b0}}, q_r};
    wire signed [W_WIDTH-1:0] sk_se = {{(W_WIDTH-BW){1'b0}}, scale_k_r};
    wire signed [W_WIDTH-1:0] bm_se = {{(W_WIDTH-BW){1'b0}}, bm_r};
    // BARRETT_ADD = 2^(SH-1); 54-bit one shifted left by the runtime shift
    wire signed [W_WIDTH-1:0] bar_add = {{(W_WIDTH-1){1'b0}}, 1'b1} << (sh_r - 6'd1);

    // -------------------------------------------------------------------------
    // Parameterized modular arithmetic: reference functions (not used by the
    // pipelined datapath; see header note).
    // -------------------------------------------------------------------------

    // Montgomery reduction: a -> a * R^{-1} mod q  (BW-bit signed output)
    function [BW-1:0] montgomery_reduce;
        input [W_WIDTH-1:0] a;
        reg  [BW-1:0]        t_low;
        reg  signed [W_WIDTH-1:0] t_signed;
        reg  signed [W_WIDTH-1:0] result;
        begin
            t_low    = (a[0 +: BW] * QINV) & ((1 << BW) - 1);
            t_signed = {{(W_WIDTH-BW){t_low[BW-1]}}, t_low};
            result   = ($signed(a) - (t_signed * Q)) >>> BW;
            montgomery_reduce = result[0 +: BW];
        end
    endfunction

    // fqmul: Montgomery multiplication  a * b * R^{-1} mod q
    function [BW-1:0] fqmul;
        input [BW-1:0] a;
        input [BW-1:0] b;
        reg  signed [W_WIDTH-1:0] sa, sb;
        reg  [W_WIDTH-1:0]        prod;
        begin
            sa   = {{(W_WIDTH-BW){a[BW-1]}}, a};
            sb   = {{(W_WIDTH-BW){b[BW-1]}}, b};
            prod = sa * sb;
            fqmul = montgomery_reduce(prod);
        end
    endfunction

    // Barrett reduction: a -> a mod q in [-q/2, q/2]
    function [BW-1:0] barrett_reduce;
        input [BW-1:0] a;
        reg  signed [W_WIDTH-1:0] v_a;
        reg  signed [W_WIDTH-1:0] t;
        reg  signed [W_WIDTH-1:0] result;
        begin
            v_a    = BARRETT_M * {{(W_WIDTH-BW){a[BW-1]}}, a};
            t      = (v_a + BARRETT_ADD) >>> BARRETT_SH;
            result = {{(W_WIDTH-BW){a[BW-1]}}, a} - (t * Q);
            barrett_reduce = result[0 +: BW];
        end
    endfunction

    // -------------------------------------------------------------------------
    // NTT FSM
    // -------------------------------------------------------------------------
    localparam [2:0]  S_IDLE        = 3'd0,
                      S_LAYER_SETUP = 3'd1,
                      S_BUTTER      = 3'd2,
                      S_NEXT_BLOCK  = 3'd3,
                      S_NEXT_LAYER  = 3'd4,
                      S_REDUCE      = 3'd5,
                      S_SCALE       = 3'd6,
                      S_DONE        = 3'd7;

    reg [2:0]  state;
    reg [2:0]  layer_idx;
    reg [7:0]  block_cnt;
    reg [7:0]  j_cnt;
    reg [7:0]  len;
    reg [N_LAYERS-1:0] nblk;
    reg [N_LAYERS-1:0] zeta_cnt;
    reg [8:0]  cnt;
    reg        inv_mode;
    reg [3:0]  butter_ph;
    reg [2:0]  rph;

    // Butterfly pipeline registers
    reg [BW-1:0] pa, pb, zv_reg;
    reg [BW-1:0] rin;
    reg [BW-1:0] xd_reg;
    reg [BW-1:0] sum_reg;
    reg [8:0]    addr_a_reg, addr_b_reg;
    reg          last_butter;

    // Shared arithmetic pipeline registers.
    // prod_bf: butterfly M0 product (S_BUTTER ph3)
    // prod_sc: INTT-scale M0 product (S_SCALE ph1)
    // Split (Task 73) so both DSP48E1 cascaces have flop-only inputs; the FSM
    // state bits drive register enables, not DSP data selects.
    reg signed [W_WIDTH-1:0] prod_bf;
    reg signed [W_WIDTH-1:0] prod_sc;
    // Registered prod_sel select flag (Task 73, post-route WNS fix).
    // The combinational decode (state == S_SCALE) sat directly on the DSP48E1
    // cascade input of the M1 multiply: post-route timing showed
    //   state_reg[2]/C (fanout 954) -> LUT2 -> 3x DSP48E1 cascade
    // as the single critical structure (WNS -0.338 ns, 285 failing endpoints).
    // Sampling the flag one cycle ahead keeps that decode off the multiplier
    // input path without adding any pipeline stage: m1_w / mont_diff are only
    // consumed >= 2 cycles after every state transition, so a one-cycle-delayed
    // select is equivalent.
    reg                       prod_sel_scale;
    wire signed [W_WIDTH-1:0] prod_sel = prod_sel_scale ? prod_sc : prod_bf;
    reg [BW-1:0]            t_low;
    reg [BW-1:0]            s_reg;
    reg signed [W_WIDTH-1:0] v_a;
    reg signed [7:0]         bar_t_reg;
    reg signed [W_WIDTH-1:0] mont_diff_r;
    reg signed [W_WIDTH-1:0] bar_mul_r;
    // M2a1 -> M2a2 pipeline register: tq_prod = sign_ext(t_low) * Q.
    // Registers the DSP-bound multiply so the CARRY4-bound subtract can sit in
    // its own clock cycle (SIGN 100 MHz fix).
    (* use_dsp = "yes" *) reg signed [W_WIDTH-1:0] tq_prod;

    // -------------------------------------------------------------------------
    // block_start = block_cnt * (len << 1) -> DSP48E1
    // -------------------------------------------------------------------------
    (* use_dsp = "yes" *) reg [31:0] bs_p;
    always @(posedge clk) begin
        bs_p <= block_cnt * {len, 1'b0};
    end
    wire [8:0] block_start = bs_p[8:0];

    // -------------------------------------------------------------------------
    // Pipelined arithmetic wires (runtime-configured)
    // -------------------------------------------------------------------------
    wire signed [W_WIDTH-1:0] bf_zv_e     = {{(W_WIDTH-BW){zv_reg[BW-1]}}, zv_reg};
    wire signed [W_WIDTH-1:0] bf_operand  = inv_mode ? {{(W_WIDTH-BW){xd_reg[BW-1]}}, xd_reg}
                                              : {{(W_WIDTH-BW){pb[BW-1]}}, pb};
    (* use_dsp = "yes" *) wire signed [W_WIDTH-1:0] bf_m0
                                      = bf_zv_e * bf_operand;           // M0
    wire        [BW-1:0]      m1_w        = prod_sel[0 +: BW] * qinv_r;  // M1 (montgomery)

    wire signed [W_WIDTH-1:0] bf_va       = bm_se * $signed({{(W_WIDTH-BW){sum_reg[BW-1]}}, sum_reg});
    wire signed [W_WIDTH-1:0] rd_va       = bm_se * $signed({{(W_WIDTH-BW){rin[BW-1]}}, rin});

    // Montgomery reduction, split into two phases to break the 14-level
    // (DSP48E1x2 + CARRY4x11) critical path on the SIGN configuration.
    //   M2a1 : tq_prod <= tq_mul                      (DSP-bound)
    //   M2a2 : mont_diff_r <= mont_diff = prod - tq_prod   (CARRY4-bound)
    wire signed [W_WIDTH-1:0] tq_mul      = $signed({{(W_WIDTH-BW){t_low[BW-1]}}, t_low}) * q_se;
    wire signed [W_WIDTH-1:0] mont_diff   = prod_sel - tq_prod;
    wire signed [W_WIDTH-1:0] mont_sh     = mont_diff_r >>> BW;
    wire        [BW-1:0]      mont_res    = mont_sh[0 +: BW];

    wire signed [W_WIDTH-1:0] bar_sub     = $signed({{(W_WIDTH-BW){s_reg[BW-1]}}, s_reg}) - bar_mul_r;
    wire        [BW-1:0]      bar_res     = bar_sub[0 +: BW];

    wire        [BW-1:0]      fwd_a       = pa + mont_res;
    wire        [BW-1:0]      fwd_b       = pa - mont_res;

    (* use_dsp = "yes" *) wire signed [W_WIDTH-1:0] sc_m0w
                                      = {{(W_WIDTH-BW){rin[BW-1]}}, rin} * sk_se;

    // -------------------------------------------------------------------------
    // Main FSM
    // -------------------------------------------------------------------------
    integer gi;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            busy       <= 1'b0;
            done       <= 1'b0;
            layer_idx  <= 3'd0;
            block_cnt  <= 8'd0;
            j_cnt      <= 8'd0;
            len        <= 8'd0;
            nblk       <= {N_LAYERS{1'b0}};
            zeta_cnt   <= {N_LAYERS{1'b0}};
            cnt        <= 9'd0;
            inv_mode   <= 1'b0;
            butter_ph  <= 4'd0;
            rph        <= 3'd0;
            prod_bf    <= {W_WIDTH{1'b0}};
            prod_sc    <= {W_WIDTH{1'b0}};
            t_low      <= {BW{1'b0}};
            s_reg      <= {BW{1'b0}};
            v_a        <= {W_WIDTH{1'b0}};
            bar_t_reg  <= 8'sd0;
            mont_diff_r<= {W_WIDTH{1'b0}};
            bar_mul_r  <= {W_WIDTH{1'b0}};
            tq_prod    <= {W_WIDTH{1'b0}};
            pa         <= {BW{1'b0}};
            pb         <= {BW{1'b0}};
            zv_reg     <= {BW{1'b0}};
            xd_reg     <= {BW{1'b0}};
            sum_reg    <= {BW{1'b0}};
            rin        <= {BW{1'b0}};
            prod_sel_scale <= 1'b0;
            for (gi = 0; gi < N; gi = gi + 1)
                coeff[gi] <= {BW{1'b0}};
        end else begin
            done <= 1'b0;
            prod_sel_scale <= (state == S_SCALE);

            // Load interface (works in any state)
            if (load) begin
                coeff[load_addr] <= load_data;
            end

            case (state)
                // -------------------------------------------------------------
                S_IDLE: begin
                    if (start) begin
                        busy     <= 1'b1;
                        inv_mode <= inverse;
                        // Layer schedule is derived from the RUNTIME layer
                        // count nl_r so a single BW=27/N_LAYERS=8 instance can
                        // also run the 7-layer KEM transform.
                        if (inverse) begin
                            zeta_cnt  <= (1 << nl_r) - 1;
                            layer_idx <= 3'd0;
                            len       <= (N >> nl_r);
                            nblk      <= ((N >> 1) >> (LOGN - nl_r));
                        end else begin
                            zeta_cnt  <= {{(N_LAYERS-1){1'b0}}, 1'b1};
                            layer_idx <= 3'd0;
                            len       <= 8'd128;
                            nblk      <= {{(N_LAYERS-1){1'b0}}, 1'b1};
                        end
                        block_cnt <= 8'd0;
                        j_cnt     <= 8'd0;
                        butter_ph <= 4'd0;
                        rph       <= 3'd0;
                        state     <= S_LAYER_SETUP;
                    end
                end

                // -------------------------------------------------------------
                S_LAYER_SETUP: begin
                    j_cnt     <= 8'd0;
                    butter_ph <= 4'd0;
                    state     <= S_BUTTER;
                end

                // -------------------------------------------------------------
                // 8-phase butterfly: one multiply per tick
                S_BUTTER: begin
                    case (butter_ph)
                        4'd0: begin // ADDR
                            addr_a_reg <= block_start + j_cnt;
                            addr_b_reg <= block_start + j_cnt + len;
                            zv_reg     <= zeta_rom[zeta_cnt];
                            last_butter<= (j_cnt + 8'd1 == len);
                            j_cnt      <= j_cnt + 8'd1;
                            butter_ph  <= 4'd1;
                        end
                        4'd1: begin // READ
                            pa <= coeff[addr_a_reg];
                            pb <= coeff[addr_b_reg];
                            butter_ph <= 4'd2;
                        end
                        4'd2: begin // SUB
                            xd_reg  <= pb - pa;
                            sum_reg <= pa + pb;
                            butter_ph <= 4'd3;
                        end
                        4'd3: begin // M0 (butterfly product)
                            prod_bf <= bf_m0;
                            if (inv_mode) begin
                                s_reg <= sum_reg;
                                v_a   <= bf_va;
                            end
                            butter_ph <= 4'd4;
                        end
                        4'd4: begin // M1
                            t_low     <= m1_w;
                            bar_t_reg <= (v_a + bar_add) >>> sh_r;
                            butter_ph <= 4'd5;
                        end
                        4'd5: begin // M2a1: register the multiply (DSP-bound)
                            tq_prod   <= tq_mul;
                            bar_mul_r <= bar_t_reg * q_se;
                            butter_ph <= 4'd6;
                        end
                        4'd6: begin // M2a2: register the subtract (CARRY4-bound)
                            mont_diff_r <= mont_diff;
                            butter_ph   <= 4'd7;
                        end
                        4'd7: begin // M2b: final writes
                            if (inv_mode) begin
                                coeff[addr_a_reg] <= bar_res;
                                coeff[addr_b_reg] <= mont_res;
                            end else begin
                                coeff[addr_a_reg] <= fwd_a;
                                coeff[addr_b_reg] <= fwd_b;
                            end
                            if (last_butter) begin
                                butter_ph <= 4'd0;
                                state     <= S_NEXT_BLOCK;
                            end else begin
                                butter_ph <= 4'd0;
                            end
                        end
                        default: butter_ph <= 4'd0;
                    endcase
                end

                // -------------------------------------------------------------
                S_NEXT_BLOCK: begin
                    if (inv_mode)
                        zeta_cnt <= zeta_cnt - 1'b1;
                    else
                        zeta_cnt <= zeta_cnt + 1'b1;

                    if (block_cnt + 8'd1 < nblk) begin
                        block_cnt <= block_cnt + 8'd1;
                        j_cnt     <= 8'd0;
                        butter_ph <= 4'd0;
                        state     <= S_LAYER_SETUP;
                    end else begin
                        state <= S_NEXT_LAYER;
                    end
                end

                // -------------------------------------------------------------
                S_NEXT_LAYER: begin
                    if (inv_mode) begin
                        if (layer_idx < (nl_r - 4'd1)) begin
                            layer_idx <= layer_idx + 3'd1;
                            len       <= len << 1;
                            nblk      <= nblk >> 1;
                            block_cnt <= 8'd0;
                            j_cnt     <= 8'd0;
                            butter_ph <= 4'd0;
                            state     <= S_LAYER_SETUP;
                        end else begin
                            cnt   <= 9'd0;
                            rph   <= 3'd0;
                            state <= S_SCALE;
                        end
                    end else begin
                        if (layer_idx < (nl_r - 4'd1)) begin
                            layer_idx <= layer_idx + 3'd1;
                            len       <= len >> 1;
                            nblk      <= nblk << 1;
                            block_cnt <= 8'd0;
                            j_cnt     <= 8'd0;
                            butter_ph <= 4'd0;
                            state     <= S_LAYER_SETUP;
                        end else begin
                            cnt   <= 9'd0;
                            rph   <= 3'd0;
                            state <= S_REDUCE;
                        end
                    end
                end

                // -------------------------------------------------------------
                // poly_reduce: barrett each coeff, one multiply per tick.
                S_REDUCE: begin
                    case (rph)
                        3'd0: begin
                            if (cnt < N) begin
                                rin <= coeff[cnt];
                                rph <= 3'd1;
                            end else begin
                                state <= S_DONE;
                            end
                        end
                        3'd1: begin // M1'
                            s_reg <= rin;
                            v_a   <= rd_va;
                            rph   <= 3'd2;
                        end
                        3'd2: begin // M2a
                            bar_t_reg <= (v_a + bar_add) >>> sh_r;
                            rph       <= 3'd3;
                        end
                        3'd3: begin // M2b
                            bar_mul_r <= bar_t_reg * q_se;
                            rph       <= 3'd4;
                        end
                        3'd4: begin // M2c + WRITE
                            coeff[cnt] <= bar_res;
                            if (cnt + 9'd1 < N) begin
                                cnt <= cnt + 9'd1;
                                rph <= 3'd0;
                            end else begin
                                cnt  <= cnt + 9'd1;
                                rph  <= 3'd0;
                                state <= S_DONE;
                            end
                        end
                        default: rph <= 3'd0;
                    endcase
                end

                // -------------------------------------------------------------
                // INTT final scaling: fqmul(coeff, SCALE_K), one multiply/tick
                S_SCALE: begin
                    case (rph)
                        3'd0: begin
                            if (cnt < N) begin
                                rin <= coeff[cnt];
                                rph <= 3'd1;
                            end else begin
                                state <= S_DONE;
                            end
                        end
                        3'd1: begin // M0 (scale product)
                            prod_sc <= sc_m0w;
                            rph  <= 3'd2;
                        end
                        3'd2: begin // M1
                            t_low <= m1_w;
                            rph   <= 3'd3;
                        end
                        3'd3: begin // M2a1: register t_low*Q
                            tq_prod   <= tq_mul;
                            rph       <= 3'd4;
                        end
                        3'd4: begin // M2a2: register prod - tq_prod
                            mont_diff_r <= mont_diff;
                            rph         <= 3'd5;
                        end
                        3'd5: begin // M2b + WRITE
                            coeff[cnt] <= mont_res;
                            if (cnt + 9'd1 < N) begin
                                cnt <= cnt + 9'd1;
                                rph <= 3'd0;
                            end else begin
                                cnt  <= cnt + 9'd1;
                                rph  <= 3'd0;
                                state <= S_DONE;
                            end
                        end
                        default: rph <= 3'd0;
                    endcase
                end

                // -------------------------------------------------------------
                S_DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

    assign read_data = coeff[read_addr];

endmodule

`default_nettype wire
