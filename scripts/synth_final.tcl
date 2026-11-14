# Vivado System-Level Synthesis - Final TCL Script
# Run via: vivado.bat -mode batch -source synth_final.tcl
# Uses ASCII path symlink: C:/tmp_ipx_synth

set PROJ_ROOT "C:/tmp_ipx_synth"
set RESULTS "$PROJ_ROOT/results"
set CONST "$PROJ_ROOT/constrains"
set WORK "$PROJ_ROOT/vivado_work_synth"
set TOP "ipx_aoi_sec_fpga_top"
set PART "xc7k70tfbg484-1"

# Clean work directory
file delete -force $WORK
file mkdir $WORK

# Create project with part
create_project -force $WORK -part $PART

# Use the default sources fileset explicitly
set fs "sources_1"

# Add source files
puts "=== Adding source files ==="

# Top-level
add_files -fileset $fs "$PROJ_ROOT/rtl/ipx_aoi_sec_fpga_top.v"

# Stubs
add_files -fileset $fs "$PROJ_ROOT/rtl/submodule_stubs.v"

# Core modules
foreach f [lsort [glob -directory "$PROJ_ROOT/rtl/core" "*.v"]] {
    add_files -fileset $fs $f
    puts "  Added: $f"
}

# Real modules
foreach f [lsort [glob -directory "$PROJ_ROOT/rtl/real" "*.v"]] {
    add_files -fileset $fs $f
    puts "  Added: $f"
}

# Add constraints to constrs_1 fileset
add_files -fileset constrs_1 "$CONST/project.xdc"

# Set top module
set_property top $TOP [get_filesets sources_1]

# Run synthesis
puts ""
puts "=== Running synthesis ==="
synth_design -top $TOP -part $PART

# Write reports
puts ""
puts "=== Writing reports ==="
report_utilization -file "$RESULTS/util_system.rpt"
report_timing -file "$RESULTS/timing_system.rpt"

puts ""
puts "=== Synthesis Complete ==="

# Read and print key metrics
set tf [open "$RESULTS/timing_system.rpt" r]
set td [read $tf]
close $tf

if {[regexp {WNS\s+([-\d.]+)} $td wns_match]} {
    puts "WNS: [lindex $wns_match 1] ns"
}

if {[regexp {LUT\s*\|\s*(\d+)} $td lut_match]} {
    puts "LUTs: [lindex $lut_match 1]"
}

if {[regexp {FF\s*\|\s*(\d+)} $td ff_match]} {
    puts "FFs: [lindex $ff_match 1]"
}

exit