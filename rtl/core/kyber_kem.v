// =============================================================================
// ML-KEM-768-style KEM  (FIPS-203-shaped, FPGA prototype)
// -----------------------------------------------------------------------------
// Integrates verified primitives: kyber_sampler / kyber_ntt / kyber_poly /
// kyber_basemul / shake / keccak_perm.
//
// Parameters: k=3, eta=2, q=3329, du=10, dv=4
//
// KeyGen:  d -> G(d) -> (rho,sigma);
//   A[i][j]=NTT(CBD(SHAKE-128(rho||i||j,128)));
//   s[i]=CBD(SHAKE-256(sigma||i,128));
//   e[i]=CBD(SHAKE-256(sigma||k+i,128));
//   t[i]=sum_j A[i][j]*s_ntt[j] + e_ntt[i]  (NTT domain, mont-corrected)
// Encaps:
//   r[i]=CBD(SHAKE-256(m||i,128));
//   e1[i]=CBD(SHAKE-256(m||k+i,128));
//   e2=CBD(SHAKE-256(m||2k,128));
//   u[j]=INTT(sum_i A[i][j]*r_ntt[i]) + e1[j];
//   v=INTT(sum_i t[i]*r_ntt[i]) + e2 + encode(m);  compress u(du) v(dv)
// Decaps:
//   m' = v - INTT(sum_i s_ntt[i]*u_ntt[i]);  decode;  ss=SHAKE-256(m')
//
// basemul scaling: poly_basemul(ntt(a),ntt(b)) = ntt(a⊙b)*mont^-1.
//   KeyGen multiplies basemul result by mont (R_MOD=2285) so t[i] is true NTT.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module kyber_kem #(
    parameter K     = 3,
    parameter N     = 256,
    parameter Q     = 3329,
    parameter BW    = 16,
    parameter ETA   = 2,
    parameter DU    = 10,
    parameter DV    = 4,
    parameter R_MOD = 2285,
    parameter SEED_B = 32,
    parameter MSG_B  = 32,
    parameter SS_B   = 32
)(
    input  wire                clk,
    input  wire                rst_n,

    input  wire                start,
    input  wire                op_keygen,
    input  wire                op_encaps,
    output reg                 busy,
    output reg                 done,
    output reg                 error,

    input  wire                in_load,
    input  wire [7:0]          in_addr,
    input  wire [7:0]          in_data,

    // Ciphertext load for Decaps (independent of this instance's own Encaps)
    input  wire                ct_load,
    input  wire [15:0]         ct_in_addr,
    input  wire [15:0]         ct_data_in,

    output reg                 pk_valid,
    output reg [15:0]          pk_addr,
    output reg [BW-1:0]        pk_data,

    output reg                 ct_valid,
    output reg [15:0]          ct_addr,
    output reg [15:0]          ct_data,

    output reg                 ss_valid,
    output reg [7:0]           ss_data,

    // ---- #6a leakage probe taps (passthrough from u_ntt) --------------------
    // Expose the NTT arithmetic datapath to the top level for the TDM probe
    // router.  Pure wiring of the u_ntt probe outputs; the KEM functional
    // behaviour and its KAT golden-vector results are unchanged.
    output wire [BW-1:0]       ntt_probe_fqmul,
    output wire [BW-1:0]       ntt_probe_addsub,
    output wire [BW-1:0]       ntt_probe_ram_rd,
    output wire                ntt_probe_valid
);

    // -------------------------------------------------------------------------
    // State machine
    // -------------------------------------------------------------------------
    localparam [4:0]
        S_IDLE       = 5'd0,
        // KeyGen
        S_KG_G       = 5'd1,
        S_KG_A       = 5'd2,
        S_KG_S       = 5'd3,
        S_KG_E       = 5'd4,
        S_KG_SNTT    = 5'd5,
        S_KG_ENTT    = 5'd6,
        S_KG_T       = 5'd7,
        S_KG_DONE    = 5'd8,
        S_KG_OUTPUT  = 5'd9,
        // Encaps
        S_ENC_R      = 5'd10,
        S_ENC_E1     = 5'd11,
        S_ENC_E2     = 5'd12,
        S_ENC_RNTT   = 5'd13,
        S_ENC_U      = 5'd14,
        S_ENC_V      = 5'd15,
        S_ENC_COMP   = 5'd16,
        S_ENC_SS     = 5'd17,
        S_ENC_OUTPUT = 5'd18,
        // Decaps
        S_DEC_DECOMP = 5'd19,
        S_DEC_SNTT   = 5'd20,
        S_DEC_UNTT   = 5'd21,
        S_DEC_M      = 5'd22,
        S_DEC_DECODE = 5'd23,
        S_DEC_OUTPUT = 5'd24;

    reg [4:0] st;
    reg [3:0] phase;   // sub-phase within current state

    // -------------------------------------------------------------------------
    // Polynomial storage
    // -------------------------------------------------------------------------
    (* ram_style = "block" *)
    reg [BW-1:0] A_mat [0:K*K*N-1];
    (* ram_style = "block" *)
    reg [BW-1:0] s_poly [0:K*N-1];
    (* ram_style = "block" *)
    reg [BW-1:0] e_poly [0:K*N-1];
    (* ram_style = "block" *)
    reg [BW-1:0] t_poly [0:K*N-1];
    (* ram_style = "block" *)
    reg [BW-1:0] r_poly [0:K*N-1];
    (* ram_style = "block" *)
    reg [BW-1:0] e1_poly [0:K*N-1];
    reg [BW-1:0] e2_poly [0:N-1];
    (* ram_style = "block" *)
    reg [BW-1:0] u_poly [0:K*N-1];
    reg [BW-1:0] v_poly [0:N-1];
    reg [BW-1:0] acc [0:N-1];
    (* ram_style = "block" *)
    reg [BW-1:0] u_ntt_poly [0:K*N-1];   // Decaps: NTT(u[j])
    reg [BW-1:0] m_prime_poly[0:N-1];           // Decaps: v - INTT(s.u)
    (* ram_style = "block" *)
    reg [BW-1:0] cu_poly [0:K*N-1];   // Encaps: compress(du, u[j])
    reg [BW-1:0] cv_poly     [0:N-1];           // Encaps: compress(dv, v)
    reg [7:0]    ss_buf      [0:SS_B-1];        // shared secret
    reg [7:0]    m_prime_buf [0:MSG_B-1];       // Decaps: recovered message

    // NTT-domain copies (for basemul)
    (* ram_style = "block" *)
    reg [BW-1:0] s_ntt_poly [0:K*N-1];
    (* ram_style = "block" *)
    reg [BW-1:0] e_ntt_poly [0:K*N-1];
    (* ram_style = "block" *)
    reg [BW-1:0] r_ntt_poly [0:K*N-1];

    // -------------------------------------------------------------------------
    // Seed / message buffers
    // -------------------------------------------------------------------------
    reg [7:0] seed_buf [0:SEED_B-1];
    reg [7:0] rho_buf  [0:SEED_B-1];
    reg [7:0] sigma_buf[0:SEED_B-1];
    reg [7:0] msg_buf  [0:MSG_B-1];

    // -------------------------------------------------------------------------
    // Counters
    // -------------------------------------------------------------------------
    reg [7:0]  i_idx, j_idx;
    reg [8:0]  coeff_cnt;   // 0..255 (9 bits)
    reg [7:0]  byte_cnt;    // 0..255
    reg [7:0]  load_cnt;
    reg [15:0] out_cnt;     // output byte counter (pk/ct/ss)
    integer lc;          // coeff_cnt loop iterator (elaboration-time only)
    integer lb;          // byte_cnt  loop iterator (elaboration-time only)
    integer ll;          // load_cnt  loop iterator (elaboration-time only)

    // -------------------------------------------------------------------------
    // Sub-module handshake
    // -------------------------------------------------------------------------
    // XOF-128 — FSM-driven outputs (reg), sub-module status/data inputs (wire)
    reg         x128_st;
    reg  [15:0] x128_ml, x128_ol;
    reg         x128_we;
    reg  [15:0] x128_wa;
    reg  [7:0]  x128_wd;
    reg  [15:0] x128_ra;
    wire        x128_bs, x128_dn;
    wire [7:0]  x128_rd;

    // XOF-256
    reg         x256_st;
    reg  [15:0] x256_ml, x256_ol;
    reg         x256_we;
    reg  [15:0] x256_wa;
    reg  [7:0]  x256_wd;
    reg  [15:0] x256_ra;
    wire        x256_bs, x256_dn;
    wire [7:0]  x256_rd;

    // Sampler
    reg         samp_st;
    reg         samp_load_en;
    reg  [6:0]  samp_la;
    reg  [7:0]  samp_load_data;
    reg  [7:0]  samp_ca;
    wire        samp_bs, samp_dn;
    wire [BW-1:0] samp_cd;

    // NTT
    reg         ntt_st;
    reg         ntt_inv;
    reg         ntt_load_en;
    reg  [7:0]  ntt_la;
    reg  [BW-1:0] ntt_load_data;
    reg  [7:0]  ntt_ra;
    wire        ntt_bs, ntt_dn;
    wire [BW-1:0] ntt_rd;

    // Poly add/sub
    reg         poly_st;
    reg         poly_add;
    reg         poly_ald;
    reg  [7:0]  poly_aa;
    reg  [BW-1:0] poly_ad;
    reg         poly_bld;
    reg  [7:0]  poly_ba;
    reg  [BW-1:0] poly_bd;
    reg  [7:0]  poly_ra;
    wire        poly_bs, poly_dn;
    wire [BW-1:0] poly_rd;

    // Basemul
    reg         bm_st;
    reg         bm_a_load, bm_b_load;
    reg  [7:0]  bm_a_addr, bm_b_addr;
    reg  [BW-1:0] bm_a_data, bm_b_data;
    reg  [7:0]  bm_r_addr;
    wire        bm_bs, bm_dn;
    wire [BW-1:0] bm_r_data;

    // 4-stage accumulate pipeline staging registers (S_KG_T phase 5).
    // Splits the poly_r -> *R_MOD -> Barrett -> +acc -> Barrett -> acc path
    // (47 logic levels, -34.8 ns @ 10 ns period) into four <=2-level stages.
    reg [31:0]  sc_prod;    // stage A: bm_r_data * R_MOD
    reg [BW-1:0] sc_red;    // stage B: barrett_reduce(sc_prod)
    reg [BW-1:0] sc_sum;    // stage C: acc[k] + sc_red
    reg [BW-1:0] rd_samp;   // stage A: registered basemul result read
    reg [8:0]   stage_cnt;  // cycle counter inside the pipelined phases

    // ---------------------------------------------------------------------
    // v_poly flowing pipeline (Encaps S_ENC_V phase 4'd10).
    // v = (INTT(acc) + e2) + encode_message(m), computed as
    //   barrett_reduce( barrett_reduce(ntt_rd + e2) + (bit?1664:0) ).
    // The original single-cycle double-barrett cone was THE 100 MHz worst
    // path (39.8 ns, 46 logic levels, 29 CARRY4 + 2 DSP48E1) because each
    // barrett_reduce chains two multiplies (20159*a then t*3329).  It is
    // split here into 8 stages with at most ONE multiply per stage so every
    // stage fits the 10 ns budget (100 MHz):
    //   k   : capture ntt_rd/e2/msg-bit/idx
    //   k+1 : a1=ntt+e2 ; va1=20159*a1
    //   k+2 : t1=(va1+2^25)>>>26
    //   k+3 : r1=a1-t1*3329                    (barrett#1)
    //   k+4 : a2=r1+(bit?1664:0)               (add only)
    //   k+5 : va2=20159*a2                     (multiply only)
    //   k+6 : t2=(va2+2^25)>>>26
    //   k+7 : r2=a2-t2*3329                    (barrett#2)
    //   k+8 : v_poly[idx]=r2                   (idx=k)
    // Latency 8 cycles; throughput stays 1 coeff/cycle.
    // ---------------------------------------------------------------------
    reg [BW-1:0]  vp0_ntt;      // stage A: captured ntt_rd (INTT coeff)
    reg [BW-1:0]  vp0_e2;       // stage A: captured e2_poly[idx]
    reg [8:0]     vp0_idx;      // stage A: captured coefficient index
    reg           vp0_bit;      // stage A: captured message bit
    reg signed [31:0] vp1_a1;   // stage B: a1 = ntt+e2 (sign-extended)
    reg signed [63:0] vp1_va;   // stage B: 20159*a1
    reg [8:0]     vp1_idx;
    reg           vp1_bit;
    reg signed [31:0] vp2_a1;   // stage C (carried for the stage-D subtract)
    reg signed [31:0] vp2_t1;   // stage C: (va1+2^25)>>>26
    reg [8:0]     vp2_idx;
    reg           vp2_bit;
    reg signed [31:0] vp3_r1;   // stage D: a1-t1*3329 (barrett#1 result)
    reg [8:0]     vp3_idx;
    reg           vp3_bit;
    reg signed [31:0] vp4_a2;   // stage E: r1+(bit?1664:0) (add only)
    reg [8:0]     vp4_idx;
    reg signed [31:0] vp5_a2;   // stage F: carried a2 (for stage-H subtract)
    reg signed [63:0] vp5_va2;  // stage F: 20159*a2 (multiply only)
    reg [8:0]     vp5_idx;
    reg signed [31:0] vp6_a2;   // stage G: carried a2
    reg signed [31:0] vp6_t2;   // stage G: (va2+2^25)>>>26
    reg [8:0]     vp6_idx;
    reg signed [31:0] vp7_r2;   // stage H: a2-t2*3329 (barrett#2 result)
    reg [8:0]     vp7_idx;

    // ---------------------------------------------------------------------
    // u_poly flowing pipeline (Encaps S_ENC phase 4'd10).
    // u[j] = barrett_reduce( ntt_rd + e1[j] ), a SINGLE barrett (2 multiplies
    // + add + shift in one cycle).  That one-cycle cone became the t89h
    // pre-route worst path (23.7 ns, 29 levels, 17 CARRY4 + 1 DSP48E1).  It is
    // split here into 5 stages with at most ONE multiply per stage:
    //   k   : capture ntt_rd / e1_poly[idx] / idx
    //   k+1 : a=ntt+e1 ; va=20159*a
    //   k+2 : t=(va+2^25)>>>26
    //   k+3 : r=a-t*3329                      (barrett result)
    //   k+4 : u_poly[idx]=r                   (idx=k)
    // Latency 4 cycles; throughput stays 1 coeff/cycle.
    // ---------------------------------------------------------------------
    reg [BW-1:0]  up0_ntt;      // stage A: captured ntt_rd
    reg [BW-1:0]  up0_e1;       // stage A: captured e1_poly[idx]
    reg [9:0]     up0_idx;      // stage A: captured full write address
    reg signed [31:0] up1_a;    // stage B: a = ntt+e1 (sign-extended)
    reg signed [63:0] up1_va;   // stage B: 20159*a
    reg [9:0]     up1_idx;
    reg signed [31:0] up2_a;    // stage C (carried for the stage-D subtract)
    reg signed [31:0] up2_t;    // stage C: (va+2^25)>>>26
    reg [9:0]     up2_idx;
    reg signed [31:0] up3_r;    // stage D: a-t*3329 (barrett result)
    reg [9:0]     up3_idx;

    // -------------------------------------------------------------------------
    // t_poly write-back pipeline (KeyGen S_KG phase 7): identical structure to
    // the u_poly pipeline above.  Splits the single-cycle barrett cone
    //   t_poly[idx] = barrett_reduce(acc[idx] + e_ntt_poly[idx])
    // into 5 stages with at most ONE multiply per stage:
    //   k   : capture acc / e_ntt_poly / idx
    //   k+1 : a=acc+e_ntt ; va=20159*a
    //   k+2 : t=(va+2^25)>>>26
    //   k+3 : r=a-t*3329                      (barrett result)
    //   k+4 : t_poly[idx]=r                   (idx=k)
    // Latency 4 cycles; throughput stays 1 coeff/cycle.
    reg [BW-1:0]  tp0_acc;      // stage A: captured acc[coeff_cnt]
    reg [BW-1:0]  tp0_e;        // stage A: captured e_ntt_poly[idx]
    reg [9:0]     tp0_idx;      // stage A: captured full write address
    reg signed [31:0] tp1_a;    // stage B: a = acc+e_ntt (sign-extended)
    reg signed [63:0] tp1_va;   // stage B: 20159*a
    reg [9:0]     tp1_idx;
    reg signed [31:0] tp2_a;    // stage C (carried for the stage-D subtract)
    reg signed [31:0] tp2_t;    // stage C: (va+2^25)>>>26
    reg [9:0]     tp2_idx;
    reg signed [31:0] tp3_r;    // stage D: a-t*3329 (barrett result)
    reg [9:0]     tp3_idx;

    // a = ntt_rd + e1 as a 17-bit signed sum (sign-extended to 32-bit in
    // up1_a; the multiply uses the same signed value, matching barrett_reduce).
    wire signed [16:0] up_s1 = $signed(up0_ntt) + $signed(up0_e1);

    // a = acc + e_ntt as a 17-bit signed sum (sign-extended to 32-bit in
    // tp1_a; the multiply uses the same signed value, matching barrett_reduce).
    wire signed [16:0] tp_s1 = $signed(tp0_acc) + $signed(tp0_e);

    // -------------------------------------------------------------------------
    // m_prime_poly write-back pipeline (Decaps S_DEC phase 10): identical
    // structure to the t_poly pipeline above.  Splits the single-cycle
    // barrett cone
    //   m_prime_poly[k] = barrett_reduce(v_poly[k] - ntt_rd)
    // into 5 stages with at most ONE multiply per stage:
    //   k   : capture v_poly[k] / ntt_rd / idx ; prime ntt_ra = k+1
    //   k+1 : a=v_poly-ntt_rd ; va=20159*a
    //   k+2 : t=(va+2^25)>>>26
    //   k+3 : r=a-t*3329                      (barrett result)
    //   k+4 : m_prime_poly[idx]=r             (idx=k)
    // Latency 4 cycles; throughput stays 1 coeff/cycle.
    reg [BW-1:0]  mp0_v;        // stage A: captured v_poly[k]
    reg [BW-1:0]  mp0_ntt;      // stage A: captured ntt_rd (NTT-out for k)
    reg [9:0]     mp0_idx;      // stage A: captured write address (k)
    reg signed [31:0] mp1_a;    // stage B: a = v_poly - ntt_rd (sign-extended)
    reg signed [63:0] mp1_va;   // stage B: 20159*a
    reg [9:0]     mp1_idx;
    reg signed [31:0] mp2_a;    // stage C (carried for the stage-D subtract)
    reg signed [31:0] mp2_t;    // stage C: (va+2^25)>>>26
    reg [9:0]     mp2_idx;
    reg signed [31:0] mp3_r;    // stage D: a-t*3329 (barrett result)
    reg [9:0]     mp3_idx;

    // a = v_poly - ntt_rd as a 17-bit signed difference (sign-extended to
    // 32-bit in mp1_a; the multiply uses the same signed value, matching
    // barrett_reduce).
    wire signed [16:0] mp_s1 = $signed(mp0_v) - $signed(mp0_ntt);

    // -------------------------------------------------------------------------
    // Compress write-back pipeline (S_ENC_COMP): splits the single-cycle cone
    //   cu_poly[k] = compress_du(u_poly[k]) ; cv_poly[k] = compress_dv(v_poly[k])
    // (which chains a RAM read mux + (x<<d)+q/2 + a 22x22 -> 2-DSP multiply
    // + shift + mask) into 3 stages:
    //   k   : capture u_poly/v_poly coeff, idx, is_u ; num = (x<<d)+q/2
    //   k+1 : prod = num * 2580335                   (the 2-DSP multiply)
    //   k+2 : cu_poly[idx] = (prod>>>33)&1023  or  cv_poly[idx] = (prod>>>33)&15
    // Latency 2 cycles; throughput stays 1 coeff/cycle.
    reg signed [31:0] st1_num;  // stage 1: (x<<d) + q/2   (d=10 u / d=4 v)
    reg [9:0]   st1_idx;        // stage 1: write address (cu 0..767 / cv 0..255)
    reg         st1_isu;        // stage 1: 1=compress u (cu_poly), 0=v (cv_poly)
    reg signed [63:0] st2_prod; // stage 2: num * 2580335
    reg [9:0]   st2_idx;        // stage 2: write address
    reg         st2_isu;        // stage 2: 1=cu, 0=cv

    // -------------------------------------------------------------------------
    // Accumulate barrett split registers.  Each single-cycle barrett_reduce
    // (20159*a then t*3329, TWO multiplies) is split so at most ONE multiply
    // per stage.  The carried operand a must survive 2 stages (capture -> t ->
    // subtract) while stage 1 keeps capturing the NEXT coefficient, so each
    // carry is shifted through TWO registers (sc_X_c then sc_X_c2).  The
    // sc_prod carry survives 3 stages because the 20159*sc_prod (32-bit
    // operand) multiply is itself split into two 16-bit partials
    // (sc_plo / sc_phi) over two stages, needing a third carry register.
    reg signed [63:0] sc_plo;    // barrett(sc_prod) #1: 20159*sc_prod[15:0]
    reg signed [63:0] sc_phi;    // barrett(sc_prod) #1: 20159*sc_prod[31:16]
    reg signed [63:0] sc_va1;    // barrett(sc_prod) #1: plo + (phi<<<16)
    reg signed [31:0] sc_prod_c; // barrett(sc_prod) #1: carried prod (stage 1)
    reg signed [31:0] sc_prod_c2;// barrett(sc_prod) #1: carried prod (stage 2)
    reg signed [31:0] sc_prod_c3;// barrett(sc_prod) #1: carried prod (stage 3)
    reg signed [31:0] sc_t1;     // barrett(sc_prod) #1: (va1+2^25)>>>26
    reg signed [63:0] sc_va2;    // barrett(sc_sum) #2: 20159*sc_sum
    reg signed [31:0] sc_sum_c;  // barrett(sc_sum) #2: carried sum (stage 1)
    reg signed [31:0] sc_sum_c2; // barrett(sc_sum) #2: carried sum (stage 2)
    reg signed [31:0] sc_t2;     // barrett(sc_sum) #2: (va2+2^25)>>>26

    // -------------------------------------------------------------------------
    // NTT read-back pipeline registers.  Each "READ 256 coeffs from NTT into
    // <poly>" loop was a single-cycle cone:
    //   NTT coeff_reg -> async read mux (LUT6+MUXF7+MUXF8) -> <poly> write
    // which is route-dominated (~82%).  Register ntt_rd + the write index at
    // the loop head so the cone is cut at rn_data; the write lands 1 cycle
    // later (loop runs to 256 to drain).  rn_data/rn_idx are SHARED across
    // all 6 copy loops because only one state runs at a time.
    reg [BW-1:0] rn_data;   // captured ntt_rd
    reg [11:0]   rn_idx;    // captured write index
    reg [BW-1:0] rn_data_p;  // Plan B: pipelined rn_data (write data, +1 cyc)
    reg [11:0]   rn_idx_p;   // Plan B: pipelined rn_idx  (write index, +1 cyc)

    // -------------------------------------------------------------------------
    // Decompress pipeline registers.  S_DEC_DECOMP was a single-cycle cone:
    //   out_cnt -> cu_poly/cv_poly async RAM read -> *3329 (DSP) -> +2^d -> >>d
    //   -> u_poly/v_poly write.  Split into 3 stages so at most ONE DSP or one
    //   add/shift per stage.  dc1_* captured at stage 1; dc2_* at stage 2;
    //   write-back at stage 3.  dc_idx/dc_isu survive 2 stages so they use the
    //   two-register carry pattern (dc1 -> dc2) like the compress pipeline.
    reg [31:0]  dc1_a;      // stage 1: zero-extended cu_poly/cv_poly sample
    reg [9:0]   dc1_idx;    // stage 1: write address (u: [9:0], v: [7:0])
    reg         dc1_isu;    // stage 1: 1=u_poly, 0=v_poly
    reg [31:0]  dc2_prod;   // stage 2: dc1_a * 3329
    reg [9:0]   dc2_idx;    // stage 2: shifted write address
    reg         dc2_isu;    // stage 2: shifted is_u

    // a1 = ntt_rd + e2 as a 17-bit signed sum (sign-extended to 32-bit in
    // vp1_a1; the multiply uses the same signed value, matching barrett_reduce).
    wire signed [16:0] vp_s1 = $signed(vp0_ntt) + $signed(vp0_e2);

    // -------------------------------------------------------------------------
    // Sub-module instances
    // -------------------------------------------------------------------------
    shake #(.RATE(168), .MAX_IN(256), .MAX_OUT(128)) u_xof128 (
        .clk(clk), .rst_n(rst_n),
        .start(x128_st), .msg_len(x128_ml), .out_len(x128_ol),
        .wr_en(x128_we), .wr_addr(x128_wa), .wr_data(x128_wd),
        .rd_addr(x128_ra), .rd_data(x128_rd),
        .busy(x128_bs), .done(x128_dn)
    );

    shake #(.RATE(136), .MAX_IN(256), .MAX_OUT(128)) u_xof256 (
        .clk(clk), .rst_n(rst_n),
        .start(x256_st), .msg_len(x256_ml), .out_len(x256_ol),
        .wr_en(x256_we), .wr_addr(x256_wa), .wr_data(x256_wd),
        .rd_addr(x256_ra), .rd_data(x256_rd),
        .busy(x256_bs), .done(x256_dn)
    );

    kyber_sampler #(.N(N), .Q(Q), .BW(BW), .ETA(ETA)) u_sampler (
        .clk(clk), .rst_n(rst_n),
        .start(samp_st), .busy(samp_bs), .done(samp_dn),
        .load(samp_load_en), .load_addr(samp_la), .load_data(samp_load_data),
        .coeff_addr(samp_ca), .coeff_data(samp_cd)
    );

    kyber_ntt #(.N(N), .Q(Q), .BW(BW)) u_ntt (
        .clk(clk), .rst_n(rst_n),
        .start(ntt_st), .inverse(ntt_inv),
        .busy(ntt_bs), .done(ntt_dn),
        .load(ntt_load_en), .load_addr(ntt_la), .load_data(ntt_load_data),
        .read_addr(ntt_ra), .read_data(ntt_rd),
        .probe_fqmul(ntt_probe_fqmul),
        .probe_addsub(ntt_probe_addsub),
        .probe_ram_rd(ntt_probe_ram_rd),
        .probe_valid(ntt_probe_valid)
    );

    kyber_poly #(.N(N), .Q(Q), .BW(BW)) u_kpoly (
        .clk(clk), .rst_n(rst_n),
        .start(poly_st), .op_add(poly_add),
        .busy(poly_bs), .done(poly_dn),
        .a_load(poly_ald), .a_addr(poly_aa), .a_data(poly_ad),
        .b_load(poly_bld), .b_addr(poly_ba), .b_data(poly_bd),
        .r_addr(poly_ra), .r_data(poly_rd)
    );

    kyber_basemul #(.N(N), .Q(Q), .BW(BW)) u_basemul (
        .clk(clk), .rst_n(rst_n),
        .start(bm_st), .busy(bm_bs), .done(bm_dn),
        .a_load(bm_a_load), .a_addr(bm_a_addr), .a_data(bm_a_data),
        .b_load(bm_b_load), .b_addr(bm_b_addr), .b_data(bm_b_data),
        .r_addr(bm_r_addr), .r_data(bm_r_data)
    );

    // -------------------------------------------------------------------------
    // Arithmetic functions (local copies for use in FSM)
    // -------------------------------------------------------------------------
    function [BW-1:0] barrett_reduce;
        input [31:0] a;
        reg signed [31:0] t;
        reg signed [31:0] result;
        reg signed [63:0] v_a;
        begin
            // FIPS-203 / ref/fq.c barrett_reduce, faithful to the C reference:
            //   t      = (20159*a + (1<<25)) >>> 26
            //   result = a - t*q        (returned UNNORMALISED, i.e. in (-q, q))
            // The golden vectors store these SIGNED int16 patterns (e.g. 0xff9b
            // == -109), so the result MUST NOT be clamped into [0,q) here.
            // Clamping was the bug that left t[i] at 393/768 instead of 768/768.
            v_a    = 64'sd20159 * $signed(a);
            t      = (v_a + 64'sd33554432) >>> 26;
            result = $signed(a) - (t * 32'sd3329);
            barrett_reduce = result[BW-1:0];
        end
    endfunction

    // Floor division by q.  kem_ref.compress() uses Python `//`, which is a
    // FLOOR division even for negative numerators (C's `/` truncates toward
    // zero and would give a different compressed value).  Verilog `/` on
    // signed values truncates, so the remainder correction below restores
    // Python semantics.  The divisor (q = 3329) is always positive.
    function signed [31:0] floor_div_q;
        input signed [31:0] a;
        reg signed [63:0] prod;
        begin
            // Exact constant division by q=3329 via multiply-by-reciprocal
            // (magic number).  a is always >= 0 in the compress path
            // (a = (x<<d) + q/2, x in [0,q)); verified exact:
            //   floor(a/3329) == (a * 2580335) >>> 33   for a in [0, 3409536]
            // where 2580335 = ceil(2^33 / 3329), error 623, 623*3409536 < 2^33.
            // Replaces `a / 32'sd3329` which synthesizes a ~27-CARRY4
            // combinational divider (the t89g pre-route worst path, 31.0 ns).
            // The 64-bit product is REQUIRED: a*M reaches 8.8e12 (> 2^31), a
            // 32-bit product would silently truncate (bit-width lesson, Task 89).
            prod = a * 64'sd2580335;
            floor_div_q = prod >>> 33;
        end
    endfunction

    // compress(10, x) = ((x<<10) + q/2) // q  &  1023      (q/2 = 1664)
    function [BW-1:0] compress_du;
        input [BW-1:0] x;
        reg signed [31:0] num;
        begin
            num = ($signed(x) << 10) + 32'sd1664;
            compress_du = floor_div_q(num) & 32'sd1023;
        end
    endfunction

    // compress(4, x)  = ((x<<4)  + q/2) // q  &  15
    function [BW-1:0] compress_dv;
        input [BW-1:0] x;
        reg signed [31:0] num;
        begin
            num = ($signed(x) << 4) + 32'sd1664;
            compress_dv = floor_div_q(num) & 32'sd15;
        end
    endfunction

    // decompress(10, a) = (a*q + 2^9) >> 10
    function [BW-1:0] decompress_du;
        input [BW-1:0] a;
        reg [31:0] num;
        begin
            num = ({16'd0, a} * 32'sd3329) + 32'sd512;
            decompress_du = num >> 10;
        end
    endfunction

    // decompress(4, a)  = (a*q + 2^3) >> 4
    function [BW-1:0] decompress_dv;
        input [BW-1:0] a;
        reg [31:0] num;
        begin
            num = ({16'd0, a} * 32'sd3329) + 32'sd8;
            decompress_dv = num >> 4;
        end
    endfunction

    // Normalise an int16 pattern into [0, q) for message decoding.
    function [BW-1:0] norm_q;
        input [BW-1:0] x;
        begin
            if ($signed(x) < 0)
                norm_q = x + 16'sd3329;
            else if ($signed(x) >= 32'sd3329)
                norm_q = x - 16'sd3329;
            else
                norm_q = x;
        end
    endfunction

    // -------------------------------------------------------------------------
    // Input load: capture seed/message bytes
    // -------------------------------------------------------------------------
    // P1-b: clock-only sensitivity.  The previous async-reset branch
    // bulk-cleared these buffers with for-loops, which marked the arrays as
    // "sensitive to asynchronous reset signal" - a style Vivado will not map
    // to Block RAM (Synth 8-4767).  Nobody reads either buffer before the
    // loader writes it, so the clear was dead weight.
    always @(posedge clk) begin
        if (in_load && !busy) begin
            if (in_addr < SEED_B)
                seed_buf[in_addr] <= in_data;
            else if (in_addr < SEED_B + MSG_B)
                msg_buf[in_addr - SEED_B] <= in_data;
        end
    end

    // -------------------------------------------------------------------------
    // Main FSM
    // -------------------------------------------------------------------------
    // P1-b: clock-only sensitivity (synchronous reset).  This branch touches
    // only control registers - no array writes - yet its async-reset
    // sensitivity is what marked every polynomial array as "sensitive to
    // asynchronous reset signal" and blocked Block RAM inference.
    always @(posedge clk) begin
        if (!rst_n) begin
            st <= S_IDLE;
            busy <= 0; done <= 0; error <= 0;
            pk_valid <= 0; ct_valid <= 0; ss_valid <= 0;
i_idx <= 0; j_idx <= 0; coeff_cnt <= 0; byte_cnt <= 0;
                        load_cnt <= 0; out_cnt <= 0;
                        phase <= 0;
        end else begin
            done <= 0; error <= 0;
            pk_valid <= 0; ct_valid <= 0; ss_valid <= 0;

            // Default: deassert sub-module start signals
            x128_st <= 0; x256_st <= 0;
            samp_st <= 0; ntt_st <= 0;
            poly_st <= 0; bm_st <= 0;

            case (st)
                // ===== IDLE =====
                S_IDLE: begin
                    // P1-c: ct_load merged into the FSM always block so that
                    // cu_poly / cv_poly have only ONE write port (the FSM's
                    // own S_ENC_COMP write).  The standalone always block that
                    // used to handle ct_load created a second write port, which
                    // blocked BRAM inference (Synth 8-2914 / 8-4767).  Guarded
                    // by !busy so it cannot race the FSM's own decompress stage.
                    if (ct_load && !busy) begin
                        if (ct_in_addr[9:8] < 2'd3)
                            cu_poly[ct_in_addr[9:0]] <= ct_data_in;
                        else
                            cv_poly[ct_in_addr[7:0]] <= ct_data_in;
                    end
                    if (start) begin
                        busy <= 1;
                        i_idx <= 0; j_idx <= 0; coeff_cnt <= 0; byte_cnt <= 0;
                        phase <= 0; out_cnt <= 0;
                        if (op_keygen)      st <= S_KG_G;
                        else if (op_encaps) st <= S_ENC_R;
                        else                st <= S_DEC_DECOMP;
                    end
                end

                // =====================================================================
                // KeyGen: G(d) -> rho + sigma
                // =====================================================================
                S_KG_G: begin
                    case (phase)
                        // Phase 0: LOAD 32 seed bytes into XOF-256
                        4'd0: begin
                            if (byte_cnt < 7'd32) begin
                                x256_we <= 1;
                                x256_wa <= {8'd0, byte_cnt};
                                x256_wd <= seed_buf[byte_cnt];
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                x256_we <= 0;
                                phase <= 4'd1;
                            end
                        end
                        // Phase 1: START XOF-256 (msg_len=32, out_len=64)
                        4'd1: begin
                            x256_st <= 1;
                            x256_ml <= 16'd32;
                            x256_ol <= 16'd64;
                            byte_cnt <= 0;   // reset for the read phase
                            phase <= 4'd2;
                        end
                        // Phase 2: WAIT for XOF-256 done
                        4'd2: begin
                            if (x256_dn) begin
                                x256_ra = 16'd0;  // prime read addr for the loop below
                                phase <= 4'd3;
                            end
                        end
                        // Phase 3: READ 64 bytes -> rho[0..31], sigma[0..31]
                        4'd3: begin

                            if (byte_cnt < 7'd32)
                                rho_buf[byte_cnt] <= x256_rd;
                            else
                                sigma_buf[byte_cnt - 7'd32] <= x256_rd;
                            x256_ra = {8'd0, byte_cnt} + 16'd1;  // prime next addr
                            if (byte_cnt == 7'd63) begin
                                phase <= 4'd0;
                                byte_cnt <= 0;
                                st <= S_KG_A;
                            end else begin
                                byte_cnt <= byte_cnt + 7'd1;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // =====================================================================
                // KeyGen: A[i][j] = NTT(CBD(SHAKE-128(rho||i||j, 128)))
                // =====================================================================
                S_KG_A: begin
                    case (phase)
                        // Phase 0: LOAD rho(32)||i(1)||j(1) = 34 bytes into XOF-128
                        4'd0: begin
                            if (byte_cnt < 7'd34) begin
                                x128_we <= 1;
                                x128_wa <= {8'd0, byte_cnt};
                                if (byte_cnt < 7'd32)
                                    x128_wd <= rho_buf[byte_cnt];
                                else if (byte_cnt == 7'd32)
                                    x128_wd <= i_idx[7:0];
                                else
                                    x128_wd <= j_idx[7:0];
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                x128_we <= 0;
                                phase <= 4'd1;
                            end
                        end
                        // Phase 1: START XOF-128 (msg_len=34, out_len=128)
                        4'd1: begin
                            x128_st <= 1;
                            x128_ml <= 16'd34;
                            x128_ol <= 16'd128;
                            byte_cnt <= 0;   // reset for the read phase
                            phase <= 4'd2;
                        end
                        // Phase 2: WAIT for XOF-128 done
                        4'd2: begin
                            if (x128_dn) begin
                                x128_ra = 16'd0;  // prime read addr for the loop below
                                phase <= 4'd3;
                            end
                        end
                        // Phase 3: READ 128 bytes from XOF-128 into sampler
                        4'd3: begin
                            if (byte_cnt < 8'd128) begin
                                samp_load_en <= 1;
                                samp_la <= byte_cnt[6:0];
                                samp_load_data <= x128_rd;
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                samp_load_en <= 0;
                                phase <= 4'd4;
                            end
                            x128_ra = {8'd0, byte_cnt} + 16'd1;  // prime next addr
                        end
                        // Phase 4: START sampler
                        4'd4: begin
                            samp_st <= 1;
                            phase <= 4'd5;
                        end
                        // Phase 5: WAIT for sampler done
                        4'd5: begin
                            if (samp_dn) begin
                                samp_ca = 8'd0;  // prime read addr for the loop below
                                phase <= 4'd6;
                            end
                        end
                        // Phase 6: READ 256 coeffs from sampler into NTT
                        4'd6: begin
                            ntt_load_en <= 1;
                            ntt_la <= coeff_cnt[7:0];
                            ntt_load_data <= samp_cd;
                            samp_ca = coeff_cnt[7:0] + 8'd1;  // prime next addr

                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd7;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        // Phase 7: START NTT forward
                        // ntt_load_en is deasserted HERE, one cycle after the
                        // final load (addr 255). Clearing it inside phase 6 would
                        // schedule two non-blocking writes to ntt_load_en in the
                        // same cycle (<=1 then <=0); the latter wins and the
                        // load at address 255 is silently dropped.
                        4'd7: begin
                            ntt_load_en <= 0;
                            ntt_st <= 1;
                            ntt_inv <= 0;
                            phase <= 4'd8;
                        end
                        // Phase 8: WAIT for NTT done
                        4'd8: begin
                            if (ntt_dn) begin
                                ntt_ra = 8'd0;  // prime read addr for the loop below
                                coeff_cnt <= 0;  // reset before reading all 256 coeffs
                                phase <= 4'd9;
                            end
                        end
                        // Phase 9: READ 256 coeffs from NTT into A_mat
                        4'd9: begin
                            rn_data <= ntt_rd;
                            rn_idx  <= (i_idx*K + j_idx)*N + coeff_cnt[7:0];
                            rn_data_p <= rn_data;
                            rn_idx_p  <= rn_idx;
                            ntt_ra = coeff_cnt[7:0] + 8'd1;  // prime next addr
                            if (coeff_cnt >= 9'd2)
                                A_mat[rn_idx_p] <= rn_data_p;

                            if (coeff_cnt == 9'd257) begin
                                phase <= 4'd10;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        // Phase 10: Advance (i,j); if done -> S_KG_S
                        4'd10: begin
                            if (j_idx < K-1) begin
                                j_idx <= j_idx + 7'd1;
                            end else begin
                                j_idx <= 0;
                                if (i_idx < K-1) begin
                                    i_idx <= i_idx + 7'd1;
                                end else begin
                                    i_idx <= 0; j_idx <= 0;
                                    st <= S_KG_S;
                                end
                            end
                            // Reset counters for next (i,j)
                            byte_cnt <= 0;
                            coeff_cnt <= 0;
                            phase <= 4'd0;
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // =====================================================================
                // KeyGen: s[i] = CBD(SHAKE-256(sigma||i, 128))
                // =====================================================================
                S_KG_S: begin
                    case (phase)
                        // Phase 0: LOAD sigma(32)||i(1) = 33 bytes into XOF-256
                        4'd0: begin
                            if (byte_cnt < 7'd33) begin
                                x256_we <= 1;
                                x256_wa <= {8'd0, byte_cnt};
                                if (byte_cnt < 7'd32)
                                    x256_wd <= sigma_buf[byte_cnt];
                                else
                                    x256_wd <= i_idx[7:0];
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                x256_we <= 0;
                                phase <= 4'd1;
                            end
                        end
                        // Phase 1: START XOF-256 (msg_len=33, out_len=128)
                        4'd1: begin
                            x256_st <= 1;
                            x256_ml <= 16'd33;
                            x256_ol <= 16'd128;
                            byte_cnt <= 0;   // reset for the read phase
                            phase <= 4'd2;
                        end
                        // Phase 2: WAIT for XOF-256 done
                        4'd2: begin
                            if (x256_dn) begin
                                x256_ra = 16'd0;  // prime read addr for the loop below
                                phase <= 4'd3;
                            end
                        end
                        // Phase 3: READ 128 bytes from XOF-256 into sampler
                        4'd3: begin
                            if (byte_cnt < 8'd128) begin
                                samp_load_en <= 1;
                                samp_la <= byte_cnt[6:0];
                                samp_load_data <= x256_rd;
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                samp_load_en <= 0;
                                phase <= 4'd4;
                            end
                            x256_ra = {8'd0, byte_cnt} + 16'd1;  // prime next addr
                        end
                        // Phase 4: START sampler
                        4'd4: begin
                            samp_st <= 1;
                            phase <= 4'd5;
                        end
                        // Phase 5: WAIT for sampler done
                        4'd5: begin
                            if (samp_dn) begin
                                samp_ca = 8'd0;  // prime read addr for the loop below
                                phase <= 4'd6;
                            end
                        end
                        // Phase 6: READ 256 coeffs from sampler into s_poly[i]
                        4'd6: begin
                            s_poly[i_idx*N + coeff_cnt[7:0]] <= samp_cd;
                            samp_ca = coeff_cnt[7:0] + 8'd1;  // prime next addr
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd7;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        // Phase 7: Advance i; if done -> S_KG_E
                        4'd7: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                            end else begin
                                i_idx <= 0;
                                st <= S_KG_E;
                            end
                            byte_cnt <= 0;
                            coeff_cnt <= 0;
                            phase <= 4'd0;
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // =====================================================================
                // KeyGen: e[i] = CBD(SHAKE-256(sigma||k+i, 128))
                // =====================================================================
                S_KG_E: begin
                    case (phase)
                        // Phase 0: LOAD sigma(32)||(k+i)(1) = 33 bytes into XOF-256
                        4'd0: begin
                            if (byte_cnt < 7'd33) begin
                                x256_we <= 1;
                                x256_wa <= {8'd0, byte_cnt};
                                if (byte_cnt < 7'd32)
                                    x256_wd <= sigma_buf[byte_cnt];
                                else
                                    x256_wd <= K + i_idx;
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                x256_we <= 0;
                                phase <= 4'd1;
                            end
                        end
                        // Phase 1: START XOF-256 (msg_len=33, out_len=128)
                        4'd1: begin
                            x256_st <= 1;
                            x256_ml <= 16'd33;
                            x256_ol <= 16'd128;
                            byte_cnt <= 0;   // reset for the read phase
                            phase <= 4'd2;
                        end
                        // Phase 2: WAIT for XOF-256 done
                        4'd2: begin
                            if (x256_dn) begin
                                x256_ra = 16'd0;  // prime read addr for the loop below
                                phase <= 4'd3;
                            end
                        end
                        // Phase 3: READ 128 bytes from XOF-256 into sampler
                        4'd3: begin
                            if (byte_cnt < 8'd128) begin
                                samp_load_en <= 1;
                                samp_la <= byte_cnt[6:0];
                                samp_load_data <= x256_rd;
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                samp_load_en <= 0;
                                phase <= 4'd4;
                            end
                            x256_ra = {8'd0, byte_cnt} + 16'd1;  // prime next addr
                        end
                        // Phase 4: START sampler
                        4'd4: begin
                            samp_st <= 1;
                            phase <= 4'd5;
                        end
                        // Phase 5: WAIT for sampler done
                        4'd5: begin
                            if (samp_dn) begin
                                samp_ca = 8'd0;  // prime read addr for the loop below
                                phase <= 4'd6;
                            end
                        end
                        // Phase 6: READ 256 coeffs from sampler into e_poly[i]
                        4'd6: begin
                            e_poly[i_idx*N + coeff_cnt[7:0]] <= samp_cd;
                            samp_ca = coeff_cnt[7:0] + 8'd1;  // prime next addr
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd7;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        // Phase 7: Advance i; if done -> S_KG_SNTT
                        4'd7: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                            end else begin
                                i_idx <= 0;
                                st <= S_KG_SNTT;
                            end
                            byte_cnt <= 0;
                            coeff_cnt <= 0;
                            phase <= 4'd0;
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // =====================================================================
                // KeyGen: s_ntt[i] = NTT(s[i])
                // =====================================================================
                S_KG_SNTT: begin
                    case (phase)
                        // Phase 0: LOAD s_poly[i] into NTT (256 coeffs)
                        4'd0: begin
                            ntt_load_en <= 1;
                            ntt_la <= coeff_cnt[7:0];
                            ntt_load_data <= s_poly[i_idx*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd1;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        // Phase 1: START NTT forward
                        // ntt_load_en deasserted here, one cycle after the final
                        // load (addr 255) - see the note in S_KG_A phase 7.
                        4'd1: begin
                            ntt_load_en <= 0;
                            ntt_st <= 1;
                            ntt_inv <= 0;
                            phase <= 4'd2;
                        end
                        // Phase 2: WAIT for NTT done
                        4'd2: begin
                            if (ntt_dn) begin
                                ntt_ra = 8'd0;  // prime read addr for the loop below
                                coeff_cnt <= 0;  // reset before reading all 256 coeffs
                                phase <= 4'd3;
                            end
                        end
                        // Phase 3: READ 256 coeffs from NTT into s_ntt_poly[i]
                        4'd3: begin
                            rn_data <= ntt_rd;
                            rn_idx  <= i_idx*N + coeff_cnt[7:0];
                            rn_data_p <= rn_data;
                            rn_idx_p  <= rn_idx;
                            ntt_ra = coeff_cnt[7:0] + 8'd1;  // prime next addr
                            if (coeff_cnt >= 9'd2)
                                s_ntt_poly[rn_idx_p] <= rn_data_p;

                            if (coeff_cnt == 9'd257) begin
                                phase <= 4'd4;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        // Phase 4: Advance i; if done -> S_KG_ENTT
                        4'd4: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                            end else begin
                                i_idx <= 0;
                                st <= S_KG_ENTT;
                            end
                            coeff_cnt <= 0;
                            phase <= 4'd0;
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // =====================================================================
                // KeyGen: e_ntt[i] = NTT(e[i])
                // =====================================================================
                S_KG_ENTT: begin
                    case (phase)
                        // Phase 0: LOAD e_poly[i] into NTT (256 coeffs)
                        4'd0: begin
                            ntt_load_en <= 1;
                            ntt_la <= coeff_cnt[7:0];
                            ntt_load_data <= e_poly[i_idx*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd1;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        // Phase 1: START NTT forward
                        // ntt_load_en deasserted here, one cycle after the final
                        // load (addr 255) - see the note in S_KG_A phase 7.
                        4'd1: begin
                            ntt_load_en <= 0;
                            ntt_st <= 1;
                            ntt_inv <= 0;
                            phase <= 4'd2;
                        end
                        // Phase 2: WAIT for NTT done
                        4'd2: begin
                            if (ntt_dn) begin
                                ntt_ra = 8'd0;  // prime read addr for the loop below
                                coeff_cnt <= 0;  // reset before reading all 256 coeffs
                                phase <= 4'd3;
                            end
                        end
                        // Phase 3: READ 256 coeffs from NTT into e_ntt_poly[i]
                        4'd3: begin
                            rn_data <= ntt_rd;
                            rn_idx  <= i_idx*N + coeff_cnt[7:0];
                            rn_data_p <= rn_data;
                            rn_idx_p  <= rn_idx;
                            ntt_ra = coeff_cnt[7:0] + 8'd1;  // prime next addr
                            if (coeff_cnt >= 9'd2)
                                e_ntt_poly[rn_idx_p] <= rn_data_p;

                            if (coeff_cnt == 9'd257) begin
                                phase <= 4'd4;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        // Phase 4: Advance i; if done -> S_KG_T
                        4'd4: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                            end else begin
                                i_idx <= 0;
                                st <= S_KG_T;
                            end
                            coeff_cnt <= 0;
                            phase <= 4'd0;
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // =====================================================================
                // KeyGen: t[i] = sum_j A[i][j]*s_ntt[j]*R_MOD + e_ntt[i]
                // =====================================================================
                S_KG_T: begin
                    case (phase)
                        // Phase 0: Clear acc, set j=0
                        4'd0: begin
                            for (lc = 0; lc < N; lc = lc + 1)
                                acc[lc] <= 16'd0;
                            j_idx <= 0;
                            coeff_cnt <= 0;
                            phase <= 4'd1;
                        end
                        // Phase 1: LOAD A[i][j] into basemul (256 coeffs)
                        4'd1: begin
                            bm_a_load <= 1;
                            bm_a_addr <= coeff_cnt[7:0];
                            bm_a_data <= A_mat[(i_idx*K + j_idx)*N + coeff_cnt[7:0]];

                            if (coeff_cnt == 9'd255) begin
                                phase      <= 4'd2;
                                coeff_cnt  <= 0;   // re-arm the 0..255 load loop for phase 2
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        // Phase 2: LOAD s_ntt[j] into basemul (256 coeffs)
                        // bm_a_load is deasserted HERE, one cycle after the final
                        // A load (addr 255). Clearing it inside phase 1 would put two
                        // non-blocking writes (<=1 then <=0) on the same reg in one
                        // cycle; the last one wins and the addr-255 load is dropped.
                        4'd2: begin
                            bm_a_load <= 0;
                            bm_b_load <= 1;
                            bm_b_addr <= coeff_cnt[7:0];
                            bm_b_data <= s_ntt_poly[j_idx*N + coeff_cnt[7:0]];

                            if (coeff_cnt == 9'd255) begin
                                phase      <= 4'd3;
                                coeff_cnt  <= 0;   // re-arm for the phase-5 read loop
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        // Phase 3: START basemul
                        // bm_b_load deasserted here, one cycle after the final B
                        // load (addr 255) - see the note in phase 2 above.
                        4'd3: begin
                            bm_b_load <= 0;
                            bm_st <= 1;
                            phase <= 4'd4;
                        end
                        // Phase 4: WAIT for basemul done
                        4'd4: begin
                            if (bm_dn) begin
                                bm_r_addr = 8'd0;  // prime read addr for the loop below
                                coeff_cnt <= 0;    // re-arm the 0..255 accumulate loop
                                stage_cnt <= 9'd0; // arm the 4-stage pipeline
                                phase <= 4'd5;
                            end
                        end
                        // Phase 5: pipelined accumulate
                        //   acc[k] += barrett(barrett(bm_r[k] * R_MOD) + acc[k])
                        // with one stage per clock.  stage_cnt is the cycle
                        // counter since entering phase 5; coefficient k flows
                        //   stage A at cycle k, B at k+1, C at k+2, D at k+3.
                        // (bm_r_addr is primed one cycle ahead with blocking
                        // assignments so poly_r[k] is sampled at cycle k.)
                        4'd5: begin
                            // Flowing 8-stage pipeline: each barrett_reduce
                            // (20159*a then t*3329) is split so at most ONE
                            // multiply per stage; the 20159*sc_prod (32-bit
                            // operand) multiply is further split into two
                            // 16-bit partials.  Coefficient k flows
                            //   A(k) B1a(k+1) B1b(k+2) B2(k+3) B3(k+4)
                            //   C(k+5) D1(k+6) D2(k+7) D3(k+8).
                            // (bm_r_addr is primed one cycle ahead with blocking
                            // assignments so poly_r[k] is sampled at cycle k.)
                            // Stage A: read + scale (cycles 0..255)
                            if (stage_cnt < 9'd256) begin
                                sc_prod <= $signed(bm_r_data) * 32'sd2285;
                                if (stage_cnt < 9'd255)
                                    bm_r_addr = stage_cnt[7:0] + 8'd1;
                            end
                            // Stage B1a: Barrett#1 partial multiplies + carry (1..256)
                            if (stage_cnt >= 9'd1 && stage_cnt < 9'd257) begin
                                sc_plo  <= 64'sd20159 * $signed({16'd0, sc_prod[15:0]});
                                sc_phi  <= 64'sd20159 * $signed(sc_prod[31:16]);
                                sc_prod_c <= $signed(sc_prod);
                            end
                            // Stage B1b: Barrett#1 combine partials (2..257)
                            if (stage_cnt >= 9'd2 && stage_cnt < 9'd258) begin
                                sc_va1  <= sc_plo + (sc_phi <<< 16);
                                sc_prod_c2 <= sc_prod_c;
                            end
                            // Stage B2: Barrett#1 t + carry shift (3..258)
                            if (stage_cnt >= 9'd3 && stage_cnt < 9'd259) begin
                                sc_t1 <= (sc_va1 + 64'sd33554432) >>> 26;
                                sc_prod_c3 <= sc_prod_c2;
                            end
                            // Stage B3: Barrett#1 result (4..259)
                            if (stage_cnt >= 9'd4 && stage_cnt < 9'd260)
                                sc_red <= sc_prod_c3 - sc_t1 * 32'sd3329;
                            // Stage C: add the accumulator (5..260)
                            if (stage_cnt >= 9'd5 && stage_cnt < 9'd261)
                                sc_sum <= $signed(acc[stage_cnt - 9'd5])
                                        + $signed(sc_red);
                            // Stage D1: Barrett#2 multiply + carry (6..261)
                            if (stage_cnt >= 9'd6 && stage_cnt < 9'd262) begin
                                sc_va2  <= 64'sd20159 * $signed(sc_sum);
                                sc_sum_c <= $signed(sc_sum);
                            end
                            // Stage D2: Barrett#2 t + carry shift (7..262)
                            if (stage_cnt >= 9'd7 && stage_cnt < 9'd263) begin
                                sc_t2 <= (sc_va2 + 64'sd33554432) >>> 26;
                                sc_sum_c2 <= sc_sum_c;
                            end
                            // Stage D3: Barrett#2 result + write back (8..263)
                            if (stage_cnt >= 9'd8 && stage_cnt < 9'd264)
                                acc[stage_cnt - 9'd8] <= sc_sum_c2 - sc_t2 * 32'sd3329;

                            if (stage_cnt == 9'd263) begin
                                phase <= 4'd6;
                            end else begin
                                stage_cnt <= stage_cnt + 9'd1;
                            end
                        end
                        // Phase 6: Advance j; if j<K -> phase 1, else -> phase 7
                        4'd6: begin
                            if (j_idx < K-1) begin
                                j_idx <= j_idx + 7'd1;
                                coeff_cnt <= 0;
                                phase <= 4'd1;
                            end else begin
                                coeff_cnt <= 0;   // re-arm: phase 7 writes one coeff/cycle
                                stage_cnt <= 9'd0; // arm the 5-stage t_poly pipeline
                                phase <= 4'd7;
                            end
                        end
                        // Phase 7: ADD e_ntt[i] to acc -> t_poly[i], one
                        // coefficient per cycle.  P1-b: the previous
                        // `for (lc = 0; lc < N; ...)` wrote all 256 entries
                        // in a single cycle, i.e. 256 RAM write ports in one
                        // process, which Vivado rejects ("multiple writes via
                        // different ports in same process", Synth 8-4767).
                        // acc / e_ntt_poly are not written in this phase and
                        // t_poly[i] is not read until S_KG_OUTPUT, so the
                        // end state is identical.
                        4'd7: begin
                            // Flowing 5-stage pipeline (see the register
                            // declarations): splits the single-cycle barrett
                            // cone.  stage_cnt runs 0..259: capture coeff[k]
                            // at k (0..255), write back t_poly[k] at k+4
                            // (4..259).  acc / e_ntt_poly are combinational
                            // reads (distributed RAM), so the capture in
                            // cycle k sees coeff[k] directly.
                            // Stage A: capture (stage_cnt < 256)
                            if (stage_cnt < 9'd256) begin
                                tp0_acc <= acc[stage_cnt[7:0]];
                                tp0_e   <= e_ntt_poly[i_idx*N + stage_cnt[7:0]];
                                tp0_idx <= i_idx*N + stage_cnt[7:0];
                            end
                            // Stage B: a and 20159*a
                            tp1_a   <= tp_s1;
                            tp1_va  <= 64'sd20159 * $signed(tp_s1);
                            tp1_idx <= tp0_idx;
                            // Stage C: t
                            tp2_a   <= tp1_a;
                            tp2_t   <= (tp1_va + 64'sd33554432) >>> 26;
                            tp2_idx <= tp1_idx;
                            // Stage D: barrett result
                            tp3_r   <= tp2_a - tp2_t * 32'sd3329;
                            tp3_idx <= tp2_idx;
                            // Stage E: write back t_poly[stage_cnt-4]
                            if (stage_cnt >= 9'd4 && stage_cnt < 9'd260)
                                t_poly[tp3_idx] <= tp3_r[15:0];
                            if (stage_cnt == 9'd259) begin
                                phase <= 4'd8;
                            end else begin
                                stage_cnt <= stage_cnt + 9'd1;
                            end
                        end
                        // Phase 8: Advance i; if done -> S_KG_DONE
                        4'd8: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                                coeff_cnt <= 0;
                                phase <= 4'd0;
                            end else begin
                                st <= S_KG_DONE;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ===== KeyGen: transition to output =====
                S_KG_DONE: begin
                    out_cnt <= 0;
                    st <= S_KG_OUTPUT;
                end

                // ===== KeyGen: output pk = t[0..2] || rho =====
                S_KG_OUTPUT: begin
                    pk_valid <= 1;
                    pk_addr <= out_cnt;
                    if (out_cnt < 16'd768) begin
                        // t[0..2]: 3*256 = 768 coeffs, each 2 bytes
                        pk_data <= t_poly[out_cnt[10:8]*N + out_cnt[7:0]];
                    end else begin
                        // rho: 32 bytes
                        pk_data <= {8'd0, rho_buf[out_cnt[10:0] - 16'd768]};
                    end

                    if (out_cnt == 16'd799) begin
                        busy <= 0;
                        done <= 1;
                        // NOTE: pk_valid must stay asserted on this cycle so the
                        // consumer can latch the final byte (addr 799 = rho[31]).
                        // Clearing it here would put two non-blocking writes on
                        // pk_valid in one cycle (<=1 above, <=0 here); the last
                        // write wins and the final byte is silently lost.
                        // pk_valid is deasserted by the per-cycle default in the
                        // S_IDLE cycle that follows.
                        st <= S_IDLE;
                    end else begin
                        out_cnt <= out_cnt + 16'd1;
                    end
                end

                // =====================================================================
                // Encaps  (mirrors verify/kem_ref.py::encaps coefficient-for-
                // coefficient; this is the golden the RTL must reproduce)
                //   r[i]   = CBD(SHAKE-256(m || i,   128))
                //   e1[i]  = CBD(SHAKE-256(m || k+i, 128))
                //   e2     = CBD(SHAKE-256(m || 2k,  128))
                //   u[j]   = INTT( sum_i basemul(A[i][j], r_ntt[i]) ) + e1[j]
                //   v      = INTT( sum_i basemul(t[i],   r_ntt[i]) ) + e2 + encode(m)
                //   cu[j]  = compress(du, u[j]);   cv = compress(dv, v)
                //   ss     = SHAKE-256(m)
                //
                // A_mat / t_poly / rho_buf come from the immediately preceding
                // KeyGen run; that is the interface this prototype exposes to
                // tb_kyber_kem.v (keygen once, encaps many).
                //
                // NOTE (load-enable deassertion)  Every "load 256 coeffs then
                // start the unit" sequence deasserts the load enable in the
                // phase AFTER the final addr-255 load.  Clearing it in the same
                // cycle as the addr-255 load schedules two non-blocking writes
                // on the same reg (<=1 then <=0); the last write wins and the
                // addr-255 coefficient is silently dropped.  That is the root
                // cause of the 768->393 KeyGen regression, so the pattern is
                // replicated everywhere below.
                // =====================================================================

                // ----- r[i] = CBD(SHAKE-256(m || i, 128)) --------------------
                S_ENC_R: begin
                    case (phase)
                        4'd0: begin
                            if (byte_cnt < 7'd33) begin
                                x256_we <= 1;
                                x256_wa <= {5'd0, byte_cnt};
                                if (byte_cnt < 7'd32)
                                    x256_wd <= msg_buf[byte_cnt[4:0]];
                                else
                                    x256_wd <= i_idx[7:0];
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                x256_we <= 0;
                                phase <= 4'd1;
                            end
                        end
                        4'd1: begin
                            x256_st <= 1;
                            x256_ml <= 16'd33;
                            x256_ol <= 16'd128;
                            byte_cnt <= 0;
                            phase <= 4'd2;
                        end
                        4'd2: begin
                            if (x256_dn) begin
                                x256_ra = 16'd0;
                                phase <= 4'd3;
                            end
                        end
                        4'd3: begin
                            if (byte_cnt < 8'd128) begin
                                samp_load_en <= 1;
                                samp_la <= byte_cnt[6:0];
                                samp_load_data <= x256_rd;
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                samp_load_en <= 0;
                                phase <= 4'd4;
                            end
                            x256_ra = {5'd0, byte_cnt} + 16'd1;
                        end
                        4'd4: begin
                            samp_st <= 1;
                            phase <= 4'd5;
                        end
                        4'd5: begin
                            if (samp_dn) begin
                                samp_ca = 8'd0;
                                phase <= 4'd6;
                            end
                        end
                        4'd6: begin
                            r_poly[i_idx*N + coeff_cnt[7:0]] <= samp_cd;
                            samp_ca = coeff_cnt[7:0] + 8'd1;
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd7;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd7: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                            end else begin
                                i_idx <= 0;
                                st <= S_ENC_E1;
                            end
                            byte_cnt  <= 0;
                            coeff_cnt <= 0;
                            phase <= 4'd0;
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- e1[i] = CBD(SHAKE-256(m || k+i, 128)) ----------------
                S_ENC_E1: begin
                    case (phase)
                        4'd0: begin
                            if (byte_cnt < 7'd33) begin
                                x256_we <= 1;
                                x256_wa <= {5'd0, byte_cnt};
                                if (byte_cnt < 7'd32)
                                    x256_wd <= msg_buf[byte_cnt[4:0]];
                                else
                                    x256_wd <= K + i_idx;
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                x256_we <= 0;
                                phase <= 4'd1;
                            end
                        end
                        4'd1: begin
                            x256_st <= 1;
                            x256_ml <= 16'd33;
                            x256_ol <= 16'd128;
                            byte_cnt <= 0;
                            phase <= 4'd2;
                        end
                        4'd2: begin
                            if (x256_dn) begin
                                x256_ra = 16'd0;
                                phase <= 4'd3;
                            end
                        end
                        4'd3: begin
                            if (byte_cnt < 8'd128) begin
                                samp_load_en <= 1;
                                samp_la <= byte_cnt[6:0];
                                samp_load_data <= x256_rd;
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                samp_load_en <= 0;
                                phase <= 4'd4;
                            end
                            x256_ra = {5'd0, byte_cnt} + 16'd1;
                        end
                        4'd4: begin
                            samp_st <= 1;
                            phase <= 4'd5;
                        end
                        4'd5: begin
                            if (samp_dn) begin
                                samp_ca = 8'd0;
                                phase <= 4'd6;
                            end
                        end
                        4'd6: begin
                            e1_poly[i_idx*N + coeff_cnt[7:0]] <= samp_cd;
                            samp_ca = coeff_cnt[7:0] + 8'd1;
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd7;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd7: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                            end else begin
                                i_idx <= 0;
                                st <= S_ENC_E2;
                            end
                            byte_cnt  <= 0;
                            coeff_cnt <= 0;
                            phase <= 4'd0;
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- e2 = CBD(SHAKE-256(m || 2k, 128)) ---------------------
                S_ENC_E2: begin
                    case (phase)
                        4'd0: begin
                            if (byte_cnt < 7'd33) begin
                                x256_we <= 1;
                                x256_wa <= {5'd0, byte_cnt};
                                if (byte_cnt < 7'd32)
                                    x256_wd <= msg_buf[byte_cnt[4:0]];
                                else
                                    x256_wd <= 2 * K;
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                x256_we <= 0;
                                phase <= 4'd1;
                            end
                        end
                        4'd1: begin
                            x256_st <= 1;
                            x256_ml <= 16'd33;
                            x256_ol <= 16'd128;
                            byte_cnt <= 0;
                            phase <= 4'd2;
                        end
                        4'd2: begin
                            if (x256_dn) begin
                                x256_ra = 16'd0;
                                phase <= 4'd3;
                            end
                        end
                        4'd3: begin
                            if (byte_cnt < 8'd128) begin
                                samp_load_en <= 1;
                                samp_la <= byte_cnt[6:0];
                                samp_load_data <= x256_rd;
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                samp_load_en <= 0;
                                phase <= 4'd4;
                            end
                            x256_ra = {5'd0, byte_cnt} + 16'd1;
                        end
                        4'd4: begin
                            samp_st <= 1;
                            phase <= 4'd5;
                        end
                        4'd5: begin
                            if (samp_dn) begin
                                samp_ca = 8'd0;
                                phase <= 4'd6;
                            end
                        end
                        4'd6: begin
                            e2_poly[coeff_cnt[7:0]] <= samp_cd;
                            samp_ca = coeff_cnt[7:0] + 8'd1;
                            if (coeff_cnt == 9'd255) begin
                                coeff_cnt <= 0;
                                i_idx <= 0;
                                st <= S_ENC_RNTT;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- r_ntt[i] = NTT(r[i]) ----------------------------------
                S_ENC_RNTT: begin
                    case (phase)
                        4'd0: begin
                            ntt_load_en <= 1;
                            ntt_la <= coeff_cnt[7:0];
                            ntt_load_data <= r_poly[i_idx*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd1;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd1: begin
                            ntt_load_en <= 0;
                            ntt_st <= 1;
                            ntt_inv <= 0;
                            phase <= 4'd2;
                        end
                        4'd2: begin
                            if (ntt_dn) begin
                                ntt_ra = 8'd0;
                                coeff_cnt <= 0;
                                phase <= 4'd3;
                            end
                        end
                        4'd3: begin
                            rn_data <= ntt_rd;
                            rn_idx  <= i_idx*N + coeff_cnt[7:0];
                            rn_data_p <= rn_data;
                            rn_idx_p  <= rn_idx;
                            ntt_ra = coeff_cnt[7:0] + 8'd1;
                            if (coeff_cnt >= 9'd2)
                                r_ntt_poly[rn_idx_p] <= rn_data_p;
                            if (coeff_cnt == 9'd257) begin
                                phase <= 4'd4;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd4: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                                coeff_cnt <= 0;
                                phase <= 4'd0;
                            end else begin
                                i_idx <= 0;
                                j_idx <= 0;
                                phase <= 4'd0;
                                st <= S_ENC_U;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- u[j] = INTT( sum_i basemul(A[i][j], r_ntt[i]) ) + e1[j]
                S_ENC_U: begin
                    case (phase)
                        4'd0: begin
                            for (lc = 0; lc < N; lc = lc + 1)
                                acc[lc] <= 16'd0;
                            i_idx <= 0;
                            coeff_cnt <= 0;
                            phase <= 4'd1;
                        end
                        4'd1: begin
                            bm_a_load <= 1;
                            bm_a_addr <= coeff_cnt[7:0];
                            bm_a_data <= A_mat[(i_idx*K + j_idx)*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd2;
                                coeff_cnt <= 0;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd2: begin
                            bm_a_load <= 0;
                            bm_b_load <= 1;
                            bm_b_addr <= coeff_cnt[7:0];
                            bm_b_data <= r_ntt_poly[i_idx*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd3;
                                coeff_cnt <= 0;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd3: begin
                            bm_b_load <= 0;
                            bm_st <= 1;
                            phase <= 4'd4;
                        end
                        4'd4: begin
                            if (bm_dn) begin
                                bm_r_addr = 8'd0;
                                coeff_cnt <= 0;
                                stage_cnt <= 9'd0;
                                phase <= 4'd5;
                            end
                        end
                        // Accumulate with NO R_MOD correction - Encaps leaves the
                        // basemul result unscaled and lets INTT's final 1441
                        // scaling absorb it, exactly as kem_ref.encaps does.
                        // Phase 5 (pipelined, 3 stages): coefficient k flows
                        //   stage A at cycle k, B at k+1, C at k+2.  Splits the
                        //   poly_r -> read mux -> +acc -> Barrett -> acc path.
                        4'd5: begin
                            // Flowing 5-stage pipeline: the single-cycle
                            // barrett_reduce (20159*a then t*3329) is split so
                            // at most ONE multiply per stage.  Coefficient k
                            // flows A(k) B(k+1) C1(k+2) C2(k+3) C3(k+4).
                            // (bm_r_addr is primed one cycle ahead with blocking
                            // assignments so poly_r[k] is sampled at cycle k.)
                            // Stage A: register the combinational RAM read
                            if (stage_cnt < 9'd256) begin
                                rd_samp <= bm_r_data;
                                if (stage_cnt < 9'd255)
                                    bm_r_addr = stage_cnt[7:0] + 8'd1;
                            end
                            // Stage B: add the accumulator (1..256)
                            if (stage_cnt >= 9'd1 && stage_cnt < 9'd257)
                                sc_sum <= $signed(acc[stage_cnt - 9'd1])
                                        + $signed(rd_samp);
                            // Stage C1: Barrett multiply + carry (2..257)
                            if (stage_cnt >= 9'd2 && stage_cnt < 9'd258) begin
                                sc_va2  <= 64'sd20159 * $signed(sc_sum);
                                sc_sum_c <= $signed(sc_sum);
                            end
                            // Stage C2: Barrett t + carry shift (3..258)
                            if (stage_cnt >= 9'd3 && stage_cnt < 9'd259) begin
                                sc_t2 <= (sc_va2 + 64'sd33554432) >>> 26;
                                sc_sum_c2 <= sc_sum_c;
                            end
                            // Stage C3: Barrett result + write back (4..259)
                            if (stage_cnt >= 9'd4 && stage_cnt < 9'd260)
                                acc[stage_cnt - 9'd4] <= sc_sum_c2 - sc_t2 * 32'sd3329;

                            if (stage_cnt == 9'd259) begin
                                phase <= 4'd6;
                            end else begin
                                stage_cnt <= stage_cnt + 9'd1;
                            end
                        end
                        4'd6: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                                coeff_cnt <= 0;
                                phase <= 4'd1;
                            end else begin
                                // LAST accumulation: restart the 0..255 loop
                                // used to load acc[] into the NTT.  Without this
                                // coeff_cnt is still 255, so phase 7 loads a
                                // single coefficient (acc[255] -> ntt addr 255)
                                // and fires ntt_st immediately, leaving addr
                                // 0..254 holding the previous NTT load.  That is
                                // the Encaps u/v corruption.
                                coeff_cnt <= 0;
                                phase <= 4'd7;
                            end
                        end
                        4'd7: begin
                            ntt_load_en <= 1;
                            ntt_la <= coeff_cnt[7:0];
                            ntt_load_data <= acc[coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd8;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd8: begin
                            ntt_load_en <= 0;
                            ntt_st <= 1;
                            ntt_inv <= 1;
                            phase <= 4'd9;
                        end
                        4'd9: begin
                            if (ntt_dn) begin
                                ntt_ra = 8'd0;
                                coeff_cnt <= 0;
                                stage_cnt <= 9'd0;
                                phase <= 4'd10;
                            end
                        end
                        // u[j] = barrett_reduce(ntt_rd + e1[j]); a coefficient
                        // of e1[j] is the polynomial e1 (sampled noise), and
                        // the reduction brings (ntt_rd + e1) back into (-q, q).
                        //
                        // Flowing 5-stage pipeline (see the register
                        // declarations) splits the single-cycle barrett cone.
                        // stage_cnt runs 0..259: capture coeff[k] at k (0..255),
                        // write back u_poly[k] at k+4 (4..259).  ntt_ra is
                        // updated AFTER the capture so ntt_rd still holds
                        // coeff[stage_cnt].
                        4'd10: begin
                            // Stage A: capture (stage_cnt < 256)
                            if (stage_cnt < 9'd256) begin
                                up0_ntt <= ntt_rd;
                                up0_e1  <= e1_poly[j_idx*N + stage_cnt[7:0]];
                                up0_idx <= j_idx*N + stage_cnt[7:0];
                                ntt_ra  = stage_cnt[7:0] + 8'd1;
                            end
                            // Stage B: a and 20159*a
                            up1_a   <= up_s1;
                            up1_va  <= 64'sd20159 * $signed(up_s1);
                            up1_idx <= up0_idx;
                            // Stage C: t
                            up2_a   <= up1_a;
                            up2_t   <= (up1_va + 64'sd33554432) >>> 26;
                            up2_idx <= up1_idx;
                            // Stage D: barrett result
                            up3_r   <= up2_a - up2_t * 32'sd3329;
                            up3_idx <= up2_idx;
                            // Stage E: write back u_poly[stage_cnt-4]
                            if (stage_cnt >= 9'd4 && stage_cnt < 9'd260)
                                u_poly[up3_idx] <= up3_r[15:0];
                            if (stage_cnt == 9'd259) begin
                                phase <= 4'd11;
                            end else begin
                                stage_cnt <= stage_cnt + 9'd1;
                            end
                        end
                        4'd11: begin
                            if (j_idx < K-1) begin
                                j_idx <= j_idx + 7'd1;
                                coeff_cnt <= 0;
                                phase <= 4'd0;
                            end else begin
                                phase <= 4'd0;
                                st <= S_ENC_V;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- v = INTT( sum_i basemul(t[i], r_ntt[i]) ) + e2 + encode(m)
                S_ENC_V: begin
                    case (phase)
                        4'd0: begin
                            for (lc = 0; lc < N; lc = lc + 1)
                                acc[lc] <= 16'd0;
                            i_idx <= 0;
                            coeff_cnt <= 0;
                            phase <= 4'd1;
                        end
                        4'd1: begin
                            bm_a_load <= 1;
                            bm_a_addr <= coeff_cnt[7:0];
                            bm_a_data <= t_poly[i_idx*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd2;
                                coeff_cnt <= 0;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd2: begin
                            bm_a_load <= 0;
                            bm_b_load <= 1;
                            bm_b_addr <= coeff_cnt[7:0];
                            bm_b_data <= r_ntt_poly[i_idx*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd3;
                                coeff_cnt <= 0;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd3: begin
                            bm_b_load <= 0;
                            bm_st <= 1;
                            phase <= 4'd4;
                        end
                        4'd4: begin
                            if (bm_dn) begin
                                bm_r_addr = 8'd0;
                                coeff_cnt <= 0;
                                stage_cnt <= 9'd0;
                                phase <= 4'd5;
                            end
                        end
                        // Phase 5 (pipelined, 3 stages): coefficient k flows
                        //   stage A at cycle k, B at k+1, C at k+2.  Splits the
                        //   poly_r -> read mux -> +acc -> Barrett -> acc path.
                        4'd5: begin
                            // Flowing 5-stage pipeline: the single-cycle
                            // barrett_reduce (20159*a then t*3329) is split so
                            // at most ONE multiply per stage.  Coefficient k
                            // flows A(k) B(k+1) C1(k+2) C2(k+3) C3(k+4).
                            // (bm_r_addr is primed one cycle ahead with blocking
                            // assignments so poly_r[k] is sampled at cycle k.)
                            // Stage A: register the combinational RAM read
                            if (stage_cnt < 9'd256) begin
                                rd_samp <= bm_r_data;
                                if (stage_cnt < 9'd255)
                                    bm_r_addr = stage_cnt[7:0] + 8'd1;
                            end
                            // Stage B: add the accumulator (1..256)
                            if (stage_cnt >= 9'd1 && stage_cnt < 9'd257)
                                sc_sum <= $signed(acc[stage_cnt - 9'd1])
                                        + $signed(rd_samp);
                            // Stage C1: Barrett multiply + carry (2..257)
                            if (stage_cnt >= 9'd2 && stage_cnt < 9'd258) begin
                                sc_va2  <= 64'sd20159 * $signed(sc_sum);
                                sc_sum_c <= $signed(sc_sum);
                            end
                            // Stage C2: Barrett t + carry shift (3..258)
                            if (stage_cnt >= 9'd3 && stage_cnt < 9'd259) begin
                                sc_t2 <= (sc_va2 + 64'sd33554432) >>> 26;
                                sc_sum_c2 <= sc_sum_c;
                            end
                            // Stage C3: Barrett result + write back (4..259)
                            if (stage_cnt >= 9'd4 && stage_cnt < 9'd260)
                                acc[stage_cnt - 9'd4] <= sc_sum_c2 - sc_t2 * 32'sd3329;

                            if (stage_cnt == 9'd259) begin
                                phase <= 4'd6;
                            end else begin
                                stage_cnt <= stage_cnt + 9'd1;
                            end
                        end
                        4'd6: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                                coeff_cnt <= 0;
                                phase <= 4'd1;
                            end else begin
                                // LAST accumulation: restart the 0..255 loop used
                                // to load acc[] into the NTT.  See the note in
                                // S_ENC_U phase 6 for the failure mode.
                                coeff_cnt <= 0;
                                phase <= 4'd7;
                            end
                        end
                        4'd7: begin
                            ntt_load_en <= 1;
                            ntt_la <= coeff_cnt[7:0];
                            ntt_load_data <= acc[coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd8;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd8: begin
                            ntt_load_en <= 0;
                            ntt_st <= 1;
                            ntt_inv <= 1;
                            phase <= 4'd9;
                        end
                        4'd9: begin
                            if (ntt_dn) begin
                                ntt_ra = 8'd0;
                                stage_cnt <= 9'd0;
                                phase <= 4'd10;
                            end
                        end
                        // v = (INTT(acc) + e2) + encode_message(m); a coefficient
                        // of the encoded message is (q-1)/2 = 1664 when the bit is
                        // set, 0 otherwise.  Two barretts match poly_add(poly_add(..)).
                        //
                        // Flowing 8-stage pipeline (see the register declarations)
                        // splits the single-cycle double-barrett cone.  stage_cnt
                        // runs 0..263: capture data[k] at k (0..255), write back
                        // v_poly[k-8] at k (8..263).  ntt_ra is updated AFTER the
                        // capture so ntt_rd still holds coeff[stage_cnt].
                        4'd10: begin
                            // Stage A: capture (k < 256)
                            if (stage_cnt < 9'd256) begin
                                vp0_ntt <= ntt_rd;
                                vp0_e2  <= e2_poly[stage_cnt[7:0]];
                                vp0_idx <= stage_cnt;
                                vp0_bit <= (msg_buf[stage_cnt[7:3]] >> stage_cnt[2:0]) & 8'd1;
                                ntt_ra  = stage_cnt[7:0] + 8'd1;
                            end
                            // Stage B: a1 and 20159*a1
                            vp1_a1  <= vp_s1;
                            vp1_va  <= 64'sd20159 * $signed(vp_s1);
                            vp1_idx <= vp0_idx;
                            vp1_bit <= vp0_bit;
                            // Stage C: t1
                            vp2_a1  <= vp1_a1;
                            vp2_t1  <= (vp1_va + 64'sd33554432) >>> 26;
                            vp2_idx <= vp1_idx;
                            vp2_bit <= vp1_bit;
                            // Stage D: barrett#1 result
                            vp3_r1  <= vp2_a1 - vp2_t1 * 32'sd3329;
                            vp3_idx <= vp2_idx;
                            vp3_bit <= vp2_bit;
                            // Stage E: a2 = r1+(bit?1664:0)  (add only)
                            vp4_a2  <= vp3_r1 + (vp3_bit ? 32'sd1664 : 32'sd0);
                            vp4_idx <= vp3_idx;
                            // Stage F: va2 = 20159*a2 (multiply only) + carry a2
                            vp5_a2  <= vp4_a2;
                            vp5_va2 <= 64'sd20159 * $signed(vp4_a2);
                            vp5_idx <= vp4_idx;
                            // Stage G: t2 + carry a2
                            vp6_a2  <= vp5_a2;
                            vp6_t2  <= (vp5_va2 + 64'sd33554432) >>> 26;
                            vp6_idx <= vp5_idx;
                            // Stage H: barrett#2 result
                            vp7_r2  <= vp6_a2 - vp6_t2 * 32'sd3329;
                            vp7_idx <= vp6_idx;
                            // Stage I: write back v_poly[stage_cnt-8]
                            if (stage_cnt >= 9'd8 && stage_cnt < 9'd264)
                                v_poly[vp7_idx[7:0]] <= vp7_r2[15:0];
                            if (stage_cnt == 9'd263) begin
                                out_cnt <= 0;
                                st <= S_ENC_COMP;
                            end else begin
                                stage_cnt <= stage_cnt + 9'd1;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- cu[j] = compress(du, u[j]);  cv = compress(dv, v) -----
                // Emitted as 16-bit coefficient values (0..1023 / 0..15) rather
                // than FIPS-203 bit-packed bytes, which is what sim/kem_cu*.hex
                // and sim/kem_cv.hex store.  Bit packing is a transport concern
                // for the top level and is deliberately not mixed into this math.
                S_ENC_COMP: begin
                    // Flowing 3-stage pipeline (see register decls): splits
                    // the single-cycle compress cone.  out_cnt runs 0..1025:
                    // capture coeff[k] at k (0..1023), write back at k+2
                    // (2..1025).  out_cnt[9:0] is the flat 10-bit address into
                    // cu_poly (0..767); out_cnt[7:0] is the 8-bit address into
                    // cv_poly (0..255).  Using bit-selects lets Vivado match a
                    // clean BRAM address template.
                    // Stage 1: capture x + compute num (out_cnt 0..1023)
                    if (out_cnt < 16'd1024) begin
                        if (out_cnt < 16'd768) begin
                            st1_num <= ($signed(u_poly[out_cnt[9:0]]) << 10)
                                       + 32'sd1664;
                            st1_idx <= out_cnt[9:0];
                            st1_isu <= 1'b1;
                        end else begin
                            st1_num <= ($signed(v_poly[out_cnt[7:0]]) << 4)
                                       + 32'sd1664;
                            st1_idx <= out_cnt[7:0];
                            st1_isu <= 1'b0;
                        end
                    end
                    // Stage 2: prod = num * 2580335 (the 2-DSP multiply)
                    st2_prod <= st1_num * 64'sd2580335;
                    st2_idx  <= st1_idx;
                    st2_isu  <= st1_isu;
                    // Stage 3: write back (out_cnt 2..1025)
                    if (out_cnt >= 16'd2) begin
                        if (st2_isu)
                            cu_poly[st2_idx] <= (st2_prod >>> 33) & 32'sd1023;
                        else
                            cv_poly[st2_idx] <= (st2_prod >>> 33) & 32'sd15;
                    end
                    if (out_cnt == 16'd1025) begin
                        byte_cnt <= 0;
                        phase <= 0;
                        st <= S_ENC_SS;
                    end else begin
                        out_cnt <= out_cnt + 16'd1;
                    end
                end

                // ----- ss = SHAKE-256(m) --------------------------------------
                S_ENC_SS: begin
                    case (phase)
                        4'd0: begin
                            if (byte_cnt < 7'd32) begin
                                x256_we <= 1;
                                x256_wa <= {5'd0, byte_cnt};
                                x256_wd <= msg_buf[byte_cnt[4:0]];
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                x256_we <= 0;
                                phase <= 4'd1;
                            end
                        end
                        4'd1: begin
                            x256_st <= 1;
                            x256_ml <= 16'd32;
                            x256_ol <= 16'd32;
                            byte_cnt <= 0;
                            phase <= 4'd2;
                        end
                        4'd2: begin
                            if (x256_dn) begin
                                x256_ra = 16'd0;
                                phase <= 4'd3;
                            end
                        end
                        4'd3: begin
                            ss_buf[byte_cnt[4:0]] <= x256_rd;
                            x256_ra = {5'd0, byte_cnt} + 16'd1;
                            if (byte_cnt == 7'd31) begin
                                byte_cnt <= 0;
                                out_cnt  <= 0;
                                st <= S_ENC_OUTPUT;
                            end else begin
                                byte_cnt <= byte_cnt + 7'd1;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- Output: 1024 ct coefficient words, then 32 ss bytes ----
                S_ENC_OUTPUT: begin
                    if (out_cnt < 16'd1024) begin
                        ct_valid <= 1;
                        ct_addr  <= out_cnt;
                        if (out_cnt < 16'd768)
                            ct_data <= cu_poly[out_cnt[9:0]];
                        else
                            ct_data <= cv_poly[out_cnt[7:0]];
                        out_cnt <= out_cnt + 16'd1;
                    end else if (out_cnt < 16'd1056) begin
                        ss_valid <= 1;
                        ss_data  <= ss_buf[out_cnt - 16'd1024];
                        out_cnt  <= out_cnt + 16'd1;
                    end else begin
                        busy <= 0;
                        done <= 1;
                        // ct_valid / ss_valid stay asserted on this final cycle
                        // (cleared by the per-cycle default on the S_IDLE cycle
                        // that follows) so the consumer can latch ss[31].
                        st <= S_IDLE;
                    end
                end


                // =====================================================================
                // Decaps  (mirrors verify/kem_ref.py::decaps)
                //   u[j] = decompress(du, cu[j]);  v = decompress(dv, cv)
                //   m'   = v - INTT( sum_i basemul(s_ntt[i], u_ntt[i]) )
                //   m''  = decode(m')                      ss = SHAKE-256(m'')
                // cu_poly / cv_poly are supplied by the Encaps run; s_poly from
                // the preceding KeyGen.
                // =====================================================================

                // ----- Decompress ----------------------------------------------
                S_DEC_DECOMP: begin
                    // Flowing 3-stage pipeline (same structure as S_ENC_COMP):
                    //   stage 1 (k):   async RAM read -> dc1_a/dc1_idx/dc1_isu
                    //   stage 2 (k+1): *3329 -> dc2_prod, shift idx/isu
                    //   stage 3 (k+2): +2^(d-1) >> d -> u_poly/v_poly write
                    // Coeff k is written at out_cnt = k+2, so the write-back is
                    // guarded by out_cnt >= 2 and the loop runs to 1025 (2 extra
                    // cycles to drain).
                    // Stage 1: async RAM read + capture index/flag
                    if (out_cnt < 16'd768) begin
                        dc1_a   <= {16'd0, cu_poly[out_cnt[9:0]]};
                        dc1_idx <= out_cnt[9:0];
                        dc1_isu <= 1'b1;
                    end else begin
                        dc1_a   <= {16'd0, cv_poly[out_cnt[7:0]]};
                        dc1_idx <= out_cnt[7:0];
                        dc1_isu <= 1'b0;
                    end
                    // Stage 2: decompress multiply + shift idx/flag
                    dc2_prod <= dc1_a * 32'sd3329;
                    dc2_idx  <= dc1_idx;
                    dc2_isu  <= dc1_isu;
                    // Stage 3: add + shift + write back
                    if (out_cnt >= 16'd2) begin
                        if (dc2_isu)
                            u_poly[dc2_idx] <= (dc2_prod + 32'sd512) >> 10;
                        else
                            v_poly[dc2_idx] <= (dc2_prod + 32'sd8) >> 4;
                    end
                    if (out_cnt == 16'd1025) begin
                        i_idx <= 0;
                        // Hardening: S_DEC_SNTT phase 0 does not re-initialise
                        // coeff_cnt either.  Today it is 0 because the start
                        // pulse cleared it, but that is an accident of entry
                        // rather than a stated contract - make it explicit.
                        coeff_cnt <= 0;
                        phase <= 0;
                        st <= S_DEC_SNTT;
                    end else begin
                        out_cnt <= out_cnt + 16'd1;
                    end
                end

                // ----- s_ntt[i] = NTT(s[i]) ----------------------------------
                S_DEC_SNTT: begin
                    case (phase)
                        4'd0: begin
                            ntt_load_en <= 1;
                            ntt_la <= coeff_cnt[7:0];
                            ntt_load_data <= s_poly[i_idx*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd1;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd1: begin
                            ntt_load_en <= 0;
                            ntt_st <= 1;
                            ntt_inv <= 0;
                            phase <= 4'd2;
                        end
                        4'd2: begin
                            if (ntt_dn) begin
                                ntt_ra = 8'd0;
                                coeff_cnt <= 0;
                                phase <= 4'd3;
                            end
                        end
                        4'd3: begin
                            rn_data <= ntt_rd;
                            rn_idx  <= i_idx*N + coeff_cnt[7:0];
                            rn_data_p <= rn_data;
                            rn_idx_p  <= rn_idx;
                            ntt_ra = coeff_cnt[7:0] + 8'd1;
                            if (coeff_cnt >= 9'd2)
                                s_ntt_poly[rn_idx_p] <= rn_data_p;
                            if (coeff_cnt == 9'd257) begin
                                phase <= 4'd4;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd4: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                                coeff_cnt <= 0;
                                phase <= 4'd0;
                            end else begin
                                i_idx <= 0;
                                j_idx <= 0;
                                // S_DEC_UNTT phase 0 does NOT re-initialise
                                // coeff_cnt, so it must be cleared here.
                                // Leaving it at 255 makes the very first NTT
                                // load only coefficient 255, so u_ntt_poly[0]
                                // comes out as an NTT of stale memory.
                                coeff_cnt <= 0;
                                phase <= 4'd0;
                                st <= S_DEC_UNTT;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- u_ntt[j] = NTT(u[j]) ----------------------------------
                S_DEC_UNTT: begin
                    case (phase)
                        4'd0: begin
                            ntt_load_en <= 1;
                            ntt_la <= coeff_cnt[7:0];
                            ntt_load_data <= u_poly[j_idx*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd1;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd1: begin
                            ntt_load_en <= 0;
                            ntt_st <= 1;
                            ntt_inv <= 0;
                            phase <= 4'd2;
                        end
                        4'd2: begin
                            if (ntt_dn) begin
                                ntt_ra = 8'd0;
                                coeff_cnt <= 0;
                                phase <= 4'd3;
                            end
                        end
                        4'd3: begin
                            rn_data <= ntt_rd;
                            rn_idx  <= j_idx*N + coeff_cnt[7:0];
                            rn_data_p <= rn_data;
                            rn_idx_p  <= rn_idx;
                            ntt_ra = coeff_cnt[7:0] + 8'd1;
                            if (coeff_cnt >= 9'd2)
                                u_ntt_poly[rn_idx_p] <= rn_data_p;
                            if (coeff_cnt == 9'd257) begin
                                phase <= 4'd4;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd4: begin
                            if (j_idx < K-1) begin
                                j_idx <= j_idx + 7'd1;
                                coeff_cnt <= 0;
                                phase <= 4'd0;
                            end else begin
                                j_idx <= 0;
                                i_idx <= 0;
                                coeff_cnt <= 0;
                                phase <= 4'd0;
                                st <= S_DEC_M;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- m' = v - INTT( sum_i basemul(s_ntt[i], u_ntt[i]) ) ----
                S_DEC_M: begin
                    case (phase)
                        4'd0: begin
                            for (lc = 0; lc < N; lc = lc + 1)
                                acc[lc] <= 16'd0;
                            i_idx <= 0;
                            coeff_cnt <= 0;
                            phase <= 4'd1;
                        end
                        4'd1: begin
                            bm_a_load <= 1;
                            bm_a_addr <= coeff_cnt[7:0];
                            bm_a_data <= s_ntt_poly[i_idx*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd2;
                                coeff_cnt <= 0;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd2: begin
                            bm_a_load <= 0;
                            bm_b_load <= 1;
                            bm_b_addr <= coeff_cnt[7:0];
                            bm_b_data <= u_ntt_poly[i_idx*N + coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd3;
                                coeff_cnt <= 0;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd3: begin
                            bm_b_load <= 0;
                            bm_st <= 1;
                            phase <= 4'd4;
                        end
                        4'd4: begin
                            if (bm_dn) begin
                                bm_r_addr = 8'd0;
                                coeff_cnt <= 0;
                                stage_cnt <= 9'd0;
                                phase <= 4'd5;
                            end
                        end
                        // Phase 5 (pipelined, 3 stages): coefficient k flows
                        //   stage A at cycle k, B at k+1, C at k+2.  Splits the
                        //   poly_r -> read mux -> +acc -> Barrett -> acc path.
                        4'd5: begin
                            // Flowing 5-stage pipeline: the single-cycle
                            // barrett_reduce (20159*a then t*3329) is split so
                            // at most ONE multiply per stage.  Coefficient k
                            // flows A(k) B(k+1) C1(k+2) C2(k+3) C3(k+4).
                            // (bm_r_addr is primed one cycle ahead with blocking
                            // assignments so poly_r[k] is sampled at cycle k.)
                            // Stage A: register the combinational RAM read
                            if (stage_cnt < 9'd256) begin
                                rd_samp <= bm_r_data;
                                if (stage_cnt < 9'd255)
                                    bm_r_addr = stage_cnt[7:0] + 8'd1;
                            end
                            // Stage B: add the accumulator (1..256)
                            if (stage_cnt >= 9'd1 && stage_cnt < 9'd257)
                                sc_sum <= $signed(acc[stage_cnt - 9'd1])
                                        + $signed(rd_samp);
                            // Stage C1: Barrett multiply + carry (2..257)
                            if (stage_cnt >= 9'd2 && stage_cnt < 9'd258) begin
                                sc_va2  <= 64'sd20159 * $signed(sc_sum);
                                sc_sum_c <= $signed(sc_sum);
                            end
                            // Stage C2: Barrett t + carry shift (3..258)
                            if (stage_cnt >= 9'd3 && stage_cnt < 9'd259) begin
                                sc_t2 <= (sc_va2 + 64'sd33554432) >>> 26;
                                sc_sum_c2 <= sc_sum_c;
                            end
                            // Stage C3: Barrett result + write back (4..259)
                            if (stage_cnt >= 9'd4 && stage_cnt < 9'd260)
                                acc[stage_cnt - 9'd4] <= sc_sum_c2 - sc_t2 * 32'sd3329;

                            if (stage_cnt == 9'd259) begin
                                phase <= 4'd6;
                            end else begin
                                stage_cnt <= stage_cnt + 9'd1;
                            end
                        end
                        4'd6: begin
                            if (i_idx < K-1) begin
                                i_idx <= i_idx + 7'd1;
                                coeff_cnt <= 0;
                                phase <= 4'd1;
                            end else begin
                                // LAST accumulation: restart the 0..255 loop used
                                // to load acc[] into the NTT.  See the note in
                                // S_ENC_U phase 6 for the failure mode.
                                coeff_cnt <= 0;
                                phase <= 4'd7;
                            end
                        end
                        4'd7: begin
                            ntt_load_en <= 1;
                            ntt_la <= coeff_cnt[7:0];
                            ntt_load_data <= acc[coeff_cnt[7:0]];
                            if (coeff_cnt == 9'd255) begin
                                phase <= 4'd8;
                            end else begin
                                coeff_cnt <= coeff_cnt + 9'd1;
                            end
                        end
                        4'd8: begin
                            ntt_load_en <= 0;
                            ntt_st <= 1;
                            ntt_inv <= 1;
                            phase <= 4'd9;
                        end
                        4'd9: begin
                            if (ntt_dn) begin
                                ntt_ra = 8'd0;
                                coeff_cnt <= 0;
                                stage_cnt <= 9'd0; // arm the 5-stage m_prime pipeline
                                phase <= 4'd10;
                            end
                        end
                        4'd10: begin
                            // Flowing 5-stage pipeline (see register decls):
                            // splits the single-cycle barrett cone.  stage_cnt
                            // runs 0..259: capture coeff[k] at k (0..255),
                            // write back m_prime_poly[k] at k+4 (4..259).
                            // ntt_ra is primed one cycle ahead with a blocking
                            // assignment so ntt_rd holds NTT-out for coeff[k]
                            // at cycle k.
                            // Stage A: capture (stage_cnt < 256)
                            if (stage_cnt < 9'd256) begin
                                mp0_v   <= v_poly[stage_cnt[7:0]];
                                mp0_ntt <= ntt_rd;
                                mp0_idx <= stage_cnt[7:0];
                                ntt_ra  = stage_cnt[7:0] + 8'd1;
                            end
                            // Stage B: a and 20159*a
                            mp1_a   <= mp_s1;
                            mp1_va  <= 64'sd20159 * $signed(mp_s1);
                            mp1_idx <= mp0_idx;
                            // Stage C: t
                            mp2_a   <= mp1_a;
                            mp2_t   <= (mp1_va + 64'sd33554432) >>> 26;
                            mp2_idx <= mp1_idx;
                            // Stage D: barrett result
                            mp3_r   <= mp2_a - mp2_t * 32'sd3329;
                            mp3_idx <= mp2_idx;
                            // Stage E: write back m_prime_poly[stage_cnt-4]
                            if (stage_cnt >= 9'd4 && stage_cnt < 9'd260)
                                m_prime_poly[mp3_idx] <= mp3_r[15:0];
                            if (stage_cnt == 9'd259) begin
                                byte_cnt <= 0;
                                phase <= 4'd0;
                                st <= S_DEC_DECODE;
                            end else begin
                                stage_cnt <= stage_cnt + 9'd1;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- decode m' -> 32 bytes, then ss = SHAKE-256(m'') -------
                S_DEC_DECODE: begin
                    case (phase)
                        4'd0: begin
                            for (lb = 0; lb < MSG_B; lb = lb + 1)
                                m_prime_buf[lb] <= 8'd0;
                            byte_cnt <= 0;
                            phase <= 4'd1;
                        end
                        4'd1: begin
                            // kem_ref: xr = x mod q; bit = (xr > q/4) and (xr < 3q/4)
                            if ((norm_q(m_prime_poly[byte_cnt[7:0]]) > 16'sd832) &&
                                (norm_q(m_prime_poly[byte_cnt[7:0]]) < 16'sd2496))
                                m_prime_buf[byte_cnt[7:3]] <=
                                    m_prime_buf[byte_cnt[7:3]] | ({7'd0, 8'd1} << byte_cnt[2:0]);
                            if (byte_cnt == 8'd255) begin
                                byte_cnt <= 0;
                                phase <= 4'd2;
                            end else begin
                                byte_cnt <= byte_cnt + 8'd1;
                            end
                        end
                        4'd2: begin
                            if (byte_cnt < 7'd32) begin
                                x256_we <= 1;
                                x256_wa <= {5'd0, byte_cnt};
                                x256_wd <= m_prime_buf[byte_cnt[4:0]];
                                byte_cnt <= byte_cnt + 7'd1;
                            end else begin
                                x256_we <= 0;
                                phase <= 4'd3;
                            end
                        end
                        4'd3: begin
                            x256_st <= 1;
                            x256_ml <= 16'd32;
                            x256_ol <= 16'd32;
                            byte_cnt <= 0;
                            phase <= 4'd4;
                        end
                        4'd4: begin
                            if (x256_dn) begin
                                x256_ra = 16'd0;
                                phase <= 4'd5;
                            end
                        end
                        4'd5: begin
                            ss_buf[byte_cnt[4:0]] <= x256_rd;
                            x256_ra = {5'd0, byte_cnt} + 16'd1;
                            if (byte_cnt == 7'd31) begin
                                byte_cnt <= 0;
                                out_cnt  <= 0;
                                st <= S_DEC_OUTPUT;
                            end else begin
                                byte_cnt <= byte_cnt + 7'd1;
                            end
                        end
                        default: phase <= 4'd0;
                    endcase
                end

                // ----- Output: 32 ss bytes -----------------------------------
                S_DEC_OUTPUT: begin
                    ss_valid <= 1;
                    ss_data  <= ss_buf[out_cnt[4:0]];
                    if (out_cnt == 16'd31) begin
                        busy <= 0;
                        done <= 1;
                        st <= S_IDLE;
                    end else begin
                        out_cnt <= out_cnt + 16'd1;
                    end
                end

                default: st <= S_IDLE;
            endcase
        end
    end

endmodule

`default_nettype wire
