# run_v5_power.tcl
# Full power run: rebuilt DCP (default flatten) + v5 SAIF (official format).
set OUT "C:/tmp/glpwr_1794120391"
open_checkpoint $OUT/gl_synth_rebuilt.dcp

create_clock -period 10.000 [get_ports clk]

# Baseline (no activity file)
report_power -no_propagation -file $OUT/gl_power_v5_baseline.rpt

# Annotated with v5 SAIF
read_saif -strip_path ipx_aoi_sec_board_top $OUT/power_activity_v5.saif
report_power -no_propagation -file $OUT/gl_power_v5_annot.rpt

puts "RUN_V5_POWER_DONE"
