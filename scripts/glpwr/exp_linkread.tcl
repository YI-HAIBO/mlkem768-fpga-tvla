# exp_linkread.tcl
# Decisive experiment: read funcsim netlist (has real hierarchy) + link_design
# then check FULL_NAME and read_saif matching.
set OUT "C:/tmp/glpwr_1794120391"
set fh [open "$OUT/exp_linkread.txt" w]

read_verilog $OUT/gl_synth_rebuilt.v
link_design -top ipx_aoi_sec_board_top

set total 0
set empty 0
set nonempty 0
foreach n [get_nets -hier] {
    incr total
    if {[string length [get_property FULL_NAME $n]] == 0} {
        incr empty
    } else {
        incr nonempty
    }
}
puts $fh "LINK_TOTAL_NETS: $total"
puts $fh "LINK_FULL_NAME_EMPTY: $empty"
puts $fh "LINK_FULL_NAME_NONEMPTY: $nonempty"

# Sample some FULL_NAMEs
set samples ""
set cnt 0
foreach n [get_nets -hier -filter "NAME =~ *sc_va2_reg_i_1311*"] {
    if {$cnt < 5} {
        append samples "  NAME=[get_property NAME $n] FULL_NAME=[get_property FULL_NAME $n]\n"
        incr cnt
    }
}
puts $fh "SAMPLES:\n$samples"

# Check u_kem cell
set c [get_cells -hier u_kem]
puts $fh "U_KEM_CELLS: [llength $c]"
foreach cc $c {
    puts $fh "  U_KEM NAME=[get_property NAME $cc] FULL_NAME=[get_property FULL_NAME $cc] REF=[get_property REF_NAME $cc]"
}

# Now create a mini SAIF with the exact net name and read_saif
set mini "$OUT/mini_rebuilt.saif"
set fd [open $mini w]
puts $fd "(SAIFILE"
puts $fd "  (VERSION \"2.0\")"
puts $fd "  (DESIGN \"ipx_aoi_sec_board_top\")"
puts $fd "  (DATE \"2026-11-08\")"
puts $fd "  (TIMESCALE 1ns)"
puts $fd "  (DURATION 100000.0)"
puts $fd "  (NET \"u_kem/sc_va2_reg_i_1311_n_0\""
puts $fd "    (T0 50000.0) (T1 50000.0) (TX 0.0) (TC 100000)"
puts $fd "  )"
puts $fd ")"
close $fd

create_clock -period 10.000 [get_ports clk]
read_saif -strip_path ipx_aoi_sec_board_top $mini
report_power -no_propagation -file $OUT/gl_power_linkread.rpt

close $fh
puts "EXP_LINKREAD_DONE"
