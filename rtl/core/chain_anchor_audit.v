// =============================================================================
// C1 — 区块链锚定推理审计 (chain-anchor audit trail)
// =============================================================================
// Every inference committed to the chip produces an audit record:
//
//   H_i = Hash( H_{i-1} || model_id || in_digest || out || seq_i )
//
// H_i chains into H_{i-1}, so deleting, reordering or editing any stored
// record breaks the chain.  A second, independent chain L accumulates H_i:
//
//   L_0 = Perm(IV),   L_i = Perm( L_{i-1} ^ H_i )
//
// L_n is the "on-chain root": one 256-bit commitment published per epoch to
// a blockchain or tamper-evident log, while the full record trail stays
// on-chip.  C_VERIFY replays every stored record, recomputes both chains,
// and compares against the stored root — the analogue of a light client
// checking an SPV proof.
//
// Threat model (stated honestly):
//   * catches  after-the-fact tampering with audit RAM (any flip in a stored
//      record breaks H or L and is caught by C_VERIFY)
//   * catches  record deletion (the H chain skips a link)
//   * catches  replay of an old record (stored seq must equal the record
//      index)
//   * does NOT catch an attacker who controls the chip at append time and
//      simply omits a record, or appends a fabricated-but-well-formed one.
//      That needs a real consensus anchor plus heartbeat absence detection
//      — system layer, out of scope here.
//
// Hash: custom 256-bit sponge, 12 rounds, GF(2^8) byte mixing.  NOT a
// standard primitive; it exists so the chain is bit-exact verifiable against
// a Python golden model at prototype speed.  Production replaces the
// permutation core with Keccak (already proven in the shake module); the
// chain logic above it is hash-agnostic.
//
// Record layout, 96 bytes per record:
//   [0..31]   H_prev    (32B)   chain link from the previous record
//   [32..35]  model_id  (4B)
//   [36..51]  in_digest (16B)
//   [52..59]  out       (8B)
//   [60..63]  seq       (4B, little-endian)
//   [64..95]  H_cur     (32B)
// Hash input = bytes [0..63] (two 32-byte absorb blocks), output = H_cur.
// =============================================================================

module chain_anchor_audit #(
    parameter MAX_REC = 32             // records held in the on-chip trail
)(
    input  wire        clk,
    input  wire        rst_n,

    input  wire        cmd_valid,
    input  wire [3:0]  cmd,
    output reg         busy,
    output reg         done,
    output reg         error,          // illegal command (sticky)

    // single-port byte-wide record RAM
    input  wire        wr_valid,
    input  wire [11:0] wr_addr,        // < 0xF00: record RAM
    input  wire [7:0]  wr_data,
    input  wire        rd_valid,
    input  wire [11:0] rd_addr,        // < 0xF00: RAM, >= 0xF00: register map
    output wire [7:0]  rd_data,

    output reg  [15:0] seq_count,      // records committed
    output reg         audit_fail,     // C_VERIFY mismatch (sticky)
    output wire [7:0]  root_byte       // L byte 0 (full root via reg map)
);

    localparam [3:0]
        C_RESET  = 4'h0,   // initialise chains, seq = 0
        C_APPEND = 4'h1,   // commit record seq_count (fields pre-loaded in RAM)
        C_ROOT   = 4'h2,   // pulse done, root readable via reg map
        C_VERIFY = 4'h3;   // replay the trail, compare both chains

    localparam [7:0] REC_BYTES = 8'd96;
    localparam [11:0] RAM_SIZE = MAX_REC * 96;

    // field offsets (bytes within a record)
    localparam [7:0]
        O_HP  = 8'd0,    // H_prev  32
        O_MID = 8'd32,   // model_id 4
        O_IN  = 8'd36,   // in_digest 16
        O_OUT = 8'd52,   // out 8
        O_SEQ = 8'd60,   // seq 4
        O_HC  = 8'd64;   // H_cur 32

    // register map at 0xF00
    localparam [11:0]
        R_ROOT  = 12'hF00,   // L[0..31]  (32 bytes)
        R_SEQ   = 12'hF20,   // seq_count low byte
        R_STAT  = 12'hF21,   // {6'b0, audit_fail, dirty}
        R_LASTH = 12'hF28;   // last H[0..31]

    // FSM --------------------------------------------------------------------
    localparam [3:0]
        S_IDLE  = 4'd0,
        S_PREP  = 4'd1,   // append: write H_prev + seq into the record
        S_ABS   = 4'd2,   // absorb 32-byte block into st
        S_PERM  = 4'd3,   // 12 permutation rounds
        S_STORE = 4'd4,   // write H_cur, then start link update
        S_VCMP  = 4'd5,   // verify: compare recomputed H, check seq
        S_VFIN  = 4'd6,   // verify: compare accumulated link to stored L
        S_V0    = 4'd7,   // verify empty trail: compare L0 to L
        S_PDONE = 4'd8;   // capture the 12th permutation round's result

    // perm return targets
    localparam [2:0]
        PR_ABS2  = 3'd0,   // continue absorbing block 2
        PR_STORE = 3'd1,   // append: store H_cur
        PR_LINK  = 3'd2,   // append: finish link update
        PR_VL0   = 3'd3,   // verify: L0 computed
        PR_VCMP  = 3'd4,   // verify: record H computed
        PR_VLINK = 3'd5;   // verify: record link accumulated

    reg [3:0]  st_f;
    reg [2:0]  perm_ret;
    reg        verifying;     // 1 while C_VERIFY replays the trail
    reg [8:0]  bidx;          // byte index within the current absorb stream
    reg [5:0]  rnd;           // permutation round counter
    reg [5:0]  vrec;          // verify record loop counter
    reg        vmatch;

    reg [7:0] st  [0:31];     // sponge state
    reg [7:0] link[0:31];     // L chain (root)
    reg [7:0] last_h[0:31];   // H of the most recent committed record
    reg [7:0] lv  [0:31];     // L chain as recomputed by C_VERIFY

    // IV (record 0's H_prev, and the L0 pre-image)
    localparam [7:0] IV0=8'h67, IV1=8'h09, IV2=8'he6, IV3=8'h67,
                     IV4=8'h85, IV5=8'hae, IV6=8'h67, IV7=8'hbb,
                     IV8=8'h72, IV9=8'hf3, IV10=8'h6e, IV11=8'h3c,
                     IV12=8'h3a, IV13=8'hf5, IV14=8'h4f, IV15=8'ha5,
                     IV16=8'h27, IV17=8'h0e, IV18=8'h51, IV19=8'h7f,
                     IV20=8'h8c, IV21=8'h68, IV22=8'h05, IV23=8'h9b,
                     IV24=8'hab, IV25=8'hd9, IV26=8'h83, IV27=8'h1f,
                     IV28=8'h19, IV29=8'hcd, IV30=8'he0, IV31=8'h5b;

    // record RAM --------------------------------------------------------------
    reg [7:0] ram [0:3071];
    // internal synchronous write port (blocking selects + NBA write)
    reg       rw_we;
    reg [11:0] rw_addr;
    reg [7:0]  rw_wdata;

    wire [11:0] cur_base = verifying ? (vrec * 12'd96)
                                     : (seq_count * 12'd96);

    // ---- combinational read mux ---------------------------------------------
    reg [7:0] rd_mux;
    always @(*) begin
        if (rd_addr >= R_ROOT && rd_addr < R_ROOT + 12'd32)
            rd_mux = link[rd_addr[4:0]];
        else if (rd_addr >= R_LASTH && rd_addr < R_LASTH + 12'd32)
            rd_mux = last_h[rd_addr[4:0]];
        else if (rd_addr == R_SEQ)
            rd_mux = seq_count[7:0];
        else if (rd_addr == R_STAT)
            rd_mux = {6'b0, audit_fail, dirty_reg};
        else
            rd_mux = ram[rd_addr[11:0]];
    end
    assign rd_data   = rd_mux;
    assign root_byte = link[0];

    reg dirty_reg;

    // ---- GF(2^8) multiplier, reduction 0x11B --------------------------------
    function [7:0] gf256;
        input [7:0] a, b;
        reg [7:0] acc, ai;
        integer j;
        begin
            acc = 8'd0;
            ai  = a;
            for (j = 0; j < 8; j = j + 1) begin
                if (b[j]) acc = acc ^ ai;
                if (ai[7]) ai = (ai << 1) ^ 8'h1B;
                else       ai = ai << 1;
            end
            gf256 = acc;
        end
    endfunction

    // ---- one permutation round, applied to st -------------------------------
    // st'[i] = gf(st[i]^st[i+1], 0x1F) ^ st[i+3] ^ gf(st[i+17], rc)
    // rc = 0x2B ^ (r*0x11) ^ i
    task perm_round;
        input [5:0] r;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 1)
                st[i] <= gf256(st[i] ^ st[(i + 1) & 8'd31], 8'h1F)
                       ^ st[(i + 3) & 8'd31]
                       ^ gf256(st[(i + 17) & 8'd31],
                               (8'h2B ^ (r * 8'h11) ^ i[7:0]) & 8'hFF);
        end
    endtask

    // hash input bytes [0..63] of the current record come straight from RAM
    wire [7:0] abs_byte = ram[cur_base + bidx[7:0]];

    integer k;

    // =========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            st_f <= S_IDLE;  perm_ret <= PR_ABS2;
            verifying <= 1'b0;  bidx <= 9'd0;  rnd <= 6'd0;  vrec <= 6'd0;
            vmatch <= 1'b1;
            busy <= 1'b0;  done <= 1'b0;  error <= 1'b0;
            audit_fail <= 1'b0;  seq_count <= 16'd0;  dirty_reg <= 1'b0;
            rw_we <= 1'b0;
            for (k = 0; k < 32; k = k + 1) begin
                st[k] <= 8'd0;  link[k] <= 8'd0;  last_h[k] <= 8'd0;
                lv[k] <= 8'd0;
            end
        end else begin
            done  <= 1'b0;
            rw_we <= 1'b0;

            // ---- external write port is handled in the dedicated synchronous
            // ---- RAM write process below (single unified write port) --------

            case (st_f)
            // ----------------------------------------------------------------------
            S_IDLE: begin
                if (cmd_valid) begin
                    case (cmd)
                    // -------------------------------------------------- C_RESET
                    C_RESET: begin
                        st[0] <= IV0;  st[1] <= IV1;  st[2] <= IV2;  st[3] <= IV3;
                        st[4] <= IV4;  st[5] <= IV5;  st[6] <= IV6;  st[7] <= IV7;
                        st[8] <= IV8;  st[9] <= IV9;  st[10]<= IV10; st[11]<= IV11;
                        st[12]<= IV12; st[13]<= IV13; st[14]<= IV14; st[15]<= IV15;
                        st[16]<= IV16; st[17]<= IV17; st[18]<= IV18; st[19]<= IV19;
                        st[20]<= IV20; st[21]<= IV21; st[22]<= IV22; st[23]<= IV23;
                        st[24]<= IV24; st[25]<= IV25; st[26]<= IV26; st[27]<= IV27;
                        st[28]<= IV28; st[29]<= IV29; st[30]<= IV30; st[31]<= IV31;
                        st_f <= S_PERM;  perm_ret <= PR_VL0;
                        rnd <= 6'd0;
                        seq_count <= 16'd0;
                        audit_fail <= 1'b0;
                        verifying <= 1'b0;
                        busy <= 1'b1;
                        // record 0's H_prev is the IV
                        last_h[0] <= IV0;  last_h[1] <= IV1;
                        last_h[2] <= IV2;  last_h[3] <= IV3;
                        last_h[4] <= IV4;  last_h[5] <= IV5;
                        last_h[6] <= IV6;  last_h[7] <= IV7;
                        last_h[8] <= IV8;  last_h[9] <= IV9;
                        last_h[10]<= IV10; last_h[11]<= IV11;
                        last_h[12]<= IV12; last_h[13]<= IV13;
                        last_h[14]<= IV14; last_h[15]<= IV15;
                        last_h[16]<= IV16; last_h[17]<= IV17;
                        last_h[18]<= IV18; last_h[19]<= IV19;
                        last_h[20]<= IV20; last_h[21]<= IV21;
                        last_h[22]<= IV22; last_h[23]<= IV23;
                        last_h[24]<= IV24; last_h[25]<= IV25;
                        last_h[26]<= IV26; last_h[27]<= IV27;
                        last_h[28]<= IV28; last_h[29]<= IV29;
                        last_h[30]<= IV30; last_h[31]<= IV31;
                    end
                    // -------------------------------------------------- C_APPEND
                    C_APPEND: begin
                        if (seq_count >= MAX_REC) begin
                            error <= 1'b1;  done <= 1'b1;
                        end else begin
                            st_f <= S_PREP;  bidx <= 9'd0;
                            verifying <= 1'b0;
                            busy <= 1'b1;
                        end
                    end
                    // -------------------------------------------------- C_ROOT
                    C_ROOT: begin
                        dirty_reg <= 1'b0;  done <= 1'b1;
                    end
                    // -------------------------------------------------- C_VERIFY
                    C_VERIFY: begin
`ifdef DBG_C1
                        $display("DBG VERIFY start n=%0d", seq_count);
`endif
                        if (seq_count == 16'd0) begin
                            // empty trail: L must still equal L0
                            st[0] <= IV0;  st[1] <= IV1;  st[2] <= IV2;  st[3] <= IV3;
                            st[4] <= IV4;  st[5] <= IV5;  st[6] <= IV6;  st[7] <= IV7;
                            st[8] <= IV8;  st[9] <= IV9;  st[10]<= IV10; st[11]<= IV11;
                            st[12]<= IV12; st[13]<= IV13; st[14]<= IV14; st[15]<= IV15;
                            st[16]<= IV16; st[17]<= IV17; st[18]<= IV18; st[19]<= IV19;
                            st[20]<= IV20; st[21]<= IV21; st[22]<= IV22; st[23]<= IV23;
                            st[24]<= IV24; st[25]<= IV25; st[26]<= IV26; st[27]<= IV27;
                            st[28]<= IV28; st[29]<= IV29; st[30]<= IV30; st[31]<= IV31;
                            st_f <= S_PERM;  perm_ret <= PR_VL0;
                            rnd <= 6'd0;  verifying <= 1'b1;
                            vmatch <= 1'b1;
                            busy <= 1'b1;
                        end else begin
                            st[0] <= IV0;  st[1] <= IV1;  st[2] <= IV2;  st[3] <= IV3;
                            st[4] <= IV4;  st[5] <= IV5;  st[6] <= IV6;  st[7] <= IV7;
                            st[8] <= IV8;  st[9] <= IV9;  st[10]<= IV10; st[11]<= IV11;
                            st[12]<= IV12; st[13]<= IV13; st[14]<= IV14; st[15]<= IV15;
                            st[16]<= IV16; st[17]<= IV17; st[18]<= IV18; st[19]<= IV19;
                            st[20]<= IV20; st[21]<= IV21; st[22]<= IV22; st[23]<= IV23;
                            st[24]<= IV24; st[25]<= IV25; st[26]<= IV26; st[27]<= IV27;
                            st[28]<= IV28; st[29]<= IV29; st[30]<= IV30; st[31]<= IV31;
                            st_f <= S_PERM;  perm_ret <= PR_VL0;
                            rnd <= 6'd0;  verifying <= 1'b1;
                            vrec <= 6'd0;  vmatch <= 1'b1;
                            busy <= 1'b1;
                        end
                    end
                    default: begin
                        error <= 1'b1;  done <= 1'b1;
                    end
                    endcase
                end
            end
            // ----------------------------------------------------------------------
            // append: write H_prev (last_h, IV for record 0) then seq into RAM
            S_PREP: begin
                if (bidx < 9'd32) begin
                    rw_we    <= 1'b1;
                    rw_addr  <= cur_base + bidx[8:0];
                    rw_wdata <= last_h[bidx[5:0]];
                    bidx <= bidx + 9'd1;
                end else if (bidx < 9'd36) begin
                    rw_we   <= 1'b1;
                    rw_addr <= cur_base + O_SEQ + (bidx - 9'd32);
                    case (bidx - 9'd32)
                        9'd0: rw_wdata <= seq_count[7:0];
                        9'd1: rw_wdata <= seq_count[15:8];
                        default: rw_wdata <= 8'd0;
                    endcase
                    bidx <= bidx + 9'd1;
                end else begin
                    st_f <= S_ABS;  bidx <= 9'd0;
                end
            end
            // ----------------------------------------------------------------------
            // absorb: st[i] ^= ram byte, 32 bytes per block, perm between blocks
            S_ABS: begin
`ifdef DBG_C1
                if (bidx == 9'd0)
                    $display("DBG ABS start base=%0d st=%h %h %h %h lv=%h %h %h %h",
                             cur_base, st[0], st[1], st[2], st[3],
                             lv[0], lv[1], lv[2], lv[3]);
`endif
                if (bidx == 9'd31) begin
                    st[bidx[4:0]] <= st[bidx[4:0]] ^ abs_byte;
                    st_f <= S_PERM;  perm_ret <= PR_ABS2;  rnd <= 6'd0;
                    bidx <= bidx + 9'd1;   // -> 32
                end else if (bidx == 9'd63) begin
                    st[bidx[4:0]] <= st[bidx[4:0]] ^ abs_byte;
                    if (verifying) begin
                        st_f <= S_PERM;  perm_ret <= PR_VCMP;  rnd <= 6'd0;
                    end else begin
                        st_f <= S_PERM;  perm_ret <= PR_STORE;  rnd <= 6'd0;
                    end
                    bidx <= bidx + 9'd1;   // -> 64
                end else begin
                    st[bidx[4:0]] <= st[bidx[4:0]] ^ abs_byte;
                    bidx <= bidx + 9'd1;
                end
            end
            // ----------------------------------------------------------------------
            S_PERM: begin
                perm_round(rnd);
                if (rnd == 6'd11) begin
                    // the round-11 result lands at the end of this cycle;
                    // capture it in S_PDONE, one cycle later
                    st_f <= S_PDONE;
                end else begin
                    rnd <= rnd + 6'd1;
                end
            end
            // ----------------------------------------------------------------------
            S_PDONE: begin
                case (perm_ret)
                    PR_ABS2: begin
                        st_f <= S_ABS;   // bidx already 32
                    end
                    PR_STORE: begin
                        st_f <= S_STORE;  bidx <= 9'd0;
                    end
                    PR_LINK: begin
                        for (k = 0; k < 32; k = k + 1) link[k] <= st[k];
                        st_f <= S_IDLE;  busy <= 1'b0;  done <= 1'b1;
                        seq_count <= seq_count + 16'd1;
                        dirty_reg <= 1'b1;
                    end
                    PR_VL0: begin
                        // during C_VERIFY only the recomputed chain lv is
                        // written; the stored root link must stay untouched
                        // so S_VFIN can compare against it
                        for (k = 0; k < 32; k = k + 1) begin
                            lv[k] <= st[k];
                            if (!verifying) link[k] <= st[k];
                        end
                        if (verifying && seq_count == 16'd0) begin
                            st_f <= S_IDLE;  busy <= 1'b0;  done <= 1'b1;
                            verifying <= 1'b0;
                        end else begin
                            // continue: for C_RESET this ends the sequence too
                            if (verifying) begin
                                st_f <= S_ABS;  bidx <= 9'd0;
                            end else begin
                                st_f <= S_IDLE;  busy <= 1'b0;  done <= 1'b1;
                            end
                        end
                    end
                    PR_VCMP: begin
                        st_f <= S_VCMP;  bidx <= 9'd0;
                    end
                    PR_VLINK: begin
                        for (k = 0; k < 32; k = k + 1) lv[k] <= st[k];
                        if (vrec + 6'd1 == seq_count[5:0]) begin
                            st_f <= S_VFIN;
                        end else begin
                            vrec  <= vrec + 6'd1;
                            st_f <= S_ABS;  bidx <= 9'd0;
                        end
                    end
                    default: st_f <= S_IDLE;
                endcase
            end
            // ----------------------------------------------------------------------
            S_STORE: begin
                if (bidx < 9'd32) begin
                    rw_we    <= 1'b1;
                    rw_addr  <= cur_base + O_HC + bidx[8:0];
                    rw_wdata <= st[bidx[5:0]];
                    last_h[bidx[5:0]] <= st[bidx[5:0]];
                    bidx <= bidx + 9'd1;
                end else begin
                    // L = Perm(L ^ H): xor link into st, then permute
                    for (k = 0; k < 32; k = k + 1)
                        st[k] <= link[k] ^ st[k];
                    st_f <= S_PERM;  perm_ret <= PR_LINK;  rnd <= 6'd0;
                end
            end
            // ----------------------------------------------------------------------
            // verify: compare the recomputed H (in st) with the stored H_cur,
            // check the stored seq, then accumulate L
            // bidx:  0..31  H_cur byte compare (one byte per clock, single
            //                 RAM read port)
            //        32..35  stored seq field check
            //        36      accumulate the link chain and permute
            S_VCMP: begin
                if (bidx < 9'd32) begin
`ifdef DBG_C1
                    if (st[bidx[4:0]] !== ram[cur_base + O_HC + bidx[7:0]])
                        $display("DBG vrec=%0d byte %0d: H_cur %h != rec %h",
                                 vrec, bidx, st[bidx[4:0]],
                                 ram[cur_base + O_HC + bidx[7:0]]);
`endif
                    if (st[bidx[4:0]] !== ram[cur_base + O_HC + bidx[7:0]])
                        vmatch <= 1'b0;
                    bidx <= bidx + 9'd1;
                end else if (bidx < 9'd36) begin
                    if (bidx == 9'd32) begin
                        if (ram[cur_base + O_SEQ] !== {2'b00, vrec})
                            vmatch <= 1'b0;
                    end else begin
                        if (ram[cur_base + O_SEQ + (bidx - 9'd32)] !== 8'd0)
                            vmatch <= 1'b0;
                    end
                    bidx <= bidx + 9'd1;
                end else begin
                    // accumulate the link chain
                    for (k = 0; k < 32; k = k + 1)
                        st[k] <= lv[k] ^ st[k];
                    st_f <= S_PERM;  perm_ret <= PR_VLINK;  rnd <= 6'd0;
                end
            end
            // ----------------------------------------------------------------------
            S_VFIN: begin
                for (k = 0; k < 32; k = k + 1)
                    if (lv[k] !== link[k]) vmatch <= 1'b0;
`ifdef DBG_C1
                $display("DBG VFIN vmatch=%b first-diff lv=%h link=%h",
                         vmatch, lv[0], link[0]);
`endif
                if (!vmatch) audit_fail <= 1'b1;
                st_f <= S_IDLE;  busy <= 1'b0;  done <= 1'b1;
                verifying <= 1'b0;
            end
            // ----------------------------------------------------------------------
            default: st_f <= S_IDLE;
            endcase

        end
    end

    // =========================================================================
    // Dedicated synchronous record-RAM write process.
    // One physical write port, priority to the FSM (rw_* are registered in the
    // main process one cycle ahead, so this sees exactly the same values the
    // original inlined assignment saw).  Keeping the RAM out of the
    // asynchronous-reset process and giving it a single write port is what
    // lets Vivado infer distributed RAM instead of dissolving 24,576 RAM bits
    // into slice registers.
    // =========================================================================
    always @(posedge clk) begin
        if (rw_we)
            ram[rw_addr[11:0]] <= rw_wdata;
        else if (wr_valid && wr_addr < 12'hF00)
            ram[wr_addr[11:0]] <= wr_data;
    end

endmodule
