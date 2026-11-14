# Minimal TCL test - find available parts
puts "=== TCL script starting ==="
puts "TCL version: [info patchlevel]"

set WORK "C:/tmp_ipx_synth/vivado_work_synth"

# Clean
file delete -force $WORK
file mkdir $WORK

# Create project
create_project -force $WORK

puts "Project created"

# Find available parts
puts "=== Available parts ==="
set parts [get_parts]
puts "Total parts: [llength $parts]"
foreach p [lrange $parts 0 20] {
    puts "  $p"
}

# Try to find a Kintex-7 or similar
puts ""
puts "=== Searching for Kintex-7 ==="
foreach p $parts {
    if {[string match "*k7*" $p] || [string match "*K7*" $p]} {
        puts "  FOUND: $p"
    }
}

puts ""
puts "=== Searching for Artix-7 ==="
foreach p $parts {
    if {[string match "*a7*" $p] || [string match "*A7*" $p]} {
        puts "  FOUND: $p"
    }
}

puts ""
puts "=== Searching for Zynq ==="
foreach p $parts {
    if {[string match "*zc*" $p] || [string match "*ZC*" $p]} {
        puts "  FOUND: $p"
    }
}

puts ""
puts "=== Done ==="
exit