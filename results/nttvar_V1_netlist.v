// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (win64) Build 6511674 Tue Jun 16 11:02:23 MDT 2026
// Date        : Fri Oct 16 19:18:59 2026
// Host        : Yi running 64-bit major release  (build 9200)
// Command     : write_verilog -force -nolib C:/tmp_nttvar_1792149297/V1/reports/netlist.v
// Design      : kyber_ntt
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* BW = "16" *) (* N = "256" *) (* Q = "3329" *) 
(* S_BUTTER = "3'b010" *) (* S_DONE = "3'b111" *) (* S_IDLE = "3'b000" *) 
(* S_LAYER_SETUP = "3'b001" *) (* S_NEXT_BLOCK = "3'b011" *) (* S_NEXT_LAYER = "3'b100" *) 
(* S_REDUCE = "3'b101" *) (* S_SCALE = "3'b110" *) 
(* STRUCTURAL_NETLIST = "yes" *)
module kyber_ntt
   (clk,
    rst_n,
    start,
    inverse,
    busy,
    done,
    load,
    load_addr,
    load_data,
    read_addr,
    read_data);
  input clk;
  input rst_n;
  input start;
  input inverse;
  output busy;
  output done;
  input load;
  input [7:0]load_addr;
  input [15:0]load_data;
  input [7:0]read_addr;
  output [15:0]read_data;

  wire \<const0> ;
  wire \<const1> ;
  wire \FSM_sequential_state[0]_i_2_n_0 ;
  wire \FSM_sequential_state[2]_i_10_n_0 ;
  wire \FSM_sequential_state[2]_i_11_n_0 ;
  wire \FSM_sequential_state[2]_i_1_n_0 ;
  wire \FSM_sequential_state[2]_i_4_n_0 ;
  wire \FSM_sequential_state[2]_i_5_n_0 ;
  wire \FSM_sequential_state[2]_i_6_n_0 ;
  wire \FSM_sequential_state[2]_i_7_n_0 ;
  wire \FSM_sequential_state[2]_i_8_n_0 ;
  wire \FSM_sequential_state[2]_i_9_n_0 ;
  wire \FSM_sequential_state_reg[2]_i_3_n_0 ;
  wire \FSM_sequential_state_reg[2]_i_3_n_1 ;
  wire \FSM_sequential_state_reg[2]_i_3_n_2 ;
  wire \FSM_sequential_state_reg[2]_i_3_n_3 ;
  wire [7:1]block_cnt;
  wire \block_cnt[0]_i_1_n_0 ;
  wire \block_cnt[5]_i_2_n_0 ;
  wire \block_cnt[7]_i_1_n_0 ;
  wire \block_cnt[7]_i_3_n_0 ;
  wire \block_cnt_reg_n_0_[0] ;
  wire \block_cnt_reg_n_0_[1] ;
  wire \block_cnt_reg_n_0_[2] ;
  wire \block_cnt_reg_n_0_[3] ;
  wire \block_cnt_reg_n_0_[4] ;
  wire \block_cnt_reg_n_0_[5] ;
  wire \block_cnt_reg_n_0_[6] ;
  wire \block_cnt_reg_n_0_[7] ;
  wire busy;
  wire busy_OBUF;
  wire busy_i_1_n_0;
  wire busy_i_2_n_0;
  wire clk;
  wire clk_IBUF;
  wire clk_IBUF_BUFG;
  wire [8:0]cnt;
  wire \cnt[4]_i_2_n_0 ;
  wire \cnt[5]_i_2_n_0 ;
  wire \cnt[8]_i_1_n_0 ;
  wire \cnt[8]_i_3_n_0 ;
  wire \cnt_reg_n_0_[0] ;
  wire \cnt_reg_n_0_[1] ;
  wire \cnt_reg_n_0_[2] ;
  wire \cnt_reg_n_0_[3] ;
  wire \cnt_reg_n_0_[4] ;
  wire \cnt_reg_n_0_[5] ;
  wire \cnt_reg_n_0_[6] ;
  wire \cnt_reg_n_0_[7] ;
  wire \cnt_reg_n_0_[8] ;
  wire done;
  wire done_OBUF;
  wire done_i_1_n_0;
  wire inv_mode;
  wire inv_mode_reg_n_0;
  wire inverse;
  wire inverse_IBUF;
  wire [7:0]j_cnt;
  wire \j_cnt[5]_i_2_n_0 ;
  wire \j_cnt[5]_i_3_n_0 ;
  wire \j_cnt[7]_i_100_n_0 ;
  wire \j_cnt[7]_i_101_n_0 ;
  wire \j_cnt[7]_i_102_n_0 ;
  wire \j_cnt[7]_i_103_n_0 ;
  wire \j_cnt[7]_i_104_n_0 ;
  wire \j_cnt[7]_i_105_n_0 ;
  wire \j_cnt[7]_i_106_n_0 ;
  wire \j_cnt[7]_i_107_n_0 ;
  wire \j_cnt[7]_i_108_n_0 ;
  wire \j_cnt[7]_i_109_n_0 ;
  wire \j_cnt[7]_i_10_n_0 ;
  wire \j_cnt[7]_i_110_n_0 ;
  wire \j_cnt[7]_i_111_n_0 ;
  wire \j_cnt[7]_i_112_n_0 ;
  wire \j_cnt[7]_i_113_n_0 ;
  wire \j_cnt[7]_i_114_n_0 ;
  wire \j_cnt[7]_i_115_n_0 ;
  wire \j_cnt[7]_i_116_n_0 ;
  wire \j_cnt[7]_i_11_n_0 ;
  wire \j_cnt[7]_i_12_n_0 ;
  wire \j_cnt[7]_i_13_n_0 ;
  wire \j_cnt[7]_i_15_n_0 ;
  wire \j_cnt[7]_i_1_n_0 ;
  wire \j_cnt[7]_i_23_n_0 ;
  wire \j_cnt[7]_i_24_n_0 ;
  wire \j_cnt[7]_i_25_n_0 ;
  wire \j_cnt[7]_i_27_n_0 ;
  wire \j_cnt[7]_i_28_n_0 ;
  wire \j_cnt[7]_i_30_n_0 ;
  wire \j_cnt[7]_i_31_n_0 ;
  wire \j_cnt[7]_i_34_n_0 ;
  wire \j_cnt[7]_i_35_n_0 ;
  wire \j_cnt[7]_i_36_n_0 ;
  wire \j_cnt[7]_i_37_n_0 ;
  wire \j_cnt[7]_i_39_n_0 ;
  wire \j_cnt[7]_i_3_n_0 ;
  wire \j_cnt[7]_i_41_n_0 ;
  wire \j_cnt[7]_i_42_n_0 ;
  wire \j_cnt[7]_i_44_n_0 ;
  wire \j_cnt[7]_i_45_n_0 ;
  wire \j_cnt[7]_i_46_n_0 ;
  wire \j_cnt[7]_i_47_n_0 ;
  wire \j_cnt[7]_i_48_n_0 ;
  wire \j_cnt[7]_i_49_n_0 ;
  wire \j_cnt[7]_i_50_n_0 ;
  wire \j_cnt[7]_i_51_n_0 ;
  wire \j_cnt[7]_i_53_n_0 ;
  wire \j_cnt[7]_i_54_n_0 ;
  wire \j_cnt[7]_i_55_n_0 ;
  wire \j_cnt[7]_i_56_n_0 ;
  wire \j_cnt[7]_i_58_n_0 ;
  wire \j_cnt[7]_i_59_n_0 ;
  wire \j_cnt[7]_i_5_n_0 ;
  wire \j_cnt[7]_i_60_n_0 ;
  wire \j_cnt[7]_i_61_n_0 ;
  wire \j_cnt[7]_i_64_n_0 ;
  wire \j_cnt[7]_i_65_n_0 ;
  wire \j_cnt[7]_i_66_n_0 ;
  wire \j_cnt[7]_i_67_n_0 ;
  wire \j_cnt[7]_i_68_n_0 ;
  wire \j_cnt[7]_i_69_n_0 ;
  wire \j_cnt[7]_i_6_n_0 ;
  wire \j_cnt[7]_i_70_n_0 ;
  wire \j_cnt[7]_i_71_n_0 ;
  wire \j_cnt[7]_i_73_n_0 ;
  wire \j_cnt[7]_i_74_n_0 ;
  wire \j_cnt[7]_i_75_n_0 ;
  wire \j_cnt[7]_i_76_n_0 ;
  wire \j_cnt[7]_i_78_n_0 ;
  wire \j_cnt[7]_i_79_n_0 ;
  wire \j_cnt[7]_i_7_n_0 ;
  wire \j_cnt[7]_i_80_n_0 ;
  wire \j_cnt[7]_i_81_n_0 ;
  wire \j_cnt[7]_i_82_n_0 ;
  wire \j_cnt[7]_i_83_n_0 ;
  wire \j_cnt[7]_i_84_n_0 ;
  wire \j_cnt[7]_i_85_n_0 ;
  wire \j_cnt[7]_i_86_n_0 ;
  wire \j_cnt[7]_i_87_n_0 ;
  wire \j_cnt[7]_i_88_n_0 ;
  wire \j_cnt[7]_i_89_n_0 ;
  wire \j_cnt[7]_i_8_n_0 ;
  wire \j_cnt[7]_i_90_n_0 ;
  wire \j_cnt[7]_i_91_n_0 ;
  wire \j_cnt[7]_i_92_n_0 ;
  wire \j_cnt[7]_i_93_n_0 ;
  wire \j_cnt[7]_i_94_n_0 ;
  wire \j_cnt[7]_i_95_n_0 ;
  wire \j_cnt[7]_i_96_n_0 ;
  wire \j_cnt[7]_i_97_n_0 ;
  wire \j_cnt[7]_i_98_n_0 ;
  wire \j_cnt[7]_i_99_n_0 ;
  wire \j_cnt[7]_i_9_n_0 ;
  wire \j_cnt_reg[7]_i_14_n_3 ;
  wire \j_cnt_reg[7]_i_16_n_2 ;
  wire \j_cnt_reg[7]_i_16_n_3 ;
  wire \j_cnt_reg[7]_i_16_n_7 ;
  wire \j_cnt_reg[7]_i_17_n_2 ;
  wire \j_cnt_reg[7]_i_17_n_3 ;
  wire \j_cnt_reg[7]_i_17_n_7 ;
  wire \j_cnt_reg[7]_i_18_n_2 ;
  wire \j_cnt_reg[7]_i_18_n_3 ;
  wire \j_cnt_reg[7]_i_18_n_7 ;
  wire \j_cnt_reg[7]_i_19_n_2 ;
  wire \j_cnt_reg[7]_i_19_n_3 ;
  wire \j_cnt_reg[7]_i_19_n_7 ;
  wire \j_cnt_reg[7]_i_20_n_3 ;
  wire \j_cnt_reg[7]_i_21_n_2 ;
  wire \j_cnt_reg[7]_i_21_n_3 ;
  wire \j_cnt_reg[7]_i_21_n_7 ;
  wire \j_cnt_reg[7]_i_22_n_0 ;
  wire \j_cnt_reg[7]_i_22_n_1 ;
  wire \j_cnt_reg[7]_i_22_n_2 ;
  wire \j_cnt_reg[7]_i_22_n_3 ;
  wire \j_cnt_reg[7]_i_22_n_4 ;
  wire \j_cnt_reg[7]_i_22_n_5 ;
  wire \j_cnt_reg[7]_i_22_n_6 ;
  wire \j_cnt_reg[7]_i_22_n_7 ;
  wire \j_cnt_reg[7]_i_26_n_0 ;
  wire \j_cnt_reg[7]_i_26_n_1 ;
  wire \j_cnt_reg[7]_i_26_n_2 ;
  wire \j_cnt_reg[7]_i_26_n_3 ;
  wire \j_cnt_reg[7]_i_26_n_4 ;
  wire \j_cnt_reg[7]_i_26_n_5 ;
  wire \j_cnt_reg[7]_i_26_n_6 ;
  wire \j_cnt_reg[7]_i_26_n_7 ;
  wire \j_cnt_reg[7]_i_29_n_0 ;
  wire \j_cnt_reg[7]_i_29_n_1 ;
  wire \j_cnt_reg[7]_i_29_n_2 ;
  wire \j_cnt_reg[7]_i_29_n_3 ;
  wire \j_cnt_reg[7]_i_29_n_4 ;
  wire \j_cnt_reg[7]_i_29_n_5 ;
  wire \j_cnt_reg[7]_i_29_n_6 ;
  wire \j_cnt_reg[7]_i_29_n_7 ;
  wire \j_cnt_reg[7]_i_32_n_0 ;
  wire \j_cnt_reg[7]_i_32_n_1 ;
  wire \j_cnt_reg[7]_i_32_n_2 ;
  wire \j_cnt_reg[7]_i_32_n_3 ;
  wire \j_cnt_reg[7]_i_32_n_4 ;
  wire \j_cnt_reg[7]_i_32_n_5 ;
  wire \j_cnt_reg[7]_i_32_n_6 ;
  wire \j_cnt_reg[7]_i_32_n_7 ;
  wire \j_cnt_reg[7]_i_33_n_0 ;
  wire \j_cnt_reg[7]_i_33_n_1 ;
  wire \j_cnt_reg[7]_i_33_n_2 ;
  wire \j_cnt_reg[7]_i_33_n_3 ;
  wire \j_cnt_reg[7]_i_33_n_4 ;
  wire \j_cnt_reg[7]_i_33_n_5 ;
  wire \j_cnt_reg[7]_i_33_n_6 ;
  wire \j_cnt_reg[7]_i_33_n_7 ;
  wire \j_cnt_reg[7]_i_38_n_0 ;
  wire \j_cnt_reg[7]_i_38_n_1 ;
  wire \j_cnt_reg[7]_i_38_n_2 ;
  wire \j_cnt_reg[7]_i_38_n_3 ;
  wire \j_cnt_reg[7]_i_40_n_0 ;
  wire \j_cnt_reg[7]_i_40_n_1 ;
  wire \j_cnt_reg[7]_i_40_n_2 ;
  wire \j_cnt_reg[7]_i_40_n_3 ;
  wire \j_cnt_reg[7]_i_40_n_4 ;
  wire \j_cnt_reg[7]_i_40_n_5 ;
  wire \j_cnt_reg[7]_i_40_n_6 ;
  wire \j_cnt_reg[7]_i_40_n_7 ;
  wire \j_cnt_reg[7]_i_43_n_0 ;
  wire \j_cnt_reg[7]_i_43_n_1 ;
  wire \j_cnt_reg[7]_i_43_n_2 ;
  wire \j_cnt_reg[7]_i_43_n_3 ;
  wire \j_cnt_reg[7]_i_43_n_4 ;
  wire \j_cnt_reg[7]_i_43_n_5 ;
  wire \j_cnt_reg[7]_i_43_n_6 ;
  wire \j_cnt_reg[7]_i_43_n_7 ;
  wire \j_cnt_reg[7]_i_4_n_0 ;
  wire \j_cnt_reg[7]_i_4_n_1 ;
  wire \j_cnt_reg[7]_i_4_n_2 ;
  wire \j_cnt_reg[7]_i_4_n_3 ;
  wire \j_cnt_reg[7]_i_52_n_0 ;
  wire \j_cnt_reg[7]_i_52_n_1 ;
  wire \j_cnt_reg[7]_i_52_n_2 ;
  wire \j_cnt_reg[7]_i_52_n_3 ;
  wire \j_cnt_reg[7]_i_52_n_4 ;
  wire \j_cnt_reg[7]_i_52_n_5 ;
  wire \j_cnt_reg[7]_i_52_n_6 ;
  wire \j_cnt_reg[7]_i_57_n_0 ;
  wire \j_cnt_reg[7]_i_57_n_1 ;
  wire \j_cnt_reg[7]_i_57_n_2 ;
  wire \j_cnt_reg[7]_i_57_n_3 ;
  wire \j_cnt_reg[7]_i_57_n_4 ;
  wire \j_cnt_reg[7]_i_57_n_5 ;
  wire \j_cnt_reg[7]_i_57_n_6 ;
  wire \j_cnt_reg[7]_i_62_n_0 ;
  wire \j_cnt_reg[7]_i_62_n_1 ;
  wire \j_cnt_reg[7]_i_62_n_2 ;
  wire \j_cnt_reg[7]_i_62_n_3 ;
  wire \j_cnt_reg[7]_i_62_n_4 ;
  wire \j_cnt_reg[7]_i_62_n_5 ;
  wire \j_cnt_reg[7]_i_62_n_6 ;
  wire \j_cnt_reg[7]_i_63_n_0 ;
  wire \j_cnt_reg[7]_i_63_n_1 ;
  wire \j_cnt_reg[7]_i_63_n_2 ;
  wire \j_cnt_reg[7]_i_63_n_3 ;
  wire \j_cnt_reg[7]_i_63_n_4 ;
  wire \j_cnt_reg[7]_i_63_n_5 ;
  wire \j_cnt_reg[7]_i_63_n_6 ;
  wire \j_cnt_reg[7]_i_72_n_0 ;
  wire \j_cnt_reg[7]_i_72_n_1 ;
  wire \j_cnt_reg[7]_i_72_n_2 ;
  wire \j_cnt_reg[7]_i_72_n_3 ;
  wire \j_cnt_reg[7]_i_77_n_0 ;
  wire \j_cnt_reg[7]_i_77_n_1 ;
  wire \j_cnt_reg[7]_i_77_n_2 ;
  wire \j_cnt_reg[7]_i_77_n_3 ;
  wire \j_cnt_reg[7]_i_77_n_4 ;
  wire \j_cnt_reg[7]_i_77_n_5 ;
  wire \j_cnt_reg[7]_i_77_n_6 ;
  wire \j_cnt_reg_n_0_[0] ;
  wire \j_cnt_reg_n_0_[1] ;
  wire \j_cnt_reg_n_0_[2] ;
  wire \j_cnt_reg_n_0_[3] ;
  wire \j_cnt_reg_n_0_[4] ;
  wire \j_cnt_reg_n_0_[5] ;
  wire \j_cnt_reg_n_0_[6] ;
  wire \j_cnt_reg_n_0_[7] ;
  wire [2:1]layer_idx;
  wire \layer_idx[0]_i_1_n_0 ;
  wire \layer_idx_reg_n_0_[0] ;
  wire \layer_idx_reg_n_0_[1] ;
  wire \layer_idx_reg_n_0_[2] ;
  wire [7:0]len;
  wire \len[7]_i_1_n_0 ;
  wire \len[7]_i_3_n_0 ;
  wire \len_reg_n_0_[0] ;
  wire \len_reg_n_0_[1] ;
  wire \len_reg_n_0_[2] ;
  wire \len_reg_n_0_[3] ;
  wire \len_reg_n_0_[4] ;
  wire \len_reg_n_0_[5] ;
  wire \len_reg_n_0_[6] ;
  wire \len_reg_n_0_[7] ;
  wire [15:0]read_data;
  wire rst_n;
  wire rst_n_IBUF;
  wire start;
  wire start_IBUF;
  wire [2:0]state;
  wire [2:0]state__0;
  wire [3:0]\NLW_j_cnt_reg[7]_i_52_O_UNCONNECTED ;
  wire [3:0]\NLW_j_cnt_reg[7]_i_57_O_UNCONNECTED ;
  wire [3:0]\NLW_j_cnt_reg[7]_i_62_O_UNCONNECTED ;
  wire [3:0]\NLW_j_cnt_reg[7]_i_63_O_UNCONNECTED ;
  wire [3:0]\NLW_j_cnt_reg[7]_i_77_O_UNCONNECTED ;

  LUT6 #(
    .INIT(64'h0FFEF0FF0FFE00FF)) 
    \FSM_sequential_state[0]_i_1 
       (.I0(\FSM_sequential_state[0]_i_2_n_0 ),
        .I1(inv_mode_reg_n_0),
        .I2(state[1]),
        .I3(state[0]),
        .I4(state[2]),
        .I5(\j_cnt_reg[7]_i_4_n_0 ),
        .O(state__0[0]));
  LUT2 #(
    .INIT(4'h7)) 
    \FSM_sequential_state[0]_i_2 
       (.I0(\layer_idx_reg_n_0_[1] ),
        .I1(\layer_idx_reg_n_0_[2] ),
        .O(\FSM_sequential_state[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000FFFFFFFF2000)) 
    \FSM_sequential_state[1]_i_1 
       (.I0(state[2]),
        .I1(inv_mode_reg_n_0),
        .I2(\layer_idx_reg_n_0_[2] ),
        .I3(\layer_idx_reg_n_0_[1] ),
        .I4(state[1]),
        .I5(state[0]),
        .O(state__0[1]));
  LUT6 #(
    .INIT(64'hFFC3CECEFFC3FEFE)) 
    \FSM_sequential_state[2]_i_1 
       (.I0(start_IBUF),
        .I1(state[0]),
        .I2(state[1]),
        .I3(\cnt_reg_n_0_[8] ),
        .I4(state[2]),
        .I5(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .O(\FSM_sequential_state[2]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h9009)) 
    \FSM_sequential_state[2]_i_10 
       (.I0(\j_cnt_reg_n_0_[3] ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\j_cnt_reg_n_0_[2] ),
        .I3(\len_reg_n_0_[2] ),
        .O(\FSM_sequential_state[2]_i_10_n_0 ));
  LUT4 #(
    .INIT(16'h8421)) 
    \FSM_sequential_state[2]_i_11 
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\j_cnt_reg_n_0_[1] ),
        .I2(\len_reg_n_0_[0] ),
        .I3(\len_reg_n_0_[1] ),
        .O(\FSM_sequential_state[2]_i_11_n_0 ));
  LUT6 #(
    .INIT(64'h000FFF00FF008800)) 
    \FSM_sequential_state[2]_i_2 
       (.I0(\layer_idx_reg_n_0_[2] ),
        .I1(\layer_idx_reg_n_0_[1] ),
        .I2(\j_cnt_reg[7]_i_4_n_0 ),
        .I3(state[2]),
        .I4(state[0]),
        .I5(state[1]),
        .O(state__0[2]));
  LUT4 #(
    .INIT(16'h22B2)) 
    \FSM_sequential_state[2]_i_4 
       (.I0(\len_reg_n_0_[7] ),
        .I1(\j_cnt_reg_n_0_[7] ),
        .I2(\len_reg_n_0_[6] ),
        .I3(\j_cnt_reg_n_0_[6] ),
        .O(\FSM_sequential_state[2]_i_4_n_0 ));
  LUT4 #(
    .INIT(16'h22B2)) 
    \FSM_sequential_state[2]_i_5 
       (.I0(\len_reg_n_0_[5] ),
        .I1(\j_cnt_reg_n_0_[5] ),
        .I2(\len_reg_n_0_[4] ),
        .I3(\j_cnt_reg_n_0_[4] ),
        .O(\FSM_sequential_state[2]_i_5_n_0 ));
  LUT4 #(
    .INIT(16'h22B2)) 
    \FSM_sequential_state[2]_i_6 
       (.I0(\len_reg_n_0_[3] ),
        .I1(\j_cnt_reg_n_0_[3] ),
        .I2(\len_reg_n_0_[2] ),
        .I3(\j_cnt_reg_n_0_[2] ),
        .O(\FSM_sequential_state[2]_i_6_n_0 ));
  LUT4 #(
    .INIT(16'h22B2)) 
    \FSM_sequential_state[2]_i_7 
       (.I0(\len_reg_n_0_[1] ),
        .I1(\j_cnt_reg_n_0_[1] ),
        .I2(\len_reg_n_0_[0] ),
        .I3(\j_cnt_reg_n_0_[0] ),
        .O(\FSM_sequential_state[2]_i_7_n_0 ));
  LUT4 #(
    .INIT(16'h9009)) 
    \FSM_sequential_state[2]_i_8 
       (.I0(\j_cnt_reg_n_0_[7] ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\j_cnt_reg_n_0_[6] ),
        .I3(\len_reg_n_0_[6] ),
        .O(\FSM_sequential_state[2]_i_8_n_0 ));
  LUT4 #(
    .INIT(16'h9009)) 
    \FSM_sequential_state[2]_i_9 
       (.I0(\j_cnt_reg_n_0_[5] ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\j_cnt_reg_n_0_[4] ),
        .I3(\len_reg_n_0_[4] ),
        .O(\FSM_sequential_state[2]_i_9_n_0 ));
  (* FSM_ENCODED_STATES = "S_IDLE:000,S_BUTTER:010,S_NEXT_BLOCK:011,S_DONE:111,S_NEXT_LAYER:100,S_SCALE:101,S_REDUCE:110,S_LAYER_SETUP:001" *) 
  FDCE \FSM_sequential_state_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\FSM_sequential_state[2]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(state__0[0]),
        .Q(state[0]));
  (* FSM_ENCODED_STATES = "S_IDLE:000,S_BUTTER:010,S_NEXT_BLOCK:011,S_DONE:111,S_NEXT_LAYER:100,S_SCALE:101,S_REDUCE:110,S_LAYER_SETUP:001" *) 
  FDCE \FSM_sequential_state_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\FSM_sequential_state[2]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(state__0[1]),
        .Q(state[1]));
  (* FSM_ENCODED_STATES = "S_IDLE:000,S_BUTTER:010,S_NEXT_BLOCK:011,S_DONE:111,S_NEXT_LAYER:100,S_SCALE:101,S_REDUCE:110,S_LAYER_SETUP:001" *) 
  FDCE \FSM_sequential_state_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\FSM_sequential_state[2]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(state__0[2]),
        .Q(state[2]));
  (* COMPARATOR_THRESHOLD = "6" *) 
  CARRY4 \FSM_sequential_state_reg[2]_i_3 
       (.CI(\<const0> ),
        .CO({\FSM_sequential_state_reg[2]_i_3_n_0 ,\FSM_sequential_state_reg[2]_i_3_n_1 ,\FSM_sequential_state_reg[2]_i_3_n_2 ,\FSM_sequential_state_reg[2]_i_3_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\FSM_sequential_state[2]_i_4_n_0 ,\FSM_sequential_state[2]_i_5_n_0 ,\FSM_sequential_state[2]_i_6_n_0 ,\FSM_sequential_state[2]_i_7_n_0 }),
        .S({\FSM_sequential_state[2]_i_8_n_0 ,\FSM_sequential_state[2]_i_9_n_0 ,\FSM_sequential_state[2]_i_10_n_0 ,\FSM_sequential_state[2]_i_11_n_0 }));
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
  LUT2 #(
    .INIT(4'h2)) 
    \block_cnt[0]_i_1 
       (.I0(state[1]),
        .I1(\block_cnt_reg_n_0_[0] ),
        .O(\block_cnt[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h60)) 
    \block_cnt[1]_i_1 
       (.I0(\block_cnt_reg_n_0_[0] ),
        .I1(\block_cnt_reg_n_0_[1] ),
        .I2(state[1]),
        .O(block_cnt[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT4 #(
    .INIT(16'h7800)) 
    \block_cnt[2]_i_1 
       (.I0(\block_cnt_reg_n_0_[1] ),
        .I1(\block_cnt_reg_n_0_[0] ),
        .I2(\block_cnt_reg_n_0_[2] ),
        .I3(state[1]),
        .O(block_cnt[2]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h7F008000)) 
    \block_cnt[3]_i_1 
       (.I0(\block_cnt_reg_n_0_[1] ),
        .I1(\block_cnt_reg_n_0_[0] ),
        .I2(\block_cnt_reg_n_0_[2] ),
        .I3(state[1]),
        .I4(\block_cnt_reg_n_0_[3] ),
        .O(block_cnt[3]));
  LUT6 #(
    .INIT(64'h6AAAAAAA00000000)) 
    \block_cnt[4]_i_1 
       (.I0(\block_cnt_reg_n_0_[4] ),
        .I1(\block_cnt_reg_n_0_[2] ),
        .I2(\block_cnt_reg_n_0_[0] ),
        .I3(\block_cnt_reg_n_0_[1] ),
        .I4(\block_cnt_reg_n_0_[3] ),
        .I5(state[1]),
        .O(block_cnt[4]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'hB040)) 
    \block_cnt[5]_i_1 
       (.I0(\block_cnt[5]_i_2_n_0 ),
        .I1(\block_cnt_reg_n_0_[4] ),
        .I2(state[1]),
        .I3(\block_cnt_reg_n_0_[5] ),
        .O(block_cnt[5]));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \block_cnt[5]_i_2 
       (.I0(\block_cnt_reg_n_0_[2] ),
        .I1(\block_cnt_reg_n_0_[0] ),
        .I2(\block_cnt_reg_n_0_[1] ),
        .I3(\block_cnt_reg_n_0_[3] ),
        .O(\block_cnt[5]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'h82)) 
    \block_cnt[6]_i_1 
       (.I0(state[1]),
        .I1(\block_cnt[7]_i_3_n_0 ),
        .I2(\block_cnt_reg_n_0_[6] ),
        .O(block_cnt[6]));
  LUT5 #(
    .INIT(32'hAAAAEAAA)) 
    \block_cnt[7]_i_1 
       (.I0(\len[7]_i_1_n_0 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(\j_cnt_reg[7]_i_4_n_0 ),
        .I4(state[2]),
        .O(\block_cnt[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'h8288)) 
    \block_cnt[7]_i_2 
       (.I0(state[1]),
        .I1(\block_cnt_reg_n_0_[7] ),
        .I2(\block_cnt[7]_i_3_n_0 ),
        .I3(\block_cnt_reg_n_0_[6] ),
        .O(block_cnt[7]));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    \block_cnt[7]_i_3 
       (.I0(\block_cnt_reg_n_0_[4] ),
        .I1(\block_cnt_reg_n_0_[2] ),
        .I2(\block_cnt_reg_n_0_[0] ),
        .I3(\block_cnt_reg_n_0_[1] ),
        .I4(\block_cnt_reg_n_0_[3] ),
        .I5(\block_cnt_reg_n_0_[5] ),
        .O(\block_cnt[7]_i_3_n_0 ));
  FDCE \block_cnt_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(\block_cnt[0]_i_1_n_0 ),
        .Q(\block_cnt_reg_n_0_[0] ));
  FDCE \block_cnt_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(block_cnt[1]),
        .Q(\block_cnt_reg_n_0_[1] ));
  FDCE \block_cnt_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(block_cnt[2]),
        .Q(\block_cnt_reg_n_0_[2] ));
  FDCE \block_cnt_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(block_cnt[3]),
        .Q(\block_cnt_reg_n_0_[3] ));
  FDCE \block_cnt_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(block_cnt[4]),
        .Q(\block_cnt_reg_n_0_[4] ));
  FDCE \block_cnt_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(block_cnt[5]),
        .Q(\block_cnt_reg_n_0_[5] ));
  FDCE \block_cnt_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(block_cnt[6]),
        .Q(\block_cnt_reg_n_0_[6] ));
  FDCE \block_cnt_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(block_cnt[7]),
        .Q(\block_cnt_reg_n_0_[7] ));
  OBUF busy_OBUF_inst
       (.I(busy_OBUF),
        .O(busy));
  LUT4 #(
    .INIT(16'h8810)) 
    busy_i_1
       (.I0(state[0]),
        .I1(state[1]),
        .I2(start_IBUF),
        .I3(state[2]),
        .O(busy_i_1_n_0));
  LUT2 #(
    .INIT(4'h2)) 
    busy_i_2
       (.I0(start_IBUF),
        .I1(state[2]),
        .O(busy_i_2_n_0));
  FDCE busy_reg
       (.C(clk_IBUF_BUFG),
        .CE(busy_i_1_n_0),
        .CLR(\len[7]_i_3_n_0 ),
        .D(busy_i_2_n_0),
        .Q(busy_OBUF));
  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'h0E)) 
    \cnt[0]_i_1 
       (.I0(state[1]),
        .I1(state[0]),
        .I2(\cnt_reg_n_0_[0] ),
        .O(cnt[0]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'h6660)) 
    \cnt[1]_i_1 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(\cnt_reg_n_0_[1] ),
        .I2(state[1]),
        .I3(state[0]),
        .O(cnt[1]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT5 #(
    .INIT(32'h77708880)) 
    \cnt[2]_i_1 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(\cnt_reg_n_0_[1] ),
        .I2(state[1]),
        .I3(state[0]),
        .I4(\cnt_reg_n_0_[2] ),
        .O(cnt[2]));
  LUT6 #(
    .INIT(64'h7F7F7F0080808000)) 
    \cnt[3]_i_1 
       (.I0(\cnt_reg_n_0_[1] ),
        .I1(\cnt_reg_n_0_[0] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(state[1]),
        .I4(state[0]),
        .I5(\cnt_reg_n_0_[3] ),
        .O(cnt[3]));
  LUT6 #(
    .INIT(64'h7FFF000080000000)) 
    \cnt[4]_i_1 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\cnt_reg_n_0_[0] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\cnt_reg_n_0_[3] ),
        .I4(\cnt[4]_i_2_n_0 ),
        .I5(\cnt_reg_n_0_[4] ),
        .O(cnt[4]));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \cnt[4]_i_2 
       (.I0(state[1]),
        .I1(state[0]),
        .O(\cnt[4]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'hA854)) 
    \cnt[5]_i_1 
       (.I0(\cnt[5]_i_2_n_0 ),
        .I1(state[1]),
        .I2(state[0]),
        .I3(\cnt_reg_n_0_[5] ),
        .O(cnt[5]));
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \cnt[5]_i_2 
       (.I0(\cnt_reg_n_0_[3] ),
        .I1(\cnt_reg_n_0_[1] ),
        .I2(\cnt_reg_n_0_[0] ),
        .I3(\cnt_reg_n_0_[2] ),
        .I4(\cnt_reg_n_0_[4] ),
        .O(\cnt[5]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'h9990)) 
    \cnt[6]_i_1 
       (.I0(\cnt[8]_i_3_n_0 ),
        .I1(\cnt_reg_n_0_[6] ),
        .I2(state[1]),
        .I3(state[0]),
        .O(cnt[6]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT5 #(
    .INIT(32'hBBB04440)) 
    \cnt[7]_i_1 
       (.I0(\cnt[8]_i_3_n_0 ),
        .I1(\cnt_reg_n_0_[6] ),
        .I2(state[1]),
        .I3(state[0]),
        .I4(\cnt_reg_n_0_[7] ),
        .O(cnt[7]));
  LUT6 #(
    .INIT(64'h000800000FF80000)) 
    \cnt[8]_i_1 
       (.I0(\layer_idx_reg_n_0_[1] ),
        .I1(\layer_idx_reg_n_0_[2] ),
        .I2(state[0]),
        .I3(state[1]),
        .I4(state[2]),
        .I5(\cnt_reg_n_0_[8] ),
        .O(\cnt[8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hDF20DF20DF200000)) 
    \cnt[8]_i_2 
       (.I0(\cnt_reg_n_0_[6] ),
        .I1(\cnt[8]_i_3_n_0 ),
        .I2(\cnt_reg_n_0_[7] ),
        .I3(\cnt_reg_n_0_[8] ),
        .I4(state[1]),
        .I5(state[0]),
        .O(cnt[8]));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    \cnt[8]_i_3 
       (.I0(\cnt_reg_n_0_[4] ),
        .I1(\cnt_reg_n_0_[2] ),
        .I2(\cnt_reg_n_0_[0] ),
        .I3(\cnt_reg_n_0_[1] ),
        .I4(\cnt_reg_n_0_[3] ),
        .I5(\cnt_reg_n_0_[5] ),
        .O(\cnt[8]_i_3_n_0 ));
  FDCE \cnt_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[8]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(cnt[0]),
        .Q(\cnt_reg_n_0_[0] ));
  FDCE \cnt_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[8]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(cnt[1]),
        .Q(\cnt_reg_n_0_[1] ));
  FDCE \cnt_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[8]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(cnt[2]),
        .Q(\cnt_reg_n_0_[2] ));
  FDCE \cnt_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[8]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(cnt[3]),
        .Q(\cnt_reg_n_0_[3] ));
  FDCE \cnt_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[8]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(cnt[4]),
        .Q(\cnt_reg_n_0_[4] ));
  FDCE \cnt_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[8]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(cnt[5]),
        .Q(\cnt_reg_n_0_[5] ));
  FDCE \cnt_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[8]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(cnt[6]),
        .Q(\cnt_reg_n_0_[6] ));
  FDCE \cnt_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[8]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(cnt[7]),
        .Q(\cnt_reg_n_0_[7] ));
  FDCE \cnt_reg[8] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[8]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(cnt[8]),
        .Q(\cnt_reg_n_0_[8] ));
  OBUF done_OBUF_inst
       (.I(done_OBUF),
        .O(done));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'h80)) 
    done_i_1
       (.I0(state[1]),
        .I1(state[0]),
        .I2(state[2]),
        .O(done_i_1_n_0));
  FDCE done_reg
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(done_i_1_n_0),
        .Q(done_OBUF));
  LUT4 #(
    .INIT(16'h0004)) 
    inv_mode_i_1
       (.I0(state[2]),
        .I1(start_IBUF),
        .I2(state[1]),
        .I3(state[0]),
        .O(inv_mode));
  FDCE inv_mode_reg
       (.C(clk_IBUF_BUFG),
        .CE(inv_mode),
        .CLR(\len[7]_i_3_n_0 ),
        .D(inverse_IBUF),
        .Q(inv_mode_reg_n_0));
  IBUF inverse_IBUF_inst
       (.I(inverse),
        .O(inverse_IBUF));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'h04)) 
    \j_cnt[0]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\j_cnt_reg_n_0_[0] ),
        .O(j_cnt[0]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h0220)) 
    \j_cnt[1]_i_1 
       (.I0(state[1]),
        .I1(state[0]),
        .I2(\j_cnt_reg_n_0_[1] ),
        .I3(\j_cnt_reg_n_0_[0] ),
        .O(j_cnt[1]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h02222000)) 
    \j_cnt[2]_i_1 
       (.I0(state[1]),
        .I1(state[0]),
        .I2(\j_cnt_reg_n_0_[1] ),
        .I3(\j_cnt_reg_n_0_[0] ),
        .I4(\j_cnt_reg_n_0_[2] ),
        .O(j_cnt[2]));
  LUT6 #(
    .INIT(64'h007F000000800000)) 
    \j_cnt[3]_i_1 
       (.I0(\j_cnt_reg_n_0_[1] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\j_cnt_reg_n_0_[2] ),
        .I3(state[0]),
        .I4(state[1]),
        .I5(\j_cnt_reg_n_0_[3] ),
        .O(j_cnt[3]));
  LUT6 #(
    .INIT(64'h7FFF000080000000)) 
    \j_cnt[4]_i_1 
       (.I0(\j_cnt_reg_n_0_[2] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\j_cnt_reg_n_0_[1] ),
        .I3(\j_cnt_reg_n_0_[3] ),
        .I4(\j_cnt[5]_i_3_n_0 ),
        .I5(\j_cnt_reg_n_0_[4] ),
        .O(j_cnt[4]));
  LUT6 #(
    .INIT(64'hDFFF000020000000)) 
    \j_cnt[5]_i_1 
       (.I0(\j_cnt_reg_n_0_[3] ),
        .I1(\j_cnt[5]_i_2_n_0 ),
        .I2(\j_cnt_reg_n_0_[2] ),
        .I3(\j_cnt_reg_n_0_[4] ),
        .I4(\j_cnt[5]_i_3_n_0 ),
        .I5(\j_cnt_reg_n_0_[5] ),
        .O(j_cnt[5]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT2 #(
    .INIT(4'h7)) 
    \j_cnt[5]_i_2 
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\j_cnt_reg_n_0_[1] ),
        .O(\j_cnt[5]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \j_cnt[5]_i_3 
       (.I0(state[1]),
        .I1(state[0]),
        .O(\j_cnt[5]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h0900)) 
    \j_cnt[6]_i_1 
       (.I0(\j_cnt[7]_i_5_n_0 ),
        .I1(\j_cnt_reg_n_0_[6] ),
        .I2(state[0]),
        .I3(state[1]),
        .O(j_cnt[6]));
  LUT6 #(
    .INIT(64'hAAAAAAAAEAFFEAEE)) 
    \j_cnt[7]_i_1 
       (.I0(\j_cnt[7]_i_3_n_0 ),
        .I1(state[0]),
        .I2(\j_cnt_reg[7]_i_4_n_0 ),
        .I3(state[1]),
        .I4(start_IBUF),
        .I5(state[2]),
        .O(\j_cnt[7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h41248218)) 
    \j_cnt[7]_i_10 
       (.I0(\block_cnt_reg_n_0_[7] ),
        .I1(\j_cnt_reg[7]_i_14_n_3 ),
        .I2(\block_cnt_reg_n_0_[6] ),
        .I3(\block_cnt[7]_i_3_n_0 ),
        .I4(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_10_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_100 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_19_n_2 ),
        .O(\j_cnt[7]_i_100_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_101 
       (.I0(\j_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\j_cnt_reg[7]_i_63_n_5 ),
        .O(\j_cnt[7]_i_101_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_102 
       (.I0(\j_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\j_cnt_reg[7]_i_63_n_6 ),
        .O(\j_cnt[7]_i_102_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_103 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_19_n_2 ),
        .O(\j_cnt[7]_i_103_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_104 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_17_n_2 ),
        .O(\j_cnt[7]_i_104_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_105 
       (.I0(\j_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\j_cnt_reg[7]_i_57_n_5 ),
        .O(\j_cnt[7]_i_105_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_106 
       (.I0(\j_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\j_cnt_reg[7]_i_57_n_6 ),
        .O(\j_cnt[7]_i_106_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_107 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_17_n_2 ),
        .O(\j_cnt[7]_i_107_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_108 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_21_n_2 ),
        .O(\j_cnt[7]_i_108_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_109 
       (.I0(\j_cnt_reg[7]_i_21_n_2 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\j_cnt_reg[7]_i_77_n_4 ),
        .O(\j_cnt[7]_i_109_n_0 ));
  LUT5 #(
    .INIT(32'h90094224)) 
    \j_cnt[7]_i_11 
       (.I0(\block_cnt_reg_n_0_[4] ),
        .I1(\block_cnt[5]_i_2_n_0 ),
        .I2(\block_cnt_reg_n_0_[5] ),
        .I3(\j_cnt_reg[7]_i_16_n_2 ),
        .I4(\j_cnt_reg[7]_i_17_n_2 ),
        .O(\j_cnt[7]_i_11_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_110 
       (.I0(\j_cnt_reg[7]_i_21_n_2 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\j_cnt_reg[7]_i_77_n_5 ),
        .O(\j_cnt[7]_i_110_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_111 
       (.I0(\j_cnt_reg[7]_i_21_n_2 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\j_cnt_reg[7]_i_77_n_6 ),
        .O(\j_cnt[7]_i_111_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_112 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_21_n_2 ),
        .O(\j_cnt[7]_i_112_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_113 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_18_n_2 ),
        .O(\j_cnt[7]_i_113_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_114 
       (.I0(\j_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\j_cnt_reg[7]_i_62_n_5 ),
        .O(\j_cnt[7]_i_114_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_115 
       (.I0(\j_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\j_cnt_reg[7]_i_62_n_6 ),
        .O(\j_cnt[7]_i_115_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_116 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_18_n_2 ),
        .O(\j_cnt[7]_i_116_n_0 ));
  LUT6 #(
    .INIT(64'h6A00006A15808015)) 
    \j_cnt[7]_i_12 
       (.I0(\block_cnt_reg_n_0_[2] ),
        .I1(\block_cnt_reg_n_0_[0] ),
        .I2(\block_cnt_reg_n_0_[1] ),
        .I3(\block_cnt_reg_n_0_[3] ),
        .I4(\j_cnt_reg[7]_i_19_n_2 ),
        .I5(\j_cnt_reg[7]_i_18_n_2 ),
        .O(\j_cnt[7]_i_12_n_0 ));
  LUT4 #(
    .INIT(16'h0960)) 
    \j_cnt[7]_i_13 
       (.I0(\block_cnt_reg_n_0_[1] ),
        .I1(\j_cnt_reg[7]_i_21_n_2 ),
        .I2(\block_cnt_reg_n_0_[0] ),
        .I3(\j_cnt_reg[7]_i_20_n_3 ),
        .O(\j_cnt[7]_i_13_n_0 ));
  LUT2 #(
    .INIT(4'hE)) 
    \j_cnt[7]_i_15 
       (.I0(\j_cnt[7]_i_25_n_0 ),
        .I1(\len_reg_n_0_[7] ),
        .O(\j_cnt[7]_i_15_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h0B000400)) 
    \j_cnt[7]_i_2 
       (.I0(\j_cnt[7]_i_5_n_0 ),
        .I1(\j_cnt_reg_n_0_[6] ),
        .I2(state[0]),
        .I3(state[1]),
        .I4(\j_cnt_reg_n_0_[7] ),
        .O(j_cnt[7]));
  LUT1 #(
    .INIT(2'h1)) 
    \j_cnt[7]_i_23 
       (.I0(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_23_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \j_cnt[7]_i_24 
       (.I0(\len_reg_n_0_[7] ),
        .I1(\j_cnt[7]_i_25_n_0 ),
        .O(\j_cnt[7]_i_24_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    \j_cnt[7]_i_25 
       (.I0(\len_reg_n_0_[5] ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\len_reg_n_0_[2] ),
        .I4(\len_reg_n_0_[4] ),
        .I5(\len_reg_n_0_[6] ),
        .O(\j_cnt[7]_i_25_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_27 
       (.I0(\j_cnt_reg[7]_i_14_n_3 ),
        .I1(\j_cnt_reg[7]_i_22_n_4 ),
        .O(\j_cnt[7]_i_27_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_28 
       (.I0(\j_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\j_cnt_reg[7]_i_22_n_5 ),
        .O(\j_cnt[7]_i_28_n_0 ));
  LUT6 #(
    .INIT(64'h0007000700F00000)) 
    \j_cnt[7]_i_3 
       (.I0(\layer_idx_reg_n_0_[1] ),
        .I1(\layer_idx_reg_n_0_[2] ),
        .I2(state[1]),
        .I3(state[0]),
        .I4(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I5(state[2]),
        .O(\j_cnt[7]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_30 
       (.I0(\j_cnt_reg[7]_i_16_n_2 ),
        .I1(\j_cnt_reg[7]_i_16_n_7 ),
        .O(\j_cnt[7]_i_30_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_31 
       (.I0(\j_cnt_reg[7]_i_16_n_2 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\j_cnt_reg[7]_i_26_n_4 ),
        .O(\j_cnt[7]_i_31_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_34 
       (.I0(\j_cnt_reg[7]_i_19_n_2 ),
        .I1(\j_cnt_reg[7]_i_19_n_7 ),
        .O(\j_cnt[7]_i_34_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_35 
       (.I0(\j_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\j_cnt_reg[7]_i_33_n_4 ),
        .O(\j_cnt[7]_i_35_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_36 
       (.I0(\j_cnt_reg[7]_i_17_n_2 ),
        .I1(\j_cnt_reg[7]_i_17_n_7 ),
        .O(\j_cnt[7]_i_36_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_37 
       (.I0(\j_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\j_cnt_reg[7]_i_29_n_4 ),
        .O(\j_cnt[7]_i_37_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_39 
       (.I0(\j_cnt_reg[7]_i_21_n_2 ),
        .I1(\j_cnt_reg[7]_i_21_n_7 ),
        .O(\j_cnt[7]_i_39_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_41 
       (.I0(\j_cnt_reg[7]_i_18_n_2 ),
        .I1(\j_cnt_reg[7]_i_18_n_7 ),
        .O(\j_cnt[7]_i_41_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_42 
       (.I0(\j_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\j_cnt_reg[7]_i_32_n_4 ),
        .O(\j_cnt[7]_i_42_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \j_cnt[7]_i_44 
       (.I0(\len_reg_n_0_[7] ),
        .I1(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_44_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \j_cnt[7]_i_45 
       (.I0(\len_reg_n_0_[6] ),
        .I1(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_45_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \j_cnt[7]_i_46 
       (.I0(\len_reg_n_0_[5] ),
        .I1(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_46_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \j_cnt[7]_i_47 
       (.I0(\len_reg_n_0_[4] ),
        .I1(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_47_n_0 ));
  LUT3 #(
    .INIT(8'h97)) 
    \j_cnt[7]_i_48 
       (.I0(\len_reg_n_0_[7] ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\j_cnt[7]_i_90_n_0 ),
        .O(\j_cnt[7]_i_48_n_0 ));
  LUT4 #(
    .INIT(16'hA55B)) 
    \j_cnt[7]_i_49 
       (.I0(\len_reg_n_0_[6] ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\len_reg_n_0_[5] ),
        .I3(\j_cnt[7]_i_91_n_0 ),
        .O(\j_cnt[7]_i_49_n_0 ));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    \j_cnt[7]_i_5 
       (.I0(\j_cnt_reg_n_0_[4] ),
        .I1(\j_cnt_reg_n_0_[2] ),
        .I2(\j_cnt_reg_n_0_[0] ),
        .I3(\j_cnt_reg_n_0_[1] ),
        .I4(\j_cnt_reg_n_0_[3] ),
        .I5(\j_cnt_reg_n_0_[5] ),
        .O(\j_cnt[7]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h9696969696969669)) 
    \j_cnt[7]_i_50 
       (.I0(\j_cnt[7]_i_15_n_0 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\len_reg_n_0_[4] ),
        .I3(\len_reg_n_0_[2] ),
        .I4(\len_reg_n_0_[1] ),
        .I5(\len_reg_n_0_[3] ),
        .O(\j_cnt[7]_i_50_n_0 ));
  LUT5 #(
    .INIT(32'h96969669)) 
    \j_cnt[7]_i_51 
       (.I0(\j_cnt[7]_i_15_n_0 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\len_reg_n_0_[3] ),
        .I3(\len_reg_n_0_[1] ),
        .I4(\len_reg_n_0_[2] ),
        .O(\j_cnt[7]_i_51_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_53 
       (.I0(\j_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\j_cnt_reg[7]_i_22_n_6 ),
        .O(\j_cnt[7]_i_53_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_54 
       (.I0(\j_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\j_cnt_reg[7]_i_22_n_7 ),
        .O(\j_cnt[7]_i_54_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_55 
       (.I0(\j_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\j_cnt_reg[7]_i_43_n_4 ),
        .O(\j_cnt[7]_i_55_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_56 
       (.I0(\j_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\j_cnt_reg[7]_i_43_n_5 ),
        .O(\j_cnt[7]_i_56_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_58 
       (.I0(\j_cnt_reg[7]_i_16_n_2 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\j_cnt_reg[7]_i_26_n_5 ),
        .O(\j_cnt[7]_i_58_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_59 
       (.I0(\j_cnt_reg[7]_i_16_n_2 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\j_cnt_reg[7]_i_26_n_6 ),
        .O(\j_cnt[7]_i_59_n_0 ));
  LUT5 #(
    .INIT(32'h400858EF)) 
    \j_cnt[7]_i_6 
       (.I0(\block_cnt[7]_i_3_n_0 ),
        .I1(\j_cnt_reg[7]_i_14_n_3 ),
        .I2(\block_cnt_reg_n_0_[6] ),
        .I3(\block_cnt_reg_n_0_[7] ),
        .I4(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_6_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_60 
       (.I0(\j_cnt_reg[7]_i_16_n_2 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\j_cnt_reg[7]_i_26_n_7 ),
        .O(\j_cnt[7]_i_60_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_61 
       (.I0(\j_cnt_reg[7]_i_16_n_2 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\j_cnt_reg[7]_i_52_n_4 ),
        .O(\j_cnt[7]_i_61_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_64 
       (.I0(\j_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\j_cnt_reg[7]_i_33_n_5 ),
        .O(\j_cnt[7]_i_64_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_65 
       (.I0(\j_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\j_cnt_reg[7]_i_33_n_6 ),
        .O(\j_cnt[7]_i_65_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_66 
       (.I0(\j_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\j_cnt_reg[7]_i_33_n_7 ),
        .O(\j_cnt[7]_i_66_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_67 
       (.I0(\j_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\j_cnt_reg[7]_i_63_n_4 ),
        .O(\j_cnt[7]_i_67_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_68 
       (.I0(\j_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\j_cnt_reg[7]_i_29_n_5 ),
        .O(\j_cnt[7]_i_68_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_69 
       (.I0(\j_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\j_cnt_reg[7]_i_29_n_6 ),
        .O(\j_cnt[7]_i_69_n_0 ));
  LUT5 #(
    .INIT(32'h22B2E822)) 
    \j_cnt[7]_i_7 
       (.I0(\j_cnt_reg[7]_i_16_n_2 ),
        .I1(\block_cnt_reg_n_0_[5] ),
        .I2(\j_cnt_reg[7]_i_17_n_2 ),
        .I3(\block_cnt_reg_n_0_[4] ),
        .I4(\block_cnt[5]_i_2_n_0 ),
        .O(\j_cnt[7]_i_7_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_70 
       (.I0(\j_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\j_cnt_reg[7]_i_29_n_7 ),
        .O(\j_cnt[7]_i_70_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_71 
       (.I0(\j_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\j_cnt_reg[7]_i_57_n_4 ),
        .O(\j_cnt[7]_i_71_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_73 
       (.I0(\j_cnt_reg[7]_i_21_n_2 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\j_cnt_reg[7]_i_40_n_4 ),
        .O(\j_cnt[7]_i_73_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_74 
       (.I0(\j_cnt_reg[7]_i_21_n_2 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\j_cnt_reg[7]_i_40_n_5 ),
        .O(\j_cnt[7]_i_74_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_75 
       (.I0(\j_cnt_reg[7]_i_21_n_2 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\j_cnt_reg[7]_i_40_n_6 ),
        .O(\j_cnt[7]_i_75_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_76 
       (.I0(\j_cnt_reg[7]_i_21_n_2 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\j_cnt_reg[7]_i_40_n_7 ),
        .O(\j_cnt[7]_i_76_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_78 
       (.I0(\j_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\j_cnt_reg[7]_i_32_n_5 ),
        .O(\j_cnt[7]_i_78_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_79 
       (.I0(\j_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\j_cnt_reg[7]_i_32_n_6 ),
        .O(\j_cnt[7]_i_79_n_0 ));
  LUT6 #(
    .INIT(64'h8870F7FF80000070)) 
    \j_cnt[7]_i_8 
       (.I0(\block_cnt_reg_n_0_[0] ),
        .I1(\block_cnt_reg_n_0_[1] ),
        .I2(\j_cnt_reg[7]_i_18_n_2 ),
        .I3(\block_cnt_reg_n_0_[2] ),
        .I4(\block_cnt_reg_n_0_[3] ),
        .I5(\j_cnt_reg[7]_i_19_n_2 ),
        .O(\j_cnt[7]_i_8_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_80 
       (.I0(\j_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\j_cnt_reg[7]_i_32_n_7 ),
        .O(\j_cnt[7]_i_80_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_81 
       (.I0(\j_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\j_cnt_reg[7]_i_62_n_4 ),
        .O(\j_cnt[7]_i_81_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \j_cnt[7]_i_82 
       (.I0(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_82_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \j_cnt[7]_i_83 
       (.I0(\len_reg_n_0_[3] ),
        .I1(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_83_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \j_cnt[7]_i_84 
       (.I0(\len_reg_n_0_[1] ),
        .I1(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_84_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \j_cnt[7]_i_85 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_85_n_0 ));
  LUT4 #(
    .INIT(16'h9669)) 
    \j_cnt[7]_i_86 
       (.I0(\j_cnt[7]_i_15_n_0 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\len_reg_n_0_[2] ),
        .I3(\len_reg_n_0_[1] ),
        .O(\j_cnt[7]_i_86_n_0 ));
  LUT3 #(
    .INIT(8'h69)) 
    \j_cnt[7]_i_87 
       (.I0(\j_cnt[7]_i_15_n_0 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\len_reg_n_0_[1] ),
        .O(\j_cnt[7]_i_87_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_88 
       (.I0(\j_cnt[7]_i_15_n_0 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\len_reg_n_0_[0] ),
        .O(\j_cnt[7]_i_88_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \j_cnt[7]_i_89 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt[7]_i_15_n_0 ),
        .O(\j_cnt[7]_i_89_n_0 ));
  LUT4 #(
    .INIT(16'hC8B0)) 
    \j_cnt[7]_i_9 
       (.I0(\j_cnt_reg[7]_i_20_n_3 ),
        .I1(\block_cnt_reg_n_0_[0] ),
        .I2(\j_cnt_reg[7]_i_21_n_2 ),
        .I3(\block_cnt_reg_n_0_[1] ),
        .O(\j_cnt[7]_i_9_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \j_cnt[7]_i_90 
       (.I0(\len_reg_n_0_[4] ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\len_reg_n_0_[3] ),
        .I4(\len_reg_n_0_[5] ),
        .O(\j_cnt[7]_i_90_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \j_cnt[7]_i_91 
       (.I0(\len_reg_n_0_[4] ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\len_reg_n_0_[3] ),
        .O(\j_cnt[7]_i_91_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_92 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_14_n_3 ),
        .O(\j_cnt[7]_i_92_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_93 
       (.I0(\j_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\j_cnt_reg[7]_i_43_n_6 ),
        .O(\j_cnt[7]_i_93_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_94 
       (.I0(\j_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\j_cnt_reg[7]_i_43_n_7 ),
        .O(\j_cnt[7]_i_94_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_95 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_14_n_3 ),
        .O(\j_cnt[7]_i_95_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_96 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_16_n_2 ),
        .O(\j_cnt[7]_i_96_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_97 
       (.I0(\j_cnt_reg[7]_i_16_n_2 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\j_cnt_reg[7]_i_52_n_5 ),
        .O(\j_cnt[7]_i_97_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \j_cnt[7]_i_98 
       (.I0(\j_cnt_reg[7]_i_16_n_2 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\j_cnt_reg[7]_i_52_n_6 ),
        .O(\j_cnt[7]_i_98_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \j_cnt[7]_i_99 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg[7]_i_16_n_2 ),
        .O(\j_cnt[7]_i_99_n_0 ));
  FDCE \j_cnt_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(j_cnt[0]),
        .Q(\j_cnt_reg_n_0_[0] ));
  FDCE \j_cnt_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(j_cnt[1]),
        .Q(\j_cnt_reg_n_0_[1] ));
  FDCE \j_cnt_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(j_cnt[2]),
        .Q(\j_cnt_reg_n_0_[2] ));
  FDCE \j_cnt_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(j_cnt[3]),
        .Q(\j_cnt_reg_n_0_[3] ));
  FDCE \j_cnt_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(j_cnt[4]),
        .Q(\j_cnt_reg_n_0_[4] ));
  FDCE \j_cnt_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(j_cnt[5]),
        .Q(\j_cnt_reg_n_0_[5] ));
  FDCE \j_cnt_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(j_cnt[6]),
        .Q(\j_cnt_reg_n_0_[6] ));
  FDCE \j_cnt_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(j_cnt[7]),
        .Q(\j_cnt_reg_n_0_[7] ));
  CARRY4 \j_cnt_reg[7]_i_14 
       (.CI(\j_cnt_reg[7]_i_22_n_0 ),
        .CO(\j_cnt_reg[7]_i_14_n_3 ),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\j_cnt[7]_i_23_n_0 }),
        .S({\<const0> ,\<const0> ,\<const0> ,\j_cnt[7]_i_24_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_16 
       (.CI(\j_cnt_reg[7]_i_26_n_0 ),
        .CO({\j_cnt_reg[7]_i_16_n_2 ,\j_cnt_reg[7]_i_16_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\j_cnt_reg[7]_i_14_n_3 ,\j_cnt_reg[7]_i_22_n_5 }),
        .O(\j_cnt_reg[7]_i_16_n_7 ),
        .S({\<const0> ,\<const0> ,\j_cnt[7]_i_27_n_0 ,\j_cnt[7]_i_28_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_17 
       (.CI(\j_cnt_reg[7]_i_29_n_0 ),
        .CO({\j_cnt_reg[7]_i_17_n_2 ,\j_cnt_reg[7]_i_17_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\j_cnt_reg[7]_i_16_n_2 ,\j_cnt_reg[7]_i_26_n_4 }),
        .O(\j_cnt_reg[7]_i_17_n_7 ),
        .S({\<const0> ,\<const0> ,\j_cnt[7]_i_30_n_0 ,\j_cnt[7]_i_31_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_18 
       (.CI(\j_cnt_reg[7]_i_32_n_0 ),
        .CO({\j_cnt_reg[7]_i_18_n_2 ,\j_cnt_reg[7]_i_18_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\j_cnt_reg[7]_i_19_n_2 ,\j_cnt_reg[7]_i_33_n_4 }),
        .O(\j_cnt_reg[7]_i_18_n_7 ),
        .S({\<const0> ,\<const0> ,\j_cnt[7]_i_34_n_0 ,\j_cnt[7]_i_35_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_19 
       (.CI(\j_cnt_reg[7]_i_33_n_0 ),
        .CO({\j_cnt_reg[7]_i_19_n_2 ,\j_cnt_reg[7]_i_19_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\j_cnt_reg[7]_i_17_n_2 ,\j_cnt_reg[7]_i_29_n_4 }),
        .O(\j_cnt_reg[7]_i_19_n_7 ),
        .S({\<const0> ,\<const0> ,\j_cnt[7]_i_36_n_0 ,\j_cnt[7]_i_37_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_20 
       (.CI(\j_cnt_reg[7]_i_38_n_0 ),
        .CO(\j_cnt_reg[7]_i_20_n_3 ),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\j_cnt_reg[7]_i_21_n_2 }),
        .S({\<const0> ,\<const0> ,\<const0> ,\j_cnt[7]_i_39_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_21 
       (.CI(\j_cnt_reg[7]_i_40_n_0 ),
        .CO({\j_cnt_reg[7]_i_21_n_2 ,\j_cnt_reg[7]_i_21_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\j_cnt_reg[7]_i_18_n_2 ,\j_cnt_reg[7]_i_32_n_4 }),
        .O(\j_cnt_reg[7]_i_21_n_7 ),
        .S({\<const0> ,\<const0> ,\j_cnt[7]_i_41_n_0 ,\j_cnt[7]_i_42_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_22 
       (.CI(\j_cnt_reg[7]_i_43_n_0 ),
        .CO({\j_cnt_reg[7]_i_22_n_0 ,\j_cnt_reg[7]_i_22_n_1 ,\j_cnt_reg[7]_i_22_n_2 ,\j_cnt_reg[7]_i_22_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\j_cnt[7]_i_44_n_0 ,\j_cnt[7]_i_45_n_0 ,\j_cnt[7]_i_46_n_0 ,\j_cnt[7]_i_47_n_0 }),
        .O({\j_cnt_reg[7]_i_22_n_4 ,\j_cnt_reg[7]_i_22_n_5 ,\j_cnt_reg[7]_i_22_n_6 ,\j_cnt_reg[7]_i_22_n_7 }),
        .S({\j_cnt[7]_i_48_n_0 ,\j_cnt[7]_i_49_n_0 ,\j_cnt[7]_i_50_n_0 ,\j_cnt[7]_i_51_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_26 
       (.CI(\j_cnt_reg[7]_i_52_n_0 ),
        .CO({\j_cnt_reg[7]_i_26_n_0 ,\j_cnt_reg[7]_i_26_n_1 ,\j_cnt_reg[7]_i_26_n_2 ,\j_cnt_reg[7]_i_26_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\j_cnt_reg[7]_i_22_n_6 ,\j_cnt_reg[7]_i_22_n_7 ,\j_cnt_reg[7]_i_43_n_4 ,\j_cnt_reg[7]_i_43_n_5 }),
        .O({\j_cnt_reg[7]_i_26_n_4 ,\j_cnt_reg[7]_i_26_n_5 ,\j_cnt_reg[7]_i_26_n_6 ,\j_cnt_reg[7]_i_26_n_7 }),
        .S({\j_cnt[7]_i_53_n_0 ,\j_cnt[7]_i_54_n_0 ,\j_cnt[7]_i_55_n_0 ,\j_cnt[7]_i_56_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_29 
       (.CI(\j_cnt_reg[7]_i_57_n_0 ),
        .CO({\j_cnt_reg[7]_i_29_n_0 ,\j_cnt_reg[7]_i_29_n_1 ,\j_cnt_reg[7]_i_29_n_2 ,\j_cnt_reg[7]_i_29_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\j_cnt_reg[7]_i_26_n_5 ,\j_cnt_reg[7]_i_26_n_6 ,\j_cnt_reg[7]_i_26_n_7 ,\j_cnt_reg[7]_i_52_n_4 }),
        .O({\j_cnt_reg[7]_i_29_n_4 ,\j_cnt_reg[7]_i_29_n_5 ,\j_cnt_reg[7]_i_29_n_6 ,\j_cnt_reg[7]_i_29_n_7 }),
        .S({\j_cnt[7]_i_58_n_0 ,\j_cnt[7]_i_59_n_0 ,\j_cnt[7]_i_60_n_0 ,\j_cnt[7]_i_61_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_32 
       (.CI(\j_cnt_reg[7]_i_62_n_0 ),
        .CO({\j_cnt_reg[7]_i_32_n_0 ,\j_cnt_reg[7]_i_32_n_1 ,\j_cnt_reg[7]_i_32_n_2 ,\j_cnt_reg[7]_i_32_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\j_cnt_reg[7]_i_33_n_5 ,\j_cnt_reg[7]_i_33_n_6 ,\j_cnt_reg[7]_i_33_n_7 ,\j_cnt_reg[7]_i_63_n_4 }),
        .O({\j_cnt_reg[7]_i_32_n_4 ,\j_cnt_reg[7]_i_32_n_5 ,\j_cnt_reg[7]_i_32_n_6 ,\j_cnt_reg[7]_i_32_n_7 }),
        .S({\j_cnt[7]_i_64_n_0 ,\j_cnt[7]_i_65_n_0 ,\j_cnt[7]_i_66_n_0 ,\j_cnt[7]_i_67_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_33 
       (.CI(\j_cnt_reg[7]_i_63_n_0 ),
        .CO({\j_cnt_reg[7]_i_33_n_0 ,\j_cnt_reg[7]_i_33_n_1 ,\j_cnt_reg[7]_i_33_n_2 ,\j_cnt_reg[7]_i_33_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\j_cnt_reg[7]_i_29_n_5 ,\j_cnt_reg[7]_i_29_n_6 ,\j_cnt_reg[7]_i_29_n_7 ,\j_cnt_reg[7]_i_57_n_4 }),
        .O({\j_cnt_reg[7]_i_33_n_4 ,\j_cnt_reg[7]_i_33_n_5 ,\j_cnt_reg[7]_i_33_n_6 ,\j_cnt_reg[7]_i_33_n_7 }),
        .S({\j_cnt[7]_i_68_n_0 ,\j_cnt[7]_i_69_n_0 ,\j_cnt[7]_i_70_n_0 ,\j_cnt[7]_i_71_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_38 
       (.CI(\j_cnt_reg[7]_i_72_n_0 ),
        .CO({\j_cnt_reg[7]_i_38_n_0 ,\j_cnt_reg[7]_i_38_n_1 ,\j_cnt_reg[7]_i_38_n_2 ,\j_cnt_reg[7]_i_38_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\j_cnt_reg[7]_i_40_n_4 ,\j_cnt_reg[7]_i_40_n_5 ,\j_cnt_reg[7]_i_40_n_6 ,\j_cnt_reg[7]_i_40_n_7 }),
        .S({\j_cnt[7]_i_73_n_0 ,\j_cnt[7]_i_74_n_0 ,\j_cnt[7]_i_75_n_0 ,\j_cnt[7]_i_76_n_0 }));
  (* COMPARATOR_THRESHOLD = "6" *) 
  CARRY4 \j_cnt_reg[7]_i_4 
       (.CI(\<const0> ),
        .CO({\j_cnt_reg[7]_i_4_n_0 ,\j_cnt_reg[7]_i_4_n_1 ,\j_cnt_reg[7]_i_4_n_2 ,\j_cnt_reg[7]_i_4_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\j_cnt[7]_i_6_n_0 ,\j_cnt[7]_i_7_n_0 ,\j_cnt[7]_i_8_n_0 ,\j_cnt[7]_i_9_n_0 }),
        .S({\j_cnt[7]_i_10_n_0 ,\j_cnt[7]_i_11_n_0 ,\j_cnt[7]_i_12_n_0 ,\j_cnt[7]_i_13_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_40 
       (.CI(\j_cnt_reg[7]_i_77_n_0 ),
        .CO({\j_cnt_reg[7]_i_40_n_0 ,\j_cnt_reg[7]_i_40_n_1 ,\j_cnt_reg[7]_i_40_n_2 ,\j_cnt_reg[7]_i_40_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\j_cnt_reg[7]_i_32_n_5 ,\j_cnt_reg[7]_i_32_n_6 ,\j_cnt_reg[7]_i_32_n_7 ,\j_cnt_reg[7]_i_62_n_4 }),
        .O({\j_cnt_reg[7]_i_40_n_4 ,\j_cnt_reg[7]_i_40_n_5 ,\j_cnt_reg[7]_i_40_n_6 ,\j_cnt_reg[7]_i_40_n_7 }),
        .S({\j_cnt[7]_i_78_n_0 ,\j_cnt[7]_i_79_n_0 ,\j_cnt[7]_i_80_n_0 ,\j_cnt[7]_i_81_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_43 
       (.CI(\<const0> ),
        .CO({\j_cnt_reg[7]_i_43_n_0 ,\j_cnt_reg[7]_i_43_n_1 ,\j_cnt_reg[7]_i_43_n_2 ,\j_cnt_reg[7]_i_43_n_3 }),
        .CYINIT(\j_cnt[7]_i_82_n_0 ),
        .DI({\j_cnt[7]_i_83_n_0 ,\len_reg_n_0_[1] ,\j_cnt[7]_i_84_n_0 ,\j_cnt[7]_i_85_n_0 }),
        .O({\j_cnt_reg[7]_i_43_n_4 ,\j_cnt_reg[7]_i_43_n_5 ,\j_cnt_reg[7]_i_43_n_6 ,\j_cnt_reg[7]_i_43_n_7 }),
        .S({\j_cnt[7]_i_86_n_0 ,\j_cnt[7]_i_87_n_0 ,\j_cnt[7]_i_88_n_0 ,\j_cnt[7]_i_89_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_52 
       (.CI(\<const0> ),
        .CO({\j_cnt_reg[7]_i_52_n_0 ,\j_cnt_reg[7]_i_52_n_1 ,\j_cnt_reg[7]_i_52_n_2 ,\j_cnt_reg[7]_i_52_n_3 }),
        .CYINIT(\j_cnt_reg[7]_i_14_n_3 ),
        .DI({\j_cnt_reg[7]_i_43_n_6 ,\j_cnt_reg[7]_i_43_n_7 ,\j_cnt[7]_i_92_n_0 ,\<const0> }),
        .O({\j_cnt_reg[7]_i_52_n_4 ,\j_cnt_reg[7]_i_52_n_5 ,\j_cnt_reg[7]_i_52_n_6 ,\NLW_j_cnt_reg[7]_i_52_O_UNCONNECTED [0]}),
        .S({\j_cnt[7]_i_93_n_0 ,\j_cnt[7]_i_94_n_0 ,\j_cnt[7]_i_95_n_0 ,\<const1> }));
  CARRY4 \j_cnt_reg[7]_i_57 
       (.CI(\<const0> ),
        .CO({\j_cnt_reg[7]_i_57_n_0 ,\j_cnt_reg[7]_i_57_n_1 ,\j_cnt_reg[7]_i_57_n_2 ,\j_cnt_reg[7]_i_57_n_3 }),
        .CYINIT(\j_cnt_reg[7]_i_16_n_2 ),
        .DI({\j_cnt_reg[7]_i_52_n_5 ,\j_cnt_reg[7]_i_52_n_6 ,\j_cnt[7]_i_96_n_0 ,\<const0> }),
        .O({\j_cnt_reg[7]_i_57_n_4 ,\j_cnt_reg[7]_i_57_n_5 ,\j_cnt_reg[7]_i_57_n_6 ,\NLW_j_cnt_reg[7]_i_57_O_UNCONNECTED [0]}),
        .S({\j_cnt[7]_i_97_n_0 ,\j_cnt[7]_i_98_n_0 ,\j_cnt[7]_i_99_n_0 ,\<const1> }));
  CARRY4 \j_cnt_reg[7]_i_62 
       (.CI(\<const0> ),
        .CO({\j_cnt_reg[7]_i_62_n_0 ,\j_cnt_reg[7]_i_62_n_1 ,\j_cnt_reg[7]_i_62_n_2 ,\j_cnt_reg[7]_i_62_n_3 }),
        .CYINIT(\j_cnt_reg[7]_i_19_n_2 ),
        .DI({\j_cnt_reg[7]_i_63_n_5 ,\j_cnt_reg[7]_i_63_n_6 ,\j_cnt[7]_i_100_n_0 ,\<const0> }),
        .O({\j_cnt_reg[7]_i_62_n_4 ,\j_cnt_reg[7]_i_62_n_5 ,\j_cnt_reg[7]_i_62_n_6 ,\NLW_j_cnt_reg[7]_i_62_O_UNCONNECTED [0]}),
        .S({\j_cnt[7]_i_101_n_0 ,\j_cnt[7]_i_102_n_0 ,\j_cnt[7]_i_103_n_0 ,\<const1> }));
  CARRY4 \j_cnt_reg[7]_i_63 
       (.CI(\<const0> ),
        .CO({\j_cnt_reg[7]_i_63_n_0 ,\j_cnt_reg[7]_i_63_n_1 ,\j_cnt_reg[7]_i_63_n_2 ,\j_cnt_reg[7]_i_63_n_3 }),
        .CYINIT(\j_cnt_reg[7]_i_17_n_2 ),
        .DI({\j_cnt_reg[7]_i_57_n_5 ,\j_cnt_reg[7]_i_57_n_6 ,\j_cnt[7]_i_104_n_0 ,\<const0> }),
        .O({\j_cnt_reg[7]_i_63_n_4 ,\j_cnt_reg[7]_i_63_n_5 ,\j_cnt_reg[7]_i_63_n_6 ,\NLW_j_cnt_reg[7]_i_63_O_UNCONNECTED [0]}),
        .S({\j_cnt[7]_i_105_n_0 ,\j_cnt[7]_i_106_n_0 ,\j_cnt[7]_i_107_n_0 ,\<const1> }));
  CARRY4 \j_cnt_reg[7]_i_72 
       (.CI(\<const0> ),
        .CO({\j_cnt_reg[7]_i_72_n_0 ,\j_cnt_reg[7]_i_72_n_1 ,\j_cnt_reg[7]_i_72_n_2 ,\j_cnt_reg[7]_i_72_n_3 }),
        .CYINIT(\j_cnt_reg[7]_i_21_n_2 ),
        .DI({\j_cnt_reg[7]_i_77_n_4 ,\j_cnt_reg[7]_i_77_n_5 ,\j_cnt_reg[7]_i_77_n_6 ,\j_cnt[7]_i_108_n_0 }),
        .S({\j_cnt[7]_i_109_n_0 ,\j_cnt[7]_i_110_n_0 ,\j_cnt[7]_i_111_n_0 ,\j_cnt[7]_i_112_n_0 }));
  CARRY4 \j_cnt_reg[7]_i_77 
       (.CI(\<const0> ),
        .CO({\j_cnt_reg[7]_i_77_n_0 ,\j_cnt_reg[7]_i_77_n_1 ,\j_cnt_reg[7]_i_77_n_2 ,\j_cnt_reg[7]_i_77_n_3 }),
        .CYINIT(\j_cnt_reg[7]_i_18_n_2 ),
        .DI({\j_cnt_reg[7]_i_62_n_5 ,\j_cnt_reg[7]_i_62_n_6 ,\j_cnt[7]_i_113_n_0 ,\<const0> }),
        .O({\j_cnt_reg[7]_i_77_n_4 ,\j_cnt_reg[7]_i_77_n_5 ,\j_cnt_reg[7]_i_77_n_6 ,\NLW_j_cnt_reg[7]_i_77_O_UNCONNECTED [0]}),
        .S({\j_cnt[7]_i_114_n_0 ,\j_cnt[7]_i_115_n_0 ,\j_cnt[7]_i_116_n_0 ,\<const1> }));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \layer_idx[0]_i_1 
       (.I0(state[2]),
        .I1(\layer_idx_reg_n_0_[0] ),
        .O(\layer_idx[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT3 #(
    .INIT(8'h60)) 
    \layer_idx[1]_i_1 
       (.I0(\layer_idx_reg_n_0_[0] ),
        .I1(\layer_idx_reg_n_0_[1] ),
        .I2(state[2]),
        .O(layer_idx[1]));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h7080)) 
    \layer_idx[2]_i_1 
       (.I0(\layer_idx_reg_n_0_[0] ),
        .I1(\layer_idx_reg_n_0_[1] ),
        .I2(state[2]),
        .I3(\layer_idx_reg_n_0_[2] ),
        .O(layer_idx[2]));
  FDCE \layer_idx_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(\layer_idx[0]_i_1_n_0 ),
        .Q(\layer_idx_reg_n_0_[0] ));
  FDCE \layer_idx_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(layer_idx[1]),
        .Q(\layer_idx_reg_n_0_[1] ));
  FDCE \layer_idx_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(layer_idx[2]),
        .Q(\layer_idx_reg_n_0_[2] ));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT3 #(
    .INIT(8'h20)) 
    \len[0]_i_1 
       (.I0(\len_reg_n_0_[1] ),
        .I1(inv_mode_reg_n_0),
        .I2(state[2]),
        .O(len[0]));
  LUT5 #(
    .INIT(32'hE2FFE200)) 
    \len[1]_i_1 
       (.I0(\len_reg_n_0_[2] ),
        .I1(inv_mode_reg_n_0),
        .I2(\len_reg_n_0_[0] ),
        .I3(state[2]),
        .I4(inverse_IBUF),
        .O(len[1]));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'hB080)) 
    \len[2]_i_1 
       (.I0(\len_reg_n_0_[1] ),
        .I1(inv_mode_reg_n_0),
        .I2(state[2]),
        .I3(\len_reg_n_0_[3] ),
        .O(len[2]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'hB080)) 
    \len[3]_i_1 
       (.I0(\len_reg_n_0_[2] ),
        .I1(inv_mode_reg_n_0),
        .I2(state[2]),
        .I3(\len_reg_n_0_[4] ),
        .O(len[3]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'hB080)) 
    \len[4]_i_1 
       (.I0(\len_reg_n_0_[3] ),
        .I1(inv_mode_reg_n_0),
        .I2(state[2]),
        .I3(\len_reg_n_0_[5] ),
        .O(len[4]));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT4 #(
    .INIT(16'hC480)) 
    \len[5]_i_1 
       (.I0(inv_mode_reg_n_0),
        .I1(state[2]),
        .I2(\len_reg_n_0_[4] ),
        .I3(\len_reg_n_0_[6] ),
        .O(len[5]));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT4 #(
    .INIT(16'hC480)) 
    \len[6]_i_1 
       (.I0(inv_mode_reg_n_0),
        .I1(state[2]),
        .I2(\len_reg_n_0_[5] ),
        .I3(\len_reg_n_0_[7] ),
        .O(len[6]));
  LUT6 #(
    .INIT(64'h0000000000002EEE)) 
    \len[7]_i_1 
       (.I0(start_IBUF),
        .I1(state[2]),
        .I2(\layer_idx_reg_n_0_[2] ),
        .I3(\layer_idx_reg_n_0_[1] ),
        .I4(state[1]),
        .I5(state[0]),
        .O(\len[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT4 #(
    .INIT(16'hC055)) 
    \len[7]_i_2 
       (.I0(inverse_IBUF),
        .I1(\len_reg_n_0_[6] ),
        .I2(inv_mode_reg_n_0),
        .I3(state[2]),
        .O(len[7]));
  LUT1 #(
    .INIT(2'h1)) 
    \len[7]_i_3 
       (.I0(rst_n_IBUF),
        .O(\len[7]_i_3_n_0 ));
  FDCE \len_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(len[0]),
        .Q(\len_reg_n_0_[0] ));
  FDCE \len_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(len[1]),
        .Q(\len_reg_n_0_[1] ));
  FDCE \len_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(len[2]),
        .Q(\len_reg_n_0_[2] ));
  FDCE \len_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(len[3]),
        .Q(\len_reg_n_0_[3] ));
  FDCE \len_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(len[4]),
        .Q(\len_reg_n_0_[4] ));
  FDCE \len_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(len[5]),
        .Q(\len_reg_n_0_[5] ));
  FDCE \len_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(len[6]),
        .Q(\len_reg_n_0_[6] ));
  FDCE \len_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\len[7]_i_3_n_0 ),
        .D(len[7]),
        .Q(\len_reg_n_0_[7] ));
  OBUF \read_data_OBUF[0]_inst 
       (.I(\<const0> ),
        .O(read_data[0]));
  OBUF \read_data_OBUF[10]_inst 
       (.I(\<const0> ),
        .O(read_data[10]));
  OBUF \read_data_OBUF[11]_inst 
       (.I(\<const0> ),
        .O(read_data[11]));
  OBUF \read_data_OBUF[12]_inst 
       (.I(\<const0> ),
        .O(read_data[12]));
  OBUF \read_data_OBUF[13]_inst 
       (.I(\<const0> ),
        .O(read_data[13]));
  OBUF \read_data_OBUF[14]_inst 
       (.I(\<const0> ),
        .O(read_data[14]));
  OBUF \read_data_OBUF[15]_inst 
       (.I(\<const0> ),
        .O(read_data[15]));
  OBUF \read_data_OBUF[1]_inst 
       (.I(\<const0> ),
        .O(read_data[1]));
  OBUF \read_data_OBUF[2]_inst 
       (.I(\<const0> ),
        .O(read_data[2]));
  OBUF \read_data_OBUF[3]_inst 
       (.I(\<const0> ),
        .O(read_data[3]));
  OBUF \read_data_OBUF[4]_inst 
       (.I(\<const0> ),
        .O(read_data[4]));
  OBUF \read_data_OBUF[5]_inst 
       (.I(\<const0> ),
        .O(read_data[5]));
  OBUF \read_data_OBUF[6]_inst 
       (.I(\<const0> ),
        .O(read_data[6]));
  OBUF \read_data_OBUF[7]_inst 
       (.I(\<const0> ),
        .O(read_data[7]));
  OBUF \read_data_OBUF[8]_inst 
       (.I(\<const0> ),
        .O(read_data[8]));
  OBUF \read_data_OBUF[9]_inst 
       (.I(\<const0> ),
        .O(read_data[9]));
  IBUF rst_n_IBUF_inst
       (.I(rst_n),
        .O(rst_n_IBUF));
  IBUF start_IBUF_inst
       (.I(start),
        .O(start_IBUF));
endmodule
