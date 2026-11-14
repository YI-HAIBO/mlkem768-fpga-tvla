
puts "=== P2 part probe ==="
# 1) Does xc7a325t exist at all, in ANY package/speed?
set p325 [get_parts -quiet -regexp {xc7a325t.*}]
puts "PARTS_325T: [llength $p325]"
foreach p $p325 { puts "  $p" }

# 2) xc7a680t (the other candidate named in report section 9)
set p680 [get_parts -quiet -regexp {xc7a680t.*}]
puts "PARTS_680T: [llength $p680]"
foreach p $p680 { puts "  $p" }

# 3) All Artix-7 families Vivado knows
set fams [get_parts -quiet -regexp {xc7a.*}]
set devlist {}
foreach p $fams {
    set dev [get_property DEVICE $p]
    if { ![dict exists $devlist $dev] } { dict set devlist $dev 1 }
}
puts "ARTIX7_DEVICES: [lsort [dict keys $devlist]]"

# 4) Full resource dump for the biggest artix-7 die we can find,
#    plus the current xc7a100t for a known-good reference.
foreach probe_device {xc7a325t xc7a680t xc7a200t xc7a100t} {
    set cand [lsearch -inline -all [lsort -unique $fams] "${probe_device}*"]
    # the above lsearch runs on part names; use get_parts directly instead
    set cand [get_parts -quiet -regexp "^${probe_device}-.*"]
    if { [llength $cand] == 0 } {
        puts "DEVICE $probe_device: NOT FOUND"
        continue
    }
    set part [lindex $cand 0]
    puts "DEVICE $probe_device: [llength $cand] parts, sample = $part"
    # all properties of one sample part
    foreach prop [lsort [list_property $part]] {
        set val [get_property $prop $part]
        if { $val ne "" && $val ne "*" } {
            puts "  $prop = $val"
        }
    }
}
puts "=== DONE ==="
exit 0
