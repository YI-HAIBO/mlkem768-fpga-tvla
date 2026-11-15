# #10B/C multi-device synthesis: same ML-KEM-768 kyber_kem core across part
# families. All paths are ASCII (C:/mdv_work) because Vivado reads .tcl source
# files in the system ANSI codepage, which mangles non-ASCII paths.
# Usage:  vivado -mode batch -source multidev_synth.tcl -tclargs <TAG> <PART> <OUT>
catch {set_param synth.enableParallelHelperSpawn none}
catch {set_param synth.elaboration.useElabCache false}

set TAG   [lindex $argv 0]
set PART  [lindex $argv 1]
set OUT   [lindex $argv 2]
set RTLDIR "C:/mdv_work/rtl/core"
set TOP   "kyber_kem"
set FILES {kyber_kem.v kyber_poly.v kyber_ntt.v kyber_sampler.v shake.v keccak_perm.v}

file mkdir $OUT
puts "=== multidev synth TAG=$TAG TOP=$TOP PART=$PART ==="

create_project -force kk_${TAG} proj_${TAG} -part $PART
foreach f $FILES {
    add_files "$RTLDIR/$f"
}
puts "=== files added ==="

synth_design -top $TOP -part $PART -directive default
puts "=== synth done ==="

# Checkpoint FIRST (core asset), before any report step that might hang.
write_checkpoint -force "$OUT/synth.dcp"
puts "=== checkpoint written ==="

# 100 MHz clock on the KEM core clock port (after elaboration so get_ports works)
create_clock -period 10.000 -name clk100 [get_ports clk]

report_utilization -file "$OUT/util.rpt"
puts "=== util written ==="

report_timing_summary -file "$OUT/timing.rpt" -delay_type min_max -max_paths 5
puts "=== timing written ==="

puts "=== DONE $PART ==="
exit
