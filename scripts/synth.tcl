# Vivado System-Level Synthesis TCL Script
# Run via: vivado.bat -mode batch -source synth.tcl
# Uses ASCII path symlink: C:/tmp_ipx_synth

set PROJ_ROOT "C:/tmp_ipx_synth"
set RESULTS "$PROJ_ROOT/results"
set CONST "$PROJ_ROOT/constrains"
set WORK "$PROJ_ROOT/vivado_work_synth"
set TOP "ipx_aoi_sec_fpga_top"

# Clean work directory
file delete -force $WORK
file mkdir $WORK

# Create project
create_project -name synth_system -force $WORK

# Set target part
set_part -part xc7k325t-2ffg900-2

# Add source files
puts "=== Adding source files ==="

# Top-level
add_files -fileset [get_filesets] "$PROJ_ROOT/rtl/ipx_aoi_sec_fpga_top.v"

# Stubs
add_files -fileset [get_filesets] "$PROJ_ROOT/rtl/submodule_stubs.v"

# Core modules
foreach f [lsort [glob -directory "$PROJ_ROOT/rtl/core" "*.v"]] {
    add_files -fileset [get_filesets] $f
    puts "  Added: $f"
}

# Real modules
foreach f [lsort [glob -directory "$PROJ_ROOT/rtl/real" "*.v"]] {
    add_files -fileset [get_filesets] $f
    puts "  Added: $f"
}

# Add constraints
add_files -fileset [get_filesets] -of_objects [get_filesets] "$CONST/project.xdc"

# Set top module
set_property top $TOP [get_filesets]

# Run synthesis
puts ""
puts "=== Running synthesis ==="
synth_design -top $TOP -part xc7k325t-2ffg900-2

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

exit