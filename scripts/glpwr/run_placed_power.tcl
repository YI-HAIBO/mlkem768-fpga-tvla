# run_placed_power.tcl
# Power run on the PLACED board DCP (b2nttdram4) + v5 SAIF.
set OUT "C:/tmp/glpwr_1794120391"
set DCP "C:/tmp_impl_board_b2nttdram4_20261108_103559/placed.dcp"
open_checkpoint $DCP

create_clock -period 10.000 [get_ports clk]

# Sanity: net name presence
set tgt [get_nets -hier -filter "NAME =~ *sc_va2_reg_i_1311_n_0*"]
puts "PLACED_MATCH_1311: [llength $tgt]"

report_power -no_propagation -file $OUT/gl_power_placed_baseline.rpt

read_saif -strip_path ipx_aoi_sec_board_top $OUT/power_activity_v5.saif
report_power -no_propagation -file $OUT/gl_power_placed_annot.rpt

puts "RUN_PLACED_POWER_DONE"
