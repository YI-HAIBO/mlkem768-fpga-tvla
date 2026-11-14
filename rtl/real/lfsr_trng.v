// =============================================================================
// Module 3 sub-core : LFSR-based random number source
// -----------------------------------------------------------------------------
// Project : IPX-AOI-Sec
//
// Bit-exact with behavioral/m3_sidechannel.py::LfsrTrng
//
//   state  : 128-bit Galois LFSR, taps (127,6,5,4) = x^128+x^7+x^2+x+1
//   counter: 32-bit, incremented on every draw
//   output : whiten( ((state ^ entropy) & 0xFFFFFFFF
//                    ^ (state ^ entropy)[95:64]) ^ counter )
//            with a multiply-xorshift whitener
//
// Ordering matches the Python model exactly: step the LFSR, increment the
// counter, then compute the output from the NEW state and NEW counter. Any
// other ordering breaks bit-exactness against the golden vectors.
//
// Why the counter is there
// ------------------------
// Projecting a 128-bit LFSR state onto 32 bits is many-to-one, so masks
// repeat: measured 43 collisions in 20,000 draws with a plain low-window
// projection, and splicing all four windows did not fix it (the projection
// itself is the problem, not the window choice). Mixing in an incrementing
// counter makes a repeat require BOTH the LFSR window and the counter to
// coincide, which turns "usually unique" into a guaranteed property.
//
// Why not a plain LFSR
// --------------------
// An LFSR is linear: 128 observed bits predict the entire sequence, so a
// single trace taken at mask-generation time reconstructs every future mask.
// The entropy input exists to break that linearity.
//
// TIMING: why the whitener is split across two clocks
// ---------------------------------------------------
// The whitener is two 32x32 multiplies in series (x MUL1, then x MUL2). Each
// one costs a 2-deep DSP48E1 cascade plus a CARRY4 partial-product adder, so
// the pair measured 12.1 ns of logic on xc7k70tfbg484-1 - a -7.822 ns setup
// violation at the 100 MHz target.
//
// The obvious fix, registering wh1 and letting rnd_out lag one clock, is NOT
// usable here: tb_module3_sidechannel.v asserts enable and samples rnd_out on
// the very next posedge, so a lagging rnd_out fails every golden vector in
// artifacts/m3_trng.hex.
//
// Instead the FIRST multiply runs one draw AHEAD. On every clock the module
// computes wh1 for the state/counter that will be live after the NEXT edge and
// parks it in wh1_p; the current edge then only needs the second multiply to
// finish wh4. rnd_out still lands on the same edge as before, one multiply per
// clock in each path, and the visible behaviour is unchanged.
//
// PRODUCTION WARNING
// ------------------
// This is a portable stand-in, NOT a certified entropy source. A real design
// must replace it with a ring-oscillator TRNG or a vendor TRNG IP and pass
// NIST SP 800-90B. docs/09_module3_sidechannel.md section 8 lists this.
// =============================================================================
`timescale 1ns / 1ps
`default_nettype none

module lfsr_trng #(
    parameter [127:0] SEED = 128'h1
)(
    input  wire          clk,
    input  wire          rst_n,

    input  wire          reseed,        // 1-clock pulse: inject fresh entropy
    input  wire [127:0]  entropy,       // external entropy (jitter / thermal)
    input  wire          enable,        // 0 = hold (no advance, no new word)

    output reg  [31:0]   rnd_out,       // one random word per enabled clock
    output wire          health_ok,     // LFSR is neither stuck-0 nor stuck-1
    output wire [31:0]   draw_count     // how many words have been produced
);

    localparam [31:0] MUL1 = 32'h9E3779B1;
    localparam [31:0] MUL2 = 32'h85EBCA6B;

    reg [127:0] state;
    reg [127:0] ent_r;
    reg [31:0]  counter;

    assign health_ok  = (state != 128'd0) && (state != {128{1'b1}});
    assign draw_count = counter;

    // ---- LFSR advance -----------------------------------------------------
    wire        fb     = state[127] ^ state[6] ^ state[5] ^ state[4];
    wire [127:0] state_nxt = {state[126:0], fb};

    // ---- the state/counter that will be live after THIS edge --------------
    // (reseed wins over enable, exactly as the register update below does)
    wire [127:0] next_state = reseed ? (state_nxt ^ entropy)
                                     : (enable ? state_nxt : state);
    wire [31:0]  next_count = reseed ? 32'd0
                                     : (enable ? counter + 32'd1 : counter);
    wire [127:0] next_ent   = reseed ? entropy : ent_r;

    // ---- one MORE step ahead: the draw rnd_out latches on the NEXT edge ---
    // The stage-1 multiply has to finish a clock early, so it is fed the
    // values the NEXT draw will use rather than the current ones. An extra
    // LFSR step is just wiring plus a 4-input XOR, so it costs nothing here.
    wire        fb_a  = next_state[127] ^ next_state[6]
                      ^ next_state[5]   ^ next_state[4];
    wire [127:0] pre_state = {next_state[126:0], fb_a};

    // The counter needs the same two-step look-ahead, but a 32-bit increment
    // is NOT free: counter+2 put a 3-deep CARRY4 chain plus a 0.52 ns hop
    // between CARRY4 columns right in front of the DSP48 A input, 1.15 ns of
    // the -1.414 ns violation. Both candidate values are therefore kept in
    // shadow registers fed from next_count (one clock of slack, well clear of
    // the critical path), and the datapath only sees a 2:1 select that folds
    // into the XOR LUT below for free.
    reg [31:0] cnt_a1;    // next_count + 1  (counter if the next edge idles)
    reg [31:0] cnt_a2;    // next_count + 2  (counter if the next edge draws)
    wire [31:0] pre_count = reseed ? 32'd1 : (enable ? cnt_a2 : cnt_a1);

    // ---- output window: low 32 bits XOR bits [95:64] ----------------------
    // Python: ((s >> 64) ^ s) & 0xFFFFFFFF  ->  s[31:0] ^ s[95:64]
    wire [127:0] pre_mixed = pre_state ^ next_ent;
    wire [31:0]  pre_win   = pre_mixed[31:0] ^ pre_mixed[95:64];
    wire [31:0]  pre_raw   = pre_win ^ pre_count;

    // ---- stage 1 (runs one draw ahead) ------------------------------------
    // Multiply by an odd constant is a bijection on GF(2^32); the xorshifts
    // then mix the high bits down. (A cube v**3 mod 2**32 is a bijection only
    // on odd inputs, which collided about half the time.)
    wire [31:0] wh1_nxt = pre_raw * MUL1;

    reg [31:0] wh1_p;      // stage-1 result for the NEXT draw

    // ---- stage 2 (finishes the current draw) ------------------------------
    wire [31:0] wh2 = wh1_p ^ (wh1_p >> 15);
    wire [31:0] wh3 = wh2 * MUL2;
    wire [31:0] wh4 = wh3 ^ (wh3 >> 13);

    // ---- reset value for the stage-1 pipeline -----------------------------
    // Out of reset the registers hold (SEED, 0, ent=0), so the first draw
    // uses state_nxt = step(SEED) and counter 1. wh1_p must already hold that
    // product on the first enabled edge; it is a constant, so it folds away
    // at elaboration. The same "seed the pipeline for the next enabled edge"
    // trick covers reseed through next_state/next_count above.
    localparam [127:0] SEED_STEP = {SEED[126:0],
                                    SEED[127] ^ SEED[6] ^ SEED[5] ^ SEED[4]};
    localparam [31:0]  RST_WIN   = SEED_STEP[31:0] ^ SEED_STEP[95:64];
    localparam [31:0]  RST_RAW   = RST_WIN ^ 32'd1;
    localparam [31:0]  RST_WH1   = RST_RAW * MUL1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // ent_r = 0, and the core stays idle until `enable` - which also
            // matches a Python LfsrTrng(SEED) whose first rand32() is the
            // first enabled draw.
            state   <= SEED;
            ent_r   <= 128'd0;
            counter <= 32'd0;
            rnd_out <= 32'd0;
            wh1_p   <= RST_WH1;
            // counter restarts at 0, so the first draw uses count 1 and the
            // one after it 2 - the reset values of the shadow registers.
            cnt_a1  <= 32'd1;
            cnt_a2  <= 32'd2;
        end else begin
            // Shadows and stage 1 advance on every clock, enabled or not, so
            // they are always primed for the next draw. rnd_out only consumes
            // stage 2 on an enabled edge, which is what keeps the latency at
            // zero. Neither the shadow adders nor stage 1 sit on the path
            // that ends at rnd_out.
            cnt_a1 <= next_count + 32'd1;
            cnt_a2 <= next_count + 32'd2;
            wh1_p  <= wh1_nxt;

            if (reseed) begin
                // Python reseed(): step once, XOR the entropy in, zero the
                // counter. The step matters - without it the first
                // post-reseed word is one draw ahead of the model and the
                // golden vectors never match.
                state   <= state_nxt ^ entropy;
                ent_r   <= entropy;
                counter <= 32'd0;
                rnd_out <= 32'd0;
            end else if (enable) begin
                state   <= state_nxt;
                counter <= counter + 32'd1;
                rnd_out <= wh4;
            end
        end
    end

endmodule

`default_nettype wire
