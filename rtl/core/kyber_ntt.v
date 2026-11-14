// =============================================================================
// CRYSTALS-Kyber NTT / INTT  (pq-crystals/kyber ref/ntt.c faithful RTL)
// -----------------------------------------------------------------------------
// Project  : IPX-AOI-Sec
// Ring     : Zq[X]/(X^256+1),  q = 3329
// Zeta     : 17 = primitive 512th root of unity (zeta^256 = -1 mod q)
//
// Montgomery arithmetic (R = 2^16 = 65536):
//   R mod q      = 2285   (= zetas[0], Montgomery form of 1)
//   R^{-1} mod q = 169
//   QINV         = 62209 (= -3327 signed, q^{-1} mod 2^16)
//
// Forward NTT (7 layers, Cooley-Tukey, bit-reversed output):
//   k = 1;  len = 128
//   while len >= 2:
//     for start = 0..255 step 2*len:
//       zeta = ZETAS[k];  k++
//       for j = start..start+len-1:
//         t = fqmul(zeta, a[j+len])
//         a[j+len] = a[j] - t
//         a[j]     = a[j] + t
//     len >>= 1
//   poly_reduce(a)   // barrett_reduce each coeff -> [-q/2, q/2]
//
// Inverse NTT (7 layers, Gentleman-Sande, standard-order output):
//   k = 127;  len = 2
//   while len <= 128:
//     for start = 0..255 step 2*len:
//       zeta = ZETAS[k];  k--
//       for j = start..start+len-1:
//         t = a[j]
//         a[j]   = barrett_reduce(t + a[j+len])
//         a[j+len] = a[j+len] - t
//         a[j+len] = fqmul(zeta, a[j+len])
//     len <<= 1
//   for j = 0..255:  a[j] = fqmul(a[j], 1441)
//     // 1441 = R^2 * 128^{-1} mod q
//
// Domain: poly_mul = poly_ntt -> poly_basemul_montgomery -> invntt
//   gives schoolbook(a*b) in signed representation (congruent mod q).
//   invntt(poly_ntt(f)) = f * R mod q  (round-trip adds Montgomery factor).
//
// =============================================================================
// TIMING PIPELINE (Task 58, 100 MHz closure) -- every register-to-register arc
// is kept under the 10 ns budget by breaking the two long combinational cones
// that the original single-cycle DUT put on one arc (~28.99 ns total):
//
//   (A) ADDRESS cone  (len -> block_start=block_cnt*len*2 -> 256:1 MUX)
//       ~15.33 ns of carry-chain + ~8.87 ns MUX.
//       -> block_start is produced by a DSP48E1 multiplier that registers only
//          its product, so block_start lags block_cnt by exactly one cycle --
//          which matches the single S_LAYER_SETUP cycle between a block_cnt/len
//          update and its first use.  The MUX read is isolated in its own tick.
//
//   (B) ARITHMETIC cone  (fqmul = a*b -> (a_lo*QINV) -> (t*q), three DSP48E1
//       multiplies chained; barrett = two chained multiplies).
//       -> Each butterfly is a 5-phase micro-pipeline with at most ONE
//          multiplier per tick (ADDR / READ / M0 / M1 / M2+write), so no tick
//          carries a chained multiply.  poly_reduce (S_REDUCE) and the INTT
//          scale (S_SCALE) are pipelined the same way and reuse the shared
//          intermediate registers prod / t_low / s_reg / v_a.
//
// The arithmetic functions montgomery_reduce / fqmul / barrett_reduce below are
// kept verbatim as the executable specification; the FSM reproduces their exact
// bit-level behaviour one multiply per tick (validated by the iverilog KAT).
// The external load / combinational read_data interface is UNCHANGED, so the
// KAT bench (15 golden vectors) validates this build as-is.
// =============================================================================

`timescale 1ns / 1ps
`default_nettype none

module kyber_ntt #(
    parameter N  = 256,
    parameter Q  = 3329,
    parameter BW = 16              // coefficient width (signed, int16_t)
)(
    input  wire                clk,
    input  wire                rst_n,

    input  wire                start,
    input  wire                inverse,    // 0 = forward NTT, 1 = inverse INTT
    output reg                 busy,
    output reg                 done,

    // Coefficient load interface
    input  wire                load,
    input  wire [7:0]          load_addr,
    input  wire [BW-1:0]       load_data,

    // Coefficient read interface (combinational)
    input  wire [7:0]          read_addr,
    output wire [BW-1:0]       read_data
);

    // -------------------------------------------------------------------------
    // Coefficient register file (256 x 16-bit)
    // -------------------------------------------------------------------------
    reg [BW-1:0] coeff [0:N-1];
    // read_data combinational mirror: a shadow copy of coeff[] kept in sync on
    // every write, read combinationally by the external read_data port.  The
    // main coeff[] therefore has ONLY synchronous reads (dout_a/dout_b) so
    // Vivado can infer a BRAM for it; read_data keeps the exact 0-latency
    // interface kyber_kem expects (NO kyber_kem change needed).  coeff_rd is
    // never on the timing-critical butterfly path.
    reg [BW-1:0] coeff_rd [0:255];

    // -------------------------------------------------------------------------
    // Zeta ROM accessor (portable case-based ROM for iverilog).
    // Values are the SIGNED int16_t constants from ref/ntt.c
    // (e.g. zetas[0] = -1044, NOT its +q reduction 2285). Plain int16
    // addition in the butterflies wraps mod 2^16, so the true signed
    // bit-patterns must be used for the result to match the reference.
    // -------------------------------------------------------------------------
    function [BW-1:0] get_zeta;
        input [6:0] zidx;
        begin
            case (zidx)
                7'd0:   get_zeta = 16'd64492;
                7'd1:   get_zeta = 16'd64778;
                7'd2:   get_zeta = 16'd65177;
                7'd3:   get_zeta = 16'd64019;
                7'd4:   get_zeta = 16'd1493;
                7'd5:   get_zeta = 16'd1422;
                7'd6:   get_zeta = 16'd287;
                7'd7:   get_zeta = 16'd202;
                7'd8:   get_zeta = 16'd3158;
                7'd9:   get_zeta = 16'd622;
                7'd10:  get_zeta = 16'd1577;
                7'd11:  get_zeta = 16'd182;
                7'd12:  get_zeta = 16'd962;
                7'd13:  get_zeta = 16'd2127;
                7'd14:  get_zeta = 16'd1855;
                7'd15:  get_zeta = 16'd1468;
                7'd16:  get_zeta = 16'd573;
                7'd17:  get_zeta = 16'd2004;
                7'd18:  get_zeta = 16'd264;
                7'd19:  get_zeta = 16'd383;
                7'd20:  get_zeta = 16'd2500;
                7'd21:  get_zeta = 16'd1458;
                7'd22:  get_zeta = 16'd1727;
                7'd23:  get_zeta = 16'd3199;
                7'd24:  get_zeta = 16'd2648;
                7'd25:  get_zeta = 16'd1017;
                7'd26:  get_zeta = 16'd732;
                7'd27:  get_zeta = 16'd608;
                7'd28:  get_zeta = 16'd1787;
                7'd29:  get_zeta = 16'd411;
                7'd30:  get_zeta = 16'd3124;
                7'd31:  get_zeta = 16'd1758;
                7'd32:  get_zeta = 16'd1223;
                7'd33:  get_zeta = 16'd652;
                7'd34:  get_zeta = 16'd2777;
                7'd35:  get_zeta = 16'd1015;
                7'd36:  get_zeta = 16'd2036;
                7'd37:  get_zeta = 16'd1491;
                7'd38:  get_zeta = 16'd3047;
                7'd39:  get_zeta = 16'd1785;
                7'd40:  get_zeta = 16'd516;
                7'd41:  get_zeta = 16'd3321;
                7'd42:  get_zeta = 16'd3009;
                7'd43:  get_zeta = 16'd2663;
                7'd44:  get_zeta = 16'd1711;
                7'd45:  get_zeta = 16'd2167;
                7'd46:  get_zeta = 16'd126;
                7'd47:  get_zeta = 16'd1469;
                7'd48:  get_zeta = 16'd2476;
                7'd49:  get_zeta = 16'd3239;
                7'd50:  get_zeta = 16'd3058;
                7'd51:  get_zeta = 16'd830;
                7'd52:  get_zeta = 16'd107;
                7'd53:  get_zeta = 16'd1908;
                7'd54:  get_zeta = 16'd3082;
                7'd55:  get_zeta = 16'd2378;
                7'd56:  get_zeta = 16'd2931;
                7'd57:  get_zeta = 16'd961;
                7'd58:  get_zeta = 16'd1821;
                7'd59:  get_zeta = 16'd2604;
                7'd60:  get_zeta = 16'd448;
                7'd61:  get_zeta = 16'd2264;
                7'd62:  get_zeta = 16'd677;
                7'd63:  get_zeta = 16'd2054;
                7'd64:  get_zeta = 16'd2226;
                7'd65:  get_zeta = 16'd430;
                7'd66:  get_zeta = 16'd555;
                7'd67:  get_zeta = 16'd843;
                7'd68:  get_zeta = 16'd2078;
                7'd69:  get_zeta = 16'd871;
                7'd70:  get_zeta = 16'd1550;
                7'd71:  get_zeta = 16'd105;
                7'd72:  get_zeta = 16'd422;
                7'd73:  get_zeta = 16'd587;
                7'd74:  get_zeta = 16'd177;
                7'd75:  get_zeta = 16'd3094;
                7'd76:  get_zeta = 16'd3038;
                7'd77:  get_zeta = 16'd2869;
                7'd78:  get_zeta = 16'd1574;
                7'd79:  get_zeta = 16'd1653;
                7'd80:  get_zeta = 16'd3083;
                7'd81:  get_zeta = 16'd778;
                7'd82:  get_zeta = 16'd1159;
                7'd83:  get_zeta = 16'd3182;
                7'd84:  get_zeta = 16'd2552;
                7'd85:  get_zeta = 16'd1483;
                7'd86:  get_zeta = 16'd2727;
                7'd87:  get_zeta = 16'd1119;
                7'd88:  get_zeta = 16'd1739;
                7'd89:  get_zeta = 16'd644;
                7'd90:  get_zeta = 16'd2457;
                7'd91:  get_zeta = 16'd349;
                7'd92:  get_zeta = 16'd418;
                7'd93:  get_zeta = 16'd329;
                7'd94:  get_zeta = 16'd3173;
                7'd95:  get_zeta = 16'd3254;
                7'd96:  get_zeta = 16'd817;
                7'd97:  get_zeta = 16'd1097;
                7'd98:  get_zeta = 16'd603;
                7'd99:  get_zeta = 16'd610;
                7'd100: get_zeta = 16'd1322;
                7'd101: get_zeta = 16'd2044;
                7'd102: get_zeta = 16'd1864;
                7'd103: get_zeta = 16'd384;
                7'd104: get_zeta = 16'd2114;
                7'd105: get_zeta = 16'd3193;
                7'd106: get_zeta = 16'd1218;
                7'd107: get_zeta = 16'd1994;
                7'd108: get_zeta = 16'd2455;
                7'd109: get_zeta = 16'd220;
                7'd110: get_zeta = 16'd2142;
                7'd111: get_zeta = 16'd1670;
                7'd112: get_zeta = 16'd2144;
                7'd113: get_zeta = 16'd1799;
                7'd114: get_zeta = 16'd2051;
                7'd115: get_zeta = 16'd794;
                7'd116: get_zeta = 16'd1819;
                7'd117: get_zeta = 16'd2475;
                7'd118: get_zeta = 16'd2459;
                7'd119: get_zeta = 16'd478;
                7'd120: get_zeta = 16'd3221;
                7'd121: get_zeta = 16'd3021;
                7'd122: get_zeta = 16'd996;
                7'd123: get_zeta = 16'd991;
                7'd124: get_zeta = 16'd958;
                7'd125: get_zeta = 16'd1869;
                7'd126: get_zeta = 16'd1522;
                7'd127: get_zeta = 16'd1628;
                default: get_zeta = 16'd0;
            endcase
        end
    endfunction

    // -------------------------------------------------------------------------
    // Modular arithmetic (combinational functions -- executable spec)
    // -------------------------------------------------------------------------

    // Montgomery reduction:  a -> a * R^{-1} mod q   (signed 16-bit output)
    function [BW-1:0] montgomery_reduce;
        input [31:0] a;
        reg [15:0]  t_low;
        reg [31:0]  t_signed;
        reg [31:0]  result;
        begin
            t_low    = (a[15:0] * 16'd62209) & 16'hFFFF;
            t_signed = { {16{t_low[15]}}, t_low };
            result   = ($signed(a) - (t_signed * 32'd3329)) >>> 16;
            montgomery_reduce = result[BW-1:0];
        end
    endfunction

    // fqmul: Montgomery multiplication  a * b * R^{-1} mod q
    function [BW-1:0] fqmul;
        input [BW-1:0] a;
        input [BW-1:0] b;
        reg signed [31:0] sa, sb;
        reg [31:0] prod;
        begin
            sa   = {{16{a[15]}}, a};
            sb   = {{16{b[15]}}, b};
            prod = sa * sb;
            fqmul = montgomery_reduce(prod);
        end
    endfunction

    // Barrett reduction:  a -> a mod q in [-q/2, q/2]
    function [BW-1:0] barrett_reduce;
        input [BW-1:0] a;
        reg signed [31:0] v_a;
        reg signed [31:0] t;
        reg signed [31:0] result;
        begin
            v_a    = 32'sd20159 * $signed(a);
            t      = (v_a + 32'sd33554432) >>> 26;
            result = $signed(a) - (t * 32'sd3329);
            barrett_reduce = result[BW-1:0];
        end
    endfunction

    // -------------------------------------------------------------------------
    // NTT FSM (timing-pipelined, see header)
    // -------------------------------------------------------------------------
    localparam [2:0]  S_IDLE        = 3'd0,
                      S_LAYER_SETUP = 3'd1,
                      S_BUTTER      = 3'd2,
                      S_NEXT_BLOCK  = 3'd3,
                      S_NEXT_LAYER  = 3'd4,
                      S_REDUCE      = 3'd5,   // poly_reduce (forward only)
                      S_SCALE       = 3'd6,   // INTT final scaling
                      S_DONE        = 3'd7;

    reg [2:0]  state;
    reg [2:0]  layer_idx;      // 0..6 (7 layers)
    reg [7:0]  block_cnt;      // which start block within current layer
    reg [7:0]  j_cnt;          // inner loop counter (0..len-1)
    reg [7:0]  len;            // current layer length
    reg [6:0]  nblk;           // blocks per layer = 128/len, kept incrementally
                                // (len is a power of two, so 128/len doubles on
                                //  every forward layer and halves on every
                                //  inverse layer -- avoids a variable divider,
                                //  whose ~15 ns cone sat on the j_cnt CE path)
    reg [6:0]  zeta_cnt;       // zeta ROM index (1..127 forward, 127..1 inverse)
    reg [8:0]  cnt;            // generic counter (reduce / scale), 0..256
    reg [8:0]  cnt_d;          // latched cnt for reduce/scale writeback addr
    reg        inv_mode;

    // Pipeline sub-phase counters
    reg [3:0]  butter_ph;      // 0=ADDR 1=READ 2=SUB 3=M0 4=M1 5=M2a 6=M2b
    reg [2:0]  rph;            // reduce/scale sub-phase (READ / M0 / M1 / M2a / M2b)

    // Butterfly pipeline registers
    reg [BW-1:0] pa, pb, zv_reg;            // captured operands + zeta
    reg [BW-1:0] rin;                       // captured coeff for reduce/scale
    reg [BW-1:0] xd_reg;                    // staged pb-pa (inverse operand)
    reg [BW-1:0] sum_reg;                   // staged pa+pb (barrett operand)
    reg [8:0]    addr_a_reg, addr_b_reg;    // latched read/write addresses
    reg          last_butter;               // set in ADDR when j_cnt+1 == len

    // Shared arithmetic pipeline registers (one multiply staged per tick)
    reg [31:0]       prod;      // M0 product  (zv*operand, or rin*1441)
    reg [15:0]       t_low;     // M1 = (prod[15:0] * QINV) & 0xFFFF
    reg [15:0]       s_reg;     // barrett operand  (pa+pb, or rin)
    reg signed [31:0] v_a;      // M1' = 20159 * s_reg
    reg signed [7:0]  bar_t_reg;// M2a = (v_a + 2^25) >>> 26  (barrett shift staged)
    reg signed [31:0] mont_diff_r;// M2a = prod - t_low*3329 (montgomery subtract staged)
    reg signed [31:0] bar_mul_r;  // M2b = bar_t_reg * 3329  (barrett multiply staged)

    // -------------------------------------------------------------------------
    // block_start = block_cnt * (len << 1) -> DSP48E1, product-only registered
    // so it lags block_cnt by exactly one cycle (matches the single
    // S_LAYER_SETUP cycle).  block_start < 256 for every valid pair, so [8:0].
    // -------------------------------------------------------------------------
    (* use_dsp = "yes" *) reg [31:0] bs_p;
    always @(posedge clk) begin
        bs_p <= block_cnt * {len, 1'b0};
    end
    wire [8:0] block_start = bs_p[8:0];
    // -------------------------------------------------------------------------
    // Synchronous read ports for coeff[] (TDP BRAM target).
    //   rd_addr_a : butterfly-A / reduce / scale read address
    //   rd_addr_b : butterfly-B read address
    //   dout_a/dout_b : 1-cycle-latency read data
    // The FSM captures dout_a/dout_b one phase AFTER the address is driven so
    // the BRAM synchronous-read latency is absorbed (butterfly 7 -> 9 phases).
    // -------------------------------------------------------------------------
    wire [8:0] rd_addr_a = (state == S_BUTTER) ? addr_a_reg :
                           ((state == S_REDUCE || state == S_SCALE) ? cnt :
                            (load ? {1'b0, load_addr} : 9'd0));
    wire [8:0] rd_addr_b = addr_b_reg;
    // dout_a/dout_b are the synchronous read outputs of the two BRAM ports.
    // They are assigned in the port A / port B read+write blocks near the end
    // of the module (where bar_res/mont_res/fwd_a/fwd_b are in scope).
    reg [BW-1:0] dout_a, dout_b;

    // -------------------------------------------------------------------------
    // Pipelined arithmetic wires (combinational functions of the pipeline
    // registers above).  At most one DSP48E1 multiply per guarded tick.
    //   bf_m0  : butterfly M0  = zeta * (inv ? pb-pa : pb)
    //   m1_w   : Montgomery M1 = (prod[15:0] * QINV) & 0xFFFF
    //   mont_res : Montgomery M2 tail -> fqmul result
    //   bar_res  : Barrett tail -> barrett_reduce result
    // -------------------------------------------------------------------------
    wire signed [31:0] bf_zv_e     = {{16{zv_reg[15]}}, zv_reg};
    wire signed [31:0] bf_operand  = inv_mode ? {{16{xd_reg[15]}}, xd_reg}
                                              : {{16{pb[15]}}, pb};
    wire signed [31:0] bf_m0       = bf_zv_e * bf_operand;           // M0
    wire        [15:0] m1_w        = prod[15:0] * 16'd62209;         // M1 (montgomery)

    wire signed [31:0] bf_va       = 32'sd20159 * $signed(sum_reg);  // M1' (inverse out_a)
    wire signed [31:0] rd_va       = 32'sd20159 * $signed(rin);      // M1' (poly_reduce)

    // Montgomery tail split: the 32-bit subtract (prod - t_low*3329) is
    // staged into mont_diff_r so the final tick is only a shift + 16-bit add.
    wire signed [31:0] mont_diff   = $signed(prod)
                                     - $signed({{16{t_low[15]}}, t_low}) * 32'sd3329;
    wire signed [31:0] mont_sh     = mont_diff_r >>> 16;
    wire        [15:0] mont_res    = mont_sh[15:0];                  // M2 (montgomery)

    // Barrett tail uses STAGED shift (bar_t_reg) and STAGED multiply (bar_mul_r)
    // so the final tick is only a 16-bit subtract + MUX (~2.5 ns).
    wire signed [31:0] bar_sub     = $signed(s_reg) - bar_mul_r;
    wire        [15:0] bar_res     = bar_sub[15:0];                  // M2' (barrett)

    wire        [15:0] fwd_a       = pa + mont_res;                  // forward a[j]
    wire        [15:0] fwd_b       = pa - mont_res;                  // forward a[j+len]

    // INTT scale M0 = rin * 1441
    wire signed [31:0] sc_m0w      = {{16{rin[15]}}, rin} * 32'sd1441;

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
            nblk       <= 7'd0;
            zeta_cnt   <= 7'd0;
            cnt        <= 9'd0;
            cnt_d      <= 9'd0;
            inv_mode   <= 1'b0;
            butter_ph  <= 3'd0;
            rph        <= 3'd0;
            prod       <= 32'd0;
            t_low      <= 16'd0;
            s_reg      <= 16'd0;
            v_a        <= 32'sd0;
            bar_t_reg  <= 8'sd0;
            mont_diff_r<= 32'sd0;
            bar_mul_r  <= 32'sd0;
            xd_reg     <= {BW{1'b0}};
            sum_reg    <= {BW{1'b0}};
            dout_a     <= {BW{1'b0}};
            dout_b     <= {BW{1'b0}};
            // NOTE: coeff[] is no longer reset-cleared so Vivado can infer a
            // BRAM (BRAM has no reset).  Every NTT start must be preceded by a
            // full 256-coefficient load; the KAT bench validates this.
        end else begin
            done <= 1'b0;

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
                        if (inverse) begin
                            zeta_cnt  <= 7'd127;
                            layer_idx <= 3'd0;
                            len       <= 8'd2;
                            nblk      <= 7'd64;
                        end else begin
                            zeta_cnt  <= 7'd1;
                            layer_idx <= 3'd0;
                            len       <= 8'd128;
                            nblk      <= 7'd1;
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
                // 9-phase butterfly: at most one multiply per tick, all DSP
                // inputs from registers.  coeff[] reads are SYNCHRONOUS (TDP
                // BRAM target): the address is driven in ADDR (P0), the BRAM
                // latches it in READ (P1) and the data is captured in CAP (P2).
                // The A/B writes are phase-separated (M2b/M2c) to fit a single
                // write port.  The arithmetic chain (SUB..M2a) is identical to
                // the original 7-phase butterfly, shifted by two phases.
                S_BUTTER: begin
                    case (butter_ph)
                        4'd0: begin // ADDR
                            addr_a_reg <= block_start + j_cnt;
                            addr_b_reg <= block_start + j_cnt + len;
                            zv_reg     <= get_zeta(zeta_cnt);
                            last_butter<= (j_cnt + 8'd1 == len);
                            j_cnt      <= j_cnt + 8'd1;
                            butter_ph  <= 4'd1;
                        end
                        4'd1: begin // READ (sync BRAM latency absorbed here)
                            butter_ph  <= 4'd2;
                        end
                        4'd2: begin // CAP
                            pa <= dout_a;
                            pb <= dout_b;
                            butter_ph <= 4'd3;
                        end
                        4'd3: begin // SUB: stage pb-pa and pa+pb for inverse
                            xd_reg  <= pb - pa;
                            sum_reg <= pa + pb;
                            butter_ph <= 4'd4;
                        end
                        4'd4: begin // M0  (DSP inputs all from registers)
                            prod <= bf_m0;
                            if (inv_mode) begin
                                s_reg <= sum_reg;
                                v_a   <= bf_va;
                            end
                            butter_ph <= 4'd5;
                        end
                        4'd5: begin // M1 (+ stage barrett shift for inverse)
                            t_low     <= m1_w;
                            bar_t_reg <= (v_a + 32'sd33554432) >>> 26;
                            butter_ph <= 4'd6;
                        end
                        4'd6: begin // M2a: stage montgomery subtract + barrett multiply
                            mont_diff_r <= mont_diff;
                            bar_mul_r   <= bar_t_reg * 32'sd3329;
                            butter_ph   <= 4'd7;
                        end
                        4'd7: begin // M2b: write A (handled by dp_wen comb)
                            butter_ph <= 4'd8;
                        end
                        4'd8: begin // M2c: write B (handled by dp_wen comb)
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
                        zeta_cnt <= zeta_cnt - 7'd1;
                    else
                        zeta_cnt <= zeta_cnt + 7'd1;

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
                        if (layer_idx < 3'd6) begin
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
                        if (layer_idx < 3'd6) begin
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
                                cnt_d <= cnt;           // latch addr for writeback
                                rph <= 3'd1;
                            end else begin
                                rph  <= 3'd0;
                                state <= S_DONE;
                            end
                        end
                        3'd1: begin // CAP (sync read: dout_a = coeff[cnt_d])
                            rin <= dout_a;
                            rph <= 3'd2;
                        end
                        3'd2: begin // M1'
                            s_reg <= rin;
                            v_a   <= rd_va;
                            rph   <= 3'd3;
                        end
                        3'd3: begin // M2a  (stage the +2^25 >> 26 shift)
                            bar_t_reg <= (v_a + 32'sd33554432) >>> 26;
                            rph       <= 3'd4;
                        end
                        3'd4: begin // M2b  (stage bar_t_reg * 3329)
                            bar_mul_r <= bar_t_reg * 32'sd3329;
                            rph       <= 3'd5;
                        end
                        3'd5: begin // M2c (writeback handled by dp_wen)
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
                // INTT final scaling: fqmul(coeff, 1441), one multiply per tick.
                S_SCALE: begin
                    case (rph)
                        3'd0: begin
                            if (cnt < N) begin
                                cnt_d <= cnt;
                                rph <= 3'd1;
                            end else begin
                                rph  <= 3'd0;
                                state <= S_DONE;
                            end
                        end
                        3'd1: begin // CAP
                            rin <= dout_a;
                            rph <= 3'd2;
                        end
                        3'd2: begin // M0
                            prod <= sc_m0w;
                            rph  <= 3'd3;
                        end
                        3'd3: begin // M1
                            t_low <= m1_w;
                            rph   <= 3'd4;
                        end
                        3'd4: begin // M2a: stage montgomery subtract
                            mont_diff_r <= mont_diff;
                            rph <= 3'd5;
                        end
                        3'd5: begin // M2b (writeback handled by dp_wen)
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

    // -------------------------------------------------------------------------
    // coeff[] dual-port BRAM (TDP template: each port reads+WRITES in one
    // always block, sharing ONE address signal -- Vivado's supported form):
    //   Port A : addr = rd_addr_a (butterfly-A / reduce / scale / load),
    //            read -> dout_a, write on butterfly P7 / reduce rph5 /
    //            scale rph5 / load.  rd_addr_a and the write address coincide
    //            at every write phase (P7: addr_a_reg; rph5: cnt==cnt_d;
    //            load: load_addr), so ONE address serves both.
    //   Port B : addr = addr_b_reg (butterfly-B), read -> dout_b,
    //            write on butterfly P8 (addr_b_reg).
    // coeff_rd is a SEPARATE shadow array (own always block) so Vivado never
    // merges it with coeff[] -- if merged, the async read_data would block the
    // BRAM inference.  It mirrors every coeff[] write for the combinational
    // read_data port (0 added latency, NO kyber_kem change).
    // -------------------------------------------------------------------------
    wire portA_we = (state == S_BUTTER && butter_ph == 4'd7) ||
                    (state == S_REDUCE && rph == 3'd5) ||
                    (state == S_SCALE  && rph == 3'd5) ||
                    load;
    wire [BW-1:0] portA_wdata = load ? load_data
                              : (state == S_BUTTER) ? (inv_mode ? bar_res : fwd_a)
                              : (state == S_REDUCE) ? bar_res : mont_res;
    wire portB_we = (state == S_BUTTER && butter_ph == 4'd8);
    wire [BW-1:0] portB_wdata = inv_mode ? mont_res : fwd_b;
    always @(posedge clk) begin
        if (portA_we) coeff[rd_addr_a] <= portA_wdata;
        else          dout_a       <= coeff[rd_addr_a];
        if (portB_we) coeff[addr_b_reg] <= portB_wdata;
        else          dout_b        <= coeff[addr_b_reg];
    end
    always @(posedge clk) begin
        if (portA_we)      coeff_rd[rd_addr_a]  <= portA_wdata;
        else if (portB_we) coeff_rd[addr_b_reg] <= portB_wdata;
    end

    // -------------------------------------------------------------------------
    // read_data combinational mirror (coeff_rd declared above next to coeff).
    // coeff[] itself has ONLY synchronous reads (dout_a/dout_b), so Vivado can
    // infer a BRAM for it.  The external read_data port is served by this
    // shadow copy, updated on every coeff[] write and read combinationally.
    // -------------------------------------------------------------------------
    assign read_data = coeff_rd[read_addr];

endmodule

`default_nettype wire
