
set_part xc7a50tcsg324-1
read_verilog "C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype\rtl\core\dilithium_core.v"
synth_design -top dilithium_core -part xc7a50tcsg324-1
report_utilization -file "C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype\results\util.rpt"
report_timing_summary -file "C:\Users\Yi\WorkBuddy\2026-10-05-09-29-14\调研FPGA大模型安全\研发\ipx_aoi_fpga_prototype\results\timing.rpt"
puts "SYNTH_DONE"
exit
