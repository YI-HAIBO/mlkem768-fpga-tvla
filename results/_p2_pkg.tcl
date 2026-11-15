
set ps [get_parts -quiet -regexp {^xc7a200t-.*}]
foreach p [lsort $ps] {
    set dev [get_property DEVICE $p]
    set pkg [get_property PACKAGE $p]
    set spd [get_property SPEED $p]
    set io  [get_property AVAILABLE_IOBS $p]
    puts "PART $p  pkg=$pkg speed=$spd iobs=$io"
}
set cands [get_parts -quiet -regexp {^xc7a200t-(fbg484|sbg484|fbg676|fbv484|ffg1156)-.*}]
foreach p $cands {
    puts "SAMPLE $p slices=[get_property SLICES $p] lut=[get_property LUT_ELEMENTS $p] ff=[get_property FLIPFLOPS $p] bram=[get_property BLOCK_RAMS $p] dsp=[get_property DSP $p]"
}
exit 0
