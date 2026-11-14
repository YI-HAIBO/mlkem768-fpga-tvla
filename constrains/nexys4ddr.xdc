# IPX-AOI-Sec FPGA 原型 - Nexys 4 DDR 版本约束文件
# 目标器件：Xilinx Artix-7 XC7A100T-1csg324
# 设计者：Dr. Haibo Yi (海博易, 深圳技术大学)
# 用途：Phase 5 实现阶段管脚分配 (E3 100MHz 时钟)

# ============================
# 时钟约束 (Clock Constraints)
# ============================

# 系统时钟：E3 (100MHz)
create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

# 时钟不确定性 (Clock Uncertainty)
set_clock_uncertainty -setup 0.300 [get_clocks clk]
set_clock_uncertainty -hold  0.150 [get_clocks clk]

# ============================
# 管脚分配 (Pin Assignments)
# ============================
# 不分配未使用的 IO，避免布局布线前误分配。实际使用时按此文件补充：

# - 系统时钟：E3 (MRCC)
set_property PACKAGE_PIN E3 [get_ports clk]

# - 系统复位：C12 (CPU Reset)
set_property PACKAGE_PIN C12 [get_ports rst_n]

# - 用户测试接口 (仅用于快速验证，实际系统中这些 IO 将由其他模块占用)

#   16 个用户 LED：LD0..LD15
#   上电测试：全部点亮 (0 微秒内)
set_property PACKAGE_PIN H17 [get_ports {test_led[0]}]
set_property PACKAGE_PIN K15 [get_ports {test_led[1]}]
set_property PACKAGE_PIN J13 [get_ports {test_led[2]}]
set_property PACKAGE_PIN N14 [get_ports {test_led[3]}]
set_property PACKAGE_PIN R18 [get_ports {test_led[4]}]
set_property PACKAGE_PIN V17 [get_ports {test_led[5]}]
set_property PACKAGE_PIN U17 [get_ports {test_led[6]}]
set_property PACKAGE_PIN U16 [get_ports {test_led[7]}]
set_property PACKAGE_PIN V16 [get_ports {test_led[8]}]
set_property PACKAGE_PIN T15 [get_ports {test_led[9]}]
set_property PACKAGE_PIN U14 [get_ports {test_led[10]}]
set_property PACKAGE_PIN T16 [get_ports {test_led[11]}]
set_property PACKAGE_PIN V15 [get_ports {test_led[12]}]
set_property PACKAGE_PIN V14 [get_ports {test_led[13]}]
set_property PACKAGE_PIN V12 [get_ports {test_led[14]}]
set_property PACKAGE_PIN V11 [get_ports {test_led[15]}]

#   16 个滑动开关：SW0..SW15 (输入，高电平有效)
set_property PACKAGE_PIN J15 [get_ports {test_sw[0]}]
set_property PACKAGE_PIN L16 [get_ports {test_sw[1]}]
set_property PACKAGE_PIN M13 [get_ports {test_sw[2]}]
set_property PACKAGE_PIN R15 [get_ports {test_sw[3]}]
set_property PACKAGE_PIN R17 [get_ports {test_sw[4]}]
set_property PACKAGE_PIN T18 [get_ports {test_sw[5]}]
set_property PACKAGE_PIN U18 [get_ports {test_sw[6]}]
set_property PACKAGE_PIN R13 [get_ports {test_sw[7]}]
set_property PACKAGE_PIN T8 [get_ports {test_sw[8]}]
set_property PACKAGE_PIN U8 [get_ports {test_sw[9]}]
set_property PACKAGE_PIN R16 [get_ports {test_sw[10]}]
set_property PACKAGE_PIN T13 [get_ports {test_sw[11]}]
set_property PACKAGE_PIN H6 [get_ports {test_sw[12]}]
set_property PACKAGE_PIN U12 [get_ports {test_sw[13]}]
set_property PACKAGE_PIN U11 [get_ports {test_sw[14]}]
set_property PACKAGE_PIN V10 [get_ports {test_sw[15]}]

#   5 个按钮：BTNC/BTNL/BTNR/BTNU/BTND (低电平有效，按下为 0)
set_property PACKAGE_PIN N17 [get_ports {test_btn[0]}]
set_property PACKAGE_PIN P17 [get_ports {test_btn[1]}]
set_property PACKAGE_PIN M17 [get_ports {test_btn[2]}]
set_property PACKAGE_PIN M18 [get_ports {test_btn[3]}]
set_property PACKAGE_PIN P18 [get_ports {test_btn[4]}]

# ============================
# I/O 标准
# ============================
# 所有用户 IO 采用 LVCMOS33
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports {test_led[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {test_sw[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {test_btn[*]}]

# ============================
# 未使用 IO 处理
# ============================
# 布局布线前暂不约束，保留后续扩展。
