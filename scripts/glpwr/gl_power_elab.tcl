# Full power flow on the re-elaborated funcsim netlist (hierarchical design).
# Usage: vivado -mode batch -source gl_power_elab.tcl \
#           -tclargs <netlist.v> <saif> <outbase>
set netlist [lindex $argv 0]
set saif    [lindex $argv 1]
set rpt     [lindex $argv 2]

read_verilog $netlist
link_design -part xc7a100tcsg324-1 -top ipx_aoi_sec_board_top

if {[llength [get_ports -quiet clk]] > 0} {
    create_clock -name clk -period 10.000 [get_ports clk]
} else { puts "ERROR: no clk port"; exit 1 }

report_power -no_propagation -file ${rpt}_default.rpt

# design name from SAIF
set unmatched [file rootname $saif].unmatched_elab.txt
set saif_design ""
set fh [open $saif r]
while {[gets $fh line] >= 0} {
    if {[string match "*DESIGN*" $line]} {
        foreach p [split $line " "] {
            if {[string match {*\"*} $p]} { set saif_design [string trim $p {\"\t\r\n()}]; break }
        }
        break
    }
}
close $fh
puts "SAIF design: $saif_design"

# try strip_path with the design name
read_saif -strip_path $saif_design -out_file $unmatched $saif

report_power -file $rpt -hierarchical_depth 0 -hier all -l 40
report_power -file ${rpt}_hier3.rpt -hierarchical_depth 3 -hier all -l 40
puts "GL_POWER_ELAB_OK"
exit
