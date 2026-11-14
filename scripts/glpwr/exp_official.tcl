# exp_official.tcl
# Decisive: use EXACTLY the Vivado-documented xsim SAIF format (style A).
# Header: (SAIFILE (SAIFVERSION "2.0") (DIRECTION "backward") (DESIGN..) ... (INSTANCE (NET (name (attrs)))))
set OUT "C:/tmp/glpwr_1794120391"
set fh [open "$OUT/exp_official.txt" w]

open_checkpoint $OUT/gl_synth_rebuilt.dcp

# Style A: Vivado/xsim exact format
set std "$OUT/official_one.saif"
set fd [open $std w]
puts $fd "(SAIFILE"
puts $fd "  (SAIFVERSION \"2.0\")"
puts $fd "  (DIRECTION \"backward\")"
puts $fd "  (DESIGN \"ipx_aoi_sec_board_top\")"
puts $fd "  (DATE \"Sun Nov  8 00:00:00 2026\")"
puts $fd "  (VENDOR \"Icarus\")"
puts $fd "  (PROGRAM_NAME \"iverilog\")"
puts $fd "  (VERSION \"12.0\")"
puts $fd "  (DIVIDER /)"
puts $fd "  (TIMESCALE 1 ns)"
puts $fd "  (DURATION 100000.0)"
puts $fd "  (INSTANCE ipx_aoi_sec_board_top"
puts $fd "    (NET (u_kem/sc_va2_reg_i_1311_n_0 (T0 50000.0) (T1 50000.0) (TX 0.0) (TC 100000)))"
puts $fd "  )"
puts $fd ")"
close $fd

create_clock -period 10.000 [get_ports clk]
read_saif -strip_path ipx_aoi_sec_board_top $std
report_power -no_propagation -file $OUT/gl_power_official.rpt

close $fh
puts "EXP_OFFICIAL_DONE"
