// =============================================================================
// Module 1 : PUF-derived AES key
// -----------------------------------------------------------------------------
// Project : IPX-AOI-Sec  (industrial-vision FPGA IP protection suite)
// Target  : Verilog-2005, Xilinx / Altera / FudanMicro / Anlogic portable
//
// Function
//   1. accept the 256-bit raw Arbiter-PUF response (produced by the physical
//      PUF array in the target fabric; this module only consumes it),
//   2. mix it with a 32-bit context (chip_id | model_id | timestamp) and
//      derive a 128-bit AES key,
//   3. derive a 32-bit PUF fingerprint used for chip binding / forensics.
//
// Mixing function (bit-exact with behavioral/m1_puf_key.py::KDF):
//
//    s = seed
//    s ^= s << 37            (256-bit, truncated)
//    s ^= s >> 41
//    s ^= s << 89            (256-bit, truncated)
//    key = s[127:0] ^ {ctx, ctx, ctx, ctx}
//
//   fp = mix32( seed[127:96] ^ seed[95:64] ^ seed[63:32] ^ seed[31:0] ^ ctx )
//    mix32(x): x ^= x>>16; x ^= x<<8; x ^= x>>7; x ^= x<<3   (all 32-bit)
//
// Latency: kdf_start may assert at any cycle; aes_key / puf_fingerprint are
// combinational, kdf_done / key_valid pulse one cycle later.
//
// NOTE on production: the simplified linear mix above is PoC-grade and is
// bit-consistent with the Python model on purpose. The customer build replaces
// it with a SHA-256 hardware core (~500 LUT) for the FIPS 140-3 argument.
// =============================================================================
`default_nettype none

module puf_key #(
    parameter RAW_SEED_WIDTH = 256,
          seed_w = 256
) (
    input  wire                     clk,
    input  wire                     rst_n,

    // ---- physical PUF array output (combinational, stable at t=0) ----
    input  wire [seed_w-1:0]        puf_seed,
    // ---- context: chip_id | model_id | timestamp --------------------
    input  wire [31:0]              puf_context,
    input  wire                     kdf_start,   // single-cycle pulse

    // ---- derived values ---------------------------------------------
    output wire [127:0]             aes_key,
    output wire [31:0]              puf_fingerprint,
    output reg                      kdf_done,    // single-cycle pulse
    output reg                      key_valid
);

    // ------------------------------------------------------------------
    // 256-bit mixing (truncated to RAW_SEED_WIDTH)
    // ------------------------------------------------------------------
    function [seed_w-1:0] mix_seed;
        input [seed_w-1:0] a;
        reg   [seed_w-1:0] t;
        begin
            t = a;
            t = t ^ (t << 37);
            t = t ^ (t >> 41);
            t = t ^ (t << 89);
            mix_seed = t;
        end
    endfunction

    // ------------------------------------------------------------------
    // 32-bit mixing
    // ------------------------------------------------------------------
    function [31:0] mix32;
        input [31:0] a;
        reg   [31:0] t;
        begin
            t = a;
            t = t ^ (t >> 16);
            t = t ^ (t <<  8);
            t = t ^ (t >>  7);
            t = t ^ (t <<  3);
            mix32 = t;
        end
    endfunction

    // ------------------------------------------------------------------
    // Combinational outputs
    // ------------------------------------------------------------------
    wire [seed_w-1:0]  s_mix      = mix_seed(puf_seed);
    // NOTE: must be 128 bits wide. Declaring it [31:0] silently truncates the
    // four-way context repeat to a single copy, and then only the low 32 key
    // bits get the context bound (caught by the golden-vector test).
    wire [127:0]       ctx_rep    = {puf_context, puf_context,
                                     puf_context, puf_context};
    // The fingerprint folds the MIXED 256-bit value, not the raw seed:
    // folding the raw seed collapses every symmetric seed (0x..ff) to a
    // zero fingerprint, which would break chip identification.
    wire [31:0]        fp_raw     = s_mix[127:96]  ^ s_mix[95:64] ^
                                     s_mix[63:32]   ^ s_mix[31:0]  ^
                                     puf_context;

    assign aes_key         = s_mix[127:0] ^ {64'd0, ctx_rep};
    assign puf_fingerprint = mix32(fp_raw);

    // ------------------------------------------------------------------
    // kdf_done / key_valid are one cycle after kdf_start
    // ------------------------------------------------------------------
    reg start_q;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_q  <= 1'b0;
            kdf_done <= 1'b0;
            key_valid<= 1'b0;
        end else begin
            start_q  <= kdf_start;
            kdf_done <= kdf_start && !start_q;   // edge-detect pulse
            // key_valid is a LATCH, asserted on the kdf_start rising edge and
            // cleared only by a reset. docs/02 defines it as "set to 1 once
            // the KDF has finished"; M5 gates on it, so it must outlive the
            // single-cycle kdf_done strobe.
            if (kdf_start && !start_q) key_valid <= 1'b1;
        end
    end

endmodule

`default_nettype wire
