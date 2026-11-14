# report_power.tcl - Run power analysis on the t75f design checkpoint
# Usage: vivado -mode batch -source report_power.tcl

set PROJ_DIR "c:/Users/Yi/WorkBuddy/2026-10-05-09-29-14/调研FPGA大模型安全/研发/ipx_aoi_fpga_prototype"
set DCP "$PROJ_DIR/results/ipx_aoi_sec_nexys_top.dcp"

puts "=== Vivado Power Report ==="
puts "Date: [clock format [clock seconds]]"
puts "DCP: $DCP"

# Open the design checkpoint
open_checkpoint $DCP

# Report power - full details
report_power -file "$PROJ_DIR/results/impl_board_top_t75f_power.rpt" -details all -nets all

# Report power - summary only
report_power -file "$PROJ_DIR/results/impl_board_top_t75f_power_summary.rpt"

# Report power by clock domain
report_power -file "$PROJ_DIR/results/impl_board_top_t75f_power_bydomain.rpt" -clock_domains all

# Also report timing for completeness
report_timing_summary -file "$PROJ_DIR/results/impl_board_top_t75f_power_timing.rpt" -delay_type min_max -max_paths 10

puts "=== Power report complete ==="