# verify_rebuilt.tcl
# Verify gl_synth_rebuilt.dcp has proper hierarchical net names (FULL_NAME non-empty)
# and that read_saif can match a known net.
set OUT "C:/tmp/glpwr_1794120391"
open_checkpoint $OUT/gl_synth_rebuilt.dcp

set fh [open "$OUT/verify_rebuilt.txt" w]

# Count nets with empty vs non-empty FULL_NAME
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
puts $fh "TOTAL_NETS: $total"
puts $fh "FULL_NAME_EMPTY: $empty"
puts $fh "FULL_NAME_NONEMPTY: $nonempty"

# Try to resolve a known hierarchical net
set tgt "u_kem/sc_va2_reg_i_1311_n_0"
set h [get_nets -hier -filter "NAME =~ *sc_va2_reg_i_1311_n_0*"]
puts $fh "HIER_MATCH_count: [llength $h]"
foreach n $h {
    puts $fh "  NAME=[get_property NAME $n] FULL_NAME=[get_property FULL_NAME $n]"
}

# Direct resolution
set d [get_nets $tgt]
puts $fh "DIRECT_RESOLVE_count: [llength $d]"
foreach n $d {
    puts $fh "  NAME=[get_property NAME $n] FULL_NAME=[get_property FULL_NAME $n]"
}

# Read SAIF from v4 and report match count
set saif $OUT/power_activity_v4.saif
set f [open $saif r]
set saif_design ""
while {[gets $f line] >= 0} {
    if {[regexp {\(DESIGN\s+"([^"]+)"} $line -> d]} {
        set saif_design $d
        break
    }
}
close $f
puts $fh "SAIF_DESIGN: $saif_design"

create_clock -period 10.000 [get_ports clk]
if {[llength [get_ports clk]] == 0} {
    # maybe clock port named differently; try all clock-ish
    foreach p [get_ports -quiet] {
        puts $fh "PORT: [get_property NAME $p]"
    }
}

read_saif -strip_path $saif_design $saif
report_power -no_propagation -file $OUT/gl_power_rebuilt_baseline.rpt
report_power -no_propagation -file $OUT/gl_power_rebuilt_annot.rpt

close $fh
puts "VERIFY_REBUILT_DONE"
