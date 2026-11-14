// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2026.1 (win64) Build 6511674 Tue Jun 16 11:02:23 MDT 2026
// Date        : Fri Oct 16 19:26:03 2026
// Host        : Yi running 64-bit major release  (build 9200)
// Command     : write_verilog -force -nolib C:/tmp_nttvar_1792149297/V4/reports/netlist.v
// Design      : kyber_ntt
// Purpose     : This is a Verilog netlist of the current design or from a specific cell of the design. The output is an
//               IEEE 1364-2001 compliant Verilog HDL file that contains netlist information obtained from the input
//               design files.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* BW = "16" *) (* N = "16" *) (* Q = "3329" *) 
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
  wire GND_2;
  wire VCC_2;
  wire a__0_i_10_n_0;
  wire a__0_i_11_n_0;
  wire a__0_i_12_n_0;
  wire a__0_i_13_n_0;
  wire a__0_i_14_n_0;
  wire a__0_i_15_n_0;
  wire a__0_i_16_n_0;
  wire a__0_i_17_n_0;
  wire a__0_i_18_n_0;
  wire a__0_i_19_n_0;
  wire a__0_i_1_n_1;
  wire a__0_i_1_n_2;
  wire a__0_i_1_n_3;
  wire a__0_i_20_n_0;
  wire a__0_i_2_n_0;
  wire a__0_i_2_n_1;
  wire a__0_i_2_n_2;
  wire a__0_i_2_n_3;
  wire a__0_i_3_n_0;
  wire a__0_i_3_n_1;
  wire a__0_i_3_n_2;
  wire a__0_i_3_n_3;
  wire a__0_i_4_n_0;
  wire a__0_i_4_n_1;
  wire a__0_i_4_n_2;
  wire a__0_i_4_n_3;
  wire a__0_i_5_n_0;
  wire a__0_i_6_n_0;
  wire a__0_i_7_n_0;
  wire a__0_i_8_n_0;
  wire a__0_i_9_n_0;
  wire a__0_n_100;
  wire a__0_n_101;
  wire a__0_n_102;
  wire a__0_n_103;
  wire a__0_n_104;
  wire a__0_n_105;
  wire a__0_n_74;
  wire a__0_n_75;
  wire a__0_n_76;
  wire a__0_n_77;
  wire a__0_n_78;
  wire a__0_n_79;
  wire a__0_n_80;
  wire a__0_n_81;
  wire a__0_n_82;
  wire a__0_n_83;
  wire a__0_n_84;
  wire a__0_n_85;
  wire a__0_n_86;
  wire a__0_n_87;
  wire a__0_n_88;
  wire a__0_n_89;
  wire a__0_n_90;
  wire a__0_n_91;
  wire a__0_n_92;
  wire a__0_n_93;
  wire a__0_n_94;
  wire a__0_n_95;
  wire a__0_n_96;
  wire a__0_n_97;
  wire a__0_n_98;
  wire a__0_n_99;
  wire a__1_n_77;
  wire a__1_n_78;
  wire a__1_n_79;
  wire a__1_n_80;
  wire a__1_n_81;
  wire a__1_n_82;
  wire a__1_n_83;
  wire a__1_n_84;
  wire a__1_n_85;
  wire a__1_n_86;
  wire a__1_n_87;
  wire a__1_n_88;
  wire a__1_n_89;
  wire [15:0]a__2;
  wire a_i_100_n_0;
  wire a_i_101_n_0;
  wire a_i_102_n_0;
  wire a_i_103_n_0;
  wire a_i_104_n_0;
  wire a_i_105_n_0;
  wire a_i_106_n_0;
  wire a_i_107_n_0;
  wire a_i_108_n_0;
  wire a_i_109_n_0;
  wire a_i_10_n_0;
  wire a_i_11_n_0;
  wire a_i_12_n_0;
  wire a_i_13_n_0;
  wire a_i_14_n_0;
  wire a_i_15_n_0;
  wire a_i_16_n_0;
  wire a_i_17_n_0;
  wire a_i_18_n_0;
  wire a_i_19_n_0;
  wire a_i_1_n_0;
  wire a_i_20_n_0;
  wire a_i_21_n_0;
  wire a_i_22_n_0;
  wire a_i_23_n_0;
  wire a_i_24_n_0;
  wire a_i_25_n_0;
  wire a_i_26_n_0;
  wire a_i_27_n_0;
  wire a_i_28_n_0;
  wire a_i_29_n_0;
  wire a_i_2_n_0;
  wire a_i_30_n_0;
  wire a_i_31_n_0;
  wire a_i_32_n_0;
  wire a_i_33_n_0;
  wire a_i_34_n_0;
  wire a_i_35_n_0;
  wire a_i_36_n_0;
  wire a_i_37_n_0;
  wire a_i_38_n_0;
  wire a_i_39_n_0;
  wire a_i_3_n_0;
  wire a_i_40_n_0;
  wire a_i_41_n_0;
  wire a_i_42_n_0;
  wire a_i_43_n_0;
  wire a_i_44_n_0;
  wire a_i_45_n_0;
  wire a_i_46_n_0;
  wire a_i_47_n_0;
  wire a_i_48_n_0;
  wire a_i_49_n_0;
  wire a_i_4_n_0;
  wire a_i_50_n_0;
  wire a_i_51_n_0;
  wire a_i_52_n_0;
  wire a_i_53_n_0;
  wire a_i_54_n_0;
  wire a_i_55_n_0;
  wire a_i_56_n_0;
  wire a_i_57_n_0;
  wire a_i_58_n_0;
  wire a_i_59_n_0;
  wire a_i_5_n_0;
  wire a_i_60_n_0;
  wire a_i_61_n_0;
  wire a_i_62_n_0;
  wire a_i_63_n_0;
  wire a_i_64_n_0;
  wire a_i_65_n_0;
  wire a_i_66_n_0;
  wire a_i_67_n_0;
  wire a_i_68_n_0;
  wire a_i_69_n_0;
  wire a_i_6_n_0;
  wire a_i_70_n_0;
  wire a_i_71_n_0;
  wire a_i_72_n_0;
  wire a_i_73_n_0;
  wire a_i_74_n_0;
  wire a_i_75_n_0;
  wire a_i_76_n_0;
  wire a_i_77_n_0;
  wire a_i_78_n_0;
  wire a_i_79_n_0;
  wire a_i_7_n_0;
  wire a_i_80_n_0;
  wire a_i_81_n_0;
  wire a_i_82_n_0;
  wire a_i_83_n_0;
  wire a_i_84_n_0;
  wire a_i_85_n_0;
  wire a_i_86_n_0;
  wire a_i_87_n_0;
  wire a_i_88_n_0;
  wire a_i_89_n_0;
  wire a_i_8_n_0;
  wire a_i_90_n_0;
  wire a_i_91_n_0;
  wire a_i_92_n_0;
  wire a_i_93_n_0;
  wire a_i_94_n_0;
  wire a_i_95_n_0;
  wire a_i_96_n_0;
  wire a_i_97_n_0;
  wire a_i_98_n_0;
  wire a_i_98_n_1;
  wire a_i_98_n_2;
  wire a_i_98_n_3;
  wire a_i_98_n_4;
  wire a_i_98_n_5;
  wire a_i_98_n_6;
  wire a_i_98_n_7;
  wire a_i_99_n_0;
  wire a_i_9_n_0;
  wire a_n_100;
  wire a_n_101;
  wire a_n_102;
  wire a_n_103;
  wire a_n_104;
  wire a_n_105;
  wire a_n_74;
  wire a_n_75;
  wire a_n_76;
  wire a_n_77;
  wire a_n_78;
  wire a_n_79;
  wire a_n_80;
  wire a_n_81;
  wire a_n_82;
  wire a_n_83;
  wire a_n_84;
  wire a_n_85;
  wire a_n_86;
  wire a_n_87;
  wire a_n_88;
  wire a_n_89;
  wire a_n_90;
  wire a_n_91;
  wire a_n_92;
  wire a_n_93;
  wire a_n_94;
  wire a_n_95;
  wire a_n_96;
  wire a_n_97;
  wire a_n_98;
  wire a_n_99;
  wire [15:0]barrett_reduce_return;
  wire [7:0]block_cnt;
  wire \block_cnt[1]_i_1_n_0 ;
  wire \block_cnt[2]_i_1_n_0 ;
  wire \block_cnt[3]_i_1_n_0 ;
  wire \block_cnt[4]_i_1_n_0 ;
  wire \block_cnt[5]_i_1_n_0 ;
  wire \block_cnt[6]_i_1_n_0 ;
  wire \block_cnt[7]_i_100_n_0 ;
  wire \block_cnt[7]_i_101_n_0 ;
  wire \block_cnt[7]_i_102_n_0 ;
  wire \block_cnt[7]_i_103_n_0 ;
  wire \block_cnt[7]_i_104_n_0 ;
  wire \block_cnt[7]_i_105_n_0 ;
  wire \block_cnt[7]_i_106_n_0 ;
  wire \block_cnt[7]_i_107_n_0 ;
  wire \block_cnt[7]_i_108_n_0 ;
  wire \block_cnt[7]_i_109_n_0 ;
  wire \block_cnt[7]_i_10_n_0 ;
  wire \block_cnt[7]_i_110_n_0 ;
  wire \block_cnt[7]_i_111_n_0 ;
  wire \block_cnt[7]_i_112_n_0 ;
  wire \block_cnt[7]_i_113_n_0 ;
  wire \block_cnt[7]_i_114_n_0 ;
  wire \block_cnt[7]_i_115_n_0 ;
  wire \block_cnt[7]_i_11_n_0 ;
  wire \block_cnt[7]_i_12_n_0 ;
  wire \block_cnt[7]_i_13_n_0 ;
  wire \block_cnt[7]_i_16_n_0 ;
  wire \block_cnt[7]_i_1_n_0 ;
  wire \block_cnt[7]_i_22_n_0 ;
  wire \block_cnt[7]_i_24_n_0 ;
  wire \block_cnt[7]_i_25_n_0 ;
  wire \block_cnt[7]_i_27_n_0 ;
  wire \block_cnt[7]_i_28_n_0 ;
  wire \block_cnt[7]_i_30_n_0 ;
  wire \block_cnt[7]_i_31_n_0 ;
  wire \block_cnt[7]_i_33_n_0 ;
  wire \block_cnt[7]_i_34_n_0 ;
  wire \block_cnt[7]_i_36_n_0 ;
  wire \block_cnt[7]_i_37_n_0 ;
  wire \block_cnt[7]_i_39_n_0 ;
  wire \block_cnt[7]_i_40_n_0 ;
  wire \block_cnt[7]_i_42_n_0 ;
  wire \block_cnt[7]_i_44_n_0 ;
  wire \block_cnt[7]_i_45_n_0 ;
  wire \block_cnt[7]_i_46_n_0 ;
  wire \block_cnt[7]_i_47_n_0 ;
  wire \block_cnt[7]_i_48_n_0 ;
  wire \block_cnt[7]_i_49_n_0 ;
  wire \block_cnt[7]_i_4_n_0 ;
  wire \block_cnt[7]_i_50_n_0 ;
  wire \block_cnt[7]_i_51_n_0 ;
  wire \block_cnt[7]_i_53_n_0 ;
  wire \block_cnt[7]_i_54_n_0 ;
  wire \block_cnt[7]_i_55_n_0 ;
  wire \block_cnt[7]_i_56_n_0 ;
  wire \block_cnt[7]_i_58_n_0 ;
  wire \block_cnt[7]_i_59_n_0 ;
  wire \block_cnt[7]_i_5_n_0 ;
  wire \block_cnt[7]_i_60_n_0 ;
  wire \block_cnt[7]_i_61_n_0 ;
  wire \block_cnt[7]_i_63_n_0 ;
  wire \block_cnt[7]_i_64_n_0 ;
  wire \block_cnt[7]_i_65_n_0 ;
  wire \block_cnt[7]_i_66_n_0 ;
  wire \block_cnt[7]_i_68_n_0 ;
  wire \block_cnt[7]_i_69_n_0 ;
  wire \block_cnt[7]_i_6_n_0 ;
  wire \block_cnt[7]_i_70_n_0 ;
  wire \block_cnt[7]_i_71_n_0 ;
  wire \block_cnt[7]_i_73_n_0 ;
  wire \block_cnt[7]_i_74_n_0 ;
  wire \block_cnt[7]_i_75_n_0 ;
  wire \block_cnt[7]_i_76_n_0 ;
  wire \block_cnt[7]_i_78_n_0 ;
  wire \block_cnt[7]_i_79_n_0 ;
  wire \block_cnt[7]_i_7_n_0 ;
  wire \block_cnt[7]_i_80_n_0 ;
  wire \block_cnt[7]_i_81_n_0 ;
  wire \block_cnt[7]_i_82_n_0 ;
  wire \block_cnt[7]_i_83_n_0 ;
  wire \block_cnt[7]_i_84_n_0 ;
  wire \block_cnt[7]_i_85_n_0 ;
  wire \block_cnt[7]_i_86_n_0 ;
  wire \block_cnt[7]_i_87_n_0 ;
  wire \block_cnt[7]_i_88_n_0 ;
  wire \block_cnt[7]_i_89_n_0 ;
  wire \block_cnt[7]_i_8_n_0 ;
  wire \block_cnt[7]_i_90_n_0 ;
  wire \block_cnt[7]_i_91_n_0 ;
  wire \block_cnt[7]_i_92_n_0 ;
  wire \block_cnt[7]_i_93_n_0 ;
  wire \block_cnt[7]_i_94_n_0 ;
  wire \block_cnt[7]_i_95_n_0 ;
  wire \block_cnt[7]_i_96_n_0 ;
  wire \block_cnt[7]_i_97_n_0 ;
  wire \block_cnt[7]_i_98_n_0 ;
  wire \block_cnt[7]_i_99_n_0 ;
  wire \block_cnt[7]_i_9_n_0 ;
  wire \block_cnt_reg[7]_i_14_n_3 ;
  wire \block_cnt_reg[7]_i_15_n_2 ;
  wire \block_cnt_reg[7]_i_15_n_3 ;
  wire \block_cnt_reg[7]_i_15_n_7 ;
  wire \block_cnt_reg[7]_i_17_n_2 ;
  wire \block_cnt_reg[7]_i_17_n_3 ;
  wire \block_cnt_reg[7]_i_17_n_7 ;
  wire \block_cnt_reg[7]_i_18_n_2 ;
  wire \block_cnt_reg[7]_i_18_n_3 ;
  wire \block_cnt_reg[7]_i_18_n_7 ;
  wire \block_cnt_reg[7]_i_19_n_2 ;
  wire \block_cnt_reg[7]_i_19_n_3 ;
  wire \block_cnt_reg[7]_i_19_n_7 ;
  wire \block_cnt_reg[7]_i_20_n_2 ;
  wire \block_cnt_reg[7]_i_20_n_3 ;
  wire \block_cnt_reg[7]_i_20_n_7 ;
  wire \block_cnt_reg[7]_i_21_n_3 ;
  wire \block_cnt_reg[7]_i_23_n_0 ;
  wire \block_cnt_reg[7]_i_23_n_1 ;
  wire \block_cnt_reg[7]_i_23_n_2 ;
  wire \block_cnt_reg[7]_i_23_n_3 ;
  wire \block_cnt_reg[7]_i_23_n_4 ;
  wire \block_cnt_reg[7]_i_23_n_5 ;
  wire \block_cnt_reg[7]_i_23_n_6 ;
  wire \block_cnt_reg[7]_i_23_n_7 ;
  wire \block_cnt_reg[7]_i_26_n_0 ;
  wire \block_cnt_reg[7]_i_26_n_1 ;
  wire \block_cnt_reg[7]_i_26_n_2 ;
  wire \block_cnt_reg[7]_i_26_n_3 ;
  wire \block_cnt_reg[7]_i_26_n_4 ;
  wire \block_cnt_reg[7]_i_26_n_5 ;
  wire \block_cnt_reg[7]_i_26_n_6 ;
  wire \block_cnt_reg[7]_i_26_n_7 ;
  wire \block_cnt_reg[7]_i_29_n_0 ;
  wire \block_cnt_reg[7]_i_29_n_1 ;
  wire \block_cnt_reg[7]_i_29_n_2 ;
  wire \block_cnt_reg[7]_i_29_n_3 ;
  wire \block_cnt_reg[7]_i_29_n_4 ;
  wire \block_cnt_reg[7]_i_29_n_5 ;
  wire \block_cnt_reg[7]_i_29_n_6 ;
  wire \block_cnt_reg[7]_i_29_n_7 ;
  wire \block_cnt_reg[7]_i_32_n_0 ;
  wire \block_cnt_reg[7]_i_32_n_1 ;
  wire \block_cnt_reg[7]_i_32_n_2 ;
  wire \block_cnt_reg[7]_i_32_n_3 ;
  wire \block_cnt_reg[7]_i_32_n_4 ;
  wire \block_cnt_reg[7]_i_32_n_5 ;
  wire \block_cnt_reg[7]_i_32_n_6 ;
  wire \block_cnt_reg[7]_i_32_n_7 ;
  wire \block_cnt_reg[7]_i_35_n_0 ;
  wire \block_cnt_reg[7]_i_35_n_1 ;
  wire \block_cnt_reg[7]_i_35_n_2 ;
  wire \block_cnt_reg[7]_i_35_n_3 ;
  wire \block_cnt_reg[7]_i_35_n_4 ;
  wire \block_cnt_reg[7]_i_35_n_5 ;
  wire \block_cnt_reg[7]_i_35_n_6 ;
  wire \block_cnt_reg[7]_i_35_n_7 ;
  wire \block_cnt_reg[7]_i_38_n_0 ;
  wire \block_cnt_reg[7]_i_38_n_1 ;
  wire \block_cnt_reg[7]_i_38_n_2 ;
  wire \block_cnt_reg[7]_i_38_n_3 ;
  wire \block_cnt_reg[7]_i_38_n_4 ;
  wire \block_cnt_reg[7]_i_38_n_5 ;
  wire \block_cnt_reg[7]_i_38_n_6 ;
  wire \block_cnt_reg[7]_i_38_n_7 ;
  wire \block_cnt_reg[7]_i_3_n_0 ;
  wire \block_cnt_reg[7]_i_3_n_1 ;
  wire \block_cnt_reg[7]_i_3_n_2 ;
  wire \block_cnt_reg[7]_i_3_n_3 ;
  wire \block_cnt_reg[7]_i_41_n_0 ;
  wire \block_cnt_reg[7]_i_41_n_1 ;
  wire \block_cnt_reg[7]_i_41_n_2 ;
  wire \block_cnt_reg[7]_i_41_n_3 ;
  wire \block_cnt_reg[7]_i_43_n_0 ;
  wire \block_cnt_reg[7]_i_43_n_1 ;
  wire \block_cnt_reg[7]_i_43_n_2 ;
  wire \block_cnt_reg[7]_i_43_n_3 ;
  wire \block_cnt_reg[7]_i_43_n_4 ;
  wire \block_cnt_reg[7]_i_43_n_5 ;
  wire \block_cnt_reg[7]_i_43_n_6 ;
  wire \block_cnt_reg[7]_i_43_n_7 ;
  wire \block_cnt_reg[7]_i_52_n_0 ;
  wire \block_cnt_reg[7]_i_52_n_1 ;
  wire \block_cnt_reg[7]_i_52_n_2 ;
  wire \block_cnt_reg[7]_i_52_n_3 ;
  wire \block_cnt_reg[7]_i_52_n_4 ;
  wire \block_cnt_reg[7]_i_52_n_5 ;
  wire \block_cnt_reg[7]_i_52_n_6 ;
  wire \block_cnt_reg[7]_i_57_n_0 ;
  wire \block_cnt_reg[7]_i_57_n_1 ;
  wire \block_cnt_reg[7]_i_57_n_2 ;
  wire \block_cnt_reg[7]_i_57_n_3 ;
  wire \block_cnt_reg[7]_i_57_n_4 ;
  wire \block_cnt_reg[7]_i_57_n_5 ;
  wire \block_cnt_reg[7]_i_57_n_6 ;
  wire \block_cnt_reg[7]_i_62_n_0 ;
  wire \block_cnt_reg[7]_i_62_n_1 ;
  wire \block_cnt_reg[7]_i_62_n_2 ;
  wire \block_cnt_reg[7]_i_62_n_3 ;
  wire \block_cnt_reg[7]_i_62_n_4 ;
  wire \block_cnt_reg[7]_i_62_n_5 ;
  wire \block_cnt_reg[7]_i_62_n_6 ;
  wire \block_cnt_reg[7]_i_67_n_0 ;
  wire \block_cnt_reg[7]_i_67_n_1 ;
  wire \block_cnt_reg[7]_i_67_n_2 ;
  wire \block_cnt_reg[7]_i_67_n_3 ;
  wire \block_cnt_reg[7]_i_67_n_4 ;
  wire \block_cnt_reg[7]_i_67_n_5 ;
  wire \block_cnt_reg[7]_i_67_n_6 ;
  wire \block_cnt_reg[7]_i_72_n_0 ;
  wire \block_cnt_reg[7]_i_72_n_1 ;
  wire \block_cnt_reg[7]_i_72_n_2 ;
  wire \block_cnt_reg[7]_i_72_n_3 ;
  wire \block_cnt_reg[7]_i_72_n_4 ;
  wire \block_cnt_reg[7]_i_72_n_5 ;
  wire \block_cnt_reg[7]_i_72_n_6 ;
  wire \block_cnt_reg[7]_i_77_n_0 ;
  wire \block_cnt_reg[7]_i_77_n_1 ;
  wire \block_cnt_reg[7]_i_77_n_2 ;
  wire \block_cnt_reg[7]_i_77_n_3 ;
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
  wire [1:0]cnt;
  wire \cnt[2]_i_1_n_0 ;
  wire \cnt[3]_i_1_n_0 ;
  wire \cnt[4]_i_1_n_0 ;
  wire \cnt[4]_i_2_n_0 ;
  wire \cnt[4]_i_3_n_0 ;
  wire \cnt_reg_n_0_[0] ;
  wire \cnt_reg_n_0_[1] ;
  wire \cnt_reg_n_0_[2] ;
  wire \cnt_reg_n_0_[3] ;
  wire \cnt_reg_n_0_[4] ;
  wire [15:0]coeff;
  wire \coeff[0][0]_i_2_n_0 ;
  wire \coeff[0][0]_i_3_n_0 ;
  wire \coeff[0][0]_i_4_n_0 ;
  wire \coeff[0][0]_i_5_n_0 ;
  wire \coeff[0][0]_i_6_n_0 ;
  wire \coeff[0][0]_i_7_n_0 ;
  wire \coeff[0][10]_i_2_n_0 ;
  wire \coeff[0][10]_i_3_n_0 ;
  wire \coeff[0][10]_i_4_n_0 ;
  wire \coeff[0][10]_i_5_n_0 ;
  wire \coeff[0][10]_i_6_n_0 ;
  wire \coeff[0][10]_i_7_n_0 ;
  wire \coeff[0][11]_i_11_n_0 ;
  wire \coeff[0][11]_i_12_n_0 ;
  wire \coeff[0][11]_i_13_n_0 ;
  wire \coeff[0][11]_i_14_n_0 ;
  wire \coeff[0][11]_i_15_n_0 ;
  wire \coeff[0][11]_i_16_n_0 ;
  wire \coeff[0][11]_i_17_n_0 ;
  wire \coeff[0][11]_i_18_n_0 ;
  wire \coeff[0][11]_i_20_n_0 ;
  wire \coeff[0][11]_i_21_n_0 ;
  wire \coeff[0][11]_i_22_n_0 ;
  wire \coeff[0][11]_i_23_n_0 ;
  wire \coeff[0][11]_i_24_n_0 ;
  wire \coeff[0][11]_i_25_n_0 ;
  wire \coeff[0][11]_i_26_n_0 ;
  wire \coeff[0][11]_i_27_n_0 ;
  wire \coeff[0][11]_i_28_n_0 ;
  wire \coeff[0][11]_i_29_n_0 ;
  wire \coeff[0][11]_i_2_n_0 ;
  wire \coeff[0][11]_i_30_n_0 ;
  wire \coeff[0][11]_i_31_n_0 ;
  wire \coeff[0][11]_i_3_n_0 ;
  wire \coeff[0][11]_i_4_n_0 ;
  wire \coeff[0][11]_i_5_n_0 ;
  wire \coeff[0][11]_i_8_n_0 ;
  wire \coeff[0][11]_i_9_n_0 ;
  wire \coeff[0][12]_i_2_n_0 ;
  wire \coeff[0][12]_i_3_n_0 ;
  wire \coeff[0][12]_i_4_n_0 ;
  wire \coeff[0][12]_i_5_n_0 ;
  wire \coeff[0][12]_i_6_n_0 ;
  wire \coeff[0][12]_i_7_n_0 ;
  wire \coeff[0][13]_i_2_n_0 ;
  wire \coeff[0][13]_i_3_n_0 ;
  wire \coeff[0][13]_i_4_n_0 ;
  wire \coeff[0][13]_i_5_n_0 ;
  wire \coeff[0][13]_i_6_n_0 ;
  wire \coeff[0][13]_i_7_n_0 ;
  wire \coeff[0][14]_i_2_n_0 ;
  wire \coeff[0][14]_i_3_n_0 ;
  wire \coeff[0][14]_i_4_n_0 ;
  wire \coeff[0][14]_i_5_n_0 ;
  wire \coeff[0][14]_i_6_n_0 ;
  wire \coeff[0][14]_i_7_n_0 ;
  wire \coeff[0][15]_i_10_n_0 ;
  wire \coeff[0][15]_i_11_n_0 ;
  wire \coeff[0][15]_i_12_n_0 ;
  wire \coeff[0][15]_i_15_n_0 ;
  wire \coeff[0][15]_i_16_n_0 ;
  wire \coeff[0][15]_i_19_n_0 ;
  wire \coeff[0][15]_i_1_n_0 ;
  wire \coeff[0][15]_i_20_n_0 ;
  wire \coeff[0][15]_i_23_n_0 ;
  wire \coeff[0][15]_i_24_n_0 ;
  wire \coeff[0][15]_i_25_n_0 ;
  wire \coeff[0][15]_i_26_n_0 ;
  wire \coeff[0][15]_i_27_n_0 ;
  wire \coeff[0][15]_i_28_n_0 ;
  wire \coeff[0][15]_i_29_n_0 ;
  wire \coeff[0][15]_i_30_n_0 ;
  wire \coeff[0][15]_i_33_n_0 ;
  wire \coeff[0][15]_i_34_n_0 ;
  wire \coeff[0][15]_i_35_n_0 ;
  wire \coeff[0][15]_i_36_n_0 ;
  wire \coeff[0][15]_i_37_n_0 ;
  wire \coeff[0][15]_i_38_n_0 ;
  wire \coeff[0][15]_i_39_n_0 ;
  wire \coeff[0][15]_i_3_n_0 ;
  wire \coeff[0][15]_i_40_n_0 ;
  wire \coeff[0][15]_i_42_n_0 ;
  wire \coeff[0][15]_i_43_n_0 ;
  wire \coeff[0][15]_i_44_n_0 ;
  wire \coeff[0][15]_i_45_n_0 ;
  wire \coeff[0][15]_i_47_n_0 ;
  wire \coeff[0][15]_i_48_n_0 ;
  wire \coeff[0][15]_i_49_n_0 ;
  wire \coeff[0][15]_i_4_n_0 ;
  wire \coeff[0][15]_i_50_n_0 ;
  wire \coeff[0][15]_i_51_n_0 ;
  wire \coeff[0][15]_i_52_n_0 ;
  wire \coeff[0][15]_i_53_n_0 ;
  wire \coeff[0][15]_i_54_n_0 ;
  wire \coeff[0][15]_i_55_n_0 ;
  wire \coeff[0][15]_i_56_n_0 ;
  wire \coeff[0][15]_i_57_n_0 ;
  wire \coeff[0][15]_i_58_n_0 ;
  wire \coeff[0][15]_i_59_n_0 ;
  wire \coeff[0][15]_i_5_n_0 ;
  wire \coeff[0][15]_i_60_n_0 ;
  wire \coeff[0][15]_i_61_n_0 ;
  wire \coeff[0][15]_i_62_n_0 ;
  wire \coeff[0][15]_i_63_n_0 ;
  wire \coeff[0][15]_i_64_n_0 ;
  wire \coeff[0][15]_i_65_n_0 ;
  wire \coeff[0][15]_i_68_n_0 ;
  wire \coeff[0][15]_i_69_n_0 ;
  wire \coeff[0][15]_i_6_n_0 ;
  wire \coeff[0][15]_i_70_n_0 ;
  wire \coeff[0][15]_i_71_n_0 ;
  wire \coeff[0][15]_i_72_n_0 ;
  wire \coeff[0][15]_i_73_n_0 ;
  wire \coeff[0][15]_i_74_n_0 ;
  wire \coeff[0][15]_i_75_n_0 ;
  wire \coeff[0][15]_i_76_n_0 ;
  wire \coeff[0][15]_i_77_n_0 ;
  wire \coeff[0][15]_i_78_n_0 ;
  wire \coeff[0][15]_i_79_n_0 ;
  wire \coeff[0][15]_i_7_n_0 ;
  wire \coeff[0][15]_i_80_n_0 ;
  wire \coeff[0][15]_i_82_n_0 ;
  wire \coeff[0][15]_i_83_n_0 ;
  wire \coeff[0][15]_i_84_n_0 ;
  wire \coeff[0][15]_i_85_n_0 ;
  wire \coeff[0][15]_i_86_n_0 ;
  wire \coeff[0][15]_i_8_n_0 ;
  wire \coeff[0][15]_i_9_n_0 ;
  wire \coeff[0][1]_i_2_n_0 ;
  wire \coeff[0][1]_i_3_n_0 ;
  wire \coeff[0][1]_i_4_n_0 ;
  wire \coeff[0][1]_i_5_n_0 ;
  wire \coeff[0][1]_i_6_n_0 ;
  wire \coeff[0][1]_i_7_n_0 ;
  wire \coeff[0][2]_i_2_n_0 ;
  wire \coeff[0][2]_i_3_n_0 ;
  wire \coeff[0][2]_i_4_n_0 ;
  wire \coeff[0][2]_i_5_n_0 ;
  wire \coeff[0][2]_i_6_n_0 ;
  wire \coeff[0][2]_i_7_n_0 ;
  wire \coeff[0][3]_i_11_n_0 ;
  wire \coeff[0][3]_i_12_n_0 ;
  wire \coeff[0][3]_i_13_n_0 ;
  wire \coeff[0][3]_i_14_n_0 ;
  wire \coeff[0][3]_i_15_n_0 ;
  wire \coeff[0][3]_i_16_n_0 ;
  wire \coeff[0][3]_i_17_n_0 ;
  wire \coeff[0][3]_i_18_n_0 ;
  wire \coeff[0][3]_i_20_n_0 ;
  wire \coeff[0][3]_i_21_n_0 ;
  wire \coeff[0][3]_i_22_n_0 ;
  wire \coeff[0][3]_i_23_n_0 ;
  wire \coeff[0][3]_i_24_n_0 ;
  wire \coeff[0][3]_i_25_n_0 ;
  wire \coeff[0][3]_i_26_n_0 ;
  wire \coeff[0][3]_i_27_n_0 ;
  wire \coeff[0][3]_i_28_n_0 ;
  wire \coeff[0][3]_i_29_n_0 ;
  wire \coeff[0][3]_i_2_n_0 ;
  wire \coeff[0][3]_i_30_n_0 ;
  wire \coeff[0][3]_i_31_n_0 ;
  wire \coeff[0][3]_i_3_n_0 ;
  wire \coeff[0][3]_i_4_n_0 ;
  wire \coeff[0][3]_i_5_n_0 ;
  wire \coeff[0][3]_i_8_n_0 ;
  wire \coeff[0][3]_i_9_n_0 ;
  wire \coeff[0][4]_i_2_n_0 ;
  wire \coeff[0][4]_i_3_n_0 ;
  wire \coeff[0][4]_i_4_n_0 ;
  wire \coeff[0][4]_i_5_n_0 ;
  wire \coeff[0][4]_i_6_n_0 ;
  wire \coeff[0][4]_i_7_n_0 ;
  wire \coeff[0][5]_i_2_n_0 ;
  wire \coeff[0][5]_i_3_n_0 ;
  wire \coeff[0][5]_i_4_n_0 ;
  wire \coeff[0][5]_i_5_n_0 ;
  wire \coeff[0][5]_i_6_n_0 ;
  wire \coeff[0][5]_i_7_n_0 ;
  wire \coeff[0][6]_i_2_n_0 ;
  wire \coeff[0][6]_i_3_n_0 ;
  wire \coeff[0][6]_i_4_n_0 ;
  wire \coeff[0][6]_i_5_n_0 ;
  wire \coeff[0][6]_i_6_n_0 ;
  wire \coeff[0][6]_i_7_n_0 ;
  wire \coeff[0][7]_i_11_n_0 ;
  wire \coeff[0][7]_i_12_n_0 ;
  wire \coeff[0][7]_i_13_n_0 ;
  wire \coeff[0][7]_i_14_n_0 ;
  wire \coeff[0][7]_i_15_n_0 ;
  wire \coeff[0][7]_i_16_n_0 ;
  wire \coeff[0][7]_i_17_n_0 ;
  wire \coeff[0][7]_i_18_n_0 ;
  wire \coeff[0][7]_i_20_n_0 ;
  wire \coeff[0][7]_i_21_n_0 ;
  wire \coeff[0][7]_i_22_n_0 ;
  wire \coeff[0][7]_i_23_n_0 ;
  wire \coeff[0][7]_i_24_n_0 ;
  wire \coeff[0][7]_i_25_n_0 ;
  wire \coeff[0][7]_i_26_n_0 ;
  wire \coeff[0][7]_i_27_n_0 ;
  wire \coeff[0][7]_i_28_n_0 ;
  wire \coeff[0][7]_i_29_n_0 ;
  wire \coeff[0][7]_i_2_n_0 ;
  wire \coeff[0][7]_i_30_n_0 ;
  wire \coeff[0][7]_i_31_n_0 ;
  wire \coeff[0][7]_i_3_n_0 ;
  wire \coeff[0][7]_i_4_n_0 ;
  wire \coeff[0][7]_i_5_n_0 ;
  wire \coeff[0][7]_i_8_n_0 ;
  wire \coeff[0][7]_i_9_n_0 ;
  wire \coeff[0][8]_i_2_n_0 ;
  wire \coeff[0][8]_i_3_n_0 ;
  wire \coeff[0][8]_i_4_n_0 ;
  wire \coeff[0][8]_i_5_n_0 ;
  wire \coeff[0][8]_i_6_n_0 ;
  wire \coeff[0][8]_i_7_n_0 ;
  wire \coeff[0][9]_i_2_n_0 ;
  wire \coeff[0][9]_i_3_n_0 ;
  wire \coeff[0][9]_i_4_n_0 ;
  wire \coeff[0][9]_i_5_n_0 ;
  wire \coeff[0][9]_i_6_n_0 ;
  wire \coeff[0][9]_i_7_n_0 ;
  wire \coeff[10][0]_i_1_n_0 ;
  wire \coeff[10][0]_i_2_n_0 ;
  wire \coeff[10][0]_i_3_n_0 ;
  wire \coeff[10][10]_i_1_n_0 ;
  wire \coeff[10][10]_i_2_n_0 ;
  wire \coeff[10][10]_i_3_n_0 ;
  wire \coeff[10][11]_i_1_n_0 ;
  wire \coeff[10][11]_i_2_n_0 ;
  wire \coeff[10][11]_i_3_n_0 ;
  wire \coeff[10][12]_i_1_n_0 ;
  wire \coeff[10][12]_i_2_n_0 ;
  wire \coeff[10][12]_i_3_n_0 ;
  wire \coeff[10][13]_i_1_n_0 ;
  wire \coeff[10][13]_i_2_n_0 ;
  wire \coeff[10][13]_i_3_n_0 ;
  wire \coeff[10][14]_i_1_n_0 ;
  wire \coeff[10][14]_i_2_n_0 ;
  wire \coeff[10][14]_i_3_n_0 ;
  wire \coeff[10][15]_i_1_n_0 ;
  wire \coeff[10][15]_i_2_n_0 ;
  wire \coeff[10][15]_i_3_n_0 ;
  wire \coeff[10][15]_i_4_n_0 ;
  wire \coeff[10][15]_i_5_n_0 ;
  wire \coeff[10][15]_i_6_n_0 ;
  wire \coeff[10][15]_i_7_n_0 ;
  wire \coeff[10][15]_i_8_n_0 ;
  wire \coeff[10][1]_i_1_n_0 ;
  wire \coeff[10][1]_i_2_n_0 ;
  wire \coeff[10][1]_i_3_n_0 ;
  wire \coeff[10][2]_i_1_n_0 ;
  wire \coeff[10][2]_i_2_n_0 ;
  wire \coeff[10][2]_i_3_n_0 ;
  wire \coeff[10][3]_i_1_n_0 ;
  wire \coeff[10][3]_i_2_n_0 ;
  wire \coeff[10][3]_i_3_n_0 ;
  wire \coeff[10][4]_i_1_n_0 ;
  wire \coeff[10][4]_i_2_n_0 ;
  wire \coeff[10][4]_i_3_n_0 ;
  wire \coeff[10][5]_i_1_n_0 ;
  wire \coeff[10][5]_i_2_n_0 ;
  wire \coeff[10][5]_i_3_n_0 ;
  wire \coeff[10][6]_i_1_n_0 ;
  wire \coeff[10][6]_i_2_n_0 ;
  wire \coeff[10][6]_i_3_n_0 ;
  wire \coeff[10][7]_i_1_n_0 ;
  wire \coeff[10][7]_i_2_n_0 ;
  wire \coeff[10][7]_i_3_n_0 ;
  wire \coeff[10][8]_i_1_n_0 ;
  wire \coeff[10][8]_i_2_n_0 ;
  wire \coeff[10][8]_i_3_n_0 ;
  wire \coeff[10][9]_i_1_n_0 ;
  wire \coeff[10][9]_i_2_n_0 ;
  wire \coeff[10][9]_i_3_n_0 ;
  wire \coeff[11][0]_i_1_n_0 ;
  wire \coeff[11][0]_i_2_n_0 ;
  wire \coeff[11][0]_i_3_n_0 ;
  wire \coeff[11][10]_i_1_n_0 ;
  wire \coeff[11][10]_i_2_n_0 ;
  wire \coeff[11][10]_i_3_n_0 ;
  wire \coeff[11][11]_i_1_n_0 ;
  wire \coeff[11][11]_i_2_n_0 ;
  wire \coeff[11][11]_i_3_n_0 ;
  wire \coeff[11][12]_i_1_n_0 ;
  wire \coeff[11][12]_i_2_n_0 ;
  wire \coeff[11][12]_i_3_n_0 ;
  wire \coeff[11][13]_i_1_n_0 ;
  wire \coeff[11][13]_i_2_n_0 ;
  wire \coeff[11][13]_i_3_n_0 ;
  wire \coeff[11][14]_i_1_n_0 ;
  wire \coeff[11][14]_i_2_n_0 ;
  wire \coeff[11][14]_i_3_n_0 ;
  wire \coeff[11][15]_i_1_n_0 ;
  wire \coeff[11][15]_i_2_n_0 ;
  wire \coeff[11][15]_i_3_n_0 ;
  wire \coeff[11][15]_i_4_n_0 ;
  wire \coeff[11][15]_i_5_n_0 ;
  wire \coeff[11][15]_i_6_n_0 ;
  wire \coeff[11][15]_i_7_n_0 ;
  wire \coeff[11][15]_i_8_n_0 ;
  wire \coeff[11][1]_i_1_n_0 ;
  wire \coeff[11][1]_i_2_n_0 ;
  wire \coeff[11][1]_i_3_n_0 ;
  wire \coeff[11][2]_i_1_n_0 ;
  wire \coeff[11][2]_i_2_n_0 ;
  wire \coeff[11][2]_i_3_n_0 ;
  wire \coeff[11][3]_i_1_n_0 ;
  wire \coeff[11][3]_i_2_n_0 ;
  wire \coeff[11][3]_i_3_n_0 ;
  wire \coeff[11][4]_i_1_n_0 ;
  wire \coeff[11][4]_i_2_n_0 ;
  wire \coeff[11][4]_i_3_n_0 ;
  wire \coeff[11][5]_i_1_n_0 ;
  wire \coeff[11][5]_i_2_n_0 ;
  wire \coeff[11][5]_i_3_n_0 ;
  wire \coeff[11][6]_i_1_n_0 ;
  wire \coeff[11][6]_i_2_n_0 ;
  wire \coeff[11][6]_i_3_n_0 ;
  wire \coeff[11][7]_i_1_n_0 ;
  wire \coeff[11][7]_i_2_n_0 ;
  wire \coeff[11][7]_i_3_n_0 ;
  wire \coeff[11][8]_i_1_n_0 ;
  wire \coeff[11][8]_i_2_n_0 ;
  wire \coeff[11][8]_i_3_n_0 ;
  wire \coeff[11][9]_i_1_n_0 ;
  wire \coeff[11][9]_i_2_n_0 ;
  wire \coeff[11][9]_i_3_n_0 ;
  wire \coeff[12][0]_i_1_n_0 ;
  wire \coeff[12][0]_i_2_n_0 ;
  wire \coeff[12][0]_i_3_n_0 ;
  wire \coeff[12][10]_i_1_n_0 ;
  wire \coeff[12][10]_i_2_n_0 ;
  wire \coeff[12][10]_i_3_n_0 ;
  wire \coeff[12][11]_i_1_n_0 ;
  wire \coeff[12][11]_i_2_n_0 ;
  wire \coeff[12][11]_i_3_n_0 ;
  wire \coeff[12][12]_i_1_n_0 ;
  wire \coeff[12][12]_i_2_n_0 ;
  wire \coeff[12][12]_i_3_n_0 ;
  wire \coeff[12][13]_i_1_n_0 ;
  wire \coeff[12][13]_i_2_n_0 ;
  wire \coeff[12][13]_i_3_n_0 ;
  wire \coeff[12][14]_i_1_n_0 ;
  wire \coeff[12][14]_i_2_n_0 ;
  wire \coeff[12][14]_i_3_n_0 ;
  wire \coeff[12][15]_i_1_n_0 ;
  wire \coeff[12][15]_i_2_n_0 ;
  wire \coeff[12][15]_i_3_n_0 ;
  wire \coeff[12][15]_i_4_n_0 ;
  wire \coeff[12][15]_i_5_n_0 ;
  wire \coeff[12][15]_i_6_n_0 ;
  wire \coeff[12][15]_i_7_n_0 ;
  wire \coeff[12][15]_i_8_n_0 ;
  wire \coeff[12][1]_i_1_n_0 ;
  wire \coeff[12][1]_i_2_n_0 ;
  wire \coeff[12][1]_i_3_n_0 ;
  wire \coeff[12][2]_i_1_n_0 ;
  wire \coeff[12][2]_i_2_n_0 ;
  wire \coeff[12][2]_i_3_n_0 ;
  wire \coeff[12][3]_i_1_n_0 ;
  wire \coeff[12][3]_i_2_n_0 ;
  wire \coeff[12][3]_i_3_n_0 ;
  wire \coeff[12][4]_i_1_n_0 ;
  wire \coeff[12][4]_i_2_n_0 ;
  wire \coeff[12][4]_i_3_n_0 ;
  wire \coeff[12][5]_i_1_n_0 ;
  wire \coeff[12][5]_i_2_n_0 ;
  wire \coeff[12][5]_i_3_n_0 ;
  wire \coeff[12][6]_i_1_n_0 ;
  wire \coeff[12][6]_i_2_n_0 ;
  wire \coeff[12][6]_i_3_n_0 ;
  wire \coeff[12][7]_i_1_n_0 ;
  wire \coeff[12][7]_i_2_n_0 ;
  wire \coeff[12][7]_i_3_n_0 ;
  wire \coeff[12][8]_i_1_n_0 ;
  wire \coeff[12][8]_i_2_n_0 ;
  wire \coeff[12][8]_i_3_n_0 ;
  wire \coeff[12][9]_i_1_n_0 ;
  wire \coeff[12][9]_i_2_n_0 ;
  wire \coeff[12][9]_i_3_n_0 ;
  wire \coeff[13][0]_i_1_n_0 ;
  wire \coeff[13][0]_i_2_n_0 ;
  wire \coeff[13][0]_i_3_n_0 ;
  wire \coeff[13][10]_i_1_n_0 ;
  wire \coeff[13][10]_i_2_n_0 ;
  wire \coeff[13][10]_i_3_n_0 ;
  wire \coeff[13][11]_i_1_n_0 ;
  wire \coeff[13][11]_i_2_n_0 ;
  wire \coeff[13][11]_i_3_n_0 ;
  wire \coeff[13][12]_i_1_n_0 ;
  wire \coeff[13][12]_i_2_n_0 ;
  wire \coeff[13][12]_i_3_n_0 ;
  wire \coeff[13][13]_i_1_n_0 ;
  wire \coeff[13][13]_i_2_n_0 ;
  wire \coeff[13][13]_i_3_n_0 ;
  wire \coeff[13][14]_i_1_n_0 ;
  wire \coeff[13][14]_i_2_n_0 ;
  wire \coeff[13][14]_i_3_n_0 ;
  wire \coeff[13][15]_i_1_n_0 ;
  wire \coeff[13][15]_i_2_n_0 ;
  wire \coeff[13][15]_i_3_n_0 ;
  wire \coeff[13][15]_i_4_n_0 ;
  wire \coeff[13][15]_i_5_n_0 ;
  wire \coeff[13][15]_i_6_n_0 ;
  wire \coeff[13][15]_i_7_n_0 ;
  wire \coeff[13][15]_i_8_n_0 ;
  wire \coeff[13][1]_i_1_n_0 ;
  wire \coeff[13][1]_i_2_n_0 ;
  wire \coeff[13][1]_i_3_n_0 ;
  wire \coeff[13][2]_i_1_n_0 ;
  wire \coeff[13][2]_i_2_n_0 ;
  wire \coeff[13][2]_i_3_n_0 ;
  wire \coeff[13][3]_i_1_n_0 ;
  wire \coeff[13][3]_i_2_n_0 ;
  wire \coeff[13][3]_i_3_n_0 ;
  wire \coeff[13][4]_i_1_n_0 ;
  wire \coeff[13][4]_i_2_n_0 ;
  wire \coeff[13][4]_i_3_n_0 ;
  wire \coeff[13][5]_i_1_n_0 ;
  wire \coeff[13][5]_i_2_n_0 ;
  wire \coeff[13][5]_i_3_n_0 ;
  wire \coeff[13][6]_i_1_n_0 ;
  wire \coeff[13][6]_i_2_n_0 ;
  wire \coeff[13][6]_i_3_n_0 ;
  wire \coeff[13][7]_i_1_n_0 ;
  wire \coeff[13][7]_i_2_n_0 ;
  wire \coeff[13][7]_i_3_n_0 ;
  wire \coeff[13][8]_i_1_n_0 ;
  wire \coeff[13][8]_i_2_n_0 ;
  wire \coeff[13][8]_i_3_n_0 ;
  wire \coeff[13][9]_i_1_n_0 ;
  wire \coeff[13][9]_i_2_n_0 ;
  wire \coeff[13][9]_i_3_n_0 ;
  wire \coeff[14][0]_i_1_n_0 ;
  wire \coeff[14][0]_i_2_n_0 ;
  wire \coeff[14][0]_i_3_n_0 ;
  wire \coeff[14][10]_i_1_n_0 ;
  wire \coeff[14][10]_i_2_n_0 ;
  wire \coeff[14][10]_i_3_n_0 ;
  wire \coeff[14][11]_i_1_n_0 ;
  wire \coeff[14][11]_i_2_n_0 ;
  wire \coeff[14][11]_i_3_n_0 ;
  wire \coeff[14][12]_i_1_n_0 ;
  wire \coeff[14][12]_i_2_n_0 ;
  wire \coeff[14][12]_i_3_n_0 ;
  wire \coeff[14][13]_i_1_n_0 ;
  wire \coeff[14][13]_i_2_n_0 ;
  wire \coeff[14][13]_i_3_n_0 ;
  wire \coeff[14][14]_i_1_n_0 ;
  wire \coeff[14][14]_i_2_n_0 ;
  wire \coeff[14][14]_i_3_n_0 ;
  wire \coeff[14][15]_i_1_n_0 ;
  wire \coeff[14][15]_i_2_n_0 ;
  wire \coeff[14][15]_i_3_n_0 ;
  wire \coeff[14][15]_i_4_n_0 ;
  wire \coeff[14][15]_i_5_n_0 ;
  wire \coeff[14][15]_i_6_n_0 ;
  wire \coeff[14][15]_i_7_n_0 ;
  wire \coeff[14][15]_i_8_n_0 ;
  wire \coeff[14][1]_i_1_n_0 ;
  wire \coeff[14][1]_i_2_n_0 ;
  wire \coeff[14][1]_i_3_n_0 ;
  wire \coeff[14][2]_i_1_n_0 ;
  wire \coeff[14][2]_i_2_n_0 ;
  wire \coeff[14][2]_i_3_n_0 ;
  wire \coeff[14][3]_i_1_n_0 ;
  wire \coeff[14][3]_i_2_n_0 ;
  wire \coeff[14][3]_i_3_n_0 ;
  wire \coeff[14][4]_i_1_n_0 ;
  wire \coeff[14][4]_i_2_n_0 ;
  wire \coeff[14][4]_i_3_n_0 ;
  wire \coeff[14][5]_i_1_n_0 ;
  wire \coeff[14][5]_i_2_n_0 ;
  wire \coeff[14][5]_i_3_n_0 ;
  wire \coeff[14][6]_i_1_n_0 ;
  wire \coeff[14][6]_i_2_n_0 ;
  wire \coeff[14][6]_i_3_n_0 ;
  wire \coeff[14][7]_i_1_n_0 ;
  wire \coeff[14][7]_i_2_n_0 ;
  wire \coeff[14][7]_i_3_n_0 ;
  wire \coeff[14][8]_i_1_n_0 ;
  wire \coeff[14][8]_i_2_n_0 ;
  wire \coeff[14][8]_i_3_n_0 ;
  wire \coeff[14][9]_i_1_n_0 ;
  wire \coeff[14][9]_i_2_n_0 ;
  wire \coeff[14][9]_i_3_n_0 ;
  wire \coeff[15][0]_i_1_n_0 ;
  wire \coeff[15][0]_i_2_n_0 ;
  wire \coeff[15][0]_i_3_n_0 ;
  wire \coeff[15][10]_i_1_n_0 ;
  wire \coeff[15][10]_i_2_n_0 ;
  wire \coeff[15][10]_i_3_n_0 ;
  wire \coeff[15][11]_i_1_n_0 ;
  wire \coeff[15][11]_i_2_n_0 ;
  wire \coeff[15][11]_i_3_n_0 ;
  wire \coeff[15][12]_i_1_n_0 ;
  wire \coeff[15][12]_i_2_n_0 ;
  wire \coeff[15][12]_i_3_n_0 ;
  wire \coeff[15][13]_i_1_n_0 ;
  wire \coeff[15][13]_i_2_n_0 ;
  wire \coeff[15][13]_i_3_n_0 ;
  wire \coeff[15][14]_i_1_n_0 ;
  wire \coeff[15][14]_i_2_n_0 ;
  wire \coeff[15][14]_i_3_n_0 ;
  wire \coeff[15][15]_i_1_n_0 ;
  wire \coeff[15][15]_i_2_n_0 ;
  wire \coeff[15][15]_i_3_n_0 ;
  wire \coeff[15][15]_i_4_n_0 ;
  wire \coeff[15][15]_i_5_n_0 ;
  wire \coeff[15][15]_i_6_n_0 ;
  wire \coeff[15][15]_i_7_n_0 ;
  wire \coeff[15][15]_i_8_n_0 ;
  wire \coeff[15][1]_i_1_n_0 ;
  wire \coeff[15][1]_i_2_n_0 ;
  wire \coeff[15][1]_i_3_n_0 ;
  wire \coeff[15][2]_i_1_n_0 ;
  wire \coeff[15][2]_i_2_n_0 ;
  wire \coeff[15][2]_i_3_n_0 ;
  wire \coeff[15][3]_i_1_n_0 ;
  wire \coeff[15][3]_i_2_n_0 ;
  wire \coeff[15][3]_i_3_n_0 ;
  wire \coeff[15][4]_i_1_n_0 ;
  wire \coeff[15][4]_i_2_n_0 ;
  wire \coeff[15][4]_i_3_n_0 ;
  wire \coeff[15][5]_i_1_n_0 ;
  wire \coeff[15][5]_i_2_n_0 ;
  wire \coeff[15][5]_i_3_n_0 ;
  wire \coeff[15][6]_i_1_n_0 ;
  wire \coeff[15][6]_i_2_n_0 ;
  wire \coeff[15][6]_i_3_n_0 ;
  wire \coeff[15][7]_i_1_n_0 ;
  wire \coeff[15][7]_i_2_n_0 ;
  wire \coeff[15][7]_i_3_n_0 ;
  wire \coeff[15][8]_i_1_n_0 ;
  wire \coeff[15][8]_i_2_n_0 ;
  wire \coeff[15][8]_i_3_n_0 ;
  wire \coeff[15][9]_i_1_n_0 ;
  wire \coeff[15][9]_i_2_n_0 ;
  wire \coeff[15][9]_i_3_n_0 ;
  wire \coeff[1][0]_i_1_n_0 ;
  wire \coeff[1][0]_i_2_n_0 ;
  wire \coeff[1][0]_i_3_n_0 ;
  wire \coeff[1][10]_i_1_n_0 ;
  wire \coeff[1][10]_i_2_n_0 ;
  wire \coeff[1][10]_i_3_n_0 ;
  wire \coeff[1][11]_i_1_n_0 ;
  wire \coeff[1][11]_i_2_n_0 ;
  wire \coeff[1][11]_i_3_n_0 ;
  wire \coeff[1][12]_i_1_n_0 ;
  wire \coeff[1][12]_i_2_n_0 ;
  wire \coeff[1][12]_i_3_n_0 ;
  wire \coeff[1][13]_i_1_n_0 ;
  wire \coeff[1][13]_i_2_n_0 ;
  wire \coeff[1][13]_i_3_n_0 ;
  wire \coeff[1][14]_i_1_n_0 ;
  wire \coeff[1][14]_i_2_n_0 ;
  wire \coeff[1][14]_i_3_n_0 ;
  wire \coeff[1][15]_i_10_n_0 ;
  wire \coeff[1][15]_i_1_n_0 ;
  wire \coeff[1][15]_i_2_n_0 ;
  wire \coeff[1][15]_i_3_n_0 ;
  wire \coeff[1][15]_i_4_n_0 ;
  wire \coeff[1][15]_i_5_n_0 ;
  wire \coeff[1][15]_i_6_n_0 ;
  wire \coeff[1][15]_i_7_n_0 ;
  wire \coeff[1][15]_i_8_n_0 ;
  wire \coeff[1][15]_i_9_n_0 ;
  wire \coeff[1][1]_i_1_n_0 ;
  wire \coeff[1][1]_i_2_n_0 ;
  wire \coeff[1][1]_i_3_n_0 ;
  wire \coeff[1][2]_i_1_n_0 ;
  wire \coeff[1][2]_i_2_n_0 ;
  wire \coeff[1][2]_i_3_n_0 ;
  wire \coeff[1][3]_i_1_n_0 ;
  wire \coeff[1][3]_i_2_n_0 ;
  wire \coeff[1][3]_i_3_n_0 ;
  wire \coeff[1][4]_i_1_n_0 ;
  wire \coeff[1][4]_i_2_n_0 ;
  wire \coeff[1][4]_i_3_n_0 ;
  wire \coeff[1][5]_i_1_n_0 ;
  wire \coeff[1][5]_i_2_n_0 ;
  wire \coeff[1][5]_i_3_n_0 ;
  wire \coeff[1][6]_i_1_n_0 ;
  wire \coeff[1][6]_i_2_n_0 ;
  wire \coeff[1][6]_i_3_n_0 ;
  wire \coeff[1][7]_i_1_n_0 ;
  wire \coeff[1][7]_i_2_n_0 ;
  wire \coeff[1][7]_i_3_n_0 ;
  wire \coeff[1][8]_i_1_n_0 ;
  wire \coeff[1][8]_i_2_n_0 ;
  wire \coeff[1][8]_i_3_n_0 ;
  wire \coeff[1][9]_i_1_n_0 ;
  wire \coeff[1][9]_i_2_n_0 ;
  wire \coeff[1][9]_i_3_n_0 ;
  wire \coeff[2][0]_i_1_n_0 ;
  wire \coeff[2][0]_i_2_n_0 ;
  wire \coeff[2][0]_i_3_n_0 ;
  wire \coeff[2][10]_i_1_n_0 ;
  wire \coeff[2][10]_i_2_n_0 ;
  wire \coeff[2][10]_i_3_n_0 ;
  wire \coeff[2][11]_i_1_n_0 ;
  wire \coeff[2][11]_i_2_n_0 ;
  wire \coeff[2][11]_i_3_n_0 ;
  wire \coeff[2][12]_i_1_n_0 ;
  wire \coeff[2][12]_i_2_n_0 ;
  wire \coeff[2][12]_i_3_n_0 ;
  wire \coeff[2][13]_i_1_n_0 ;
  wire \coeff[2][13]_i_2_n_0 ;
  wire \coeff[2][13]_i_3_n_0 ;
  wire \coeff[2][14]_i_1_n_0 ;
  wire \coeff[2][14]_i_2_n_0 ;
  wire \coeff[2][14]_i_3_n_0 ;
  wire \coeff[2][15]_i_1_n_0 ;
  wire \coeff[2][15]_i_2_n_0 ;
  wire \coeff[2][15]_i_3_n_0 ;
  wire \coeff[2][15]_i_4_n_0 ;
  wire \coeff[2][15]_i_5_n_0 ;
  wire \coeff[2][15]_i_6_n_0 ;
  wire \coeff[2][15]_i_7_n_0 ;
  wire \coeff[2][15]_i_8_n_0 ;
  wire \coeff[2][15]_i_9_n_0 ;
  wire \coeff[2][1]_i_1_n_0 ;
  wire \coeff[2][1]_i_2_n_0 ;
  wire \coeff[2][1]_i_3_n_0 ;
  wire \coeff[2][2]_i_1_n_0 ;
  wire \coeff[2][2]_i_2_n_0 ;
  wire \coeff[2][2]_i_3_n_0 ;
  wire \coeff[2][3]_i_1_n_0 ;
  wire \coeff[2][3]_i_2_n_0 ;
  wire \coeff[2][3]_i_3_n_0 ;
  wire \coeff[2][4]_i_1_n_0 ;
  wire \coeff[2][4]_i_2_n_0 ;
  wire \coeff[2][4]_i_3_n_0 ;
  wire \coeff[2][5]_i_1_n_0 ;
  wire \coeff[2][5]_i_2_n_0 ;
  wire \coeff[2][5]_i_3_n_0 ;
  wire \coeff[2][6]_i_1_n_0 ;
  wire \coeff[2][6]_i_2_n_0 ;
  wire \coeff[2][6]_i_3_n_0 ;
  wire \coeff[2][7]_i_1_n_0 ;
  wire \coeff[2][7]_i_2_n_0 ;
  wire \coeff[2][7]_i_3_n_0 ;
  wire \coeff[2][8]_i_1_n_0 ;
  wire \coeff[2][8]_i_2_n_0 ;
  wire \coeff[2][8]_i_3_n_0 ;
  wire \coeff[2][9]_i_1_n_0 ;
  wire \coeff[2][9]_i_2_n_0 ;
  wire \coeff[2][9]_i_3_n_0 ;
  wire \coeff[3][0]_i_1_n_0 ;
  wire \coeff[3][0]_i_2_n_0 ;
  wire \coeff[3][0]_i_3_n_0 ;
  wire \coeff[3][10]_i_1_n_0 ;
  wire \coeff[3][10]_i_2_n_0 ;
  wire \coeff[3][10]_i_3_n_0 ;
  wire \coeff[3][11]_i_1_n_0 ;
  wire \coeff[3][11]_i_2_n_0 ;
  wire \coeff[3][11]_i_3_n_0 ;
  wire \coeff[3][12]_i_1_n_0 ;
  wire \coeff[3][12]_i_2_n_0 ;
  wire \coeff[3][12]_i_3_n_0 ;
  wire \coeff[3][13]_i_1_n_0 ;
  wire \coeff[3][13]_i_2_n_0 ;
  wire \coeff[3][13]_i_3_n_0 ;
  wire \coeff[3][14]_i_1_n_0 ;
  wire \coeff[3][14]_i_2_n_0 ;
  wire \coeff[3][14]_i_3_n_0 ;
  wire \coeff[3][15]_i_1_n_0 ;
  wire \coeff[3][15]_i_2_n_0 ;
  wire \coeff[3][15]_i_3_n_0 ;
  wire \coeff[3][15]_i_4_n_0 ;
  wire \coeff[3][15]_i_5_n_0 ;
  wire \coeff[3][15]_i_6_n_0 ;
  wire \coeff[3][15]_i_7_n_0 ;
  wire \coeff[3][15]_i_8_n_0 ;
  wire \coeff[3][1]_i_1_n_0 ;
  wire \coeff[3][1]_i_2_n_0 ;
  wire \coeff[3][1]_i_3_n_0 ;
  wire \coeff[3][2]_i_1_n_0 ;
  wire \coeff[3][2]_i_2_n_0 ;
  wire \coeff[3][2]_i_3_n_0 ;
  wire \coeff[3][3]_i_1_n_0 ;
  wire \coeff[3][3]_i_2_n_0 ;
  wire \coeff[3][3]_i_3_n_0 ;
  wire \coeff[3][4]_i_1_n_0 ;
  wire \coeff[3][4]_i_2_n_0 ;
  wire \coeff[3][4]_i_3_n_0 ;
  wire \coeff[3][5]_i_1_n_0 ;
  wire \coeff[3][5]_i_2_n_0 ;
  wire \coeff[3][5]_i_3_n_0 ;
  wire \coeff[3][6]_i_1_n_0 ;
  wire \coeff[3][6]_i_2_n_0 ;
  wire \coeff[3][6]_i_3_n_0 ;
  wire \coeff[3][7]_i_1_n_0 ;
  wire \coeff[3][7]_i_2_n_0 ;
  wire \coeff[3][7]_i_3_n_0 ;
  wire \coeff[3][8]_i_1_n_0 ;
  wire \coeff[3][8]_i_2_n_0 ;
  wire \coeff[3][8]_i_3_n_0 ;
  wire \coeff[3][9]_i_1_n_0 ;
  wire \coeff[3][9]_i_2_n_0 ;
  wire \coeff[3][9]_i_3_n_0 ;
  wire \coeff[4][0]_i_1_n_0 ;
  wire \coeff[4][0]_i_2_n_0 ;
  wire \coeff[4][0]_i_3_n_0 ;
  wire \coeff[4][10]_i_1_n_0 ;
  wire \coeff[4][10]_i_2_n_0 ;
  wire \coeff[4][10]_i_3_n_0 ;
  wire \coeff[4][11]_i_1_n_0 ;
  wire \coeff[4][11]_i_2_n_0 ;
  wire \coeff[4][11]_i_3_n_0 ;
  wire \coeff[4][12]_i_1_n_0 ;
  wire \coeff[4][12]_i_2_n_0 ;
  wire \coeff[4][12]_i_3_n_0 ;
  wire \coeff[4][13]_i_1_n_0 ;
  wire \coeff[4][13]_i_2_n_0 ;
  wire \coeff[4][13]_i_3_n_0 ;
  wire \coeff[4][14]_i_1_n_0 ;
  wire \coeff[4][14]_i_2_n_0 ;
  wire \coeff[4][14]_i_3_n_0 ;
  wire \coeff[4][15]_i_1_n_0 ;
  wire \coeff[4][15]_i_2_n_0 ;
  wire \coeff[4][15]_i_3_n_0 ;
  wire \coeff[4][15]_i_4_n_0 ;
  wire \coeff[4][15]_i_5_n_0 ;
  wire \coeff[4][15]_i_6_n_0 ;
  wire \coeff[4][15]_i_7_n_0 ;
  wire \coeff[4][15]_i_8_n_0 ;
  wire \coeff[4][1]_i_1_n_0 ;
  wire \coeff[4][1]_i_2_n_0 ;
  wire \coeff[4][1]_i_3_n_0 ;
  wire \coeff[4][2]_i_1_n_0 ;
  wire \coeff[4][2]_i_2_n_0 ;
  wire \coeff[4][2]_i_3_n_0 ;
  wire \coeff[4][3]_i_1_n_0 ;
  wire \coeff[4][3]_i_2_n_0 ;
  wire \coeff[4][3]_i_3_n_0 ;
  wire \coeff[4][4]_i_1_n_0 ;
  wire \coeff[4][4]_i_2_n_0 ;
  wire \coeff[4][4]_i_3_n_0 ;
  wire \coeff[4][5]_i_1_n_0 ;
  wire \coeff[4][5]_i_2_n_0 ;
  wire \coeff[4][5]_i_3_n_0 ;
  wire \coeff[4][6]_i_1_n_0 ;
  wire \coeff[4][6]_i_2_n_0 ;
  wire \coeff[4][6]_i_3_n_0 ;
  wire \coeff[4][7]_i_1_n_0 ;
  wire \coeff[4][7]_i_2_n_0 ;
  wire \coeff[4][7]_i_3_n_0 ;
  wire \coeff[4][8]_i_1_n_0 ;
  wire \coeff[4][8]_i_2_n_0 ;
  wire \coeff[4][8]_i_3_n_0 ;
  wire \coeff[4][9]_i_1_n_0 ;
  wire \coeff[4][9]_i_2_n_0 ;
  wire \coeff[4][9]_i_3_n_0 ;
  wire \coeff[5][0]_i_1_n_0 ;
  wire \coeff[5][0]_i_2_n_0 ;
  wire \coeff[5][0]_i_3_n_0 ;
  wire \coeff[5][10]_i_1_n_0 ;
  wire \coeff[5][10]_i_2_n_0 ;
  wire \coeff[5][10]_i_3_n_0 ;
  wire \coeff[5][11]_i_1_n_0 ;
  wire \coeff[5][11]_i_2_n_0 ;
  wire \coeff[5][11]_i_3_n_0 ;
  wire \coeff[5][12]_i_1_n_0 ;
  wire \coeff[5][12]_i_2_n_0 ;
  wire \coeff[5][12]_i_3_n_0 ;
  wire \coeff[5][13]_i_1_n_0 ;
  wire \coeff[5][13]_i_2_n_0 ;
  wire \coeff[5][13]_i_3_n_0 ;
  wire \coeff[5][14]_i_1_n_0 ;
  wire \coeff[5][14]_i_2_n_0 ;
  wire \coeff[5][14]_i_3_n_0 ;
  wire \coeff[5][15]_i_1_n_0 ;
  wire \coeff[5][15]_i_2_n_0 ;
  wire \coeff[5][15]_i_3_n_0 ;
  wire \coeff[5][15]_i_4_n_0 ;
  wire \coeff[5][15]_i_5_n_0 ;
  wire \coeff[5][15]_i_6_n_0 ;
  wire \coeff[5][15]_i_7_n_0 ;
  wire \coeff[5][15]_i_8_n_0 ;
  wire \coeff[5][1]_i_1_n_0 ;
  wire \coeff[5][1]_i_2_n_0 ;
  wire \coeff[5][1]_i_3_n_0 ;
  wire \coeff[5][2]_i_1_n_0 ;
  wire \coeff[5][2]_i_2_n_0 ;
  wire \coeff[5][2]_i_3_n_0 ;
  wire \coeff[5][3]_i_1_n_0 ;
  wire \coeff[5][3]_i_2_n_0 ;
  wire \coeff[5][3]_i_3_n_0 ;
  wire \coeff[5][4]_i_1_n_0 ;
  wire \coeff[5][4]_i_2_n_0 ;
  wire \coeff[5][4]_i_3_n_0 ;
  wire \coeff[5][5]_i_1_n_0 ;
  wire \coeff[5][5]_i_2_n_0 ;
  wire \coeff[5][5]_i_3_n_0 ;
  wire \coeff[5][6]_i_1_n_0 ;
  wire \coeff[5][6]_i_2_n_0 ;
  wire \coeff[5][6]_i_3_n_0 ;
  wire \coeff[5][7]_i_1_n_0 ;
  wire \coeff[5][7]_i_2_n_0 ;
  wire \coeff[5][7]_i_3_n_0 ;
  wire \coeff[5][8]_i_1_n_0 ;
  wire \coeff[5][8]_i_2_n_0 ;
  wire \coeff[5][8]_i_3_n_0 ;
  wire \coeff[5][9]_i_1_n_0 ;
  wire \coeff[5][9]_i_2_n_0 ;
  wire \coeff[5][9]_i_3_n_0 ;
  wire \coeff[6][0]_i_1_n_0 ;
  wire \coeff[6][0]_i_2_n_0 ;
  wire \coeff[6][0]_i_3_n_0 ;
  wire \coeff[6][10]_i_1_n_0 ;
  wire \coeff[6][10]_i_2_n_0 ;
  wire \coeff[6][10]_i_3_n_0 ;
  wire \coeff[6][11]_i_1_n_0 ;
  wire \coeff[6][11]_i_2_n_0 ;
  wire \coeff[6][11]_i_3_n_0 ;
  wire \coeff[6][12]_i_1_n_0 ;
  wire \coeff[6][12]_i_2_n_0 ;
  wire \coeff[6][12]_i_3_n_0 ;
  wire \coeff[6][13]_i_1_n_0 ;
  wire \coeff[6][13]_i_2_n_0 ;
  wire \coeff[6][13]_i_3_n_0 ;
  wire \coeff[6][14]_i_1_n_0 ;
  wire \coeff[6][14]_i_2_n_0 ;
  wire \coeff[6][14]_i_3_n_0 ;
  wire \coeff[6][15]_i_1_n_0 ;
  wire \coeff[6][15]_i_2_n_0 ;
  wire \coeff[6][15]_i_3_n_0 ;
  wire \coeff[6][15]_i_4_n_0 ;
  wire \coeff[6][15]_i_5_n_0 ;
  wire \coeff[6][15]_i_6_n_0 ;
  wire \coeff[6][15]_i_7_n_0 ;
  wire \coeff[6][15]_i_8_n_0 ;
  wire \coeff[6][1]_i_1_n_0 ;
  wire \coeff[6][1]_i_2_n_0 ;
  wire \coeff[6][1]_i_3_n_0 ;
  wire \coeff[6][2]_i_1_n_0 ;
  wire \coeff[6][2]_i_2_n_0 ;
  wire \coeff[6][2]_i_3_n_0 ;
  wire \coeff[6][3]_i_1_n_0 ;
  wire \coeff[6][3]_i_2_n_0 ;
  wire \coeff[6][3]_i_3_n_0 ;
  wire \coeff[6][4]_i_1_n_0 ;
  wire \coeff[6][4]_i_2_n_0 ;
  wire \coeff[6][4]_i_3_n_0 ;
  wire \coeff[6][5]_i_1_n_0 ;
  wire \coeff[6][5]_i_2_n_0 ;
  wire \coeff[6][5]_i_3_n_0 ;
  wire \coeff[6][6]_i_1_n_0 ;
  wire \coeff[6][6]_i_2_n_0 ;
  wire \coeff[6][6]_i_3_n_0 ;
  wire \coeff[6][7]_i_1_n_0 ;
  wire \coeff[6][7]_i_2_n_0 ;
  wire \coeff[6][7]_i_3_n_0 ;
  wire \coeff[6][8]_i_1_n_0 ;
  wire \coeff[6][8]_i_2_n_0 ;
  wire \coeff[6][8]_i_3_n_0 ;
  wire \coeff[6][9]_i_1_n_0 ;
  wire \coeff[6][9]_i_2_n_0 ;
  wire \coeff[6][9]_i_3_n_0 ;
  wire \coeff[7][0]_i_1_n_0 ;
  wire \coeff[7][0]_i_2_n_0 ;
  wire \coeff[7][0]_i_3_n_0 ;
  wire \coeff[7][10]_i_1_n_0 ;
  wire \coeff[7][10]_i_2_n_0 ;
  wire \coeff[7][10]_i_3_n_0 ;
  wire \coeff[7][11]_i_1_n_0 ;
  wire \coeff[7][11]_i_2_n_0 ;
  wire \coeff[7][11]_i_3_n_0 ;
  wire \coeff[7][12]_i_1_n_0 ;
  wire \coeff[7][12]_i_2_n_0 ;
  wire \coeff[7][12]_i_3_n_0 ;
  wire \coeff[7][13]_i_1_n_0 ;
  wire \coeff[7][13]_i_2_n_0 ;
  wire \coeff[7][13]_i_3_n_0 ;
  wire \coeff[7][14]_i_1_n_0 ;
  wire \coeff[7][14]_i_2_n_0 ;
  wire \coeff[7][14]_i_3_n_0 ;
  wire \coeff[7][15]_i_1_n_0 ;
  wire \coeff[7][15]_i_2_n_0 ;
  wire \coeff[7][15]_i_3_n_0 ;
  wire \coeff[7][15]_i_4_n_0 ;
  wire \coeff[7][15]_i_5_n_0 ;
  wire \coeff[7][15]_i_6_n_0 ;
  wire \coeff[7][15]_i_7_n_0 ;
  wire \coeff[7][15]_i_8_n_0 ;
  wire \coeff[7][1]_i_1_n_0 ;
  wire \coeff[7][1]_i_2_n_0 ;
  wire \coeff[7][1]_i_3_n_0 ;
  wire \coeff[7][2]_i_1_n_0 ;
  wire \coeff[7][2]_i_2_n_0 ;
  wire \coeff[7][2]_i_3_n_0 ;
  wire \coeff[7][3]_i_1_n_0 ;
  wire \coeff[7][3]_i_2_n_0 ;
  wire \coeff[7][3]_i_3_n_0 ;
  wire \coeff[7][4]_i_1_n_0 ;
  wire \coeff[7][4]_i_2_n_0 ;
  wire \coeff[7][4]_i_3_n_0 ;
  wire \coeff[7][5]_i_1_n_0 ;
  wire \coeff[7][5]_i_2_n_0 ;
  wire \coeff[7][5]_i_3_n_0 ;
  wire \coeff[7][6]_i_1_n_0 ;
  wire \coeff[7][6]_i_2_n_0 ;
  wire \coeff[7][6]_i_3_n_0 ;
  wire \coeff[7][7]_i_1_n_0 ;
  wire \coeff[7][7]_i_2_n_0 ;
  wire \coeff[7][7]_i_3_n_0 ;
  wire \coeff[7][8]_i_1_n_0 ;
  wire \coeff[7][8]_i_2_n_0 ;
  wire \coeff[7][8]_i_3_n_0 ;
  wire \coeff[7][9]_i_1_n_0 ;
  wire \coeff[7][9]_i_2_n_0 ;
  wire \coeff[7][9]_i_3_n_0 ;
  wire \coeff[8][0]_i_1_n_0 ;
  wire \coeff[8][0]_i_2_n_0 ;
  wire \coeff[8][0]_i_3_n_0 ;
  wire \coeff[8][10]_i_1_n_0 ;
  wire \coeff[8][10]_i_2_n_0 ;
  wire \coeff[8][10]_i_3_n_0 ;
  wire \coeff[8][11]_i_1_n_0 ;
  wire \coeff[8][11]_i_2_n_0 ;
  wire \coeff[8][11]_i_3_n_0 ;
  wire \coeff[8][12]_i_1_n_0 ;
  wire \coeff[8][12]_i_2_n_0 ;
  wire \coeff[8][12]_i_3_n_0 ;
  wire \coeff[8][13]_i_1_n_0 ;
  wire \coeff[8][13]_i_2_n_0 ;
  wire \coeff[8][13]_i_3_n_0 ;
  wire \coeff[8][14]_i_1_n_0 ;
  wire \coeff[8][14]_i_2_n_0 ;
  wire \coeff[8][14]_i_3_n_0 ;
  wire \coeff[8][15]_i_10_n_0 ;
  wire \coeff[8][15]_i_1_n_0 ;
  wire \coeff[8][15]_i_2_n_0 ;
  wire \coeff[8][15]_i_3_n_0 ;
  wire \coeff[8][15]_i_4_n_0 ;
  wire \coeff[8][15]_i_5_n_0 ;
  wire \coeff[8][15]_i_6_n_0 ;
  wire \coeff[8][15]_i_7_n_0 ;
  wire \coeff[8][15]_i_8_n_0 ;
  wire \coeff[8][15]_i_9_n_0 ;
  wire \coeff[8][1]_i_1_n_0 ;
  wire \coeff[8][1]_i_2_n_0 ;
  wire \coeff[8][1]_i_3_n_0 ;
  wire \coeff[8][2]_i_1_n_0 ;
  wire \coeff[8][2]_i_2_n_0 ;
  wire \coeff[8][2]_i_3_n_0 ;
  wire \coeff[8][3]_i_1_n_0 ;
  wire \coeff[8][3]_i_2_n_0 ;
  wire \coeff[8][3]_i_3_n_0 ;
  wire \coeff[8][4]_i_1_n_0 ;
  wire \coeff[8][4]_i_2_n_0 ;
  wire \coeff[8][4]_i_3_n_0 ;
  wire \coeff[8][5]_i_1_n_0 ;
  wire \coeff[8][5]_i_2_n_0 ;
  wire \coeff[8][5]_i_3_n_0 ;
  wire \coeff[8][6]_i_1_n_0 ;
  wire \coeff[8][6]_i_2_n_0 ;
  wire \coeff[8][6]_i_3_n_0 ;
  wire \coeff[8][7]_i_1_n_0 ;
  wire \coeff[8][7]_i_2_n_0 ;
  wire \coeff[8][7]_i_3_n_0 ;
  wire \coeff[8][8]_i_1_n_0 ;
  wire \coeff[8][8]_i_2_n_0 ;
  wire \coeff[8][8]_i_3_n_0 ;
  wire \coeff[8][9]_i_1_n_0 ;
  wire \coeff[8][9]_i_2_n_0 ;
  wire \coeff[8][9]_i_3_n_0 ;
  wire \coeff[9][0]_i_1_n_0 ;
  wire \coeff[9][0]_i_2_n_0 ;
  wire \coeff[9][0]_i_3_n_0 ;
  wire \coeff[9][10]_i_1_n_0 ;
  wire \coeff[9][10]_i_2_n_0 ;
  wire \coeff[9][10]_i_3_n_0 ;
  wire \coeff[9][11]_i_1_n_0 ;
  wire \coeff[9][11]_i_2_n_0 ;
  wire \coeff[9][11]_i_3_n_0 ;
  wire \coeff[9][12]_i_1_n_0 ;
  wire \coeff[9][12]_i_2_n_0 ;
  wire \coeff[9][12]_i_3_n_0 ;
  wire \coeff[9][13]_i_1_n_0 ;
  wire \coeff[9][13]_i_2_n_0 ;
  wire \coeff[9][13]_i_3_n_0 ;
  wire \coeff[9][14]_i_1_n_0 ;
  wire \coeff[9][14]_i_2_n_0 ;
  wire \coeff[9][14]_i_3_n_0 ;
  wire \coeff[9][15]_i_1_n_0 ;
  wire \coeff[9][15]_i_2_n_0 ;
  wire \coeff[9][15]_i_3_n_0 ;
  wire \coeff[9][15]_i_4_n_0 ;
  wire \coeff[9][15]_i_5_n_0 ;
  wire \coeff[9][15]_i_6_n_0 ;
  wire \coeff[9][15]_i_7_n_0 ;
  wire \coeff[9][15]_i_8_n_0 ;
  wire \coeff[9][1]_i_1_n_0 ;
  wire \coeff[9][1]_i_2_n_0 ;
  wire \coeff[9][1]_i_3_n_0 ;
  wire \coeff[9][2]_i_1_n_0 ;
  wire \coeff[9][2]_i_2_n_0 ;
  wire \coeff[9][2]_i_3_n_0 ;
  wire \coeff[9][3]_i_1_n_0 ;
  wire \coeff[9][3]_i_2_n_0 ;
  wire \coeff[9][3]_i_3_n_0 ;
  wire \coeff[9][4]_i_1_n_0 ;
  wire \coeff[9][4]_i_2_n_0 ;
  wire \coeff[9][4]_i_3_n_0 ;
  wire \coeff[9][5]_i_1_n_0 ;
  wire \coeff[9][5]_i_2_n_0 ;
  wire \coeff[9][5]_i_3_n_0 ;
  wire \coeff[9][6]_i_1_n_0 ;
  wire \coeff[9][6]_i_2_n_0 ;
  wire \coeff[9][6]_i_3_n_0 ;
  wire \coeff[9][7]_i_1_n_0 ;
  wire \coeff[9][7]_i_2_n_0 ;
  wire \coeff[9][7]_i_3_n_0 ;
  wire \coeff[9][8]_i_1_n_0 ;
  wire \coeff[9][8]_i_2_n_0 ;
  wire \coeff[9][8]_i_3_n_0 ;
  wire \coeff[9][9]_i_1_n_0 ;
  wire \coeff[9][9]_i_2_n_0 ;
  wire \coeff[9][9]_i_3_n_0 ;
  wire \coeff_reg[0][11]_i_10_n_0 ;
  wire \coeff_reg[0][11]_i_10_n_1 ;
  wire \coeff_reg[0][11]_i_10_n_2 ;
  wire \coeff_reg[0][11]_i_10_n_3 ;
  wire \coeff_reg[0][11]_i_10_n_4 ;
  wire \coeff_reg[0][11]_i_10_n_5 ;
  wire \coeff_reg[0][11]_i_10_n_6 ;
  wire \coeff_reg[0][11]_i_10_n_7 ;
  wire \coeff_reg[0][11]_i_19_n_0 ;
  wire \coeff_reg[0][11]_i_19_n_1 ;
  wire \coeff_reg[0][11]_i_19_n_2 ;
  wire \coeff_reg[0][11]_i_19_n_3 ;
  wire \coeff_reg[0][11]_i_19_n_4 ;
  wire \coeff_reg[0][11]_i_19_n_5 ;
  wire \coeff_reg[0][11]_i_19_n_6 ;
  wire \coeff_reg[0][11]_i_19_n_7 ;
  wire \coeff_reg[0][11]_i_6_n_0 ;
  wire \coeff_reg[0][11]_i_6_n_1 ;
  wire \coeff_reg[0][11]_i_6_n_2 ;
  wire \coeff_reg[0][11]_i_6_n_3 ;
  wire \coeff_reg[0][11]_i_7_n_0 ;
  wire \coeff_reg[0][11]_i_7_n_1 ;
  wire \coeff_reg[0][11]_i_7_n_2 ;
  wire \coeff_reg[0][11]_i_7_n_3 ;
  wire \coeff_reg[0][11]_i_7_n_4 ;
  wire \coeff_reg[0][11]_i_7_n_5 ;
  wire \coeff_reg[0][11]_i_7_n_6 ;
  wire \coeff_reg[0][11]_i_7_n_7 ;
  wire \coeff_reg[0][15]_i_13_n_0 ;
  wire \coeff_reg[0][15]_i_13_n_1 ;
  wire \coeff_reg[0][15]_i_13_n_2 ;
  wire \coeff_reg[0][15]_i_13_n_3 ;
  wire \coeff_reg[0][15]_i_14_n_0 ;
  wire \coeff_reg[0][15]_i_14_n_1 ;
  wire \coeff_reg[0][15]_i_14_n_2 ;
  wire \coeff_reg[0][15]_i_14_n_3 ;
  wire \coeff_reg[0][15]_i_17_n_1 ;
  wire \coeff_reg[0][15]_i_17_n_2 ;
  wire \coeff_reg[0][15]_i_17_n_3 ;
  wire \coeff_reg[0][15]_i_18_n_1 ;
  wire \coeff_reg[0][15]_i_18_n_2 ;
  wire \coeff_reg[0][15]_i_18_n_3 ;
  wire \coeff_reg[0][15]_i_18_n_4 ;
  wire \coeff_reg[0][15]_i_18_n_5 ;
  wire \coeff_reg[0][15]_i_18_n_6 ;
  wire \coeff_reg[0][15]_i_18_n_7 ;
  wire \coeff_reg[0][15]_i_21_n_2 ;
  wire \coeff_reg[0][15]_i_21_n_3 ;
  wire \coeff_reg[0][15]_i_22_n_0 ;
  wire \coeff_reg[0][15]_i_22_n_1 ;
  wire \coeff_reg[0][15]_i_22_n_2 ;
  wire \coeff_reg[0][15]_i_22_n_3 ;
  wire \coeff_reg[0][15]_i_22_n_4 ;
  wire \coeff_reg[0][15]_i_22_n_5 ;
  wire \coeff_reg[0][15]_i_22_n_6 ;
  wire \coeff_reg[0][15]_i_22_n_7 ;
  wire \coeff_reg[0][15]_i_31_n_1 ;
  wire \coeff_reg[0][15]_i_31_n_2 ;
  wire \coeff_reg[0][15]_i_31_n_3 ;
  wire \coeff_reg[0][15]_i_32_n_1 ;
  wire \coeff_reg[0][15]_i_32_n_2 ;
  wire \coeff_reg[0][15]_i_32_n_3 ;
  wire \coeff_reg[0][15]_i_32_n_4 ;
  wire \coeff_reg[0][15]_i_32_n_5 ;
  wire \coeff_reg[0][15]_i_32_n_6 ;
  wire \coeff_reg[0][15]_i_32_n_7 ;
  wire \coeff_reg[0][15]_i_41_n_1 ;
  wire \coeff_reg[0][15]_i_41_n_2 ;
  wire \coeff_reg[0][15]_i_41_n_3 ;
  wire \coeff_reg[0][15]_i_41_n_4 ;
  wire \coeff_reg[0][15]_i_41_n_5 ;
  wire \coeff_reg[0][15]_i_41_n_6 ;
  wire \coeff_reg[0][15]_i_41_n_7 ;
  wire \coeff_reg[0][15]_i_46_n_2 ;
  wire \coeff_reg[0][15]_i_46_n_3 ;
  wire \coeff_reg[0][15]_i_46_n_5 ;
  wire \coeff_reg[0][15]_i_46_n_6 ;
  wire \coeff_reg[0][15]_i_46_n_7 ;
  wire \coeff_reg[0][15]_i_66_n_7 ;
  wire \coeff_reg[0][15]_i_67_n_0 ;
  wire \coeff_reg[0][15]_i_67_n_1 ;
  wire \coeff_reg[0][15]_i_67_n_2 ;
  wire \coeff_reg[0][15]_i_67_n_3 ;
  wire \coeff_reg[0][15]_i_67_n_4 ;
  wire \coeff_reg[0][15]_i_67_n_5 ;
  wire \coeff_reg[0][15]_i_67_n_6 ;
  wire \coeff_reg[0][15]_i_67_n_7 ;
  wire \coeff_reg[0][15]_i_81_n_7 ;
  wire \coeff_reg[0][3]_i_10_n_0 ;
  wire \coeff_reg[0][3]_i_10_n_1 ;
  wire \coeff_reg[0][3]_i_10_n_2 ;
  wire \coeff_reg[0][3]_i_10_n_3 ;
  wire \coeff_reg[0][3]_i_10_n_4 ;
  wire \coeff_reg[0][3]_i_10_n_5 ;
  wire \coeff_reg[0][3]_i_10_n_6 ;
  wire \coeff_reg[0][3]_i_10_n_7 ;
  wire \coeff_reg[0][3]_i_19_n_0 ;
  wire \coeff_reg[0][3]_i_19_n_1 ;
  wire \coeff_reg[0][3]_i_19_n_2 ;
  wire \coeff_reg[0][3]_i_19_n_3 ;
  wire \coeff_reg[0][3]_i_19_n_4 ;
  wire \coeff_reg[0][3]_i_19_n_5 ;
  wire \coeff_reg[0][3]_i_19_n_6 ;
  wire \coeff_reg[0][3]_i_19_n_7 ;
  wire \coeff_reg[0][3]_i_6_n_0 ;
  wire \coeff_reg[0][3]_i_6_n_1 ;
  wire \coeff_reg[0][3]_i_6_n_2 ;
  wire \coeff_reg[0][3]_i_6_n_3 ;
  wire \coeff_reg[0][3]_i_7_n_0 ;
  wire \coeff_reg[0][3]_i_7_n_1 ;
  wire \coeff_reg[0][3]_i_7_n_2 ;
  wire \coeff_reg[0][3]_i_7_n_3 ;
  wire \coeff_reg[0][3]_i_7_n_4 ;
  wire \coeff_reg[0][3]_i_7_n_5 ;
  wire \coeff_reg[0][3]_i_7_n_6 ;
  wire \coeff_reg[0][3]_i_7_n_7 ;
  wire \coeff_reg[0][7]_i_10_n_0 ;
  wire \coeff_reg[0][7]_i_10_n_1 ;
  wire \coeff_reg[0][7]_i_10_n_2 ;
  wire \coeff_reg[0][7]_i_10_n_3 ;
  wire \coeff_reg[0][7]_i_10_n_4 ;
  wire \coeff_reg[0][7]_i_10_n_5 ;
  wire \coeff_reg[0][7]_i_10_n_6 ;
  wire \coeff_reg[0][7]_i_10_n_7 ;
  wire \coeff_reg[0][7]_i_19_n_0 ;
  wire \coeff_reg[0][7]_i_19_n_1 ;
  wire \coeff_reg[0][7]_i_19_n_2 ;
  wire \coeff_reg[0][7]_i_19_n_3 ;
  wire \coeff_reg[0][7]_i_19_n_4 ;
  wire \coeff_reg[0][7]_i_19_n_5 ;
  wire \coeff_reg[0][7]_i_19_n_6 ;
  wire \coeff_reg[0][7]_i_19_n_7 ;
  wire \coeff_reg[0][7]_i_6_n_0 ;
  wire \coeff_reg[0][7]_i_6_n_1 ;
  wire \coeff_reg[0][7]_i_6_n_2 ;
  wire \coeff_reg[0][7]_i_6_n_3 ;
  wire \coeff_reg[0][7]_i_7_n_0 ;
  wire \coeff_reg[0][7]_i_7_n_1 ;
  wire \coeff_reg[0][7]_i_7_n_2 ;
  wire \coeff_reg[0][7]_i_7_n_3 ;
  wire \coeff_reg[0][7]_i_7_n_4 ;
  wire \coeff_reg[0][7]_i_7_n_5 ;
  wire \coeff_reg[0][7]_i_7_n_6 ;
  wire \coeff_reg[0][7]_i_7_n_7 ;
  wire \coeff_reg_n_0_[0][0] ;
  wire \coeff_reg_n_0_[0][10] ;
  wire \coeff_reg_n_0_[0][11] ;
  wire \coeff_reg_n_0_[0][12] ;
  wire \coeff_reg_n_0_[0][13] ;
  wire \coeff_reg_n_0_[0][14] ;
  wire \coeff_reg_n_0_[0][15] ;
  wire \coeff_reg_n_0_[0][1] ;
  wire \coeff_reg_n_0_[0][2] ;
  wire \coeff_reg_n_0_[0][3] ;
  wire \coeff_reg_n_0_[0][4] ;
  wire \coeff_reg_n_0_[0][5] ;
  wire \coeff_reg_n_0_[0][6] ;
  wire \coeff_reg_n_0_[0][7] ;
  wire \coeff_reg_n_0_[0][8] ;
  wire \coeff_reg_n_0_[0][9] ;
  wire \coeff_reg_n_0_[10][0] ;
  wire \coeff_reg_n_0_[10][10] ;
  wire \coeff_reg_n_0_[10][11] ;
  wire \coeff_reg_n_0_[10][12] ;
  wire \coeff_reg_n_0_[10][13] ;
  wire \coeff_reg_n_0_[10][14] ;
  wire \coeff_reg_n_0_[10][15] ;
  wire \coeff_reg_n_0_[10][1] ;
  wire \coeff_reg_n_0_[10][2] ;
  wire \coeff_reg_n_0_[10][3] ;
  wire \coeff_reg_n_0_[10][4] ;
  wire \coeff_reg_n_0_[10][5] ;
  wire \coeff_reg_n_0_[10][6] ;
  wire \coeff_reg_n_0_[10][7] ;
  wire \coeff_reg_n_0_[10][8] ;
  wire \coeff_reg_n_0_[10][9] ;
  wire \coeff_reg_n_0_[11][0] ;
  wire \coeff_reg_n_0_[11][10] ;
  wire \coeff_reg_n_0_[11][11] ;
  wire \coeff_reg_n_0_[11][12] ;
  wire \coeff_reg_n_0_[11][13] ;
  wire \coeff_reg_n_0_[11][14] ;
  wire \coeff_reg_n_0_[11][15] ;
  wire \coeff_reg_n_0_[11][1] ;
  wire \coeff_reg_n_0_[11][2] ;
  wire \coeff_reg_n_0_[11][3] ;
  wire \coeff_reg_n_0_[11][4] ;
  wire \coeff_reg_n_0_[11][5] ;
  wire \coeff_reg_n_0_[11][6] ;
  wire \coeff_reg_n_0_[11][7] ;
  wire \coeff_reg_n_0_[11][8] ;
  wire \coeff_reg_n_0_[11][9] ;
  wire \coeff_reg_n_0_[12][0] ;
  wire \coeff_reg_n_0_[12][10] ;
  wire \coeff_reg_n_0_[12][11] ;
  wire \coeff_reg_n_0_[12][12] ;
  wire \coeff_reg_n_0_[12][13] ;
  wire \coeff_reg_n_0_[12][14] ;
  wire \coeff_reg_n_0_[12][15] ;
  wire \coeff_reg_n_0_[12][1] ;
  wire \coeff_reg_n_0_[12][2] ;
  wire \coeff_reg_n_0_[12][3] ;
  wire \coeff_reg_n_0_[12][4] ;
  wire \coeff_reg_n_0_[12][5] ;
  wire \coeff_reg_n_0_[12][6] ;
  wire \coeff_reg_n_0_[12][7] ;
  wire \coeff_reg_n_0_[12][8] ;
  wire \coeff_reg_n_0_[12][9] ;
  wire \coeff_reg_n_0_[13][0] ;
  wire \coeff_reg_n_0_[13][10] ;
  wire \coeff_reg_n_0_[13][11] ;
  wire \coeff_reg_n_0_[13][12] ;
  wire \coeff_reg_n_0_[13][13] ;
  wire \coeff_reg_n_0_[13][14] ;
  wire \coeff_reg_n_0_[13][15] ;
  wire \coeff_reg_n_0_[13][1] ;
  wire \coeff_reg_n_0_[13][2] ;
  wire \coeff_reg_n_0_[13][3] ;
  wire \coeff_reg_n_0_[13][4] ;
  wire \coeff_reg_n_0_[13][5] ;
  wire \coeff_reg_n_0_[13][6] ;
  wire \coeff_reg_n_0_[13][7] ;
  wire \coeff_reg_n_0_[13][8] ;
  wire \coeff_reg_n_0_[13][9] ;
  wire \coeff_reg_n_0_[14][0] ;
  wire \coeff_reg_n_0_[14][10] ;
  wire \coeff_reg_n_0_[14][11] ;
  wire \coeff_reg_n_0_[14][12] ;
  wire \coeff_reg_n_0_[14][13] ;
  wire \coeff_reg_n_0_[14][14] ;
  wire \coeff_reg_n_0_[14][15] ;
  wire \coeff_reg_n_0_[14][1] ;
  wire \coeff_reg_n_0_[14][2] ;
  wire \coeff_reg_n_0_[14][3] ;
  wire \coeff_reg_n_0_[14][4] ;
  wire \coeff_reg_n_0_[14][5] ;
  wire \coeff_reg_n_0_[14][6] ;
  wire \coeff_reg_n_0_[14][7] ;
  wire \coeff_reg_n_0_[14][8] ;
  wire \coeff_reg_n_0_[14][9] ;
  wire \coeff_reg_n_0_[15][0] ;
  wire \coeff_reg_n_0_[15][10] ;
  wire \coeff_reg_n_0_[15][11] ;
  wire \coeff_reg_n_0_[15][12] ;
  wire \coeff_reg_n_0_[15][13] ;
  wire \coeff_reg_n_0_[15][14] ;
  wire \coeff_reg_n_0_[15][15] ;
  wire \coeff_reg_n_0_[15][1] ;
  wire \coeff_reg_n_0_[15][2] ;
  wire \coeff_reg_n_0_[15][3] ;
  wire \coeff_reg_n_0_[15][4] ;
  wire \coeff_reg_n_0_[15][5] ;
  wire \coeff_reg_n_0_[15][6] ;
  wire \coeff_reg_n_0_[15][7] ;
  wire \coeff_reg_n_0_[15][8] ;
  wire \coeff_reg_n_0_[15][9] ;
  wire \coeff_reg_n_0_[1][0] ;
  wire \coeff_reg_n_0_[1][10] ;
  wire \coeff_reg_n_0_[1][11] ;
  wire \coeff_reg_n_0_[1][12] ;
  wire \coeff_reg_n_0_[1][13] ;
  wire \coeff_reg_n_0_[1][14] ;
  wire \coeff_reg_n_0_[1][15] ;
  wire \coeff_reg_n_0_[1][1] ;
  wire \coeff_reg_n_0_[1][2] ;
  wire \coeff_reg_n_0_[1][3] ;
  wire \coeff_reg_n_0_[1][4] ;
  wire \coeff_reg_n_0_[1][5] ;
  wire \coeff_reg_n_0_[1][6] ;
  wire \coeff_reg_n_0_[1][7] ;
  wire \coeff_reg_n_0_[1][8] ;
  wire \coeff_reg_n_0_[1][9] ;
  wire \coeff_reg_n_0_[2][0] ;
  wire \coeff_reg_n_0_[2][10] ;
  wire \coeff_reg_n_0_[2][11] ;
  wire \coeff_reg_n_0_[2][12] ;
  wire \coeff_reg_n_0_[2][13] ;
  wire \coeff_reg_n_0_[2][14] ;
  wire \coeff_reg_n_0_[2][15] ;
  wire \coeff_reg_n_0_[2][1] ;
  wire \coeff_reg_n_0_[2][2] ;
  wire \coeff_reg_n_0_[2][3] ;
  wire \coeff_reg_n_0_[2][4] ;
  wire \coeff_reg_n_0_[2][5] ;
  wire \coeff_reg_n_0_[2][6] ;
  wire \coeff_reg_n_0_[2][7] ;
  wire \coeff_reg_n_0_[2][8] ;
  wire \coeff_reg_n_0_[2][9] ;
  wire \coeff_reg_n_0_[3][0] ;
  wire \coeff_reg_n_0_[3][10] ;
  wire \coeff_reg_n_0_[3][11] ;
  wire \coeff_reg_n_0_[3][12] ;
  wire \coeff_reg_n_0_[3][13] ;
  wire \coeff_reg_n_0_[3][14] ;
  wire \coeff_reg_n_0_[3][15] ;
  wire \coeff_reg_n_0_[3][1] ;
  wire \coeff_reg_n_0_[3][2] ;
  wire \coeff_reg_n_0_[3][3] ;
  wire \coeff_reg_n_0_[3][4] ;
  wire \coeff_reg_n_0_[3][5] ;
  wire \coeff_reg_n_0_[3][6] ;
  wire \coeff_reg_n_0_[3][7] ;
  wire \coeff_reg_n_0_[3][8] ;
  wire \coeff_reg_n_0_[3][9] ;
  wire \coeff_reg_n_0_[4][0] ;
  wire \coeff_reg_n_0_[4][10] ;
  wire \coeff_reg_n_0_[4][11] ;
  wire \coeff_reg_n_0_[4][12] ;
  wire \coeff_reg_n_0_[4][13] ;
  wire \coeff_reg_n_0_[4][14] ;
  wire \coeff_reg_n_0_[4][15] ;
  wire \coeff_reg_n_0_[4][1] ;
  wire \coeff_reg_n_0_[4][2] ;
  wire \coeff_reg_n_0_[4][3] ;
  wire \coeff_reg_n_0_[4][4] ;
  wire \coeff_reg_n_0_[4][5] ;
  wire \coeff_reg_n_0_[4][6] ;
  wire \coeff_reg_n_0_[4][7] ;
  wire \coeff_reg_n_0_[4][8] ;
  wire \coeff_reg_n_0_[4][9] ;
  wire \coeff_reg_n_0_[5][0] ;
  wire \coeff_reg_n_0_[5][10] ;
  wire \coeff_reg_n_0_[5][11] ;
  wire \coeff_reg_n_0_[5][12] ;
  wire \coeff_reg_n_0_[5][13] ;
  wire \coeff_reg_n_0_[5][14] ;
  wire \coeff_reg_n_0_[5][15] ;
  wire \coeff_reg_n_0_[5][1] ;
  wire \coeff_reg_n_0_[5][2] ;
  wire \coeff_reg_n_0_[5][3] ;
  wire \coeff_reg_n_0_[5][4] ;
  wire \coeff_reg_n_0_[5][5] ;
  wire \coeff_reg_n_0_[5][6] ;
  wire \coeff_reg_n_0_[5][7] ;
  wire \coeff_reg_n_0_[5][8] ;
  wire \coeff_reg_n_0_[5][9] ;
  wire \coeff_reg_n_0_[6][0] ;
  wire \coeff_reg_n_0_[6][10] ;
  wire \coeff_reg_n_0_[6][11] ;
  wire \coeff_reg_n_0_[6][12] ;
  wire \coeff_reg_n_0_[6][13] ;
  wire \coeff_reg_n_0_[6][14] ;
  wire \coeff_reg_n_0_[6][15] ;
  wire \coeff_reg_n_0_[6][1] ;
  wire \coeff_reg_n_0_[6][2] ;
  wire \coeff_reg_n_0_[6][3] ;
  wire \coeff_reg_n_0_[6][4] ;
  wire \coeff_reg_n_0_[6][5] ;
  wire \coeff_reg_n_0_[6][6] ;
  wire \coeff_reg_n_0_[6][7] ;
  wire \coeff_reg_n_0_[6][8] ;
  wire \coeff_reg_n_0_[6][9] ;
  wire \coeff_reg_n_0_[7][0] ;
  wire \coeff_reg_n_0_[7][10] ;
  wire \coeff_reg_n_0_[7][11] ;
  wire \coeff_reg_n_0_[7][12] ;
  wire \coeff_reg_n_0_[7][13] ;
  wire \coeff_reg_n_0_[7][14] ;
  wire \coeff_reg_n_0_[7][15] ;
  wire \coeff_reg_n_0_[7][1] ;
  wire \coeff_reg_n_0_[7][2] ;
  wire \coeff_reg_n_0_[7][3] ;
  wire \coeff_reg_n_0_[7][4] ;
  wire \coeff_reg_n_0_[7][5] ;
  wire \coeff_reg_n_0_[7][6] ;
  wire \coeff_reg_n_0_[7][7] ;
  wire \coeff_reg_n_0_[7][8] ;
  wire \coeff_reg_n_0_[7][9] ;
  wire \coeff_reg_n_0_[8][0] ;
  wire \coeff_reg_n_0_[8][10] ;
  wire \coeff_reg_n_0_[8][11] ;
  wire \coeff_reg_n_0_[8][12] ;
  wire \coeff_reg_n_0_[8][13] ;
  wire \coeff_reg_n_0_[8][14] ;
  wire \coeff_reg_n_0_[8][15] ;
  wire \coeff_reg_n_0_[8][1] ;
  wire \coeff_reg_n_0_[8][2] ;
  wire \coeff_reg_n_0_[8][3] ;
  wire \coeff_reg_n_0_[8][4] ;
  wire \coeff_reg_n_0_[8][5] ;
  wire \coeff_reg_n_0_[8][6] ;
  wire \coeff_reg_n_0_[8][7] ;
  wire \coeff_reg_n_0_[8][8] ;
  wire \coeff_reg_n_0_[8][9] ;
  wire \coeff_reg_n_0_[9][0] ;
  wire \coeff_reg_n_0_[9][10] ;
  wire \coeff_reg_n_0_[9][11] ;
  wire \coeff_reg_n_0_[9][12] ;
  wire \coeff_reg_n_0_[9][13] ;
  wire \coeff_reg_n_0_[9][14] ;
  wire \coeff_reg_n_0_[9][15] ;
  wire \coeff_reg_n_0_[9][1] ;
  wire \coeff_reg_n_0_[9][2] ;
  wire \coeff_reg_n_0_[9][3] ;
  wire \coeff_reg_n_0_[9][4] ;
  wire \coeff_reg_n_0_[9][5] ;
  wire \coeff_reg_n_0_[9][6] ;
  wire \coeff_reg_n_0_[9][7] ;
  wire \coeff_reg_n_0_[9][8] ;
  wire \coeff_reg_n_0_[9][9] ;
  wire done;
  wire done_OBUF;
  wire done_i_1_n_0;
  wire g0_b0_n_0;
  wire g0_b10_n_0;
  wire g0_b11_n_0;
  wire g0_b12_n_0;
  wire g0_b1_n_0;
  wire g0_b2_n_0;
  wire g0_b3_n_0;
  wire g0_b4_n_0;
  wire g0_b5_n_0;
  wire g0_b6_n_0;
  wire g0_b7_n_0;
  wire g0_b8_n_0;
  wire g0_b9_n_0;
  wire g1_b0_n_0;
  wire g1_b10_n_0;
  wire g1_b11_n_0;
  wire g1_b1_n_0;
  wire g1_b2_n_0;
  wire g1_b3_n_0;
  wire g1_b4_n_0;
  wire g1_b5_n_0;
  wire g1_b6_n_0;
  wire g1_b7_n_0;
  wire g1_b8_n_0;
  wire g1_b9_n_0;
  wire inv_mode;
  wire inv_mode_reg_n_0;
  wire inverse;
  wire inverse_IBUF;
  wire [0:0]j_cnt;
  wire \j_cnt[1]_i_1_n_0 ;
  wire \j_cnt[2]_i_1_n_0 ;
  wire \j_cnt[3]_i_1_n_0 ;
  wire \j_cnt[4]_i_1_n_0 ;
  wire \j_cnt[4]_i_2_n_0 ;
  wire \j_cnt[5]_i_1_n_0 ;
  wire \j_cnt[5]_i_2_n_0 ;
  wire \j_cnt[6]_i_1_n_0 ;
  wire \j_cnt[7]_i_1_n_0 ;
  wire \j_cnt[7]_i_2_n_0 ;
  wire \j_cnt[7]_i_3_n_0 ;
  wire \j_cnt[7]_i_4_n_0 ;
  wire \j_cnt[7]_i_5_n_0 ;
  wire \j_cnt_reg_n_0_[0] ;
  wire \j_cnt_reg_n_0_[1] ;
  wire \j_cnt_reg_n_0_[2] ;
  wire \j_cnt_reg_n_0_[3] ;
  wire \j_cnt_reg_n_0_[4] ;
  wire \j_cnt_reg_n_0_[5] ;
  wire \j_cnt_reg_n_0_[6] ;
  wire \j_cnt_reg_n_0_[7] ;
  wire [2:0]layer_idx;
  wire \layer_idx[1]_i_1_n_0 ;
  wire \layer_idx_reg_n_0_[0] ;
  wire \layer_idx_reg_n_0_[1] ;
  wire \layer_idx_reg_n_0_[2] ;
  wire [7:0]len;
  wire \len[2]_i_1_n_0 ;
  wire \len[3]_i_1_n_0 ;
  wire \len[4]_i_1_n_0 ;
  wire \len[5]_i_1_n_0 ;
  wire \len[6]_i_1_n_0 ;
  wire \len[7]_i_1_n_0 ;
  wire \len_reg_n_0_[0] ;
  wire \len_reg_n_0_[1] ;
  wire \len_reg_n_0_[2] ;
  wire \len_reg_n_0_[3] ;
  wire \len_reg_n_0_[4] ;
  wire \len_reg_n_0_[5] ;
  wire \len_reg_n_0_[6] ;
  wire \len_reg_n_0_[7] ;
  wire load;
  wire load_IBUF;
  wire [7:0]load_addr;
  wire [7:0]load_addr_IBUF;
  wire [15:0]load_data;
  wire [15:0]load_data_IBUF;
  wire p_0_in__0_n_100;
  wire p_0_in__0_n_101;
  wire p_0_in__0_n_102;
  wire p_0_in__0_n_103;
  wire p_0_in__0_n_104;
  wire p_0_in__0_n_105;
  wire p_0_in__0_n_74;
  wire p_0_in__0_n_75;
  wire p_0_in__0_n_76;
  wire p_0_in__0_n_77;
  wire p_0_in__0_n_78;
  wire p_0_in__0_n_79;
  wire p_0_in__0_n_80;
  wire p_0_in__0_n_81;
  wire p_0_in__0_n_82;
  wire p_0_in__0_n_83;
  wire p_0_in__0_n_84;
  wire p_0_in__0_n_85;
  wire p_0_in__0_n_86;
  wire p_0_in__0_n_87;
  wire p_0_in__0_n_88;
  wire p_0_in__0_n_89;
  wire p_0_in__0_n_90;
  wire p_0_in__0_n_91;
  wire p_0_in__0_n_92;
  wire p_0_in__0_n_93;
  wire p_0_in__0_n_94;
  wire p_0_in__0_n_95;
  wire p_0_in__0_n_96;
  wire p_0_in__0_n_97;
  wire p_0_in__0_n_98;
  wire p_0_in__0_n_99;
  wire p_0_in__1_n_100;
  wire p_0_in__1_n_101;
  wire p_0_in__1_n_102;
  wire p_0_in__1_n_103;
  wire p_0_in__1_n_104;
  wire p_0_in__1_n_105;
  wire p_0_in__1_n_74;
  wire p_0_in__1_n_75;
  wire p_0_in__1_n_76;
  wire p_0_in__1_n_77;
  wire p_0_in__1_n_78;
  wire p_0_in__1_n_79;
  wire p_0_in__1_n_80;
  wire p_0_in__1_n_81;
  wire p_0_in__1_n_82;
  wire p_0_in__1_n_83;
  wire p_0_in__1_n_84;
  wire p_0_in__1_n_85;
  wire p_0_in__1_n_86;
  wire p_0_in__1_n_87;
  wire p_0_in__1_n_88;
  wire p_0_in__1_n_89;
  wire p_0_in__1_n_90;
  wire p_0_in__1_n_91;
  wire p_0_in__1_n_92;
  wire p_0_in__1_n_93;
  wire p_0_in__1_n_94;
  wire p_0_in__1_n_95;
  wire p_0_in__1_n_96;
  wire p_0_in__1_n_97;
  wire p_0_in__1_n_98;
  wire p_0_in__1_n_99;
  wire [15:0]p_0_in__2;
  wire p_0_in_n_100;
  wire p_0_in_n_101;
  wire p_0_in_n_102;
  wire p_0_in_n_103;
  wire p_0_in_n_104;
  wire p_0_in_n_105;
  wire p_0_in_n_74;
  wire p_0_in_n_75;
  wire p_0_in_n_76;
  wire p_0_in_n_77;
  wire p_0_in_n_78;
  wire p_0_in_n_79;
  wire p_0_in_n_80;
  wire p_0_in_n_81;
  wire p_0_in_n_82;
  wire p_0_in_n_83;
  wire p_0_in_n_84;
  wire p_0_in_n_85;
  wire p_0_in_n_86;
  wire p_0_in_n_87;
  wire p_0_in_n_88;
  wire p_0_in_n_89;
  wire p_0_in_n_90;
  wire p_0_in_n_91;
  wire p_0_in_n_92;
  wire p_0_in_n_93;
  wire p_0_in_n_94;
  wire p_0_in_n_95;
  wire p_0_in_n_96;
  wire p_0_in_n_97;
  wire p_0_in_n_98;
  wire p_0_in_n_99;
  wire [7:1]p_1_in;
  wire [31:16]p_1_out__0;
  wire p_1_out_i_10_n_0;
  wire p_1_out_i_11_n_0;
  wire p_1_out_i_12_n_0;
  wire p_1_out_i_13_n_0;
  wire p_1_out_i_14_n_0;
  wire p_1_out_i_15_n_0;
  wire p_1_out_i_16_n_0;
  wire p_1_out_i_17_n_0;
  wire p_1_out_i_18_n_0;
  wire p_1_out_i_19_n_0;
  wire p_1_out_i_1_n_2;
  wire p_1_out_i_1_n_3;
  wire p_1_out_i_1_n_5;
  wire p_1_out_i_1_n_6;
  wire p_1_out_i_1_n_7;
  wire p_1_out_i_20_n_0;
  wire p_1_out_i_21_n_0;
  wire p_1_out_i_22_n_0;
  wire p_1_out_i_23_n_0;
  wire p_1_out_i_24_n_0;
  wire p_1_out_i_25_n_0;
  wire p_1_out_i_26_n_0;
  wire p_1_out_i_27_n_0;
  wire p_1_out_i_28_n_0;
  wire p_1_out_i_29_n_0;
  wire p_1_out_i_2_n_0;
  wire p_1_out_i_2_n_1;
  wire p_1_out_i_2_n_2;
  wire p_1_out_i_2_n_3;
  wire p_1_out_i_2_n_4;
  wire p_1_out_i_2_n_5;
  wire p_1_out_i_2_n_6;
  wire p_1_out_i_2_n_7;
  wire p_1_out_i_30_n_0;
  wire p_1_out_i_31_n_0;
  wire p_1_out_i_32_n_0;
  wire p_1_out_i_33_n_0;
  wire p_1_out_i_34_n_0;
  wire p_1_out_i_35_n_0;
  wire p_1_out_i_36_n_0;
  wire p_1_out_i_37_n_0;
  wire p_1_out_i_38_n_0;
  wire p_1_out_i_39_n_0;
  wire p_1_out_i_3_n_0;
  wire p_1_out_i_3_n_1;
  wire p_1_out_i_3_n_2;
  wire p_1_out_i_3_n_3;
  wire p_1_out_i_3_n_4;
  wire p_1_out_i_3_n_5;
  wire p_1_out_i_3_n_6;
  wire p_1_out_i_3_n_7;
  wire p_1_out_i_40_n_0;
  wire p_1_out_i_41_n_0;
  wire p_1_out_i_42_n_0;
  wire p_1_out_i_43_n_0;
  wire p_1_out_i_44_n_0;
  wire p_1_out_i_45_n_0;
  wire p_1_out_i_46_n_0;
  wire p_1_out_i_47_n_0;
  wire p_1_out_i_48_n_0;
  wire p_1_out_i_49_n_0;
  wire p_1_out_i_4_n_0;
  wire p_1_out_i_4_n_1;
  wire p_1_out_i_4_n_2;
  wire p_1_out_i_4_n_3;
  wire p_1_out_i_4_n_4;
  wire p_1_out_i_4_n_5;
  wire p_1_out_i_4_n_6;
  wire p_1_out_i_4_n_7;
  wire p_1_out_i_50_n_1;
  wire p_1_out_i_50_n_3;
  wire p_1_out_i_50_n_6;
  wire p_1_out_i_50_n_7;
  wire p_1_out_i_51_n_0;
  wire p_1_out_i_51_n_1;
  wire p_1_out_i_51_n_2;
  wire p_1_out_i_51_n_3;
  wire p_1_out_i_51_n_4;
  wire p_1_out_i_51_n_5;
  wire p_1_out_i_51_n_6;
  wire p_1_out_i_51_n_7;
  wire p_1_out_i_52_n_0;
  wire p_1_out_i_52_n_1;
  wire p_1_out_i_52_n_2;
  wire p_1_out_i_52_n_3;
  wire p_1_out_i_52_n_4;
  wire p_1_out_i_52_n_5;
  wire p_1_out_i_52_n_6;
  wire p_1_out_i_52_n_7;
  wire p_1_out_i_53_n_0;
  wire p_1_out_i_53_n_1;
  wire p_1_out_i_53_n_2;
  wire p_1_out_i_53_n_3;
  wire p_1_out_i_53_n_4;
  wire p_1_out_i_53_n_5;
  wire p_1_out_i_53_n_6;
  wire p_1_out_i_53_n_7;
  wire p_1_out_i_54_n_0;
  wire p_1_out_i_54_n_1;
  wire p_1_out_i_54_n_2;
  wire p_1_out_i_54_n_3;
  wire p_1_out_i_54_n_4;
  wire p_1_out_i_54_n_5;
  wire p_1_out_i_54_n_6;
  wire p_1_out_i_54_n_7;
  wire p_1_out_i_55_n_0;
  wire p_1_out_i_56_n_0;
  wire p_1_out_i_57_n_0;
  wire p_1_out_i_58_n_0;
  wire p_1_out_i_59_n_0;
  wire p_1_out_i_5_n_0;
  wire p_1_out_i_5_n_1;
  wire p_1_out_i_5_n_2;
  wire p_1_out_i_5_n_3;
  wire p_1_out_i_5_n_4;
  wire p_1_out_i_5_n_5;
  wire p_1_out_i_5_n_6;
  wire p_1_out_i_5_n_7;
  wire p_1_out_i_60_n_0;
  wire p_1_out_i_61_n_0;
  wire p_1_out_i_62_n_0;
  wire p_1_out_i_63_n_0;
  wire p_1_out_i_64_n_0;
  wire p_1_out_i_65_n_0;
  wire p_1_out_i_66_n_0;
  wire p_1_out_i_67_n_0;
  wire p_1_out_i_68_n_0;
  wire p_1_out_i_69_n_0;
  wire p_1_out_i_6_n_0;
  wire p_1_out_i_6_n_1;
  wire p_1_out_i_6_n_2;
  wire p_1_out_i_6_n_3;
  wire p_1_out_i_6_n_4;
  wire p_1_out_i_6_n_5;
  wire p_1_out_i_6_n_6;
  wire p_1_out_i_6_n_7;
  wire p_1_out_i_70_n_0;
  wire p_1_out_i_71_n_0;
  wire p_1_out_i_7_n_0;
  wire p_1_out_i_8_n_0;
  wire p_1_out_i_9_n_0;
  wire p_1_out_n_100;
  wire p_1_out_n_101;
  wire p_1_out_n_102;
  wire p_1_out_n_103;
  wire p_1_out_n_104;
  wire p_1_out_n_105;
  wire p_1_out_n_90;
  wire p_1_out_n_91;
  wire p_1_out_n_92;
  wire p_1_out_n_93;
  wire p_1_out_n_94;
  wire p_1_out_n_95;
  wire p_1_out_n_96;
  wire p_1_out_n_97;
  wire p_1_out_n_98;
  wire p_1_out_n_99;
  wire [7:0]p_2_out;
  wire [31:16]p_4_out__0;
  wire p_4_out_i_10_n_0;
  wire p_4_out_i_11_n_0;
  wire p_4_out_i_12_n_0;
  wire p_4_out_i_13_n_0;
  wire p_4_out_i_14_n_0;
  wire p_4_out_i_15_n_0;
  wire p_4_out_i_16_n_0;
  wire p_4_out_i_17_n_0;
  wire p_4_out_i_18_n_0;
  wire p_4_out_i_19_n_0;
  wire p_4_out_i_1_n_2;
  wire p_4_out_i_1_n_3;
  wire p_4_out_i_1_n_5;
  wire p_4_out_i_1_n_6;
  wire p_4_out_i_1_n_7;
  wire p_4_out_i_20_n_0;
  wire p_4_out_i_21_n_0;
  wire p_4_out_i_22_n_0;
  wire p_4_out_i_23_n_0;
  wire p_4_out_i_24_n_0;
  wire p_4_out_i_25_n_0;
  wire p_4_out_i_26_n_0;
  wire p_4_out_i_27_n_0;
  wire p_4_out_i_28_n_0;
  wire p_4_out_i_29_n_0;
  wire p_4_out_i_2_n_0;
  wire p_4_out_i_2_n_1;
  wire p_4_out_i_2_n_2;
  wire p_4_out_i_2_n_3;
  wire p_4_out_i_2_n_4;
  wire p_4_out_i_2_n_5;
  wire p_4_out_i_2_n_6;
  wire p_4_out_i_2_n_7;
  wire p_4_out_i_30_n_0;
  wire p_4_out_i_31_n_0;
  wire p_4_out_i_32_n_0;
  wire p_4_out_i_33_n_0;
  wire p_4_out_i_34_n_0;
  wire p_4_out_i_35_n_0;
  wire p_4_out_i_36_n_0;
  wire p_4_out_i_37_n_0;
  wire p_4_out_i_38_n_0;
  wire p_4_out_i_39_n_0;
  wire p_4_out_i_3_n_0;
  wire p_4_out_i_3_n_1;
  wire p_4_out_i_3_n_2;
  wire p_4_out_i_3_n_3;
  wire p_4_out_i_3_n_4;
  wire p_4_out_i_3_n_5;
  wire p_4_out_i_3_n_6;
  wire p_4_out_i_3_n_7;
  wire p_4_out_i_40_n_0;
  wire p_4_out_i_41_n_0;
  wire p_4_out_i_42_n_0;
  wire p_4_out_i_43_n_0;
  wire p_4_out_i_44_n_0;
  wire p_4_out_i_45_n_0;
  wire p_4_out_i_46_n_0;
  wire p_4_out_i_47_n_0;
  wire p_4_out_i_48_n_0;
  wire p_4_out_i_49_n_0;
  wire p_4_out_i_4_n_0;
  wire p_4_out_i_4_n_1;
  wire p_4_out_i_4_n_2;
  wire p_4_out_i_4_n_3;
  wire p_4_out_i_4_n_4;
  wire p_4_out_i_4_n_5;
  wire p_4_out_i_4_n_6;
  wire p_4_out_i_4_n_7;
  wire p_4_out_i_50_n_1;
  wire p_4_out_i_50_n_3;
  wire p_4_out_i_50_n_6;
  wire p_4_out_i_50_n_7;
  wire p_4_out_i_51_n_0;
  wire p_4_out_i_51_n_1;
  wire p_4_out_i_51_n_2;
  wire p_4_out_i_51_n_3;
  wire p_4_out_i_51_n_4;
  wire p_4_out_i_51_n_5;
  wire p_4_out_i_51_n_6;
  wire p_4_out_i_51_n_7;
  wire p_4_out_i_52_n_0;
  wire p_4_out_i_52_n_1;
  wire p_4_out_i_52_n_2;
  wire p_4_out_i_52_n_3;
  wire p_4_out_i_52_n_4;
  wire p_4_out_i_52_n_5;
  wire p_4_out_i_52_n_6;
  wire p_4_out_i_52_n_7;
  wire p_4_out_i_53_n_0;
  wire p_4_out_i_53_n_1;
  wire p_4_out_i_53_n_2;
  wire p_4_out_i_53_n_3;
  wire p_4_out_i_53_n_4;
  wire p_4_out_i_53_n_5;
  wire p_4_out_i_53_n_6;
  wire p_4_out_i_53_n_7;
  wire p_4_out_i_54_n_0;
  wire p_4_out_i_54_n_1;
  wire p_4_out_i_54_n_2;
  wire p_4_out_i_54_n_3;
  wire p_4_out_i_54_n_4;
  wire p_4_out_i_54_n_5;
  wire p_4_out_i_54_n_6;
  wire p_4_out_i_54_n_7;
  wire p_4_out_i_55_n_0;
  wire p_4_out_i_56_n_0;
  wire p_4_out_i_57_n_0;
  wire p_4_out_i_58_n_0;
  wire p_4_out_i_59_n_0;
  wire p_4_out_i_5_n_0;
  wire p_4_out_i_5_n_1;
  wire p_4_out_i_5_n_2;
  wire p_4_out_i_5_n_3;
  wire p_4_out_i_5_n_4;
  wire p_4_out_i_5_n_5;
  wire p_4_out_i_5_n_6;
  wire p_4_out_i_5_n_7;
  wire p_4_out_i_60_n_0;
  wire p_4_out_i_61_n_0;
  wire p_4_out_i_62_n_0;
  wire p_4_out_i_63_n_0;
  wire p_4_out_i_64_n_0;
  wire p_4_out_i_65_n_0;
  wire p_4_out_i_66_n_0;
  wire p_4_out_i_67_n_0;
  wire p_4_out_i_68_n_0;
  wire p_4_out_i_69_n_0;
  wire p_4_out_i_6_n_0;
  wire p_4_out_i_6_n_1;
  wire p_4_out_i_6_n_2;
  wire p_4_out_i_6_n_3;
  wire p_4_out_i_6_n_4;
  wire p_4_out_i_6_n_5;
  wire p_4_out_i_6_n_6;
  wire p_4_out_i_6_n_7;
  wire p_4_out_i_70_n_0;
  wire p_4_out_i_71_n_0;
  wire p_4_out_i_7_n_0;
  wire p_4_out_i_8_n_0;
  wire p_4_out_i_9_n_0;
  wire p_4_out_n_100;
  wire p_4_out_n_101;
  wire p_4_out_n_102;
  wire p_4_out_n_103;
  wire p_4_out_n_104;
  wire p_4_out_n_105;
  wire p_4_out_n_90;
  wire p_4_out_n_91;
  wire p_4_out_n_92;
  wire p_4_out_n_93;
  wire p_4_out_n_94;
  wire p_4_out_n_95;
  wire p_4_out_n_96;
  wire p_4_out_n_97;
  wire p_4_out_n_98;
  wire p_4_out_n_99;
  wire [31:16]p_7_out__0;
  wire p_7_out_i_10_n_0;
  wire p_7_out_i_11_n_0;
  wire p_7_out_i_12_n_0;
  wire p_7_out_i_13_n_0;
  wire p_7_out_i_14_n_0;
  wire p_7_out_i_15_n_0;
  wire p_7_out_i_16_n_0;
  wire p_7_out_i_17_n_0;
  wire p_7_out_i_18_n_0;
  wire p_7_out_i_19_n_0;
  wire p_7_out_i_1_n_2;
  wire p_7_out_i_1_n_3;
  wire p_7_out_i_1_n_5;
  wire p_7_out_i_1_n_6;
  wire p_7_out_i_1_n_7;
  wire p_7_out_i_20_n_0;
  wire p_7_out_i_21_n_0;
  wire p_7_out_i_22_n_0;
  wire p_7_out_i_23_n_0;
  wire p_7_out_i_24_n_0;
  wire p_7_out_i_25_n_0;
  wire p_7_out_i_26_n_0;
  wire p_7_out_i_27_n_0;
  wire p_7_out_i_28_n_0;
  wire p_7_out_i_29_n_0;
  wire p_7_out_i_2_n_0;
  wire p_7_out_i_2_n_1;
  wire p_7_out_i_2_n_2;
  wire p_7_out_i_2_n_3;
  wire p_7_out_i_2_n_4;
  wire p_7_out_i_2_n_5;
  wire p_7_out_i_2_n_6;
  wire p_7_out_i_2_n_7;
  wire p_7_out_i_30_n_0;
  wire p_7_out_i_31_n_0;
  wire p_7_out_i_32_n_0;
  wire p_7_out_i_33_n_0;
  wire p_7_out_i_34_n_0;
  wire p_7_out_i_35_n_0;
  wire p_7_out_i_36_n_0;
  wire p_7_out_i_37_n_0;
  wire p_7_out_i_38_n_0;
  wire p_7_out_i_39_n_0;
  wire p_7_out_i_3_n_0;
  wire p_7_out_i_3_n_1;
  wire p_7_out_i_3_n_2;
  wire p_7_out_i_3_n_3;
  wire p_7_out_i_3_n_4;
  wire p_7_out_i_3_n_5;
  wire p_7_out_i_3_n_6;
  wire p_7_out_i_3_n_7;
  wire p_7_out_i_40_n_0;
  wire p_7_out_i_41_n_0;
  wire p_7_out_i_42_n_0;
  wire p_7_out_i_43_n_0;
  wire p_7_out_i_44_n_0;
  wire p_7_out_i_45_n_0;
  wire p_7_out_i_46_n_0;
  wire p_7_out_i_47_n_0;
  wire p_7_out_i_48_n_0;
  wire p_7_out_i_49_n_0;
  wire p_7_out_i_4_n_0;
  wire p_7_out_i_4_n_1;
  wire p_7_out_i_4_n_2;
  wire p_7_out_i_4_n_3;
  wire p_7_out_i_4_n_4;
  wire p_7_out_i_4_n_5;
  wire p_7_out_i_4_n_6;
  wire p_7_out_i_4_n_7;
  wire p_7_out_i_50_n_1;
  wire p_7_out_i_50_n_3;
  wire p_7_out_i_50_n_6;
  wire p_7_out_i_50_n_7;
  wire p_7_out_i_51_n_0;
  wire p_7_out_i_51_n_1;
  wire p_7_out_i_51_n_2;
  wire p_7_out_i_51_n_3;
  wire p_7_out_i_51_n_4;
  wire p_7_out_i_51_n_5;
  wire p_7_out_i_51_n_6;
  wire p_7_out_i_51_n_7;
  wire p_7_out_i_52_n_0;
  wire p_7_out_i_52_n_1;
  wire p_7_out_i_52_n_2;
  wire p_7_out_i_52_n_3;
  wire p_7_out_i_52_n_4;
  wire p_7_out_i_52_n_5;
  wire p_7_out_i_52_n_6;
  wire p_7_out_i_52_n_7;
  wire p_7_out_i_53_n_0;
  wire p_7_out_i_53_n_1;
  wire p_7_out_i_53_n_2;
  wire p_7_out_i_53_n_3;
  wire p_7_out_i_53_n_4;
  wire p_7_out_i_53_n_5;
  wire p_7_out_i_53_n_6;
  wire p_7_out_i_53_n_7;
  wire p_7_out_i_54_n_0;
  wire p_7_out_i_54_n_1;
  wire p_7_out_i_54_n_2;
  wire p_7_out_i_54_n_3;
  wire p_7_out_i_54_n_4;
  wire p_7_out_i_54_n_5;
  wire p_7_out_i_54_n_6;
  wire p_7_out_i_54_n_7;
  wire p_7_out_i_55_n_0;
  wire p_7_out_i_56_n_0;
  wire p_7_out_i_57_n_0;
  wire p_7_out_i_58_n_0;
  wire p_7_out_i_59_n_0;
  wire p_7_out_i_5_n_0;
  wire p_7_out_i_5_n_1;
  wire p_7_out_i_5_n_2;
  wire p_7_out_i_5_n_3;
  wire p_7_out_i_5_n_4;
  wire p_7_out_i_5_n_5;
  wire p_7_out_i_5_n_6;
  wire p_7_out_i_5_n_7;
  wire p_7_out_i_60_n_0;
  wire p_7_out_i_61_n_0;
  wire p_7_out_i_62_n_0;
  wire p_7_out_i_63_n_0;
  wire p_7_out_i_64_n_0;
  wire p_7_out_i_65_n_0;
  wire p_7_out_i_66_n_0;
  wire p_7_out_i_67_n_0;
  wire p_7_out_i_68_n_0;
  wire p_7_out_i_69_n_0;
  wire p_7_out_i_6_n_0;
  wire p_7_out_i_6_n_1;
  wire p_7_out_i_6_n_2;
  wire p_7_out_i_6_n_3;
  wire p_7_out_i_6_n_4;
  wire p_7_out_i_6_n_5;
  wire p_7_out_i_6_n_6;
  wire p_7_out_i_6_n_7;
  wire p_7_out_i_70_n_0;
  wire p_7_out_i_71_n_0;
  wire p_7_out_i_7_n_0;
  wire p_7_out_i_8_n_0;
  wire p_7_out_i_9_n_0;
  wire p_7_out_n_100;
  wire p_7_out_n_101;
  wire p_7_out_n_102;
  wire p_7_out_n_103;
  wire p_7_out_n_104;
  wire p_7_out_n_105;
  wire p_7_out_n_90;
  wire p_7_out_n_91;
  wire p_7_out_n_92;
  wire p_7_out_n_93;
  wire p_7_out_n_94;
  wire p_7_out_n_95;
  wire p_7_out_n_96;
  wire p_7_out_n_97;
  wire p_7_out_n_98;
  wire p_7_out_n_99;
  wire [7:0]read_addr;
  wire [3:0]read_addr_IBUF;
  wire [15:0]read_data;
  wire [15:0]read_data_OBUF;
  wire \read_data_OBUF[0]_inst_i_2_n_0 ;
  wire \read_data_OBUF[0]_inst_i_3_n_0 ;
  wire \read_data_OBUF[0]_inst_i_4_n_0 ;
  wire \read_data_OBUF[0]_inst_i_5_n_0 ;
  wire \read_data_OBUF[0]_inst_i_6_n_0 ;
  wire \read_data_OBUF[0]_inst_i_7_n_0 ;
  wire \read_data_OBUF[10]_inst_i_2_n_0 ;
  wire \read_data_OBUF[10]_inst_i_3_n_0 ;
  wire \read_data_OBUF[10]_inst_i_4_n_0 ;
  wire \read_data_OBUF[10]_inst_i_5_n_0 ;
  wire \read_data_OBUF[10]_inst_i_6_n_0 ;
  wire \read_data_OBUF[10]_inst_i_7_n_0 ;
  wire \read_data_OBUF[11]_inst_i_2_n_0 ;
  wire \read_data_OBUF[11]_inst_i_3_n_0 ;
  wire \read_data_OBUF[11]_inst_i_4_n_0 ;
  wire \read_data_OBUF[11]_inst_i_5_n_0 ;
  wire \read_data_OBUF[11]_inst_i_6_n_0 ;
  wire \read_data_OBUF[11]_inst_i_7_n_0 ;
  wire \read_data_OBUF[12]_inst_i_2_n_0 ;
  wire \read_data_OBUF[12]_inst_i_3_n_0 ;
  wire \read_data_OBUF[12]_inst_i_4_n_0 ;
  wire \read_data_OBUF[12]_inst_i_5_n_0 ;
  wire \read_data_OBUF[12]_inst_i_6_n_0 ;
  wire \read_data_OBUF[12]_inst_i_7_n_0 ;
  wire \read_data_OBUF[13]_inst_i_2_n_0 ;
  wire \read_data_OBUF[13]_inst_i_3_n_0 ;
  wire \read_data_OBUF[13]_inst_i_4_n_0 ;
  wire \read_data_OBUF[13]_inst_i_5_n_0 ;
  wire \read_data_OBUF[13]_inst_i_6_n_0 ;
  wire \read_data_OBUF[13]_inst_i_7_n_0 ;
  wire \read_data_OBUF[14]_inst_i_2_n_0 ;
  wire \read_data_OBUF[14]_inst_i_3_n_0 ;
  wire \read_data_OBUF[14]_inst_i_4_n_0 ;
  wire \read_data_OBUF[14]_inst_i_5_n_0 ;
  wire \read_data_OBUF[14]_inst_i_6_n_0 ;
  wire \read_data_OBUF[14]_inst_i_7_n_0 ;
  wire \read_data_OBUF[15]_inst_i_2_n_0 ;
  wire \read_data_OBUF[15]_inst_i_3_n_0 ;
  wire \read_data_OBUF[15]_inst_i_4_n_0 ;
  wire \read_data_OBUF[15]_inst_i_5_n_0 ;
  wire \read_data_OBUF[15]_inst_i_6_n_0 ;
  wire \read_data_OBUF[15]_inst_i_7_n_0 ;
  wire \read_data_OBUF[1]_inst_i_2_n_0 ;
  wire \read_data_OBUF[1]_inst_i_3_n_0 ;
  wire \read_data_OBUF[1]_inst_i_4_n_0 ;
  wire \read_data_OBUF[1]_inst_i_5_n_0 ;
  wire \read_data_OBUF[1]_inst_i_6_n_0 ;
  wire \read_data_OBUF[1]_inst_i_7_n_0 ;
  wire \read_data_OBUF[2]_inst_i_2_n_0 ;
  wire \read_data_OBUF[2]_inst_i_3_n_0 ;
  wire \read_data_OBUF[2]_inst_i_4_n_0 ;
  wire \read_data_OBUF[2]_inst_i_5_n_0 ;
  wire \read_data_OBUF[2]_inst_i_6_n_0 ;
  wire \read_data_OBUF[2]_inst_i_7_n_0 ;
  wire \read_data_OBUF[3]_inst_i_2_n_0 ;
  wire \read_data_OBUF[3]_inst_i_3_n_0 ;
  wire \read_data_OBUF[3]_inst_i_4_n_0 ;
  wire \read_data_OBUF[3]_inst_i_5_n_0 ;
  wire \read_data_OBUF[3]_inst_i_6_n_0 ;
  wire \read_data_OBUF[3]_inst_i_7_n_0 ;
  wire \read_data_OBUF[4]_inst_i_2_n_0 ;
  wire \read_data_OBUF[4]_inst_i_3_n_0 ;
  wire \read_data_OBUF[4]_inst_i_4_n_0 ;
  wire \read_data_OBUF[4]_inst_i_5_n_0 ;
  wire \read_data_OBUF[4]_inst_i_6_n_0 ;
  wire \read_data_OBUF[4]_inst_i_7_n_0 ;
  wire \read_data_OBUF[5]_inst_i_2_n_0 ;
  wire \read_data_OBUF[5]_inst_i_3_n_0 ;
  wire \read_data_OBUF[5]_inst_i_4_n_0 ;
  wire \read_data_OBUF[5]_inst_i_5_n_0 ;
  wire \read_data_OBUF[5]_inst_i_6_n_0 ;
  wire \read_data_OBUF[5]_inst_i_7_n_0 ;
  wire \read_data_OBUF[6]_inst_i_2_n_0 ;
  wire \read_data_OBUF[6]_inst_i_3_n_0 ;
  wire \read_data_OBUF[6]_inst_i_4_n_0 ;
  wire \read_data_OBUF[6]_inst_i_5_n_0 ;
  wire \read_data_OBUF[6]_inst_i_6_n_0 ;
  wire \read_data_OBUF[6]_inst_i_7_n_0 ;
  wire \read_data_OBUF[7]_inst_i_2_n_0 ;
  wire \read_data_OBUF[7]_inst_i_3_n_0 ;
  wire \read_data_OBUF[7]_inst_i_4_n_0 ;
  wire \read_data_OBUF[7]_inst_i_5_n_0 ;
  wire \read_data_OBUF[7]_inst_i_6_n_0 ;
  wire \read_data_OBUF[7]_inst_i_7_n_0 ;
  wire \read_data_OBUF[8]_inst_i_2_n_0 ;
  wire \read_data_OBUF[8]_inst_i_3_n_0 ;
  wire \read_data_OBUF[8]_inst_i_4_n_0 ;
  wire \read_data_OBUF[8]_inst_i_5_n_0 ;
  wire \read_data_OBUF[8]_inst_i_6_n_0 ;
  wire \read_data_OBUF[8]_inst_i_7_n_0 ;
  wire \read_data_OBUF[9]_inst_i_2_n_0 ;
  wire \read_data_OBUF[9]_inst_i_3_n_0 ;
  wire \read_data_OBUF[9]_inst_i_4_n_0 ;
  wire \read_data_OBUF[9]_inst_i_5_n_0 ;
  wire \read_data_OBUF[9]_inst_i_6_n_0 ;
  wire \read_data_OBUF[9]_inst_i_7_n_0 ;
  wire rst_n;
  wire rst_n_IBUF;
  wire start;
  wire start_IBUF;
  wire [2:0]state;
  wire [2:0]state__0;
  wire unamedDSP__0_n_100;
  wire unamedDSP__0_n_101;
  wire unamedDSP__0_n_102;
  wire unamedDSP__0_n_103;
  wire unamedDSP__0_n_104;
  wire unamedDSP__0_n_105;
  wire unamedDSP__0_n_76;
  wire unamedDSP__0_n_77;
  wire unamedDSP__0_n_78;
  wire unamedDSP__0_n_79;
  wire unamedDSP__0_n_80;
  wire unamedDSP__0_n_81;
  wire unamedDSP__0_n_82;
  wire unamedDSP__0_n_83;
  wire unamedDSP__0_n_84;
  wire unamedDSP__0_n_85;
  wire unamedDSP__0_n_86;
  wire unamedDSP__0_n_87;
  wire unamedDSP__0_n_88;
  wire unamedDSP__0_n_89;
  wire unamedDSP__0_n_90;
  wire unamedDSP__0_n_91;
  wire unamedDSP__0_n_92;
  wire unamedDSP__0_n_93;
  wire unamedDSP__0_n_94;
  wire unamedDSP__0_n_95;
  wire unamedDSP__0_n_96;
  wire unamedDSP__0_n_97;
  wire unamedDSP__0_n_98;
  wire unamedDSP__0_n_99;
  wire unamedDSP__1_i_10_n_0;
  wire unamedDSP__1_i_11_n_0;
  wire unamedDSP__1_i_12_n_0;
  wire unamedDSP__1_i_13_n_0;
  wire unamedDSP__1_i_14_n_0;
  wire unamedDSP__1_i_15_n_0;
  wire unamedDSP__1_i_16_n_0;
  wire unamedDSP__1_i_17_n_0;
  wire unamedDSP__1_i_18_n_0;
  wire unamedDSP__1_i_19_n_0;
  wire unamedDSP__1_i_1_n_0;
  wire unamedDSP__1_i_20_n_0;
  wire unamedDSP__1_i_21_n_0;
  wire unamedDSP__1_i_22_n_0;
  wire unamedDSP__1_i_23_n_0;
  wire unamedDSP__1_i_24_n_0;
  wire unamedDSP__1_i_25_n_0;
  wire unamedDSP__1_i_26_n_0;
  wire unamedDSP__1_i_27_n_0;
  wire unamedDSP__1_i_28_n_0;
  wire unamedDSP__1_i_29_n_0;
  wire unamedDSP__1_i_2_n_0;
  wire unamedDSP__1_i_30_n_0;
  wire unamedDSP__1_i_31_n_0;
  wire unamedDSP__1_i_32_n_0;
  wire unamedDSP__1_i_33_n_0;
  wire unamedDSP__1_i_34_n_0;
  wire unamedDSP__1_i_35_n_0;
  wire unamedDSP__1_i_36_n_0;
  wire unamedDSP__1_i_37_n_0;
  wire unamedDSP__1_i_38_n_0;
  wire unamedDSP__1_i_39_n_0;
  wire unamedDSP__1_i_3_n_0;
  wire unamedDSP__1_i_40_n_0;
  wire unamedDSP__1_i_41_n_0;
  wire unamedDSP__1_i_42_n_0;
  wire unamedDSP__1_i_43_n_0;
  wire unamedDSP__1_i_44_n_0;
  wire unamedDSP__1_i_45_n_0;
  wire unamedDSP__1_i_46_n_0;
  wire unamedDSP__1_i_47_n_0;
  wire unamedDSP__1_i_48_n_0;
  wire unamedDSP__1_i_49_n_0;
  wire unamedDSP__1_i_4_n_0;
  wire unamedDSP__1_i_50_n_0;
  wire unamedDSP__1_i_51_n_0;
  wire unamedDSP__1_i_52_n_0;
  wire unamedDSP__1_i_53_n_0;
  wire unamedDSP__1_i_54_n_0;
  wire unamedDSP__1_i_55_n_0;
  wire unamedDSP__1_i_56_n_0;
  wire unamedDSP__1_i_57_n_0;
  wire unamedDSP__1_i_58_n_0;
  wire unamedDSP__1_i_59_n_0;
  wire unamedDSP__1_i_5_n_0;
  wire unamedDSP__1_i_60_n_0;
  wire unamedDSP__1_i_61_n_0;
  wire unamedDSP__1_i_62_n_0;
  wire unamedDSP__1_i_63_n_0;
  wire unamedDSP__1_i_64_n_0;
  wire unamedDSP__1_i_65_n_0;
  wire unamedDSP__1_i_66_n_0;
  wire unamedDSP__1_i_67_n_0;
  wire unamedDSP__1_i_68_n_0;
  wire unamedDSP__1_i_69_n_0;
  wire unamedDSP__1_i_6_n_0;
  wire unamedDSP__1_i_70_n_0;
  wire unamedDSP__1_i_71_n_0;
  wire unamedDSP__1_i_72_n_0;
  wire unamedDSP__1_i_73_n_0;
  wire unamedDSP__1_i_74_n_0;
  wire unamedDSP__1_i_75_n_0;
  wire unamedDSP__1_i_76_n_0;
  wire unamedDSP__1_i_77_n_0;
  wire unamedDSP__1_i_78_n_0;
  wire unamedDSP__1_i_79_n_0;
  wire unamedDSP__1_i_7_n_0;
  wire unamedDSP__1_i_80_n_0;
  wire unamedDSP__1_i_81_n_0;
  wire unamedDSP__1_i_8_n_0;
  wire unamedDSP__1_i_9_n_0;
  wire unamedDSP__1_n_100;
  wire unamedDSP__1_n_101;
  wire unamedDSP__1_n_102;
  wire unamedDSP__1_n_103;
  wire unamedDSP__1_n_104;
  wire unamedDSP__1_n_105;
  wire unamedDSP__1_n_75;
  wire unamedDSP__1_n_76;
  wire unamedDSP__1_n_77;
  wire unamedDSP__1_n_78;
  wire unamedDSP__1_n_79;
  wire unamedDSP__1_n_80;
  wire unamedDSP__1_n_81;
  wire unamedDSP__1_n_82;
  wire unamedDSP__1_n_83;
  wire unamedDSP__1_n_84;
  wire unamedDSP__1_n_85;
  wire unamedDSP__1_n_86;
  wire unamedDSP__1_n_87;
  wire unamedDSP__1_n_88;
  wire unamedDSP__1_n_89;
  wire unamedDSP__1_n_90;
  wire unamedDSP__1_n_91;
  wire unamedDSP__1_n_92;
  wire unamedDSP__1_n_93;
  wire unamedDSP__1_n_94;
  wire unamedDSP__1_n_95;
  wire unamedDSP__1_n_96;
  wire unamedDSP__1_n_97;
  wire unamedDSP__1_n_98;
  wire unamedDSP__1_n_99;
  wire unamedDSP__2_n_100;
  wire unamedDSP__2_n_101;
  wire unamedDSP__2_n_102;
  wire unamedDSP__2_n_103;
  wire unamedDSP__2_n_104;
  wire unamedDSP__2_n_105;
  wire unamedDSP__2_n_76;
  wire unamedDSP__2_n_77;
  wire unamedDSP__2_n_78;
  wire unamedDSP__2_n_79;
  wire unamedDSP__2_n_80;
  wire unamedDSP__2_n_81;
  wire unamedDSP__2_n_82;
  wire unamedDSP__2_n_83;
  wire unamedDSP__2_n_84;
  wire unamedDSP__2_n_85;
  wire unamedDSP__2_n_86;
  wire unamedDSP__2_n_87;
  wire unamedDSP__2_n_88;
  wire unamedDSP__2_n_89;
  wire unamedDSP__2_n_90;
  wire unamedDSP__2_n_91;
  wire unamedDSP__2_n_92;
  wire unamedDSP__2_n_93;
  wire unamedDSP__2_n_94;
  wire unamedDSP__2_n_95;
  wire unamedDSP__2_n_96;
  wire unamedDSP__2_n_97;
  wire unamedDSP__2_n_98;
  wire unamedDSP__2_n_99;
  wire unamedDSP_i_100_n_0;
  wire unamedDSP_i_101_n_0;
  wire unamedDSP_i_102_n_0;
  wire unamedDSP_i_103_n_0;
  wire unamedDSP_i_104_n_0;
  wire unamedDSP_i_105_n_0;
  wire unamedDSP_i_106_n_0;
  wire unamedDSP_i_107_n_0;
  wire unamedDSP_i_108_n_0;
  wire unamedDSP_i_109_n_0;
  wire unamedDSP_i_10_n_0;
  wire unamedDSP_i_110_n_0;
  wire unamedDSP_i_111_n_0;
  wire unamedDSP_i_112_n_0;
  wire unamedDSP_i_113_n_0;
  wire unamedDSP_i_114_n_0;
  wire unamedDSP_i_115_n_0;
  wire unamedDSP_i_116_n_0;
  wire unamedDSP_i_117_n_0;
  wire unamedDSP_i_118_n_0;
  wire unamedDSP_i_119_n_0;
  wire unamedDSP_i_11_n_0;
  wire unamedDSP_i_120_n_0;
  wire unamedDSP_i_121_n_0;
  wire unamedDSP_i_122_n_0;
  wire unamedDSP_i_123_n_0;
  wire unamedDSP_i_124_n_0;
  wire unamedDSP_i_125_n_0;
  wire unamedDSP_i_126_n_0;
  wire unamedDSP_i_127_n_0;
  wire unamedDSP_i_128_n_0;
  wire unamedDSP_i_129_n_0;
  wire unamedDSP_i_12_n_0;
  wire unamedDSP_i_130_n_0;
  wire unamedDSP_i_131_n_0;
  wire unamedDSP_i_132_n_0;
  wire unamedDSP_i_133_n_0;
  wire unamedDSP_i_134_n_0;
  wire unamedDSP_i_135_n_0;
  wire unamedDSP_i_136_n_0;
  wire unamedDSP_i_137_n_0;
  wire unamedDSP_i_138_n_0;
  wire unamedDSP_i_139_n_0;
  wire unamedDSP_i_13_n_0;
  wire unamedDSP_i_140_n_0;
  wire unamedDSP_i_141_n_0;
  wire unamedDSP_i_142_n_0;
  wire unamedDSP_i_143_n_0;
  wire unamedDSP_i_144_n_0;
  wire unamedDSP_i_145_n_0;
  wire unamedDSP_i_146_n_0;
  wire unamedDSP_i_147_n_0;
  wire unamedDSP_i_148_n_0;
  wire unamedDSP_i_149_n_0;
  wire unamedDSP_i_14_n_0;
  wire unamedDSP_i_150_n_0;
  wire unamedDSP_i_151_n_0;
  wire unamedDSP_i_152_n_0;
  wire unamedDSP_i_153_n_0;
  wire unamedDSP_i_154_n_0;
  wire unamedDSP_i_155_n_0;
  wire unamedDSP_i_156_n_0;
  wire unamedDSP_i_157_n_0;
  wire unamedDSP_i_158_n_0;
  wire unamedDSP_i_159_n_0;
  wire unamedDSP_i_15_n_0;
  wire unamedDSP_i_160_n_0;
  wire unamedDSP_i_161_n_0;
  wire unamedDSP_i_162_n_0;
  wire unamedDSP_i_163_n_0;
  wire unamedDSP_i_164_n_0;
  wire unamedDSP_i_165_n_0;
  wire unamedDSP_i_166_n_0;
  wire unamedDSP_i_167_n_0;
  wire unamedDSP_i_168_n_0;
  wire unamedDSP_i_169_n_0;
  wire unamedDSP_i_16_n_0;
  wire unamedDSP_i_170_n_0;
  wire unamedDSP_i_171_n_0;
  wire unamedDSP_i_172_n_0;
  wire unamedDSP_i_173_n_0;
  wire unamedDSP_i_174_n_0;
  wire unamedDSP_i_175_n_0;
  wire unamedDSP_i_176_n_0;
  wire unamedDSP_i_177_n_0;
  wire unamedDSP_i_178_n_0;
  wire unamedDSP_i_179_n_0;
  wire unamedDSP_i_17_n_0;
  wire unamedDSP_i_180_n_0;
  wire unamedDSP_i_181_n_0;
  wire unamedDSP_i_182_n_0;
  wire unamedDSP_i_183_n_0;
  wire unamedDSP_i_184_n_0;
  wire unamedDSP_i_185_n_0;
  wire unamedDSP_i_186_n_0;
  wire unamedDSP_i_187_n_0;
  wire unamedDSP_i_188_n_0;
  wire unamedDSP_i_189_n_0;
  wire unamedDSP_i_18_n_0;
  wire unamedDSP_i_190_n_0;
  wire unamedDSP_i_191_n_0;
  wire unamedDSP_i_192_n_0;
  wire unamedDSP_i_193_n_0;
  wire unamedDSP_i_194_n_0;
  wire unamedDSP_i_195_n_0;
  wire unamedDSP_i_196_n_0;
  wire unamedDSP_i_197_n_0;
  wire unamedDSP_i_198_n_0;
  wire unamedDSP_i_199_n_0;
  wire unamedDSP_i_19_n_0;
  wire unamedDSP_i_1_n_1;
  wire unamedDSP_i_1_n_2;
  wire unamedDSP_i_1_n_3;
  wire unamedDSP_i_1_n_4;
  wire unamedDSP_i_1_n_5;
  wire unamedDSP_i_1_n_6;
  wire unamedDSP_i_1_n_7;
  wire unamedDSP_i_200_n_0;
  wire unamedDSP_i_201_n_0;
  wire unamedDSP_i_202_n_0;
  wire unamedDSP_i_203_n_0;
  wire unamedDSP_i_204_n_0;
  wire unamedDSP_i_205_n_0;
  wire unamedDSP_i_206_n_0;
  wire unamedDSP_i_207_n_0;
  wire unamedDSP_i_208_n_0;
  wire unamedDSP_i_209_n_0;
  wire unamedDSP_i_20_n_0;
  wire unamedDSP_i_210_n_0;
  wire unamedDSP_i_211_n_0;
  wire unamedDSP_i_212_n_0;
  wire unamedDSP_i_213_n_0;
  wire unamedDSP_i_214_n_0;
  wire unamedDSP_i_215_n_0;
  wire unamedDSP_i_216_n_0;
  wire unamedDSP_i_217_n_0;
  wire unamedDSP_i_218_n_0;
  wire unamedDSP_i_219_n_0;
  wire unamedDSP_i_21_n_0;
  wire unamedDSP_i_220_n_0;
  wire unamedDSP_i_221_n_0;
  wire unamedDSP_i_222_n_0;
  wire unamedDSP_i_223_n_0;
  wire unamedDSP_i_224_n_0;
  wire unamedDSP_i_225_n_0;
  wire unamedDSP_i_226_n_0;
  wire unamedDSP_i_227_n_0;
  wire unamedDSP_i_228_n_0;
  wire unamedDSP_i_229_n_0;
  wire unamedDSP_i_22_n_0;
  wire unamedDSP_i_230_n_0;
  wire unamedDSP_i_231_n_0;
  wire unamedDSP_i_232_n_0;
  wire unamedDSP_i_233_n_0;
  wire unamedDSP_i_234_n_0;
  wire unamedDSP_i_235_n_0;
  wire unamedDSP_i_236_n_0;
  wire unamedDSP_i_237_n_0;
  wire unamedDSP_i_238_n_0;
  wire unamedDSP_i_239_n_0;
  wire unamedDSP_i_23_n_0;
  wire unamedDSP_i_240_n_0;
  wire unamedDSP_i_241_n_0;
  wire unamedDSP_i_242_n_0;
  wire unamedDSP_i_243_n_0;
  wire unamedDSP_i_244_n_0;
  wire unamedDSP_i_245_n_0;
  wire unamedDSP_i_246_n_0;
  wire unamedDSP_i_247_n_0;
  wire unamedDSP_i_248_n_0;
  wire unamedDSP_i_249_n_0;
  wire unamedDSP_i_24_n_0;
  wire unamedDSP_i_250_n_0;
  wire unamedDSP_i_251_n_0;
  wire unamedDSP_i_252_n_0;
  wire unamedDSP_i_253_n_0;
  wire unamedDSP_i_254_n_0;
  wire unamedDSP_i_255_n_0;
  wire unamedDSP_i_256_n_0;
  wire unamedDSP_i_257_n_0;
  wire unamedDSP_i_258_n_0;
  wire unamedDSP_i_259_n_0;
  wire unamedDSP_i_25_n_0;
  wire unamedDSP_i_260_n_0;
  wire unamedDSP_i_261_n_0;
  wire unamedDSP_i_262_n_0;
  wire unamedDSP_i_263_n_0;
  wire unamedDSP_i_264_n_0;
  wire unamedDSP_i_26_n_0;
  wire unamedDSP_i_27_n_0;
  wire unamedDSP_i_28_n_0;
  wire unamedDSP_i_29_n_0;
  wire unamedDSP_i_2_n_0;
  wire unamedDSP_i_2_n_1;
  wire unamedDSP_i_2_n_2;
  wire unamedDSP_i_2_n_3;
  wire unamedDSP_i_2_n_4;
  wire unamedDSP_i_2_n_5;
  wire unamedDSP_i_2_n_6;
  wire unamedDSP_i_2_n_7;
  wire unamedDSP_i_30_n_0;
  wire unamedDSP_i_31_n_0;
  wire unamedDSP_i_32_n_0;
  wire unamedDSP_i_33_n_0;
  wire unamedDSP_i_34_n_0;
  wire unamedDSP_i_35_n_0;
  wire unamedDSP_i_36_n_0;
  wire unamedDSP_i_37_n_0;
  wire unamedDSP_i_38_n_0;
  wire unamedDSP_i_39_n_0;
  wire unamedDSP_i_3_n_0;
  wire unamedDSP_i_3_n_1;
  wire unamedDSP_i_3_n_2;
  wire unamedDSP_i_3_n_3;
  wire unamedDSP_i_3_n_4;
  wire unamedDSP_i_3_n_5;
  wire unamedDSP_i_3_n_6;
  wire unamedDSP_i_3_n_7;
  wire unamedDSP_i_40_n_0;
  wire unamedDSP_i_41_n_0;
  wire unamedDSP_i_42_n_0;
  wire unamedDSP_i_43_n_0;
  wire unamedDSP_i_44_n_0;
  wire unamedDSP_i_45_n_0;
  wire unamedDSP_i_46_n_0;
  wire unamedDSP_i_47_n_0;
  wire unamedDSP_i_48_n_0;
  wire unamedDSP_i_49_n_0;
  wire unamedDSP_i_4_n_0;
  wire unamedDSP_i_4_n_1;
  wire unamedDSP_i_4_n_2;
  wire unamedDSP_i_4_n_3;
  wire unamedDSP_i_4_n_4;
  wire unamedDSP_i_4_n_5;
  wire unamedDSP_i_4_n_6;
  wire unamedDSP_i_4_n_7;
  wire unamedDSP_i_50_n_0;
  wire unamedDSP_i_51_n_0;
  wire unamedDSP_i_52_n_0;
  wire unamedDSP_i_53_n_0;
  wire unamedDSP_i_54_n_0;
  wire unamedDSP_i_55_n_0;
  wire unamedDSP_i_56_n_0;
  wire unamedDSP_i_57_n_0;
  wire unamedDSP_i_58_n_0;
  wire unamedDSP_i_59_n_0;
  wire unamedDSP_i_5_n_0;
  wire unamedDSP_i_60_n_0;
  wire unamedDSP_i_61_n_0;
  wire unamedDSP_i_62_n_0;
  wire unamedDSP_i_63_n_0;
  wire unamedDSP_i_64_n_0;
  wire unamedDSP_i_65_n_0;
  wire unamedDSP_i_66_n_0;
  wire unamedDSP_i_67_n_0;
  wire unamedDSP_i_68_n_0;
  wire unamedDSP_i_69_n_0;
  wire unamedDSP_i_6_n_0;
  wire unamedDSP_i_70_n_0;
  wire unamedDSP_i_71_n_0;
  wire unamedDSP_i_72_n_0;
  wire unamedDSP_i_73_n_0;
  wire unamedDSP_i_74_n_0;
  wire unamedDSP_i_75_n_0;
  wire unamedDSP_i_76_n_0;
  wire unamedDSP_i_77_n_0;
  wire unamedDSP_i_78_n_0;
  wire unamedDSP_i_79_n_0;
  wire unamedDSP_i_7_n_0;
  wire unamedDSP_i_80_n_0;
  wire unamedDSP_i_81_n_0;
  wire unamedDSP_i_82_n_0;
  wire unamedDSP_i_83_n_0;
  wire unamedDSP_i_84_n_0;
  wire unamedDSP_i_85_n_0;
  wire unamedDSP_i_86_n_0;
  wire unamedDSP_i_87_n_0;
  wire unamedDSP_i_88_n_0;
  wire unamedDSP_i_89_n_0;
  wire unamedDSP_i_8_n_0;
  wire unamedDSP_i_90_n_0;
  wire unamedDSP_i_91_n_0;
  wire unamedDSP_i_92_n_0;
  wire unamedDSP_i_93_n_0;
  wire unamedDSP_i_94_n_0;
  wire unamedDSP_i_95_n_0;
  wire unamedDSP_i_96_n_0;
  wire unamedDSP_i_97_n_0;
  wire unamedDSP_i_98_n_0;
  wire unamedDSP_i_99_n_0;
  wire unamedDSP_i_9_n_0;
  wire unamedDSP_n_100;
  wire unamedDSP_n_101;
  wire unamedDSP_n_102;
  wire unamedDSP_n_103;
  wire unamedDSP_n_104;
  wire unamedDSP_n_105;
  wire unamedDSP_n_75;
  wire unamedDSP_n_76;
  wire unamedDSP_n_77;
  wire unamedDSP_n_78;
  wire unamedDSP_n_79;
  wire unamedDSP_n_80;
  wire unamedDSP_n_81;
  wire unamedDSP_n_82;
  wire unamedDSP_n_83;
  wire unamedDSP_n_84;
  wire unamedDSP_n_85;
  wire unamedDSP_n_86;
  wire unamedDSP_n_87;
  wire unamedDSP_n_88;
  wire unamedDSP_n_89;
  wire unamedDSP_n_90;
  wire unamedDSP_n_91;
  wire unamedDSP_n_92;
  wire unamedDSP_n_93;
  wire unamedDSP_n_94;
  wire unamedDSP_n_95;
  wire unamedDSP_n_96;
  wire unamedDSP_n_97;
  wire unamedDSP_n_98;
  wire unamedDSP_n_99;
  wire [6:0]zeta_cnt;
  wire \zeta_cnt[1]_i_3_n_0 ;
  wire \zeta_cnt[1]_i_4_n_0 ;
  wire \zeta_cnt[1]_i_5_n_0 ;
  wire \zeta_cnt[1]_i_6_n_0 ;
  wire \zeta_cnt[1]_i_7_n_0 ;
  wire \zeta_cnt[6]_i_1_n_0 ;
  wire \zeta_cnt[6]_i_4_n_0 ;
  wire \zeta_cnt[6]_i_5_n_0 ;
  wire \zeta_cnt_reg[1]_i_2_n_0 ;
  wire \zeta_cnt_reg[1]_i_2_n_1 ;
  wire \zeta_cnt_reg[1]_i_2_n_2 ;
  wire \zeta_cnt_reg[1]_i_2_n_3 ;
  wire \zeta_cnt_reg[1]_i_2_n_4 ;
  wire \zeta_cnt_reg[1]_i_2_n_5 ;
  wire \zeta_cnt_reg[1]_i_2_n_6 ;
  wire \zeta_cnt_reg[1]_i_2_n_7 ;
  wire \zeta_cnt_reg[6]_i_3_n_3 ;
  wire \zeta_cnt_reg[6]_i_3_n_6 ;
  wire \zeta_cnt_reg[6]_i_3_n_7 ;
  wire \zeta_cnt_reg_n_0_[0] ;
  wire \zeta_cnt_reg_n_0_[1] ;
  wire \zeta_cnt_reg_n_0_[2] ;
  wire \zeta_cnt_reg_n_0_[3] ;
  wire \zeta_cnt_reg_n_0_[4] ;
  wire \zeta_cnt_reg_n_0_[5] ;
  wire \zeta_cnt_reg_n_0_[6] ;
  wire [3:0]\NLW_block_cnt_reg[7]_i_52_O_UNCONNECTED ;
  wire [3:0]\NLW_block_cnt_reg[7]_i_57_O_UNCONNECTED ;
  wire [3:0]\NLW_block_cnt_reg[7]_i_62_O_UNCONNECTED ;
  wire [3:0]\NLW_block_cnt_reg[7]_i_67_O_UNCONNECTED ;
  wire [3:0]\NLW_block_cnt_reg[7]_i_72_O_UNCONNECTED ;
  wire [3:0]NLW_p_1_out_i_50_CO_UNCONNECTED;
  wire [3:0]NLW_p_4_out_i_50_CO_UNCONNECTED;
  wire [3:0]NLW_p_7_out_i_50_CO_UNCONNECTED;

  LUT6 #(
    .INIT(64'h00FFF000FFDDFFFF)) 
    \FSM_sequential_state[0]_i_1 
       (.I0(\FSM_sequential_state[0]_i_2_n_0 ),
        .I1(inv_mode_reg_n_0),
        .I2(\block_cnt_reg[7]_i_3_n_0 ),
        .I3(state[1]),
        .I4(state[2]),
        .I5(state[0]),
        .O(state__0[0]));
  LUT2 #(
    .INIT(4'h8)) 
    \FSM_sequential_state[0]_i_2 
       (.I0(\layer_idx_reg_n_0_[2] ),
        .I1(\layer_idx_reg_n_0_[1] ),
        .O(\FSM_sequential_state[0]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h6666666676666666)) 
    \FSM_sequential_state[1]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\layer_idx_reg_n_0_[1] ),
        .I3(\layer_idx_reg_n_0_[2] ),
        .I4(state[2]),
        .I5(inv_mode_reg_n_0),
        .O(state__0[1]));
  LUT6 #(
    .INIT(64'hFFCEC3CEFFFEC3FE)) 
    \FSM_sequential_state[2]_i_1 
       (.I0(start_IBUF),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(\cnt_reg_n_0_[4] ),
        .I5(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .O(\FSM_sequential_state[2]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h9009)) 
    \FSM_sequential_state[2]_i_10 
       (.I0(\j_cnt_reg_n_0_[2] ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\j_cnt_reg_n_0_[3] ),
        .I3(\len_reg_n_0_[3] ),
        .O(\FSM_sequential_state[2]_i_10_n_0 ));
  LUT3 #(
    .INIT(8'h09)) 
    \FSM_sequential_state[2]_i_11 
       (.I0(\j_cnt_reg_n_0_[1] ),
        .I1(\len_reg_n_0_[1] ),
        .I2(a_i_96_n_0),
        .O(\FSM_sequential_state[2]_i_11_n_0 ));
  LUT6 #(
    .INIT(64'h00FFFF880F000000)) 
    \FSM_sequential_state[2]_i_2 
       (.I0(\layer_idx_reg_n_0_[2] ),
        .I1(\layer_idx_reg_n_0_[1] ),
        .I2(\block_cnt_reg[7]_i_3_n_0 ),
        .I3(state[1]),
        .I4(state[0]),
        .I5(state[2]),
        .O(state__0[2]));
  LUT4 #(
    .INIT(16'h44D4)) 
    \FSM_sequential_state[2]_i_4 
       (.I0(\j_cnt_reg_n_0_[7] ),
        .I1(\len_reg_n_0_[7] ),
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
       (.I0(\len_reg_n_0_[7] ),
        .I1(\j_cnt_reg_n_0_[7] ),
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
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(state__0[0]),
        .Q(state[0]));
  (* FSM_ENCODED_STATES = "S_IDLE:000,S_BUTTER:010,S_NEXT_BLOCK:011,S_DONE:111,S_NEXT_LAYER:100,S_SCALE:101,S_REDUCE:110,S_LAYER_SETUP:001" *) 
  FDCE \FSM_sequential_state_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\FSM_sequential_state[2]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(state__0[1]),
        .Q(state[1]));
  (* FSM_ENCODED_STATES = "S_IDLE:000,S_BUTTER:010,S_NEXT_BLOCK:011,S_DONE:111,S_NEXT_LAYER:100,S_SCALE:101,S_REDUCE:110,S_LAYER_SETUP:001" *) 
  FDCE \FSM_sequential_state_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\FSM_sequential_state[2]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
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
  GND GND_1
       (.G(GND_2));
  VCC VCC
       (.P(\<const1> ));
  VCC VCC_1
       (.P(VCC_2));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    a
       (.A({g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,a_i_17_n_0,a_i_18_n_0,a_i_19_n_0,a_i_20_n_0,a_i_21_n_0,a_i_22_n_0,a_i_23_n_0,a_i_24_n_0,a_i_25_n_0,a_i_26_n_0,a_i_27_n_0,a_i_28_n_0}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .B({a_i_1_n_0,a_i_1_n_0,a_i_1_n_0,a_i_2_n_0,a_i_3_n_0,a_i_4_n_0,a_i_5_n_0,a_i_6_n_0,a_i_7_n_0,a_i_8_n_0,a_i_9_n_0,a_i_10_n_0,a_i_11_n_0,a_i_12_n_0,a_i_13_n_0,a_i_14_n_0,a_i_15_n_0,a_i_16_n_0}),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const0> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({a_n_74,a_n_75,a_n_76,a_n_77,a_n_78,a_n_79,a_n_80,a_n_81,a_n_82,a_n_83,a_n_84,a_n_85,a_n_86,a_n_87,a_n_88,a_n_89,a_n_90,a_n_91,a_n_92,a_n_93,a_n_94,a_n_95,a_n_96,a_n_97,a_n_98,a_n_99,a_n_100,a_n_101,a_n_102,a_n_103,a_n_104,a_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    a__0
       (.A({g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,a_i_17_n_0,a_i_18_n_0,a_i_19_n_0,a_i_20_n_0,a_i_21_n_0,a_i_22_n_0,a_i_23_n_0,a_i_24_n_0,a_i_25_n_0,a_i_26_n_0,a_i_27_n_0,a_i_28_n_0}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .B({p_0_in__2[15],p_0_in__2[15],p_0_in__2}),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const0> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({a__0_n_74,a__0_n_75,a__0_n_76,a__0_n_77,a__0_n_78,a__0_n_79,a__0_n_80,a__0_n_81,a__0_n_82,a__0_n_83,a__0_n_84,a__0_n_85,a__0_n_86,a__0_n_87,a__0_n_88,a__0_n_89,a__0_n_90,a__0_n_91,a__0_n_92,a__0_n_93,a__0_n_94,a__0_n_95,a__0_n_96,a__0_n_97,a__0_n_98,a__0_n_99,a__0_n_100,a__0_n_101,a__0_n_102,a__0_n_103,a__0_n_104,a__0_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 a__0_i_1
       (.CI(a__0_i_2_n_0),
        .CO({a__0_i_1_n_1,a__0_i_1_n_2,a__0_i_1_n_3}),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,a_i_2_n_0,a_i_3_n_0,a_i_4_n_0}),
        .O(p_0_in__2[15:12]),
        .S({a__0_i_5_n_0,a__0_i_6_n_0,a__0_i_7_n_0,a__0_i_8_n_0}));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_10
       (.I0(unamedDSP_i_52_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_52_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_51_n_0),
        .I5(unamedDSP_i_48_n_0),
        .O(a__0_i_10_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_11
       (.I0(unamedDSP_i_53_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_56_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_55_n_0),
        .I5(unamedDSP_i_49_n_0),
        .O(a__0_i_11_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_12
       (.I0(unamedDSP_i_54_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_60_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_59_n_0),
        .I5(unamedDSP_i_50_n_0),
        .O(a__0_i_12_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_13
       (.I0(unamedDSP_i_59_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_64_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_63_n_0),
        .I5(unamedDSP_i_55_n_0),
        .O(a__0_i_13_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_14
       (.I0(unamedDSP_i_60_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_68_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_67_n_0),
        .I5(unamedDSP_i_56_n_0),
        .O(a__0_i_14_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_15
       (.I0(unamedDSP_i_61_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_72_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_71_n_0),
        .I5(unamedDSP_i_57_n_0),
        .O(a__0_i_15_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_16
       (.I0(unamedDSP_i_62_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_76_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_75_n_0),
        .I5(unamedDSP_i_58_n_0),
        .O(a__0_i_16_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_17
       (.I0(unamedDSP_i_67_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_80_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_79_n_0),
        .I5(unamedDSP_i_63_n_0),
        .O(a__0_i_17_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_18
       (.I0(unamedDSP_i_68_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_84_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_83_n_0),
        .I5(unamedDSP_i_64_n_0),
        .O(a__0_i_18_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_19
       (.I0(unamedDSP_i_69_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_88_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_87_n_0),
        .I5(unamedDSP_i_65_n_0),
        .O(a__0_i_19_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 a__0_i_2
       (.CI(a__0_i_3_n_0),
        .CO({a__0_i_2_n_0,a__0_i_2_n_1,a__0_i_2_n_2,a__0_i_2_n_3}),
        .CYINIT(\<const0> ),
        .DI({a_i_5_n_0,a_i_6_n_0,a_i_7_n_0,a_i_8_n_0}),
        .O(p_0_in__2[11:8]),
        .S({a__0_i_9_n_0,a__0_i_10_n_0,a__0_i_11_n_0,a__0_i_12_n_0}));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_20
       (.I0(unamedDSP_i_70_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_92_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_91_n_0),
        .I5(unamedDSP_i_66_n_0),
        .O(a__0_i_20_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 a__0_i_3
       (.CI(a__0_i_4_n_0),
        .CO({a__0_i_3_n_0,a__0_i_3_n_1,a__0_i_3_n_2,a__0_i_3_n_3}),
        .CYINIT(\<const0> ),
        .DI({a_i_9_n_0,a_i_10_n_0,a_i_11_n_0,a_i_12_n_0}),
        .O(p_0_in__2[7:4]),
        .S({a__0_i_13_n_0,a__0_i_14_n_0,a__0_i_15_n_0,a__0_i_16_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 a__0_i_4
       (.CI(\<const0> ),
        .CO({a__0_i_4_n_0,a__0_i_4_n_1,a__0_i_4_n_2,a__0_i_4_n_3}),
        .CYINIT(\<const1> ),
        .DI({a_i_13_n_0,a_i_14_n_0,a_i_15_n_0,a_i_16_n_0}),
        .O(p_0_in__2[3:0]),
        .S({a__0_i_17_n_0,a__0_i_18_n_0,a__0_i_19_n_0,a__0_i_20_n_0}));
  LUT6 #(
    .INIT(64'hAA6AAA6A9959AA6A)) 
    a__0_i_5
       (.I0(unamedDSP_i_43_n_0),
        .I1(a_i_34_n_0),
        .I2(unamedDSP_i_42_n_0),
        .I3(unamedDSP_i_41_n_0),
        .I4(unamedDSP_i_40_n_0),
        .I5(unamedDSP_i_39_n_0),
        .O(a__0_i_5_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_6
       (.I0(unamedDSP_i_44_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_36_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_35_n_0),
        .I5(unamedDSP_i_36_n_0),
        .O(a__0_i_6_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_7
       (.I0(unamedDSP_i_45_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_40_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_39_n_0),
        .I5(unamedDSP_i_37_n_0),
        .O(a__0_i_7_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_8
       (.I0(unamedDSP_i_46_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_44_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_43_n_0),
        .I5(unamedDSP_i_38_n_0),
        .O(a__0_i_8_n_0));
  LUT6 #(
    .INIT(64'h111DDD1DEEE222E2)) 
    a__0_i_9
       (.I0(unamedDSP_i_51_n_0),
        .I1(a_i_34_n_0),
        .I2(a_i_48_n_0),
        .I3(a_i_33_n_0),
        .I4(a_i_47_n_0),
        .I5(unamedDSP_i_47_n_0),
        .O(a__0_i_9_n_0));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    a__1
       (.A({unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_2_n_0,unamedDSP__1_i_3_n_0,unamedDSP__1_i_4_n_0,unamedDSP__1_i_5_n_0,unamedDSP__1_i_6_n_0,unamedDSP__1_i_7_n_0,unamedDSP__1_i_8_n_0,unamedDSP__1_i_9_n_0,unamedDSP__1_i_10_n_0,unamedDSP__1_i_11_n_0,unamedDSP__1_i_12_n_0,unamedDSP__1_i_13_n_0,unamedDSP__1_i_14_n_0,unamedDSP__1_i_15_n_0,unamedDSP__1_i_16_n_0}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .B({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const0> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({a__1_n_77,a__1_n_78,a__1_n_79,a__1_n_80,a__1_n_81,a__1_n_82,a__1_n_83,a__1_n_84,a__1_n_85,a__1_n_86,a__1_n_87,a__1_n_88,a__1_n_89,a__2}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  LUT6 #(
    .INIT(64'h0F0F00FF55553333)) 
    a_i_1
       (.I0(a_i_29_n_0),
        .I1(a_i_30_n_0),
        .I2(a_i_31_n_0),
        .I3(a_i_32_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_34_n_0),
        .O(a_i_1_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_10
       (.I0(a_i_67_n_0),
        .I1(a_i_68_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_69_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_70_n_0),
        .O(a_i_10_n_0));
  (* SOFT_HLUTNM = "soft_lutpair77" *) 
  LUT3 #(
    .INIT(8'h96)) 
    a_i_100
       (.I0(\j_cnt_reg_n_0_[2] ),
        .I1(a_i_98_n_6),
        .I2(\len_reg_n_0_[2] ),
        .O(a_i_100_n_0));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT5 #(
    .INIT(32'h7FF7F77F)) 
    a_i_101
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\len_reg_n_0_[0] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\j_cnt_reg_n_0_[1] ),
        .I4(a_i_98_n_7),
        .O(a_i_101_n_0));
  LUT6 #(
    .INIT(64'h17E8E817E81717E8)) 
    a_i_102
       (.I0(a_i_98_n_6),
        .I1(\j_cnt_reg_n_0_[2] ),
        .I2(\len_reg_n_0_[2] ),
        .I3(\len_reg_n_0_[3] ),
        .I4(\j_cnt_reg_n_0_[3] ),
        .I5(\coeff_reg[0][15]_i_22_n_7 ),
        .O(a_i_102_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    a_i_103
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg_n_0_[3] ),
        .O(a_i_103_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    a_i_104
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg_n_0_[2] ),
        .O(a_i_104_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    a_i_105
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg_n_0_[1] ),
        .O(a_i_105_n_0));
  LUT4 #(
    .INIT(16'h7888)) 
    a_i_106
       (.I0(\block_cnt_reg_n_0_[3] ),
        .I1(\len_reg_n_0_[0] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\block_cnt_reg_n_0_[2] ),
        .O(a_i_106_n_0));
  LUT4 #(
    .INIT(16'h7888)) 
    a_i_107
       (.I0(\block_cnt_reg_n_0_[2] ),
        .I1(\len_reg_n_0_[0] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\block_cnt_reg_n_0_[1] ),
        .O(a_i_107_n_0));
  LUT4 #(
    .INIT(16'h7888)) 
    a_i_108
       (.I0(\block_cnt_reg_n_0_[1] ),
        .I1(\len_reg_n_0_[0] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\block_cnt_reg_n_0_[0] ),
        .O(a_i_108_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    a_i_109
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg_n_0_[0] ),
        .O(a_i_109_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_11
       (.I0(a_i_71_n_0),
        .I1(a_i_72_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_73_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_74_n_0),
        .O(a_i_11_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_12
       (.I0(a_i_75_n_0),
        .I1(a_i_76_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_77_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_78_n_0),
        .O(a_i_12_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_13
       (.I0(a_i_79_n_0),
        .I1(a_i_80_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_81_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_82_n_0),
        .O(a_i_13_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_14
       (.I0(a_i_83_n_0),
        .I1(a_i_84_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_85_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_86_n_0),
        .O(a_i_14_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_15
       (.I0(a_i_87_n_0),
        .I1(a_i_88_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_89_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_90_n_0),
        .O(a_i_15_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_16
       (.I0(a_i_91_n_0),
        .I1(a_i_92_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_93_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_94_n_0),
        .O(a_i_16_n_0));
  MUXF7 a_i_17
       (.I0(g0_b11_n_0),
        .I1(g1_b11_n_0),
        .O(a_i_17_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  MUXF7 a_i_18
       (.I0(g0_b10_n_0),
        .I1(g1_b10_n_0),
        .O(a_i_18_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  MUXF7 a_i_19
       (.I0(g0_b9_n_0),
        .I1(g1_b9_n_0),
        .O(a_i_19_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_2
       (.I0(a_i_35_n_0),
        .I1(a_i_36_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_37_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_38_n_0),
        .O(a_i_2_n_0));
  MUXF7 a_i_20
       (.I0(g0_b8_n_0),
        .I1(g1_b8_n_0),
        .O(a_i_20_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  MUXF7 a_i_21
       (.I0(g0_b7_n_0),
        .I1(g1_b7_n_0),
        .O(a_i_21_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  MUXF7 a_i_22
       (.I0(g0_b6_n_0),
        .I1(g1_b6_n_0),
        .O(a_i_22_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  MUXF7 a_i_23
       (.I0(g0_b5_n_0),
        .I1(g1_b5_n_0),
        .O(a_i_23_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  MUXF7 a_i_24
       (.I0(g0_b4_n_0),
        .I1(g1_b4_n_0),
        .O(a_i_24_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  MUXF7 a_i_25
       (.I0(g0_b3_n_0),
        .I1(g1_b3_n_0),
        .O(a_i_25_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  MUXF7 a_i_26
       (.I0(g0_b2_n_0),
        .I1(g1_b2_n_0),
        .O(a_i_26_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  MUXF7 a_i_27
       (.I0(g0_b1_n_0),
        .I1(g1_b1_n_0),
        .O(a_i_27_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  MUXF7 a_i_28
       (.I0(g0_b0_n_0),
        .I1(g1_b0_n_0),
        .O(a_i_28_n_0),
        .S(\zeta_cnt_reg_n_0_[6] ));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    a_i_29
       (.I0(\coeff_reg_n_0_[9][15] ),
        .I1(\coeff_reg_n_0_[8][15] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][15] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][15] ),
        .O(a_i_29_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_3
       (.I0(a_i_39_n_0),
        .I1(a_i_40_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_41_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_42_n_0),
        .O(a_i_3_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    a_i_30
       (.I0(\coeff_reg_n_0_[13][15] ),
        .I1(\coeff_reg_n_0_[12][15] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][15] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][15] ),
        .O(a_i_30_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    a_i_31
       (.I0(\coeff_reg_n_0_[1][15] ),
        .I1(\coeff_reg_n_0_[0][15] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][15] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][15] ),
        .O(a_i_31_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    a_i_32
       (.I0(\coeff_reg_n_0_[5][15] ),
        .I1(\coeff_reg_n_0_[4][15] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][15] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][15] ),
        .O(a_i_32_n_0));
  LUT6 #(
    .INIT(64'h693C3C963C9696C3)) 
    a_i_33
       (.I0(a_i_97_n_0),
        .I1(a_i_98_n_6),
        .I2(a_i_99_n_0),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(\len_reg_n_0_[1] ),
        .O(a_i_33_n_0));
  LUT6 #(
    .INIT(64'hA880FEEA577F0115)) 
    a_i_34
       (.I0(a_i_100_n_0),
        .I1(a_i_98_n_7),
        .I2(\j_cnt_reg_n_0_[1] ),
        .I3(\len_reg_n_0_[1] ),
        .I4(a_i_101_n_0),
        .I5(a_i_102_n_0),
        .O(a_i_34_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_35
       (.I0(\coeff_reg_n_0_[1][14] ),
        .I1(\coeff_reg_n_0_[0][14] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][14] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][14] ),
        .O(a_i_35_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_36
       (.I0(\coeff_reg_n_0_[5][14] ),
        .I1(\coeff_reg_n_0_[4][14] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][14] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][14] ),
        .O(a_i_36_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_37
       (.I0(\coeff_reg_n_0_[9][14] ),
        .I1(\coeff_reg_n_0_[8][14] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][14] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][14] ),
        .O(a_i_37_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_38
       (.I0(\coeff_reg_n_0_[13][14] ),
        .I1(\coeff_reg_n_0_[12][14] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][14] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][14] ),
        .O(a_i_38_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_39
       (.I0(\coeff_reg_n_0_[1][13] ),
        .I1(\coeff_reg_n_0_[0][13] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][13] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][13] ),
        .O(a_i_39_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_4
       (.I0(a_i_43_n_0),
        .I1(a_i_44_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_45_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_46_n_0),
        .O(a_i_4_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_40
       (.I0(\coeff_reg_n_0_[5][13] ),
        .I1(\coeff_reg_n_0_[4][13] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][13] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][13] ),
        .O(a_i_40_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_41
       (.I0(\coeff_reg_n_0_[9][13] ),
        .I1(\coeff_reg_n_0_[8][13] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][13] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][13] ),
        .O(a_i_41_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_42
       (.I0(\coeff_reg_n_0_[13][13] ),
        .I1(\coeff_reg_n_0_[12][13] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][13] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][13] ),
        .O(a_i_42_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_43
       (.I0(\coeff_reg_n_0_[1][12] ),
        .I1(\coeff_reg_n_0_[0][12] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][12] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][12] ),
        .O(a_i_43_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_44
       (.I0(\coeff_reg_n_0_[5][12] ),
        .I1(\coeff_reg_n_0_[4][12] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][12] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][12] ),
        .O(a_i_44_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_45
       (.I0(\coeff_reg_n_0_[9][12] ),
        .I1(\coeff_reg_n_0_[8][12] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][12] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][12] ),
        .O(a_i_45_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_46
       (.I0(\coeff_reg_n_0_[13][12] ),
        .I1(\coeff_reg_n_0_[12][12] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][12] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][12] ),
        .O(a_i_46_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_47
       (.I0(\coeff_reg_n_0_[1][11] ),
        .I1(\coeff_reg_n_0_[0][11] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][11] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][11] ),
        .O(a_i_47_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_48
       (.I0(\coeff_reg_n_0_[5][11] ),
        .I1(\coeff_reg_n_0_[4][11] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][11] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][11] ),
        .O(a_i_48_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_49
       (.I0(\coeff_reg_n_0_[9][11] ),
        .I1(\coeff_reg_n_0_[8][11] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][11] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][11] ),
        .O(a_i_49_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_5
       (.I0(a_i_47_n_0),
        .I1(a_i_48_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_49_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_50_n_0),
        .O(a_i_5_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_50
       (.I0(\coeff_reg_n_0_[13][11] ),
        .I1(\coeff_reg_n_0_[12][11] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][11] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][11] ),
        .O(a_i_50_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_51
       (.I0(\coeff_reg_n_0_[1][10] ),
        .I1(\coeff_reg_n_0_[0][10] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][10] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][10] ),
        .O(a_i_51_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_52
       (.I0(\coeff_reg_n_0_[5][10] ),
        .I1(\coeff_reg_n_0_[4][10] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][10] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][10] ),
        .O(a_i_52_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_53
       (.I0(\coeff_reg_n_0_[9][10] ),
        .I1(\coeff_reg_n_0_[8][10] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][10] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][10] ),
        .O(a_i_53_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_54
       (.I0(\coeff_reg_n_0_[13][10] ),
        .I1(\coeff_reg_n_0_[12][10] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][10] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][10] ),
        .O(a_i_54_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_55
       (.I0(\coeff_reg_n_0_[1][9] ),
        .I1(\coeff_reg_n_0_[0][9] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][9] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][9] ),
        .O(a_i_55_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_56
       (.I0(\coeff_reg_n_0_[5][9] ),
        .I1(\coeff_reg_n_0_[4][9] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][9] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][9] ),
        .O(a_i_56_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_57
       (.I0(\coeff_reg_n_0_[9][9] ),
        .I1(\coeff_reg_n_0_[8][9] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][9] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][9] ),
        .O(a_i_57_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_58
       (.I0(\coeff_reg_n_0_[13][9] ),
        .I1(\coeff_reg_n_0_[12][9] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][9] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][9] ),
        .O(a_i_58_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_59
       (.I0(\coeff_reg_n_0_[1][8] ),
        .I1(\coeff_reg_n_0_[0][8] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][8] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][8] ),
        .O(a_i_59_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_6
       (.I0(a_i_51_n_0),
        .I1(a_i_52_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_53_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_54_n_0),
        .O(a_i_6_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_60
       (.I0(\coeff_reg_n_0_[5][8] ),
        .I1(\coeff_reg_n_0_[4][8] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][8] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][8] ),
        .O(a_i_60_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_61
       (.I0(\coeff_reg_n_0_[9][8] ),
        .I1(\coeff_reg_n_0_[8][8] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][8] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][8] ),
        .O(a_i_61_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_62
       (.I0(\coeff_reg_n_0_[13][8] ),
        .I1(\coeff_reg_n_0_[12][8] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][8] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][8] ),
        .O(a_i_62_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_63
       (.I0(\coeff_reg_n_0_[1][7] ),
        .I1(\coeff_reg_n_0_[0][7] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][7] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][7] ),
        .O(a_i_63_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_64
       (.I0(\coeff_reg_n_0_[5][7] ),
        .I1(\coeff_reg_n_0_[4][7] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][7] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][7] ),
        .O(a_i_64_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_65
       (.I0(\coeff_reg_n_0_[9][7] ),
        .I1(\coeff_reg_n_0_[8][7] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][7] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][7] ),
        .O(a_i_65_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_66
       (.I0(\coeff_reg_n_0_[13][7] ),
        .I1(\coeff_reg_n_0_[12][7] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][7] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][7] ),
        .O(a_i_66_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_67
       (.I0(\coeff_reg_n_0_[1][6] ),
        .I1(\coeff_reg_n_0_[0][6] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][6] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][6] ),
        .O(a_i_67_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_68
       (.I0(\coeff_reg_n_0_[5][6] ),
        .I1(\coeff_reg_n_0_[4][6] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][6] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][6] ),
        .O(a_i_68_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_69
       (.I0(\coeff_reg_n_0_[9][6] ),
        .I1(\coeff_reg_n_0_[8][6] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][6] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][6] ),
        .O(a_i_69_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_7
       (.I0(a_i_55_n_0),
        .I1(a_i_56_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_57_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_58_n_0),
        .O(a_i_7_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_70
       (.I0(\coeff_reg_n_0_[13][6] ),
        .I1(\coeff_reg_n_0_[12][6] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][6] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][6] ),
        .O(a_i_70_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_71
       (.I0(\coeff_reg_n_0_[1][5] ),
        .I1(\coeff_reg_n_0_[0][5] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][5] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][5] ),
        .O(a_i_71_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_72
       (.I0(\coeff_reg_n_0_[5][5] ),
        .I1(\coeff_reg_n_0_[4][5] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][5] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][5] ),
        .O(a_i_72_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_73
       (.I0(\coeff_reg_n_0_[9][5] ),
        .I1(\coeff_reg_n_0_[8][5] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][5] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][5] ),
        .O(a_i_73_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_74
       (.I0(\coeff_reg_n_0_[13][5] ),
        .I1(\coeff_reg_n_0_[12][5] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][5] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][5] ),
        .O(a_i_74_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_75
       (.I0(\coeff_reg_n_0_[1][4] ),
        .I1(\coeff_reg_n_0_[0][4] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][4] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][4] ),
        .O(a_i_75_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_76
       (.I0(\coeff_reg_n_0_[5][4] ),
        .I1(\coeff_reg_n_0_[4][4] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][4] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][4] ),
        .O(a_i_76_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_77
       (.I0(\coeff_reg_n_0_[9][4] ),
        .I1(\coeff_reg_n_0_[8][4] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][4] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][4] ),
        .O(a_i_77_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_78
       (.I0(\coeff_reg_n_0_[13][4] ),
        .I1(\coeff_reg_n_0_[12][4] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][4] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][4] ),
        .O(a_i_78_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_79
       (.I0(\coeff_reg_n_0_[1][3] ),
        .I1(\coeff_reg_n_0_[0][3] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][3] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][3] ),
        .O(a_i_79_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_8
       (.I0(a_i_59_n_0),
        .I1(a_i_60_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_61_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_62_n_0),
        .O(a_i_8_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_80
       (.I0(\coeff_reg_n_0_[5][3] ),
        .I1(\coeff_reg_n_0_[4][3] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][3] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][3] ),
        .O(a_i_80_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_81
       (.I0(\coeff_reg_n_0_[9][3] ),
        .I1(\coeff_reg_n_0_[8][3] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][3] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][3] ),
        .O(a_i_81_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_82
       (.I0(\coeff_reg_n_0_[13][3] ),
        .I1(\coeff_reg_n_0_[12][3] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][3] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][3] ),
        .O(a_i_82_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_83
       (.I0(\coeff_reg_n_0_[1][2] ),
        .I1(\coeff_reg_n_0_[0][2] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][2] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][2] ),
        .O(a_i_83_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_84
       (.I0(\coeff_reg_n_0_[5][2] ),
        .I1(\coeff_reg_n_0_[4][2] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][2] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][2] ),
        .O(a_i_84_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_85
       (.I0(\coeff_reg_n_0_[9][2] ),
        .I1(\coeff_reg_n_0_[8][2] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][2] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][2] ),
        .O(a_i_85_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_86
       (.I0(\coeff_reg_n_0_[13][2] ),
        .I1(\coeff_reg_n_0_[12][2] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][2] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][2] ),
        .O(a_i_86_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_87
       (.I0(\coeff_reg_n_0_[1][1] ),
        .I1(\coeff_reg_n_0_[0][1] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][1] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][1] ),
        .O(a_i_87_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_88
       (.I0(\coeff_reg_n_0_[5][1] ),
        .I1(\coeff_reg_n_0_[4][1] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][1] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][1] ),
        .O(a_i_88_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_89
       (.I0(\coeff_reg_n_0_[9][1] ),
        .I1(\coeff_reg_n_0_[8][1] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][1] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][1] ),
        .O(a_i_89_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_9
       (.I0(a_i_63_n_0),
        .I1(a_i_64_n_0),
        .I2(a_i_34_n_0),
        .I3(a_i_65_n_0),
        .I4(a_i_33_n_0),
        .I5(a_i_66_n_0),
        .O(a_i_9_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_90
       (.I0(\coeff_reg_n_0_[13][1] ),
        .I1(\coeff_reg_n_0_[12][1] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][1] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][1] ),
        .O(a_i_90_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_91
       (.I0(\coeff_reg_n_0_[1][0] ),
        .I1(\coeff_reg_n_0_[0][0] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[3][0] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[2][0] ),
        .O(a_i_91_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_92
       (.I0(\coeff_reg_n_0_[5][0] ),
        .I1(\coeff_reg_n_0_[4][0] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[7][0] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[6][0] ),
        .O(a_i_92_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_93
       (.I0(\coeff_reg_n_0_[9][0] ),
        .I1(\coeff_reg_n_0_[8][0] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[11][0] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[10][0] ),
        .O(a_i_93_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    a_i_94
       (.I0(\coeff_reg_n_0_[13][0] ),
        .I1(\coeff_reg_n_0_[12][0] ),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[15][0] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[14][0] ),
        .O(a_i_94_n_0));
  LUT5 #(
    .INIT(32'h87787887)) 
    a_i_95
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\len_reg_n_0_[0] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\j_cnt_reg_n_0_[1] ),
        .I4(a_i_98_n_7),
        .O(a_i_95_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    a_i_96
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .O(a_i_96_n_0));
  (* SOFT_HLUTNM = "soft_lutpair60" *) 
  LUT2 #(
    .INIT(4'h7)) 
    a_i_97
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\len_reg_n_0_[0] ),
        .O(a_i_97_n_0));
  CARRY4 a_i_98
       (.CI(\<const0> ),
        .CO({a_i_98_n_0,a_i_98_n_1,a_i_98_n_2,a_i_98_n_3}),
        .CYINIT(\<const0> ),
        .DI({a_i_103_n_0,a_i_104_n_0,a_i_105_n_0,\<const0> }),
        .O({a_i_98_n_4,a_i_98_n_5,a_i_98_n_6,a_i_98_n_7}),
        .S({a_i_106_n_0,a_i_107_n_0,a_i_108_n_0,a_i_109_n_0}));
  (* SOFT_HLUTNM = "soft_lutpair179" *) 
  LUT2 #(
    .INIT(4'h6)) 
    a_i_99
       (.I0(\len_reg_n_0_[2] ),
        .I1(\j_cnt_reg_n_0_[2] ),
        .O(a_i_99_n_0));
  (* SOFT_HLUTNM = "soft_lutpair178" *) 
  LUT2 #(
    .INIT(4'h4)) 
    \block_cnt[0]_i_1 
       (.I0(\block_cnt_reg_n_0_[0] ),
        .I1(state[1]),
        .O(block_cnt[0]));
  (* SOFT_HLUTNM = "soft_lutpair178" *) 
  LUT3 #(
    .INIT(8'h60)) 
    \block_cnt[1]_i_1 
       (.I0(\block_cnt_reg_n_0_[1] ),
        .I1(\block_cnt_reg_n_0_[0] ),
        .I2(state[1]),
        .O(\block_cnt[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair182" *) 
  LUT4 #(
    .INIT(16'h6A00)) 
    \block_cnt[2]_i_1 
       (.I0(\block_cnt_reg_n_0_[2] ),
        .I1(\block_cnt_reg_n_0_[0] ),
        .I2(\block_cnt_reg_n_0_[1] ),
        .I3(state[1]),
        .O(\block_cnt[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair182" *) 
  LUT5 #(
    .INIT(32'h7F800000)) 
    \block_cnt[3]_i_1 
       (.I0(\block_cnt_reg_n_0_[2] ),
        .I1(\block_cnt_reg_n_0_[0] ),
        .I2(\block_cnt_reg_n_0_[1] ),
        .I3(\block_cnt_reg_n_0_[3] ),
        .I4(state[1]),
        .O(\block_cnt[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h7FFF800000000000)) 
    \block_cnt[4]_i_1 
       (.I0(\block_cnt_reg_n_0_[3] ),
        .I1(\block_cnt_reg_n_0_[1] ),
        .I2(\block_cnt_reg_n_0_[0] ),
        .I3(\block_cnt_reg_n_0_[2] ),
        .I4(\block_cnt_reg_n_0_[4] ),
        .I5(state[1]),
        .O(\block_cnt[4]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h90)) 
    \block_cnt[5]_i_1 
       (.I0(\block_cnt_reg_n_0_[5] ),
        .I1(\block_cnt[7]_i_4_n_0 ),
        .I2(state[1]),
        .O(\block_cnt[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair180" *) 
  LUT4 #(
    .INIT(16'h8288)) 
    \block_cnt[6]_i_1 
       (.I0(state[1]),
        .I1(\block_cnt_reg_n_0_[6] ),
        .I2(\block_cnt[7]_i_4_n_0 ),
        .I3(\block_cnt_reg_n_0_[5] ),
        .O(\block_cnt[6]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hAAAAEAAA)) 
    \block_cnt[7]_i_1 
       (.I0(\len[7]_i_1_n_0 ),
        .I1(state[0]),
        .I2(\block_cnt_reg[7]_i_3_n_0 ),
        .I3(state[1]),
        .I4(state[2]),
        .O(\block_cnt[7]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h90090960)) 
    \block_cnt[7]_i_10 
       (.I0(\block_cnt_reg_n_0_[5] ),
        .I1(\block_cnt_reg[7]_i_15_n_2 ),
        .I2(\block_cnt_reg_n_0_[4] ),
        .I3(\block_cnt[7]_i_16_n_0 ),
        .I4(\block_cnt_reg[7]_i_17_n_2 ),
        .O(\block_cnt[7]_i_10_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_100 
       (.I0(\block_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\block_cnt_reg[7]_i_57_n_5 ),
        .O(\block_cnt[7]_i_100_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_101 
       (.I0(\block_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\block_cnt_reg[7]_i_57_n_6 ),
        .O(\block_cnt[7]_i_101_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_102 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_17_n_2 ),
        .O(\block_cnt[7]_i_102_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_103 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_18_n_2 ),
        .O(\block_cnt[7]_i_103_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_104 
       (.I0(\block_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\block_cnt_reg[7]_i_62_n_5 ),
        .O(\block_cnt[7]_i_104_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_105 
       (.I0(\block_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\block_cnt_reg[7]_i_62_n_6 ),
        .O(\block_cnt[7]_i_105_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_106 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_18_n_2 ),
        .O(\block_cnt[7]_i_106_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_107 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_19_n_2 ),
        .O(\block_cnt[7]_i_107_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_108 
       (.I0(\block_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\block_cnt_reg[7]_i_67_n_5 ),
        .O(\block_cnt[7]_i_108_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_109 
       (.I0(\block_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\block_cnt_reg[7]_i_67_n_6 ),
        .O(\block_cnt[7]_i_109_n_0 ));
  LUT6 #(
    .INIT(64'h0990909060090909)) 
    \block_cnt[7]_i_11 
       (.I0(\block_cnt_reg_n_0_[3] ),
        .I1(\block_cnt_reg[7]_i_18_n_2 ),
        .I2(\block_cnt_reg_n_0_[2] ),
        .I3(\block_cnt_reg_n_0_[1] ),
        .I4(\block_cnt_reg_n_0_[0] ),
        .I5(\block_cnt_reg[7]_i_19_n_2 ),
        .O(\block_cnt[7]_i_11_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_110 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_19_n_2 ),
        .O(\block_cnt[7]_i_110_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_111 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_20_n_2 ),
        .O(\block_cnt[7]_i_111_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_112 
       (.I0(\block_cnt_reg[7]_i_20_n_2 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\block_cnt_reg[7]_i_72_n_4 ),
        .O(\block_cnt[7]_i_112_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_113 
       (.I0(\block_cnt_reg[7]_i_20_n_2 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\block_cnt_reg[7]_i_72_n_5 ),
        .O(\block_cnt[7]_i_113_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_114 
       (.I0(\block_cnt_reg[7]_i_20_n_2 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\block_cnt_reg[7]_i_72_n_6 ),
        .O(\block_cnt[7]_i_114_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_115 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_20_n_2 ),
        .O(\block_cnt[7]_i_115_n_0 ));
  LUT4 #(
    .INIT(16'h0690)) 
    \block_cnt[7]_i_12 
       (.I0(\block_cnt_reg_n_0_[1] ),
        .I1(\block_cnt_reg[7]_i_20_n_2 ),
        .I2(\block_cnt_reg[7]_i_21_n_3 ),
        .I3(\block_cnt_reg_n_0_[0] ),
        .O(\block_cnt[7]_i_12_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \block_cnt[7]_i_13 
       (.I0(\len_reg_n_0_[7] ),
        .I1(\block_cnt[7]_i_22_n_0 ),
        .O(\block_cnt[7]_i_13_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \block_cnt[7]_i_16 
       (.I0(\block_cnt_reg_n_0_[3] ),
        .I1(\block_cnt_reg_n_0_[1] ),
        .I2(\block_cnt_reg_n_0_[0] ),
        .I3(\block_cnt_reg_n_0_[2] ),
        .O(\block_cnt[7]_i_16_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair180" *) 
  LUT5 #(
    .INIT(32'hA2AA0800)) 
    \block_cnt[7]_i_2 
       (.I0(state[1]),
        .I1(\block_cnt_reg_n_0_[6] ),
        .I2(\block_cnt[7]_i_4_n_0 ),
        .I3(\block_cnt_reg_n_0_[5] ),
        .I4(\block_cnt_reg_n_0_[7] ),
        .O(block_cnt[7]));
  LUT6 #(
    .INIT(64'hFFFFFFFFFFFFFFFE)) 
    \block_cnt[7]_i_22 
       (.I0(\len_reg_n_0_[6] ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\len_reg_n_0_[2] ),
        .I4(\len_reg_n_0_[3] ),
        .I5(\len_reg_n_0_[5] ),
        .O(\block_cnt[7]_i_22_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \block_cnt[7]_i_24 
       (.I0(\len_reg_n_0_[7] ),
        .I1(\block_cnt[7]_i_22_n_0 ),
        .O(\block_cnt[7]_i_24_n_0 ));
  LUT2 #(
    .INIT(4'h7)) 
    \block_cnt[7]_i_25 
       (.I0(\block_cnt[7]_i_22_n_0 ),
        .I1(\len_reg_n_0_[7] ),
        .O(\block_cnt[7]_i_25_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_27 
       (.I0(\block_cnt_reg[7]_i_14_n_3 ),
        .I1(\block_cnt_reg[7]_i_23_n_4 ),
        .O(\block_cnt[7]_i_27_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_28 
       (.I0(\block_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\block_cnt_reg[7]_i_23_n_5 ),
        .O(\block_cnt[7]_i_28_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_30 
       (.I0(\block_cnt_reg[7]_i_15_n_2 ),
        .I1(\block_cnt_reg[7]_i_15_n_7 ),
        .O(\block_cnt[7]_i_30_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_31 
       (.I0(\block_cnt_reg[7]_i_15_n_2 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\block_cnt_reg[7]_i_26_n_4 ),
        .O(\block_cnt[7]_i_31_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_33 
       (.I0(\block_cnt_reg[7]_i_17_n_2 ),
        .I1(\block_cnt_reg[7]_i_17_n_7 ),
        .O(\block_cnt[7]_i_33_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_34 
       (.I0(\block_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\block_cnt_reg[7]_i_29_n_4 ),
        .O(\block_cnt[7]_i_34_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_36 
       (.I0(\block_cnt_reg[7]_i_18_n_2 ),
        .I1(\block_cnt_reg[7]_i_18_n_7 ),
        .O(\block_cnt[7]_i_36_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_37 
       (.I0(\block_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\block_cnt_reg[7]_i_32_n_4 ),
        .O(\block_cnt[7]_i_37_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_39 
       (.I0(\block_cnt_reg[7]_i_19_n_2 ),
        .I1(\block_cnt_reg[7]_i_19_n_7 ),
        .O(\block_cnt[7]_i_39_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair65" *) 
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \block_cnt[7]_i_4 
       (.I0(\block_cnt_reg_n_0_[3] ),
        .I1(\block_cnt_reg_n_0_[1] ),
        .I2(\block_cnt_reg_n_0_[0] ),
        .I3(\block_cnt_reg_n_0_[2] ),
        .I4(\block_cnt_reg_n_0_[4] ),
        .O(\block_cnt[7]_i_4_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_40 
       (.I0(\block_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\block_cnt_reg[7]_i_35_n_4 ),
        .O(\block_cnt[7]_i_40_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_42 
       (.I0(\block_cnt_reg[7]_i_20_n_2 ),
        .I1(\block_cnt_reg[7]_i_20_n_7 ),
        .O(\block_cnt[7]_i_42_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_44 
       (.I0(\len_reg_n_0_[7] ),
        .I1(\block_cnt[7]_i_13_n_0 ),
        .O(\block_cnt[7]_i_44_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_45 
       (.I0(\len_reg_n_0_[6] ),
        .I1(\block_cnt[7]_i_13_n_0 ),
        .O(\block_cnt[7]_i_45_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_46 
       (.I0(\len_reg_n_0_[5] ),
        .I1(\block_cnt[7]_i_13_n_0 ),
        .O(\block_cnt[7]_i_46_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_47 
       (.I0(\len_reg_n_0_[4] ),
        .I1(\block_cnt[7]_i_13_n_0 ),
        .O(\block_cnt[7]_i_47_n_0 ));
  LUT3 #(
    .INIT(8'h97)) 
    \block_cnt[7]_i_48 
       (.I0(\len_reg_n_0_[7] ),
        .I1(\block_cnt[7]_i_89_n_0 ),
        .I2(\len_reg_n_0_[6] ),
        .O(\block_cnt[7]_i_48_n_0 ));
  LUT4 #(
    .INIT(16'hC33D)) 
    \block_cnt[7]_i_49 
       (.I0(\len_reg_n_0_[7] ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\block_cnt[7]_i_90_n_0 ),
        .I3(\len_reg_n_0_[5] ),
        .O(\block_cnt[7]_i_49_n_0 ));
  LUT6 #(
    .INIT(64'h2C22BABB0800A2AA)) 
    \block_cnt[7]_i_5 
       (.I0(\block_cnt[7]_i_13_n_0 ),
        .I1(\block_cnt_reg_n_0_[6] ),
        .I2(\block_cnt[7]_i_4_n_0 ),
        .I3(\block_cnt_reg_n_0_[5] ),
        .I4(\block_cnt_reg_n_0_[7] ),
        .I5(\block_cnt_reg[7]_i_14_n_3 ),
        .O(\block_cnt[7]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h6666666999999996)) 
    \block_cnt[7]_i_50 
       (.I0(\block_cnt[7]_i_13_n_0 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\len_reg_n_0_[3] ),
        .I3(\len_reg_n_0_[2] ),
        .I4(\len_reg_n_0_[1] ),
        .I5(\len_reg_n_0_[4] ),
        .O(\block_cnt[7]_i_50_n_0 ));
  LUT5 #(
    .INIT(32'h66699996)) 
    \block_cnt[7]_i_51 
       (.I0(\block_cnt[7]_i_13_n_0 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\len_reg_n_0_[2] ),
        .I4(\len_reg_n_0_[3] ),
        .O(\block_cnt[7]_i_51_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_53 
       (.I0(\block_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\block_cnt_reg[7]_i_23_n_6 ),
        .O(\block_cnt[7]_i_53_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_54 
       (.I0(\block_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\block_cnt_reg[7]_i_23_n_7 ),
        .O(\block_cnt[7]_i_54_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_55 
       (.I0(\block_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\block_cnt_reg[7]_i_43_n_4 ),
        .O(\block_cnt[7]_i_55_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_56 
       (.I0(\block_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\block_cnt_reg[7]_i_43_n_5 ),
        .O(\block_cnt[7]_i_56_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_58 
       (.I0(\block_cnt_reg[7]_i_15_n_2 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\block_cnt_reg[7]_i_26_n_5 ),
        .O(\block_cnt[7]_i_58_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_59 
       (.I0(\block_cnt_reg[7]_i_15_n_2 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\block_cnt_reg[7]_i_26_n_6 ),
        .O(\block_cnt[7]_i_59_n_0 ));
  LUT5 #(
    .INIT(32'h38AE208A)) 
    \block_cnt[7]_i_6 
       (.I0(\block_cnt_reg[7]_i_15_n_2 ),
        .I1(\block_cnt[7]_i_16_n_0 ),
        .I2(\block_cnt_reg_n_0_[4] ),
        .I3(\block_cnt_reg_n_0_[5] ),
        .I4(\block_cnt_reg[7]_i_17_n_2 ),
        .O(\block_cnt[7]_i_6_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_60 
       (.I0(\block_cnt_reg[7]_i_15_n_2 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\block_cnt_reg[7]_i_26_n_7 ),
        .O(\block_cnt[7]_i_60_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_61 
       (.I0(\block_cnt_reg[7]_i_15_n_2 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\block_cnt_reg[7]_i_52_n_4 ),
        .O(\block_cnt[7]_i_61_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_63 
       (.I0(\block_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\block_cnt_reg[7]_i_29_n_5 ),
        .O(\block_cnt[7]_i_63_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_64 
       (.I0(\block_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\block_cnt_reg[7]_i_29_n_6 ),
        .O(\block_cnt[7]_i_64_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_65 
       (.I0(\block_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\block_cnt_reg[7]_i_29_n_7 ),
        .O(\block_cnt[7]_i_65_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_66 
       (.I0(\block_cnt_reg[7]_i_17_n_2 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\block_cnt_reg[7]_i_57_n_4 ),
        .O(\block_cnt[7]_i_66_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_68 
       (.I0(\block_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\block_cnt_reg[7]_i_32_n_5 ),
        .O(\block_cnt[7]_i_68_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_69 
       (.I0(\block_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\block_cnt_reg[7]_i_32_n_6 ),
        .O(\block_cnt[7]_i_69_n_0 ));
  LUT6 #(
    .INIT(64'hC222ABBB80002AAA)) 
    \block_cnt[7]_i_7 
       (.I0(\block_cnt_reg[7]_i_18_n_2 ),
        .I1(\block_cnt_reg_n_0_[2] ),
        .I2(\block_cnt_reg_n_0_[0] ),
        .I3(\block_cnt_reg_n_0_[1] ),
        .I4(\block_cnt_reg_n_0_[3] ),
        .I5(\block_cnt_reg[7]_i_19_n_2 ),
        .O(\block_cnt[7]_i_7_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_70 
       (.I0(\block_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\block_cnt_reg[7]_i_32_n_7 ),
        .O(\block_cnt[7]_i_70_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_71 
       (.I0(\block_cnt_reg[7]_i_18_n_2 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\block_cnt_reg[7]_i_62_n_4 ),
        .O(\block_cnt[7]_i_71_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_73 
       (.I0(\block_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\block_cnt_reg[7]_i_35_n_5 ),
        .O(\block_cnt[7]_i_73_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_74 
       (.I0(\block_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\block_cnt_reg[7]_i_35_n_6 ),
        .O(\block_cnt[7]_i_74_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_75 
       (.I0(\block_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\block_cnt_reg[7]_i_35_n_7 ),
        .O(\block_cnt[7]_i_75_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_76 
       (.I0(\block_cnt_reg[7]_i_19_n_2 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\block_cnt_reg[7]_i_67_n_4 ),
        .O(\block_cnt[7]_i_76_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_78 
       (.I0(\block_cnt_reg[7]_i_20_n_2 ),
        .I1(\len_reg_n_0_[7] ),
        .I2(\block_cnt_reg[7]_i_38_n_4 ),
        .O(\block_cnt[7]_i_78_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_79 
       (.I0(\block_cnt_reg[7]_i_20_n_2 ),
        .I1(\len_reg_n_0_[6] ),
        .I2(\block_cnt_reg[7]_i_38_n_5 ),
        .O(\block_cnt[7]_i_79_n_0 ));
  LUT4 #(
    .INIT(16'hE282)) 
    \block_cnt[7]_i_8 
       (.I0(\block_cnt_reg[7]_i_20_n_2 ),
        .I1(\block_cnt_reg_n_0_[1] ),
        .I2(\block_cnt_reg_n_0_[0] ),
        .I3(\block_cnt_reg[7]_i_21_n_3 ),
        .O(\block_cnt[7]_i_8_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_80 
       (.I0(\block_cnt_reg[7]_i_20_n_2 ),
        .I1(\len_reg_n_0_[5] ),
        .I2(\block_cnt_reg[7]_i_38_n_6 ),
        .O(\block_cnt[7]_i_80_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_81 
       (.I0(\block_cnt_reg[7]_i_20_n_2 ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\block_cnt_reg[7]_i_38_n_7 ),
        .O(\block_cnt[7]_i_81_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_82 
       (.I0(\len_reg_n_0_[3] ),
        .I1(\block_cnt[7]_i_13_n_0 ),
        .O(\block_cnt[7]_i_82_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_83 
       (.I0(\len_reg_n_0_[1] ),
        .I1(\block_cnt[7]_i_13_n_0 ),
        .O(\block_cnt[7]_i_83_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_84 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt[7]_i_13_n_0 ),
        .O(\block_cnt[7]_i_84_n_0 ));
  LUT4 #(
    .INIT(16'h6996)) 
    \block_cnt[7]_i_85 
       (.I0(\block_cnt[7]_i_13_n_0 ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\len_reg_n_0_[2] ),
        .I3(\len_reg_n_0_[1] ),
        .O(\block_cnt[7]_i_85_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_86 
       (.I0(\block_cnt[7]_i_13_n_0 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\len_reg_n_0_[1] ),
        .O(\block_cnt[7]_i_86_n_0 ));
  LUT3 #(
    .INIT(8'h69)) 
    \block_cnt[7]_i_87 
       (.I0(\block_cnt[7]_i_13_n_0 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\len_reg_n_0_[0] ),
        .O(\block_cnt[7]_i_87_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_88 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt[7]_i_13_n_0 ),
        .O(\block_cnt[7]_i_88_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \block_cnt[7]_i_89 
       (.I0(\len_reg_n_0_[5] ),
        .I1(\len_reg_n_0_[3] ),
        .I2(\len_reg_n_0_[2] ),
        .I3(\len_reg_n_0_[1] ),
        .I4(\len_reg_n_0_[4] ),
        .O(\block_cnt[7]_i_89_n_0 ));
  LUT6 #(
    .INIT(64'h9009909009600909)) 
    \block_cnt[7]_i_9 
       (.I0(\block_cnt_reg_n_0_[7] ),
        .I1(\block_cnt[7]_i_13_n_0 ),
        .I2(\block_cnt_reg_n_0_[6] ),
        .I3(\block_cnt[7]_i_4_n_0 ),
        .I4(\block_cnt_reg_n_0_[5] ),
        .I5(\block_cnt_reg[7]_i_14_n_3 ),
        .O(\block_cnt[7]_i_9_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \block_cnt[7]_i_90 
       (.I0(\len_reg_n_0_[3] ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\len_reg_n_0_[4] ),
        .O(\block_cnt[7]_i_90_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_91 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_14_n_3 ),
        .O(\block_cnt[7]_i_91_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_92 
       (.I0(\block_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\block_cnt_reg[7]_i_43_n_6 ),
        .O(\block_cnt[7]_i_92_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_93 
       (.I0(\block_cnt_reg[7]_i_14_n_3 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\block_cnt_reg[7]_i_43_n_7 ),
        .O(\block_cnt[7]_i_93_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_94 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_14_n_3 ),
        .O(\block_cnt[7]_i_94_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_95 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_15_n_2 ),
        .O(\block_cnt[7]_i_95_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_96 
       (.I0(\block_cnt_reg[7]_i_15_n_2 ),
        .I1(\len_reg_n_0_[2] ),
        .I2(\block_cnt_reg[7]_i_52_n_5 ),
        .O(\block_cnt[7]_i_96_n_0 ));
  LUT3 #(
    .INIT(8'h96)) 
    \block_cnt[7]_i_97 
       (.I0(\block_cnt_reg[7]_i_15_n_2 ),
        .I1(\len_reg_n_0_[1] ),
        .I2(\block_cnt_reg[7]_i_52_n_6 ),
        .O(\block_cnt[7]_i_97_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_98 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_15_n_2 ),
        .O(\block_cnt[7]_i_98_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \block_cnt[7]_i_99 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg[7]_i_17_n_2 ),
        .O(\block_cnt[7]_i_99_n_0 ));
  FDCE \block_cnt_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(block_cnt[0]),
        .Q(\block_cnt_reg_n_0_[0] ));
  FDCE \block_cnt_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\block_cnt[1]_i_1_n_0 ),
        .Q(\block_cnt_reg_n_0_[1] ));
  FDCE \block_cnt_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\block_cnt[2]_i_1_n_0 ),
        .Q(\block_cnt_reg_n_0_[2] ));
  FDCE \block_cnt_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\block_cnt[3]_i_1_n_0 ),
        .Q(\block_cnt_reg_n_0_[3] ));
  FDCE \block_cnt_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\block_cnt[4]_i_1_n_0 ),
        .Q(\block_cnt_reg_n_0_[4] ));
  FDCE \block_cnt_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\block_cnt[5]_i_1_n_0 ),
        .Q(\block_cnt_reg_n_0_[5] ));
  FDCE \block_cnt_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\block_cnt[6]_i_1_n_0 ),
        .Q(\block_cnt_reg_n_0_[6] ));
  FDCE \block_cnt_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(\block_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(block_cnt[7]),
        .Q(\block_cnt_reg_n_0_[7] ));
  CARRY4 \block_cnt_reg[7]_i_14 
       (.CI(\block_cnt_reg[7]_i_23_n_0 ),
        .CO(\block_cnt_reg[7]_i_14_n_3 ),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\block_cnt[7]_i_24_n_0 }),
        .S({\<const0> ,\<const0> ,\<const0> ,\block_cnt[7]_i_25_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_15 
       (.CI(\block_cnt_reg[7]_i_26_n_0 ),
        .CO({\block_cnt_reg[7]_i_15_n_2 ,\block_cnt_reg[7]_i_15_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\block_cnt_reg[7]_i_14_n_3 ,\block_cnt_reg[7]_i_23_n_5 }),
        .O(\block_cnt_reg[7]_i_15_n_7 ),
        .S({\<const0> ,\<const0> ,\block_cnt[7]_i_27_n_0 ,\block_cnt[7]_i_28_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_17 
       (.CI(\block_cnt_reg[7]_i_29_n_0 ),
        .CO({\block_cnt_reg[7]_i_17_n_2 ,\block_cnt_reg[7]_i_17_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\block_cnt_reg[7]_i_15_n_2 ,\block_cnt_reg[7]_i_26_n_4 }),
        .O(\block_cnt_reg[7]_i_17_n_7 ),
        .S({\<const0> ,\<const0> ,\block_cnt[7]_i_30_n_0 ,\block_cnt[7]_i_31_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_18 
       (.CI(\block_cnt_reg[7]_i_32_n_0 ),
        .CO({\block_cnt_reg[7]_i_18_n_2 ,\block_cnt_reg[7]_i_18_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\block_cnt_reg[7]_i_17_n_2 ,\block_cnt_reg[7]_i_29_n_4 }),
        .O(\block_cnt_reg[7]_i_18_n_7 ),
        .S({\<const0> ,\<const0> ,\block_cnt[7]_i_33_n_0 ,\block_cnt[7]_i_34_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_19 
       (.CI(\block_cnt_reg[7]_i_35_n_0 ),
        .CO({\block_cnt_reg[7]_i_19_n_2 ,\block_cnt_reg[7]_i_19_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\block_cnt_reg[7]_i_18_n_2 ,\block_cnt_reg[7]_i_32_n_4 }),
        .O(\block_cnt_reg[7]_i_19_n_7 ),
        .S({\<const0> ,\<const0> ,\block_cnt[7]_i_36_n_0 ,\block_cnt[7]_i_37_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_20 
       (.CI(\block_cnt_reg[7]_i_38_n_0 ),
        .CO({\block_cnt_reg[7]_i_20_n_2 ,\block_cnt_reg[7]_i_20_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\block_cnt_reg[7]_i_19_n_2 ,\block_cnt_reg[7]_i_35_n_4 }),
        .O(\block_cnt_reg[7]_i_20_n_7 ),
        .S({\<const0> ,\<const0> ,\block_cnt[7]_i_39_n_0 ,\block_cnt[7]_i_40_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_21 
       (.CI(\block_cnt_reg[7]_i_41_n_0 ),
        .CO(\block_cnt_reg[7]_i_21_n_3 ),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\block_cnt_reg[7]_i_20_n_2 }),
        .S({\<const0> ,\<const0> ,\<const0> ,\block_cnt[7]_i_42_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_23 
       (.CI(\block_cnt_reg[7]_i_43_n_0 ),
        .CO({\block_cnt_reg[7]_i_23_n_0 ,\block_cnt_reg[7]_i_23_n_1 ,\block_cnt_reg[7]_i_23_n_2 ,\block_cnt_reg[7]_i_23_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\block_cnt[7]_i_44_n_0 ,\block_cnt[7]_i_45_n_0 ,\block_cnt[7]_i_46_n_0 ,\block_cnt[7]_i_47_n_0 }),
        .O({\block_cnt_reg[7]_i_23_n_4 ,\block_cnt_reg[7]_i_23_n_5 ,\block_cnt_reg[7]_i_23_n_6 ,\block_cnt_reg[7]_i_23_n_7 }),
        .S({\block_cnt[7]_i_48_n_0 ,\block_cnt[7]_i_49_n_0 ,\block_cnt[7]_i_50_n_0 ,\block_cnt[7]_i_51_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_26 
       (.CI(\block_cnt_reg[7]_i_52_n_0 ),
        .CO({\block_cnt_reg[7]_i_26_n_0 ,\block_cnt_reg[7]_i_26_n_1 ,\block_cnt_reg[7]_i_26_n_2 ,\block_cnt_reg[7]_i_26_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\block_cnt_reg[7]_i_23_n_6 ,\block_cnt_reg[7]_i_23_n_7 ,\block_cnt_reg[7]_i_43_n_4 ,\block_cnt_reg[7]_i_43_n_5 }),
        .O({\block_cnt_reg[7]_i_26_n_4 ,\block_cnt_reg[7]_i_26_n_5 ,\block_cnt_reg[7]_i_26_n_6 ,\block_cnt_reg[7]_i_26_n_7 }),
        .S({\block_cnt[7]_i_53_n_0 ,\block_cnt[7]_i_54_n_0 ,\block_cnt[7]_i_55_n_0 ,\block_cnt[7]_i_56_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_29 
       (.CI(\block_cnt_reg[7]_i_57_n_0 ),
        .CO({\block_cnt_reg[7]_i_29_n_0 ,\block_cnt_reg[7]_i_29_n_1 ,\block_cnt_reg[7]_i_29_n_2 ,\block_cnt_reg[7]_i_29_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\block_cnt_reg[7]_i_26_n_5 ,\block_cnt_reg[7]_i_26_n_6 ,\block_cnt_reg[7]_i_26_n_7 ,\block_cnt_reg[7]_i_52_n_4 }),
        .O({\block_cnt_reg[7]_i_29_n_4 ,\block_cnt_reg[7]_i_29_n_5 ,\block_cnt_reg[7]_i_29_n_6 ,\block_cnt_reg[7]_i_29_n_7 }),
        .S({\block_cnt[7]_i_58_n_0 ,\block_cnt[7]_i_59_n_0 ,\block_cnt[7]_i_60_n_0 ,\block_cnt[7]_i_61_n_0 }));
  (* COMPARATOR_THRESHOLD = "6" *) 
  CARRY4 \block_cnt_reg[7]_i_3 
       (.CI(\<const0> ),
        .CO({\block_cnt_reg[7]_i_3_n_0 ,\block_cnt_reg[7]_i_3_n_1 ,\block_cnt_reg[7]_i_3_n_2 ,\block_cnt_reg[7]_i_3_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\block_cnt[7]_i_5_n_0 ,\block_cnt[7]_i_6_n_0 ,\block_cnt[7]_i_7_n_0 ,\block_cnt[7]_i_8_n_0 }),
        .S({\block_cnt[7]_i_9_n_0 ,\block_cnt[7]_i_10_n_0 ,\block_cnt[7]_i_11_n_0 ,\block_cnt[7]_i_12_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_32 
       (.CI(\block_cnt_reg[7]_i_62_n_0 ),
        .CO({\block_cnt_reg[7]_i_32_n_0 ,\block_cnt_reg[7]_i_32_n_1 ,\block_cnt_reg[7]_i_32_n_2 ,\block_cnt_reg[7]_i_32_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\block_cnt_reg[7]_i_29_n_5 ,\block_cnt_reg[7]_i_29_n_6 ,\block_cnt_reg[7]_i_29_n_7 ,\block_cnt_reg[7]_i_57_n_4 }),
        .O({\block_cnt_reg[7]_i_32_n_4 ,\block_cnt_reg[7]_i_32_n_5 ,\block_cnt_reg[7]_i_32_n_6 ,\block_cnt_reg[7]_i_32_n_7 }),
        .S({\block_cnt[7]_i_63_n_0 ,\block_cnt[7]_i_64_n_0 ,\block_cnt[7]_i_65_n_0 ,\block_cnt[7]_i_66_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_35 
       (.CI(\block_cnt_reg[7]_i_67_n_0 ),
        .CO({\block_cnt_reg[7]_i_35_n_0 ,\block_cnt_reg[7]_i_35_n_1 ,\block_cnt_reg[7]_i_35_n_2 ,\block_cnt_reg[7]_i_35_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\block_cnt_reg[7]_i_32_n_5 ,\block_cnt_reg[7]_i_32_n_6 ,\block_cnt_reg[7]_i_32_n_7 ,\block_cnt_reg[7]_i_62_n_4 }),
        .O({\block_cnt_reg[7]_i_35_n_4 ,\block_cnt_reg[7]_i_35_n_5 ,\block_cnt_reg[7]_i_35_n_6 ,\block_cnt_reg[7]_i_35_n_7 }),
        .S({\block_cnt[7]_i_68_n_0 ,\block_cnt[7]_i_69_n_0 ,\block_cnt[7]_i_70_n_0 ,\block_cnt[7]_i_71_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_38 
       (.CI(\block_cnt_reg[7]_i_72_n_0 ),
        .CO({\block_cnt_reg[7]_i_38_n_0 ,\block_cnt_reg[7]_i_38_n_1 ,\block_cnt_reg[7]_i_38_n_2 ,\block_cnt_reg[7]_i_38_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\block_cnt_reg[7]_i_35_n_5 ,\block_cnt_reg[7]_i_35_n_6 ,\block_cnt_reg[7]_i_35_n_7 ,\block_cnt_reg[7]_i_67_n_4 }),
        .O({\block_cnt_reg[7]_i_38_n_4 ,\block_cnt_reg[7]_i_38_n_5 ,\block_cnt_reg[7]_i_38_n_6 ,\block_cnt_reg[7]_i_38_n_7 }),
        .S({\block_cnt[7]_i_73_n_0 ,\block_cnt[7]_i_74_n_0 ,\block_cnt[7]_i_75_n_0 ,\block_cnt[7]_i_76_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_41 
       (.CI(\block_cnt_reg[7]_i_77_n_0 ),
        .CO({\block_cnt_reg[7]_i_41_n_0 ,\block_cnt_reg[7]_i_41_n_1 ,\block_cnt_reg[7]_i_41_n_2 ,\block_cnt_reg[7]_i_41_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\block_cnt_reg[7]_i_38_n_4 ,\block_cnt_reg[7]_i_38_n_5 ,\block_cnt_reg[7]_i_38_n_6 ,\block_cnt_reg[7]_i_38_n_7 }),
        .S({\block_cnt[7]_i_78_n_0 ,\block_cnt[7]_i_79_n_0 ,\block_cnt[7]_i_80_n_0 ,\block_cnt[7]_i_81_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_43 
       (.CI(\<const0> ),
        .CO({\block_cnt_reg[7]_i_43_n_0 ,\block_cnt_reg[7]_i_43_n_1 ,\block_cnt_reg[7]_i_43_n_2 ,\block_cnt_reg[7]_i_43_n_3 }),
        .CYINIT(\block_cnt[7]_i_13_n_0 ),
        .DI({\block_cnt[7]_i_82_n_0 ,\len_reg_n_0_[1] ,\block_cnt[7]_i_83_n_0 ,\block_cnt[7]_i_84_n_0 }),
        .O({\block_cnt_reg[7]_i_43_n_4 ,\block_cnt_reg[7]_i_43_n_5 ,\block_cnt_reg[7]_i_43_n_6 ,\block_cnt_reg[7]_i_43_n_7 }),
        .S({\block_cnt[7]_i_85_n_0 ,\block_cnt[7]_i_86_n_0 ,\block_cnt[7]_i_87_n_0 ,\block_cnt[7]_i_88_n_0 }));
  CARRY4 \block_cnt_reg[7]_i_52 
       (.CI(\<const0> ),
        .CO({\block_cnt_reg[7]_i_52_n_0 ,\block_cnt_reg[7]_i_52_n_1 ,\block_cnt_reg[7]_i_52_n_2 ,\block_cnt_reg[7]_i_52_n_3 }),
        .CYINIT(\block_cnt_reg[7]_i_14_n_3 ),
        .DI({\block_cnt_reg[7]_i_43_n_6 ,\block_cnt_reg[7]_i_43_n_7 ,\block_cnt[7]_i_91_n_0 ,\<const0> }),
        .O({\block_cnt_reg[7]_i_52_n_4 ,\block_cnt_reg[7]_i_52_n_5 ,\block_cnt_reg[7]_i_52_n_6 ,\NLW_block_cnt_reg[7]_i_52_O_UNCONNECTED [0]}),
        .S({\block_cnt[7]_i_92_n_0 ,\block_cnt[7]_i_93_n_0 ,\block_cnt[7]_i_94_n_0 ,\<const1> }));
  CARRY4 \block_cnt_reg[7]_i_57 
       (.CI(\<const0> ),
        .CO({\block_cnt_reg[7]_i_57_n_0 ,\block_cnt_reg[7]_i_57_n_1 ,\block_cnt_reg[7]_i_57_n_2 ,\block_cnt_reg[7]_i_57_n_3 }),
        .CYINIT(\block_cnt_reg[7]_i_15_n_2 ),
        .DI({\block_cnt_reg[7]_i_52_n_5 ,\block_cnt_reg[7]_i_52_n_6 ,\block_cnt[7]_i_95_n_0 ,\<const0> }),
        .O({\block_cnt_reg[7]_i_57_n_4 ,\block_cnt_reg[7]_i_57_n_5 ,\block_cnt_reg[7]_i_57_n_6 ,\NLW_block_cnt_reg[7]_i_57_O_UNCONNECTED [0]}),
        .S({\block_cnt[7]_i_96_n_0 ,\block_cnt[7]_i_97_n_0 ,\block_cnt[7]_i_98_n_0 ,\<const1> }));
  CARRY4 \block_cnt_reg[7]_i_62 
       (.CI(\<const0> ),
        .CO({\block_cnt_reg[7]_i_62_n_0 ,\block_cnt_reg[7]_i_62_n_1 ,\block_cnt_reg[7]_i_62_n_2 ,\block_cnt_reg[7]_i_62_n_3 }),
        .CYINIT(\block_cnt_reg[7]_i_17_n_2 ),
        .DI({\block_cnt_reg[7]_i_57_n_5 ,\block_cnt_reg[7]_i_57_n_6 ,\block_cnt[7]_i_99_n_0 ,\<const0> }),
        .O({\block_cnt_reg[7]_i_62_n_4 ,\block_cnt_reg[7]_i_62_n_5 ,\block_cnt_reg[7]_i_62_n_6 ,\NLW_block_cnt_reg[7]_i_62_O_UNCONNECTED [0]}),
        .S({\block_cnt[7]_i_100_n_0 ,\block_cnt[7]_i_101_n_0 ,\block_cnt[7]_i_102_n_0 ,\<const1> }));
  CARRY4 \block_cnt_reg[7]_i_67 
       (.CI(\<const0> ),
        .CO({\block_cnt_reg[7]_i_67_n_0 ,\block_cnt_reg[7]_i_67_n_1 ,\block_cnt_reg[7]_i_67_n_2 ,\block_cnt_reg[7]_i_67_n_3 }),
        .CYINIT(\block_cnt_reg[7]_i_18_n_2 ),
        .DI({\block_cnt_reg[7]_i_62_n_5 ,\block_cnt_reg[7]_i_62_n_6 ,\block_cnt[7]_i_103_n_0 ,\<const0> }),
        .O({\block_cnt_reg[7]_i_67_n_4 ,\block_cnt_reg[7]_i_67_n_5 ,\block_cnt_reg[7]_i_67_n_6 ,\NLW_block_cnt_reg[7]_i_67_O_UNCONNECTED [0]}),
        .S({\block_cnt[7]_i_104_n_0 ,\block_cnt[7]_i_105_n_0 ,\block_cnt[7]_i_106_n_0 ,\<const1> }));
  CARRY4 \block_cnt_reg[7]_i_72 
       (.CI(\<const0> ),
        .CO({\block_cnt_reg[7]_i_72_n_0 ,\block_cnt_reg[7]_i_72_n_1 ,\block_cnt_reg[7]_i_72_n_2 ,\block_cnt_reg[7]_i_72_n_3 }),
        .CYINIT(\block_cnt_reg[7]_i_19_n_2 ),
        .DI({\block_cnt_reg[7]_i_67_n_5 ,\block_cnt_reg[7]_i_67_n_6 ,\block_cnt[7]_i_107_n_0 ,\<const0> }),
        .O({\block_cnt_reg[7]_i_72_n_4 ,\block_cnt_reg[7]_i_72_n_5 ,\block_cnt_reg[7]_i_72_n_6 ,\NLW_block_cnt_reg[7]_i_72_O_UNCONNECTED [0]}),
        .S({\block_cnt[7]_i_108_n_0 ,\block_cnt[7]_i_109_n_0 ,\block_cnt[7]_i_110_n_0 ,\<const1> }));
  CARRY4 \block_cnt_reg[7]_i_77 
       (.CI(\<const0> ),
        .CO({\block_cnt_reg[7]_i_77_n_0 ,\block_cnt_reg[7]_i_77_n_1 ,\block_cnt_reg[7]_i_77_n_2 ,\block_cnt_reg[7]_i_77_n_3 }),
        .CYINIT(\block_cnt_reg[7]_i_20_n_2 ),
        .DI({\block_cnt_reg[7]_i_72_n_4 ,\block_cnt_reg[7]_i_72_n_5 ,\block_cnt_reg[7]_i_72_n_6 ,\block_cnt[7]_i_111_n_0 }),
        .S({\block_cnt[7]_i_112_n_0 ,\block_cnt[7]_i_113_n_0 ,\block_cnt[7]_i_114_n_0 ,\block_cnt[7]_i_115_n_0 }));
  OBUF busy_OBUF_inst
       (.I(busy_OBUF),
        .O(busy));
  LUT4 #(
    .INIT(16'hC002)) 
    busy_i_1
       (.I0(start_IBUF),
        .I1(state[2]),
        .I2(state[1]),
        .I3(state[0]),
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
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(busy_i_2_n_0),
        .Q(busy_OBUF));
  BUFG clk_IBUF_BUFG_inst
       (.I(clk_IBUF),
        .O(clk_IBUF_BUFG));
  IBUF clk_IBUF_inst
       (.I(clk),
        .O(clk_IBUF));
  LUT3 #(
    .INIT(8'h54)) 
    \cnt[0]_i_1 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(state[0]),
        .I2(state[1]),
        .O(cnt[0]));
  (* SOFT_HLUTNM = "soft_lutpair76" *) 
  LUT4 #(
    .INIT(16'h0EE0)) 
    \cnt[1]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\cnt_reg_n_0_[0] ),
        .O(cnt[1]));
  (* SOFT_HLUTNM = "soft_lutpair76" *) 
  LUT5 #(
    .INIT(32'h0EEEE000)) 
    \cnt[2]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\cnt_reg_n_0_[0] ),
        .I4(\cnt_reg_n_0_[2] ),
        .O(\cnt[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0EEEEEEEE0000000)) 
    \cnt[3]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\cnt_reg_n_0_[0] ),
        .I3(\cnt_reg_n_0_[1] ),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(\cnt_reg_n_0_[3] ),
        .O(\cnt[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h020000002A282828)) 
    \cnt[4]_i_1 
       (.I0(state[2]),
        .I1(state[0]),
        .I2(state[1]),
        .I3(\layer_idx_reg_n_0_[1] ),
        .I4(\layer_idx_reg_n_0_[2] ),
        .I5(\cnt_reg_n_0_[4] ),
        .O(\cnt[4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h1555555540000000)) 
    \cnt[4]_i_2 
       (.I0(\cnt[4]_i_3_n_0 ),
        .I1(\cnt_reg_n_0_[0] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\cnt_reg_n_0_[2] ),
        .I4(\cnt_reg_n_0_[3] ),
        .I5(\cnt_reg_n_0_[4] ),
        .O(\cnt[4]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT2 #(
    .INIT(4'h1)) 
    \cnt[4]_i_3 
       (.I0(state[0]),
        .I1(state[1]),
        .O(\cnt[4]_i_3_n_0 ));
  FDCE \cnt_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[4]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(cnt[0]),
        .Q(\cnt_reg_n_0_[0] ));
  FDCE \cnt_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[4]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(cnt[1]),
        .Q(\cnt_reg_n_0_[1] ));
  FDCE \cnt_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[4]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\cnt[2]_i_1_n_0 ),
        .Q(\cnt_reg_n_0_[2] ));
  FDCE \cnt_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[4]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\cnt[3]_i_1_n_0 ),
        .Q(\cnt_reg_n_0_[3] ));
  FDCE \cnt_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\cnt[4]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\cnt[4]_i_2_n_0 ),
        .Q(\cnt_reg_n_0_[4] ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][0]_i_1 
       (.I0(\coeff[0][0]_i_2_n_0 ),
        .I1(\coeff[0][0]_i_3_n_0 ),
        .I2(load_data_IBUF[0]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][0]_i_4_n_0 ),
        .O(coeff[0]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][0]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair174" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][0]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[0]),
        .I2(\coeff_reg[0][3]_i_7_n_7 ),
        .O(\coeff[0][0]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][0]_i_4 
       (.I0(\coeff[0][0]_i_6_n_0 ),
        .I1(\coeff[0][0]_i_7_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[0]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][0]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair174" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][0]_i_5 
       (.I0(p_7_out__0[16]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][3]_i_10_n_7 ),
        .O(\coeff[0][0]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h0AC00000)) 
    \coeff[0][0]_i_6 
       (.I0(p_1_out__0[16]),
        .I1(\coeff_reg[0][3]_i_19_n_7 ),
        .I2(state[1]),
        .I3(state[0]),
        .I4(state[2]),
        .O(\coeff[0][0]_i_6_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][0]_i_7 
       (.I0(load_data_IBUF[0]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][0]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][10]_i_1 
       (.I0(\coeff[0][10]_i_2_n_0 ),
        .I1(\coeff[0][10]_i_3_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][10]_i_4_n_0 ),
        .O(coeff[10]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][10]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair164" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][10]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[10]),
        .I2(\coeff_reg[0][11]_i_7_n_5 ),
        .O(\coeff[0][10]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][10]_i_4 
       (.I0(\coeff[0][10]_i_6_n_0 ),
        .I1(\coeff[0][10]_i_7_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[10]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][10]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair164" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][10]_i_5 
       (.I0(p_7_out__0[26]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][11]_i_10_n_5 ),
        .O(\coeff[0][10]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h2C002000)) 
    \coeff[0][10]_i_6 
       (.I0(\coeff_reg[0][11]_i_19_n_5 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(p_1_out__0[26]),
        .O(\coeff[0][10]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][10]_i_7 
       (.I0(load_data_IBUF[10]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][10]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][11]_i_1 
       (.I0(\coeff[0][11]_i_2_n_0 ),
        .I1(\coeff[0][11]_i_3_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][11]_i_4_n_0 ),
        .O(coeff[11]));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_11 
       (.I0(unamedDSP_i_2_n_4),
        .I1(unamedDSP__0_n_94),
        .O(\coeff[0][11]_i_11_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_12 
       (.I0(unamedDSP_i_2_n_5),
        .I1(unamedDSP__0_n_95),
        .O(\coeff[0][11]_i_12_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_13 
       (.I0(unamedDSP_i_2_n_6),
        .I1(unamedDSP__0_n_96),
        .O(\coeff[0][11]_i_13_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_14 
       (.I0(unamedDSP_i_2_n_7),
        .I1(unamedDSP__0_n_97),
        .O(\coeff[0][11]_i_14_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_15 
       (.I0(p_4_out__0[27]),
        .I1(unamedDSP_i_47_n_0),
        .O(\coeff[0][11]_i_15_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_16 
       (.I0(p_4_out__0[26]),
        .I1(unamedDSP_i_48_n_0),
        .O(\coeff[0][11]_i_16_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_17 
       (.I0(p_4_out__0[25]),
        .I1(unamedDSP_i_49_n_0),
        .O(\coeff[0][11]_i_17_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_18 
       (.I0(p_4_out__0[24]),
        .I1(unamedDSP_i_50_n_0),
        .O(\coeff[0][11]_i_18_n_0 ));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][11]_i_2_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][11]_i_20 
       (.I0(unamedDSP_i_47_n_0),
        .O(\coeff[0][11]_i_20_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][11]_i_21 
       (.I0(unamedDSP_i_48_n_0),
        .O(\coeff[0][11]_i_21_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][11]_i_22 
       (.I0(unamedDSP_i_49_n_0),
        .O(\coeff[0][11]_i_22_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][11]_i_23 
       (.I0(unamedDSP_i_50_n_0),
        .O(\coeff[0][11]_i_23_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][11]_i_24 
       (.I0(unamedDSP_i_47_n_0),
        .I1(p_4_out__0[27]),
        .O(\coeff[0][11]_i_24_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][11]_i_25 
       (.I0(unamedDSP_i_48_n_0),
        .I1(p_4_out__0[26]),
        .O(\coeff[0][11]_i_25_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][11]_i_26 
       (.I0(unamedDSP_i_49_n_0),
        .I1(p_4_out__0[25]),
        .O(\coeff[0][11]_i_26_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][11]_i_27 
       (.I0(unamedDSP_i_50_n_0),
        .I1(p_4_out__0[24]),
        .O(\coeff[0][11]_i_27_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_28 
       (.I0(unamedDSP__1_i_5_n_0),
        .I1(unamedDSP__2_n_94),
        .O(\coeff[0][11]_i_28_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_29 
       (.I0(unamedDSP__1_i_6_n_0),
        .I1(unamedDSP__2_n_95),
        .O(\coeff[0][11]_i_29_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair163" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][11]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[11]),
        .I2(\coeff_reg[0][11]_i_7_n_4 ),
        .O(\coeff[0][11]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_30 
       (.I0(unamedDSP__1_i_7_n_0),
        .I1(unamedDSP__2_n_96),
        .O(\coeff[0][11]_i_30_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][11]_i_31 
       (.I0(unamedDSP__1_i_8_n_0),
        .I1(unamedDSP__2_n_97),
        .O(\coeff[0][11]_i_31_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][11]_i_4 
       (.I0(\coeff[0][11]_i_8_n_0 ),
        .I1(\coeff[0][11]_i_9_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[11]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][11]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair163" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][11]_i_5 
       (.I0(p_7_out__0[27]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][11]_i_10_n_4 ),
        .O(\coeff[0][11]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h2C002000)) 
    \coeff[0][11]_i_8 
       (.I0(\coeff_reg[0][11]_i_19_n_4 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(p_1_out__0[27]),
        .O(\coeff[0][11]_i_8_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][11]_i_9 
       (.I0(load_data_IBUF[11]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][11]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[0][12]_i_1 
       (.I0(\coeff[0][12]_i_2_n_0 ),
        .I1(load_data_IBUF[12]),
        .I2(\coeff[0][12]_i_3_n_0 ),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][12]_i_4_n_0 ),
        .O(coeff[12]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][12]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair162" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][12]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[12]),
        .I2(\coeff_reg[0][15]_i_18_n_7 ),
        .O(\coeff[0][12]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFFF0F2F2)) 
    \coeff[0][12]_i_4 
       (.I0(load_data_IBUF[12]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][12]_i_6_n_0 ),
        .I3(\coeff[0][12]_i_7_n_0 ),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][12]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair162" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][12]_i_5 
       (.I0(p_7_out__0[28]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][15]_i_32_n_7 ),
        .O(\coeff[0][12]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][12]_i_6 
       (.I0(load_data_IBUF[12]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][12]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'h0AC00000)) 
    \coeff[0][12]_i_7 
       (.I0(p_1_out__0[28]),
        .I1(\coeff_reg[0][15]_i_41_n_7 ),
        .I2(state[1]),
        .I3(state[0]),
        .I4(state[2]),
        .O(\coeff[0][12]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][13]_i_1 
       (.I0(\coeff[0][13]_i_2_n_0 ),
        .I1(\coeff[0][13]_i_3_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][13]_i_4_n_0 ),
        .O(coeff[13]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][13]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair161" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][13]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[13]),
        .I2(\coeff_reg[0][15]_i_18_n_6 ),
        .O(\coeff[0][13]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][13]_i_4 
       (.I0(\coeff[0][13]_i_6_n_0 ),
        .I1(\coeff[0][13]_i_7_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[13]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][13]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair161" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][13]_i_5 
       (.I0(p_7_out__0[29]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][15]_i_32_n_6 ),
        .O(\coeff[0][13]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h0AC00000)) 
    \coeff[0][13]_i_6 
       (.I0(p_1_out__0[29]),
        .I1(\coeff_reg[0][15]_i_41_n_6 ),
        .I2(state[1]),
        .I3(state[0]),
        .I4(state[2]),
        .O(\coeff[0][13]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][13]_i_7 
       (.I0(load_data_IBUF[13]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][13]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][14]_i_1 
       (.I0(\coeff[0][14]_i_2_n_0 ),
        .I1(\coeff[0][14]_i_3_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][14]_i_4_n_0 ),
        .O(coeff[14]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][14]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair160" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][14]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[14]),
        .I2(\coeff_reg[0][15]_i_18_n_5 ),
        .O(\coeff[0][14]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][14]_i_4 
       (.I0(\coeff[0][14]_i_6_n_0 ),
        .I1(\coeff[0][14]_i_7_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[14]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][14]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair160" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][14]_i_5 
       (.I0(p_7_out__0[30]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][15]_i_32_n_5 ),
        .O(\coeff[0][14]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h2C002000)) 
    \coeff[0][14]_i_6 
       (.I0(\coeff_reg[0][15]_i_41_n_5 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(p_1_out__0[30]),
        .O(\coeff[0][14]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][14]_i_7 
       (.I0(load_data_IBUF[14]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][14]_i_7_n_0 ));
  LUT4 #(
    .INIT(16'hFBAA)) 
    \coeff[0][15]_i_1 
       (.I0(\coeff[0][15]_i_3_n_0 ),
        .I1(\coeff[0][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_5_n_0 ),
        .I3(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][15]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair181" *) 
  LUT5 #(
    .INIT(32'h00000001)) 
    \coeff[0][15]_i_10 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(\cnt_reg_n_0_[1] ),
        .I2(\cnt_reg_n_0_[4] ),
        .I3(\cnt_reg_n_0_[3] ),
        .I4(\cnt_reg_n_0_[2] ),
        .O(\coeff[0][15]_i_10_n_0 ));
  LUT3 #(
    .INIT(8'h01)) 
    \coeff[0][15]_i_11 
       (.I0(load_addr_IBUF[0]),
        .I1(\coeff[1][15]_i_10_n_0 ),
        .I2(load_addr_IBUF[1]),
        .O(\coeff[0][15]_i_11_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT5 #(
    .INIT(32'hFFFFFFFE)) 
    \coeff[0][15]_i_12 
       (.I0(p_1_in[4]),
        .I1(p_1_in[5]),
        .I2(p_1_in[7]),
        .I3(p_1_in[6]),
        .I4(p_1_in[3]),
        .O(\coeff[0][15]_i_12_n_0 ));
  LUT5 #(
    .INIT(32'h00000001)) 
    \coeff[0][15]_i_15 
       (.I0(p_2_out[3]),
        .I1(p_2_out[5]),
        .I2(p_2_out[7]),
        .I3(p_2_out[4]),
        .I4(p_2_out[6]),
        .O(\coeff[0][15]_i_15_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair159" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][15]_i_16 
       (.I0(p_7_out__0[31]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][15]_i_32_n_4 ),
        .O(\coeff[0][15]_i_16_n_0 ));
  LUT5 #(
    .INIT(32'h2C002000)) 
    \coeff[0][15]_i_19 
       (.I0(\coeff_reg[0][15]_i_41_n_4 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(p_1_out__0[31]),
        .O(\coeff[0][15]_i_19_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][15]_i_2 
       (.I0(\coeff[0][15]_i_7_n_0 ),
        .I1(\coeff[0][15]_i_8_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][15]_i_9_n_0 ),
        .O(coeff[15]));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][15]_i_20 
       (.I0(load_data_IBUF[15]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][15]_i_20_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_23 
       (.I0(\coeff_reg[0][15]_i_22_n_6 ),
        .I1(\j_cnt_reg_n_0_[4] ),
        .O(\coeff[0][15]_i_23_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_24 
       (.I0(\coeff_reg[0][15]_i_22_n_7 ),
        .I1(\j_cnt_reg_n_0_[3] ),
        .O(\coeff[0][15]_i_24_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_25 
       (.I0(a_i_98_n_6),
        .I1(\j_cnt_reg_n_0_[2] ),
        .O(\coeff[0][15]_i_25_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_26 
       (.I0(a_i_98_n_7),
        .I1(\j_cnt_reg_n_0_[1] ),
        .O(\coeff[0][15]_i_26_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_27 
       (.I0(p_1_in[3]),
        .I1(\len_reg_n_0_[3] ),
        .O(\coeff[0][15]_i_27_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_28 
       (.I0(p_1_in[2]),
        .I1(\len_reg_n_0_[2] ),
        .O(\coeff[0][15]_i_28_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_29 
       (.I0(p_1_in[1]),
        .I1(\len_reg_n_0_[1] ),
        .O(\coeff[0][15]_i_29_n_0 ));
  LUT5 #(
    .INIT(32'h444F4444)) 
    \coeff[0][15]_i_3 
       (.I0(\coeff[1][15]_i_7_n_0 ),
        .I1(\coeff[0][15]_i_10_n_0 ),
        .I2(load_addr_IBUF[2]),
        .I3(load_addr_IBUF[3]),
        .I4(\coeff[0][15]_i_11_n_0 ),
        .O(\coeff[0][15]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_30 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .O(\coeff[0][15]_i_30_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_33 
       (.I0(unamedDSP_i_1_n_4),
        .I1(unamedDSP__0_n_90),
        .O(\coeff[0][15]_i_33_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_34 
       (.I0(unamedDSP_i_1_n_5),
        .I1(unamedDSP__0_n_91),
        .O(\coeff[0][15]_i_34_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_35 
       (.I0(unamedDSP_i_1_n_6),
        .I1(unamedDSP__0_n_92),
        .O(\coeff[0][15]_i_35_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_36 
       (.I0(unamedDSP_i_1_n_7),
        .I1(unamedDSP__0_n_93),
        .O(\coeff[0][15]_i_36_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_37 
       (.I0(p_4_out__0[31]),
        .I1(unamedDSP_i_43_n_0),
        .O(\coeff[0][15]_i_37_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_38 
       (.I0(p_4_out__0[30]),
        .I1(unamedDSP_i_36_n_0),
        .O(\coeff[0][15]_i_38_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_39 
       (.I0(p_4_out__0[29]),
        .I1(unamedDSP_i_37_n_0),
        .O(\coeff[0][15]_i_39_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair189" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    \coeff[0][15]_i_4 
       (.I0(\coeff[0][15]_i_12_n_0 ),
        .I1(p_1_in[1]),
        .I2(\j_cnt_reg_n_0_[0] ),
        .I3(p_1_in[2]),
        .O(\coeff[0][15]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_40 
       (.I0(p_4_out__0[28]),
        .I1(unamedDSP_i_38_n_0),
        .O(\coeff[0][15]_i_40_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_42 
       (.I0(\j_cnt_reg_n_0_[7] ),
        .I1(\coeff_reg[0][15]_i_66_n_7 ),
        .O(\coeff[0][15]_i_42_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_43 
       (.I0(\coeff_reg[0][15]_i_22_n_4 ),
        .I1(\j_cnt_reg_n_0_[6] ),
        .O(\coeff[0][15]_i_43_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_44 
       (.I0(\coeff_reg[0][15]_i_22_n_5 ),
        .I1(\j_cnt_reg_n_0_[5] ),
        .O(\coeff[0][15]_i_44_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_45 
       (.I0(\coeff_reg[0][15]_i_46_n_6 ),
        .I1(\coeff_reg[0][15]_i_67_n_4 ),
        .O(\coeff[0][15]_i_45_n_0 ));
  LUT4 #(
    .INIT(16'h9666)) 
    \coeff[0][15]_i_47 
       (.I0(\coeff_reg[0][15]_i_67_n_4 ),
        .I1(\coeff_reg[0][15]_i_46_n_6 ),
        .I2(\len_reg_n_0_[5] ),
        .I3(\block_cnt_reg_n_0_[0] ),
        .O(\coeff[0][15]_i_47_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_48 
       (.I0(\coeff_reg[0][15]_i_46_n_7 ),
        .I1(\coeff_reg[0][15]_i_67_n_5 ),
        .O(\coeff[0][15]_i_48_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_49 
       (.I0(a_i_98_n_4),
        .I1(\coeff_reg[0][15]_i_67_n_6 ),
        .O(\coeff[0][15]_i_49_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair79" *) 
  LUT4 #(
    .INIT(16'h0100)) 
    \coeff[0][15]_i_5 
       (.I0(p_2_out[1]),
        .I1(p_2_out[0]),
        .I2(p_2_out[2]),
        .I3(\coeff[0][15]_i_15_n_0 ),
        .O(\coeff[0][15]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_50 
       (.I0(a_i_98_n_5),
        .I1(\coeff_reg[0][15]_i_67_n_7 ),
        .O(\coeff[0][15]_i_50_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_51 
       (.I0(\len_reg_n_0_[7] ),
        .I1(p_1_in[7]),
        .O(\coeff[0][15]_i_51_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_52 
       (.I0(p_1_in[6]),
        .I1(\len_reg_n_0_[6] ),
        .O(\coeff[0][15]_i_52_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_53 
       (.I0(p_1_in[5]),
        .I1(\len_reg_n_0_[5] ),
        .O(\coeff[0][15]_i_53_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_54 
       (.I0(p_1_in[4]),
        .I1(\len_reg_n_0_[4] ),
        .O(\coeff[0][15]_i_54_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][15]_i_55 
       (.I0(unamedDSP_i_36_n_0),
        .O(\coeff[0][15]_i_55_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][15]_i_56 
       (.I0(unamedDSP_i_37_n_0),
        .O(\coeff[0][15]_i_56_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][15]_i_57 
       (.I0(unamedDSP_i_38_n_0),
        .O(\coeff[0][15]_i_57_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_58 
       (.I0(unamedDSP_i_43_n_0),
        .I1(p_4_out__0[31]),
        .O(\coeff[0][15]_i_58_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_59 
       (.I0(unamedDSP_i_36_n_0),
        .I1(p_4_out__0[30]),
        .O(\coeff[0][15]_i_59_n_0 ));
  LUT4 #(
    .INIT(16'h0040)) 
    \coeff[0][15]_i_6 
       (.I0(state[0]),
        .I1(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I2(state[1]),
        .I3(state[2]),
        .O(\coeff[0][15]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_60 
       (.I0(unamedDSP_i_37_n_0),
        .I1(p_4_out__0[29]),
        .O(\coeff[0][15]_i_60_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_61 
       (.I0(unamedDSP_i_38_n_0),
        .I1(p_4_out__0[28]),
        .O(\coeff[0][15]_i_61_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][15]_i_62 
       (.I0(unamedDSP__2_n_90),
        .I1(unamedDSP__1_i_17_n_0),
        .O(\coeff[0][15]_i_62_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_63 
       (.I0(unamedDSP__1_i_2_n_0),
        .I1(unamedDSP__2_n_91),
        .O(\coeff[0][15]_i_63_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_64 
       (.I0(unamedDSP__1_i_3_n_0),
        .I1(unamedDSP__2_n_92),
        .O(\coeff[0][15]_i_64_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][15]_i_65 
       (.I0(unamedDSP__1_i_4_n_0),
        .I1(unamedDSP__2_n_93),
        .O(\coeff[0][15]_i_65_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \coeff[0][15]_i_68 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg_n_0_[5] ),
        .O(\coeff[0][15]_i_68_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \coeff[0][15]_i_69 
       (.I0(\len_reg_n_0_[0] ),
        .I1(\block_cnt_reg_n_0_[4] ),
        .O(\coeff[0][15]_i_69_n_0 ));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][15]_i_7_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \coeff[0][15]_i_70 
       (.I0(\len_reg_n_0_[1] ),
        .I1(\block_cnt_reg_n_0_[5] ),
        .I2(\block_cnt_reg_n_0_[6] ),
        .I3(\len_reg_n_0_[0] ),
        .O(\coeff[0][15]_i_70_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \coeff[0][15]_i_71 
       (.I0(\block_cnt_reg_n_0_[5] ),
        .I1(\len_reg_n_0_[0] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\block_cnt_reg_n_0_[4] ),
        .O(\coeff[0][15]_i_71_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \coeff[0][15]_i_72 
       (.I0(\block_cnt_reg_n_0_[4] ),
        .I1(\len_reg_n_0_[0] ),
        .I2(\len_reg_n_0_[1] ),
        .I3(\block_cnt_reg_n_0_[3] ),
        .O(\coeff[0][15]_i_72_n_0 ));
  LUT5 #(
    .INIT(32'h69999666)) 
    \coeff[0][15]_i_73 
       (.I0(\coeff_reg[0][15]_i_81_n_7 ),
        .I1(\coeff_reg[0][15]_i_46_n_5 ),
        .I2(\block_cnt_reg_n_0_[0] ),
        .I3(\len_reg_n_0_[6] ),
        .I4(\coeff[0][15]_i_82_n_0 ),
        .O(\coeff[0][15]_i_73_n_0 ));
  LUT6 #(
    .INIT(64'h8777788878887888)) 
    \coeff[0][15]_i_74 
       (.I0(\len_reg_n_0_[2] ),
        .I1(\block_cnt_reg_n_0_[3] ),
        .I2(\block_cnt_reg_n_0_[2] ),
        .I3(\len_reg_n_0_[3] ),
        .I4(\block_cnt_reg_n_0_[1] ),
        .I5(\len_reg_n_0_[4] ),
        .O(\coeff[0][15]_i_74_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \coeff[0][15]_i_75 
       (.I0(\len_reg_n_0_[3] ),
        .I1(\block_cnt_reg_n_0_[1] ),
        .I2(\len_reg_n_0_[4] ),
        .I3(\block_cnt_reg_n_0_[0] ),
        .O(\coeff[0][15]_i_75_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \coeff[0][15]_i_76 
       (.I0(\block_cnt_reg_n_0_[1] ),
        .I1(\len_reg_n_0_[2] ),
        .O(\coeff[0][15]_i_76_n_0 ));
  LUT6 #(
    .INIT(64'h6A953F3F6A6AC0C0)) 
    \coeff[0][15]_i_77 
       (.I0(\block_cnt_reg_n_0_[2] ),
        .I1(\block_cnt_reg_n_0_[3] ),
        .I2(\len_reg_n_0_[2] ),
        .I3(\block_cnt_reg_n_0_[0] ),
        .I4(\len_reg_n_0_[3] ),
        .I5(\coeff[0][15]_i_83_n_0 ),
        .O(\coeff[0][15]_i_77_n_0 ));
  LUT6 #(
    .INIT(64'h8777788878887888)) 
    \coeff[0][15]_i_78 
       (.I0(\block_cnt_reg_n_0_[0] ),
        .I1(\len_reg_n_0_[4] ),
        .I2(\block_cnt_reg_n_0_[1] ),
        .I3(\len_reg_n_0_[3] ),
        .I4(\len_reg_n_0_[2] ),
        .I5(\block_cnt_reg_n_0_[2] ),
        .O(\coeff[0][15]_i_78_n_0 ));
  LUT4 #(
    .INIT(16'h7888)) 
    \coeff[0][15]_i_79 
       (.I0(\len_reg_n_0_[2] ),
        .I1(\block_cnt_reg_n_0_[1] ),
        .I2(\len_reg_n_0_[3] ),
        .I3(\block_cnt_reg_n_0_[0] ),
        .O(\coeff[0][15]_i_79_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair159" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][15]_i_8 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[15]),
        .I2(\coeff_reg[0][15]_i_18_n_4 ),
        .O(\coeff[0][15]_i_8_n_0 ));
  LUT2 #(
    .INIT(4'h8)) 
    \coeff[0][15]_i_80 
       (.I0(\block_cnt_reg_n_0_[0] ),
        .I1(\len_reg_n_0_[2] ),
        .O(\coeff[0][15]_i_80_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair78" *) 
  LUT4 #(
    .INIT(16'h7888)) 
    \coeff[0][15]_i_82 
       (.I0(\len_reg_n_0_[5] ),
        .I1(\block_cnt_reg_n_0_[1] ),
        .I2(\coeff_reg[0][15]_i_67_n_4 ),
        .I3(\coeff_reg[0][15]_i_46_n_6 ),
        .O(\coeff[0][15]_i_82_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair78" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \coeff[0][15]_i_83 
       (.I0(\block_cnt_reg_n_0_[1] ),
        .I1(\len_reg_n_0_[4] ),
        .O(\coeff[0][15]_i_83_n_0 ));
  LUT6 #(
    .INIT(64'hEA808080157F7F7F)) 
    \coeff[0][15]_i_84 
       (.I0(\coeff[0][15]_i_85_n_0 ),
        .I1(\block_cnt_reg_n_0_[2] ),
        .I2(\len_reg_n_0_[3] ),
        .I3(\block_cnt_reg_n_0_[1] ),
        .I4(\len_reg_n_0_[4] ),
        .I5(\coeff[0][15]_i_86_n_0 ),
        .O(\coeff[0][15]_i_84_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair179" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \coeff[0][15]_i_85 
       (.I0(\block_cnt_reg_n_0_[3] ),
        .I1(\len_reg_n_0_[2] ),
        .O(\coeff[0][15]_i_85_n_0 ));
  LUT6 #(
    .INIT(64'h7888877787778777)) 
    \coeff[0][15]_i_86 
       (.I0(\len_reg_n_0_[2] ),
        .I1(\block_cnt_reg_n_0_[4] ),
        .I2(\block_cnt_reg_n_0_[3] ),
        .I3(\len_reg_n_0_[3] ),
        .I4(\block_cnt_reg_n_0_[2] ),
        .I5(\len_reg_n_0_[4] ),
        .O(\coeff[0][15]_i_86_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][15]_i_9 
       (.I0(\coeff[0][15]_i_19_n_0 ),
        .I1(\coeff[0][15]_i_20_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[15]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][15]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[0][1]_i_1 
       (.I0(\coeff[0][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][1]_i_4_n_0 ),
        .O(coeff[1]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][1]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair173" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][1]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[1]),
        .I2(\coeff_reg[0][3]_i_7_n_6 ),
        .O(\coeff[0][1]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[0][1]_i_4 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[0][15]_i_10_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[0][1]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair173" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][1]_i_5 
       (.I0(p_7_out__0[17]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][3]_i_10_n_6 ),
        .O(\coeff[0][1]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair67" *) 
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][1]_i_6 
       (.I0(load_data_IBUF[1]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][1]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'h2C002000)) 
    \coeff[0][1]_i_7 
       (.I0(\coeff_reg[0][3]_i_19_n_6 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(p_1_out__0[17]),
        .O(\coeff[0][1]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][2]_i_1 
       (.I0(\coeff[0][2]_i_2_n_0 ),
        .I1(\coeff[0][2]_i_3_n_0 ),
        .I2(load_data_IBUF[2]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][2]_i_4_n_0 ),
        .O(coeff[2]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][2]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair172" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][2]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[2]),
        .I2(\coeff_reg[0][3]_i_7_n_5 ),
        .O(\coeff[0][2]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][2]_i_4 
       (.I0(\coeff[0][2]_i_6_n_0 ),
        .I1(\coeff[0][2]_i_7_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[2]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][2]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair172" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][2]_i_5 
       (.I0(p_7_out__0[18]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][3]_i_10_n_5 ),
        .O(\coeff[0][2]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h2C002000)) 
    \coeff[0][2]_i_6 
       (.I0(\coeff_reg[0][3]_i_19_n_5 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(p_1_out__0[18]),
        .O(\coeff[0][2]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][2]_i_7 
       (.I0(load_data_IBUF[2]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][2]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[0][3]_i_1 
       (.I0(\coeff[0][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][3]_i_4_n_0 ),
        .O(coeff[3]));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_11 
       (.I0(unamedDSP_i_4_n_4),
        .I1(unamedDSP__0_n_102),
        .O(\coeff[0][3]_i_11_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_12 
       (.I0(unamedDSP_i_4_n_5),
        .I1(unamedDSP__0_n_103),
        .O(\coeff[0][3]_i_12_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_13 
       (.I0(unamedDSP_i_4_n_6),
        .I1(unamedDSP__0_n_104),
        .O(\coeff[0][3]_i_13_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_14 
       (.I0(unamedDSP_i_4_n_7),
        .I1(unamedDSP__0_n_105),
        .O(\coeff[0][3]_i_14_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_15 
       (.I0(p_4_out__0[19]),
        .I1(unamedDSP_i_63_n_0),
        .O(\coeff[0][3]_i_15_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_16 
       (.I0(p_4_out__0[18]),
        .I1(unamedDSP_i_64_n_0),
        .O(\coeff[0][3]_i_16_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_17 
       (.I0(p_4_out__0[17]),
        .I1(unamedDSP_i_65_n_0),
        .O(\coeff[0][3]_i_17_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_18 
       (.I0(p_4_out__0[16]),
        .I1(unamedDSP_i_66_n_0),
        .O(\coeff[0][3]_i_18_n_0 ));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][3]_i_2_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][3]_i_20 
       (.I0(unamedDSP_i_63_n_0),
        .O(\coeff[0][3]_i_20_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][3]_i_21 
       (.I0(unamedDSP_i_64_n_0),
        .O(\coeff[0][3]_i_21_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][3]_i_22 
       (.I0(unamedDSP_i_65_n_0),
        .O(\coeff[0][3]_i_22_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][3]_i_23 
       (.I0(unamedDSP_i_66_n_0),
        .O(\coeff[0][3]_i_23_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][3]_i_24 
       (.I0(unamedDSP_i_63_n_0),
        .I1(p_4_out__0[19]),
        .O(\coeff[0][3]_i_24_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][3]_i_25 
       (.I0(unamedDSP_i_64_n_0),
        .I1(p_4_out__0[18]),
        .O(\coeff[0][3]_i_25_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][3]_i_26 
       (.I0(unamedDSP_i_65_n_0),
        .I1(p_4_out__0[17]),
        .O(\coeff[0][3]_i_26_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][3]_i_27 
       (.I0(unamedDSP_i_66_n_0),
        .I1(p_4_out__0[16]),
        .O(\coeff[0][3]_i_27_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_28 
       (.I0(unamedDSP__1_i_13_n_0),
        .I1(unamedDSP__2_n_102),
        .O(\coeff[0][3]_i_28_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_29 
       (.I0(unamedDSP__1_i_14_n_0),
        .I1(unamedDSP__2_n_103),
        .O(\coeff[0][3]_i_29_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair171" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][3]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[3]),
        .I2(\coeff_reg[0][3]_i_7_n_4 ),
        .O(\coeff[0][3]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_30 
       (.I0(unamedDSP__1_i_15_n_0),
        .I1(unamedDSP__2_n_104),
        .O(\coeff[0][3]_i_30_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][3]_i_31 
       (.I0(unamedDSP__1_i_16_n_0),
        .I1(unamedDSP__2_n_105),
        .O(\coeff[0][3]_i_31_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[0][3]_i_4 
       (.I0(\coeff[0][3]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[3]),
        .I3(\coeff[0][15]_i_10_n_0 ),
        .I4(\coeff[0][3]_i_9_n_0 ),
        .O(\coeff[0][3]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair171" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][3]_i_5 
       (.I0(p_7_out__0[19]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][3]_i_10_n_4 ),
        .O(\coeff[0][3]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][3]_i_8 
       (.I0(load_data_IBUF[3]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][3]_i_8_n_0 ));
  LUT5 #(
    .INIT(32'h2C002000)) 
    \coeff[0][3]_i_9 
       (.I0(\coeff_reg[0][3]_i_19_n_4 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(p_1_out__0[19]),
        .O(\coeff[0][3]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][4]_i_1 
       (.I0(\coeff[0][4]_i_2_n_0 ),
        .I1(\coeff[0][4]_i_3_n_0 ),
        .I2(load_data_IBUF[4]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][4]_i_4_n_0 ),
        .O(coeff[4]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][4]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair170" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][4]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[4]),
        .I2(\coeff_reg[0][7]_i_7_n_7 ),
        .O(\coeff[0][4]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][4]_i_4 
       (.I0(\coeff[0][4]_i_6_n_0 ),
        .I1(\coeff[0][4]_i_7_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[4]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][4]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair170" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][4]_i_5 
       (.I0(p_7_out__0[20]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][7]_i_10_n_7 ),
        .O(\coeff[0][4]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h0AC00000)) 
    \coeff[0][4]_i_6 
       (.I0(p_1_out__0[20]),
        .I1(\coeff_reg[0][7]_i_19_n_7 ),
        .I2(state[1]),
        .I3(state[0]),
        .I4(state[2]),
        .O(\coeff[0][4]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][4]_i_7 
       (.I0(load_data_IBUF[4]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][4]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[0][5]_i_1 
       (.I0(\coeff[0][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][5]_i_4_n_0 ),
        .O(coeff[5]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][5]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair169" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][5]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[5]),
        .I2(\coeff_reg[0][7]_i_7_n_6 ),
        .O(\coeff[0][5]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[0][5]_i_4 
       (.I0(\coeff[0][5]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[5]),
        .I3(\coeff[0][15]_i_10_n_0 ),
        .I4(\coeff[0][5]_i_7_n_0 ),
        .O(\coeff[0][5]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair169" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][5]_i_5 
       (.I0(p_7_out__0[21]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][7]_i_10_n_6 ),
        .O(\coeff[0][5]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][5]_i_6 
       (.I0(load_data_IBUF[5]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][5]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'h2C002000)) 
    \coeff[0][5]_i_7 
       (.I0(\coeff_reg[0][7]_i_19_n_6 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(p_1_out__0[21]),
        .O(\coeff[0][5]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][6]_i_1 
       (.I0(\coeff[0][6]_i_2_n_0 ),
        .I1(\coeff[0][6]_i_3_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][6]_i_4_n_0 ),
        .O(coeff[6]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][6]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair168" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][6]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[6]),
        .I2(\coeff_reg[0][7]_i_7_n_5 ),
        .O(\coeff[0][6]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][6]_i_4 
       (.I0(\coeff[0][6]_i_6_n_0 ),
        .I1(\coeff[0][6]_i_7_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[6]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][6]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair168" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][6]_i_5 
       (.I0(p_7_out__0[22]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][7]_i_10_n_5 ),
        .O(\coeff[0][6]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h0AC00000)) 
    \coeff[0][6]_i_6 
       (.I0(p_1_out__0[22]),
        .I1(\coeff_reg[0][7]_i_19_n_5 ),
        .I2(state[1]),
        .I3(state[0]),
        .I4(state[2]),
        .O(\coeff[0][6]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][6]_i_7 
       (.I0(load_data_IBUF[6]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][6]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[0][7]_i_1 
       (.I0(\coeff[0][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][7]_i_4_n_0 ),
        .O(coeff[7]));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_11 
       (.I0(unamedDSP_i_3_n_4),
        .I1(unamedDSP__0_n_98),
        .O(\coeff[0][7]_i_11_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_12 
       (.I0(unamedDSP_i_3_n_5),
        .I1(unamedDSP__0_n_99),
        .O(\coeff[0][7]_i_12_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_13 
       (.I0(unamedDSP_i_3_n_6),
        .I1(unamedDSP__0_n_100),
        .O(\coeff[0][7]_i_13_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_14 
       (.I0(unamedDSP_i_3_n_7),
        .I1(unamedDSP__0_n_101),
        .O(\coeff[0][7]_i_14_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_15 
       (.I0(p_4_out__0[23]),
        .I1(unamedDSP_i_55_n_0),
        .O(\coeff[0][7]_i_15_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_16 
       (.I0(p_4_out__0[22]),
        .I1(unamedDSP_i_56_n_0),
        .O(\coeff[0][7]_i_16_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_17 
       (.I0(p_4_out__0[21]),
        .I1(unamedDSP_i_57_n_0),
        .O(\coeff[0][7]_i_17_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_18 
       (.I0(p_4_out__0[20]),
        .I1(unamedDSP_i_58_n_0),
        .O(\coeff[0][7]_i_18_n_0 ));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][7]_i_2_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][7]_i_20 
       (.I0(unamedDSP_i_55_n_0),
        .O(\coeff[0][7]_i_20_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][7]_i_21 
       (.I0(unamedDSP_i_56_n_0),
        .O(\coeff[0][7]_i_21_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][7]_i_22 
       (.I0(unamedDSP_i_57_n_0),
        .O(\coeff[0][7]_i_22_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \coeff[0][7]_i_23 
       (.I0(unamedDSP_i_58_n_0),
        .O(\coeff[0][7]_i_23_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][7]_i_24 
       (.I0(unamedDSP_i_55_n_0),
        .I1(p_4_out__0[23]),
        .O(\coeff[0][7]_i_24_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][7]_i_25 
       (.I0(unamedDSP_i_56_n_0),
        .I1(p_4_out__0[22]),
        .O(\coeff[0][7]_i_25_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][7]_i_26 
       (.I0(unamedDSP_i_57_n_0),
        .I1(p_4_out__0[21]),
        .O(\coeff[0][7]_i_26_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \coeff[0][7]_i_27 
       (.I0(unamedDSP_i_58_n_0),
        .I1(p_4_out__0[20]),
        .O(\coeff[0][7]_i_27_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_28 
       (.I0(unamedDSP__1_i_9_n_0),
        .I1(unamedDSP__2_n_98),
        .O(\coeff[0][7]_i_28_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_29 
       (.I0(unamedDSP__1_i_10_n_0),
        .I1(unamedDSP__2_n_99),
        .O(\coeff[0][7]_i_29_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair167" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][7]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[7]),
        .I2(\coeff_reg[0][7]_i_7_n_4 ),
        .O(\coeff[0][7]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_30 
       (.I0(unamedDSP__1_i_11_n_0),
        .I1(unamedDSP__2_n_100),
        .O(\coeff[0][7]_i_30_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \coeff[0][7]_i_31 
       (.I0(unamedDSP__1_i_12_n_0),
        .I1(unamedDSP__2_n_101),
        .O(\coeff[0][7]_i_31_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[0][7]_i_4 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[0][15]_i_10_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[0][7]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair167" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][7]_i_5 
       (.I0(p_7_out__0[23]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][7]_i_10_n_4 ),
        .O(\coeff[0][7]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][7]_i_8 
       (.I0(load_data_IBUF[7]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][7]_i_8_n_0 ));
  LUT5 #(
    .INIT(32'h2C002000)) 
    \coeff[0][7]_i_9 
       (.I0(\coeff_reg[0][7]_i_19_n_4 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(p_1_out__0[23]),
        .O(\coeff[0][7]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][8]_i_1 
       (.I0(\coeff[0][8]_i_2_n_0 ),
        .I1(\coeff[0][8]_i_3_n_0 ),
        .I2(load_data_IBUF[8]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][8]_i_4_n_0 ),
        .O(coeff[8]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][8]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair166" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][8]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[8]),
        .I2(\coeff_reg[0][11]_i_7_n_7 ),
        .O(\coeff[0][8]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][8]_i_4 
       (.I0(\coeff[0][8]_i_6_n_0 ),
        .I1(\coeff[0][8]_i_7_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[8]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][8]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair166" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][8]_i_5 
       (.I0(p_7_out__0[24]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][11]_i_10_n_7 ),
        .O(\coeff[0][8]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h0AC00000)) 
    \coeff[0][8]_i_6 
       (.I0(p_1_out__0[24]),
        .I1(\coeff_reg[0][11]_i_19_n_7 ),
        .I2(state[1]),
        .I3(state[0]),
        .I4(state[2]),
        .O(\coeff[0][8]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][8]_i_7 
       (.I0(load_data_IBUF[8]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][8]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[0][9]_i_1 
       (.I0(\coeff[0][9]_i_2_n_0 ),
        .I1(\coeff[0][9]_i_3_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[0][15]_i_4_n_0 ),
        .I4(\coeff[0][15]_i_5_n_0 ),
        .I5(\coeff[0][9]_i_4_n_0 ),
        .O(coeff[9]));
  LUT6 #(
    .INIT(64'h00010000FFFFFFFF)) 
    \coeff[0][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[0][15]_i_15_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[0][9]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair165" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    \coeff[0][9]_i_3 
       (.I0(inv_mode_reg_n_0),
        .I1(barrett_reduce_return[9]),
        .I2(\coeff_reg[0][11]_i_7_n_6 ),
        .O(\coeff[0][9]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'hEEEECFCC)) 
    \coeff[0][9]_i_4 
       (.I0(\coeff[0][9]_i_6_n_0 ),
        .I1(\coeff[0][9]_i_7_n_0 ),
        .I2(\coeff[1][15]_i_7_n_0 ),
        .I3(load_data_IBUF[9]),
        .I4(\coeff[0][15]_i_10_n_0 ),
        .O(\coeff[0][9]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair165" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \coeff[0][9]_i_5 
       (.I0(p_7_out__0[25]),
        .I1(inv_mode_reg_n_0),
        .I2(\coeff_reg[0][11]_i_10_n_6 ),
        .O(\coeff[0][9]_i_5_n_0 ));
  LUT5 #(
    .INIT(32'h2C002000)) 
    \coeff[0][9]_i_6 
       (.I0(\coeff_reg[0][11]_i_19_n_6 ),
        .I1(state[0]),
        .I2(state[1]),
        .I3(state[2]),
        .I4(p_1_out__0[25]),
        .O(\coeff[0][9]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hA0A22A2A)) 
    \coeff[0][9]_i_7 
       (.I0(load_data_IBUF[9]),
        .I1(state[2]),
        .I2(state[0]),
        .I3(\FSM_sequential_state_reg[2]_i_3_n_0 ),
        .I4(state[1]),
        .O(\coeff[0][9]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[10][0]_i_1 
       (.I0(\coeff[10][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][0]_i_3_n_0 ),
        .O(\coeff[10][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[10][0]_i_3 
       (.I0(\coeff[0][0]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[0]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][0]_i_6_n_0 ),
        .O(\coeff[10][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[10][10]_i_1 
       (.I0(\coeff[10][10]_i_2_n_0 ),
        .I1(\coeff[0][10]_i_3_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][10]_i_3_n_0 ),
        .O(\coeff[10][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[10][10]_i_3 
       (.I0(\coeff[0][10]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[10][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[10][11]_i_1 
       (.I0(\coeff[10][11]_i_2_n_0 ),
        .I1(\coeff[0][11]_i_3_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][11]_i_3_n_0 ),
        .O(\coeff[10][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[10][11]_i_3 
       (.I0(\coeff[0][11]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[10][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[10][12]_i_1 
       (.I0(\coeff[10][12]_i_2_n_0 ),
        .I1(\coeff[0][12]_i_3_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][12]_i_3_n_0 ),
        .O(\coeff[10][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[10][12]_i_3 
       (.I0(\coeff[0][12]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[10][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[10][13]_i_1 
       (.I0(\coeff[10][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][13]_i_3_n_0 ),
        .O(\coeff[10][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[10][13]_i_3 
       (.I0(\coeff[0][13]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][13]_i_6_n_0 ),
        .O(\coeff[10][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[10][14]_i_1 
       (.I0(\coeff[10][14]_i_2_n_0 ),
        .I1(\coeff[0][14]_i_3_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][14]_i_3_n_0 ),
        .O(\coeff[10][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[10][14]_i_3 
       (.I0(\coeff[0][14]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[10][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hEAEEEAEEFFFFEAEE)) 
    \coeff[10][15]_i_1 
       (.I0(\coeff[10][15]_i_3_n_0 ),
        .I1(\coeff[0][15]_i_6_n_0 ),
        .I2(\coeff[10][15]_i_4_n_0 ),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_6_n_0 ),
        .I5(\coeff[1][15]_i_7_n_0 ),
        .O(\coeff[10][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[10][15]_i_2 
       (.I0(\coeff[10][15]_i_7_n_0 ),
        .I1(\coeff[0][15]_i_8_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][15]_i_8_n_0 ),
        .O(\coeff[10][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT5 #(
    .INIT(32'h00000400)) 
    \coeff[10][15]_i_3 
       (.I0(\coeff[1][15]_i_10_n_0 ),
        .I1(load_addr_IBUF[1]),
        .I2(load_addr_IBUF[0]),
        .I3(load_addr_IBUF[3]),
        .I4(load_addr_IBUF[2]),
        .O(\coeff[10][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair84" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \coeff[10][15]_i_4 
       (.I0(p_2_out[0]),
        .I1(p_2_out[1]),
        .I2(p_2_out[2]),
        .I3(\coeff[8][15]_i_9_n_0 ),
        .O(\coeff[10][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair89" *) 
  LUT4 #(
    .INIT(16'hFFFB)) 
    \coeff[10][15]_i_5 
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(p_1_in[1]),
        .I2(p_1_in[2]),
        .I3(\coeff[8][15]_i_8_n_0 ),
        .O(\coeff[10][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT5 #(
    .INIT(32'h00000400)) 
    \coeff[10][15]_i_6 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\cnt_reg_n_0_[3] ),
        .I2(\cnt_reg_n_0_[0] ),
        .I3(\cnt_reg_n_0_[1] ),
        .I4(\cnt_reg_n_0_[4] ),
        .O(\coeff[10][15]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[10][15]_i_8 
       (.I0(\coeff[0][15]_i_19_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[10][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[10][1]_i_1 
       (.I0(\coeff[10][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][1]_i_3_n_0 ),
        .O(\coeff[10][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[10][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[10][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[10][2]_i_1 
       (.I0(\coeff[10][2]_i_2_n_0 ),
        .I1(\coeff[0][2]_i_3_n_0 ),
        .I2(load_data_IBUF[2]),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][2]_i_3_n_0 ),
        .O(\coeff[10][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[10][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[10][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[10][3]_i_1 
       (.I0(\coeff[10][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][3]_i_3_n_0 ),
        .O(\coeff[10][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[10][3]_i_3 
       (.I0(\coeff[0][3]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[3]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][3]_i_9_n_0 ),
        .O(\coeff[10][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[10][4]_i_1 
       (.I0(\coeff[10][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][4]_i_3_n_0 ),
        .O(\coeff[10][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[10][4]_i_3 
       (.I0(\coeff[0][4]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[4]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][4]_i_6_n_0 ),
        .O(\coeff[10][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[10][5]_i_1 
       (.I0(\coeff[10][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][5]_i_3_n_0 ),
        .O(\coeff[10][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[10][5]_i_3 
       (.I0(\coeff[0][5]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[5]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][5]_i_7_n_0 ),
        .O(\coeff[10][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[10][6]_i_1 
       (.I0(\coeff[10][6]_i_2_n_0 ),
        .I1(load_data_IBUF[6]),
        .I2(\coeff[0][6]_i_3_n_0 ),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][6]_i_3_n_0 ),
        .O(\coeff[10][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[10][6]_i_3 
       (.I0(\coeff[0][6]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][6]_i_6_n_0 ),
        .O(\coeff[10][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[10][7]_i_1 
       (.I0(\coeff[10][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][7]_i_3_n_0 ),
        .O(\coeff[10][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[10][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[10][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[10][8]_i_1 
       (.I0(\coeff[10][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][8]_i_3_n_0 ),
        .O(\coeff[10][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[10][8]_i_3 
       (.I0(\coeff[0][8]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[8]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][8]_i_6_n_0 ),
        .O(\coeff[10][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[10][9]_i_1 
       (.I0(\coeff[10][9]_i_2_n_0 ),
        .I1(\coeff[0][9]_i_3_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[10][15]_i_5_n_0 ),
        .I4(\coeff[10][15]_i_4_n_0 ),
        .I5(\coeff[10][9]_i_3_n_0 ),
        .O(\coeff[10][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[10][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[10][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[10][9]_i_3 
       (.I0(\coeff[0][9]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[10][15]_i_6_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[10][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[11][0]_i_1 
       (.I0(\coeff[11][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][0]_i_3_n_0 ),
        .O(\coeff[11][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[11][0]_i_3 
       (.I0(\coeff[0][0]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[0]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][0]_i_6_n_0 ),
        .O(\coeff[11][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[11][10]_i_1 
       (.I0(\coeff[11][10]_i_2_n_0 ),
        .I1(\coeff[0][10]_i_3_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][10]_i_3_n_0 ),
        .O(\coeff[11][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[11][10]_i_3 
       (.I0(load_data_IBUF[10]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][10]_i_6_n_0 ),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[11][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[11][11]_i_1 
       (.I0(\coeff[11][11]_i_2_n_0 ),
        .I1(\coeff[0][11]_i_3_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][11]_i_3_n_0 ),
        .O(\coeff[11][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[11][11]_i_3 
       (.I0(\coeff[0][11]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[11][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[11][12]_i_1 
       (.I0(\coeff[11][12]_i_2_n_0 ),
        .I1(\coeff[0][12]_i_3_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][12]_i_3_n_0 ),
        .O(\coeff[11][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[11][12]_i_3 
       (.I0(\coeff[0][12]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[11][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[11][13]_i_1 
       (.I0(\coeff[11][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][13]_i_3_n_0 ),
        .O(\coeff[11][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[11][13]_i_3 
       (.I0(\coeff[0][13]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][13]_i_6_n_0 ),
        .O(\coeff[11][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[11][14]_i_1 
       (.I0(\coeff[11][14]_i_2_n_0 ),
        .I1(\coeff[0][14]_i_3_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][14]_i_3_n_0 ),
        .O(\coeff[11][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[11][14]_i_3 
       (.I0(\coeff[0][14]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[11][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFD0FFD0FFFFFFD0)) 
    \coeff[11][15]_i_1 
       (.I0(\coeff[11][15]_i_3_n_0 ),
        .I1(\coeff[11][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_6_n_0 ),
        .I3(\coeff[11][15]_i_5_n_0 ),
        .I4(\coeff[11][15]_i_6_n_0 ),
        .I5(\coeff[1][15]_i_7_n_0 ),
        .O(\coeff[11][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[11][15]_i_2 
       (.I0(\coeff[11][15]_i_7_n_0 ),
        .I1(\coeff[0][15]_i_8_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][15]_i_8_n_0 ),
        .O(\coeff[11][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair89" *) 
  LUT4 #(
    .INIT(16'hFFF7)) 
    \coeff[11][15]_i_3 
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(p_1_in[1]),
        .I2(p_1_in[2]),
        .I3(\coeff[8][15]_i_8_n_0 ),
        .O(\coeff[11][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair84" *) 
  LUT4 #(
    .INIT(16'h0008)) 
    \coeff[11][15]_i_4 
       (.I0(p_2_out[0]),
        .I1(p_2_out[1]),
        .I2(p_2_out[2]),
        .I3(\coeff[8][15]_i_9_n_0 ),
        .O(\coeff[11][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT5 #(
    .INIT(32'h00004000)) 
    \coeff[11][15]_i_5 
       (.I0(\coeff[1][15]_i_10_n_0 ),
        .I1(load_addr_IBUF[1]),
        .I2(load_addr_IBUF[0]),
        .I3(load_addr_IBUF[3]),
        .I4(load_addr_IBUF[2]),
        .O(\coeff[11][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT5 #(
    .INIT(32'h00004000)) 
    \coeff[11][15]_i_6 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\cnt_reg_n_0_[3] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\cnt_reg_n_0_[0] ),
        .I4(\cnt_reg_n_0_[4] ),
        .O(\coeff[11][15]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[11][15]_i_8 
       (.I0(\coeff[0][15]_i_19_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[11][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[11][1]_i_1 
       (.I0(\coeff[11][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][1]_i_3_n_0 ),
        .O(\coeff[11][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[11][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[11][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[11][2]_i_1 
       (.I0(\coeff[11][2]_i_2_n_0 ),
        .I1(\coeff[0][2]_i_3_n_0 ),
        .I2(load_data_IBUF[2]),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][2]_i_3_n_0 ),
        .O(\coeff[11][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[11][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[11][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[11][3]_i_1 
       (.I0(\coeff[11][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][3]_i_3_n_0 ),
        .O(\coeff[11][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[11][3]_i_3 
       (.I0(\coeff[0][3]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[3]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][3]_i_9_n_0 ),
        .O(\coeff[11][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[11][4]_i_1 
       (.I0(\coeff[11][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][4]_i_3_n_0 ),
        .O(\coeff[11][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[11][4]_i_3 
       (.I0(\coeff[0][4]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[4]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][4]_i_6_n_0 ),
        .O(\coeff[11][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[11][5]_i_1 
       (.I0(\coeff[11][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][5]_i_3_n_0 ),
        .O(\coeff[11][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[11][5]_i_3 
       (.I0(\coeff[0][5]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[5]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][5]_i_7_n_0 ),
        .O(\coeff[11][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[11][6]_i_1 
       (.I0(\coeff[11][6]_i_2_n_0 ),
        .I1(\coeff[0][6]_i_3_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][6]_i_3_n_0 ),
        .O(\coeff[11][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[11][6]_i_3 
       (.I0(\coeff[0][6]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[11][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[11][7]_i_1 
       (.I0(\coeff[11][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][7]_i_3_n_0 ),
        .O(\coeff[11][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[11][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[11][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[11][8]_i_1 
       (.I0(\coeff[11][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][8]_i_3_n_0 ),
        .O(\coeff[11][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[11][8]_i_3 
       (.I0(\coeff[0][8]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[8]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][8]_i_6_n_0 ),
        .O(\coeff[11][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[11][9]_i_1 
       (.I0(\coeff[11][9]_i_2_n_0 ),
        .I1(\coeff[0][9]_i_3_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[11][15]_i_3_n_0 ),
        .I4(\coeff[11][15]_i_4_n_0 ),
        .I5(\coeff[11][9]_i_3_n_0 ),
        .O(\coeff[11][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000040FFFFFFFF)) 
    \coeff[11][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[11][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[11][9]_i_3 
       (.I0(\coeff[0][9]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[11][15]_i_6_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[11][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[12][0]_i_1 
       (.I0(\coeff[12][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][0]_i_3_n_0 ),
        .O(\coeff[12][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[12][0]_i_3 
       (.I0(\coeff[0][0]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[0]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][0]_i_6_n_0 ),
        .O(\coeff[12][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[12][10]_i_1 
       (.I0(\coeff[12][10]_i_2_n_0 ),
        .I1(\coeff[0][10]_i_3_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][10]_i_3_n_0 ),
        .O(\coeff[12][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[12][10]_i_3 
       (.I0(\coeff[0][10]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[12][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[12][11]_i_1 
       (.I0(\coeff[12][11]_i_2_n_0 ),
        .I1(\coeff[0][11]_i_3_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][11]_i_3_n_0 ),
        .O(\coeff[12][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[12][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[12][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[12][12]_i_1 
       (.I0(\coeff[12][12]_i_2_n_0 ),
        .I1(load_data_IBUF[12]),
        .I2(\coeff[0][12]_i_3_n_0 ),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][12]_i_3_n_0 ),
        .O(\coeff[12][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[12][12]_i_3 
       (.I0(\coeff[0][12]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][12]_i_7_n_0 ),
        .O(\coeff[12][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[12][13]_i_1 
       (.I0(\coeff[12][13]_i_2_n_0 ),
        .I1(\coeff[0][13]_i_3_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][13]_i_3_n_0 ),
        .O(\coeff[12][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[12][13]_i_3 
       (.I0(\coeff[0][13]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[12][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[12][14]_i_1 
       (.I0(\coeff[12][14]_i_2_n_0 ),
        .I1(\coeff[0][14]_i_3_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][14]_i_3_n_0 ),
        .O(\coeff[12][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[12][14]_i_3 
       (.I0(load_data_IBUF[14]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][14]_i_6_n_0 ),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[12][14]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hFFD0)) 
    \coeff[12][15]_i_1 
       (.I0(\coeff[12][15]_i_3_n_0 ),
        .I1(\coeff[12][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_6_n_0 ),
        .I3(\coeff[12][15]_i_5_n_0 ),
        .O(\coeff[12][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55505454)) 
    \coeff[12][15]_i_2 
       (.I0(\coeff[12][15]_i_6_n_0 ),
        .I1(\coeff[0][15]_i_8_n_0 ),
        .I2(\coeff[12][15]_i_4_n_0 ),
        .I3(load_data_IBUF[15]),
        .I4(\coeff[12][15]_i_3_n_0 ),
        .I5(\coeff[12][15]_i_7_n_0 ),
        .O(\coeff[12][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair88" *) 
  LUT4 #(
    .INIT(16'hFFFD)) 
    \coeff[12][15]_i_3 
       (.I0(p_1_in[2]),
        .I1(p_1_in[1]),
        .I2(\j_cnt_reg_n_0_[0] ),
        .I3(\coeff[8][15]_i_8_n_0 ),
        .O(\coeff[12][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair85" *) 
  LUT4 #(
    .INIT(16'h0010)) 
    \coeff[12][15]_i_4 
       (.I0(p_2_out[1]),
        .I1(p_2_out[0]),
        .I2(p_2_out[2]),
        .I3(\coeff[8][15]_i_9_n_0 ),
        .O(\coeff[12][15]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'hF4444444)) 
    \coeff[12][15]_i_5 
       (.I0(\coeff[1][15]_i_7_n_0 ),
        .I1(\coeff[12][15]_i_8_n_0 ),
        .I2(load_addr_IBUF[2]),
        .I3(load_addr_IBUF[3]),
        .I4(\coeff[0][15]_i_11_n_0 ),
        .O(\coeff[12][15]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][15]_i_6 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][15]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[12][15]_i_7 
       (.I0(\coeff[0][15]_i_19_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[12][15]_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair62" *) 
  LUT5 #(
    .INIT(32'h00000008)) 
    \coeff[12][15]_i_8 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\cnt_reg_n_0_[3] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\cnt_reg_n_0_[0] ),
        .I4(\cnt_reg_n_0_[4] ),
        .O(\coeff[12][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[12][1]_i_1 
       (.I0(\coeff[12][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][1]_i_3_n_0 ),
        .O(\coeff[12][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[12][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[12][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[12][2]_i_1 
       (.I0(\coeff[12][2]_i_2_n_0 ),
        .I1(\coeff[0][2]_i_3_n_0 ),
        .I2(load_data_IBUF[2]),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][2]_i_3_n_0 ),
        .O(\coeff[12][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[12][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[12][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[12][3]_i_1 
       (.I0(\coeff[12][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][3]_i_3_n_0 ),
        .O(\coeff[12][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[12][3]_i_3 
       (.I0(\coeff[0][3]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[3]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][3]_i_9_n_0 ),
        .O(\coeff[12][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[12][4]_i_1 
       (.I0(\coeff[12][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][4]_i_3_n_0 ),
        .O(\coeff[12][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[12][4]_i_3 
       (.I0(\coeff[0][4]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[4]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][4]_i_6_n_0 ),
        .O(\coeff[12][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[12][5]_i_1 
       (.I0(\coeff[12][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][5]_i_3_n_0 ),
        .O(\coeff[12][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[12][5]_i_3 
       (.I0(\coeff[0][5]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[5]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][5]_i_7_n_0 ),
        .O(\coeff[12][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[12][6]_i_1 
       (.I0(\coeff[12][6]_i_2_n_0 ),
        .I1(\coeff[0][6]_i_3_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][6]_i_3_n_0 ),
        .O(\coeff[12][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[12][6]_i_3 
       (.I0(\coeff[0][6]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[12][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[12][7]_i_1 
       (.I0(\coeff[12][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][7]_i_3_n_0 ),
        .O(\coeff[12][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[12][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[12][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[12][8]_i_1 
       (.I0(\coeff[12][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][8]_i_3_n_0 ),
        .O(\coeff[12][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[12][8]_i_3 
       (.I0(\coeff[0][8]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[8]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][8]_i_6_n_0 ),
        .O(\coeff[12][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[12][9]_i_1 
       (.I0(\coeff[12][9]_i_2_n_0 ),
        .I1(\coeff[0][9]_i_3_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[12][15]_i_3_n_0 ),
        .I4(\coeff[12][15]_i_4_n_0 ),
        .I5(\coeff[12][9]_i_3_n_0 ),
        .O(\coeff[12][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000100FFFFFFFF)) 
    \coeff[12][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[12][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[12][9]_i_3 
       (.I0(\coeff[0][9]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[12][15]_i_8_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[12][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[13][0]_i_1 
       (.I0(\coeff[13][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][0]_i_3_n_0 ),
        .O(\coeff[13][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[13][0]_i_3 
       (.I0(\coeff[0][0]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[0]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][0]_i_6_n_0 ),
        .O(\coeff[13][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[13][10]_i_1 
       (.I0(\coeff[13][10]_i_2_n_0 ),
        .I1(\coeff[0][10]_i_3_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][10]_i_3_n_0 ),
        .O(\coeff[13][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[13][10]_i_3 
       (.I0(\coeff[0][10]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[13][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[13][11]_i_1 
       (.I0(\coeff[13][11]_i_2_n_0 ),
        .I1(\coeff[0][11]_i_3_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][11]_i_3_n_0 ),
        .O(\coeff[13][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[13][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[13][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[13][12]_i_1 
       (.I0(\coeff[13][12]_i_2_n_0 ),
        .I1(\coeff[0][12]_i_3_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][12]_i_3_n_0 ),
        .O(\coeff[13][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[13][12]_i_3 
       (.I0(\coeff[0][12]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[13][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[13][13]_i_1 
       (.I0(\coeff[13][13]_i_2_n_0 ),
        .I1(\coeff[0][13]_i_3_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][13]_i_3_n_0 ),
        .O(\coeff[13][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[13][13]_i_3 
       (.I0(\coeff[0][13]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[13][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[13][14]_i_1 
       (.I0(\coeff[13][14]_i_2_n_0 ),
        .I1(\coeff[0][14]_i_3_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][14]_i_3_n_0 ),
        .O(\coeff[13][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[13][14]_i_3 
       (.I0(\coeff[0][14]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[13][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hEAEEEAEEFFFFEAEE)) 
    \coeff[13][15]_i_1 
       (.I0(\coeff[13][15]_i_3_n_0 ),
        .I1(\coeff[0][15]_i_6_n_0 ),
        .I2(\coeff[13][15]_i_4_n_0 ),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_6_n_0 ),
        .I5(\coeff[1][15]_i_7_n_0 ),
        .O(\coeff[13][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[13][15]_i_2 
       (.I0(\coeff[13][15]_i_7_n_0 ),
        .I1(\coeff[0][15]_i_8_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][15]_i_8_n_0 ),
        .O(\coeff[13][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair74" *) 
  LUT5 #(
    .INIT(32'h10000000)) 
    \coeff[13][15]_i_3 
       (.I0(load_addr_IBUF[1]),
        .I1(\coeff[1][15]_i_10_n_0 ),
        .I2(load_addr_IBUF[0]),
        .I3(load_addr_IBUF[3]),
        .I4(load_addr_IBUF[2]),
        .O(\coeff[13][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair85" *) 
  LUT4 #(
    .INIT(16'h0040)) 
    \coeff[13][15]_i_4 
       (.I0(p_2_out[1]),
        .I1(p_2_out[0]),
        .I2(p_2_out[2]),
        .I3(\coeff[8][15]_i_9_n_0 ),
        .O(\coeff[13][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair88" *) 
  LUT4 #(
    .INIT(16'hFFDF)) 
    \coeff[13][15]_i_5 
       (.I0(p_1_in[2]),
        .I1(p_1_in[1]),
        .I2(\j_cnt_reg_n_0_[0] ),
        .I3(\coeff[8][15]_i_8_n_0 ),
        .O(\coeff[13][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT5 #(
    .INIT(32'h00000080)) 
    \coeff[13][15]_i_6 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\cnt_reg_n_0_[3] ),
        .I2(\cnt_reg_n_0_[0] ),
        .I3(\cnt_reg_n_0_[1] ),
        .I4(\cnt_reg_n_0_[4] ),
        .O(\coeff[13][15]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[13][15]_i_8 
       (.I0(\coeff[0][15]_i_19_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[13][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[13][1]_i_1 
       (.I0(\coeff[13][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][1]_i_3_n_0 ),
        .O(\coeff[13][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[13][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[13][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[13][2]_i_1 
       (.I0(\coeff[13][2]_i_2_n_0 ),
        .I1(\coeff[0][2]_i_3_n_0 ),
        .I2(load_data_IBUF[2]),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][2]_i_3_n_0 ),
        .O(\coeff[13][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[13][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[13][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[13][3]_i_1 
       (.I0(\coeff[13][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][3]_i_3_n_0 ),
        .O(\coeff[13][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[13][3]_i_3 
       (.I0(\coeff[0][3]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[3]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][3]_i_9_n_0 ),
        .O(\coeff[13][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[13][4]_i_1 
       (.I0(\coeff[13][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][4]_i_3_n_0 ),
        .O(\coeff[13][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[13][4]_i_3 
       (.I0(\coeff[0][4]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[4]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][4]_i_6_n_0 ),
        .O(\coeff[13][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[13][5]_i_1 
       (.I0(\coeff[13][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][5]_i_3_n_0 ),
        .O(\coeff[13][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[13][5]_i_3 
       (.I0(\coeff[0][5]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[5]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][5]_i_7_n_0 ),
        .O(\coeff[13][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[13][6]_i_1 
       (.I0(\coeff[13][6]_i_2_n_0 ),
        .I1(\coeff[0][6]_i_3_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][6]_i_3_n_0 ),
        .O(\coeff[13][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[13][6]_i_3 
       (.I0(\coeff[0][6]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[13][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[13][7]_i_1 
       (.I0(\coeff[13][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][7]_i_3_n_0 ),
        .O(\coeff[13][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[13][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[13][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[13][8]_i_1 
       (.I0(\coeff[13][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][8]_i_3_n_0 ),
        .O(\coeff[13][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[13][8]_i_3 
       (.I0(\coeff[0][8]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[8]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][8]_i_6_n_0 ),
        .O(\coeff[13][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[13][9]_i_1 
       (.I0(\coeff[13][9]_i_2_n_0 ),
        .I1(\coeff[0][9]_i_3_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[13][15]_i_5_n_0 ),
        .I4(\coeff[13][15]_i_4_n_0 ),
        .I5(\coeff[13][9]_i_3_n_0 ),
        .O(\coeff[13][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[13][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[13][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[13][9]_i_3 
       (.I0(\coeff[0][9]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[13][15]_i_6_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[13][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[14][0]_i_1 
       (.I0(\coeff[14][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][0]_i_3_n_0 ),
        .O(\coeff[14][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[14][0]_i_3 
       (.I0(\coeff[0][0]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[0]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][0]_i_6_n_0 ),
        .O(\coeff[14][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[14][10]_i_1 
       (.I0(\coeff[14][10]_i_2_n_0 ),
        .I1(\coeff[0][10]_i_3_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][10]_i_3_n_0 ),
        .O(\coeff[14][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[14][10]_i_3 
       (.I0(\coeff[0][10]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[14][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[14][11]_i_1 
       (.I0(\coeff[14][11]_i_2_n_0 ),
        .I1(\coeff[0][11]_i_3_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][11]_i_3_n_0 ),
        .O(\coeff[14][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[14][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[14][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[14][12]_i_1 
       (.I0(\coeff[14][12]_i_2_n_0 ),
        .I1(\coeff[0][12]_i_3_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][12]_i_3_n_0 ),
        .O(\coeff[14][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[14][12]_i_3 
       (.I0(\coeff[0][12]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[14][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[14][13]_i_1 
       (.I0(\coeff[14][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][13]_i_3_n_0 ),
        .O(\coeff[14][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[14][13]_i_3 
       (.I0(\coeff[0][13]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][13]_i_6_n_0 ),
        .O(\coeff[14][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[14][14]_i_1 
       (.I0(\coeff[14][14]_i_2_n_0 ),
        .I1(\coeff[0][14]_i_3_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][14]_i_3_n_0 ),
        .O(\coeff[14][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[14][14]_i_3 
       (.I0(\coeff[0][14]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[14][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hEAEEEAEEFFFFEAEE)) 
    \coeff[14][15]_i_1 
       (.I0(\coeff[14][15]_i_3_n_0 ),
        .I1(\coeff[0][15]_i_6_n_0 ),
        .I2(\coeff[14][15]_i_4_n_0 ),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_6_n_0 ),
        .I5(\coeff[1][15]_i_7_n_0 ),
        .O(\coeff[14][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55505454)) 
    \coeff[14][15]_i_2 
       (.I0(\coeff[14][15]_i_7_n_0 ),
        .I1(\coeff[0][15]_i_8_n_0 ),
        .I2(\coeff[14][15]_i_4_n_0 ),
        .I3(load_data_IBUF[15]),
        .I4(\coeff[14][15]_i_5_n_0 ),
        .I5(\coeff[14][15]_i_8_n_0 ),
        .O(\coeff[14][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair72" *) 
  LUT5 #(
    .INIT(32'h04000000)) 
    \coeff[14][15]_i_3 
       (.I0(\coeff[1][15]_i_10_n_0 ),
        .I1(load_addr_IBUF[1]),
        .I2(load_addr_IBUF[0]),
        .I3(load_addr_IBUF[3]),
        .I4(load_addr_IBUF[2]),
        .O(\coeff[14][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair86" *) 
  LUT4 #(
    .INIT(16'h0040)) 
    \coeff[14][15]_i_4 
       (.I0(p_2_out[0]),
        .I1(p_2_out[1]),
        .I2(p_2_out[2]),
        .I3(\coeff[8][15]_i_9_n_0 ),
        .O(\coeff[14][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair87" *) 
  LUT4 #(
    .INIT(16'hFFDF)) 
    \coeff[14][15]_i_5 
       (.I0(p_1_in[2]),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(p_1_in[1]),
        .I3(\coeff[8][15]_i_8_n_0 ),
        .O(\coeff[14][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair61" *) 
  LUT5 #(
    .INIT(32'h00000800)) 
    \coeff[14][15]_i_6 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\cnt_reg_n_0_[3] ),
        .I2(\cnt_reg_n_0_[0] ),
        .I3(\cnt_reg_n_0_[1] ),
        .I4(\cnt_reg_n_0_[4] ),
        .O(\coeff[14][15]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[14][15]_i_8 
       (.I0(\coeff[0][15]_i_19_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[14][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[14][1]_i_1 
       (.I0(\coeff[14][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][1]_i_3_n_0 ),
        .O(\coeff[14][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[14][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[14][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[14][2]_i_1 
       (.I0(\coeff[14][2]_i_2_n_0 ),
        .I1(\coeff[0][2]_i_3_n_0 ),
        .I2(load_data_IBUF[2]),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][2]_i_3_n_0 ),
        .O(\coeff[14][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[14][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[14][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[14][3]_i_1 
       (.I0(\coeff[14][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][3]_i_3_n_0 ),
        .O(\coeff[14][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[14][3]_i_3 
       (.I0(\coeff[0][3]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[3]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][3]_i_9_n_0 ),
        .O(\coeff[14][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[14][4]_i_1 
       (.I0(\coeff[14][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][4]_i_3_n_0 ),
        .O(\coeff[14][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[14][4]_i_3 
       (.I0(\coeff[0][4]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[4]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][4]_i_6_n_0 ),
        .O(\coeff[14][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[14][5]_i_1 
       (.I0(\coeff[14][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][5]_i_3_n_0 ),
        .O(\coeff[14][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[14][5]_i_3 
       (.I0(\coeff[0][5]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[5]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][5]_i_7_n_0 ),
        .O(\coeff[14][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[14][6]_i_1 
       (.I0(\coeff[14][6]_i_2_n_0 ),
        .I1(load_data_IBUF[6]),
        .I2(\coeff[0][6]_i_3_n_0 ),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][6]_i_3_n_0 ),
        .O(\coeff[14][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[14][6]_i_3 
       (.I0(\coeff[0][6]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][6]_i_6_n_0 ),
        .O(\coeff[14][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[14][7]_i_1 
       (.I0(\coeff[14][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][7]_i_3_n_0 ),
        .O(\coeff[14][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[14][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[14][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[14][8]_i_1 
       (.I0(\coeff[14][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][8]_i_3_n_0 ),
        .O(\coeff[14][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[14][8]_i_3 
       (.I0(\coeff[0][8]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[8]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][8]_i_6_n_0 ),
        .O(\coeff[14][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[14][9]_i_1 
       (.I0(\coeff[14][9]_i_2_n_0 ),
        .I1(\coeff[0][9]_i_3_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[14][15]_i_5_n_0 ),
        .I4(\coeff[14][15]_i_4_n_0 ),
        .I5(\coeff[14][9]_i_3_n_0 ),
        .O(\coeff[14][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    \coeff[14][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[14][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[14][9]_i_3 
       (.I0(\coeff[0][9]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[14][15]_i_6_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[14][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[15][0]_i_1 
       (.I0(\coeff[15][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][0]_i_3_n_0 ),
        .O(\coeff[15][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[15][0]_i_3 
       (.I0(\coeff[0][0]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[0]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][0]_i_6_n_0 ),
        .O(\coeff[15][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[15][10]_i_1 
       (.I0(\coeff[15][10]_i_2_n_0 ),
        .I1(\coeff[0][10]_i_3_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][10]_i_3_n_0 ),
        .O(\coeff[15][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[15][10]_i_3 
       (.I0(\coeff[0][10]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[15][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[15][11]_i_1 
       (.I0(\coeff[15][11]_i_2_n_0 ),
        .I1(\coeff[0][11]_i_3_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][11]_i_3_n_0 ),
        .O(\coeff[15][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[15][11]_i_3 
       (.I0(\coeff[0][11]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[15][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[15][12]_i_1 
       (.I0(\coeff[15][12]_i_2_n_0 ),
        .I1(\coeff[0][12]_i_3_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][12]_i_3_n_0 ),
        .O(\coeff[15][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[15][12]_i_3 
       (.I0(\coeff[0][12]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[15][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[15][13]_i_1 
       (.I0(\coeff[15][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][13]_i_3_n_0 ),
        .O(\coeff[15][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[15][13]_i_3 
       (.I0(\coeff[0][13]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][13]_i_6_n_0 ),
        .O(\coeff[15][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[15][14]_i_1 
       (.I0(\coeff[15][14]_i_2_n_0 ),
        .I1(\coeff[0][14]_i_3_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][14]_i_3_n_0 ),
        .O(\coeff[15][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[15][14]_i_3 
       (.I0(\coeff[0][14]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[15][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF8A8AFF8A)) 
    \coeff[15][15]_i_1 
       (.I0(\coeff[0][15]_i_6_n_0 ),
        .I1(\coeff[15][15]_i_3_n_0 ),
        .I2(\coeff[15][15]_i_4_n_0 ),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[1][15]_i_7_n_0 ),
        .I5(\coeff[15][15]_i_6_n_0 ),
        .O(\coeff[15][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55505454)) 
    \coeff[15][15]_i_2 
       (.I0(\coeff[15][15]_i_7_n_0 ),
        .I1(\coeff[0][15]_i_8_n_0 ),
        .I2(\coeff[15][15]_i_3_n_0 ),
        .I3(load_data_IBUF[15]),
        .I4(\coeff[15][15]_i_4_n_0 ),
        .I5(\coeff[15][15]_i_8_n_0 ),
        .O(\coeff[15][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair86" *) 
  LUT4 #(
    .INIT(16'h0080)) 
    \coeff[15][15]_i_3 
       (.I0(p_2_out[0]),
        .I1(p_2_out[1]),
        .I2(p_2_out[2]),
        .I3(\coeff[8][15]_i_9_n_0 ),
        .O(\coeff[15][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair87" *) 
  LUT4 #(
    .INIT(16'hFF7F)) 
    \coeff[15][15]_i_4 
       (.I0(p_1_in[2]),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(p_1_in[1]),
        .I3(\coeff[8][15]_i_8_n_0 ),
        .O(\coeff[15][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair181" *) 
  LUT5 #(
    .INIT(32'h08000000)) 
    \coeff[15][15]_i_5 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(\cnt_reg_n_0_[1] ),
        .I2(\cnt_reg_n_0_[4] ),
        .I3(\cnt_reg_n_0_[3] ),
        .I4(\cnt_reg_n_0_[2] ),
        .O(\coeff[15][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair73" *) 
  LUT5 #(
    .INIT(32'h40000000)) 
    \coeff[15][15]_i_6 
       (.I0(\coeff[1][15]_i_10_n_0 ),
        .I1(load_addr_IBUF[1]),
        .I2(load_addr_IBUF[0]),
        .I3(load_addr_IBUF[3]),
        .I4(load_addr_IBUF[2]),
        .O(\coeff[15][15]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[15][15]_i_8 
       (.I0(\coeff[0][15]_i_19_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[15][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[15][1]_i_1 
       (.I0(\coeff[15][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][1]_i_3_n_0 ),
        .O(\coeff[15][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[15][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[15][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[15][2]_i_1 
       (.I0(\coeff[15][2]_i_2_n_0 ),
        .I1(\coeff[0][2]_i_3_n_0 ),
        .I2(load_data_IBUF[2]),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][2]_i_3_n_0 ),
        .O(\coeff[15][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[15][2]_i_3 
       (.I0(\coeff[0][2]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[2]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[15][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[15][3]_i_1 
       (.I0(\coeff[15][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][3]_i_3_n_0 ),
        .O(\coeff[15][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[15][3]_i_3 
       (.I0(\coeff[0][3]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[3]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][3]_i_9_n_0 ),
        .O(\coeff[15][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[15][4]_i_1 
       (.I0(\coeff[15][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][4]_i_3_n_0 ),
        .O(\coeff[15][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[15][4]_i_3 
       (.I0(\coeff[0][4]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[4]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][4]_i_6_n_0 ),
        .O(\coeff[15][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[15][5]_i_1 
       (.I0(\coeff[15][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][5]_i_3_n_0 ),
        .O(\coeff[15][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[15][5]_i_3 
       (.I0(\coeff[0][5]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[5]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][5]_i_7_n_0 ),
        .O(\coeff[15][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[15][6]_i_1 
       (.I0(\coeff[15][6]_i_2_n_0 ),
        .I1(\coeff[0][6]_i_3_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][6]_i_3_n_0 ),
        .O(\coeff[15][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[15][6]_i_3 
       (.I0(\coeff[0][6]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[15][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[15][7]_i_1 
       (.I0(\coeff[15][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][7]_i_3_n_0 ),
        .O(\coeff[15][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[15][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[15][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[15][8]_i_1 
       (.I0(\coeff[15][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][8]_i_3_n_0 ),
        .O(\coeff[15][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[15][8]_i_3 
       (.I0(\coeff[0][8]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[8]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][8]_i_6_n_0 ),
        .O(\coeff[15][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[15][9]_i_1 
       (.I0(\coeff[15][9]_i_2_n_0 ),
        .I1(\coeff[0][9]_i_3_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[15][15]_i_4_n_0 ),
        .I4(\coeff[15][15]_i_3_n_0 ),
        .I5(\coeff[15][9]_i_3_n_0 ),
        .O(\coeff[15][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[15][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[15][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[15][9]_i_3 
       (.I0(\coeff[0][9]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[15][15]_i_5_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[15][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][0]_i_1 
       (.I0(\coeff[1][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][0]_i_3_n_0 ),
        .O(\coeff[1][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][0]_i_3 
       (.I0(load_data_IBUF[0]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][0]_i_6_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][0]_i_7_n_0 ),
        .O(\coeff[1][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][10]_i_1 
       (.I0(\coeff[1][10]_i_2_n_0 ),
        .I1(load_data_IBUF[10]),
        .I2(\coeff[0][10]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][10]_i_3_n_0 ),
        .O(\coeff[1][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][10]_i_3 
       (.I0(load_data_IBUF[10]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][10]_i_6_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[1][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][11]_i_1 
       (.I0(\coeff[1][11]_i_2_n_0 ),
        .I1(load_data_IBUF[11]),
        .I2(\coeff[0][11]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][11]_i_3_n_0 ),
        .O(\coeff[1][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[1][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][12]_i_1 
       (.I0(\coeff[1][12]_i_2_n_0 ),
        .I1(load_data_IBUF[12]),
        .I2(\coeff[0][12]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][12]_i_3_n_0 ),
        .O(\coeff[1][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][12]_i_3 
       (.I0(load_data_IBUF[12]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][12]_i_7_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[1][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][13]_i_1 
       (.I0(\coeff[1][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][13]_i_3_n_0 ),
        .O(\coeff[1][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][13]_i_3 
       (.I0(load_data_IBUF[13]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][13]_i_6_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[1][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][14]_i_1 
       (.I0(\coeff[1][14]_i_2_n_0 ),
        .I1(load_data_IBUF[14]),
        .I2(\coeff[0][14]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][14]_i_3_n_0 ),
        .O(\coeff[1][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][14]_i_3 
       (.I0(load_data_IBUF[14]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][14]_i_6_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[1][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFD0FFD0FFFFFFD0)) 
    \coeff[1][15]_i_1 
       (.I0(\coeff[1][15]_i_3_n_0 ),
        .I1(\coeff[1][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_6_n_0 ),
        .I3(\coeff[1][15]_i_5_n_0 ),
        .I4(\coeff[1][15]_i_6_n_0 ),
        .I5(\coeff[1][15]_i_7_n_0 ),
        .O(\coeff[1][15]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFFFFD)) 
    \coeff[1][15]_i_10 
       (.I0(load_IBUF),
        .I1(load_addr_IBUF[5]),
        .I2(load_addr_IBUF[7]),
        .I3(load_addr_IBUF[6]),
        .I4(load_addr_IBUF[4]),
        .O(\coeff[1][15]_i_10_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][15]_i_2 
       (.I0(\coeff[1][15]_i_8_n_0 ),
        .I1(load_data_IBUF[15]),
        .I2(\coeff[0][15]_i_8_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][15]_i_9_n_0 ),
        .O(\coeff[1][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair189" *) 
  LUT4 #(
    .INIT(16'hFFEF)) 
    \coeff[1][15]_i_3 
       (.I0(\coeff[0][15]_i_12_n_0 ),
        .I1(p_1_in[1]),
        .I2(\j_cnt_reg_n_0_[0] ),
        .I3(p_1_in[2]),
        .O(\coeff[1][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair79" *) 
  LUT4 #(
    .INIT(16'h0400)) 
    \coeff[1][15]_i_4 
       (.I0(p_2_out[1]),
        .I1(p_2_out[0]),
        .I2(p_2_out[2]),
        .I3(\coeff[0][15]_i_15_n_0 ),
        .O(\coeff[1][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT5 #(
    .INIT(32'h00000100)) 
    \coeff[1][15]_i_5 
       (.I0(\coeff[1][15]_i_10_n_0 ),
        .I1(load_addr_IBUF[2]),
        .I2(load_addr_IBUF[3]),
        .I3(load_addr_IBUF[0]),
        .I4(load_addr_IBUF[1]),
        .O(\coeff[1][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT5 #(
    .INIT(32'h00000002)) 
    \coeff[1][15]_i_6 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(\cnt_reg_n_0_[1] ),
        .I2(\cnt_reg_n_0_[4] ),
        .I3(\cnt_reg_n_0_[3] ),
        .I4(\cnt_reg_n_0_[2] ),
        .O(\coeff[1][15]_i_6_n_0 ));
  LUT3 #(
    .INIT(8'hD7)) 
    \coeff[1][15]_i_7 
       (.I0(state[2]),
        .I1(state[0]),
        .I2(state[1]),
        .O(\coeff[1][15]_i_7_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][15]_i_8 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][15]_i_8_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][15]_i_9 
       (.I0(load_data_IBUF[15]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][15]_i_19_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[1][15]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][1]_i_1 
       (.I0(\coeff[1][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][1]_i_3_n_0 ),
        .O(\coeff[1][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[1][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[1][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][2]_i_1 
       (.I0(\coeff[1][2]_i_2_n_0 ),
        .I1(load_data_IBUF[2]),
        .I2(\coeff[0][2]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][2]_i_3_n_0 ),
        .O(\coeff[1][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[1][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][3]_i_1 
       (.I0(\coeff[1][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][3]_i_3_n_0 ),
        .O(\coeff[1][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][3]_i_3 
       (.I0(load_data_IBUF[3]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][3]_i_9_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][3]_i_8_n_0 ),
        .O(\coeff[1][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][4]_i_1 
       (.I0(\coeff[1][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][4]_i_3_n_0 ),
        .O(\coeff[1][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][4]_i_3 
       (.I0(load_data_IBUF[4]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][4]_i_6_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][4]_i_7_n_0 ),
        .O(\coeff[1][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][5]_i_1 
       (.I0(\coeff[1][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][5]_i_3_n_0 ),
        .O(\coeff[1][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][5]_i_3 
       (.I0(load_data_IBUF[5]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][5]_i_7_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][5]_i_6_n_0 ),
        .O(\coeff[1][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][6]_i_1 
       (.I0(\coeff[1][6]_i_2_n_0 ),
        .I1(load_data_IBUF[6]),
        .I2(\coeff[0][6]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][6]_i_3_n_0 ),
        .O(\coeff[1][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][6]_i_3 
       (.I0(load_data_IBUF[6]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][6]_i_6_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[1][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][7]_i_1 
       (.I0(\coeff[1][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][7]_i_3_n_0 ),
        .O(\coeff[1][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[1][7]_i_3 
       (.I0(\coeff[0][7]_i_9_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][7]_i_8_n_0 ),
        .O(\coeff[1][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][8]_i_1 
       (.I0(\coeff[1][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][8]_i_3_n_0 ),
        .O(\coeff[1][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][8]_i_3 
       (.I0(load_data_IBUF[8]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][8]_i_6_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][8]_i_7_n_0 ),
        .O(\coeff[1][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[1][9]_i_1 
       (.I0(\coeff[1][9]_i_2_n_0 ),
        .I1(load_data_IBUF[9]),
        .I2(\coeff[0][9]_i_3_n_0 ),
        .I3(\coeff[1][15]_i_3_n_0 ),
        .I4(\coeff[1][15]_i_4_n_0 ),
        .I5(\coeff[1][9]_i_3_n_0 ),
        .O(\coeff[1][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[1][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[1][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[1][9]_i_3 
       (.I0(load_data_IBUF[9]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][9]_i_6_n_0 ),
        .I3(\coeff[1][15]_i_6_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[1][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][0]_i_1 
       (.I0(\coeff[2][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][0]_i_3_n_0 ),
        .O(\coeff[2][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][0]_i_3 
       (.I0(load_data_IBUF[0]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][0]_i_6_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][0]_i_7_n_0 ),
        .O(\coeff[2][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][10]_i_1 
       (.I0(\coeff[2][10]_i_2_n_0 ),
        .I1(load_data_IBUF[10]),
        .I2(\coeff[0][10]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][10]_i_3_n_0 ),
        .O(\coeff[2][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][10]_i_3 
       (.I0(load_data_IBUF[10]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][10]_i_6_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[2][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][11]_i_1 
       (.I0(\coeff[2][11]_i_2_n_0 ),
        .I1(load_data_IBUF[11]),
        .I2(\coeff[0][11]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][11]_i_3_n_0 ),
        .O(\coeff[2][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[2][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][12]_i_1 
       (.I0(\coeff[2][12]_i_2_n_0 ),
        .I1(load_data_IBUF[12]),
        .I2(\coeff[0][12]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][12]_i_3_n_0 ),
        .O(\coeff[2][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][12]_i_3 
       (.I0(load_data_IBUF[12]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][12]_i_7_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[2][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][13]_i_1 
       (.I0(\coeff[2][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][13]_i_3_n_0 ),
        .O(\coeff[2][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][13]_i_3 
       (.I0(load_data_IBUF[13]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][13]_i_6_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[2][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][14]_i_1 
       (.I0(\coeff[2][14]_i_2_n_0 ),
        .I1(load_data_IBUF[14]),
        .I2(\coeff[0][14]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][14]_i_3_n_0 ),
        .O(\coeff[2][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][14]_i_3 
       (.I0(load_data_IBUF[14]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][14]_i_6_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[2][14]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hFFD0)) 
    \coeff[2][15]_i_1 
       (.I0(\coeff[2][15]_i_3_n_0 ),
        .I1(\coeff[2][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_6_n_0 ),
        .I3(\coeff[2][15]_i_5_n_0 ),
        .O(\coeff[2][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][15]_i_2 
       (.I0(\coeff[2][15]_i_6_n_0 ),
        .I1(load_data_IBUF[15]),
        .I2(\coeff[0][15]_i_8_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][15]_i_7_n_0 ),
        .O(\coeff[2][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair92" *) 
  LUT4 #(
    .INIT(16'hFFEF)) 
    \coeff[2][15]_i_3 
       (.I0(\coeff[0][15]_i_12_n_0 ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(p_1_in[1]),
        .I3(p_1_in[2]),
        .O(\coeff[2][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair80" *) 
  LUT4 #(
    .INIT(16'h0020)) 
    \coeff[2][15]_i_4 
       (.I0(\coeff[0][15]_i_15_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .O(\coeff[2][15]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'h444F4444)) 
    \coeff[2][15]_i_5 
       (.I0(\coeff[1][15]_i_7_n_0 ),
        .I1(\coeff[2][15]_i_8_n_0 ),
        .I2(load_addr_IBUF[2]),
        .I3(load_addr_IBUF[3]),
        .I4(\coeff[2][15]_i_9_n_0 ),
        .O(\coeff[2][15]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][15]_i_6 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][15]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][15]_i_7 
       (.I0(load_data_IBUF[15]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][15]_i_19_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[2][15]_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair183" *) 
  LUT5 #(
    .INIT(32'h00000002)) 
    \coeff[2][15]_i_8 
       (.I0(\cnt_reg_n_0_[1] ),
        .I1(\cnt_reg_n_0_[0] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[4] ),
        .I4(\cnt_reg_n_0_[3] ),
        .O(\coeff[2][15]_i_8_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair185" *) 
  LUT3 #(
    .INIT(8'h02)) 
    \coeff[2][15]_i_9 
       (.I0(load_addr_IBUF[1]),
        .I1(\coeff[1][15]_i_10_n_0 ),
        .I2(load_addr_IBUF[0]),
        .O(\coeff[2][15]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][1]_i_1 
       (.I0(\coeff[2][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][1]_i_3_n_0 ),
        .O(\coeff[2][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][1]_i_3 
       (.I0(load_data_IBUF[1]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][1]_i_7_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][1]_i_6_n_0 ),
        .O(\coeff[2][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][2]_i_1 
       (.I0(\coeff[2][2]_i_2_n_0 ),
        .I1(load_data_IBUF[2]),
        .I2(\coeff[0][2]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][2]_i_3_n_0 ),
        .O(\coeff[2][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[2][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][3]_i_1 
       (.I0(\coeff[2][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][3]_i_3_n_0 ),
        .O(\coeff[2][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][3]_i_3 
       (.I0(load_data_IBUF[3]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][3]_i_9_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][3]_i_8_n_0 ),
        .O(\coeff[2][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][4]_i_1 
       (.I0(\coeff[2][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][4]_i_3_n_0 ),
        .O(\coeff[2][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][4]_i_3 
       (.I0(load_data_IBUF[4]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][4]_i_6_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][4]_i_7_n_0 ),
        .O(\coeff[2][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][5]_i_1 
       (.I0(\coeff[2][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][5]_i_3_n_0 ),
        .O(\coeff[2][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][5]_i_3 
       (.I0(load_data_IBUF[5]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][5]_i_7_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][5]_i_6_n_0 ),
        .O(\coeff[2][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][6]_i_1 
       (.I0(\coeff[2][6]_i_2_n_0 ),
        .I1(load_data_IBUF[6]),
        .I2(\coeff[0][6]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][6]_i_3_n_0 ),
        .O(\coeff[2][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][6]_i_3 
       (.I0(load_data_IBUF[6]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][6]_i_6_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[2][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][7]_i_1 
       (.I0(\coeff[2][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][7]_i_3_n_0 ),
        .O(\coeff[2][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][7]_i_3 
       (.I0(load_data_IBUF[7]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][7]_i_9_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][7]_i_8_n_0 ),
        .O(\coeff[2][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][8]_i_1 
       (.I0(\coeff[2][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][8]_i_3_n_0 ),
        .O(\coeff[2][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][8]_i_3 
       (.I0(load_data_IBUF[8]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][8]_i_6_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][8]_i_7_n_0 ),
        .O(\coeff[2][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[2][9]_i_1 
       (.I0(\coeff[2][9]_i_2_n_0 ),
        .I1(load_data_IBUF[9]),
        .I2(\coeff[0][9]_i_3_n_0 ),
        .I3(\coeff[2][15]_i_3_n_0 ),
        .I4(\coeff[2][15]_i_4_n_0 ),
        .I5(\coeff[2][9]_i_3_n_0 ),
        .O(\coeff[2][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000400FFFFFFFF)) 
    \coeff[2][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[2][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[2][9]_i_3 
       (.I0(load_data_IBUF[9]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][9]_i_6_n_0 ),
        .I3(\coeff[2][15]_i_8_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[2][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][0]_i_1 
       (.I0(\coeff[3][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][0]_i_3_n_0 ),
        .O(\coeff[3][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][0]_i_3 
       (.I0(load_data_IBUF[0]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][0]_i_6_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][0]_i_7_n_0 ),
        .O(\coeff[3][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][10]_i_1 
       (.I0(\coeff[3][10]_i_2_n_0 ),
        .I1(load_data_IBUF[10]),
        .I2(\coeff[0][10]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][10]_i_3_n_0 ),
        .O(\coeff[3][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][10]_i_3 
       (.I0(load_data_IBUF[10]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][10]_i_6_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[3][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][11]_i_1 
       (.I0(\coeff[3][11]_i_2_n_0 ),
        .I1(load_data_IBUF[11]),
        .I2(\coeff[0][11]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][11]_i_3_n_0 ),
        .O(\coeff[3][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[3][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][12]_i_1 
       (.I0(\coeff[3][12]_i_2_n_0 ),
        .I1(load_data_IBUF[12]),
        .I2(\coeff[0][12]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][12]_i_3_n_0 ),
        .O(\coeff[3][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][12]_i_3 
       (.I0(load_data_IBUF[12]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][12]_i_7_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[3][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][13]_i_1 
       (.I0(\coeff[3][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][13]_i_3_n_0 ),
        .O(\coeff[3][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][13]_i_3 
       (.I0(load_data_IBUF[13]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][13]_i_6_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[3][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][14]_i_1 
       (.I0(\coeff[3][14]_i_2_n_0 ),
        .I1(load_data_IBUF[14]),
        .I2(\coeff[0][14]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][14]_i_3_n_0 ),
        .O(\coeff[3][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][14]_i_3 
       (.I0(load_data_IBUF[14]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][14]_i_6_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[3][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFD0FFD0FFFFFFD0)) 
    \coeff[3][15]_i_1 
       (.I0(\coeff[3][15]_i_3_n_0 ),
        .I1(\coeff[3][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_6_n_0 ),
        .I3(\coeff[3][15]_i_5_n_0 ),
        .I4(\coeff[3][15]_i_6_n_0 ),
        .I5(\coeff[1][15]_i_7_n_0 ),
        .O(\coeff[3][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][15]_i_2 
       (.I0(\coeff[3][15]_i_7_n_0 ),
        .I1(load_data_IBUF[15]),
        .I2(\coeff[0][15]_i_8_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][15]_i_8_n_0 ),
        .O(\coeff[3][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair92" *) 
  LUT4 #(
    .INIT(16'hFFBF)) 
    \coeff[3][15]_i_3 
       (.I0(\coeff[0][15]_i_12_n_0 ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(p_1_in[1]),
        .I3(p_1_in[2]),
        .O(\coeff[3][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair80" *) 
  LUT4 #(
    .INIT(16'h0080)) 
    \coeff[3][15]_i_4 
       (.I0(\coeff[0][15]_i_15_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .O(\coeff[3][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair71" *) 
  LUT5 #(
    .INIT(32'h01000000)) 
    \coeff[3][15]_i_5 
       (.I0(\coeff[1][15]_i_10_n_0 ),
        .I1(load_addr_IBUF[2]),
        .I2(load_addr_IBUF[3]),
        .I3(load_addr_IBUF[0]),
        .I4(load_addr_IBUF[1]),
        .O(\coeff[3][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair69" *) 
  LUT5 #(
    .INIT(32'h00000008)) 
    \coeff[3][15]_i_6 
       (.I0(\cnt_reg_n_0_[0] ),
        .I1(\cnt_reg_n_0_[1] ),
        .I2(\cnt_reg_n_0_[4] ),
        .I3(\cnt_reg_n_0_[3] ),
        .I4(\cnt_reg_n_0_[2] ),
        .O(\coeff[3][15]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][15]_i_8 
       (.I0(load_data_IBUF[15]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][15]_i_19_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[3][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][1]_i_1 
       (.I0(\coeff[3][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][1]_i_3_n_0 ),
        .O(\coeff[3][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[3][1]_i_3 
       (.I0(\coeff[0][1]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][1]_i_6_n_0 ),
        .O(\coeff[3][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][2]_i_1 
       (.I0(\coeff[3][2]_i_2_n_0 ),
        .I1(load_data_IBUF[2]),
        .I2(\coeff[0][2]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][2]_i_3_n_0 ),
        .O(\coeff[3][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[3][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][3]_i_1 
       (.I0(\coeff[3][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][3]_i_3_n_0 ),
        .O(\coeff[3][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][3]_i_3 
       (.I0(load_data_IBUF[3]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][3]_i_9_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][3]_i_8_n_0 ),
        .O(\coeff[3][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][4]_i_1 
       (.I0(\coeff[3][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][4]_i_3_n_0 ),
        .O(\coeff[3][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][4]_i_3 
       (.I0(load_data_IBUF[4]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][4]_i_6_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][4]_i_7_n_0 ),
        .O(\coeff[3][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][5]_i_1 
       (.I0(\coeff[3][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][5]_i_3_n_0 ),
        .O(\coeff[3][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][5]_i_3 
       (.I0(load_data_IBUF[5]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][5]_i_7_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][5]_i_6_n_0 ),
        .O(\coeff[3][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][6]_i_1 
       (.I0(\coeff[3][6]_i_2_n_0 ),
        .I1(load_data_IBUF[6]),
        .I2(\coeff[0][6]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][6]_i_3_n_0 ),
        .O(\coeff[3][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][6]_i_3 
       (.I0(load_data_IBUF[6]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][6]_i_6_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[3][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][7]_i_1 
       (.I0(\coeff[3][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][7]_i_3_n_0 ),
        .O(\coeff[3][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][7]_i_3 
       (.I0(load_data_IBUF[7]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][7]_i_9_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][7]_i_8_n_0 ),
        .O(\coeff[3][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][8]_i_1 
       (.I0(\coeff[3][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][8]_i_3_n_0 ),
        .O(\coeff[3][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][8]_i_3 
       (.I0(load_data_IBUF[8]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][8]_i_6_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][8]_i_7_n_0 ),
        .O(\coeff[3][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[3][9]_i_1 
       (.I0(\coeff[3][9]_i_2_n_0 ),
        .I1(load_data_IBUF[9]),
        .I2(\coeff[0][9]_i_3_n_0 ),
        .I3(\coeff[3][15]_i_3_n_0 ),
        .I4(\coeff[3][15]_i_4_n_0 ),
        .I5(\coeff[3][9]_i_3_n_0 ),
        .O(\coeff[3][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00004000FFFFFFFF)) 
    \coeff[3][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[3][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[3][9]_i_3 
       (.I0(load_data_IBUF[9]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][9]_i_6_n_0 ),
        .I3(\coeff[3][15]_i_6_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[3][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][0]_i_1 
       (.I0(\coeff[4][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][0]_i_3_n_0 ),
        .O(\coeff[4][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][0]_i_3 
       (.I0(load_data_IBUF[0]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][0]_i_6_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][0]_i_7_n_0 ),
        .O(\coeff[4][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][10]_i_1 
       (.I0(\coeff[4][10]_i_2_n_0 ),
        .I1(load_data_IBUF[10]),
        .I2(\coeff[0][10]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][10]_i_3_n_0 ),
        .O(\coeff[4][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][10]_i_3 
       (.I0(load_data_IBUF[10]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][10]_i_6_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[4][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][11]_i_1 
       (.I0(\coeff[4][11]_i_2_n_0 ),
        .I1(load_data_IBUF[11]),
        .I2(\coeff[0][11]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][11]_i_3_n_0 ),
        .O(\coeff[4][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[4][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][12]_i_1 
       (.I0(\coeff[4][12]_i_2_n_0 ),
        .I1(load_data_IBUF[12]),
        .I2(\coeff[0][12]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][12]_i_3_n_0 ),
        .O(\coeff[4][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][12]_i_3 
       (.I0(load_data_IBUF[12]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][12]_i_7_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[4][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][13]_i_1 
       (.I0(\coeff[4][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][13]_i_3_n_0 ),
        .O(\coeff[4][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][13]_i_3 
       (.I0(load_data_IBUF[13]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][13]_i_6_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[4][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][14]_i_1 
       (.I0(\coeff[4][14]_i_2_n_0 ),
        .I1(load_data_IBUF[14]),
        .I2(\coeff[0][14]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][14]_i_3_n_0 ),
        .O(\coeff[4][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][14]_i_3 
       (.I0(load_data_IBUF[14]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][14]_i_6_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[4][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hEAEEEAEEFFFFEAEE)) 
    \coeff[4][15]_i_1 
       (.I0(\coeff[4][15]_i_3_n_0 ),
        .I1(\coeff[0][15]_i_6_n_0 ),
        .I2(\coeff[4][15]_i_4_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_6_n_0 ),
        .I5(\coeff[1][15]_i_7_n_0 ),
        .O(\coeff[4][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][15]_i_2 
       (.I0(\coeff[4][15]_i_7_n_0 ),
        .I1(load_data_IBUF[15]),
        .I2(\coeff[0][15]_i_8_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][15]_i_8_n_0 ),
        .O(\coeff[4][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair184" *) 
  LUT5 #(
    .INIT(32'h00010000)) 
    \coeff[4][15]_i_3 
       (.I0(\coeff[1][15]_i_10_n_0 ),
        .I1(load_addr_IBUF[1]),
        .I2(load_addr_IBUF[0]),
        .I3(load_addr_IBUF[3]),
        .I4(load_addr_IBUF[2]),
        .O(\coeff[4][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair81" *) 
  LUT4 #(
    .INIT(16'h0200)) 
    \coeff[4][15]_i_4 
       (.I0(\coeff[0][15]_i_15_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .O(\coeff[4][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair91" *) 
  LUT4 #(
    .INIT(16'hFFFB)) 
    \coeff[4][15]_i_5 
       (.I0(\coeff[0][15]_i_12_n_0 ),
        .I1(p_1_in[2]),
        .I2(p_1_in[1]),
        .I3(\j_cnt_reg_n_0_[0] ),
        .O(\coeff[4][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT5 #(
    .INIT(32'h00000002)) 
    \coeff[4][15]_i_6 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\cnt_reg_n_0_[3] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\cnt_reg_n_0_[0] ),
        .I4(\cnt_reg_n_0_[4] ),
        .O(\coeff[4][15]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][15]_i_8 
       (.I0(load_data_IBUF[15]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][15]_i_19_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[4][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][1]_i_1 
       (.I0(\coeff[4][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][1]_i_3_n_0 ),
        .O(\coeff[4][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][1]_i_3 
       (.I0(load_data_IBUF[1]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][1]_i_7_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][1]_i_6_n_0 ),
        .O(\coeff[4][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][2]_i_1 
       (.I0(\coeff[4][2]_i_2_n_0 ),
        .I1(load_data_IBUF[2]),
        .I2(\coeff[0][2]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][2]_i_3_n_0 ),
        .O(\coeff[4][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[4][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][3]_i_1 
       (.I0(\coeff[4][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][3]_i_3_n_0 ),
        .O(\coeff[4][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][3]_i_3 
       (.I0(load_data_IBUF[3]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][3]_i_9_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][3]_i_8_n_0 ),
        .O(\coeff[4][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][4]_i_1 
       (.I0(\coeff[4][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][4]_i_3_n_0 ),
        .O(\coeff[4][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][4]_i_3 
       (.I0(load_data_IBUF[4]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][4]_i_6_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][4]_i_7_n_0 ),
        .O(\coeff[4][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][5]_i_1 
       (.I0(\coeff[4][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][5]_i_3_n_0 ),
        .O(\coeff[4][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][5]_i_3 
       (.I0(load_data_IBUF[5]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][5]_i_7_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][5]_i_6_n_0 ),
        .O(\coeff[4][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][6]_i_1 
       (.I0(\coeff[4][6]_i_2_n_0 ),
        .I1(load_data_IBUF[6]),
        .I2(\coeff[0][6]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][6]_i_3_n_0 ),
        .O(\coeff[4][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][6]_i_3 
       (.I0(load_data_IBUF[6]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][6]_i_6_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[4][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][7]_i_1 
       (.I0(\coeff[4][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][7]_i_3_n_0 ),
        .O(\coeff[4][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[4][7]_i_3 
       (.I0(\coeff[0][7]_i_9_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][7]_i_8_n_0 ),
        .O(\coeff[4][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][8]_i_1 
       (.I0(\coeff[4][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][8]_i_3_n_0 ),
        .O(\coeff[4][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][8]_i_3 
       (.I0(load_data_IBUF[8]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][8]_i_6_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][8]_i_7_n_0 ),
        .O(\coeff[4][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[4][9]_i_1 
       (.I0(\coeff[4][9]_i_2_n_0 ),
        .I1(load_data_IBUF[9]),
        .I2(\coeff[0][9]_i_3_n_0 ),
        .I3(\coeff[4][15]_i_5_n_0 ),
        .I4(\coeff[4][15]_i_4_n_0 ),
        .I5(\coeff[4][9]_i_3_n_0 ),
        .O(\coeff[4][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00040000FFFFFFFF)) 
    \coeff[4][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[4][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[4][9]_i_3 
       (.I0(load_data_IBUF[9]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][9]_i_6_n_0 ),
        .I3(\coeff[4][15]_i_6_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[4][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][0]_i_1 
       (.I0(\coeff[5][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][0]_i_3_n_0 ),
        .O(\coeff[5][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][0]_i_3 
       (.I0(load_data_IBUF[0]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][0]_i_6_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][0]_i_7_n_0 ),
        .O(\coeff[5][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][10]_i_1 
       (.I0(\coeff[5][10]_i_2_n_0 ),
        .I1(load_data_IBUF[10]),
        .I2(\coeff[0][10]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][10]_i_3_n_0 ),
        .O(\coeff[5][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][10]_i_3 
       (.I0(load_data_IBUF[10]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][10]_i_6_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[5][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][11]_i_1 
       (.I0(\coeff[5][11]_i_2_n_0 ),
        .I1(load_data_IBUF[11]),
        .I2(\coeff[0][11]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][11]_i_3_n_0 ),
        .O(\coeff[5][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[5][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][12]_i_1 
       (.I0(\coeff[5][12]_i_2_n_0 ),
        .I1(load_data_IBUF[12]),
        .I2(\coeff[0][12]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][12]_i_3_n_0 ),
        .O(\coeff[5][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][12]_i_3 
       (.I0(load_data_IBUF[12]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][12]_i_7_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[5][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][13]_i_1 
       (.I0(\coeff[5][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][13]_i_3_n_0 ),
        .O(\coeff[5][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][13]_i_3 
       (.I0(load_data_IBUF[13]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][13]_i_6_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[5][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][14]_i_1 
       (.I0(\coeff[5][14]_i_2_n_0 ),
        .I1(load_data_IBUF[14]),
        .I2(\coeff[0][14]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][14]_i_3_n_0 ),
        .O(\coeff[5][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][14]_i_3 
       (.I0(load_data_IBUF[14]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][14]_i_6_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[5][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFD0FFD0FFFFFFD0)) 
    \coeff[5][15]_i_1 
       (.I0(\coeff[5][15]_i_3_n_0 ),
        .I1(\coeff[5][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_6_n_0 ),
        .I3(\coeff[5][15]_i_5_n_0 ),
        .I4(\coeff[5][15]_i_6_n_0 ),
        .I5(\coeff[1][15]_i_7_n_0 ),
        .O(\coeff[5][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][15]_i_2 
       (.I0(\coeff[5][15]_i_7_n_0 ),
        .I1(load_data_IBUF[15]),
        .I2(\coeff[0][15]_i_8_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][15]_i_8_n_0 ),
        .O(\coeff[5][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair91" *) 
  LUT4 #(
    .INIT(16'hFBFF)) 
    \coeff[5][15]_i_3 
       (.I0(\coeff[0][15]_i_12_n_0 ),
        .I1(p_1_in[2]),
        .I2(p_1_in[1]),
        .I3(\j_cnt_reg_n_0_[0] ),
        .O(\coeff[5][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair81" *) 
  LUT4 #(
    .INIT(16'h2000)) 
    \coeff[5][15]_i_4 
       (.I0(\coeff[0][15]_i_15_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .O(\coeff[5][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair185" *) 
  LUT5 #(
    .INIT(32'h00100000)) 
    \coeff[5][15]_i_5 
       (.I0(load_addr_IBUF[1]),
        .I1(\coeff[1][15]_i_10_n_0 ),
        .I2(load_addr_IBUF[0]),
        .I3(load_addr_IBUF[3]),
        .I4(load_addr_IBUF[2]),
        .O(\coeff[5][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT5 #(
    .INIT(32'h00000040)) 
    \coeff[5][15]_i_6 
       (.I0(\cnt_reg_n_0_[1] ),
        .I1(\cnt_reg_n_0_[0] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[4] ),
        .I4(\cnt_reg_n_0_[3] ),
        .O(\coeff[5][15]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][15]_i_8 
       (.I0(load_data_IBUF[15]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][15]_i_19_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[5][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][1]_i_1 
       (.I0(\coeff[5][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][1]_i_3_n_0 ),
        .O(\coeff[5][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[5][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[5][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][2]_i_1 
       (.I0(\coeff[5][2]_i_2_n_0 ),
        .I1(load_data_IBUF[2]),
        .I2(\coeff[0][2]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][2]_i_3_n_0 ),
        .O(\coeff[5][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[5][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][3]_i_1 
       (.I0(\coeff[5][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][3]_i_3_n_0 ),
        .O(\coeff[5][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][3]_i_3 
       (.I0(load_data_IBUF[3]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][3]_i_9_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][3]_i_8_n_0 ),
        .O(\coeff[5][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][4]_i_1 
       (.I0(\coeff[5][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][4]_i_3_n_0 ),
        .O(\coeff[5][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][4]_i_3 
       (.I0(load_data_IBUF[4]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][4]_i_6_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][4]_i_7_n_0 ),
        .O(\coeff[5][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][5]_i_1 
       (.I0(\coeff[5][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][5]_i_3_n_0 ),
        .O(\coeff[5][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][5]_i_3 
       (.I0(load_data_IBUF[5]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][5]_i_7_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][5]_i_6_n_0 ),
        .O(\coeff[5][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][6]_i_1 
       (.I0(\coeff[5][6]_i_2_n_0 ),
        .I1(load_data_IBUF[6]),
        .I2(\coeff[0][6]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][6]_i_3_n_0 ),
        .O(\coeff[5][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][6]_i_3 
       (.I0(load_data_IBUF[6]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][6]_i_6_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[5][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][7]_i_1 
       (.I0(\coeff[5][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][7]_i_3_n_0 ),
        .O(\coeff[5][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[5][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[5][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][8]_i_1 
       (.I0(\coeff[5][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][8]_i_3_n_0 ),
        .O(\coeff[5][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][8]_i_3 
       (.I0(load_data_IBUF[8]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][8]_i_6_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][8]_i_7_n_0 ),
        .O(\coeff[5][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[5][9]_i_1 
       (.I0(\coeff[5][9]_i_2_n_0 ),
        .I1(load_data_IBUF[9]),
        .I2(\coeff[0][9]_i_3_n_0 ),
        .I3(\coeff[5][15]_i_3_n_0 ),
        .I4(\coeff[5][15]_i_4_n_0 ),
        .I5(\coeff[5][9]_i_3_n_0 ),
        .O(\coeff[5][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[5][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[5][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[5][9]_i_3 
       (.I0(load_data_IBUF[9]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][9]_i_6_n_0 ),
        .I3(\coeff[5][15]_i_6_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[5][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][0]_i_1 
       (.I0(\coeff[6][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][0]_i_3_n_0 ),
        .O(\coeff[6][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][0]_i_3 
       (.I0(load_data_IBUF[0]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][0]_i_6_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][0]_i_7_n_0 ),
        .O(\coeff[6][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][10]_i_1 
       (.I0(\coeff[6][10]_i_2_n_0 ),
        .I1(load_data_IBUF[10]),
        .I2(\coeff[0][10]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][10]_i_3_n_0 ),
        .O(\coeff[6][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][10]_i_3 
       (.I0(load_data_IBUF[10]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][10]_i_6_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[6][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][11]_i_1 
       (.I0(\coeff[6][11]_i_2_n_0 ),
        .I1(load_data_IBUF[11]),
        .I2(\coeff[0][11]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][11]_i_3_n_0 ),
        .O(\coeff[6][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[6][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][12]_i_1 
       (.I0(\coeff[6][12]_i_2_n_0 ),
        .I1(load_data_IBUF[12]),
        .I2(\coeff[0][12]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][12]_i_3_n_0 ),
        .O(\coeff[6][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][12]_i_3 
       (.I0(load_data_IBUF[12]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][12]_i_7_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[6][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][13]_i_1 
       (.I0(\coeff[6][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][13]_i_3_n_0 ),
        .O(\coeff[6][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][13]_i_3 
       (.I0(load_data_IBUF[13]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][13]_i_6_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[6][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][14]_i_1 
       (.I0(\coeff[6][14]_i_2_n_0 ),
        .I1(load_data_IBUF[14]),
        .I2(\coeff[0][14]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][14]_i_3_n_0 ),
        .O(\coeff[6][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][14]_i_3 
       (.I0(load_data_IBUF[14]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][14]_i_6_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[6][14]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hFFD0)) 
    \coeff[6][15]_i_1 
       (.I0(\coeff[6][15]_i_3_n_0 ),
        .I1(\coeff[6][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_6_n_0 ),
        .I3(\coeff[6][15]_i_5_n_0 ),
        .O(\coeff[6][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][15]_i_2 
       (.I0(\coeff[6][15]_i_6_n_0 ),
        .I1(load_data_IBUF[15]),
        .I2(\coeff[0][15]_i_8_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][15]_i_7_n_0 ),
        .O(\coeff[6][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair90" *) 
  LUT4 #(
    .INIT(16'hFBFF)) 
    \coeff[6][15]_i_3 
       (.I0(\coeff[0][15]_i_12_n_0 ),
        .I1(p_1_in[2]),
        .I2(\j_cnt_reg_n_0_[0] ),
        .I3(p_1_in[1]),
        .O(\coeff[6][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair82" *) 
  LUT4 #(
    .INIT(16'h2000)) 
    \coeff[6][15]_i_4 
       (.I0(\coeff[0][15]_i_15_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .O(\coeff[6][15]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'h44F44444)) 
    \coeff[6][15]_i_5 
       (.I0(\coeff[1][15]_i_7_n_0 ),
        .I1(\coeff[6][15]_i_8_n_0 ),
        .I2(load_addr_IBUF[2]),
        .I3(load_addr_IBUF[3]),
        .I4(\coeff[2][15]_i_9_n_0 ),
        .O(\coeff[6][15]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][15]_i_6 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][15]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][15]_i_7 
       (.I0(load_data_IBUF[15]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][15]_i_19_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[6][15]_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair183" *) 
  LUT5 #(
    .INIT(32'h00000020)) 
    \coeff[6][15]_i_8 
       (.I0(\cnt_reg_n_0_[1] ),
        .I1(\cnt_reg_n_0_[0] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[4] ),
        .I4(\cnt_reg_n_0_[3] ),
        .O(\coeff[6][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][1]_i_1 
       (.I0(\coeff[6][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][1]_i_3_n_0 ),
        .O(\coeff[6][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][1]_i_3 
       (.I0(load_data_IBUF[1]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][1]_i_7_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][1]_i_6_n_0 ),
        .O(\coeff[6][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][2]_i_1 
       (.I0(\coeff[6][2]_i_2_n_0 ),
        .I1(load_data_IBUF[2]),
        .I2(\coeff[0][2]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][2]_i_3_n_0 ),
        .O(\coeff[6][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[6][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][3]_i_1 
       (.I0(\coeff[6][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][3]_i_3_n_0 ),
        .O(\coeff[6][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][3]_i_3 
       (.I0(load_data_IBUF[3]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][3]_i_9_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][3]_i_8_n_0 ),
        .O(\coeff[6][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][4]_i_1 
       (.I0(\coeff[6][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][4]_i_3_n_0 ),
        .O(\coeff[6][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][4]_i_3 
       (.I0(load_data_IBUF[4]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][4]_i_6_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][4]_i_7_n_0 ),
        .O(\coeff[6][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][5]_i_1 
       (.I0(\coeff[6][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][5]_i_3_n_0 ),
        .O(\coeff[6][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][5]_i_3 
       (.I0(load_data_IBUF[5]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][5]_i_7_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][5]_i_6_n_0 ),
        .O(\coeff[6][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][6]_i_1 
       (.I0(\coeff[6][6]_i_2_n_0 ),
        .I1(load_data_IBUF[6]),
        .I2(\coeff[0][6]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][6]_i_3_n_0 ),
        .O(\coeff[6][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][6]_i_3 
       (.I0(load_data_IBUF[6]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][6]_i_6_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[6][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][7]_i_1 
       (.I0(\coeff[6][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][7]_i_3_n_0 ),
        .O(\coeff[6][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[6][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[6][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][8]_i_1 
       (.I0(\coeff[6][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][8]_i_3_n_0 ),
        .O(\coeff[6][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][8]_i_3 
       (.I0(load_data_IBUF[8]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][8]_i_6_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][8]_i_7_n_0 ),
        .O(\coeff[6][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[6][9]_i_1 
       (.I0(\coeff[6][9]_i_2_n_0 ),
        .I1(load_data_IBUF[9]),
        .I2(\coeff[0][9]_i_3_n_0 ),
        .I3(\coeff[6][15]_i_3_n_0 ),
        .I4(\coeff[6][15]_i_4_n_0 ),
        .I5(\coeff[6][9]_i_3_n_0 ),
        .O(\coeff[6][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h04000000FFFFFFFF)) 
    \coeff[6][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[0]),
        .I3(p_2_out[1]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[6][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[6][9]_i_3 
       (.I0(load_data_IBUF[9]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][9]_i_6_n_0 ),
        .I3(\coeff[6][15]_i_8_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[6][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][0]_i_1 
       (.I0(\coeff[7][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][0]_i_3_n_0 ),
        .O(\coeff[7][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][0]_i_3 
       (.I0(load_data_IBUF[0]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][0]_i_6_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][0]_i_7_n_0 ),
        .O(\coeff[7][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][10]_i_1 
       (.I0(\coeff[7][10]_i_2_n_0 ),
        .I1(load_data_IBUF[10]),
        .I2(\coeff[0][10]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][10]_i_3_n_0 ),
        .O(\coeff[7][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][10]_i_3 
       (.I0(load_data_IBUF[10]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][10]_i_6_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[7][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][11]_i_1 
       (.I0(\coeff[7][11]_i_2_n_0 ),
        .I1(load_data_IBUF[11]),
        .I2(\coeff[0][11]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][11]_i_3_n_0 ),
        .O(\coeff[7][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[7][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][12]_i_1 
       (.I0(\coeff[7][12]_i_2_n_0 ),
        .I1(load_data_IBUF[12]),
        .I2(\coeff[0][12]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][12]_i_3_n_0 ),
        .O(\coeff[7][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][12]_i_3 
       (.I0(load_data_IBUF[12]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][12]_i_7_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[7][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][13]_i_1 
       (.I0(\coeff[7][13]_i_2_n_0 ),
        .I1(load_data_IBUF[13]),
        .I2(\coeff[0][13]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][13]_i_3_n_0 ),
        .O(\coeff[7][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][13]_i_3 
       (.I0(load_data_IBUF[13]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][13]_i_6_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[7][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][14]_i_1 
       (.I0(\coeff[7][14]_i_2_n_0 ),
        .I1(load_data_IBUF[14]),
        .I2(\coeff[0][14]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][14]_i_3_n_0 ),
        .O(\coeff[7][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][14]_i_3 
       (.I0(load_data_IBUF[14]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][14]_i_6_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[7][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFD0FFD0FFFFFFD0)) 
    \coeff[7][15]_i_1 
       (.I0(\coeff[7][15]_i_3_n_0 ),
        .I1(\coeff[7][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_6_n_0 ),
        .I3(\coeff[7][15]_i_5_n_0 ),
        .I4(\coeff[7][15]_i_6_n_0 ),
        .I5(\coeff[1][15]_i_7_n_0 ),
        .O(\coeff[7][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][15]_i_2 
       (.I0(\coeff[7][15]_i_7_n_0 ),
        .I1(load_data_IBUF[15]),
        .I2(\coeff[0][15]_i_8_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][15]_i_8_n_0 ),
        .O(\coeff[7][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair90" *) 
  LUT4 #(
    .INIT(16'hBFFF)) 
    \coeff[7][15]_i_3 
       (.I0(\coeff[0][15]_i_12_n_0 ),
        .I1(p_1_in[2]),
        .I2(\j_cnt_reg_n_0_[0] ),
        .I3(p_1_in[1]),
        .O(\coeff[7][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair82" *) 
  LUT4 #(
    .INIT(16'h8000)) 
    \coeff[7][15]_i_4 
       (.I0(\coeff[0][15]_i_15_n_0 ),
        .I1(p_2_out[0]),
        .I2(p_2_out[1]),
        .I3(p_2_out[2]),
        .O(\coeff[7][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair184" *) 
  LUT5 #(
    .INIT(32'h00400000)) 
    \coeff[7][15]_i_5 
       (.I0(\coeff[1][15]_i_10_n_0 ),
        .I1(load_addr_IBUF[1]),
        .I2(load_addr_IBUF[0]),
        .I3(load_addr_IBUF[3]),
        .I4(load_addr_IBUF[2]),
        .O(\coeff[7][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair68" *) 
  LUT5 #(
    .INIT(32'h00000080)) 
    \coeff[7][15]_i_6 
       (.I0(\cnt_reg_n_0_[1] ),
        .I1(\cnt_reg_n_0_[0] ),
        .I2(\cnt_reg_n_0_[2] ),
        .I3(\cnt_reg_n_0_[4] ),
        .I4(\cnt_reg_n_0_[3] ),
        .O(\coeff[7][15]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][15]_i_8 
       (.I0(load_data_IBUF[15]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][15]_i_19_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[7][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][1]_i_1 
       (.I0(\coeff[7][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][1]_i_3_n_0 ),
        .O(\coeff[7][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[7][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[7][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][2]_i_1 
       (.I0(\coeff[7][2]_i_2_n_0 ),
        .I1(load_data_IBUF[2]),
        .I2(\coeff[0][2]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][2]_i_3_n_0 ),
        .O(\coeff[7][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[7][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][3]_i_1 
       (.I0(\coeff[7][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][3]_i_3_n_0 ),
        .O(\coeff[7][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][3]_i_3 
       (.I0(load_data_IBUF[3]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][3]_i_9_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][3]_i_8_n_0 ),
        .O(\coeff[7][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][4]_i_1 
       (.I0(\coeff[7][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][4]_i_3_n_0 ),
        .O(\coeff[7][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][4]_i_3 
       (.I0(load_data_IBUF[4]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][4]_i_6_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][4]_i_7_n_0 ),
        .O(\coeff[7][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][5]_i_1 
       (.I0(\coeff[7][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][5]_i_3_n_0 ),
        .O(\coeff[7][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][5]_i_3 
       (.I0(load_data_IBUF[5]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][5]_i_7_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][5]_i_6_n_0 ),
        .O(\coeff[7][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][6]_i_1 
       (.I0(\coeff[7][6]_i_2_n_0 ),
        .I1(load_data_IBUF[6]),
        .I2(\coeff[0][6]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][6]_i_3_n_0 ),
        .O(\coeff[7][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][6]_i_3 
       (.I0(load_data_IBUF[6]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][6]_i_6_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[7][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][7]_i_1 
       (.I0(\coeff[7][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][7]_i_3_n_0 ),
        .O(\coeff[7][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[7][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[7][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][8]_i_1 
       (.I0(\coeff[7][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][8]_i_3_n_0 ),
        .O(\coeff[7][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][8]_i_3 
       (.I0(load_data_IBUF[8]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][8]_i_6_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][8]_i_7_n_0 ),
        .O(\coeff[7][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[7][9]_i_1 
       (.I0(\coeff[7][9]_i_2_n_0 ),
        .I1(load_data_IBUF[9]),
        .I2(\coeff[0][9]_i_3_n_0 ),
        .I3(\coeff[7][15]_i_3_n_0 ),
        .I4(\coeff[7][15]_i_4_n_0 ),
        .I5(\coeff[7][9]_i_3_n_0 ),
        .O(\coeff[7][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h40000000FFFFFFFF)) 
    \coeff[7][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(\coeff[0][15]_i_15_n_0 ),
        .I2(p_2_out[1]),
        .I3(p_2_out[0]),
        .I4(p_2_out[2]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[7][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[7][9]_i_3 
       (.I0(load_data_IBUF[9]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][9]_i_6_n_0 ),
        .I3(\coeff[7][15]_i_6_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[7][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[8][0]_i_1 
       (.I0(\coeff[8][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][0]_i_3_n_0 ),
        .O(\coeff[8][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[8][0]_i_3 
       (.I0(\coeff[0][0]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[0]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][0]_i_6_n_0 ),
        .O(\coeff[8][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[8][10]_i_1 
       (.I0(\coeff[8][10]_i_2_n_0 ),
        .I1(\coeff[0][10]_i_3_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][10]_i_3_n_0 ),
        .O(\coeff[8][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[8][10]_i_3 
       (.I0(\coeff[0][10]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[8][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[8][11]_i_1 
       (.I0(\coeff[8][11]_i_2_n_0 ),
        .I1(\coeff[0][11]_i_3_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][11]_i_3_n_0 ),
        .O(\coeff[8][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[8][11]_i_3 
       (.I0(\coeff[0][11]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[8][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[8][12]_i_1 
       (.I0(\coeff[8][12]_i_2_n_0 ),
        .I1(load_data_IBUF[12]),
        .I2(\coeff[0][12]_i_3_n_0 ),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][12]_i_3_n_0 ),
        .O(\coeff[8][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[8][12]_i_3 
       (.I0(\coeff[0][12]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][12]_i_7_n_0 ),
        .O(\coeff[8][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[8][13]_i_1 
       (.I0(\coeff[8][13]_i_2_n_0 ),
        .I1(\coeff[0][13]_i_3_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][13]_i_3_n_0 ),
        .O(\coeff[8][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[8][13]_i_3 
       (.I0(\coeff[0][13]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[8][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[8][14]_i_1 
       (.I0(\coeff[8][14]_i_2_n_0 ),
        .I1(\coeff[0][14]_i_3_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][14]_i_3_n_0 ),
        .O(\coeff[8][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[8][14]_i_3 
       (.I0(\coeff[0][14]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[8][14]_i_3_n_0 ));
  LUT4 #(
    .INIT(16'hFFD0)) 
    \coeff[8][15]_i_1 
       (.I0(\coeff[8][15]_i_3_n_0 ),
        .I1(\coeff[8][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_6_n_0 ),
        .I3(\coeff[8][15]_i_5_n_0 ),
        .O(\coeff[8][15]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair64" *) 
  LUT5 #(
    .INIT(32'h00000004)) 
    \coeff[8][15]_i_10 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\cnt_reg_n_0_[3] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\cnt_reg_n_0_[0] ),
        .I4(\cnt_reg_n_0_[4] ),
        .O(\coeff[8][15]_i_10_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[8][15]_i_2 
       (.I0(\coeff[8][15]_i_6_n_0 ),
        .I1(\coeff[0][15]_i_8_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][15]_i_7_n_0 ),
        .O(\coeff[8][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair188" *) 
  LUT4 #(
    .INIT(16'hFFFE)) 
    \coeff[8][15]_i_3 
       (.I0(p_1_in[1]),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(p_1_in[2]),
        .I3(\coeff[8][15]_i_8_n_0 ),
        .O(\coeff[8][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair83" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \coeff[8][15]_i_4 
       (.I0(p_2_out[1]),
        .I1(p_2_out[0]),
        .I2(p_2_out[2]),
        .I3(\coeff[8][15]_i_9_n_0 ),
        .O(\coeff[8][15]_i_4_n_0 ));
  LUT5 #(
    .INIT(32'h4F444444)) 
    \coeff[8][15]_i_5 
       (.I0(\coeff[1][15]_i_7_n_0 ),
        .I1(\coeff[8][15]_i_10_n_0 ),
        .I2(load_addr_IBUF[2]),
        .I3(load_addr_IBUF[3]),
        .I4(\coeff[0][15]_i_11_n_0 ),
        .O(\coeff[8][15]_i_5_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][15]_i_6 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][15]_i_6_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[8][15]_i_7 
       (.I0(\coeff[0][15]_i_19_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[8][15]_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair70" *) 
  LUT5 #(
    .INIT(32'hFFFEFFFF)) 
    \coeff[8][15]_i_8 
       (.I0(p_1_in[4]),
        .I1(p_1_in[5]),
        .I2(p_1_in[7]),
        .I3(p_1_in[6]),
        .I4(p_1_in[3]),
        .O(\coeff[8][15]_i_8_n_0 ));
  LUT5 #(
    .INIT(32'hFFFEFFFF)) 
    \coeff[8][15]_i_9 
       (.I0(p_2_out[5]),
        .I1(p_2_out[7]),
        .I2(p_2_out[4]),
        .I3(p_2_out[6]),
        .I4(p_2_out[3]),
        .O(\coeff[8][15]_i_9_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[8][1]_i_1 
       (.I0(\coeff[8][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][1]_i_3_n_0 ),
        .O(\coeff[8][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[8][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[8][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[8][2]_i_1 
       (.I0(\coeff[8][2]_i_2_n_0 ),
        .I1(\coeff[0][2]_i_3_n_0 ),
        .I2(load_data_IBUF[2]),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][2]_i_3_n_0 ),
        .O(\coeff[8][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[8][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[8][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[8][3]_i_1 
       (.I0(\coeff[8][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][3]_i_3_n_0 ),
        .O(\coeff[8][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[8][3]_i_3 
       (.I0(\coeff[0][3]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[3]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][3]_i_9_n_0 ),
        .O(\coeff[8][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[8][4]_i_1 
       (.I0(\coeff[8][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][4]_i_3_n_0 ),
        .O(\coeff[8][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[8][4]_i_3 
       (.I0(\coeff[0][4]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[4]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][4]_i_6_n_0 ),
        .O(\coeff[8][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[8][5]_i_1 
       (.I0(\coeff[8][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][5]_i_3_n_0 ),
        .O(\coeff[8][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[8][5]_i_3 
       (.I0(\coeff[0][5]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[5]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][5]_i_7_n_0 ),
        .O(\coeff[8][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[8][6]_i_1 
       (.I0(\coeff[8][6]_i_2_n_0 ),
        .I1(\coeff[0][6]_i_3_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][6]_i_3_n_0 ),
        .O(\coeff[8][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[8][6]_i_3 
       (.I0(\coeff[0][6]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[8][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[8][7]_i_1 
       (.I0(\coeff[8][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][7]_i_3_n_0 ),
        .O(\coeff[8][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[8][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[8][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[8][8]_i_1 
       (.I0(\coeff[8][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][8]_i_3_n_0 ),
        .O(\coeff[8][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[8][8]_i_3 
       (.I0(\coeff[0][8]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[8]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][8]_i_6_n_0 ),
        .O(\coeff[8][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[8][9]_i_1 
       (.I0(\coeff[8][9]_i_2_n_0 ),
        .I1(\coeff[0][9]_i_3_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[8][15]_i_3_n_0 ),
        .I4(\coeff[8][15]_i_4_n_0 ),
        .I5(\coeff[8][9]_i_3_n_0 ),
        .O(\coeff[8][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000001FFFFFFFF)) 
    \coeff[8][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[8][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFAA30)) 
    \coeff[8][9]_i_3 
       (.I0(\coeff[0][9]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[8][15]_i_10_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[8][9]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[9][0]_i_1 
       (.I0(\coeff[9][0]_i_2_n_0 ),
        .I1(load_data_IBUF[0]),
        .I2(\coeff[0][0]_i_3_n_0 ),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][0]_i_3_n_0 ),
        .O(\coeff[9][0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][0]_i_2 
       (.I0(\coeff[0][0]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[9][0]_i_3 
       (.I0(\coeff[0][0]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[0]),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][0]_i_6_n_0 ),
        .O(\coeff[9][0]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[9][10]_i_1 
       (.I0(\coeff[9][10]_i_2_n_0 ),
        .I1(\coeff[0][10]_i_3_n_0 ),
        .I2(load_data_IBUF[10]),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][10]_i_3_n_0 ),
        .O(\coeff[9][10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][10]_i_2 
       (.I0(\coeff[0][10]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][10]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[9][10]_i_3 
       (.I0(load_data_IBUF[10]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][10]_i_6_n_0 ),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][10]_i_7_n_0 ),
        .O(\coeff[9][10]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[9][11]_i_1 
       (.I0(\coeff[9][11]_i_2_n_0 ),
        .I1(\coeff[0][11]_i_3_n_0 ),
        .I2(load_data_IBUF[11]),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][11]_i_3_n_0 ),
        .O(\coeff[9][11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][11]_i_2 
       (.I0(\coeff[0][11]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][11]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[9][11]_i_3 
       (.I0(load_data_IBUF[11]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][11]_i_8_n_0 ),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][11]_i_9_n_0 ),
        .O(\coeff[9][11]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[9][12]_i_1 
       (.I0(\coeff[9][12]_i_2_n_0 ),
        .I1(\coeff[0][12]_i_3_n_0 ),
        .I2(load_data_IBUF[12]),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][12]_i_3_n_0 ),
        .O(\coeff[9][12]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][12]_i_2 
       (.I0(\coeff[0][12]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][12]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[9][12]_i_3 
       (.I0(load_data_IBUF[12]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][12]_i_7_n_0 ),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][12]_i_6_n_0 ),
        .O(\coeff[9][12]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[9][13]_i_1 
       (.I0(\coeff[9][13]_i_2_n_0 ),
        .I1(\coeff[0][13]_i_3_n_0 ),
        .I2(load_data_IBUF[13]),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][13]_i_3_n_0 ),
        .O(\coeff[9][13]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][13]_i_2 
       (.I0(\coeff[0][13]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][13]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[9][13]_i_3 
       (.I0(load_data_IBUF[13]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][13]_i_6_n_0 ),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][13]_i_7_n_0 ),
        .O(\coeff[9][13]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[9][14]_i_1 
       (.I0(\coeff[9][14]_i_2_n_0 ),
        .I1(\coeff[0][14]_i_3_n_0 ),
        .I2(load_data_IBUF[14]),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][14]_i_3_n_0 ),
        .O(\coeff[9][14]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][14]_i_2 
       (.I0(\coeff[0][14]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][14]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[9][14]_i_3 
       (.I0(load_data_IBUF[14]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][14]_i_6_n_0 ),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][14]_i_7_n_0 ),
        .O(\coeff[9][14]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFD0FFD0FFFFFFD0)) 
    \coeff[9][15]_i_1 
       (.I0(\coeff[9][15]_i_3_n_0 ),
        .I1(\coeff[9][15]_i_4_n_0 ),
        .I2(\coeff[0][15]_i_6_n_0 ),
        .I3(\coeff[9][15]_i_5_n_0 ),
        .I4(\coeff[9][15]_i_6_n_0 ),
        .I5(\coeff[1][15]_i_7_n_0 ),
        .O(\coeff[9][15]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[9][15]_i_2 
       (.I0(\coeff[9][15]_i_7_n_0 ),
        .I1(\coeff[0][15]_i_8_n_0 ),
        .I2(load_data_IBUF[15]),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][15]_i_8_n_0 ),
        .O(\coeff[9][15]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair188" *) 
  LUT4 #(
    .INIT(16'hFFFB)) 
    \coeff[9][15]_i_3 
       (.I0(p_1_in[1]),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(p_1_in[2]),
        .I3(\coeff[8][15]_i_8_n_0 ),
        .O(\coeff[9][15]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair83" *) 
  LUT4 #(
    .INIT(16'h0004)) 
    \coeff[9][15]_i_4 
       (.I0(p_2_out[1]),
        .I1(p_2_out[0]),
        .I2(p_2_out[2]),
        .I3(\coeff[8][15]_i_9_n_0 ),
        .O(\coeff[9][15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair74" *) 
  LUT5 #(
    .INIT(32'h00001000)) 
    \coeff[9][15]_i_5 
       (.I0(load_addr_IBUF[1]),
        .I1(\coeff[1][15]_i_10_n_0 ),
        .I2(load_addr_IBUF[0]),
        .I3(load_addr_IBUF[3]),
        .I4(load_addr_IBUF[2]),
        .O(\coeff[9][15]_i_5_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair63" *) 
  LUT5 #(
    .INIT(32'h00000040)) 
    \coeff[9][15]_i_6 
       (.I0(\cnt_reg_n_0_[2] ),
        .I1(\cnt_reg_n_0_[3] ),
        .I2(\cnt_reg_n_0_[0] ),
        .I3(\cnt_reg_n_0_[1] ),
        .I4(\cnt_reg_n_0_[4] ),
        .O(\coeff[9][15]_i_6_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][15]_i_7 
       (.I0(\coeff[0][15]_i_16_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][15]_i_7_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[9][15]_i_8 
       (.I0(load_data_IBUF[15]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][15]_i_19_n_0 ),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][15]_i_20_n_0 ),
        .O(\coeff[9][15]_i_8_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[9][1]_i_1 
       (.I0(\coeff[9][1]_i_2_n_0 ),
        .I1(load_data_IBUF[1]),
        .I2(\coeff[0][1]_i_3_n_0 ),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][1]_i_3_n_0 ),
        .O(\coeff[9][1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][1]_i_2 
       (.I0(\coeff[0][1]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][1]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[9][1]_i_3 
       (.I0(\coeff[0][1]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[1]),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][1]_i_7_n_0 ),
        .O(\coeff[9][1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[9][2]_i_1 
       (.I0(\coeff[9][2]_i_2_n_0 ),
        .I1(\coeff[0][2]_i_3_n_0 ),
        .I2(load_data_IBUF[2]),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][2]_i_3_n_0 ),
        .O(\coeff[9][2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][2]_i_2 
       (.I0(\coeff[0][2]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][2]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[9][2]_i_3 
       (.I0(load_data_IBUF[2]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][2]_i_6_n_0 ),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][2]_i_7_n_0 ),
        .O(\coeff[9][2]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[9][3]_i_1 
       (.I0(\coeff[9][3]_i_2_n_0 ),
        .I1(load_data_IBUF[3]),
        .I2(\coeff[0][3]_i_3_n_0 ),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][3]_i_3_n_0 ),
        .O(\coeff[9][3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][3]_i_2 
       (.I0(\coeff[0][3]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][3]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[9][3]_i_3 
       (.I0(\coeff[0][3]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[3]),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][3]_i_9_n_0 ),
        .O(\coeff[9][3]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[9][4]_i_1 
       (.I0(\coeff[9][4]_i_2_n_0 ),
        .I1(load_data_IBUF[4]),
        .I2(\coeff[0][4]_i_3_n_0 ),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][4]_i_3_n_0 ),
        .O(\coeff[9][4]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][4]_i_2 
       (.I0(\coeff[0][4]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][4]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[9][4]_i_3 
       (.I0(\coeff[0][4]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[4]),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][4]_i_6_n_0 ),
        .O(\coeff[9][4]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[9][5]_i_1 
       (.I0(\coeff[9][5]_i_2_n_0 ),
        .I1(load_data_IBUF[5]),
        .I2(\coeff[0][5]_i_3_n_0 ),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][5]_i_3_n_0 ),
        .O(\coeff[9][5]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][5]_i_2 
       (.I0(\coeff[0][5]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][5]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[9][5]_i_3 
       (.I0(\coeff[0][5]_i_6_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[5]),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][5]_i_7_n_0 ),
        .O(\coeff[9][5]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[9][6]_i_1 
       (.I0(\coeff[9][6]_i_2_n_0 ),
        .I1(\coeff[0][6]_i_3_n_0 ),
        .I2(load_data_IBUF[6]),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][6]_i_3_n_0 ),
        .O(\coeff[9][6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][6]_i_2 
       (.I0(\coeff[0][6]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][6]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[9][6]_i_3 
       (.I0(load_data_IBUF[6]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][6]_i_6_n_0 ),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][6]_i_7_n_0 ),
        .O(\coeff[9][6]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[9][7]_i_1 
       (.I0(\coeff[9][7]_i_2_n_0 ),
        .I1(load_data_IBUF[7]),
        .I2(\coeff[0][7]_i_3_n_0 ),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][7]_i_3_n_0 ),
        .O(\coeff[9][7]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][7]_i_2 
       (.I0(\coeff[0][7]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][7]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[9][7]_i_3 
       (.I0(\coeff[0][7]_i_8_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[7]),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][7]_i_9_n_0 ),
        .O(\coeff[9][7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55554450)) 
    \coeff[9][8]_i_1 
       (.I0(\coeff[9][8]_i_2_n_0 ),
        .I1(load_data_IBUF[8]),
        .I2(\coeff[0][8]_i_3_n_0 ),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][8]_i_3_n_0 ),
        .O(\coeff[9][8]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][8]_i_2 
       (.I0(\coeff[0][8]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][8]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFBAAABA)) 
    \coeff[9][8]_i_3 
       (.I0(\coeff[0][8]_i_7_n_0 ),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(load_data_IBUF[8]),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][8]_i_6_n_0 ),
        .O(\coeff[9][8]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF55555044)) 
    \coeff[9][9]_i_1 
       (.I0(\coeff[9][9]_i_2_n_0 ),
        .I1(\coeff[0][9]_i_3_n_0 ),
        .I2(load_data_IBUF[9]),
        .I3(\coeff[9][15]_i_3_n_0 ),
        .I4(\coeff[9][15]_i_4_n_0 ),
        .I5(\coeff[9][9]_i_3_n_0 ),
        .O(\coeff[9][9]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h00000010FFFFFFFF)) 
    \coeff[9][9]_i_2 
       (.I0(\coeff[0][9]_i_5_n_0 ),
        .I1(p_2_out[1]),
        .I2(p_2_out[0]),
        .I3(p_2_out[2]),
        .I4(\coeff[8][15]_i_9_n_0 ),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\coeff[9][9]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'hFFFFF022)) 
    \coeff[9][9]_i_3 
       (.I0(load_data_IBUF[9]),
        .I1(\coeff[1][15]_i_7_n_0 ),
        .I2(\coeff[0][9]_i_6_n_0 ),
        .I3(\coeff[9][15]_i_6_n_0 ),
        .I4(\coeff[0][9]_i_7_n_0 ),
        .O(\coeff[9][9]_i_3_n_0 ));
  FDCE \coeff_reg[0][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[0]),
        .Q(\coeff_reg_n_0_[0][0] ));
  FDCE \coeff_reg[0][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[10]),
        .Q(\coeff_reg_n_0_[0][10] ));
  FDCE \coeff_reg[0][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[11]),
        .Q(\coeff_reg_n_0_[0][11] ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][11]_i_10 
       (.CI(\coeff_reg[0][7]_i_10_n_0 ),
        .CO({\coeff_reg[0][11]_i_10_n_0 ,\coeff_reg[0][11]_i_10_n_1 ,\coeff_reg[0][11]_i_10_n_2 ,\coeff_reg[0][11]_i_10_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\coeff[0][11]_i_20_n_0 ,\coeff[0][11]_i_21_n_0 ,\coeff[0][11]_i_22_n_0 ,\coeff[0][11]_i_23_n_0 }),
        .O({\coeff_reg[0][11]_i_10_n_4 ,\coeff_reg[0][11]_i_10_n_5 ,\coeff_reg[0][11]_i_10_n_6 ,\coeff_reg[0][11]_i_10_n_7 }),
        .S({\coeff[0][11]_i_24_n_0 ,\coeff[0][11]_i_25_n_0 ,\coeff[0][11]_i_26_n_0 ,\coeff[0][11]_i_27_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][11]_i_19 
       (.CI(\coeff_reg[0][7]_i_19_n_0 ),
        .CO({\coeff_reg[0][11]_i_19_n_0 ,\coeff_reg[0][11]_i_19_n_1 ,\coeff_reg[0][11]_i_19_n_2 ,\coeff_reg[0][11]_i_19_n_3 }),
        .CYINIT(\<const0> ),
        .DI({unamedDSP__1_i_5_n_0,unamedDSP__1_i_6_n_0,unamedDSP__1_i_7_n_0,unamedDSP__1_i_8_n_0}),
        .O({\coeff_reg[0][11]_i_19_n_4 ,\coeff_reg[0][11]_i_19_n_5 ,\coeff_reg[0][11]_i_19_n_6 ,\coeff_reg[0][11]_i_19_n_7 }),
        .S({\coeff[0][11]_i_28_n_0 ,\coeff[0][11]_i_29_n_0 ,\coeff[0][11]_i_30_n_0 ,\coeff[0][11]_i_31_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][11]_i_6 
       (.CI(\coeff_reg[0][7]_i_6_n_0 ),
        .CO({\coeff_reg[0][11]_i_6_n_0 ,\coeff_reg[0][11]_i_6_n_1 ,\coeff_reg[0][11]_i_6_n_2 ,\coeff_reg[0][11]_i_6_n_3 }),
        .CYINIT(\<const0> ),
        .DI({unamedDSP_i_2_n_4,unamedDSP_i_2_n_5,unamedDSP_i_2_n_6,unamedDSP_i_2_n_7}),
        .O(barrett_reduce_return[11:8]),
        .S({\coeff[0][11]_i_11_n_0 ,\coeff[0][11]_i_12_n_0 ,\coeff[0][11]_i_13_n_0 ,\coeff[0][11]_i_14_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][11]_i_7 
       (.CI(\coeff_reg[0][7]_i_7_n_0 ),
        .CO({\coeff_reg[0][11]_i_7_n_0 ,\coeff_reg[0][11]_i_7_n_1 ,\coeff_reg[0][11]_i_7_n_2 ,\coeff_reg[0][11]_i_7_n_3 }),
        .CYINIT(\<const0> ),
        .DI(p_4_out__0[27:24]),
        .O({\coeff_reg[0][11]_i_7_n_4 ,\coeff_reg[0][11]_i_7_n_5 ,\coeff_reg[0][11]_i_7_n_6 ,\coeff_reg[0][11]_i_7_n_7 }),
        .S({\coeff[0][11]_i_15_n_0 ,\coeff[0][11]_i_16_n_0 ,\coeff[0][11]_i_17_n_0 ,\coeff[0][11]_i_18_n_0 }));
  FDCE \coeff_reg[0][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[12]),
        .Q(\coeff_reg_n_0_[0][12] ));
  FDCE \coeff_reg[0][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[13]),
        .Q(\coeff_reg_n_0_[0][13] ));
  FDCE \coeff_reg[0][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[14]),
        .Q(\coeff_reg_n_0_[0][14] ));
  FDCE \coeff_reg[0][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[15]),
        .Q(\coeff_reg_n_0_[0][15] ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][15]_i_13 
       (.CI(\<const0> ),
        .CO({\coeff_reg[0][15]_i_13_n_0 ,\coeff_reg[0][15]_i_13_n_1 ,\coeff_reg[0][15]_i_13_n_2 ,\coeff_reg[0][15]_i_13_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\coeff_reg[0][15]_i_22_n_6 ,\coeff_reg[0][15]_i_22_n_7 ,a_i_98_n_6,a_i_98_n_7}),
        .O(p_1_in[4:1]),
        .S({\coeff[0][15]_i_23_n_0 ,\coeff[0][15]_i_24_n_0 ,\coeff[0][15]_i_25_n_0 ,\coeff[0][15]_i_26_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][15]_i_14 
       (.CI(\<const0> ),
        .CO({\coeff_reg[0][15]_i_14_n_0 ,\coeff_reg[0][15]_i_14_n_1 ,\coeff_reg[0][15]_i_14_n_2 ,\coeff_reg[0][15]_i_14_n_3 }),
        .CYINIT(\<const0> ),
        .DI({p_1_in[3:1],\j_cnt_reg_n_0_[0] }),
        .O(p_2_out[3:0]),
        .S({\coeff[0][15]_i_27_n_0 ,\coeff[0][15]_i_28_n_0 ,\coeff[0][15]_i_29_n_0 ,\coeff[0][15]_i_30_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][15]_i_17 
       (.CI(\coeff_reg[0][11]_i_6_n_0 ),
        .CO({\coeff_reg[0][15]_i_17_n_1 ,\coeff_reg[0][15]_i_17_n_2 ,\coeff_reg[0][15]_i_17_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,unamedDSP_i_1_n_5,unamedDSP_i_1_n_6,unamedDSP_i_1_n_7}),
        .O(barrett_reduce_return[15:12]),
        .S({\coeff[0][15]_i_33_n_0 ,\coeff[0][15]_i_34_n_0 ,\coeff[0][15]_i_35_n_0 ,\coeff[0][15]_i_36_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][15]_i_18 
       (.CI(\coeff_reg[0][11]_i_7_n_0 ),
        .CO({\coeff_reg[0][15]_i_18_n_1 ,\coeff_reg[0][15]_i_18_n_2 ,\coeff_reg[0][15]_i_18_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,p_4_out__0[30:28]}),
        .O({\coeff_reg[0][15]_i_18_n_4 ,\coeff_reg[0][15]_i_18_n_5 ,\coeff_reg[0][15]_i_18_n_6 ,\coeff_reg[0][15]_i_18_n_7 }),
        .S({\coeff[0][15]_i_37_n_0 ,\coeff[0][15]_i_38_n_0 ,\coeff[0][15]_i_39_n_0 ,\coeff[0][15]_i_40_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][15]_i_21 
       (.CI(\coeff_reg[0][15]_i_13_n_0 ),
        .CO({\coeff_reg[0][15]_i_21_n_2 ,\coeff_reg[0][15]_i_21_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\coeff_reg[0][15]_i_22_n_4 ,\coeff_reg[0][15]_i_22_n_5 }),
        .O(p_1_in[7:5]),
        .S({\<const0> ,\coeff[0][15]_i_42_n_0 ,\coeff[0][15]_i_43_n_0 ,\coeff[0][15]_i_44_n_0 }));
  CARRY4 \coeff_reg[0][15]_i_22 
       (.CI(\<const0> ),
        .CO({\coeff_reg[0][15]_i_22_n_0 ,\coeff_reg[0][15]_i_22_n_1 ,\coeff_reg[0][15]_i_22_n_2 ,\coeff_reg[0][15]_i_22_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\coeff[0][15]_i_45_n_0 ,\coeff_reg[0][15]_i_46_n_7 ,a_i_98_n_4,a_i_98_n_5}),
        .O({\coeff_reg[0][15]_i_22_n_4 ,\coeff_reg[0][15]_i_22_n_5 ,\coeff_reg[0][15]_i_22_n_6 ,\coeff_reg[0][15]_i_22_n_7 }),
        .S({\coeff[0][15]_i_47_n_0 ,\coeff[0][15]_i_48_n_0 ,\coeff[0][15]_i_49_n_0 ,\coeff[0][15]_i_50_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][15]_i_31 
       (.CI(\coeff_reg[0][15]_i_14_n_0 ),
        .CO({\coeff_reg[0][15]_i_31_n_1 ,\coeff_reg[0][15]_i_31_n_2 ,\coeff_reg[0][15]_i_31_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,p_1_in[6:4]}),
        .O(p_2_out[7:4]),
        .S({\coeff[0][15]_i_51_n_0 ,\coeff[0][15]_i_52_n_0 ,\coeff[0][15]_i_53_n_0 ,\coeff[0][15]_i_54_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][15]_i_32 
       (.CI(\coeff_reg[0][11]_i_10_n_0 ),
        .CO({\coeff_reg[0][15]_i_32_n_1 ,\coeff_reg[0][15]_i_32_n_2 ,\coeff_reg[0][15]_i_32_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\coeff[0][15]_i_55_n_0 ,\coeff[0][15]_i_56_n_0 ,\coeff[0][15]_i_57_n_0 }),
        .O({\coeff_reg[0][15]_i_32_n_4 ,\coeff_reg[0][15]_i_32_n_5 ,\coeff_reg[0][15]_i_32_n_6 ,\coeff_reg[0][15]_i_32_n_7 }),
        .S({\coeff[0][15]_i_58_n_0 ,\coeff[0][15]_i_59_n_0 ,\coeff[0][15]_i_60_n_0 ,\coeff[0][15]_i_61_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][15]_i_41 
       (.CI(\coeff_reg[0][11]_i_19_n_0 ),
        .CO({\coeff_reg[0][15]_i_41_n_1 ,\coeff_reg[0][15]_i_41_n_2 ,\coeff_reg[0][15]_i_41_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,unamedDSP__1_i_2_n_0,unamedDSP__1_i_3_n_0,unamedDSP__1_i_4_n_0}),
        .O({\coeff_reg[0][15]_i_41_n_4 ,\coeff_reg[0][15]_i_41_n_5 ,\coeff_reg[0][15]_i_41_n_6 ,\coeff_reg[0][15]_i_41_n_7 }),
        .S({\coeff[0][15]_i_62_n_0 ,\coeff[0][15]_i_63_n_0 ,\coeff[0][15]_i_64_n_0 ,\coeff[0][15]_i_65_n_0 }));
  CARRY4 \coeff_reg[0][15]_i_46 
       (.CI(a_i_98_n_0),
        .CO({\coeff_reg[0][15]_i_46_n_2 ,\coeff_reg[0][15]_i_46_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\coeff[0][15]_i_68_n_0 ,\coeff[0][15]_i_69_n_0 }),
        .O({\coeff_reg[0][15]_i_46_n_5 ,\coeff_reg[0][15]_i_46_n_6 ,\coeff_reg[0][15]_i_46_n_7 }),
        .S({\<const0> ,\coeff[0][15]_i_70_n_0 ,\coeff[0][15]_i_71_n_0 ,\coeff[0][15]_i_72_n_0 }));
  CARRY4 \coeff_reg[0][15]_i_66 
       (.CI(\coeff_reg[0][15]_i_22_n_0 ),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O(\coeff_reg[0][15]_i_66_n_7 ),
        .S({\<const0> ,\<const0> ,\<const0> ,\coeff[0][15]_i_73_n_0 }));
  CARRY4 \coeff_reg[0][15]_i_67 
       (.CI(\<const0> ),
        .CO({\coeff_reg[0][15]_i_67_n_0 ,\coeff_reg[0][15]_i_67_n_1 ,\coeff_reg[0][15]_i_67_n_2 ,\coeff_reg[0][15]_i_67_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\coeff[0][15]_i_74_n_0 ,\coeff[0][15]_i_75_n_0 ,\coeff[0][15]_i_76_n_0 ,\<const0> }),
        .O({\coeff_reg[0][15]_i_67_n_4 ,\coeff_reg[0][15]_i_67_n_5 ,\coeff_reg[0][15]_i_67_n_6 ,\coeff_reg[0][15]_i_67_n_7 }),
        .S({\coeff[0][15]_i_77_n_0 ,\coeff[0][15]_i_78_n_0 ,\coeff[0][15]_i_79_n_0 ,\coeff[0][15]_i_80_n_0 }));
  CARRY4 \coeff_reg[0][15]_i_81 
       (.CI(\coeff_reg[0][15]_i_67_n_0 ),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .O(\coeff_reg[0][15]_i_81_n_7 ),
        .S({\<const0> ,\<const0> ,\<const0> ,\coeff[0][15]_i_84_n_0 }));
  FDCE \coeff_reg[0][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[1]),
        .Q(\coeff_reg_n_0_[0][1] ));
  FDCE \coeff_reg[0][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[2]),
        .Q(\coeff_reg_n_0_[0][2] ));
  FDCE \coeff_reg[0][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[3]),
        .Q(\coeff_reg_n_0_[0][3] ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][3]_i_10 
       (.CI(\<const0> ),
        .CO({\coeff_reg[0][3]_i_10_n_0 ,\coeff_reg[0][3]_i_10_n_1 ,\coeff_reg[0][3]_i_10_n_2 ,\coeff_reg[0][3]_i_10_n_3 }),
        .CYINIT(\<const1> ),
        .DI({\coeff[0][3]_i_20_n_0 ,\coeff[0][3]_i_21_n_0 ,\coeff[0][3]_i_22_n_0 ,\coeff[0][3]_i_23_n_0 }),
        .O({\coeff_reg[0][3]_i_10_n_4 ,\coeff_reg[0][3]_i_10_n_5 ,\coeff_reg[0][3]_i_10_n_6 ,\coeff_reg[0][3]_i_10_n_7 }),
        .S({\coeff[0][3]_i_24_n_0 ,\coeff[0][3]_i_25_n_0 ,\coeff[0][3]_i_26_n_0 ,\coeff[0][3]_i_27_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][3]_i_19 
       (.CI(\<const0> ),
        .CO({\coeff_reg[0][3]_i_19_n_0 ,\coeff_reg[0][3]_i_19_n_1 ,\coeff_reg[0][3]_i_19_n_2 ,\coeff_reg[0][3]_i_19_n_3 }),
        .CYINIT(\<const1> ),
        .DI({unamedDSP__1_i_13_n_0,unamedDSP__1_i_14_n_0,unamedDSP__1_i_15_n_0,unamedDSP__1_i_16_n_0}),
        .O({\coeff_reg[0][3]_i_19_n_4 ,\coeff_reg[0][3]_i_19_n_5 ,\coeff_reg[0][3]_i_19_n_6 ,\coeff_reg[0][3]_i_19_n_7 }),
        .S({\coeff[0][3]_i_28_n_0 ,\coeff[0][3]_i_29_n_0 ,\coeff[0][3]_i_30_n_0 ,\coeff[0][3]_i_31_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][3]_i_6 
       (.CI(\<const0> ),
        .CO({\coeff_reg[0][3]_i_6_n_0 ,\coeff_reg[0][3]_i_6_n_1 ,\coeff_reg[0][3]_i_6_n_2 ,\coeff_reg[0][3]_i_6_n_3 }),
        .CYINIT(\<const1> ),
        .DI({unamedDSP_i_4_n_4,unamedDSP_i_4_n_5,unamedDSP_i_4_n_6,unamedDSP_i_4_n_7}),
        .O(barrett_reduce_return[3:0]),
        .S({\coeff[0][3]_i_11_n_0 ,\coeff[0][3]_i_12_n_0 ,\coeff[0][3]_i_13_n_0 ,\coeff[0][3]_i_14_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][3]_i_7 
       (.CI(\<const0> ),
        .CO({\coeff_reg[0][3]_i_7_n_0 ,\coeff_reg[0][3]_i_7_n_1 ,\coeff_reg[0][3]_i_7_n_2 ,\coeff_reg[0][3]_i_7_n_3 }),
        .CYINIT(\<const0> ),
        .DI(p_4_out__0[19:16]),
        .O({\coeff_reg[0][3]_i_7_n_4 ,\coeff_reg[0][3]_i_7_n_5 ,\coeff_reg[0][3]_i_7_n_6 ,\coeff_reg[0][3]_i_7_n_7 }),
        .S({\coeff[0][3]_i_15_n_0 ,\coeff[0][3]_i_16_n_0 ,\coeff[0][3]_i_17_n_0 ,\coeff[0][3]_i_18_n_0 }));
  FDCE \coeff_reg[0][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[4]),
        .Q(\coeff_reg_n_0_[0][4] ));
  FDCE \coeff_reg[0][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[5]),
        .Q(\coeff_reg_n_0_[0][5] ));
  FDCE \coeff_reg[0][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[6]),
        .Q(\coeff_reg_n_0_[0][6] ));
  FDCE \coeff_reg[0][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[7]),
        .Q(\coeff_reg_n_0_[0][7] ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][7]_i_10 
       (.CI(\coeff_reg[0][3]_i_10_n_0 ),
        .CO({\coeff_reg[0][7]_i_10_n_0 ,\coeff_reg[0][7]_i_10_n_1 ,\coeff_reg[0][7]_i_10_n_2 ,\coeff_reg[0][7]_i_10_n_3 }),
        .CYINIT(\<const0> ),
        .DI({\coeff[0][7]_i_20_n_0 ,\coeff[0][7]_i_21_n_0 ,\coeff[0][7]_i_22_n_0 ,\coeff[0][7]_i_23_n_0 }),
        .O({\coeff_reg[0][7]_i_10_n_4 ,\coeff_reg[0][7]_i_10_n_5 ,\coeff_reg[0][7]_i_10_n_6 ,\coeff_reg[0][7]_i_10_n_7 }),
        .S({\coeff[0][7]_i_24_n_0 ,\coeff[0][7]_i_25_n_0 ,\coeff[0][7]_i_26_n_0 ,\coeff[0][7]_i_27_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][7]_i_19 
       (.CI(\coeff_reg[0][3]_i_19_n_0 ),
        .CO({\coeff_reg[0][7]_i_19_n_0 ,\coeff_reg[0][7]_i_19_n_1 ,\coeff_reg[0][7]_i_19_n_2 ,\coeff_reg[0][7]_i_19_n_3 }),
        .CYINIT(\<const0> ),
        .DI({unamedDSP__1_i_9_n_0,unamedDSP__1_i_10_n_0,unamedDSP__1_i_11_n_0,unamedDSP__1_i_12_n_0}),
        .O({\coeff_reg[0][7]_i_19_n_4 ,\coeff_reg[0][7]_i_19_n_5 ,\coeff_reg[0][7]_i_19_n_6 ,\coeff_reg[0][7]_i_19_n_7 }),
        .S({\coeff[0][7]_i_28_n_0 ,\coeff[0][7]_i_29_n_0 ,\coeff[0][7]_i_30_n_0 ,\coeff[0][7]_i_31_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][7]_i_6 
       (.CI(\coeff_reg[0][3]_i_6_n_0 ),
        .CO({\coeff_reg[0][7]_i_6_n_0 ,\coeff_reg[0][7]_i_6_n_1 ,\coeff_reg[0][7]_i_6_n_2 ,\coeff_reg[0][7]_i_6_n_3 }),
        .CYINIT(\<const0> ),
        .DI({unamedDSP_i_3_n_4,unamedDSP_i_3_n_5,unamedDSP_i_3_n_6,unamedDSP_i_3_n_7}),
        .O(barrett_reduce_return[7:4]),
        .S({\coeff[0][7]_i_11_n_0 ,\coeff[0][7]_i_12_n_0 ,\coeff[0][7]_i_13_n_0 ,\coeff[0][7]_i_14_n_0 }));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 \coeff_reg[0][7]_i_7 
       (.CI(\coeff_reg[0][3]_i_7_n_0 ),
        .CO({\coeff_reg[0][7]_i_7_n_0 ,\coeff_reg[0][7]_i_7_n_1 ,\coeff_reg[0][7]_i_7_n_2 ,\coeff_reg[0][7]_i_7_n_3 }),
        .CYINIT(\<const0> ),
        .DI(p_4_out__0[23:20]),
        .O({\coeff_reg[0][7]_i_7_n_4 ,\coeff_reg[0][7]_i_7_n_5 ,\coeff_reg[0][7]_i_7_n_6 ,\coeff_reg[0][7]_i_7_n_7 }),
        .S({\coeff[0][7]_i_15_n_0 ,\coeff[0][7]_i_16_n_0 ,\coeff[0][7]_i_17_n_0 ,\coeff[0][7]_i_18_n_0 }));
  FDCE \coeff_reg[0][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[8]),
        .Q(\coeff_reg_n_0_[0][8] ));
  FDCE \coeff_reg[0][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[0][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(coeff[9]),
        .Q(\coeff_reg_n_0_[0][9] ));
  FDCE \coeff_reg[10][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][0] ));
  FDCE \coeff_reg[10][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][10] ));
  FDCE \coeff_reg[10][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][11] ));
  FDCE \coeff_reg[10][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][12] ));
  FDCE \coeff_reg[10][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][13] ));
  FDCE \coeff_reg[10][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][14] ));
  FDCE \coeff_reg[10][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[10][15] ));
  FDCE \coeff_reg[10][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][1] ));
  FDCE \coeff_reg[10][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][2] ));
  FDCE \coeff_reg[10][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][3] ));
  FDCE \coeff_reg[10][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][4] ));
  FDCE \coeff_reg[10][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][5] ));
  FDCE \coeff_reg[10][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][6] ));
  FDCE \coeff_reg[10][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][7] ));
  FDCE \coeff_reg[10][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][8] ));
  FDCE \coeff_reg[10][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[10][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[10][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[10][9] ));
  FDCE \coeff_reg[11][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][0] ));
  FDCE \coeff_reg[11][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][10] ));
  FDCE \coeff_reg[11][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][11] ));
  FDCE \coeff_reg[11][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][12] ));
  FDCE \coeff_reg[11][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][13] ));
  FDCE \coeff_reg[11][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][14] ));
  FDCE \coeff_reg[11][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[11][15] ));
  FDCE \coeff_reg[11][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][1] ));
  FDCE \coeff_reg[11][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][2] ));
  FDCE \coeff_reg[11][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][3] ));
  FDCE \coeff_reg[11][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][4] ));
  FDCE \coeff_reg[11][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][5] ));
  FDCE \coeff_reg[11][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][6] ));
  FDCE \coeff_reg[11][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][7] ));
  FDCE \coeff_reg[11][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][8] ));
  FDCE \coeff_reg[11][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[11][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[11][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[11][9] ));
  FDCE \coeff_reg[12][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][0] ));
  FDCE \coeff_reg[12][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][10] ));
  FDCE \coeff_reg[12][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][11] ));
  FDCE \coeff_reg[12][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][12] ));
  FDCE \coeff_reg[12][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][13] ));
  FDCE \coeff_reg[12][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][14] ));
  FDCE \coeff_reg[12][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[12][15] ));
  FDCE \coeff_reg[12][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][1] ));
  FDCE \coeff_reg[12][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][2] ));
  FDCE \coeff_reg[12][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][3] ));
  FDCE \coeff_reg[12][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][4] ));
  FDCE \coeff_reg[12][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][5] ));
  FDCE \coeff_reg[12][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][6] ));
  FDCE \coeff_reg[12][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][7] ));
  FDCE \coeff_reg[12][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][8] ));
  FDCE \coeff_reg[12][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[12][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[12][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[12][9] ));
  FDCE \coeff_reg[13][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][0] ));
  FDCE \coeff_reg[13][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][10] ));
  FDCE \coeff_reg[13][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][11] ));
  FDCE \coeff_reg[13][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][12] ));
  FDCE \coeff_reg[13][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][13] ));
  FDCE \coeff_reg[13][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][14] ));
  FDCE \coeff_reg[13][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[13][15] ));
  FDCE \coeff_reg[13][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][1] ));
  FDCE \coeff_reg[13][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][2] ));
  FDCE \coeff_reg[13][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][3] ));
  FDCE \coeff_reg[13][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][4] ));
  FDCE \coeff_reg[13][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][5] ));
  FDCE \coeff_reg[13][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][6] ));
  FDCE \coeff_reg[13][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][7] ));
  FDCE \coeff_reg[13][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][8] ));
  FDCE \coeff_reg[13][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[13][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[13][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[13][9] ));
  FDCE \coeff_reg[14][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][0] ));
  FDCE \coeff_reg[14][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][10] ));
  FDCE \coeff_reg[14][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][11] ));
  FDCE \coeff_reg[14][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][12] ));
  FDCE \coeff_reg[14][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][13] ));
  FDCE \coeff_reg[14][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][14] ));
  FDCE \coeff_reg[14][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[14][15] ));
  FDCE \coeff_reg[14][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][1] ));
  FDCE \coeff_reg[14][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][2] ));
  FDCE \coeff_reg[14][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][3] ));
  FDCE \coeff_reg[14][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][4] ));
  FDCE \coeff_reg[14][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][5] ));
  FDCE \coeff_reg[14][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][6] ));
  FDCE \coeff_reg[14][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][7] ));
  FDCE \coeff_reg[14][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][8] ));
  FDCE \coeff_reg[14][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[14][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[14][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[14][9] ));
  FDCE \coeff_reg[15][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][0] ));
  FDCE \coeff_reg[15][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][10] ));
  FDCE \coeff_reg[15][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][11] ));
  FDCE \coeff_reg[15][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][12] ));
  FDCE \coeff_reg[15][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][13] ));
  FDCE \coeff_reg[15][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][14] ));
  FDCE \coeff_reg[15][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[15][15] ));
  FDCE \coeff_reg[15][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][1] ));
  FDCE \coeff_reg[15][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][2] ));
  FDCE \coeff_reg[15][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][3] ));
  FDCE \coeff_reg[15][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][4] ));
  FDCE \coeff_reg[15][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][5] ));
  FDCE \coeff_reg[15][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][6] ));
  FDCE \coeff_reg[15][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][7] ));
  FDCE \coeff_reg[15][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][8] ));
  FDCE \coeff_reg[15][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[15][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[15][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[15][9] ));
  FDCE \coeff_reg[1][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][0] ));
  FDCE \coeff_reg[1][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][10] ));
  FDCE \coeff_reg[1][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][11] ));
  FDCE \coeff_reg[1][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][12] ));
  FDCE \coeff_reg[1][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][13] ));
  FDCE \coeff_reg[1][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][14] ));
  FDCE \coeff_reg[1][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[1][15] ));
  FDCE \coeff_reg[1][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][1] ));
  FDCE \coeff_reg[1][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][2] ));
  FDCE \coeff_reg[1][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][3] ));
  FDCE \coeff_reg[1][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][4] ));
  FDCE \coeff_reg[1][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][5] ));
  FDCE \coeff_reg[1][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][6] ));
  FDCE \coeff_reg[1][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][7] ));
  FDCE \coeff_reg[1][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][8] ));
  FDCE \coeff_reg[1][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[1][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[1][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[1][9] ));
  FDCE \coeff_reg[2][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][0] ));
  FDCE \coeff_reg[2][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][10] ));
  FDCE \coeff_reg[2][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][11] ));
  FDCE \coeff_reg[2][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][12] ));
  FDCE \coeff_reg[2][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][13] ));
  FDCE \coeff_reg[2][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][14] ));
  FDCE \coeff_reg[2][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[2][15] ));
  FDCE \coeff_reg[2][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][1] ));
  FDCE \coeff_reg[2][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][2] ));
  FDCE \coeff_reg[2][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][3] ));
  FDCE \coeff_reg[2][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][4] ));
  FDCE \coeff_reg[2][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][5] ));
  FDCE \coeff_reg[2][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][6] ));
  FDCE \coeff_reg[2][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][7] ));
  FDCE \coeff_reg[2][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][8] ));
  FDCE \coeff_reg[2][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[2][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[2][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[2][9] ));
  FDCE \coeff_reg[3][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][0] ));
  FDCE \coeff_reg[3][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][10] ));
  FDCE \coeff_reg[3][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][11] ));
  FDCE \coeff_reg[3][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][12] ));
  FDCE \coeff_reg[3][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][13] ));
  FDCE \coeff_reg[3][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][14] ));
  FDCE \coeff_reg[3][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[3][15] ));
  FDCE \coeff_reg[3][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][1] ));
  FDCE \coeff_reg[3][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][2] ));
  FDCE \coeff_reg[3][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][3] ));
  FDCE \coeff_reg[3][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][4] ));
  FDCE \coeff_reg[3][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][5] ));
  FDCE \coeff_reg[3][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][6] ));
  FDCE \coeff_reg[3][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][7] ));
  FDCE \coeff_reg[3][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][8] ));
  FDCE \coeff_reg[3][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[3][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[3][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[3][9] ));
  FDCE \coeff_reg[4][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][0] ));
  FDCE \coeff_reg[4][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][10] ));
  FDCE \coeff_reg[4][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][11] ));
  FDCE \coeff_reg[4][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][12] ));
  FDCE \coeff_reg[4][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][13] ));
  FDCE \coeff_reg[4][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][14] ));
  FDCE \coeff_reg[4][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[4][15] ));
  FDCE \coeff_reg[4][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][1] ));
  FDCE \coeff_reg[4][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][2] ));
  FDCE \coeff_reg[4][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][3] ));
  FDCE \coeff_reg[4][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][4] ));
  FDCE \coeff_reg[4][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][5] ));
  FDCE \coeff_reg[4][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][6] ));
  FDCE \coeff_reg[4][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][7] ));
  FDCE \coeff_reg[4][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][8] ));
  FDCE \coeff_reg[4][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[4][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[4][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[4][9] ));
  FDCE \coeff_reg[5][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][0] ));
  FDCE \coeff_reg[5][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][10] ));
  FDCE \coeff_reg[5][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][11] ));
  FDCE \coeff_reg[5][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][12] ));
  FDCE \coeff_reg[5][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][13] ));
  FDCE \coeff_reg[5][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][14] ));
  FDCE \coeff_reg[5][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[5][15] ));
  FDCE \coeff_reg[5][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][1] ));
  FDCE \coeff_reg[5][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][2] ));
  FDCE \coeff_reg[5][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][3] ));
  FDCE \coeff_reg[5][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][4] ));
  FDCE \coeff_reg[5][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][5] ));
  FDCE \coeff_reg[5][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][6] ));
  FDCE \coeff_reg[5][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][7] ));
  FDCE \coeff_reg[5][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][8] ));
  FDCE \coeff_reg[5][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[5][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[5][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[5][9] ));
  FDCE \coeff_reg[6][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][0] ));
  FDCE \coeff_reg[6][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][10] ));
  FDCE \coeff_reg[6][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][11] ));
  FDCE \coeff_reg[6][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][12] ));
  FDCE \coeff_reg[6][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][13] ));
  FDCE \coeff_reg[6][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][14] ));
  FDCE \coeff_reg[6][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[6][15] ));
  FDCE \coeff_reg[6][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][1] ));
  FDCE \coeff_reg[6][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][2] ));
  FDCE \coeff_reg[6][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][3] ));
  FDCE \coeff_reg[6][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][4] ));
  FDCE \coeff_reg[6][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][5] ));
  FDCE \coeff_reg[6][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][6] ));
  FDCE \coeff_reg[6][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][7] ));
  FDCE \coeff_reg[6][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][8] ));
  FDCE \coeff_reg[6][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[6][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[6][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[6][9] ));
  FDCE \coeff_reg[7][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][0] ));
  FDCE \coeff_reg[7][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][10] ));
  FDCE \coeff_reg[7][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][11] ));
  FDCE \coeff_reg[7][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][12] ));
  FDCE \coeff_reg[7][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][13] ));
  FDCE \coeff_reg[7][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][14] ));
  FDCE \coeff_reg[7][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[7][15] ));
  FDCE \coeff_reg[7][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][1] ));
  FDCE \coeff_reg[7][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][2] ));
  FDCE \coeff_reg[7][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][3] ));
  FDCE \coeff_reg[7][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][4] ));
  FDCE \coeff_reg[7][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][5] ));
  FDCE \coeff_reg[7][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][6] ));
  FDCE \coeff_reg[7][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][7] ));
  FDCE \coeff_reg[7][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][8] ));
  FDCE \coeff_reg[7][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[7][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[7][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[7][9] ));
  FDCE \coeff_reg[8][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][0] ));
  FDCE \coeff_reg[8][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][10] ));
  FDCE \coeff_reg[8][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][11] ));
  FDCE \coeff_reg[8][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][12] ));
  FDCE \coeff_reg[8][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][13] ));
  FDCE \coeff_reg[8][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][14] ));
  FDCE \coeff_reg[8][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[8][15] ));
  FDCE \coeff_reg[8][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][1] ));
  FDCE \coeff_reg[8][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][2] ));
  FDCE \coeff_reg[8][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][3] ));
  FDCE \coeff_reg[8][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][4] ));
  FDCE \coeff_reg[8][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][5] ));
  FDCE \coeff_reg[8][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][6] ));
  FDCE \coeff_reg[8][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][7] ));
  FDCE \coeff_reg[8][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][8] ));
  FDCE \coeff_reg[8][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[8][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[8][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[8][9] ));
  FDCE \coeff_reg[9][0] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][0]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][0] ));
  FDCE \coeff_reg[9][10] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][10]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][10] ));
  FDCE \coeff_reg[9][11] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][11]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][11] ));
  FDCE \coeff_reg[9][12] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][12]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][12] ));
  FDCE \coeff_reg[9][13] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][13]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][13] ));
  FDCE \coeff_reg[9][14] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][14]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][14] ));
  FDCE \coeff_reg[9][15] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][15]_i_2_n_0 ),
        .Q(\coeff_reg_n_0_[9][15] ));
  FDCE \coeff_reg[9][1] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][1]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][1] ));
  FDCE \coeff_reg[9][2] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][2]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][2] ));
  FDCE \coeff_reg[9][3] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][3]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][3] ));
  FDCE \coeff_reg[9][4] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][4]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][4] ));
  FDCE \coeff_reg[9][5] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][5]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][5] ));
  FDCE \coeff_reg[9][6] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][6]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][6] ));
  FDCE \coeff_reg[9][7] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][7]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][7] ));
  FDCE \coeff_reg[9][8] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][8]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][8] ));
  FDCE \coeff_reg[9][9] 
       (.C(clk_IBUF_BUFG),
        .CE(\coeff[9][15]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\coeff[9][9]_i_1_n_0 ),
        .Q(\coeff_reg_n_0_[9][9] ));
  OBUF done_OBUF_inst
       (.I(done_OBUF),
        .O(done));
  (* SOFT_HLUTNM = "soft_lutpair66" *) 
  LUT3 #(
    .INIT(8'h80)) 
    done_i_1
       (.I0(state[2]),
        .I1(state[0]),
        .I2(state[1]),
        .O(done_i_1_n_0));
  FDCE done_reg
       (.C(clk_IBUF_BUFG),
        .CE(\<const1> ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(done_i_1_n_0),
        .Q(done_OBUF));
  LUT6 #(
    .INIT(64'h4712BEED32C9645C)) 
    g0_b0
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b0_n_0));
  LUT6 #(
    .INIT(64'h81DE7869B0E87BEA)) 
    g0_b1
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b1_n_0));
  LUT6 #(
    .INIT(64'h046292B1D0E2C536)) 
    g0_b10
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b10_n_0));
  LUT6 #(
    .INIT(64'hA9C72E444190210F)) 
    g0_b11
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b11_n_0));
  LUT5 #(
    .INIT(32'h00000001)) 
    g0_b12
       (.I0(\zeta_cnt_reg_n_0_[2] ),
        .I1(\zeta_cnt_reg_n_0_[3] ),
        .I2(\zeta_cnt_reg_n_0_[4] ),
        .I3(\zeta_cnt_reg_n_0_[5] ),
        .I4(\zeta_cnt_reg_n_0_[6] ),
        .O(g0_b12_n_0));
  LUT6 #(
    .INIT(64'hCC2BF95BC4DBEB71)) 
    g0_b2
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b2_n_0));
  LUT6 #(
    .INIT(64'h2CD9D286B7CDE6E7)) 
    g0_b3
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b3_n_0));
  LUT6 #(
    .INIT(64'h252CE2BCF7EBC95C)) 
    g0_b4
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b4_n_0));
  LUT6 #(
    .INIT(64'h493FFAD85AE9CE01)) 
    g0_b5
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b5_n_0));
  LUT6 #(
    .INIT(64'h33B46EFD9F9A3391)) 
    g0_b6
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b6_n_0));
  LUT6 #(
    .INIT(64'h720796FFB67298B5)) 
    g0_b7
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b7_n_0));
  LUT6 #(
    .INIT(64'h17AD8478223ED073)) 
    g0_b8
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b8_n_0));
  LUT6 #(
    .INIT(64'h4F2C1DDE9F43560D)) 
    g0_b9
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g0_b9_n_0));
  LUT6 #(
    .INIT(64'h2B7612076DE5A6AC)) 
    g1_b0
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b0_n_0));
  LUT6 #(
    .INIT(64'h58FEDD1C91EF5B7F)) 
    g1_b1
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b1_n_0));
  LUT6 #(
    .INIT(64'hE1128E72C1ADC840)) 
    g1_b10
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b10_n_0));
  LUT6 #(
    .INIT(64'h03655300C4593811)) 
    g1_b11
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b11_n_0));
  LUT6 #(
    .INIT(64'hBF82F020CACCF972)) 
    g1_b2
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b2_n_0));
  LUT6 #(
    .INIT(64'hBAF86A762DBB12DE)) 
    g1_b3
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b3_n_0));
  LUT6 #(
    .INIT(64'hD9D872258C90BC11)) 
    g1_b4
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b4_n_0));
  LUT6 #(
    .INIT(64'h54210239D058E5A7)) 
    g1_b5
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b5_n_0));
  LUT6 #(
    .INIT(64'hEE816F6E69B892A8)) 
    g1_b6
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b6_n_0));
  LUT6 #(
    .INIT(64'h5FE0BCA097741503)) 
    g1_b7
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b7_n_0));
  LUT6 #(
    .INIT(64'h7EFA18F13C32312A)) 
    g1_b8
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b8_n_0));
  LUT6 #(
    .INIT(64'hBE1A886D0342F26C)) 
    g1_b9
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(\zeta_cnt_reg_n_0_[1] ),
        .I2(\zeta_cnt_reg_n_0_[2] ),
        .I3(\zeta_cnt_reg_n_0_[3] ),
        .I4(\zeta_cnt_reg_n_0_[4] ),
        .I5(\zeta_cnt_reg_n_0_[5] ),
        .O(g1_b9_n_0));
  LUT4 #(
    .INIT(16'h0100)) 
    inv_mode_i_1
       (.I0(state[0]),
        .I1(state[1]),
        .I2(state[2]),
        .I3(start_IBUF),
        .O(inv_mode));
  FDCE inv_mode_reg
       (.C(clk_IBUF_BUFG),
        .CE(inv_mode),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(inverse_IBUF),
        .Q(inv_mode_reg_n_0));
  IBUF inverse_IBUF_inst
       (.I(inverse),
        .O(inverse_IBUF));
  (* SOFT_HLUTNM = "soft_lutpair93" *) 
  LUT3 #(
    .INIT(8'h04)) 
    \j_cnt[0]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\j_cnt_reg_n_0_[0] ),
        .O(j_cnt));
  (* SOFT_HLUTNM = "soft_lutpair186" *) 
  LUT4 #(
    .INIT(16'h0440)) 
    \j_cnt[1]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\j_cnt_reg_n_0_[1] ),
        .I3(\j_cnt_reg_n_0_[0] ),
        .O(\j_cnt[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair186" *) 
  LUT5 #(
    .INIT(32'h04404040)) 
    \j_cnt[2]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\j_cnt_reg_n_0_[2] ),
        .I3(\j_cnt_reg_n_0_[1] ),
        .I4(\j_cnt_reg_n_0_[0] ),
        .O(\j_cnt[2]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0440404040404040)) 
    \j_cnt[3]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\j_cnt_reg_n_0_[3] ),
        .I3(\j_cnt_reg_n_0_[2] ),
        .I4(\j_cnt_reg_n_0_[0] ),
        .I5(\j_cnt_reg_n_0_[1] ),
        .O(\j_cnt[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair93" *) 
  LUT4 #(
    .INIT(16'h4004)) 
    \j_cnt[4]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\j_cnt_reg_n_0_[4] ),
        .I3(\j_cnt[4]_i_2_n_0 ),
        .O(\j_cnt[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair75" *) 
  LUT4 #(
    .INIT(16'h7FFF)) 
    \j_cnt[4]_i_2 
       (.I0(\j_cnt_reg_n_0_[3] ),
        .I1(\j_cnt_reg_n_0_[1] ),
        .I2(\j_cnt_reg_n_0_[0] ),
        .I3(\j_cnt_reg_n_0_[2] ),
        .O(\j_cnt[4]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h4004)) 
    \j_cnt[5]_i_1 
       (.I0(state[0]),
        .I1(state[1]),
        .I2(\j_cnt_reg_n_0_[5] ),
        .I3(\j_cnt[5]_i_2_n_0 ),
        .O(\j_cnt[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair75" *) 
  LUT5 #(
    .INIT(32'h7FFFFFFF)) 
    \j_cnt[5]_i_2 
       (.I0(\j_cnt_reg_n_0_[3] ),
        .I1(\j_cnt_reg_n_0_[1] ),
        .I2(\j_cnt_reg_n_0_[0] ),
        .I3(\j_cnt_reg_n_0_[2] ),
        .I4(\j_cnt_reg_n_0_[4] ),
        .O(\j_cnt[5]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair187" *) 
  LUT4 #(
    .INIT(16'h1400)) 
    \j_cnt[6]_i_1 
       (.I0(state[0]),
        .I1(\j_cnt_reg_n_0_[6] ),
        .I2(\j_cnt[7]_i_5_n_0 ),
        .I3(state[1]),
        .O(\j_cnt[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF00000070)) 
    \j_cnt[7]_i_1 
       (.I0(\layer_idx_reg_n_0_[1] ),
        .I1(\layer_idx_reg_n_0_[2] ),
        .I2(state[2]),
        .I3(state[1]),
        .I4(state[0]),
        .I5(\j_cnt[7]_i_4_n_0 ),
        .O(\j_cnt[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair187" *) 
  LUT5 #(
    .INIT(32'h14440000)) 
    \j_cnt[7]_i_2 
       (.I0(state[0]),
        .I1(\j_cnt_reg_n_0_[7] ),
        .I2(\j_cnt_reg_n_0_[6] ),
        .I3(\j_cnt[7]_i_5_n_0 ),
        .I4(state[1]),
        .O(\j_cnt[7]_i_2_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \j_cnt[7]_i_3 
       (.I0(rst_n_IBUF),
        .O(\j_cnt[7]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFFFF0B0B0300)) 
    \j_cnt[7]_i_4 
       (.I0(\block_cnt_reg[7]_i_3_n_0 ),
        .I1(state[1]),
        .I2(state[2]),
        .I3(start_IBUF),
        .I4(state[0]),
        .I5(\coeff[0][15]_i_6_n_0 ),
        .O(\j_cnt[7]_i_4_n_0 ));
  LUT6 #(
    .INIT(64'h8000000000000000)) 
    \j_cnt[7]_i_5 
       (.I0(\j_cnt_reg_n_0_[5] ),
        .I1(\j_cnt_reg_n_0_[4] ),
        .I2(\j_cnt_reg_n_0_[2] ),
        .I3(\j_cnt_reg_n_0_[0] ),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(\j_cnt_reg_n_0_[3] ),
        .O(\j_cnt[7]_i_5_n_0 ));
  FDCE \j_cnt_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(j_cnt),
        .Q(\j_cnt_reg_n_0_[0] ));
  FDCE \j_cnt_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\j_cnt[1]_i_1_n_0 ),
        .Q(\j_cnt_reg_n_0_[1] ));
  FDCE \j_cnt_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\j_cnt[2]_i_1_n_0 ),
        .Q(\j_cnt_reg_n_0_[2] ));
  FDCE \j_cnt_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\j_cnt[3]_i_1_n_0 ),
        .Q(\j_cnt_reg_n_0_[3] ));
  FDCE \j_cnt_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\j_cnt[4]_i_1_n_0 ),
        .Q(\j_cnt_reg_n_0_[4] ));
  FDCE \j_cnt_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\j_cnt[5]_i_1_n_0 ),
        .Q(\j_cnt_reg_n_0_[5] ));
  FDCE \j_cnt_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\j_cnt[6]_i_1_n_0 ),
        .Q(\j_cnt_reg_n_0_[6] ));
  FDCE \j_cnt_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(\j_cnt[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\j_cnt[7]_i_2_n_0 ),
        .Q(\j_cnt_reg_n_0_[7] ));
  (* SOFT_HLUTNM = "soft_lutpair95" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \layer_idx[0]_i_1 
       (.I0(state[2]),
        .I1(\layer_idx_reg_n_0_[0] ),
        .O(layer_idx[0]));
  (* SOFT_HLUTNM = "soft_lutpair190" *) 
  LUT3 #(
    .INIT(8'h28)) 
    \layer_idx[1]_i_1 
       (.I0(state[2]),
        .I1(\layer_idx_reg_n_0_[1] ),
        .I2(\layer_idx_reg_n_0_[0] ),
        .O(\layer_idx[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair190" *) 
  LUT4 #(
    .INIT(16'h2A80)) 
    \layer_idx[2]_i_1 
       (.I0(state[2]),
        .I1(\layer_idx_reg_n_0_[1] ),
        .I2(\layer_idx_reg_n_0_[0] ),
        .I3(\layer_idx_reg_n_0_[2] ),
        .O(layer_idx[2]));
  FDCE \layer_idx_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(layer_idx[0]),
        .Q(\layer_idx_reg_n_0_[0] ));
  FDCE \layer_idx_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\layer_idx[1]_i_1_n_0 ),
        .Q(\layer_idx_reg_n_0_[1] ));
  FDCE \layer_idx_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(layer_idx[2]),
        .Q(\layer_idx_reg_n_0_[2] ));
  (* SOFT_HLUTNM = "soft_lutpair94" *) 
  LUT3 #(
    .INIT(8'h40)) 
    \len[0]_i_1 
       (.I0(inv_mode_reg_n_0),
        .I1(state[2]),
        .I2(\len_reg_n_0_[1] ),
        .O(len[0]));
  LUT5 #(
    .INIT(32'hB8FFB800)) 
    \len[1]_i_1 
       (.I0(\len_reg_n_0_[0] ),
        .I1(inv_mode_reg_n_0),
        .I2(\len_reg_n_0_[2] ),
        .I3(state[2]),
        .I4(inverse_IBUF),
        .O(len[1]));
  (* SOFT_HLUTNM = "soft_lutpair95" *) 
  LUT4 #(
    .INIT(16'hE200)) 
    \len[2]_i_1 
       (.I0(\len_reg_n_0_[3] ),
        .I1(inv_mode_reg_n_0),
        .I2(\len_reg_n_0_[1] ),
        .I3(state[2]),
        .O(\len[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair94" *) 
  LUT4 #(
    .INIT(16'hE200)) 
    \len[3]_i_1 
       (.I0(\len_reg_n_0_[4] ),
        .I1(inv_mode_reg_n_0),
        .I2(\len_reg_n_0_[2] ),
        .I3(state[2]),
        .O(\len[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair192" *) 
  LUT4 #(
    .INIT(16'hE040)) 
    \len[4]_i_1 
       (.I0(inv_mode_reg_n_0),
        .I1(\len_reg_n_0_[5] ),
        .I2(state[2]),
        .I3(\len_reg_n_0_[3] ),
        .O(\len[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair191" *) 
  LUT4 #(
    .INIT(16'hE020)) 
    \len[5]_i_1 
       (.I0(\len_reg_n_0_[6] ),
        .I1(inv_mode_reg_n_0),
        .I2(state[2]),
        .I3(\len_reg_n_0_[4] ),
        .O(\len[5]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair192" *) 
  LUT4 #(
    .INIT(16'hE200)) 
    \len[6]_i_1 
       (.I0(\len_reg_n_0_[7] ),
        .I1(inv_mode_reg_n_0),
        .I2(\len_reg_n_0_[5] ),
        .I3(state[2]),
        .O(\len[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0002030203020302)) 
    \len[7]_i_1 
       (.I0(start_IBUF),
        .I1(state[1]),
        .I2(state[0]),
        .I3(state[2]),
        .I4(\layer_idx_reg_n_0_[2] ),
        .I5(\layer_idx_reg_n_0_[1] ),
        .O(\len[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair191" *) 
  LUT4 #(
    .INIT(16'hC055)) 
    \len[7]_i_2 
       (.I0(inverse_IBUF),
        .I1(\len_reg_n_0_[6] ),
        .I2(inv_mode_reg_n_0),
        .I3(state[2]),
        .O(len[7]));
  FDCE \len_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(len[0]),
        .Q(\len_reg_n_0_[0] ));
  FDCE \len_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(len[1]),
        .Q(\len_reg_n_0_[1] ));
  FDCE \len_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\len[2]_i_1_n_0 ),
        .Q(\len_reg_n_0_[2] ));
  FDCE \len_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\len[3]_i_1_n_0 ),
        .Q(\len_reg_n_0_[3] ));
  FDCE \len_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\len[4]_i_1_n_0 ),
        .Q(\len_reg_n_0_[4] ));
  FDCE \len_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\len[5]_i_1_n_0 ),
        .Q(\len_reg_n_0_[5] ));
  FDCE \len_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(\len[6]_i_1_n_0 ),
        .Q(\len_reg_n_0_[6] ));
  FDCE \len_reg[7] 
       (.C(clk_IBUF_BUFG),
        .CE(\len[7]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(len[7]),
        .Q(\len_reg_n_0_[7] ));
  IBUF load_IBUF_inst
       (.I(load),
        .O(load_IBUF));
  IBUF \load_addr_IBUF[0]_inst 
       (.I(load_addr[0]),
        .O(load_addr_IBUF[0]));
  IBUF \load_addr_IBUF[1]_inst 
       (.I(load_addr[1]),
        .O(load_addr_IBUF[1]));
  IBUF \load_addr_IBUF[2]_inst 
       (.I(load_addr[2]),
        .O(load_addr_IBUF[2]));
  IBUF \load_addr_IBUF[3]_inst 
       (.I(load_addr[3]),
        .O(load_addr_IBUF[3]));
  IBUF \load_addr_IBUF[4]_inst 
       (.I(load_addr[4]),
        .O(load_addr_IBUF[4]));
  IBUF \load_addr_IBUF[5]_inst 
       (.I(load_addr[5]),
        .O(load_addr_IBUF[5]));
  IBUF \load_addr_IBUF[6]_inst 
       (.I(load_addr[6]),
        .O(load_addr_IBUF[6]));
  IBUF \load_addr_IBUF[7]_inst 
       (.I(load_addr[7]),
        .O(load_addr_IBUF[7]));
  IBUF \load_data_IBUF[0]_inst 
       (.I(load_data[0]),
        .O(load_data_IBUF[0]));
  IBUF \load_data_IBUF[10]_inst 
       (.I(load_data[10]),
        .O(load_data_IBUF[10]));
  IBUF \load_data_IBUF[11]_inst 
       (.I(load_data[11]),
        .O(load_data_IBUF[11]));
  IBUF \load_data_IBUF[12]_inst 
       (.I(load_data[12]),
        .O(load_data_IBUF[12]));
  IBUF \load_data_IBUF[13]_inst 
       (.I(load_data[13]),
        .O(load_data_IBUF[13]));
  IBUF \load_data_IBUF[14]_inst 
       (.I(load_data[14]),
        .O(load_data_IBUF[14]));
  IBUF \load_data_IBUF[15]_inst 
       (.I(load_data[15]),
        .O(load_data_IBUF[15]));
  IBUF \load_data_IBUF[1]_inst 
       (.I(load_data[1]),
        .O(load_data_IBUF[1]));
  IBUF \load_data_IBUF[2]_inst 
       (.I(load_data[2]),
        .O(load_data_IBUF[2]));
  IBUF \load_data_IBUF[3]_inst 
       (.I(load_data[3]),
        .O(load_data_IBUF[3]));
  IBUF \load_data_IBUF[4]_inst 
       (.I(load_data[4]),
        .O(load_data_IBUF[4]));
  IBUF \load_data_IBUF[5]_inst 
       (.I(load_data[5]),
        .O(load_data_IBUF[5]));
  IBUF \load_data_IBUF[6]_inst 
       (.I(load_data[6]),
        .O(load_data_IBUF[6]));
  IBUF \load_data_IBUF[7]_inst 
       (.I(load_data[7]),
        .O(load_data_IBUF[7]));
  IBUF \load_data_IBUF[8]_inst 
       (.I(load_data[8]),
        .O(load_data_IBUF[8]));
  IBUF \load_data_IBUF[9]_inst 
       (.I(load_data[9]),
        .O(load_data_IBUF[9]));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    p_0_in
       (.A({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,a_n_90,a_n_91,a_n_92,a_n_93,a_n_94,a_n_95,a_n_96,a_n_97,a_n_98,a_n_99,a_n_100,a_n_101,a_n_102,a_n_103,a_n_104,a_n_105}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .B({\<const0> ,\<const0> ,\<const1> ,\<const1> ,\<const1> ,\<const1> ,\<const0> ,\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const0> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({p_0_in_n_74,p_0_in_n_75,p_0_in_n_76,p_0_in_n_77,p_0_in_n_78,p_0_in_n_79,p_0_in_n_80,p_0_in_n_81,p_0_in_n_82,p_0_in_n_83,p_0_in_n_84,p_0_in_n_85,p_0_in_n_86,p_0_in_n_87,p_0_in_n_88,p_0_in_n_89,p_0_in_n_90,p_0_in_n_91,p_0_in_n_92,p_0_in_n_93,p_0_in_n_94,p_0_in_n_95,p_0_in_n_96,p_0_in_n_97,p_0_in_n_98,p_0_in_n_99,p_0_in_n_100,p_0_in_n_101,p_0_in_n_102,p_0_in_n_103,p_0_in_n_104,p_0_in_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    p_0_in__0
       (.A({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,a__0_n_90,a__0_n_91,a__0_n_92,a__0_n_93,a__0_n_94,a__0_n_95,a__0_n_96,a__0_n_97,a__0_n_98,a__0_n_99,a__0_n_100,a__0_n_101,a__0_n_102,a__0_n_103,a__0_n_104,a__0_n_105}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .B({\<const0> ,\<const0> ,\<const1> ,\<const1> ,\<const1> ,\<const1> ,\<const0> ,\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const0> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({p_0_in__0_n_74,p_0_in__0_n_75,p_0_in__0_n_76,p_0_in__0_n_77,p_0_in__0_n_78,p_0_in__0_n_79,p_0_in__0_n_80,p_0_in__0_n_81,p_0_in__0_n_82,p_0_in__0_n_83,p_0_in__0_n_84,p_0_in__0_n_85,p_0_in__0_n_86,p_0_in__0_n_87,p_0_in__0_n_88,p_0_in__0_n_89,p_0_in__0_n_90,p_0_in__0_n_91,p_0_in__0_n_92,p_0_in__0_n_93,p_0_in__0_n_94,p_0_in__0_n_95,p_0_in__0_n_96,p_0_in__0_n_97,p_0_in__0_n_98,p_0_in__0_n_99,p_0_in__0_n_100,p_0_in__0_n_101,p_0_in__0_n_102,p_0_in__0_n_103,p_0_in__0_n_104,p_0_in__0_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    p_0_in__1
       (.A({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,a__2}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .B({\<const0> ,\<const0> ,\<const1> ,\<const1> ,\<const1> ,\<const1> ,\<const0> ,\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const0> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({p_0_in__1_n_74,p_0_in__1_n_75,p_0_in__1_n_76,p_0_in__1_n_77,p_0_in__1_n_78,p_0_in__1_n_79,p_0_in__1_n_80,p_0_in__1_n_81,p_0_in__1_n_82,p_0_in__1_n_83,p_0_in__1_n_84,p_0_in__1_n_85,p_0_in__1_n_86,p_0_in__1_n_87,p_0_in__1_n_88,p_0_in__1_n_89,p_0_in__1_n_90,p_0_in__1_n_91,p_0_in__1_n_92,p_0_in__1_n_93,p_0_in__1_n_94,p_0_in__1_n_95,p_0_in__1_n_96,p_0_in__1_n_97,p_0_in__1_n_98,p_0_in__1_n_99,p_0_in__1_n_100,p_0_in__1_n_101,p_0_in__1_n_102,p_0_in__1_n_103,p_0_in__1_n_104,p_0_in__1_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(0),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    p_1_out
       (.A({unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_2_n_0,unamedDSP__1_i_3_n_0,unamedDSP__1_i_4_n_0,unamedDSP__1_i_5_n_0,unamedDSP__1_i_6_n_0,unamedDSP__1_i_7_n_0,unamedDSP__1_i_8_n_0,unamedDSP__1_i_9_n_0,unamedDSP__1_i_10_n_0,unamedDSP__1_i_11_n_0,unamedDSP__1_i_12_n_0,unamedDSP__1_i_13_n_0,unamedDSP__1_i_14_n_0,unamedDSP__1_i_15_n_0,unamedDSP__1_i_16_n_0}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .B({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,p_1_out_i_1_n_5,p_1_out_i_1_n_6,p_1_out_i_1_n_7,p_1_out_i_2_n_4,p_1_out_i_2_n_5,p_1_out_i_2_n_6,p_1_out_i_2_n_7,p_1_out_i_3_n_4,p_1_out_i_3_n_5,p_1_out_i_3_n_6,p_1_out_i_3_n_7,p_1_out_i_4_n_4,p_1_out_i_4_n_5,p_1_out_i_4_n_6,p_1_out_i_4_n_7,p_1_out_i_5_n_4,p_1_out_i_5_n_5,p_1_out_i_5_n_6,p_1_out_i_5_n_7,p_1_out_i_6_n_4,p_1_out_i_6_n_5,p_1_out_i_6_n_6,p_1_out_i_6_n_7,p_1_out_i_7_n_0,p_0_in__1_n_98,p_0_in__1_n_99,p_0_in__1_n_100,p_0_in__1_n_101,p_0_in__1_n_102,p_0_in__1_n_103,p_0_in__1_n_104,p_0_in__1_n_105}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const1> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({p_1_out__0,p_1_out_n_90,p_1_out_n_91,p_1_out_n_92,p_1_out_n_93,p_1_out_n_94,p_1_out_n_95,p_1_out_n_96,p_1_out_n_97,p_1_out_n_98,p_1_out_n_99,p_1_out_n_100,p_1_out_n_101,p_1_out_n_102,p_1_out_n_103,p_1_out_n_104,p_1_out_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_1_out_i_1
       (.CI(p_1_out_i_2_n_0),
        .CO({p_1_out_i_1_n_2,p_1_out_i_1_n_3}),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,p_1_out_i_8_n_0,p_1_out_i_8_n_0}),
        .O({p_1_out_i_1_n_5,p_1_out_i_1_n_6,p_1_out_i_1_n_7}),
        .S({\<const0> ,p_1_out_i_9_n_0,p_1_out_i_9_n_0,p_1_out_i_9_n_0}));
  (* HLUTNM = "lutpair58" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_1_out_i_10
       (.I0(p_0_in__1_n_90),
        .O(p_1_out_i_10_n_0));
  (* HLUTNM = "lutpair57" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_1_out_i_11
       (.I0(p_0_in__1_n_90),
        .O(p_1_out_i_11_n_0));
  (* HLUTNM = "lutpair56" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_1_out_i_12
       (.I0(p_0_in__1_n_90),
        .O(p_1_out_i_12_n_0));
  (* HLUTNM = "lutpair55" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_1_out_i_13
       (.I0(p_0_in__1_n_90),
        .O(p_1_out_i_13_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_14
       (.I0(p_1_out_i_10_n_0),
        .I1(p_1_out_i_50_n_1),
        .O(p_1_out_i_14_n_0));
  (* HLUTNM = "lutpair58" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_1_out_i_15
       (.I0(p_1_out_i_50_n_6),
        .I1(p_1_out_i_11_n_0),
        .O(p_1_out_i_15_n_0));
  (* HLUTNM = "lutpair57" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_1_out_i_16
       (.I0(p_1_out_i_50_n_7),
        .I1(p_1_out_i_12_n_0),
        .O(p_1_out_i_16_n_0));
  (* HLUTNM = "lutpair56" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_1_out_i_17
       (.I0(p_1_out_i_51_n_4),
        .I1(p_1_out_i_13_n_0),
        .O(p_1_out_i_17_n_0));
  (* HLUTNM = "lutpair54" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_1_out_i_18
       (.I0(p_0_in__1_n_90),
        .O(p_1_out_i_18_n_0));
  (* HLUTNM = "lutpair53" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_19
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_91),
        .I2(p_1_out_i_51_n_7),
        .O(p_1_out_i_19_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_1_out_i_2
       (.CI(p_1_out_i_3_n_0),
        .CO({p_1_out_i_2_n_0,p_1_out_i_2_n_1,p_1_out_i_2_n_2,p_1_out_i_2_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_1_out_i_10_n_0,p_1_out_i_11_n_0,p_1_out_i_12_n_0,p_1_out_i_13_n_0}),
        .O({p_1_out_i_2_n_4,p_1_out_i_2_n_5,p_1_out_i_2_n_6,p_1_out_i_2_n_7}),
        .S({p_1_out_i_14_n_0,p_1_out_i_15_n_0,p_1_out_i_16_n_0,p_1_out_i_17_n_0}));
  (* HLUTNM = "lutpair52" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_20
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_92),
        .I2(p_1_out_i_52_n_4),
        .O(p_1_out_i_20_n_0));
  (* HLUTNM = "lutpair51" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_21
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_93),
        .I2(p_1_out_i_52_n_5),
        .O(p_1_out_i_21_n_0));
  (* HLUTNM = "lutpair55" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_1_out_i_22
       (.I0(p_1_out_i_51_n_5),
        .I1(p_1_out_i_18_n_0),
        .O(p_1_out_i_22_n_0));
  (* HLUTNM = "lutpair54" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_1_out_i_23
       (.I0(p_1_out_i_51_n_6),
        .I1(p_1_out_i_19_n_0),
        .O(p_1_out_i_23_n_0));
  (* HLUTNM = "lutpair53" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_24
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_91),
        .I2(p_1_out_i_51_n_7),
        .I3(p_1_out_i_20_n_0),
        .O(p_1_out_i_24_n_0));
  (* HLUTNM = "lutpair52" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_25
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_92),
        .I2(p_1_out_i_52_n_4),
        .I3(p_1_out_i_21_n_0),
        .O(p_1_out_i_25_n_0));
  (* HLUTNM = "lutpair50" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_26
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_94),
        .I2(p_1_out_i_52_n_6),
        .O(p_1_out_i_26_n_0));
  (* HLUTNM = "lutpair49" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_27
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_95),
        .I2(p_1_out_i_52_n_7),
        .O(p_1_out_i_27_n_0));
  (* HLUTNM = "lutpair48" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_28
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_96),
        .I2(p_1_out_i_53_n_4),
        .O(p_1_out_i_28_n_0));
  (* HLUTNM = "lutpair47" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_29
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_97),
        .I2(p_1_out_i_53_n_5),
        .O(p_1_out_i_29_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_1_out_i_3
       (.CI(p_1_out_i_4_n_0),
        .CO({p_1_out_i_3_n_0,p_1_out_i_3_n_1,p_1_out_i_3_n_2,p_1_out_i_3_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_1_out_i_18_n_0,p_1_out_i_19_n_0,p_1_out_i_20_n_0,p_1_out_i_21_n_0}),
        .O({p_1_out_i_3_n_4,p_1_out_i_3_n_5,p_1_out_i_3_n_6,p_1_out_i_3_n_7}),
        .S({p_1_out_i_22_n_0,p_1_out_i_23_n_0,p_1_out_i_24_n_0,p_1_out_i_25_n_0}));
  (* HLUTNM = "lutpair51" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_30
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_93),
        .I2(p_1_out_i_52_n_5),
        .I3(p_1_out_i_26_n_0),
        .O(p_1_out_i_30_n_0));
  (* HLUTNM = "lutpair50" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_31
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_94),
        .I2(p_1_out_i_52_n_6),
        .I3(p_1_out_i_27_n_0),
        .O(p_1_out_i_31_n_0));
  (* HLUTNM = "lutpair49" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_32
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_95),
        .I2(p_1_out_i_52_n_7),
        .I3(p_1_out_i_28_n_0),
        .O(p_1_out_i_32_n_0));
  (* HLUTNM = "lutpair48" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_33
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_96),
        .I2(p_1_out_i_53_n_4),
        .I3(p_1_out_i_29_n_0),
        .O(p_1_out_i_33_n_0));
  (* HLUTNM = "lutpair46" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_34
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_98),
        .I2(p_1_out_i_53_n_6),
        .O(p_1_out_i_34_n_0));
  (* HLUTNM = "lutpair45" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_35
       (.I0(p_0_in__1_n_91),
        .I1(p_0_in__1_n_99),
        .I2(p_1_out_i_53_n_7),
        .O(p_1_out_i_35_n_0));
  (* HLUTNM = "lutpair44" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_36
       (.I0(p_0_in__1_n_92),
        .I1(p_0_in__1_n_100),
        .I2(p_1_out_i_54_n_4),
        .O(p_1_out_i_36_n_0));
  (* HLUTNM = "lutpair43" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_37
       (.I0(p_0_in__1_n_93),
        .I1(p_0_in__1_n_101),
        .I2(p_1_out_i_54_n_5),
        .O(p_1_out_i_37_n_0));
  (* HLUTNM = "lutpair47" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_38
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_97),
        .I2(p_1_out_i_53_n_5),
        .I3(p_1_out_i_34_n_0),
        .O(p_1_out_i_38_n_0));
  (* HLUTNM = "lutpair46" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_39
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_98),
        .I2(p_1_out_i_53_n_6),
        .I3(p_1_out_i_35_n_0),
        .O(p_1_out_i_39_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_1_out_i_4
       (.CI(p_1_out_i_5_n_0),
        .CO({p_1_out_i_4_n_0,p_1_out_i_4_n_1,p_1_out_i_4_n_2,p_1_out_i_4_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_1_out_i_26_n_0,p_1_out_i_27_n_0,p_1_out_i_28_n_0,p_1_out_i_29_n_0}),
        .O({p_1_out_i_4_n_4,p_1_out_i_4_n_5,p_1_out_i_4_n_6,p_1_out_i_4_n_7}),
        .S({p_1_out_i_30_n_0,p_1_out_i_31_n_0,p_1_out_i_32_n_0,p_1_out_i_33_n_0}));
  (* HLUTNM = "lutpair45" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_40
       (.I0(p_0_in__1_n_91),
        .I1(p_0_in__1_n_99),
        .I2(p_1_out_i_53_n_7),
        .I3(p_1_out_i_36_n_0),
        .O(p_1_out_i_40_n_0));
  (* HLUTNM = "lutpair44" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_41
       (.I0(p_0_in__1_n_92),
        .I1(p_0_in__1_n_100),
        .I2(p_1_out_i_54_n_4),
        .I3(p_1_out_i_37_n_0),
        .O(p_1_out_i_41_n_0));
  (* HLUTNM = "lutpair42" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_42
       (.I0(p_0_in__1_n_94),
        .I1(p_0_in__1_n_102),
        .I2(p_1_out_i_54_n_6),
        .O(p_1_out_i_42_n_0));
  (* HLUTNM = "lutpair41" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_1_out_i_43
       (.I0(p_0_in__1_n_95),
        .I1(p_0_in__1_n_103),
        .I2(p_1_out_i_54_n_7),
        .O(p_1_out_i_43_n_0));
  (* HLUTNM = "lutpair40" *) 
  LUT2 #(
    .INIT(4'h8)) 
    p_1_out_i_44
       (.I0(p_0_in__1_n_104),
        .I1(p_0_in__1_n_96),
        .O(p_1_out_i_44_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    p_1_out_i_45
       (.I0(p_0_in__1_n_105),
        .I1(p_0_in__1_n_97),
        .O(p_1_out_i_45_n_0));
  (* HLUTNM = "lutpair43" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_46
       (.I0(p_0_in__1_n_93),
        .I1(p_0_in__1_n_101),
        .I2(p_1_out_i_54_n_5),
        .I3(p_1_out_i_42_n_0),
        .O(p_1_out_i_46_n_0));
  (* HLUTNM = "lutpair42" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_47
       (.I0(p_0_in__1_n_94),
        .I1(p_0_in__1_n_102),
        .I2(p_1_out_i_54_n_6),
        .I3(p_1_out_i_43_n_0),
        .O(p_1_out_i_47_n_0));
  (* HLUTNM = "lutpair41" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_1_out_i_48
       (.I0(p_0_in__1_n_95),
        .I1(p_0_in__1_n_103),
        .I2(p_1_out_i_54_n_7),
        .I3(p_1_out_i_44_n_0),
        .O(p_1_out_i_48_n_0));
  (* HLUTNM = "lutpair40" *) 
  LUT4 #(
    .INIT(16'h9666)) 
    p_1_out_i_49
       (.I0(p_0_in__1_n_104),
        .I1(p_0_in__1_n_96),
        .I2(p_0_in__1_n_97),
        .I3(p_0_in__1_n_105),
        .O(p_1_out_i_49_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_1_out_i_5
       (.CI(p_1_out_i_6_n_0),
        .CO({p_1_out_i_5_n_0,p_1_out_i_5_n_1,p_1_out_i_5_n_2,p_1_out_i_5_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_1_out_i_34_n_0,p_1_out_i_35_n_0,p_1_out_i_36_n_0,p_1_out_i_37_n_0}),
        .O({p_1_out_i_5_n_4,p_1_out_i_5_n_5,p_1_out_i_5_n_6,p_1_out_i_5_n_7}),
        .S({p_1_out_i_38_n_0,p_1_out_i_39_n_0,p_1_out_i_40_n_0,p_1_out_i_41_n_0}));
  CARRY4 p_1_out_i_50
       (.CI(p_1_out_i_51_n_0),
        .CO({p_1_out_i_50_n_1,NLW_p_1_out_i_50_CO_UNCONNECTED[1],p_1_out_i_50_n_3}),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,p_0_in__1_n_91,p_0_in__1_n_90}),
        .O({p_1_out_i_50_n_6,p_1_out_i_50_n_7}),
        .S({\<const0> ,\<const1> ,p_1_out_i_55_n_0,p_1_out_i_56_n_0}));
  CARRY4 p_1_out_i_51
       (.CI(p_1_out_i_52_n_0),
        .CO({p_1_out_i_51_n_0,p_1_out_i_51_n_1,p_1_out_i_51_n_2,p_1_out_i_51_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in__1_n_92,p_0_in__1_n_93,p_0_in__1_n_94,p_0_in__1_n_95}),
        .O({p_1_out_i_51_n_4,p_1_out_i_51_n_5,p_1_out_i_51_n_6,p_1_out_i_51_n_7}),
        .S({p_1_out_i_57_n_0,p_1_out_i_58_n_0,p_1_out_i_59_n_0,p_1_out_i_60_n_0}));
  CARRY4 p_1_out_i_52
       (.CI(p_1_out_i_53_n_0),
        .CO({p_1_out_i_52_n_0,p_1_out_i_52_n_1,p_1_out_i_52_n_2,p_1_out_i_52_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in__1_n_96,p_0_in__1_n_97,p_0_in__1_n_98,p_0_in__1_n_99}),
        .O({p_1_out_i_52_n_4,p_1_out_i_52_n_5,p_1_out_i_52_n_6,p_1_out_i_52_n_7}),
        .S({p_1_out_i_61_n_0,p_1_out_i_62_n_0,p_1_out_i_63_n_0,p_1_out_i_64_n_0}));
  CARRY4 p_1_out_i_53
       (.CI(p_1_out_i_54_n_0),
        .CO({p_1_out_i_53_n_0,p_1_out_i_53_n_1,p_1_out_i_53_n_2,p_1_out_i_53_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in__1_n_100,p_0_in__1_n_101,p_0_in__1_n_102,p_0_in__1_n_103}),
        .O({p_1_out_i_53_n_4,p_1_out_i_53_n_5,p_1_out_i_53_n_6,p_1_out_i_53_n_7}),
        .S({p_1_out_i_65_n_0,p_1_out_i_66_n_0,p_1_out_i_67_n_0,p_1_out_i_68_n_0}));
  CARRY4 p_1_out_i_54
       (.CI(\<const0> ),
        .CO({p_1_out_i_54_n_0,p_1_out_i_54_n_1,p_1_out_i_54_n_2,p_1_out_i_54_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in__1_n_104,p_0_in__1_n_105,\<const0> ,\<const1> }),
        .O({p_1_out_i_54_n_4,p_1_out_i_54_n_5,p_1_out_i_54_n_6,p_1_out_i_54_n_7}),
        .S({p_1_out_i_69_n_0,p_1_out_i_70_n_0,p_1_out_i_71_n_0,p_0_in__1_n_105}));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_55
       (.I0(p_0_in__1_n_91),
        .I1(p_0_in__1_n_90),
        .O(p_1_out_i_55_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_56
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_91),
        .O(p_1_out_i_56_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_57
       (.I0(p_0_in__1_n_90),
        .I1(p_0_in__1_n_92),
        .O(p_1_out_i_57_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_58
       (.I0(p_0_in__1_n_93),
        .I1(p_0_in__1_n_91),
        .O(p_1_out_i_58_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_59
       (.I0(p_0_in__1_n_94),
        .I1(p_0_in__1_n_92),
        .O(p_1_out_i_59_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_1_out_i_6
       (.CI(\<const0> ),
        .CO({p_1_out_i_6_n_0,p_1_out_i_6_n_1,p_1_out_i_6_n_2,p_1_out_i_6_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_1_out_i_42_n_0,p_1_out_i_43_n_0,p_1_out_i_44_n_0,p_1_out_i_45_n_0}),
        .O({p_1_out_i_6_n_4,p_1_out_i_6_n_5,p_1_out_i_6_n_6,p_1_out_i_6_n_7}),
        .S({p_1_out_i_46_n_0,p_1_out_i_47_n_0,p_1_out_i_48_n_0,p_1_out_i_49_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_60
       (.I0(p_0_in__1_n_95),
        .I1(p_0_in__1_n_93),
        .O(p_1_out_i_60_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_61
       (.I0(p_0_in__1_n_96),
        .I1(p_0_in__1_n_94),
        .O(p_1_out_i_61_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_62
       (.I0(p_0_in__1_n_97),
        .I1(p_0_in__1_n_95),
        .O(p_1_out_i_62_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_63
       (.I0(p_0_in__1_n_98),
        .I1(p_0_in__1_n_96),
        .O(p_1_out_i_63_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_64
       (.I0(p_0_in__1_n_99),
        .I1(p_0_in__1_n_97),
        .O(p_1_out_i_64_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_65
       (.I0(p_0_in__1_n_100),
        .I1(p_0_in__1_n_98),
        .O(p_1_out_i_65_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_66
       (.I0(p_0_in__1_n_101),
        .I1(p_0_in__1_n_99),
        .O(p_1_out_i_66_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_67
       (.I0(p_0_in__1_n_102),
        .I1(p_0_in__1_n_100),
        .O(p_1_out_i_67_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_68
       (.I0(p_0_in__1_n_103),
        .I1(p_0_in__1_n_101),
        .O(p_1_out_i_68_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_69
       (.I0(p_0_in__1_n_104),
        .I1(p_0_in__1_n_102),
        .O(p_1_out_i_69_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    p_1_out_i_7
       (.I0(p_0_in__1_n_97),
        .I1(p_0_in__1_n_105),
        .O(p_1_out_i_7_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_70
       (.I0(p_0_in__1_n_105),
        .I1(p_0_in__1_n_103),
        .O(p_1_out_i_70_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    p_1_out_i_71
       (.I0(p_0_in__1_n_104),
        .O(p_1_out_i_71_n_0));
  (* HLUTNM = "lutpair59" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_1_out_i_8
       (.I0(p_0_in__1_n_90),
        .O(p_1_out_i_8_n_0));
  (* HLUTNM = "lutpair59" *) 
  LUT2 #(
    .INIT(4'h9)) 
    p_1_out_i_9
       (.I0(p_1_out_i_50_n_1),
        .I1(p_1_out_i_8_n_0),
        .O(p_1_out_i_9_n_0));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(0),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    p_4_out
       (.A({g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,a_i_17_n_0,a_i_18_n_0,a_i_19_n_0,a_i_20_n_0,a_i_21_n_0,a_i_22_n_0,a_i_23_n_0,a_i_24_n_0,a_i_25_n_0,a_i_26_n_0,a_i_27_n_0,a_i_28_n_0}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .B({a_i_1_n_0,a_i_1_n_0,a_i_1_n_0,a_i_2_n_0,a_i_3_n_0,a_i_4_n_0,a_i_5_n_0,a_i_6_n_0,a_i_7_n_0,a_i_8_n_0,a_i_9_n_0,a_i_10_n_0,a_i_11_n_0,a_i_12_n_0,a_i_13_n_0,a_i_14_n_0,a_i_15_n_0,a_i_16_n_0}),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,p_4_out_i_1_n_5,p_4_out_i_1_n_6,p_4_out_i_1_n_7,p_4_out_i_2_n_4,p_4_out_i_2_n_5,p_4_out_i_2_n_6,p_4_out_i_2_n_7,p_4_out_i_3_n_4,p_4_out_i_3_n_5,p_4_out_i_3_n_6,p_4_out_i_3_n_7,p_4_out_i_4_n_4,p_4_out_i_4_n_5,p_4_out_i_4_n_6,p_4_out_i_4_n_7,p_4_out_i_5_n_4,p_4_out_i_5_n_5,p_4_out_i_5_n_6,p_4_out_i_5_n_7,p_4_out_i_6_n_4,p_4_out_i_6_n_5,p_4_out_i_6_n_6,p_4_out_i_6_n_7,p_4_out_i_7_n_0,p_0_in_n_98,p_0_in_n_99,p_0_in_n_100,p_0_in_n_101,p_0_in_n_102,p_0_in_n_103,p_0_in_n_104,p_0_in_n_105}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const1> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({p_4_out__0,p_4_out_n_90,p_4_out_n_91,p_4_out_n_92,p_4_out_n_93,p_4_out_n_94,p_4_out_n_95,p_4_out_n_96,p_4_out_n_97,p_4_out_n_98,p_4_out_n_99,p_4_out_n_100,p_4_out_n_101,p_4_out_n_102,p_4_out_n_103,p_4_out_n_104,p_4_out_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_4_out_i_1
       (.CI(p_4_out_i_2_n_0),
        .CO({p_4_out_i_1_n_2,p_4_out_i_1_n_3}),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,p_4_out_i_8_n_0,p_4_out_i_8_n_0}),
        .O({p_4_out_i_1_n_5,p_4_out_i_1_n_6,p_4_out_i_1_n_7}),
        .S({\<const0> ,p_4_out_i_9_n_0,p_4_out_i_9_n_0,p_4_out_i_9_n_0}));
  (* HLUTNM = "lutpair18" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_4_out_i_10
       (.I0(p_0_in_n_90),
        .O(p_4_out_i_10_n_0));
  (* HLUTNM = "lutpair17" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_4_out_i_11
       (.I0(p_0_in_n_90),
        .O(p_4_out_i_11_n_0));
  (* HLUTNM = "lutpair16" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_4_out_i_12
       (.I0(p_0_in_n_90),
        .O(p_4_out_i_12_n_0));
  (* HLUTNM = "lutpair15" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_4_out_i_13
       (.I0(p_0_in_n_90),
        .O(p_4_out_i_13_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_14
       (.I0(p_4_out_i_10_n_0),
        .I1(p_4_out_i_50_n_1),
        .O(p_4_out_i_14_n_0));
  (* HLUTNM = "lutpair18" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_4_out_i_15
       (.I0(p_4_out_i_50_n_6),
        .I1(p_4_out_i_11_n_0),
        .O(p_4_out_i_15_n_0));
  (* HLUTNM = "lutpair17" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_4_out_i_16
       (.I0(p_4_out_i_50_n_7),
        .I1(p_4_out_i_12_n_0),
        .O(p_4_out_i_16_n_0));
  (* HLUTNM = "lutpair16" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_4_out_i_17
       (.I0(p_4_out_i_51_n_4),
        .I1(p_4_out_i_13_n_0),
        .O(p_4_out_i_17_n_0));
  (* HLUTNM = "lutpair14" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_4_out_i_18
       (.I0(p_0_in_n_90),
        .O(p_4_out_i_18_n_0));
  (* HLUTNM = "lutpair13" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_19
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_91),
        .I2(p_4_out_i_51_n_7),
        .O(p_4_out_i_19_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_4_out_i_2
       (.CI(p_4_out_i_3_n_0),
        .CO({p_4_out_i_2_n_0,p_4_out_i_2_n_1,p_4_out_i_2_n_2,p_4_out_i_2_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_4_out_i_10_n_0,p_4_out_i_11_n_0,p_4_out_i_12_n_0,p_4_out_i_13_n_0}),
        .O({p_4_out_i_2_n_4,p_4_out_i_2_n_5,p_4_out_i_2_n_6,p_4_out_i_2_n_7}),
        .S({p_4_out_i_14_n_0,p_4_out_i_15_n_0,p_4_out_i_16_n_0,p_4_out_i_17_n_0}));
  (* HLUTNM = "lutpair12" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_20
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_92),
        .I2(p_4_out_i_52_n_4),
        .O(p_4_out_i_20_n_0));
  (* HLUTNM = "lutpair11" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_21
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_93),
        .I2(p_4_out_i_52_n_5),
        .O(p_4_out_i_21_n_0));
  (* HLUTNM = "lutpair15" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_4_out_i_22
       (.I0(p_4_out_i_51_n_5),
        .I1(p_4_out_i_18_n_0),
        .O(p_4_out_i_22_n_0));
  (* HLUTNM = "lutpair14" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_4_out_i_23
       (.I0(p_4_out_i_51_n_6),
        .I1(p_4_out_i_19_n_0),
        .O(p_4_out_i_23_n_0));
  (* HLUTNM = "lutpair13" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_24
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_91),
        .I2(p_4_out_i_51_n_7),
        .I3(p_4_out_i_20_n_0),
        .O(p_4_out_i_24_n_0));
  (* HLUTNM = "lutpair12" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_25
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_92),
        .I2(p_4_out_i_52_n_4),
        .I3(p_4_out_i_21_n_0),
        .O(p_4_out_i_25_n_0));
  (* HLUTNM = "lutpair10" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_26
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_94),
        .I2(p_4_out_i_52_n_6),
        .O(p_4_out_i_26_n_0));
  (* HLUTNM = "lutpair9" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_27
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_95),
        .I2(p_4_out_i_52_n_7),
        .O(p_4_out_i_27_n_0));
  (* HLUTNM = "lutpair8" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_28
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_96),
        .I2(p_4_out_i_53_n_4),
        .O(p_4_out_i_28_n_0));
  (* HLUTNM = "lutpair7" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_29
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_97),
        .I2(p_4_out_i_53_n_5),
        .O(p_4_out_i_29_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_4_out_i_3
       (.CI(p_4_out_i_4_n_0),
        .CO({p_4_out_i_3_n_0,p_4_out_i_3_n_1,p_4_out_i_3_n_2,p_4_out_i_3_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_4_out_i_18_n_0,p_4_out_i_19_n_0,p_4_out_i_20_n_0,p_4_out_i_21_n_0}),
        .O({p_4_out_i_3_n_4,p_4_out_i_3_n_5,p_4_out_i_3_n_6,p_4_out_i_3_n_7}),
        .S({p_4_out_i_22_n_0,p_4_out_i_23_n_0,p_4_out_i_24_n_0,p_4_out_i_25_n_0}));
  (* HLUTNM = "lutpair11" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_30
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_93),
        .I2(p_4_out_i_52_n_5),
        .I3(p_4_out_i_26_n_0),
        .O(p_4_out_i_30_n_0));
  (* HLUTNM = "lutpair10" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_31
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_94),
        .I2(p_4_out_i_52_n_6),
        .I3(p_4_out_i_27_n_0),
        .O(p_4_out_i_31_n_0));
  (* HLUTNM = "lutpair9" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_32
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_95),
        .I2(p_4_out_i_52_n_7),
        .I3(p_4_out_i_28_n_0),
        .O(p_4_out_i_32_n_0));
  (* HLUTNM = "lutpair8" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_33
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_96),
        .I2(p_4_out_i_53_n_4),
        .I3(p_4_out_i_29_n_0),
        .O(p_4_out_i_33_n_0));
  (* HLUTNM = "lutpair6" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_34
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_98),
        .I2(p_4_out_i_53_n_6),
        .O(p_4_out_i_34_n_0));
  (* HLUTNM = "lutpair5" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_35
       (.I0(p_0_in_n_91),
        .I1(p_0_in_n_99),
        .I2(p_4_out_i_53_n_7),
        .O(p_4_out_i_35_n_0));
  (* HLUTNM = "lutpair4" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_36
       (.I0(p_0_in_n_92),
        .I1(p_0_in_n_100),
        .I2(p_4_out_i_54_n_4),
        .O(p_4_out_i_36_n_0));
  (* HLUTNM = "lutpair3" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_37
       (.I0(p_0_in_n_93),
        .I1(p_0_in_n_101),
        .I2(p_4_out_i_54_n_5),
        .O(p_4_out_i_37_n_0));
  (* HLUTNM = "lutpair7" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_38
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_97),
        .I2(p_4_out_i_53_n_5),
        .I3(p_4_out_i_34_n_0),
        .O(p_4_out_i_38_n_0));
  (* HLUTNM = "lutpair6" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_39
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_98),
        .I2(p_4_out_i_53_n_6),
        .I3(p_4_out_i_35_n_0),
        .O(p_4_out_i_39_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_4_out_i_4
       (.CI(p_4_out_i_5_n_0),
        .CO({p_4_out_i_4_n_0,p_4_out_i_4_n_1,p_4_out_i_4_n_2,p_4_out_i_4_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_4_out_i_26_n_0,p_4_out_i_27_n_0,p_4_out_i_28_n_0,p_4_out_i_29_n_0}),
        .O({p_4_out_i_4_n_4,p_4_out_i_4_n_5,p_4_out_i_4_n_6,p_4_out_i_4_n_7}),
        .S({p_4_out_i_30_n_0,p_4_out_i_31_n_0,p_4_out_i_32_n_0,p_4_out_i_33_n_0}));
  (* HLUTNM = "lutpair5" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_40
       (.I0(p_0_in_n_91),
        .I1(p_0_in_n_99),
        .I2(p_4_out_i_53_n_7),
        .I3(p_4_out_i_36_n_0),
        .O(p_4_out_i_40_n_0));
  (* HLUTNM = "lutpair4" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_41
       (.I0(p_0_in_n_92),
        .I1(p_0_in_n_100),
        .I2(p_4_out_i_54_n_4),
        .I3(p_4_out_i_37_n_0),
        .O(p_4_out_i_41_n_0));
  (* HLUTNM = "lutpair2" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_42
       (.I0(p_0_in_n_94),
        .I1(p_0_in_n_102),
        .I2(p_4_out_i_54_n_6),
        .O(p_4_out_i_42_n_0));
  (* HLUTNM = "lutpair1" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_4_out_i_43
       (.I0(p_0_in_n_95),
        .I1(p_0_in_n_103),
        .I2(p_4_out_i_54_n_7),
        .O(p_4_out_i_43_n_0));
  (* HLUTNM = "lutpair0" *) 
  LUT2 #(
    .INIT(4'h8)) 
    p_4_out_i_44
       (.I0(p_0_in_n_104),
        .I1(p_0_in_n_96),
        .O(p_4_out_i_44_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    p_4_out_i_45
       (.I0(p_0_in_n_105),
        .I1(p_0_in_n_97),
        .O(p_4_out_i_45_n_0));
  (* HLUTNM = "lutpair3" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_46
       (.I0(p_0_in_n_93),
        .I1(p_0_in_n_101),
        .I2(p_4_out_i_54_n_5),
        .I3(p_4_out_i_42_n_0),
        .O(p_4_out_i_46_n_0));
  (* HLUTNM = "lutpair2" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_47
       (.I0(p_0_in_n_94),
        .I1(p_0_in_n_102),
        .I2(p_4_out_i_54_n_6),
        .I3(p_4_out_i_43_n_0),
        .O(p_4_out_i_47_n_0));
  (* HLUTNM = "lutpair1" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_4_out_i_48
       (.I0(p_0_in_n_95),
        .I1(p_0_in_n_103),
        .I2(p_4_out_i_54_n_7),
        .I3(p_4_out_i_44_n_0),
        .O(p_4_out_i_48_n_0));
  (* HLUTNM = "lutpair0" *) 
  LUT4 #(
    .INIT(16'h9666)) 
    p_4_out_i_49
       (.I0(p_0_in_n_104),
        .I1(p_0_in_n_96),
        .I2(p_0_in_n_97),
        .I3(p_0_in_n_105),
        .O(p_4_out_i_49_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_4_out_i_5
       (.CI(p_4_out_i_6_n_0),
        .CO({p_4_out_i_5_n_0,p_4_out_i_5_n_1,p_4_out_i_5_n_2,p_4_out_i_5_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_4_out_i_34_n_0,p_4_out_i_35_n_0,p_4_out_i_36_n_0,p_4_out_i_37_n_0}),
        .O({p_4_out_i_5_n_4,p_4_out_i_5_n_5,p_4_out_i_5_n_6,p_4_out_i_5_n_7}),
        .S({p_4_out_i_38_n_0,p_4_out_i_39_n_0,p_4_out_i_40_n_0,p_4_out_i_41_n_0}));
  CARRY4 p_4_out_i_50
       (.CI(p_4_out_i_51_n_0),
        .CO({p_4_out_i_50_n_1,NLW_p_4_out_i_50_CO_UNCONNECTED[1],p_4_out_i_50_n_3}),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,p_0_in_n_91,p_0_in_n_90}),
        .O({p_4_out_i_50_n_6,p_4_out_i_50_n_7}),
        .S({\<const0> ,\<const1> ,p_4_out_i_55_n_0,p_4_out_i_56_n_0}));
  CARRY4 p_4_out_i_51
       (.CI(p_4_out_i_52_n_0),
        .CO({p_4_out_i_51_n_0,p_4_out_i_51_n_1,p_4_out_i_51_n_2,p_4_out_i_51_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in_n_92,p_0_in_n_93,p_0_in_n_94,p_0_in_n_95}),
        .O({p_4_out_i_51_n_4,p_4_out_i_51_n_5,p_4_out_i_51_n_6,p_4_out_i_51_n_7}),
        .S({p_4_out_i_57_n_0,p_4_out_i_58_n_0,p_4_out_i_59_n_0,p_4_out_i_60_n_0}));
  CARRY4 p_4_out_i_52
       (.CI(p_4_out_i_53_n_0),
        .CO({p_4_out_i_52_n_0,p_4_out_i_52_n_1,p_4_out_i_52_n_2,p_4_out_i_52_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in_n_96,p_0_in_n_97,p_0_in_n_98,p_0_in_n_99}),
        .O({p_4_out_i_52_n_4,p_4_out_i_52_n_5,p_4_out_i_52_n_6,p_4_out_i_52_n_7}),
        .S({p_4_out_i_61_n_0,p_4_out_i_62_n_0,p_4_out_i_63_n_0,p_4_out_i_64_n_0}));
  CARRY4 p_4_out_i_53
       (.CI(p_4_out_i_54_n_0),
        .CO({p_4_out_i_53_n_0,p_4_out_i_53_n_1,p_4_out_i_53_n_2,p_4_out_i_53_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in_n_100,p_0_in_n_101,p_0_in_n_102,p_0_in_n_103}),
        .O({p_4_out_i_53_n_4,p_4_out_i_53_n_5,p_4_out_i_53_n_6,p_4_out_i_53_n_7}),
        .S({p_4_out_i_65_n_0,p_4_out_i_66_n_0,p_4_out_i_67_n_0,p_4_out_i_68_n_0}));
  CARRY4 p_4_out_i_54
       (.CI(\<const0> ),
        .CO({p_4_out_i_54_n_0,p_4_out_i_54_n_1,p_4_out_i_54_n_2,p_4_out_i_54_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in_n_104,p_0_in_n_105,\<const0> ,\<const1> }),
        .O({p_4_out_i_54_n_4,p_4_out_i_54_n_5,p_4_out_i_54_n_6,p_4_out_i_54_n_7}),
        .S({p_4_out_i_69_n_0,p_4_out_i_70_n_0,p_4_out_i_71_n_0,p_0_in_n_105}));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_55
       (.I0(p_0_in_n_91),
        .I1(p_0_in_n_90),
        .O(p_4_out_i_55_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_56
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_91),
        .O(p_4_out_i_56_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_57
       (.I0(p_0_in_n_90),
        .I1(p_0_in_n_92),
        .O(p_4_out_i_57_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_58
       (.I0(p_0_in_n_93),
        .I1(p_0_in_n_91),
        .O(p_4_out_i_58_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_59
       (.I0(p_0_in_n_94),
        .I1(p_0_in_n_92),
        .O(p_4_out_i_59_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_4_out_i_6
       (.CI(\<const0> ),
        .CO({p_4_out_i_6_n_0,p_4_out_i_6_n_1,p_4_out_i_6_n_2,p_4_out_i_6_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_4_out_i_42_n_0,p_4_out_i_43_n_0,p_4_out_i_44_n_0,p_4_out_i_45_n_0}),
        .O({p_4_out_i_6_n_4,p_4_out_i_6_n_5,p_4_out_i_6_n_6,p_4_out_i_6_n_7}),
        .S({p_4_out_i_46_n_0,p_4_out_i_47_n_0,p_4_out_i_48_n_0,p_4_out_i_49_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_60
       (.I0(p_0_in_n_95),
        .I1(p_0_in_n_93),
        .O(p_4_out_i_60_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_61
       (.I0(p_0_in_n_96),
        .I1(p_0_in_n_94),
        .O(p_4_out_i_61_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_62
       (.I0(p_0_in_n_97),
        .I1(p_0_in_n_95),
        .O(p_4_out_i_62_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_63
       (.I0(p_0_in_n_98),
        .I1(p_0_in_n_96),
        .O(p_4_out_i_63_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_64
       (.I0(p_0_in_n_99),
        .I1(p_0_in_n_97),
        .O(p_4_out_i_64_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_65
       (.I0(p_0_in_n_100),
        .I1(p_0_in_n_98),
        .O(p_4_out_i_65_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_66
       (.I0(p_0_in_n_101),
        .I1(p_0_in_n_99),
        .O(p_4_out_i_66_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_67
       (.I0(p_0_in_n_102),
        .I1(p_0_in_n_100),
        .O(p_4_out_i_67_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_68
       (.I0(p_0_in_n_103),
        .I1(p_0_in_n_101),
        .O(p_4_out_i_68_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_69
       (.I0(p_0_in_n_104),
        .I1(p_0_in_n_102),
        .O(p_4_out_i_69_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    p_4_out_i_7
       (.I0(p_0_in_n_97),
        .I1(p_0_in_n_105),
        .O(p_4_out_i_7_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_70
       (.I0(p_0_in_n_105),
        .I1(p_0_in_n_103),
        .O(p_4_out_i_70_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    p_4_out_i_71
       (.I0(p_0_in_n_104),
        .O(p_4_out_i_71_n_0));
  (* HLUTNM = "lutpair19" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_4_out_i_8
       (.I0(p_0_in_n_90),
        .O(p_4_out_i_8_n_0));
  (* HLUTNM = "lutpair19" *) 
  LUT2 #(
    .INIT(4'h9)) 
    p_4_out_i_9
       (.I0(p_4_out_i_50_n_1),
        .I1(p_4_out_i_8_n_0),
        .O(p_4_out_i_9_n_0));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(0),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    p_7_out
       (.A({g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,g0_b12_n_0,a_i_17_n_0,a_i_18_n_0,a_i_19_n_0,a_i_20_n_0,a_i_21_n_0,a_i_22_n_0,a_i_23_n_0,a_i_24_n_0,a_i_25_n_0,a_i_26_n_0,a_i_27_n_0,a_i_28_n_0}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .B({p_0_in__2[15],p_0_in__2[15],p_0_in__2}),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,p_7_out_i_1_n_5,p_7_out_i_1_n_6,p_7_out_i_1_n_7,p_7_out_i_2_n_4,p_7_out_i_2_n_5,p_7_out_i_2_n_6,p_7_out_i_2_n_7,p_7_out_i_3_n_4,p_7_out_i_3_n_5,p_7_out_i_3_n_6,p_7_out_i_3_n_7,p_7_out_i_4_n_4,p_7_out_i_4_n_5,p_7_out_i_4_n_6,p_7_out_i_4_n_7,p_7_out_i_5_n_4,p_7_out_i_5_n_5,p_7_out_i_5_n_6,p_7_out_i_5_n_7,p_7_out_i_6_n_4,p_7_out_i_6_n_5,p_7_out_i_6_n_6,p_7_out_i_6_n_7,p_7_out_i_7_n_0,p_0_in__0_n_98,p_0_in__0_n_99,p_0_in__0_n_100,p_0_in__0_n_101,p_0_in__0_n_102,p_0_in__0_n_103,p_0_in__0_n_104,p_0_in__0_n_105}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const1> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({p_7_out__0,p_7_out_n_90,p_7_out_n_91,p_7_out_n_92,p_7_out_n_93,p_7_out_n_94,p_7_out_n_95,p_7_out_n_96,p_7_out_n_97,p_7_out_n_98,p_7_out_n_99,p_7_out_n_100,p_7_out_n_101,p_7_out_n_102,p_7_out_n_103,p_7_out_n_104,p_7_out_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_7_out_i_1
       (.CI(p_7_out_i_2_n_0),
        .CO({p_7_out_i_1_n_2,p_7_out_i_1_n_3}),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,p_7_out_i_8_n_0,p_7_out_i_8_n_0}),
        .O({p_7_out_i_1_n_5,p_7_out_i_1_n_6,p_7_out_i_1_n_7}),
        .S({\<const0> ,p_7_out_i_9_n_0,p_7_out_i_9_n_0,p_7_out_i_9_n_0}));
  (* HLUTNM = "lutpair38" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_7_out_i_10
       (.I0(p_0_in__0_n_90),
        .O(p_7_out_i_10_n_0));
  (* HLUTNM = "lutpair37" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_7_out_i_11
       (.I0(p_0_in__0_n_90),
        .O(p_7_out_i_11_n_0));
  (* HLUTNM = "lutpair36" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_7_out_i_12
       (.I0(p_0_in__0_n_90),
        .O(p_7_out_i_12_n_0));
  (* HLUTNM = "lutpair35" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_7_out_i_13
       (.I0(p_0_in__0_n_90),
        .O(p_7_out_i_13_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_14
       (.I0(p_7_out_i_10_n_0),
        .I1(p_7_out_i_50_n_1),
        .O(p_7_out_i_14_n_0));
  (* HLUTNM = "lutpair38" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_7_out_i_15
       (.I0(p_7_out_i_50_n_6),
        .I1(p_7_out_i_11_n_0),
        .O(p_7_out_i_15_n_0));
  (* HLUTNM = "lutpair37" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_7_out_i_16
       (.I0(p_7_out_i_50_n_7),
        .I1(p_7_out_i_12_n_0),
        .O(p_7_out_i_16_n_0));
  (* HLUTNM = "lutpair36" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_7_out_i_17
       (.I0(p_7_out_i_51_n_4),
        .I1(p_7_out_i_13_n_0),
        .O(p_7_out_i_17_n_0));
  (* HLUTNM = "lutpair34" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_7_out_i_18
       (.I0(p_0_in__0_n_90),
        .O(p_7_out_i_18_n_0));
  (* HLUTNM = "lutpair33" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_19
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_91),
        .I2(p_7_out_i_51_n_7),
        .O(p_7_out_i_19_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_7_out_i_2
       (.CI(p_7_out_i_3_n_0),
        .CO({p_7_out_i_2_n_0,p_7_out_i_2_n_1,p_7_out_i_2_n_2,p_7_out_i_2_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_7_out_i_10_n_0,p_7_out_i_11_n_0,p_7_out_i_12_n_0,p_7_out_i_13_n_0}),
        .O({p_7_out_i_2_n_4,p_7_out_i_2_n_5,p_7_out_i_2_n_6,p_7_out_i_2_n_7}),
        .S({p_7_out_i_14_n_0,p_7_out_i_15_n_0,p_7_out_i_16_n_0,p_7_out_i_17_n_0}));
  (* HLUTNM = "lutpair32" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_20
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_92),
        .I2(p_7_out_i_52_n_4),
        .O(p_7_out_i_20_n_0));
  (* HLUTNM = "lutpair31" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_21
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_93),
        .I2(p_7_out_i_52_n_5),
        .O(p_7_out_i_21_n_0));
  (* HLUTNM = "lutpair35" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_7_out_i_22
       (.I0(p_7_out_i_51_n_5),
        .I1(p_7_out_i_18_n_0),
        .O(p_7_out_i_22_n_0));
  (* HLUTNM = "lutpair34" *) 
  LUT2 #(
    .INIT(4'h6)) 
    p_7_out_i_23
       (.I0(p_7_out_i_51_n_6),
        .I1(p_7_out_i_19_n_0),
        .O(p_7_out_i_23_n_0));
  (* HLUTNM = "lutpair33" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_24
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_91),
        .I2(p_7_out_i_51_n_7),
        .I3(p_7_out_i_20_n_0),
        .O(p_7_out_i_24_n_0));
  (* HLUTNM = "lutpair32" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_25
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_92),
        .I2(p_7_out_i_52_n_4),
        .I3(p_7_out_i_21_n_0),
        .O(p_7_out_i_25_n_0));
  (* HLUTNM = "lutpair30" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_26
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_94),
        .I2(p_7_out_i_52_n_6),
        .O(p_7_out_i_26_n_0));
  (* HLUTNM = "lutpair29" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_27
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_95),
        .I2(p_7_out_i_52_n_7),
        .O(p_7_out_i_27_n_0));
  (* HLUTNM = "lutpair28" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_28
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_96),
        .I2(p_7_out_i_53_n_4),
        .O(p_7_out_i_28_n_0));
  (* HLUTNM = "lutpair27" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_29
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_97),
        .I2(p_7_out_i_53_n_5),
        .O(p_7_out_i_29_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_7_out_i_3
       (.CI(p_7_out_i_4_n_0),
        .CO({p_7_out_i_3_n_0,p_7_out_i_3_n_1,p_7_out_i_3_n_2,p_7_out_i_3_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_7_out_i_18_n_0,p_7_out_i_19_n_0,p_7_out_i_20_n_0,p_7_out_i_21_n_0}),
        .O({p_7_out_i_3_n_4,p_7_out_i_3_n_5,p_7_out_i_3_n_6,p_7_out_i_3_n_7}),
        .S({p_7_out_i_22_n_0,p_7_out_i_23_n_0,p_7_out_i_24_n_0,p_7_out_i_25_n_0}));
  (* HLUTNM = "lutpair31" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_30
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_93),
        .I2(p_7_out_i_52_n_5),
        .I3(p_7_out_i_26_n_0),
        .O(p_7_out_i_30_n_0));
  (* HLUTNM = "lutpair30" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_31
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_94),
        .I2(p_7_out_i_52_n_6),
        .I3(p_7_out_i_27_n_0),
        .O(p_7_out_i_31_n_0));
  (* HLUTNM = "lutpair29" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_32
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_95),
        .I2(p_7_out_i_52_n_7),
        .I3(p_7_out_i_28_n_0),
        .O(p_7_out_i_32_n_0));
  (* HLUTNM = "lutpair28" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_33
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_96),
        .I2(p_7_out_i_53_n_4),
        .I3(p_7_out_i_29_n_0),
        .O(p_7_out_i_33_n_0));
  (* HLUTNM = "lutpair26" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_34
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_98),
        .I2(p_7_out_i_53_n_6),
        .O(p_7_out_i_34_n_0));
  (* HLUTNM = "lutpair25" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_35
       (.I0(p_0_in__0_n_91),
        .I1(p_0_in__0_n_99),
        .I2(p_7_out_i_53_n_7),
        .O(p_7_out_i_35_n_0));
  (* HLUTNM = "lutpair24" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_36
       (.I0(p_0_in__0_n_92),
        .I1(p_0_in__0_n_100),
        .I2(p_7_out_i_54_n_4),
        .O(p_7_out_i_36_n_0));
  (* HLUTNM = "lutpair23" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_37
       (.I0(p_0_in__0_n_93),
        .I1(p_0_in__0_n_101),
        .I2(p_7_out_i_54_n_5),
        .O(p_7_out_i_37_n_0));
  (* HLUTNM = "lutpair27" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_38
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_97),
        .I2(p_7_out_i_53_n_5),
        .I3(p_7_out_i_34_n_0),
        .O(p_7_out_i_38_n_0));
  (* HLUTNM = "lutpair26" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_39
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_98),
        .I2(p_7_out_i_53_n_6),
        .I3(p_7_out_i_35_n_0),
        .O(p_7_out_i_39_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_7_out_i_4
       (.CI(p_7_out_i_5_n_0),
        .CO({p_7_out_i_4_n_0,p_7_out_i_4_n_1,p_7_out_i_4_n_2,p_7_out_i_4_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_7_out_i_26_n_0,p_7_out_i_27_n_0,p_7_out_i_28_n_0,p_7_out_i_29_n_0}),
        .O({p_7_out_i_4_n_4,p_7_out_i_4_n_5,p_7_out_i_4_n_6,p_7_out_i_4_n_7}),
        .S({p_7_out_i_30_n_0,p_7_out_i_31_n_0,p_7_out_i_32_n_0,p_7_out_i_33_n_0}));
  (* HLUTNM = "lutpair25" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_40
       (.I0(p_0_in__0_n_91),
        .I1(p_0_in__0_n_99),
        .I2(p_7_out_i_53_n_7),
        .I3(p_7_out_i_36_n_0),
        .O(p_7_out_i_40_n_0));
  (* HLUTNM = "lutpair24" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_41
       (.I0(p_0_in__0_n_92),
        .I1(p_0_in__0_n_100),
        .I2(p_7_out_i_54_n_4),
        .I3(p_7_out_i_37_n_0),
        .O(p_7_out_i_41_n_0));
  (* HLUTNM = "lutpair22" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_42
       (.I0(p_0_in__0_n_94),
        .I1(p_0_in__0_n_102),
        .I2(p_7_out_i_54_n_6),
        .O(p_7_out_i_42_n_0));
  (* HLUTNM = "lutpair21" *) 
  LUT3 #(
    .INIT(8'hE8)) 
    p_7_out_i_43
       (.I0(p_0_in__0_n_95),
        .I1(p_0_in__0_n_103),
        .I2(p_7_out_i_54_n_7),
        .O(p_7_out_i_43_n_0));
  (* HLUTNM = "lutpair20" *) 
  LUT2 #(
    .INIT(4'h8)) 
    p_7_out_i_44
       (.I0(p_0_in__0_n_104),
        .I1(p_0_in__0_n_96),
        .O(p_7_out_i_44_n_0));
  LUT2 #(
    .INIT(4'h8)) 
    p_7_out_i_45
       (.I0(p_0_in__0_n_105),
        .I1(p_0_in__0_n_97),
        .O(p_7_out_i_45_n_0));
  (* HLUTNM = "lutpair23" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_46
       (.I0(p_0_in__0_n_93),
        .I1(p_0_in__0_n_101),
        .I2(p_7_out_i_54_n_5),
        .I3(p_7_out_i_42_n_0),
        .O(p_7_out_i_46_n_0));
  (* HLUTNM = "lutpair22" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_47
       (.I0(p_0_in__0_n_94),
        .I1(p_0_in__0_n_102),
        .I2(p_7_out_i_54_n_6),
        .I3(p_7_out_i_43_n_0),
        .O(p_7_out_i_47_n_0));
  (* HLUTNM = "lutpair21" *) 
  LUT4 #(
    .INIT(16'h6996)) 
    p_7_out_i_48
       (.I0(p_0_in__0_n_95),
        .I1(p_0_in__0_n_103),
        .I2(p_7_out_i_54_n_7),
        .I3(p_7_out_i_44_n_0),
        .O(p_7_out_i_48_n_0));
  (* HLUTNM = "lutpair20" *) 
  LUT4 #(
    .INIT(16'h9666)) 
    p_7_out_i_49
       (.I0(p_0_in__0_n_104),
        .I1(p_0_in__0_n_96),
        .I2(p_0_in__0_n_97),
        .I3(p_0_in__0_n_105),
        .O(p_7_out_i_49_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_7_out_i_5
       (.CI(p_7_out_i_6_n_0),
        .CO({p_7_out_i_5_n_0,p_7_out_i_5_n_1,p_7_out_i_5_n_2,p_7_out_i_5_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_7_out_i_34_n_0,p_7_out_i_35_n_0,p_7_out_i_36_n_0,p_7_out_i_37_n_0}),
        .O({p_7_out_i_5_n_4,p_7_out_i_5_n_5,p_7_out_i_5_n_6,p_7_out_i_5_n_7}),
        .S({p_7_out_i_38_n_0,p_7_out_i_39_n_0,p_7_out_i_40_n_0,p_7_out_i_41_n_0}));
  CARRY4 p_7_out_i_50
       (.CI(p_7_out_i_51_n_0),
        .CO({p_7_out_i_50_n_1,NLW_p_7_out_i_50_CO_UNCONNECTED[1],p_7_out_i_50_n_3}),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,p_0_in__0_n_91,p_0_in__0_n_90}),
        .O({p_7_out_i_50_n_6,p_7_out_i_50_n_7}),
        .S({\<const0> ,\<const1> ,p_7_out_i_55_n_0,p_7_out_i_56_n_0}));
  CARRY4 p_7_out_i_51
       (.CI(p_7_out_i_52_n_0),
        .CO({p_7_out_i_51_n_0,p_7_out_i_51_n_1,p_7_out_i_51_n_2,p_7_out_i_51_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in__0_n_92,p_0_in__0_n_93,p_0_in__0_n_94,p_0_in__0_n_95}),
        .O({p_7_out_i_51_n_4,p_7_out_i_51_n_5,p_7_out_i_51_n_6,p_7_out_i_51_n_7}),
        .S({p_7_out_i_57_n_0,p_7_out_i_58_n_0,p_7_out_i_59_n_0,p_7_out_i_60_n_0}));
  CARRY4 p_7_out_i_52
       (.CI(p_7_out_i_53_n_0),
        .CO({p_7_out_i_52_n_0,p_7_out_i_52_n_1,p_7_out_i_52_n_2,p_7_out_i_52_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in__0_n_96,p_0_in__0_n_97,p_0_in__0_n_98,p_0_in__0_n_99}),
        .O({p_7_out_i_52_n_4,p_7_out_i_52_n_5,p_7_out_i_52_n_6,p_7_out_i_52_n_7}),
        .S({p_7_out_i_61_n_0,p_7_out_i_62_n_0,p_7_out_i_63_n_0,p_7_out_i_64_n_0}));
  CARRY4 p_7_out_i_53
       (.CI(p_7_out_i_54_n_0),
        .CO({p_7_out_i_53_n_0,p_7_out_i_53_n_1,p_7_out_i_53_n_2,p_7_out_i_53_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in__0_n_100,p_0_in__0_n_101,p_0_in__0_n_102,p_0_in__0_n_103}),
        .O({p_7_out_i_53_n_4,p_7_out_i_53_n_5,p_7_out_i_53_n_6,p_7_out_i_53_n_7}),
        .S({p_7_out_i_65_n_0,p_7_out_i_66_n_0,p_7_out_i_67_n_0,p_7_out_i_68_n_0}));
  CARRY4 p_7_out_i_54
       (.CI(\<const0> ),
        .CO({p_7_out_i_54_n_0,p_7_out_i_54_n_1,p_7_out_i_54_n_2,p_7_out_i_54_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_0_in__0_n_104,p_0_in__0_n_105,\<const0> ,\<const1> }),
        .O({p_7_out_i_54_n_4,p_7_out_i_54_n_5,p_7_out_i_54_n_6,p_7_out_i_54_n_7}),
        .S({p_7_out_i_69_n_0,p_7_out_i_70_n_0,p_7_out_i_71_n_0,p_0_in__0_n_105}));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_55
       (.I0(p_0_in__0_n_91),
        .I1(p_0_in__0_n_90),
        .O(p_7_out_i_55_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_56
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_91),
        .O(p_7_out_i_56_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_57
       (.I0(p_0_in__0_n_90),
        .I1(p_0_in__0_n_92),
        .O(p_7_out_i_57_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_58
       (.I0(p_0_in__0_n_93),
        .I1(p_0_in__0_n_91),
        .O(p_7_out_i_58_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_59
       (.I0(p_0_in__0_n_94),
        .I1(p_0_in__0_n_92),
        .O(p_7_out_i_59_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 p_7_out_i_6
       (.CI(\<const0> ),
        .CO({p_7_out_i_6_n_0,p_7_out_i_6_n_1,p_7_out_i_6_n_2,p_7_out_i_6_n_3}),
        .CYINIT(\<const0> ),
        .DI({p_7_out_i_42_n_0,p_7_out_i_43_n_0,p_7_out_i_44_n_0,p_7_out_i_45_n_0}),
        .O({p_7_out_i_6_n_4,p_7_out_i_6_n_5,p_7_out_i_6_n_6,p_7_out_i_6_n_7}),
        .S({p_7_out_i_46_n_0,p_7_out_i_47_n_0,p_7_out_i_48_n_0,p_7_out_i_49_n_0}));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_60
       (.I0(p_0_in__0_n_95),
        .I1(p_0_in__0_n_93),
        .O(p_7_out_i_60_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_61
       (.I0(p_0_in__0_n_96),
        .I1(p_0_in__0_n_94),
        .O(p_7_out_i_61_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_62
       (.I0(p_0_in__0_n_97),
        .I1(p_0_in__0_n_95),
        .O(p_7_out_i_62_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_63
       (.I0(p_0_in__0_n_98),
        .I1(p_0_in__0_n_96),
        .O(p_7_out_i_63_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_64
       (.I0(p_0_in__0_n_99),
        .I1(p_0_in__0_n_97),
        .O(p_7_out_i_64_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_65
       (.I0(p_0_in__0_n_100),
        .I1(p_0_in__0_n_98),
        .O(p_7_out_i_65_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_66
       (.I0(p_0_in__0_n_101),
        .I1(p_0_in__0_n_99),
        .O(p_7_out_i_66_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_67
       (.I0(p_0_in__0_n_102),
        .I1(p_0_in__0_n_100),
        .O(p_7_out_i_67_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_68
       (.I0(p_0_in__0_n_103),
        .I1(p_0_in__0_n_101),
        .O(p_7_out_i_68_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_69
       (.I0(p_0_in__0_n_104),
        .I1(p_0_in__0_n_102),
        .O(p_7_out_i_69_n_0));
  LUT2 #(
    .INIT(4'h6)) 
    p_7_out_i_7
       (.I0(p_0_in__0_n_97),
        .I1(p_0_in__0_n_105),
        .O(p_7_out_i_7_n_0));
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_70
       (.I0(p_0_in__0_n_105),
        .I1(p_0_in__0_n_103),
        .O(p_7_out_i_70_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    p_7_out_i_71
       (.I0(p_0_in__0_n_104),
        .O(p_7_out_i_71_n_0));
  (* HLUTNM = "lutpair39" *) 
  LUT1 #(
    .INIT(2'h2)) 
    p_7_out_i_8
       (.I0(p_0_in__0_n_90),
        .O(p_7_out_i_8_n_0));
  (* HLUTNM = "lutpair39" *) 
  LUT2 #(
    .INIT(4'h9)) 
    p_7_out_i_9
       (.I0(p_7_out_i_50_n_1),
        .I1(p_7_out_i_8_n_0),
        .O(p_7_out_i_9_n_0));
  IBUF \read_addr_IBUF[0]_inst 
       (.I(read_addr[0]),
        .O(read_addr_IBUF[0]));
  IBUF \read_addr_IBUF[1]_inst 
       (.I(read_addr[1]),
        .O(read_addr_IBUF[1]));
  IBUF \read_addr_IBUF[2]_inst 
       (.I(read_addr[2]),
        .O(read_addr_IBUF[2]));
  IBUF \read_addr_IBUF[3]_inst 
       (.I(read_addr[3]),
        .O(read_addr_IBUF[3]));
  OBUF \read_data_OBUF[0]_inst 
       (.I(read_data_OBUF[0]),
        .O(read_data[0]));
  MUXF8 \read_data_OBUF[0]_inst_i_1 
       (.I0(\read_data_OBUF[0]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[0]_inst_i_3_n_0 ),
        .O(read_data_OBUF[0]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[0]_inst_i_2 
       (.I0(\read_data_OBUF[0]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[0]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[0]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[0]_inst_i_3 
       (.I0(\read_data_OBUF[0]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[0]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[0]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[0]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][0] ),
        .I1(\coeff_reg_n_0_[2][0] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][0] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][0] ),
        .O(\read_data_OBUF[0]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[0]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][0] ),
        .I1(\coeff_reg_n_0_[6][0] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][0] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][0] ),
        .O(\read_data_OBUF[0]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[0]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][0] ),
        .I1(\coeff_reg_n_0_[10][0] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][0] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][0] ),
        .O(\read_data_OBUF[0]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[0]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][0] ),
        .I1(\coeff_reg_n_0_[14][0] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][0] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][0] ),
        .O(\read_data_OBUF[0]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[10]_inst 
       (.I(read_data_OBUF[10]),
        .O(read_data[10]));
  MUXF8 \read_data_OBUF[10]_inst_i_1 
       (.I0(\read_data_OBUF[10]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[10]_inst_i_3_n_0 ),
        .O(read_data_OBUF[10]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[10]_inst_i_2 
       (.I0(\read_data_OBUF[10]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[10]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[10]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[10]_inst_i_3 
       (.I0(\read_data_OBUF[10]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[10]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[10]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[10]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][10] ),
        .I1(\coeff_reg_n_0_[2][10] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][10] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][10] ),
        .O(\read_data_OBUF[10]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[10]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][10] ),
        .I1(\coeff_reg_n_0_[6][10] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][10] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][10] ),
        .O(\read_data_OBUF[10]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[10]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][10] ),
        .I1(\coeff_reg_n_0_[10][10] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][10] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][10] ),
        .O(\read_data_OBUF[10]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[10]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][10] ),
        .I1(\coeff_reg_n_0_[14][10] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][10] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][10] ),
        .O(\read_data_OBUF[10]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[11]_inst 
       (.I(read_data_OBUF[11]),
        .O(read_data[11]));
  MUXF8 \read_data_OBUF[11]_inst_i_1 
       (.I0(\read_data_OBUF[11]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[11]_inst_i_3_n_0 ),
        .O(read_data_OBUF[11]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[11]_inst_i_2 
       (.I0(\read_data_OBUF[11]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[11]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[11]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[11]_inst_i_3 
       (.I0(\read_data_OBUF[11]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[11]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[11]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[11]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][11] ),
        .I1(\coeff_reg_n_0_[2][11] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][11] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][11] ),
        .O(\read_data_OBUF[11]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[11]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][11] ),
        .I1(\coeff_reg_n_0_[6][11] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][11] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][11] ),
        .O(\read_data_OBUF[11]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[11]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][11] ),
        .I1(\coeff_reg_n_0_[10][11] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][11] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][11] ),
        .O(\read_data_OBUF[11]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[11]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][11] ),
        .I1(\coeff_reg_n_0_[14][11] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][11] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][11] ),
        .O(\read_data_OBUF[11]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[12]_inst 
       (.I(read_data_OBUF[12]),
        .O(read_data[12]));
  MUXF8 \read_data_OBUF[12]_inst_i_1 
       (.I0(\read_data_OBUF[12]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[12]_inst_i_3_n_0 ),
        .O(read_data_OBUF[12]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[12]_inst_i_2 
       (.I0(\read_data_OBUF[12]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[12]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[12]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[12]_inst_i_3 
       (.I0(\read_data_OBUF[12]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[12]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[12]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[12]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][12] ),
        .I1(\coeff_reg_n_0_[2][12] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][12] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][12] ),
        .O(\read_data_OBUF[12]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[12]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][12] ),
        .I1(\coeff_reg_n_0_[6][12] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][12] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][12] ),
        .O(\read_data_OBUF[12]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[12]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][12] ),
        .I1(\coeff_reg_n_0_[10][12] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][12] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][12] ),
        .O(\read_data_OBUF[12]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[12]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][12] ),
        .I1(\coeff_reg_n_0_[14][12] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][12] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][12] ),
        .O(\read_data_OBUF[12]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[13]_inst 
       (.I(read_data_OBUF[13]),
        .O(read_data[13]));
  MUXF8 \read_data_OBUF[13]_inst_i_1 
       (.I0(\read_data_OBUF[13]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[13]_inst_i_3_n_0 ),
        .O(read_data_OBUF[13]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[13]_inst_i_2 
       (.I0(\read_data_OBUF[13]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[13]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[13]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[13]_inst_i_3 
       (.I0(\read_data_OBUF[13]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[13]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[13]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[13]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][13] ),
        .I1(\coeff_reg_n_0_[2][13] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][13] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][13] ),
        .O(\read_data_OBUF[13]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[13]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][13] ),
        .I1(\coeff_reg_n_0_[6][13] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][13] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][13] ),
        .O(\read_data_OBUF[13]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[13]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][13] ),
        .I1(\coeff_reg_n_0_[10][13] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][13] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][13] ),
        .O(\read_data_OBUF[13]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[13]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][13] ),
        .I1(\coeff_reg_n_0_[14][13] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][13] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][13] ),
        .O(\read_data_OBUF[13]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[14]_inst 
       (.I(read_data_OBUF[14]),
        .O(read_data[14]));
  MUXF8 \read_data_OBUF[14]_inst_i_1 
       (.I0(\read_data_OBUF[14]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[14]_inst_i_3_n_0 ),
        .O(read_data_OBUF[14]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[14]_inst_i_2 
       (.I0(\read_data_OBUF[14]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[14]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[14]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[14]_inst_i_3 
       (.I0(\read_data_OBUF[14]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[14]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[14]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[14]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][14] ),
        .I1(\coeff_reg_n_0_[2][14] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][14] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][14] ),
        .O(\read_data_OBUF[14]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[14]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][14] ),
        .I1(\coeff_reg_n_0_[6][14] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][14] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][14] ),
        .O(\read_data_OBUF[14]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[14]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][14] ),
        .I1(\coeff_reg_n_0_[10][14] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][14] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][14] ),
        .O(\read_data_OBUF[14]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[14]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][14] ),
        .I1(\coeff_reg_n_0_[14][14] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][14] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][14] ),
        .O(\read_data_OBUF[14]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[15]_inst 
       (.I(read_data_OBUF[15]),
        .O(read_data[15]));
  MUXF8 \read_data_OBUF[15]_inst_i_1 
       (.I0(\read_data_OBUF[15]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[15]_inst_i_3_n_0 ),
        .O(read_data_OBUF[15]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[15]_inst_i_2 
       (.I0(\read_data_OBUF[15]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[15]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[15]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[15]_inst_i_3 
       (.I0(\read_data_OBUF[15]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[15]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[15]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[15]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][15] ),
        .I1(\coeff_reg_n_0_[2][15] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][15] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][15] ),
        .O(\read_data_OBUF[15]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[15]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][15] ),
        .I1(\coeff_reg_n_0_[6][15] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][15] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][15] ),
        .O(\read_data_OBUF[15]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[15]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][15] ),
        .I1(\coeff_reg_n_0_[10][15] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][15] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][15] ),
        .O(\read_data_OBUF[15]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[15]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][15] ),
        .I1(\coeff_reg_n_0_[14][15] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][15] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][15] ),
        .O(\read_data_OBUF[15]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[1]_inst 
       (.I(read_data_OBUF[1]),
        .O(read_data[1]));
  MUXF8 \read_data_OBUF[1]_inst_i_1 
       (.I0(\read_data_OBUF[1]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[1]_inst_i_3_n_0 ),
        .O(read_data_OBUF[1]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[1]_inst_i_2 
       (.I0(\read_data_OBUF[1]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[1]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[1]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[1]_inst_i_3 
       (.I0(\read_data_OBUF[1]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[1]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[1]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[1]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][1] ),
        .I1(\coeff_reg_n_0_[2][1] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][1] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][1] ),
        .O(\read_data_OBUF[1]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[1]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][1] ),
        .I1(\coeff_reg_n_0_[6][1] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][1] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][1] ),
        .O(\read_data_OBUF[1]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[1]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][1] ),
        .I1(\coeff_reg_n_0_[10][1] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][1] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][1] ),
        .O(\read_data_OBUF[1]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[1]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][1] ),
        .I1(\coeff_reg_n_0_[14][1] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][1] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][1] ),
        .O(\read_data_OBUF[1]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[2]_inst 
       (.I(read_data_OBUF[2]),
        .O(read_data[2]));
  MUXF8 \read_data_OBUF[2]_inst_i_1 
       (.I0(\read_data_OBUF[2]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[2]_inst_i_3_n_0 ),
        .O(read_data_OBUF[2]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[2]_inst_i_2 
       (.I0(\read_data_OBUF[2]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[2]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[2]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[2]_inst_i_3 
       (.I0(\read_data_OBUF[2]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[2]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[2]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[2]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][2] ),
        .I1(\coeff_reg_n_0_[2][2] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][2] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][2] ),
        .O(\read_data_OBUF[2]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[2]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][2] ),
        .I1(\coeff_reg_n_0_[6][2] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][2] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][2] ),
        .O(\read_data_OBUF[2]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[2]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][2] ),
        .I1(\coeff_reg_n_0_[10][2] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][2] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][2] ),
        .O(\read_data_OBUF[2]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[2]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][2] ),
        .I1(\coeff_reg_n_0_[14][2] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][2] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][2] ),
        .O(\read_data_OBUF[2]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[3]_inst 
       (.I(read_data_OBUF[3]),
        .O(read_data[3]));
  MUXF8 \read_data_OBUF[3]_inst_i_1 
       (.I0(\read_data_OBUF[3]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[3]_inst_i_3_n_0 ),
        .O(read_data_OBUF[3]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[3]_inst_i_2 
       (.I0(\read_data_OBUF[3]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[3]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[3]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[3]_inst_i_3 
       (.I0(\read_data_OBUF[3]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[3]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[3]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[3]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][3] ),
        .I1(\coeff_reg_n_0_[2][3] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][3] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][3] ),
        .O(\read_data_OBUF[3]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[3]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][3] ),
        .I1(\coeff_reg_n_0_[6][3] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][3] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][3] ),
        .O(\read_data_OBUF[3]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[3]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][3] ),
        .I1(\coeff_reg_n_0_[10][3] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][3] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][3] ),
        .O(\read_data_OBUF[3]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[3]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][3] ),
        .I1(\coeff_reg_n_0_[14][3] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][3] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][3] ),
        .O(\read_data_OBUF[3]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[4]_inst 
       (.I(read_data_OBUF[4]),
        .O(read_data[4]));
  MUXF8 \read_data_OBUF[4]_inst_i_1 
       (.I0(\read_data_OBUF[4]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[4]_inst_i_3_n_0 ),
        .O(read_data_OBUF[4]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[4]_inst_i_2 
       (.I0(\read_data_OBUF[4]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[4]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[4]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[4]_inst_i_3 
       (.I0(\read_data_OBUF[4]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[4]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[4]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[4]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][4] ),
        .I1(\coeff_reg_n_0_[2][4] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][4] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][4] ),
        .O(\read_data_OBUF[4]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[4]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][4] ),
        .I1(\coeff_reg_n_0_[6][4] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][4] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][4] ),
        .O(\read_data_OBUF[4]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[4]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][4] ),
        .I1(\coeff_reg_n_0_[10][4] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][4] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][4] ),
        .O(\read_data_OBUF[4]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[4]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][4] ),
        .I1(\coeff_reg_n_0_[14][4] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][4] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][4] ),
        .O(\read_data_OBUF[4]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[5]_inst 
       (.I(read_data_OBUF[5]),
        .O(read_data[5]));
  MUXF8 \read_data_OBUF[5]_inst_i_1 
       (.I0(\read_data_OBUF[5]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[5]_inst_i_3_n_0 ),
        .O(read_data_OBUF[5]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[5]_inst_i_2 
       (.I0(\read_data_OBUF[5]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[5]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[5]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[5]_inst_i_3 
       (.I0(\read_data_OBUF[5]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[5]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[5]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[5]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][5] ),
        .I1(\coeff_reg_n_0_[2][5] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][5] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][5] ),
        .O(\read_data_OBUF[5]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[5]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][5] ),
        .I1(\coeff_reg_n_0_[6][5] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][5] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][5] ),
        .O(\read_data_OBUF[5]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[5]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][5] ),
        .I1(\coeff_reg_n_0_[10][5] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][5] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][5] ),
        .O(\read_data_OBUF[5]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[5]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][5] ),
        .I1(\coeff_reg_n_0_[14][5] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][5] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][5] ),
        .O(\read_data_OBUF[5]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[6]_inst 
       (.I(read_data_OBUF[6]),
        .O(read_data[6]));
  MUXF8 \read_data_OBUF[6]_inst_i_1 
       (.I0(\read_data_OBUF[6]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[6]_inst_i_3_n_0 ),
        .O(read_data_OBUF[6]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[6]_inst_i_2 
       (.I0(\read_data_OBUF[6]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[6]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[6]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[6]_inst_i_3 
       (.I0(\read_data_OBUF[6]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[6]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[6]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[6]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][6] ),
        .I1(\coeff_reg_n_0_[2][6] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][6] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][6] ),
        .O(\read_data_OBUF[6]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[6]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][6] ),
        .I1(\coeff_reg_n_0_[6][6] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][6] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][6] ),
        .O(\read_data_OBUF[6]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[6]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][6] ),
        .I1(\coeff_reg_n_0_[10][6] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][6] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][6] ),
        .O(\read_data_OBUF[6]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[6]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][6] ),
        .I1(\coeff_reg_n_0_[14][6] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][6] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][6] ),
        .O(\read_data_OBUF[6]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[7]_inst 
       (.I(read_data_OBUF[7]),
        .O(read_data[7]));
  MUXF8 \read_data_OBUF[7]_inst_i_1 
       (.I0(\read_data_OBUF[7]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[7]_inst_i_3_n_0 ),
        .O(read_data_OBUF[7]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[7]_inst_i_2 
       (.I0(\read_data_OBUF[7]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[7]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[7]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[7]_inst_i_3 
       (.I0(\read_data_OBUF[7]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[7]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[7]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[7]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][7] ),
        .I1(\coeff_reg_n_0_[2][7] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][7] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][7] ),
        .O(\read_data_OBUF[7]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[7]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][7] ),
        .I1(\coeff_reg_n_0_[6][7] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][7] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][7] ),
        .O(\read_data_OBUF[7]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[7]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][7] ),
        .I1(\coeff_reg_n_0_[10][7] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][7] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][7] ),
        .O(\read_data_OBUF[7]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[7]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][7] ),
        .I1(\coeff_reg_n_0_[14][7] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][7] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][7] ),
        .O(\read_data_OBUF[7]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[8]_inst 
       (.I(read_data_OBUF[8]),
        .O(read_data[8]));
  MUXF8 \read_data_OBUF[8]_inst_i_1 
       (.I0(\read_data_OBUF[8]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[8]_inst_i_3_n_0 ),
        .O(read_data_OBUF[8]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[8]_inst_i_2 
       (.I0(\read_data_OBUF[8]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[8]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[8]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[8]_inst_i_3 
       (.I0(\read_data_OBUF[8]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[8]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[8]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[8]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][8] ),
        .I1(\coeff_reg_n_0_[2][8] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][8] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][8] ),
        .O(\read_data_OBUF[8]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[8]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][8] ),
        .I1(\coeff_reg_n_0_[6][8] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][8] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][8] ),
        .O(\read_data_OBUF[8]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[8]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][8] ),
        .I1(\coeff_reg_n_0_[10][8] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][8] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][8] ),
        .O(\read_data_OBUF[8]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[8]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][8] ),
        .I1(\coeff_reg_n_0_[14][8] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][8] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][8] ),
        .O(\read_data_OBUF[8]_inst_i_7_n_0 ));
  OBUF \read_data_OBUF[9]_inst 
       (.I(read_data_OBUF[9]),
        .O(read_data[9]));
  MUXF8 \read_data_OBUF[9]_inst_i_1 
       (.I0(\read_data_OBUF[9]_inst_i_2_n_0 ),
        .I1(\read_data_OBUF[9]_inst_i_3_n_0 ),
        .O(read_data_OBUF[9]),
        .S(read_addr_IBUF[3]));
  MUXF7 \read_data_OBUF[9]_inst_i_2 
       (.I0(\read_data_OBUF[9]_inst_i_4_n_0 ),
        .I1(\read_data_OBUF[9]_inst_i_5_n_0 ),
        .O(\read_data_OBUF[9]_inst_i_2_n_0 ),
        .S(read_addr_IBUF[2]));
  MUXF7 \read_data_OBUF[9]_inst_i_3 
       (.I0(\read_data_OBUF[9]_inst_i_6_n_0 ),
        .I1(\read_data_OBUF[9]_inst_i_7_n_0 ),
        .O(\read_data_OBUF[9]_inst_i_3_n_0 ),
        .S(read_addr_IBUF[2]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[9]_inst_i_4 
       (.I0(\coeff_reg_n_0_[3][9] ),
        .I1(\coeff_reg_n_0_[2][9] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[1][9] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[0][9] ),
        .O(\read_data_OBUF[9]_inst_i_4_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[9]_inst_i_5 
       (.I0(\coeff_reg_n_0_[7][9] ),
        .I1(\coeff_reg_n_0_[6][9] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[5][9] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[4][9] ),
        .O(\read_data_OBUF[9]_inst_i_5_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[9]_inst_i_6 
       (.I0(\coeff_reg_n_0_[11][9] ),
        .I1(\coeff_reg_n_0_[10][9] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[9][9] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[8][9] ),
        .O(\read_data_OBUF[9]_inst_i_6_n_0 ));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \read_data_OBUF[9]_inst_i_7 
       (.I0(\coeff_reg_n_0_[15][9] ),
        .I1(\coeff_reg_n_0_[14][9] ),
        .I2(read_addr_IBUF[1]),
        .I3(\coeff_reg_n_0_[13][9] ),
        .I4(read_addr_IBUF[0]),
        .I5(\coeff_reg_n_0_[12][9] ),
        .O(\read_data_OBUF[9]_inst_i_7_n_0 ));
  IBUF rst_n_IBUF_inst
       (.I(rst_n),
        .O(rst_n_IBUF));
  IBUF start_IBUF_inst
       (.I(start),
        .O(start_IBUF));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(0),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    unamedDSP
       (.A({unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_4,unamedDSP_i_1_n_5,unamedDSP_i_1_n_6,unamedDSP_i_1_n_7,unamedDSP_i_2_n_4,unamedDSP_i_2_n_5,unamedDSP_i_2_n_6,unamedDSP_i_2_n_7,unamedDSP_i_3_n_4,unamedDSP_i_3_n_5,unamedDSP_i_3_n_6,unamedDSP_i_3_n_7,unamedDSP_i_4_n_4,unamedDSP_i_4_n_5,unamedDSP_i_4_n_6,unamedDSP_i_4_n_7}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .B({\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const0> ,\<const1> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const1> ,\<const1> ,\<const1> ,\<const1> ,\<const1> ,\<const1> }),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const0> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({unamedDSP_n_75,unamedDSP_n_76,unamedDSP_n_77,unamedDSP_n_78,unamedDSP_n_79,unamedDSP_n_80,unamedDSP_n_81,unamedDSP_n_82,unamedDSP_n_83,unamedDSP_n_84,unamedDSP_n_85,unamedDSP_n_86,unamedDSP_n_87,unamedDSP_n_88,unamedDSP_n_89,unamedDSP_n_90,unamedDSP_n_91,unamedDSP_n_92,unamedDSP_n_93,unamedDSP_n_94,unamedDSP_n_95,unamedDSP_n_96,unamedDSP_n_97,unamedDSP_n_98,unamedDSP_n_99,unamedDSP_n_100,unamedDSP_n_101,unamedDSP_n_102,unamedDSP_n_103,unamedDSP_n_104,unamedDSP_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    unamedDSP__0
       (.A({unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_75,unamedDSP_n_76,unamedDSP_n_77,unamedDSP_n_78,unamedDSP_n_79}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .B({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const0> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({unamedDSP__0_n_76,unamedDSP__0_n_77,unamedDSP__0_n_78,unamedDSP__0_n_79,unamedDSP__0_n_80,unamedDSP__0_n_81,unamedDSP__0_n_82,unamedDSP__0_n_83,unamedDSP__0_n_84,unamedDSP__0_n_85,unamedDSP__0_n_86,unamedDSP__0_n_87,unamedDSP__0_n_88,unamedDSP__0_n_89,unamedDSP__0_n_90,unamedDSP__0_n_91,unamedDSP__0_n_92,unamedDSP__0_n_93,unamedDSP__0_n_94,unamedDSP__0_n_95,unamedDSP__0_n_96,unamedDSP__0_n_97,unamedDSP__0_n_98,unamedDSP__0_n_99,unamedDSP__0_n_100,unamedDSP__0_n_101,unamedDSP__0_n_102,unamedDSP__0_n_103,unamedDSP__0_n_104,unamedDSP__0_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(0),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    unamedDSP__1
       (.A({unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_1_n_0,unamedDSP__1_i_2_n_0,unamedDSP__1_i_3_n_0,unamedDSP__1_i_4_n_0,unamedDSP__1_i_5_n_0,unamedDSP__1_i_6_n_0,unamedDSP__1_i_7_n_0,unamedDSP__1_i_8_n_0,unamedDSP__1_i_9_n_0,unamedDSP__1_i_10_n_0,unamedDSP__1_i_11_n_0,unamedDSP__1_i_12_n_0,unamedDSP__1_i_13_n_0,unamedDSP__1_i_14_n_0,unamedDSP__1_i_15_n_0,unamedDSP__1_i_16_n_0}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .B({\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const0> ,\<const1> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const1> ,\<const1> ,\<const1> ,\<const1> ,\<const1> ,\<const1> }),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const0> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({unamedDSP__1_n_75,unamedDSP__1_n_76,unamedDSP__1_n_77,unamedDSP__1_n_78,unamedDSP__1_n_79,unamedDSP__1_n_80,unamedDSP__1_n_81,unamedDSP__1_n_82,unamedDSP__1_n_83,unamedDSP__1_n_84,unamedDSP__1_n_85,unamedDSP__1_n_86,unamedDSP__1_n_87,unamedDSP__1_n_88,unamedDSP__1_n_89,unamedDSP__1_n_90,unamedDSP__1_n_91,unamedDSP__1_n_92,unamedDSP__1_n_93,unamedDSP__1_n_94,unamedDSP__1_n_95,unamedDSP__1_n_96,unamedDSP__1_n_97,unamedDSP__1_n_98,unamedDSP__1_n_99,unamedDSP__1_n_100,unamedDSP__1_n_101,unamedDSP__1_n_102,unamedDSP__1_n_103,unamedDSP__1_n_104,unamedDSP__1_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP__1_i_1
       (.I0(unamedDSP__1_i_17_n_0),
        .O(unamedDSP__1_i_1_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_10
       (.I0(unamedDSP__1_i_50_n_0),
        .I1(unamedDSP__1_i_51_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_52_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_53_n_0),
        .O(unamedDSP__1_i_10_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_11
       (.I0(unamedDSP__1_i_54_n_0),
        .I1(unamedDSP__1_i_55_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_56_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_57_n_0),
        .O(unamedDSP__1_i_11_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_12
       (.I0(unamedDSP__1_i_58_n_0),
        .I1(unamedDSP__1_i_59_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_60_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_61_n_0),
        .O(unamedDSP__1_i_12_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_13
       (.I0(unamedDSP__1_i_62_n_0),
        .I1(unamedDSP__1_i_63_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_64_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_65_n_0),
        .O(unamedDSP__1_i_13_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_14
       (.I0(unamedDSP__1_i_66_n_0),
        .I1(unamedDSP__1_i_67_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_68_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_69_n_0),
        .O(unamedDSP__1_i_14_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_15
       (.I0(unamedDSP__1_i_70_n_0),
        .I1(unamedDSP__1_i_71_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_72_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_73_n_0),
        .O(unamedDSP__1_i_15_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_16
       (.I0(unamedDSP__1_i_74_n_0),
        .I1(unamedDSP__1_i_75_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_76_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_77_n_0),
        .O(unamedDSP__1_i_16_n_0));
  LUT6 #(
    .INIT(64'h0F0055330FFF5533)) 
    unamedDSP__1_i_17
       (.I0(unamedDSP__1_i_78_n_0),
        .I1(unamedDSP__1_i_79_n_0),
        .I2(unamedDSP__1_i_80_n_0),
        .I3(\cnt_reg_n_0_[2] ),
        .I4(\cnt_reg_n_0_[3] ),
        .I5(unamedDSP__1_i_81_n_0),
        .O(unamedDSP__1_i_17_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_18
       (.I0(\coeff_reg_n_0_[15][14] ),
        .I1(\coeff_reg_n_0_[14][14] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][14] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][14] ),
        .O(unamedDSP__1_i_18_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_19
       (.I0(\coeff_reg_n_0_[11][14] ),
        .I1(\coeff_reg_n_0_[10][14] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][14] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][14] ),
        .O(unamedDSP__1_i_19_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_2
       (.I0(unamedDSP__1_i_18_n_0),
        .I1(unamedDSP__1_i_19_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_20_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_21_n_0),
        .O(unamedDSP__1_i_2_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_20
       (.I0(\coeff_reg_n_0_[7][14] ),
        .I1(\coeff_reg_n_0_[6][14] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][14] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][14] ),
        .O(unamedDSP__1_i_20_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_21
       (.I0(\coeff_reg_n_0_[3][14] ),
        .I1(\coeff_reg_n_0_[2][14] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][14] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][14] ),
        .O(unamedDSP__1_i_21_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_22
       (.I0(\coeff_reg_n_0_[15][13] ),
        .I1(\coeff_reg_n_0_[14][13] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][13] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][13] ),
        .O(unamedDSP__1_i_22_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_23
       (.I0(\coeff_reg_n_0_[11][13] ),
        .I1(\coeff_reg_n_0_[10][13] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][13] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][13] ),
        .O(unamedDSP__1_i_23_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_24
       (.I0(\coeff_reg_n_0_[7][13] ),
        .I1(\coeff_reg_n_0_[6][13] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][13] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][13] ),
        .O(unamedDSP__1_i_24_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_25
       (.I0(\coeff_reg_n_0_[3][13] ),
        .I1(\coeff_reg_n_0_[2][13] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][13] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][13] ),
        .O(unamedDSP__1_i_25_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_26
       (.I0(\coeff_reg_n_0_[15][12] ),
        .I1(\coeff_reg_n_0_[14][12] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][12] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][12] ),
        .O(unamedDSP__1_i_26_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_27
       (.I0(\coeff_reg_n_0_[11][12] ),
        .I1(\coeff_reg_n_0_[10][12] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][12] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][12] ),
        .O(unamedDSP__1_i_27_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_28
       (.I0(\coeff_reg_n_0_[7][12] ),
        .I1(\coeff_reg_n_0_[6][12] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][12] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][12] ),
        .O(unamedDSP__1_i_28_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_29
       (.I0(\coeff_reg_n_0_[3][12] ),
        .I1(\coeff_reg_n_0_[2][12] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][12] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][12] ),
        .O(unamedDSP__1_i_29_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_3
       (.I0(unamedDSP__1_i_22_n_0),
        .I1(unamedDSP__1_i_23_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_24_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_25_n_0),
        .O(unamedDSP__1_i_3_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_30
       (.I0(\coeff_reg_n_0_[15][11] ),
        .I1(\coeff_reg_n_0_[14][11] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][11] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][11] ),
        .O(unamedDSP__1_i_30_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_31
       (.I0(\coeff_reg_n_0_[11][11] ),
        .I1(\coeff_reg_n_0_[10][11] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][11] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][11] ),
        .O(unamedDSP__1_i_31_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_32
       (.I0(\coeff_reg_n_0_[7][11] ),
        .I1(\coeff_reg_n_0_[6][11] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][11] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][11] ),
        .O(unamedDSP__1_i_32_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_33
       (.I0(\coeff_reg_n_0_[3][11] ),
        .I1(\coeff_reg_n_0_[2][11] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][11] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][11] ),
        .O(unamedDSP__1_i_33_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_34
       (.I0(\coeff_reg_n_0_[15][10] ),
        .I1(\coeff_reg_n_0_[14][10] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][10] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][10] ),
        .O(unamedDSP__1_i_34_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_35
       (.I0(\coeff_reg_n_0_[11][10] ),
        .I1(\coeff_reg_n_0_[10][10] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][10] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][10] ),
        .O(unamedDSP__1_i_35_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_36
       (.I0(\coeff_reg_n_0_[7][10] ),
        .I1(\coeff_reg_n_0_[6][10] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][10] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][10] ),
        .O(unamedDSP__1_i_36_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_37
       (.I0(\coeff_reg_n_0_[3][10] ),
        .I1(\coeff_reg_n_0_[2][10] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][10] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][10] ),
        .O(unamedDSP__1_i_37_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_38
       (.I0(\coeff_reg_n_0_[15][9] ),
        .I1(\coeff_reg_n_0_[14][9] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][9] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][9] ),
        .O(unamedDSP__1_i_38_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_39
       (.I0(\coeff_reg_n_0_[11][9] ),
        .I1(\coeff_reg_n_0_[10][9] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][9] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][9] ),
        .O(unamedDSP__1_i_39_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_4
       (.I0(unamedDSP__1_i_26_n_0),
        .I1(unamedDSP__1_i_27_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_28_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_29_n_0),
        .O(unamedDSP__1_i_4_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_40
       (.I0(\coeff_reg_n_0_[7][9] ),
        .I1(\coeff_reg_n_0_[6][9] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][9] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][9] ),
        .O(unamedDSP__1_i_40_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_41
       (.I0(\coeff_reg_n_0_[3][9] ),
        .I1(\coeff_reg_n_0_[2][9] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][9] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][9] ),
        .O(unamedDSP__1_i_41_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_42
       (.I0(\coeff_reg_n_0_[15][8] ),
        .I1(\coeff_reg_n_0_[14][8] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][8] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][8] ),
        .O(unamedDSP__1_i_42_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_43
       (.I0(\coeff_reg_n_0_[11][8] ),
        .I1(\coeff_reg_n_0_[10][8] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][8] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][8] ),
        .O(unamedDSP__1_i_43_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_44
       (.I0(\coeff_reg_n_0_[7][8] ),
        .I1(\coeff_reg_n_0_[6][8] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][8] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][8] ),
        .O(unamedDSP__1_i_44_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_45
       (.I0(\coeff_reg_n_0_[3][8] ),
        .I1(\coeff_reg_n_0_[2][8] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][8] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][8] ),
        .O(unamedDSP__1_i_45_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_46
       (.I0(\coeff_reg_n_0_[15][7] ),
        .I1(\coeff_reg_n_0_[14][7] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][7] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][7] ),
        .O(unamedDSP__1_i_46_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_47
       (.I0(\coeff_reg_n_0_[11][7] ),
        .I1(\coeff_reg_n_0_[10][7] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][7] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][7] ),
        .O(unamedDSP__1_i_47_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_48
       (.I0(\coeff_reg_n_0_[7][7] ),
        .I1(\coeff_reg_n_0_[6][7] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][7] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][7] ),
        .O(unamedDSP__1_i_48_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_49
       (.I0(\coeff_reg_n_0_[3][7] ),
        .I1(\coeff_reg_n_0_[2][7] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][7] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][7] ),
        .O(unamedDSP__1_i_49_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_5
       (.I0(unamedDSP__1_i_30_n_0),
        .I1(unamedDSP__1_i_31_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_32_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_33_n_0),
        .O(unamedDSP__1_i_5_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_50
       (.I0(\coeff_reg_n_0_[15][6] ),
        .I1(\coeff_reg_n_0_[14][6] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][6] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][6] ),
        .O(unamedDSP__1_i_50_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_51
       (.I0(\coeff_reg_n_0_[11][6] ),
        .I1(\coeff_reg_n_0_[10][6] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][6] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][6] ),
        .O(unamedDSP__1_i_51_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_52
       (.I0(\coeff_reg_n_0_[7][6] ),
        .I1(\coeff_reg_n_0_[6][6] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][6] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][6] ),
        .O(unamedDSP__1_i_52_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_53
       (.I0(\coeff_reg_n_0_[3][6] ),
        .I1(\coeff_reg_n_0_[2][6] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][6] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][6] ),
        .O(unamedDSP__1_i_53_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_54
       (.I0(\coeff_reg_n_0_[15][5] ),
        .I1(\coeff_reg_n_0_[14][5] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][5] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][5] ),
        .O(unamedDSP__1_i_54_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_55
       (.I0(\coeff_reg_n_0_[11][5] ),
        .I1(\coeff_reg_n_0_[10][5] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][5] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][5] ),
        .O(unamedDSP__1_i_55_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_56
       (.I0(\coeff_reg_n_0_[7][5] ),
        .I1(\coeff_reg_n_0_[6][5] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][5] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][5] ),
        .O(unamedDSP__1_i_56_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_57
       (.I0(\coeff_reg_n_0_[3][5] ),
        .I1(\coeff_reg_n_0_[2][5] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][5] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][5] ),
        .O(unamedDSP__1_i_57_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_58
       (.I0(\coeff_reg_n_0_[15][4] ),
        .I1(\coeff_reg_n_0_[14][4] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][4] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][4] ),
        .O(unamedDSP__1_i_58_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_59
       (.I0(\coeff_reg_n_0_[11][4] ),
        .I1(\coeff_reg_n_0_[10][4] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][4] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][4] ),
        .O(unamedDSP__1_i_59_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_6
       (.I0(unamedDSP__1_i_34_n_0),
        .I1(unamedDSP__1_i_35_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_36_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_37_n_0),
        .O(unamedDSP__1_i_6_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_60
       (.I0(\coeff_reg_n_0_[7][4] ),
        .I1(\coeff_reg_n_0_[6][4] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][4] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][4] ),
        .O(unamedDSP__1_i_60_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_61
       (.I0(\coeff_reg_n_0_[3][4] ),
        .I1(\coeff_reg_n_0_[2][4] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][4] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][4] ),
        .O(unamedDSP__1_i_61_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_62
       (.I0(\coeff_reg_n_0_[15][3] ),
        .I1(\coeff_reg_n_0_[14][3] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][3] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][3] ),
        .O(unamedDSP__1_i_62_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_63
       (.I0(\coeff_reg_n_0_[11][3] ),
        .I1(\coeff_reg_n_0_[10][3] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][3] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][3] ),
        .O(unamedDSP__1_i_63_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_64
       (.I0(\coeff_reg_n_0_[7][3] ),
        .I1(\coeff_reg_n_0_[6][3] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][3] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][3] ),
        .O(unamedDSP__1_i_64_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_65
       (.I0(\coeff_reg_n_0_[3][3] ),
        .I1(\coeff_reg_n_0_[2][3] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][3] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][3] ),
        .O(unamedDSP__1_i_65_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_66
       (.I0(\coeff_reg_n_0_[15][2] ),
        .I1(\coeff_reg_n_0_[14][2] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][2] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][2] ),
        .O(unamedDSP__1_i_66_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_67
       (.I0(\coeff_reg_n_0_[11][2] ),
        .I1(\coeff_reg_n_0_[10][2] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][2] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][2] ),
        .O(unamedDSP__1_i_67_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_68
       (.I0(\coeff_reg_n_0_[7][2] ),
        .I1(\coeff_reg_n_0_[6][2] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][2] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][2] ),
        .O(unamedDSP__1_i_68_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_69
       (.I0(\coeff_reg_n_0_[3][2] ),
        .I1(\coeff_reg_n_0_[2][2] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][2] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][2] ),
        .O(unamedDSP__1_i_69_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_7
       (.I0(unamedDSP__1_i_38_n_0),
        .I1(unamedDSP__1_i_39_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_40_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_41_n_0),
        .O(unamedDSP__1_i_7_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_70
       (.I0(\coeff_reg_n_0_[15][1] ),
        .I1(\coeff_reg_n_0_[14][1] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][1] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][1] ),
        .O(unamedDSP__1_i_70_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_71
       (.I0(\coeff_reg_n_0_[11][1] ),
        .I1(\coeff_reg_n_0_[10][1] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][1] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][1] ),
        .O(unamedDSP__1_i_71_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_72
       (.I0(\coeff_reg_n_0_[7][1] ),
        .I1(\coeff_reg_n_0_[6][1] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][1] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][1] ),
        .O(unamedDSP__1_i_72_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_73
       (.I0(\coeff_reg_n_0_[3][1] ),
        .I1(\coeff_reg_n_0_[2][1] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][1] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][1] ),
        .O(unamedDSP__1_i_73_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_74
       (.I0(\coeff_reg_n_0_[15][0] ),
        .I1(\coeff_reg_n_0_[14][0] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][0] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][0] ),
        .O(unamedDSP__1_i_74_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_75
       (.I0(\coeff_reg_n_0_[11][0] ),
        .I1(\coeff_reg_n_0_[10][0] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][0] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][0] ),
        .O(unamedDSP__1_i_75_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_76
       (.I0(\coeff_reg_n_0_[7][0] ),
        .I1(\coeff_reg_n_0_[6][0] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][0] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][0] ),
        .O(unamedDSP__1_i_76_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_77
       (.I0(\coeff_reg_n_0_[3][0] ),
        .I1(\coeff_reg_n_0_[2][0] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][0] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][0] ),
        .O(unamedDSP__1_i_77_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_78
       (.I0(\coeff_reg_n_0_[7][15] ),
        .I1(\coeff_reg_n_0_[6][15] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[5][15] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[4][15] ),
        .O(unamedDSP__1_i_78_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_79
       (.I0(\coeff_reg_n_0_[3][15] ),
        .I1(\coeff_reg_n_0_[2][15] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[1][15] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[0][15] ),
        .O(unamedDSP__1_i_79_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_8
       (.I0(unamedDSP__1_i_42_n_0),
        .I1(unamedDSP__1_i_43_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_44_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_45_n_0),
        .O(unamedDSP__1_i_8_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_80
       (.I0(\coeff_reg_n_0_[15][15] ),
        .I1(\coeff_reg_n_0_[14][15] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[13][15] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[12][15] ),
        .O(unamedDSP__1_i_80_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_81
       (.I0(\coeff_reg_n_0_[11][15] ),
        .I1(\coeff_reg_n_0_[10][15] ),
        .I2(\cnt_reg_n_0_[1] ),
        .I3(\coeff_reg_n_0_[9][15] ),
        .I4(\cnt_reg_n_0_[0] ),
        .I5(\coeff_reg_n_0_[8][15] ),
        .O(unamedDSP__1_i_81_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP__1_i_9
       (.I0(unamedDSP__1_i_46_n_0),
        .I1(unamedDSP__1_i_47_n_0),
        .I2(\cnt_reg_n_0_[3] ),
        .I3(unamedDSP__1_i_48_n_0),
        .I4(\cnt_reg_n_0_[2] ),
        .I5(unamedDSP__1_i_49_n_0),
        .O(unamedDSP__1_i_9_n_0));
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-13 {cell *THIS*}}" *) 
  DSP48E1 #(
    .ACASCREG(0),
    .ADREG(1),
    .ALUMODEREG(0),
    .AREG(0),
    .AUTORESET_PATDET("NO_RESET"),
    .A_INPUT("DIRECT"),
    .BCASCREG(0),
    .BREG(0),
    .B_INPUT("DIRECT"),
    .CARRYINREG(0),
    .CARRYINSELREG(0),
    .CREG(1),
    .DREG(1),
    .INMODEREG(0),
    .MASK(48'h3FFFFFFFFFFF),
    .MREG(0),
    .OPMODEREG(0),
    .PATTERN(48'h000000000000),
    .PREG(0),
    .SEL_MASK("MASK"),
    .SEL_PATTERN("PATTERN"),
    .USE_DPORT("FALSE"),
    .USE_MULT("MULTIPLY"),
    .USE_PATTERN_DETECT("NO_PATDET"),
    .USE_SIMD("ONE48")) 
    unamedDSP__2
       (.A({unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_75,unamedDSP__1_n_76,unamedDSP__1_n_77,unamedDSP__1_n_78,unamedDSP__1_n_79}),
        .ACIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .ALUMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .B({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const1> ,\<const0> ,\<const1> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> }),
        .BCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .C({VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2,VCC_2}),
        .CARRYCASCIN(\<const0> ),
        .CARRYIN(\<const0> ),
        .CARRYINSEL({\<const0> ,\<const0> ,\<const0> }),
        .CEA1(\<const0> ),
        .CEA2(\<const0> ),
        .CEAD(\<const0> ),
        .CEALUMODE(\<const0> ),
        .CEB1(\<const0> ),
        .CEB2(\<const0> ),
        .CEC(\<const0> ),
        .CECARRYIN(\<const0> ),
        .CECTRL(\<const0> ),
        .CED(\<const0> ),
        .CEINMODE(\<const0> ),
        .CEM(\<const0> ),
        .CEP(\<const0> ),
        .CLK(\<const0> ),
        .D({GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2,GND_2}),
        .INMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .MULTSIGNIN(\<const0> ),
        .OPMODE({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const1> ,\<const0> ,\<const1> }),
        .P({unamedDSP__2_n_76,unamedDSP__2_n_77,unamedDSP__2_n_78,unamedDSP__2_n_79,unamedDSP__2_n_80,unamedDSP__2_n_81,unamedDSP__2_n_82,unamedDSP__2_n_83,unamedDSP__2_n_84,unamedDSP__2_n_85,unamedDSP__2_n_86,unamedDSP__2_n_87,unamedDSP__2_n_88,unamedDSP__2_n_89,unamedDSP__2_n_90,unamedDSP__2_n_91,unamedDSP__2_n_92,unamedDSP__2_n_93,unamedDSP__2_n_94,unamedDSP__2_n_95,unamedDSP__2_n_96,unamedDSP__2_n_97,unamedDSP__2_n_98,unamedDSP__2_n_99,unamedDSP__2_n_100,unamedDSP__2_n_101,unamedDSP__2_n_102,unamedDSP__2_n_103,unamedDSP__2_n_104,unamedDSP__2_n_105}),
        .PCIN({\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> ,\<const0> }),
        .RSTA(\<const0> ),
        .RSTALLCARRYIN(\<const0> ),
        .RSTALUMODE(\<const0> ),
        .RSTB(\<const0> ),
        .RSTC(\<const0> ),
        .RSTCTRL(\<const0> ),
        .RSTD(\<const0> ),
        .RSTINMODE(\<const0> ),
        .RSTM(\<const0> ),
        .RSTP(\<const0> ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 unamedDSP_i_1
       (.CI(unamedDSP_i_2_n_0),
        .CO({unamedDSP_i_1_n_1,unamedDSP_i_1_n_2,unamedDSP_i_1_n_3}),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,unamedDSP_i_5_n_0,unamedDSP_i_6_n_0,unamedDSP_i_7_n_0}),
        .O({unamedDSP_i_1_n_4,unamedDSP_i_1_n_5,unamedDSP_i_1_n_6,unamedDSP_i_1_n_7}),
        .S({unamedDSP_i_8_n_0,unamedDSP_i_9_n_0,unamedDSP_i_10_n_0,unamedDSP_i_11_n_0}));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_10
       (.I0(unamedDSP_i_37_n_0),
        .I1(a_i_39_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_40_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_45_n_0),
        .O(unamedDSP_i_10_n_0));
  (* SOFT_HLUTNM = "soft_lutpair126" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_100
       (.I0(\coeff_reg_n_0_[15][13] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][13] ),
        .O(unamedDSP_i_100_n_0));
  (* SOFT_HLUTNM = "soft_lutpair122" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_101
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][12] ),
        .I2(\coeff_reg_n_0_[8][12] ),
        .O(unamedDSP_i_101_n_0));
  (* SOFT_HLUTNM = "soft_lutpair123" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_102
       (.I0(\coeff_reg_n_0_[11][12] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][12] ),
        .O(unamedDSP_i_102_n_0));
  (* SOFT_HLUTNM = "soft_lutpair123" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_103
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][12] ),
        .I2(\coeff_reg_n_0_[12][12] ),
        .O(unamedDSP_i_103_n_0));
  (* SOFT_HLUTNM = "soft_lutpair124" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_104
       (.I0(\coeff_reg_n_0_[15][12] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][12] ),
        .O(unamedDSP_i_104_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_105
       (.I0(\coeff_reg_n_0_[7][11] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][11] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_217_n_0),
        .O(unamedDSP_i_105_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_106
       (.I0(\coeff_reg_n_0_[3][11] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][11] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_218_n_0),
        .O(unamedDSP_i_106_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_107
       (.I0(\coeff_reg_n_0_[15][11] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][11] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_219_n_0),
        .O(unamedDSP_i_107_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_108
       (.I0(\coeff_reg_n_0_[11][11] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][11] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_220_n_0),
        .O(unamedDSP_i_108_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_109
       (.I0(\coeff_reg_n_0_[7][10] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][10] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_221_n_0),
        .O(unamedDSP_i_109_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_11
       (.I0(unamedDSP_i_38_n_0),
        .I1(a_i_43_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_44_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_46_n_0),
        .O(unamedDSP_i_11_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_110
       (.I0(\coeff_reg_n_0_[3][10] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][10] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_222_n_0),
        .O(unamedDSP_i_110_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_111
       (.I0(\coeff_reg_n_0_[15][10] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][10] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_223_n_0),
        .O(unamedDSP_i_111_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_112
       (.I0(\coeff_reg_n_0_[11][10] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][10] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_224_n_0),
        .O(unamedDSP_i_112_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_113
       (.I0(\coeff_reg_n_0_[7][9] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][9] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_225_n_0),
        .O(unamedDSP_i_113_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_114
       (.I0(\coeff_reg_n_0_[3][9] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][9] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_226_n_0),
        .O(unamedDSP_i_114_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_115
       (.I0(\coeff_reg_n_0_[15][9] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][9] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_227_n_0),
        .O(unamedDSP_i_115_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_116
       (.I0(\coeff_reg_n_0_[11][9] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][9] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_228_n_0),
        .O(unamedDSP_i_116_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_117
       (.I0(\coeff_reg_n_0_[7][8] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][8] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_229_n_0),
        .O(unamedDSP_i_117_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_118
       (.I0(\coeff_reg_n_0_[3][8] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][8] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_230_n_0),
        .O(unamedDSP_i_118_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_119
       (.I0(\coeff_reg_n_0_[15][8] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][8] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_231_n_0),
        .O(unamedDSP_i_119_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_12
       (.I0(unamedDSP_i_47_n_0),
        .O(unamedDSP_i_12_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_120
       (.I0(\coeff_reg_n_0_[11][8] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][8] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_232_n_0),
        .O(unamedDSP_i_120_n_0));
  (* SOFT_HLUTNM = "soft_lutpair120" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_121
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][11] ),
        .I2(\coeff_reg_n_0_[8][11] ),
        .O(unamedDSP_i_121_n_0));
  (* SOFT_HLUTNM = "soft_lutpair121" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_122
       (.I0(\coeff_reg_n_0_[11][11] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][11] ),
        .O(unamedDSP_i_122_n_0));
  (* SOFT_HLUTNM = "soft_lutpair121" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_123
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][11] ),
        .I2(\coeff_reg_n_0_[12][11] ),
        .O(unamedDSP_i_123_n_0));
  (* SOFT_HLUTNM = "soft_lutpair122" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_124
       (.I0(\coeff_reg_n_0_[15][11] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][11] ),
        .O(unamedDSP_i_124_n_0));
  (* SOFT_HLUTNM = "soft_lutpair118" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_125
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][10] ),
        .I2(\coeff_reg_n_0_[8][10] ),
        .O(unamedDSP_i_125_n_0));
  (* SOFT_HLUTNM = "soft_lutpair119" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_126
       (.I0(\coeff_reg_n_0_[11][10] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][10] ),
        .O(unamedDSP_i_126_n_0));
  (* SOFT_HLUTNM = "soft_lutpair119" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_127
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][10] ),
        .I2(\coeff_reg_n_0_[12][10] ),
        .O(unamedDSP_i_127_n_0));
  (* SOFT_HLUTNM = "soft_lutpair120" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_128
       (.I0(\coeff_reg_n_0_[15][10] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][10] ),
        .O(unamedDSP_i_128_n_0));
  (* SOFT_HLUTNM = "soft_lutpair116" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_129
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][9] ),
        .I2(\coeff_reg_n_0_[8][9] ),
        .O(unamedDSP_i_129_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_13
       (.I0(unamedDSP_i_48_n_0),
        .O(unamedDSP_i_13_n_0));
  (* SOFT_HLUTNM = "soft_lutpair117" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_130
       (.I0(\coeff_reg_n_0_[11][9] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][9] ),
        .O(unamedDSP_i_130_n_0));
  (* SOFT_HLUTNM = "soft_lutpair117" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_131
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][9] ),
        .I2(\coeff_reg_n_0_[12][9] ),
        .O(unamedDSP_i_131_n_0));
  (* SOFT_HLUTNM = "soft_lutpair118" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_132
       (.I0(\coeff_reg_n_0_[15][9] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][9] ),
        .O(unamedDSP_i_132_n_0));
  (* SOFT_HLUTNM = "soft_lutpair114" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_133
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][8] ),
        .I2(\coeff_reg_n_0_[8][8] ),
        .O(unamedDSP_i_133_n_0));
  (* SOFT_HLUTNM = "soft_lutpair115" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_134
       (.I0(\coeff_reg_n_0_[11][8] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][8] ),
        .O(unamedDSP_i_134_n_0));
  (* SOFT_HLUTNM = "soft_lutpair115" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_135
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][8] ),
        .I2(\coeff_reg_n_0_[12][8] ),
        .O(unamedDSP_i_135_n_0));
  (* SOFT_HLUTNM = "soft_lutpair116" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_136
       (.I0(\coeff_reg_n_0_[15][8] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][8] ),
        .O(unamedDSP_i_136_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_137
       (.I0(\coeff_reg_n_0_[7][7] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][7] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_233_n_0),
        .O(unamedDSP_i_137_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_138
       (.I0(\coeff_reg_n_0_[3][7] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][7] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_234_n_0),
        .O(unamedDSP_i_138_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_139
       (.I0(\coeff_reg_n_0_[15][7] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][7] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_235_n_0),
        .O(unamedDSP_i_139_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_14
       (.I0(unamedDSP_i_49_n_0),
        .O(unamedDSP_i_14_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_140
       (.I0(\coeff_reg_n_0_[11][7] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][7] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_236_n_0),
        .O(unamedDSP_i_140_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_141
       (.I0(\coeff_reg_n_0_[7][6] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][6] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_237_n_0),
        .O(unamedDSP_i_141_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_142
       (.I0(\coeff_reg_n_0_[3][6] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][6] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_238_n_0),
        .O(unamedDSP_i_142_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_143
       (.I0(\coeff_reg_n_0_[15][6] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][6] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_239_n_0),
        .O(unamedDSP_i_143_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_144
       (.I0(\coeff_reg_n_0_[11][6] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][6] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_240_n_0),
        .O(unamedDSP_i_144_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_145
       (.I0(\coeff_reg_n_0_[7][5] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][5] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_241_n_0),
        .O(unamedDSP_i_145_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_146
       (.I0(\coeff_reg_n_0_[3][5] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][5] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_242_n_0),
        .O(unamedDSP_i_146_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_147
       (.I0(\coeff_reg_n_0_[15][5] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][5] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_243_n_0),
        .O(unamedDSP_i_147_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_148
       (.I0(\coeff_reg_n_0_[11][5] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][5] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_244_n_0),
        .O(unamedDSP_i_148_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_149
       (.I0(\coeff_reg_n_0_[7][4] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][4] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_245_n_0),
        .O(unamedDSP_i_149_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_15
       (.I0(unamedDSP_i_50_n_0),
        .O(unamedDSP_i_15_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_150
       (.I0(\coeff_reg_n_0_[3][4] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][4] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_246_n_0),
        .O(unamedDSP_i_150_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_151
       (.I0(\coeff_reg_n_0_[15][4] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][4] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_247_n_0),
        .O(unamedDSP_i_151_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_152
       (.I0(\coeff_reg_n_0_[11][4] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][4] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_248_n_0),
        .O(unamedDSP_i_152_n_0));
  (* SOFT_HLUTNM = "soft_lutpair112" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_153
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][7] ),
        .I2(\coeff_reg_n_0_[8][7] ),
        .O(unamedDSP_i_153_n_0));
  (* SOFT_HLUTNM = "soft_lutpair113" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_154
       (.I0(\coeff_reg_n_0_[11][7] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][7] ),
        .O(unamedDSP_i_154_n_0));
  (* SOFT_HLUTNM = "soft_lutpair113" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_155
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][7] ),
        .I2(\coeff_reg_n_0_[12][7] ),
        .O(unamedDSP_i_155_n_0));
  (* SOFT_HLUTNM = "soft_lutpair114" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_156
       (.I0(\coeff_reg_n_0_[15][7] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][7] ),
        .O(unamedDSP_i_156_n_0));
  (* SOFT_HLUTNM = "soft_lutpair110" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_157
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][6] ),
        .I2(\coeff_reg_n_0_[8][6] ),
        .O(unamedDSP_i_157_n_0));
  (* SOFT_HLUTNM = "soft_lutpair111" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_158
       (.I0(\coeff_reg_n_0_[11][6] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][6] ),
        .O(unamedDSP_i_158_n_0));
  (* SOFT_HLUTNM = "soft_lutpair111" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_159
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][6] ),
        .I2(\coeff_reg_n_0_[12][6] ),
        .O(unamedDSP_i_159_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_16
       (.I0(unamedDSP_i_47_n_0),
        .I1(a_i_47_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_48_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_51_n_0),
        .O(unamedDSP_i_16_n_0));
  (* SOFT_HLUTNM = "soft_lutpair112" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_160
       (.I0(\coeff_reg_n_0_[15][6] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][6] ),
        .O(unamedDSP_i_160_n_0));
  (* SOFT_HLUTNM = "soft_lutpair108" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_161
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][5] ),
        .I2(\coeff_reg_n_0_[8][5] ),
        .O(unamedDSP_i_161_n_0));
  (* SOFT_HLUTNM = "soft_lutpair109" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_162
       (.I0(\coeff_reg_n_0_[11][5] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][5] ),
        .O(unamedDSP_i_162_n_0));
  (* SOFT_HLUTNM = "soft_lutpair109" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_163
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][5] ),
        .I2(\coeff_reg_n_0_[12][5] ),
        .O(unamedDSP_i_163_n_0));
  (* SOFT_HLUTNM = "soft_lutpair110" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_164
       (.I0(\coeff_reg_n_0_[15][5] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][5] ),
        .O(unamedDSP_i_164_n_0));
  (* SOFT_HLUTNM = "soft_lutpair106" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_165
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][4] ),
        .I2(\coeff_reg_n_0_[8][4] ),
        .O(unamedDSP_i_165_n_0));
  (* SOFT_HLUTNM = "soft_lutpair107" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_166
       (.I0(\coeff_reg_n_0_[11][4] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][4] ),
        .O(unamedDSP_i_166_n_0));
  (* SOFT_HLUTNM = "soft_lutpair107" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_167
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][4] ),
        .I2(\coeff_reg_n_0_[12][4] ),
        .O(unamedDSP_i_167_n_0));
  (* SOFT_HLUTNM = "soft_lutpair108" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_168
       (.I0(\coeff_reg_n_0_[15][4] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][4] ),
        .O(unamedDSP_i_168_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_169
       (.I0(\coeff_reg_n_0_[7][3] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][3] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_249_n_0),
        .O(unamedDSP_i_169_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_17
       (.I0(unamedDSP_i_48_n_0),
        .I1(a_i_51_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_52_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_52_n_0),
        .O(unamedDSP_i_17_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_170
       (.I0(\coeff_reg_n_0_[3][3] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][3] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_250_n_0),
        .O(unamedDSP_i_170_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_171
       (.I0(\coeff_reg_n_0_[15][3] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][3] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_251_n_0),
        .O(unamedDSP_i_171_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_172
       (.I0(\coeff_reg_n_0_[11][3] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][3] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_252_n_0),
        .O(unamedDSP_i_172_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_173
       (.I0(\coeff_reg_n_0_[7][2] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][2] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_253_n_0),
        .O(unamedDSP_i_173_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_174
       (.I0(\coeff_reg_n_0_[3][2] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][2] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_254_n_0),
        .O(unamedDSP_i_174_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_175
       (.I0(\coeff_reg_n_0_[15][2] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][2] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_255_n_0),
        .O(unamedDSP_i_175_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_176
       (.I0(\coeff_reg_n_0_[11][2] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][2] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_256_n_0),
        .O(unamedDSP_i_176_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_177
       (.I0(\coeff_reg_n_0_[7][1] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][1] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_257_n_0),
        .O(unamedDSP_i_177_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_178
       (.I0(\coeff_reg_n_0_[3][1] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][1] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_258_n_0),
        .O(unamedDSP_i_178_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_179
       (.I0(\coeff_reg_n_0_[15][1] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][1] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_259_n_0),
        .O(unamedDSP_i_179_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_18
       (.I0(unamedDSP_i_49_n_0),
        .I1(a_i_55_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_56_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_53_n_0),
        .O(unamedDSP_i_18_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_180
       (.I0(\coeff_reg_n_0_[11][1] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][1] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_260_n_0),
        .O(unamedDSP_i_180_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_181
       (.I0(\coeff_reg_n_0_[7][0] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][0] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_261_n_0),
        .O(unamedDSP_i_181_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_182
       (.I0(\coeff_reg_n_0_[3][0] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][0] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_262_n_0),
        .O(unamedDSP_i_182_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_183
       (.I0(\coeff_reg_n_0_[15][0] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][0] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_263_n_0),
        .O(unamedDSP_i_183_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_184
       (.I0(\coeff_reg_n_0_[11][0] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][0] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_264_n_0),
        .O(unamedDSP_i_184_n_0));
  (* SOFT_HLUTNM = "soft_lutpair104" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_185
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][3] ),
        .I2(\coeff_reg_n_0_[8][3] ),
        .O(unamedDSP_i_185_n_0));
  (* SOFT_HLUTNM = "soft_lutpair105" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_186
       (.I0(\coeff_reg_n_0_[11][3] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][3] ),
        .O(unamedDSP_i_186_n_0));
  (* SOFT_HLUTNM = "soft_lutpair105" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_187
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][3] ),
        .I2(\coeff_reg_n_0_[12][3] ),
        .O(unamedDSP_i_187_n_0));
  (* SOFT_HLUTNM = "soft_lutpair106" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_188
       (.I0(\coeff_reg_n_0_[15][3] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][3] ),
        .O(unamedDSP_i_188_n_0));
  (* SOFT_HLUTNM = "soft_lutpair102" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_189
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][2] ),
        .I2(\coeff_reg_n_0_[8][2] ),
        .O(unamedDSP_i_189_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_19
       (.I0(unamedDSP_i_50_n_0),
        .I1(a_i_59_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_60_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_54_n_0),
        .O(unamedDSP_i_19_n_0));
  (* SOFT_HLUTNM = "soft_lutpair103" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_190
       (.I0(\coeff_reg_n_0_[11][2] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][2] ),
        .O(unamedDSP_i_190_n_0));
  (* SOFT_HLUTNM = "soft_lutpair103" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_191
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][2] ),
        .I2(\coeff_reg_n_0_[12][2] ),
        .O(unamedDSP_i_191_n_0));
  (* SOFT_HLUTNM = "soft_lutpair104" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_192
       (.I0(\coeff_reg_n_0_[15][2] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][2] ),
        .O(unamedDSP_i_192_n_0));
  (* SOFT_HLUTNM = "soft_lutpair100" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_193
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][1] ),
        .I2(\coeff_reg_n_0_[8][1] ),
        .O(unamedDSP_i_193_n_0));
  (* SOFT_HLUTNM = "soft_lutpair101" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_194
       (.I0(\coeff_reg_n_0_[11][1] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][1] ),
        .O(unamedDSP_i_194_n_0));
  (* SOFT_HLUTNM = "soft_lutpair101" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_195
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][1] ),
        .I2(\coeff_reg_n_0_[12][1] ),
        .O(unamedDSP_i_195_n_0));
  (* SOFT_HLUTNM = "soft_lutpair102" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_196
       (.I0(\coeff_reg_n_0_[15][1] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][1] ),
        .O(unamedDSP_i_196_n_0));
  (* SOFT_HLUTNM = "soft_lutpair98" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_197
       (.I0(\coeff_reg_n_0_[9][0] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[8][0] ),
        .O(unamedDSP_i_197_n_0));
  (* SOFT_HLUTNM = "soft_lutpair99" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_198
       (.I0(\coeff_reg_n_0_[11][0] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][0] ),
        .O(unamedDSP_i_198_n_0));
  (* SOFT_HLUTNM = "soft_lutpair99" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_199
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][0] ),
        .I2(\coeff_reg_n_0_[12][0] ),
        .O(unamedDSP_i_199_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 unamedDSP_i_2
       (.CI(unamedDSP_i_3_n_0),
        .CO({unamedDSP_i_2_n_0,unamedDSP_i_2_n_1,unamedDSP_i_2_n_2,unamedDSP_i_2_n_3}),
        .CYINIT(\<const0> ),
        .DI({unamedDSP_i_12_n_0,unamedDSP_i_13_n_0,unamedDSP_i_14_n_0,unamedDSP_i_15_n_0}),
        .O({unamedDSP_i_2_n_4,unamedDSP_i_2_n_5,unamedDSP_i_2_n_6,unamedDSP_i_2_n_7}),
        .S({unamedDSP_i_16_n_0,unamedDSP_i_17_n_0,unamedDSP_i_18_n_0,unamedDSP_i_19_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_20
       (.I0(unamedDSP_i_55_n_0),
        .O(unamedDSP_i_20_n_0));
  (* SOFT_HLUTNM = "soft_lutpair100" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_200
       (.I0(\coeff_reg_n_0_[15][0] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][0] ),
        .O(unamedDSP_i_200_n_0));
  (* SOFT_HLUTNM = "soft_lutpair131" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_201
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][14] ),
        .I2(\coeff_reg_n_0_[4][14] ),
        .O(unamedDSP_i_201_n_0));
  (* SOFT_HLUTNM = "soft_lutpair131" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_202
       (.I0(\coeff_reg_n_0_[1][14] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][14] ),
        .O(unamedDSP_i_202_n_0));
  (* SOFT_HLUTNM = "soft_lutpair130" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_203
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][14] ),
        .I2(\coeff_reg_n_0_[12][14] ),
        .O(unamedDSP_i_203_n_0));
  (* SOFT_HLUTNM = "soft_lutpair130" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_204
       (.I0(\coeff_reg_n_0_[9][14] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][14] ),
        .O(unamedDSP_i_204_n_0));
  (* SOFT_HLUTNM = "soft_lutpair133" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_205
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][13] ),
        .I2(\coeff_reg_n_0_[4][13] ),
        .O(unamedDSP_i_205_n_0));
  (* SOFT_HLUTNM = "soft_lutpair133" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_206
       (.I0(\coeff_reg_n_0_[1][13] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][13] ),
        .O(unamedDSP_i_206_n_0));
  (* SOFT_HLUTNM = "soft_lutpair132" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_207
       (.I0(\coeff_reg_n_0_[13][13] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[12][13] ),
        .O(unamedDSP_i_207_n_0));
  (* SOFT_HLUTNM = "soft_lutpair132" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_208
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[9][13] ),
        .I2(\coeff_reg_n_0_[8][13] ),
        .O(unamedDSP_i_208_n_0));
  (* SOFT_HLUTNM = "soft_lutpair135" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_209
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][12] ),
        .I2(\coeff_reg_n_0_[4][12] ),
        .O(unamedDSP_i_209_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_21
       (.I0(unamedDSP_i_56_n_0),
        .O(unamedDSP_i_21_n_0));
  (* SOFT_HLUTNM = "soft_lutpair135" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_210
       (.I0(\coeff_reg_n_0_[1][12] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][12] ),
        .O(unamedDSP_i_210_n_0));
  (* SOFT_HLUTNM = "soft_lutpair134" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_211
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][12] ),
        .I2(\coeff_reg_n_0_[12][12] ),
        .O(unamedDSP_i_211_n_0));
  (* SOFT_HLUTNM = "soft_lutpair134" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_212
       (.I0(\coeff_reg_n_0_[9][12] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][12] ),
        .O(unamedDSP_i_212_n_0));
  (* SOFT_HLUTNM = "soft_lutpair97" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_213
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][15] ),
        .I2(\coeff_reg_n_0_[4][15] ),
        .O(unamedDSP_i_213_n_0));
  (* SOFT_HLUTNM = "soft_lutpair97" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_214
       (.I0(\coeff_reg_n_0_[1][15] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][15] ),
        .O(unamedDSP_i_214_n_0));
  (* SOFT_HLUTNM = "soft_lutpair96" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_215
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][15] ),
        .I2(\coeff_reg_n_0_[12][15] ),
        .O(unamedDSP_i_215_n_0));
  (* SOFT_HLUTNM = "soft_lutpair96" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_216
       (.I0(\coeff_reg_n_0_[9][15] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][15] ),
        .O(unamedDSP_i_216_n_0));
  (* SOFT_HLUTNM = "soft_lutpair137" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_217
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][11] ),
        .I2(\coeff_reg_n_0_[4][11] ),
        .O(unamedDSP_i_217_n_0));
  (* SOFT_HLUTNM = "soft_lutpair137" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_218
       (.I0(\coeff_reg_n_0_[1][11] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][11] ),
        .O(unamedDSP_i_218_n_0));
  (* SOFT_HLUTNM = "soft_lutpair136" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_219
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][11] ),
        .I2(\coeff_reg_n_0_[12][11] ),
        .O(unamedDSP_i_219_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_22
       (.I0(unamedDSP_i_57_n_0),
        .O(unamedDSP_i_22_n_0));
  (* SOFT_HLUTNM = "soft_lutpair136" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_220
       (.I0(\coeff_reg_n_0_[9][11] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][11] ),
        .O(unamedDSP_i_220_n_0));
  (* SOFT_HLUTNM = "soft_lutpair139" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_221
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][10] ),
        .I2(\coeff_reg_n_0_[4][10] ),
        .O(unamedDSP_i_221_n_0));
  (* SOFT_HLUTNM = "soft_lutpair139" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_222
       (.I0(\coeff_reg_n_0_[1][10] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][10] ),
        .O(unamedDSP_i_222_n_0));
  (* SOFT_HLUTNM = "soft_lutpair138" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_223
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][10] ),
        .I2(\coeff_reg_n_0_[12][10] ),
        .O(unamedDSP_i_223_n_0));
  (* SOFT_HLUTNM = "soft_lutpair138" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_224
       (.I0(\coeff_reg_n_0_[9][10] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][10] ),
        .O(unamedDSP_i_224_n_0));
  (* SOFT_HLUTNM = "soft_lutpair141" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_225
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][9] ),
        .I2(\coeff_reg_n_0_[4][9] ),
        .O(unamedDSP_i_225_n_0));
  (* SOFT_HLUTNM = "soft_lutpair141" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_226
       (.I0(\coeff_reg_n_0_[1][9] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][9] ),
        .O(unamedDSP_i_226_n_0));
  (* SOFT_HLUTNM = "soft_lutpair140" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_227
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][9] ),
        .I2(\coeff_reg_n_0_[12][9] ),
        .O(unamedDSP_i_227_n_0));
  (* SOFT_HLUTNM = "soft_lutpair140" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_228
       (.I0(\coeff_reg_n_0_[9][9] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][9] ),
        .O(unamedDSP_i_228_n_0));
  (* SOFT_HLUTNM = "soft_lutpair143" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_229
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][8] ),
        .I2(\coeff_reg_n_0_[4][8] ),
        .O(unamedDSP_i_229_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_23
       (.I0(unamedDSP_i_58_n_0),
        .O(unamedDSP_i_23_n_0));
  (* SOFT_HLUTNM = "soft_lutpair143" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_230
       (.I0(\coeff_reg_n_0_[1][8] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][8] ),
        .O(unamedDSP_i_230_n_0));
  (* SOFT_HLUTNM = "soft_lutpair142" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_231
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][8] ),
        .I2(\coeff_reg_n_0_[12][8] ),
        .O(unamedDSP_i_231_n_0));
  (* SOFT_HLUTNM = "soft_lutpair142" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_232
       (.I0(\coeff_reg_n_0_[9][8] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][8] ),
        .O(unamedDSP_i_232_n_0));
  (* SOFT_HLUTNM = "soft_lutpair145" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_233
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][7] ),
        .I2(\coeff_reg_n_0_[4][7] ),
        .O(unamedDSP_i_233_n_0));
  (* SOFT_HLUTNM = "soft_lutpair145" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_234
       (.I0(\coeff_reg_n_0_[1][7] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][7] ),
        .O(unamedDSP_i_234_n_0));
  (* SOFT_HLUTNM = "soft_lutpair144" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_235
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][7] ),
        .I2(\coeff_reg_n_0_[12][7] ),
        .O(unamedDSP_i_235_n_0));
  (* SOFT_HLUTNM = "soft_lutpair144" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_236
       (.I0(\coeff_reg_n_0_[9][7] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][7] ),
        .O(unamedDSP_i_236_n_0));
  (* SOFT_HLUTNM = "soft_lutpair147" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_237
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][6] ),
        .I2(\coeff_reg_n_0_[4][6] ),
        .O(unamedDSP_i_237_n_0));
  (* SOFT_HLUTNM = "soft_lutpair147" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_238
       (.I0(\coeff_reg_n_0_[1][6] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][6] ),
        .O(unamedDSP_i_238_n_0));
  (* SOFT_HLUTNM = "soft_lutpair146" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_239
       (.I0(\coeff_reg_n_0_[13][6] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[12][6] ),
        .O(unamedDSP_i_239_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_24
       (.I0(unamedDSP_i_55_n_0),
        .I1(a_i_63_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_64_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_59_n_0),
        .O(unamedDSP_i_24_n_0));
  (* SOFT_HLUTNM = "soft_lutpair146" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_240
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[9][6] ),
        .I2(\coeff_reg_n_0_[8][6] ),
        .O(unamedDSP_i_240_n_0));
  (* SOFT_HLUTNM = "soft_lutpair149" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_241
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][5] ),
        .I2(\coeff_reg_n_0_[4][5] ),
        .O(unamedDSP_i_241_n_0));
  (* SOFT_HLUTNM = "soft_lutpair149" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_242
       (.I0(\coeff_reg_n_0_[1][5] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][5] ),
        .O(unamedDSP_i_242_n_0));
  (* SOFT_HLUTNM = "soft_lutpair148" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_243
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][5] ),
        .I2(\coeff_reg_n_0_[12][5] ),
        .O(unamedDSP_i_243_n_0));
  (* SOFT_HLUTNM = "soft_lutpair148" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_244
       (.I0(\coeff_reg_n_0_[9][5] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][5] ),
        .O(unamedDSP_i_244_n_0));
  (* SOFT_HLUTNM = "soft_lutpair151" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_245
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][4] ),
        .I2(\coeff_reg_n_0_[4][4] ),
        .O(unamedDSP_i_245_n_0));
  (* SOFT_HLUTNM = "soft_lutpair151" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_246
       (.I0(\coeff_reg_n_0_[1][4] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][4] ),
        .O(unamedDSP_i_246_n_0));
  (* SOFT_HLUTNM = "soft_lutpair150" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_247
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][4] ),
        .I2(\coeff_reg_n_0_[12][4] ),
        .O(unamedDSP_i_247_n_0));
  (* SOFT_HLUTNM = "soft_lutpair150" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_248
       (.I0(\coeff_reg_n_0_[9][4] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][4] ),
        .O(unamedDSP_i_248_n_0));
  (* SOFT_HLUTNM = "soft_lutpair153" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_249
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][3] ),
        .I2(\coeff_reg_n_0_[4][3] ),
        .O(unamedDSP_i_249_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_25
       (.I0(unamedDSP_i_56_n_0),
        .I1(a_i_67_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_68_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_60_n_0),
        .O(unamedDSP_i_25_n_0));
  (* SOFT_HLUTNM = "soft_lutpair153" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_250
       (.I0(\coeff_reg_n_0_[1][3] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][3] ),
        .O(unamedDSP_i_250_n_0));
  (* SOFT_HLUTNM = "soft_lutpair152" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_251
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][3] ),
        .I2(\coeff_reg_n_0_[12][3] ),
        .O(unamedDSP_i_251_n_0));
  (* SOFT_HLUTNM = "soft_lutpair152" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_252
       (.I0(\coeff_reg_n_0_[9][3] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][3] ),
        .O(unamedDSP_i_252_n_0));
  (* SOFT_HLUTNM = "soft_lutpair155" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_253
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][2] ),
        .I2(\coeff_reg_n_0_[4][2] ),
        .O(unamedDSP_i_253_n_0));
  (* SOFT_HLUTNM = "soft_lutpair155" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_254
       (.I0(\coeff_reg_n_0_[1][2] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][2] ),
        .O(unamedDSP_i_254_n_0));
  (* SOFT_HLUTNM = "soft_lutpair154" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_255
       (.I0(\coeff_reg_n_0_[13][2] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[12][2] ),
        .O(unamedDSP_i_255_n_0));
  (* SOFT_HLUTNM = "soft_lutpair154" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_256
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[9][2] ),
        .I2(\coeff_reg_n_0_[8][2] ),
        .O(unamedDSP_i_256_n_0));
  (* SOFT_HLUTNM = "soft_lutpair157" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_257
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[5][1] ),
        .I2(\coeff_reg_n_0_[4][1] ),
        .O(unamedDSP_i_257_n_0));
  (* SOFT_HLUTNM = "soft_lutpair157" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_258
       (.I0(\coeff_reg_n_0_[1][1] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[0][1] ),
        .O(unamedDSP_i_258_n_0));
  (* SOFT_HLUTNM = "soft_lutpair156" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_259
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[13][1] ),
        .I2(\coeff_reg_n_0_[12][1] ),
        .O(unamedDSP_i_259_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_26
       (.I0(unamedDSP_i_57_n_0),
        .I1(a_i_71_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_72_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_61_n_0),
        .O(unamedDSP_i_26_n_0));
  (* SOFT_HLUTNM = "soft_lutpair156" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_260
       (.I0(\coeff_reg_n_0_[9][1] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[8][1] ),
        .O(unamedDSP_i_260_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_261
       (.I0(\coeff_reg_n_0_[5][0] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[4][0] ),
        .O(unamedDSP_i_261_n_0));
  (* SOFT_HLUTNM = "soft_lutpair158" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_262
       (.I0(\j_cnt_reg_n_0_[0] ),
        .I1(\coeff_reg_n_0_[1][0] ),
        .I2(\coeff_reg_n_0_[0][0] ),
        .O(unamedDSP_i_262_n_0));
  (* SOFT_HLUTNM = "soft_lutpair158" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_263
       (.I0(\coeff_reg_n_0_[13][0] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[12][0] ),
        .O(unamedDSP_i_263_n_0));
  (* SOFT_HLUTNM = "soft_lutpair98" *) 
  LUT3 #(
    .INIT(8'hAC)) 
    unamedDSP_i_264
       (.I0(\coeff_reg_n_0_[9][0] ),
        .I1(\coeff_reg_n_0_[8][0] ),
        .I2(\j_cnt_reg_n_0_[0] ),
        .O(unamedDSP_i_264_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_27
       (.I0(unamedDSP_i_58_n_0),
        .I1(a_i_75_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_76_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_62_n_0),
        .O(unamedDSP_i_27_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_28
       (.I0(unamedDSP_i_63_n_0),
        .O(unamedDSP_i_28_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_29
       (.I0(unamedDSP_i_64_n_0),
        .O(unamedDSP_i_29_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 unamedDSP_i_3
       (.CI(unamedDSP_i_4_n_0),
        .CO({unamedDSP_i_3_n_0,unamedDSP_i_3_n_1,unamedDSP_i_3_n_2,unamedDSP_i_3_n_3}),
        .CYINIT(\<const0> ),
        .DI({unamedDSP_i_20_n_0,unamedDSP_i_21_n_0,unamedDSP_i_22_n_0,unamedDSP_i_23_n_0}),
        .O({unamedDSP_i_3_n_4,unamedDSP_i_3_n_5,unamedDSP_i_3_n_6,unamedDSP_i_3_n_7}),
        .S({unamedDSP_i_24_n_0,unamedDSP_i_25_n_0,unamedDSP_i_26_n_0,unamedDSP_i_27_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_30
       (.I0(unamedDSP_i_65_n_0),
        .O(unamedDSP_i_30_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_31
       (.I0(unamedDSP_i_66_n_0),
        .O(unamedDSP_i_31_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_32
       (.I0(unamedDSP_i_63_n_0),
        .I1(a_i_79_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_80_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_67_n_0),
        .O(unamedDSP_i_32_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_33
       (.I0(unamedDSP_i_64_n_0),
        .I1(a_i_83_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_84_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_68_n_0),
        .O(unamedDSP_i_33_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_34
       (.I0(unamedDSP_i_65_n_0),
        .I1(a_i_87_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_88_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_69_n_0),
        .O(unamedDSP_i_34_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_35
       (.I0(unamedDSP_i_66_n_0),
        .I1(a_i_91_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_92_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_70_n_0),
        .O(unamedDSP_i_35_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_36
       (.I0(unamedDSP_i_71_n_0),
        .I1(unamedDSP_i_72_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_74_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_76_n_0),
        .O(unamedDSP_i_36_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_37
       (.I0(unamedDSP_i_77_n_0),
        .I1(unamedDSP_i_78_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_79_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_80_n_0),
        .O(unamedDSP_i_37_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_38
       (.I0(unamedDSP_i_81_n_0),
        .I1(unamedDSP_i_82_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_83_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_84_n_0),
        .O(unamedDSP_i_38_n_0));
  LUT6 #(
    .INIT(64'hA2A2A2020202A202)) 
    unamedDSP_i_39
       (.I0(a_i_33_n_0),
        .I1(unamedDSP_i_85_n_0),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[8][15] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[9][15] ),
        .O(unamedDSP_i_39_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 unamedDSP_i_4
       (.CI(\<const0> ),
        .CO({unamedDSP_i_4_n_0,unamedDSP_i_4_n_1,unamedDSP_i_4_n_2,unamedDSP_i_4_n_3}),
        .CYINIT(\<const0> ),
        .DI({unamedDSP_i_28_n_0,unamedDSP_i_29_n_0,unamedDSP_i_30_n_0,unamedDSP_i_31_n_0}),
        .O({unamedDSP_i_4_n_4,unamedDSP_i_4_n_5,unamedDSP_i_4_n_6,unamedDSP_i_4_n_7}),
        .S({unamedDSP_i_32_n_0,unamedDSP_i_33_n_0,unamedDSP_i_34_n_0,unamedDSP_i_35_n_0}));
  LUT6 #(
    .INIT(64'hAEAEAEFEFEFEAEFE)) 
    unamedDSP_i_40
       (.I0(a_i_33_n_0),
        .I1(unamedDSP_i_86_n_0),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[12][15] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[13][15] ),
        .O(unamedDSP_i_40_n_0));
  LUT6 #(
    .INIT(64'hA2A2A2020202A202)) 
    unamedDSP_i_41
       (.I0(a_i_33_n_0),
        .I1(unamedDSP_i_87_n_0),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[0][15] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[1][15] ),
        .O(unamedDSP_i_41_n_0));
  LUT6 #(
    .INIT(64'hAEAEAEFEFEFEAEFE)) 
    unamedDSP_i_42
       (.I0(a_i_33_n_0),
        .I1(unamedDSP_i_88_n_0),
        .I2(a_i_95_n_0),
        .I3(\coeff_reg_n_0_[4][15] ),
        .I4(a_i_96_n_0),
        .I5(\coeff_reg_n_0_[5][15] ),
        .O(unamedDSP_i_42_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_43
       (.I0(unamedDSP_i_89_n_0),
        .I1(unamedDSP_i_90_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_91_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_92_n_0),
        .O(unamedDSP_i_43_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_44
       (.I0(unamedDSP_i_93_n_0),
        .I1(unamedDSP_i_94_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_95_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_96_n_0),
        .O(unamedDSP_i_44_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_45
       (.I0(unamedDSP_i_97_n_0),
        .I1(unamedDSP_i_98_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_99_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_100_n_0),
        .O(unamedDSP_i_45_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_46
       (.I0(unamedDSP_i_101_n_0),
        .I1(unamedDSP_i_102_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_103_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_104_n_0),
        .O(unamedDSP_i_46_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_47
       (.I0(unamedDSP_i_105_n_0),
        .I1(unamedDSP_i_106_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_107_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_108_n_0),
        .O(unamedDSP_i_47_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_48
       (.I0(unamedDSP_i_109_n_0),
        .I1(unamedDSP_i_110_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_111_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_112_n_0),
        .O(unamedDSP_i_48_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_49
       (.I0(unamedDSP_i_113_n_0),
        .I1(unamedDSP_i_114_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_115_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_116_n_0),
        .O(unamedDSP_i_49_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_5
       (.I0(unamedDSP_i_36_n_0),
        .O(unamedDSP_i_5_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_50
       (.I0(unamedDSP_i_117_n_0),
        .I1(unamedDSP_i_118_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_119_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_120_n_0),
        .O(unamedDSP_i_50_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_51
       (.I0(unamedDSP_i_121_n_0),
        .I1(unamedDSP_i_122_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_123_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_124_n_0),
        .O(unamedDSP_i_51_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_52
       (.I0(unamedDSP_i_125_n_0),
        .I1(unamedDSP_i_126_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_127_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_128_n_0),
        .O(unamedDSP_i_52_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_53
       (.I0(unamedDSP_i_129_n_0),
        .I1(unamedDSP_i_130_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_131_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_132_n_0),
        .O(unamedDSP_i_53_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_54
       (.I0(unamedDSP_i_133_n_0),
        .I1(unamedDSP_i_134_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_135_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_136_n_0),
        .O(unamedDSP_i_54_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_55
       (.I0(unamedDSP_i_137_n_0),
        .I1(unamedDSP_i_138_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_139_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_140_n_0),
        .O(unamedDSP_i_55_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_56
       (.I0(unamedDSP_i_141_n_0),
        .I1(unamedDSP_i_142_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_143_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_144_n_0),
        .O(unamedDSP_i_56_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_57
       (.I0(unamedDSP_i_145_n_0),
        .I1(unamedDSP_i_146_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_147_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_148_n_0),
        .O(unamedDSP_i_57_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_58
       (.I0(unamedDSP_i_149_n_0),
        .I1(unamedDSP_i_150_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_151_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_152_n_0),
        .O(unamedDSP_i_58_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_59
       (.I0(unamedDSP_i_153_n_0),
        .I1(unamedDSP_i_154_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_155_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_156_n_0),
        .O(unamedDSP_i_59_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_6
       (.I0(unamedDSP_i_37_n_0),
        .O(unamedDSP_i_6_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_60
       (.I0(unamedDSP_i_157_n_0),
        .I1(unamedDSP_i_158_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_159_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_160_n_0),
        .O(unamedDSP_i_60_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_61
       (.I0(unamedDSP_i_161_n_0),
        .I1(unamedDSP_i_162_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_163_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_164_n_0),
        .O(unamedDSP_i_61_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_62
       (.I0(unamedDSP_i_165_n_0),
        .I1(unamedDSP_i_166_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_167_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_168_n_0),
        .O(unamedDSP_i_62_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_63
       (.I0(unamedDSP_i_169_n_0),
        .I1(unamedDSP_i_170_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_171_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_172_n_0),
        .O(unamedDSP_i_63_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_64
       (.I0(unamedDSP_i_173_n_0),
        .I1(unamedDSP_i_174_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_175_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_176_n_0),
        .O(unamedDSP_i_64_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_65
       (.I0(unamedDSP_i_177_n_0),
        .I1(unamedDSP_i_178_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_179_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_180_n_0),
        .O(unamedDSP_i_65_n_0));
  LUT6 #(
    .INIT(64'h505F3030505F3F3F)) 
    unamedDSP_i_66
       (.I0(unamedDSP_i_181_n_0),
        .I1(unamedDSP_i_182_n_0),
        .I2(unamedDSP_i_73_n_0),
        .I3(unamedDSP_i_183_n_0),
        .I4(unamedDSP_i_75_n_0),
        .I5(unamedDSP_i_184_n_0),
        .O(unamedDSP_i_66_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_67
       (.I0(unamedDSP_i_185_n_0),
        .I1(unamedDSP_i_186_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_187_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_188_n_0),
        .O(unamedDSP_i_67_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_68
       (.I0(unamedDSP_i_189_n_0),
        .I1(unamedDSP_i_190_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_191_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_192_n_0),
        .O(unamedDSP_i_68_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_69
       (.I0(unamedDSP_i_193_n_0),
        .I1(unamedDSP_i_194_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_195_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_196_n_0),
        .O(unamedDSP_i_69_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    unamedDSP_i_7
       (.I0(unamedDSP_i_38_n_0),
        .O(unamedDSP_i_7_n_0));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    unamedDSP_i_70
       (.I0(unamedDSP_i_197_n_0),
        .I1(unamedDSP_i_198_n_0),
        .I2(a_i_33_n_0),
        .I3(unamedDSP_i_199_n_0),
        .I4(a_i_95_n_0),
        .I5(unamedDSP_i_200_n_0),
        .O(unamedDSP_i_70_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_71
       (.I0(\coeff_reg_n_0_[7][14] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][14] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_201_n_0),
        .O(unamedDSP_i_71_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_72
       (.I0(\coeff_reg_n_0_[3][14] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][14] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_202_n_0),
        .O(unamedDSP_i_72_n_0));
  LUT6 #(
    .INIT(64'h6669699969996999)) 
    unamedDSP_i_73
       (.I0(\j_cnt_reg_n_0_[3] ),
        .I1(\coeff_reg[0][15]_i_22_n_7 ),
        .I2(\j_cnt_reg_n_0_[2] ),
        .I3(a_i_98_n_6),
        .I4(a_i_98_n_7),
        .I5(\j_cnt_reg_n_0_[1] ),
        .O(unamedDSP_i_73_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_74
       (.I0(\coeff_reg_n_0_[15][14] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][14] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_203_n_0),
        .O(unamedDSP_i_74_n_0));
  (* SOFT_HLUTNM = "soft_lutpair77" *) 
  LUT4 #(
    .INIT(16'h9666)) 
    unamedDSP_i_75
       (.I0(\j_cnt_reg_n_0_[2] ),
        .I1(a_i_98_n_6),
        .I2(a_i_98_n_7),
        .I3(\j_cnt_reg_n_0_[1] ),
        .O(unamedDSP_i_75_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_76
       (.I0(\coeff_reg_n_0_[11][14] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][14] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_204_n_0),
        .O(unamedDSP_i_76_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_77
       (.I0(\coeff_reg_n_0_[7][13] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][13] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_205_n_0),
        .O(unamedDSP_i_77_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_78
       (.I0(\coeff_reg_n_0_[3][13] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][13] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_206_n_0),
        .O(unamedDSP_i_78_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_79
       (.I0(\coeff_reg_n_0_[15][13] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][13] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_207_n_0),
        .O(unamedDSP_i_79_n_0));
  LUT6 #(
    .INIT(64'h0F004444F0FFBBBB)) 
    unamedDSP_i_8
       (.I0(unamedDSP_i_39_n_0),
        .I1(unamedDSP_i_40_n_0),
        .I2(unamedDSP_i_41_n_0),
        .I3(unamedDSP_i_42_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_43_n_0),
        .O(unamedDSP_i_8_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_80
       (.I0(\coeff_reg_n_0_[11][13] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][13] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_208_n_0),
        .O(unamedDSP_i_80_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_81
       (.I0(\coeff_reg_n_0_[7][12] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][12] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_209_n_0),
        .O(unamedDSP_i_81_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_82
       (.I0(\coeff_reg_n_0_[3][12] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][12] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_210_n_0),
        .O(unamedDSP_i_82_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_83
       (.I0(\coeff_reg_n_0_[15][12] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][12] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_211_n_0),
        .O(unamedDSP_i_83_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_84
       (.I0(\coeff_reg_n_0_[11][12] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][12] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_212_n_0),
        .O(unamedDSP_i_84_n_0));
  (* SOFT_HLUTNM = "soft_lutpair128" *) 
  LUT3 #(
    .INIT(8'h27)) 
    unamedDSP_i_85
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[11][15] ),
        .I2(\coeff_reg_n_0_[10][15] ),
        .O(unamedDSP_i_85_n_0));
  (* SOFT_HLUTNM = "soft_lutpair129" *) 
  LUT3 #(
    .INIT(8'h47)) 
    unamedDSP_i_86
       (.I0(\coeff_reg_n_0_[15][15] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][15] ),
        .O(unamedDSP_i_86_n_0));
  (* SOFT_HLUTNM = "soft_lutpair129" *) 
  LUT3 #(
    .INIT(8'h27)) 
    unamedDSP_i_87
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[3][15] ),
        .I2(\coeff_reg_n_0_[2][15] ),
        .O(unamedDSP_i_87_n_0));
  LUT3 #(
    .INIT(8'h47)) 
    unamedDSP_i_88
       (.I0(\coeff_reg_n_0_[7][15] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[6][15] ),
        .O(unamedDSP_i_88_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_89
       (.I0(\coeff_reg_n_0_[7][15] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[6][15] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_213_n_0),
        .O(unamedDSP_i_89_n_0));
  LUT6 #(
    .INIT(64'h9A95AAAA9A955555)) 
    unamedDSP_i_9
       (.I0(unamedDSP_i_36_n_0),
        .I1(a_i_35_n_0),
        .I2(a_i_33_n_0),
        .I3(a_i_36_n_0),
        .I4(a_i_34_n_0),
        .I5(unamedDSP_i_44_n_0),
        .O(unamedDSP_i_9_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_90
       (.I0(\coeff_reg_n_0_[3][15] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[2][15] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_214_n_0),
        .O(unamedDSP_i_90_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_91
       (.I0(\coeff_reg_n_0_[15][15] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[14][15] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_215_n_0),
        .O(unamedDSP_i_91_n_0));
  LUT6 #(
    .INIT(64'hFFB8B8FF00B8B800)) 
    unamedDSP_i_92
       (.I0(\coeff_reg_n_0_[11][15] ),
        .I1(\j_cnt_reg_n_0_[0] ),
        .I2(\coeff_reg_n_0_[10][15] ),
        .I3(a_i_98_n_7),
        .I4(\j_cnt_reg_n_0_[1] ),
        .I5(unamedDSP_i_216_n_0),
        .O(unamedDSP_i_92_n_0));
  (* SOFT_HLUTNM = "soft_lutpair126" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_93
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][14] ),
        .I2(\coeff_reg_n_0_[8][14] ),
        .O(unamedDSP_i_93_n_0));
  (* SOFT_HLUTNM = "soft_lutpair127" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_94
       (.I0(\coeff_reg_n_0_[11][14] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][14] ),
        .O(unamedDSP_i_94_n_0));
  (* SOFT_HLUTNM = "soft_lutpair127" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_95
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][14] ),
        .I2(\coeff_reg_n_0_[12][14] ),
        .O(unamedDSP_i_95_n_0));
  (* SOFT_HLUTNM = "soft_lutpair128" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_96
       (.I0(\coeff_reg_n_0_[15][14] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[14][14] ),
        .O(unamedDSP_i_96_n_0));
  (* SOFT_HLUTNM = "soft_lutpair124" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_97
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[9][13] ),
        .I2(\coeff_reg_n_0_[8][13] ),
        .O(unamedDSP_i_97_n_0));
  (* SOFT_HLUTNM = "soft_lutpair125" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    unamedDSP_i_98
       (.I0(\coeff_reg_n_0_[11][13] ),
        .I1(a_i_96_n_0),
        .I2(\coeff_reg_n_0_[10][13] ),
        .O(unamedDSP_i_98_n_0));
  (* SOFT_HLUTNM = "soft_lutpair125" *) 
  LUT3 #(
    .INIT(8'hD8)) 
    unamedDSP_i_99
       (.I0(a_i_96_n_0),
        .I1(\coeff_reg_n_0_[13][13] ),
        .I2(\coeff_reg_n_0_[12][13] ),
        .O(unamedDSP_i_99_n_0));
  LUT2 #(
    .INIT(4'h7)) 
    \zeta_cnt[0]_i_1 
       (.I0(\zeta_cnt_reg_n_0_[0] ),
        .I1(state[0]),
        .O(zeta_cnt[0]));
  (* SOFT_HLUTNM = "soft_lutpair177" *) 
  LUT3 #(
    .INIT(8'hE4)) 
    \zeta_cnt[1]_i_1 
       (.I0(state[0]),
        .I1(inverse_IBUF),
        .I2(\zeta_cnt_reg[1]_i_2_n_7 ),
        .O(zeta_cnt[1]));
  LUT1 #(
    .INIT(2'h1)) 
    \zeta_cnt[1]_i_3 
       (.I0(\zeta_cnt_reg_n_0_[1] ),
        .O(\zeta_cnt[1]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \zeta_cnt[1]_i_4 
       (.I0(\zeta_cnt_reg_n_0_[3] ),
        .I1(\zeta_cnt_reg_n_0_[4] ),
        .O(\zeta_cnt[1]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \zeta_cnt[1]_i_5 
       (.I0(\zeta_cnt_reg_n_0_[2] ),
        .I1(\zeta_cnt_reg_n_0_[3] ),
        .O(\zeta_cnt[1]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \zeta_cnt[1]_i_6 
       (.I0(\zeta_cnt_reg_n_0_[1] ),
        .I1(\zeta_cnt_reg_n_0_[2] ),
        .O(\zeta_cnt[1]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h6)) 
    \zeta_cnt[1]_i_7 
       (.I0(\zeta_cnt_reg_n_0_[1] ),
        .I1(inv_mode_reg_n_0),
        .O(\zeta_cnt[1]_i_7_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair177" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \zeta_cnt[2]_i_1 
       (.I0(\zeta_cnt_reg[1]_i_2_n_6 ),
        .I1(state[0]),
        .I2(inverse_IBUF),
        .O(zeta_cnt[2]));
  (* SOFT_HLUTNM = "soft_lutpair176" *) 
  LUT3 #(
    .INIT(8'hE4)) 
    \zeta_cnt[3]_i_1 
       (.I0(state[0]),
        .I1(inverse_IBUF),
        .I2(\zeta_cnt_reg[1]_i_2_n_5 ),
        .O(zeta_cnt[3]));
  (* SOFT_HLUTNM = "soft_lutpair176" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \zeta_cnt[4]_i_1 
       (.I0(\zeta_cnt_reg[1]_i_2_n_4 ),
        .I1(state[0]),
        .I2(inverse_IBUF),
        .O(zeta_cnt[4]));
  (* SOFT_HLUTNM = "soft_lutpair175" *) 
  LUT3 #(
    .INIT(8'hE4)) 
    \zeta_cnt[5]_i_1 
       (.I0(state[0]),
        .I1(inverse_IBUF),
        .I2(\zeta_cnt_reg[6]_i_3_n_7 ),
        .O(zeta_cnt[5]));
  LUT4 #(
    .INIT(16'h3002)) 
    \zeta_cnt[6]_i_1 
       (.I0(start_IBUF),
        .I1(state[2]),
        .I2(state[1]),
        .I3(state[0]),
        .O(\zeta_cnt[6]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair175" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    \zeta_cnt[6]_i_2 
       (.I0(\zeta_cnt_reg[6]_i_3_n_6 ),
        .I1(state[0]),
        .I2(inverse_IBUF),
        .O(zeta_cnt[6]));
  LUT2 #(
    .INIT(4'h9)) 
    \zeta_cnt[6]_i_4 
       (.I0(\zeta_cnt_reg_n_0_[5] ),
        .I1(\zeta_cnt_reg_n_0_[6] ),
        .O(\zeta_cnt[6]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \zeta_cnt[6]_i_5 
       (.I0(\zeta_cnt_reg_n_0_[4] ),
        .I1(\zeta_cnt_reg_n_0_[5] ),
        .O(\zeta_cnt[6]_i_5_n_0 ));
  FDCE \zeta_cnt_reg[0] 
       (.C(clk_IBUF_BUFG),
        .CE(\zeta_cnt[6]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(zeta_cnt[0]),
        .Q(\zeta_cnt_reg_n_0_[0] ));
  FDCE \zeta_cnt_reg[1] 
       (.C(clk_IBUF_BUFG),
        .CE(\zeta_cnt[6]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(zeta_cnt[1]),
        .Q(\zeta_cnt_reg_n_0_[1] ));
  (* ADDER_THRESHOLD = "35" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY4 \zeta_cnt_reg[1]_i_2 
       (.CI(\<const0> ),
        .CO({\zeta_cnt_reg[1]_i_2_n_0 ,\zeta_cnt_reg[1]_i_2_n_1 ,\zeta_cnt_reg[1]_i_2_n_2 ,\zeta_cnt_reg[1]_i_2_n_3 }),
        .CYINIT(\zeta_cnt_reg_n_0_[0] ),
        .DI({\zeta_cnt_reg_n_0_[3] ,\zeta_cnt_reg_n_0_[2] ,\zeta_cnt_reg_n_0_[1] ,\zeta_cnt[1]_i_3_n_0 }),
        .O({\zeta_cnt_reg[1]_i_2_n_4 ,\zeta_cnt_reg[1]_i_2_n_5 ,\zeta_cnt_reg[1]_i_2_n_6 ,\zeta_cnt_reg[1]_i_2_n_7 }),
        .S({\zeta_cnt[1]_i_4_n_0 ,\zeta_cnt[1]_i_5_n_0 ,\zeta_cnt[1]_i_6_n_0 ,\zeta_cnt[1]_i_7_n_0 }));
  FDCE \zeta_cnt_reg[2] 
       (.C(clk_IBUF_BUFG),
        .CE(\zeta_cnt[6]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(zeta_cnt[2]),
        .Q(\zeta_cnt_reg_n_0_[2] ));
  FDCE \zeta_cnt_reg[3] 
       (.C(clk_IBUF_BUFG),
        .CE(\zeta_cnt[6]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(zeta_cnt[3]),
        .Q(\zeta_cnt_reg_n_0_[3] ));
  FDCE \zeta_cnt_reg[4] 
       (.C(clk_IBUF_BUFG),
        .CE(\zeta_cnt[6]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(zeta_cnt[4]),
        .Q(\zeta_cnt_reg_n_0_[4] ));
  FDCE \zeta_cnt_reg[5] 
       (.C(clk_IBUF_BUFG),
        .CE(\zeta_cnt[6]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(zeta_cnt[5]),
        .Q(\zeta_cnt_reg_n_0_[5] ));
  FDCE \zeta_cnt_reg[6] 
       (.C(clk_IBUF_BUFG),
        .CE(\zeta_cnt[6]_i_1_n_0 ),
        .CLR(\j_cnt[7]_i_3_n_0 ),
        .D(zeta_cnt[6]),
        .Q(\zeta_cnt_reg_n_0_[6] ));
  (* ADDER_THRESHOLD = "35" *) 
  (* METHODOLOGY_DRC_VIOS = "{SYNTH-8 {cell *THIS*}}" *) 
  CARRY4 \zeta_cnt_reg[6]_i_3 
       (.CI(\zeta_cnt_reg[1]_i_2_n_0 ),
        .CO(\zeta_cnt_reg[6]_i_3_n_3 ),
        .CYINIT(\<const0> ),
        .DI({\<const0> ,\<const0> ,\<const0> ,\zeta_cnt_reg_n_0_[4] }),
        .O({\zeta_cnt_reg[6]_i_3_n_6 ,\zeta_cnt_reg[6]_i_3_n_7 }),
        .S({\<const0> ,\<const0> ,\zeta_cnt[6]_i_4_n_0 ,\zeta_cnt[6]_i_5_n_0 }));
endmodule
