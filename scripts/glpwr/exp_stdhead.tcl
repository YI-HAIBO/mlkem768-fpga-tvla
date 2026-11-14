# exp_stdhead.tcl
# Decisive: standard SAIF 2.0 header single-net test on rebuilt DCP.
# If this matches, the v4 SAIF header is the root cause -> fix vcd_to_saif.py.
set OUT "C:/tmp/glpwr_1794120391"
set fh [open "$OUT/exp_stdhead.txt" w]

open_checkpoint $OUT/gl_synth_rebuilt.dcp

# Standard SAIF 2.0 compliant single-net file
set std "$OUT/std_one.saif"
set fd [open $std w]
puts $fd "(SAIFILE"
puts $fd "  (SAIFVERSION \"2.0\")"
puts $fd "  (DESIGN \"ipx_aoi_sec_board_top\")"
puts $fd "  (DIVIDER /)"
puts $fd "  (TIMESCALE 1ns)"
puts $fd "  (DURATION 100000.0)"
puts $fd "  (INSTANCE ipx_aoi_sec_board_top"
puts $fd "    (NET \"u_kem/sc_va2_reg_i_1311_n_0\""
puts $fd "      (T0 50000.0)"
puts $fd "      (T1 50000.0)"
puts $fd "      (TX 0.0)"
puts $fd "      (TC 100000)"
puts $fd "    )"
puts $fd "  )"
puts $fd ")"
close $fd

create_clock -period 10.000 [get_ports clk]
read_saif -strip_path ipx_aoi_sec_board_top $std
report_power -no_propagation -file $OUT/gl_power_stdhead.rpt

close $fh
puts "EXP_STDHEAD_DONE"
