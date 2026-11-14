# IPX-AOI-Sec FPGA 原型约束文件
# 目标器件：Xilinx Kintex-7 XC7K70T-1 FBG484
# 版本：v2.1 | 日期：2026-10-07 | 作者：Dr. Haibo Yi
# 用途：Phase 4 系统级综合时序约束
#
# v2.1 变更：
#   1. 器件标注改为与实际综合目标一致的 xc7k70tfbg484-1
#      （v2.0 头部写的是 XC7A50T-1 CSG324，与 synth_design -part 不符）。
#   2. 时钟不确定性由 1.5 ns 收紧到 0.3 ns。实测本设计系统抖动 TSJ 仅
#      0.071 ns，1.5 ns 的占位值相当于凭空吃掉 15% 的时钟周期，掩盖了
#      真实的时序余量。0.3 ns 覆盖晶振抖动 + 少量裕度；定型时须按实际
#      板级振荡器指标复核。
#   3. 移除全部 PACKAGE_PIN 分配（v2.0 的 N15/M15/L15 等属于另一封装，
#      在 FBG484 上不存在，产生 217 条 Critical Warning）。管脚需在选定
#      开发板后按原理图重新分配。

# ============================
# 时钟约束 (Clock Constraints)
# ============================

# 系统时钟 100MHz (顶层唯一时钟输入)
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# 时钟不确定性 (Clock Uncertainty)
# 0.3 ns = 晶振抖动 + 裕度。详见文件头 v2.1 变更说明。
set_clock_uncertainty -setup 0.300 [get_clocks clk]
set_clock_uncertainty -hold  0.150 [get_clocks clk]

# ============================
# 时序约束 (Timing Constraints)
# ============================

# 注：复位为同步释放设计，不跨时钟域，无需 set_false_path；
# 早期版本写的 [get_cells /*rst_n*] 模式匹配不到对象，已移除以免告警。

# ============================
# I/O 标准约束
# ============================

# 默认 I/O 标准
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# ============================
# 引脚分配 (Pin Assignments)
# ============================
# TODO：待选定开发板后按原理图分配。v2.0 中使用的 N15 / M15 / L15 /
#       AA15 等管脚在 FBG484 封装上不存在，已全部移除（见文件头 v2.1）。
#       布局布线前若未分配，Vivado 会自动放置，不影响综合阶段时序分析。
#
# 参考（FBG484 可用的时钟输入管脚对，选型时确认）：
#   set_property PACKAGE_PIN W7 [get_ports clk]     ;# MRCC
#   set_property PACKAGE_PIN Y7 [get_ports rst_n]

# ============================
# 未使用引脚处理
# ============================
# 注：综合阶段未分配管脚，无端口匹配 "unused" 过滤器，PULLDOWN 约束
# 在此处无对象可作用；布局布线阶段按开发板原理图分配管脚后，
# 再统一处理未用引脚（通常设为下拉输入或三态）。