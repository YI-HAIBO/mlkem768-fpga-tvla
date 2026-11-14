# run_routed_power.tcl
# Open placed.dcp -> route_design (single-threaded, per impl.tcl lesson) ->
# save routed.dcp -> baseline power + SAIF/I/O annotated power + timing.
# Goal: Design implementation state = High (routed) -> Overall confidence High,
# dynamic power with real routing capacitance.
set OUT "C:/tmp/glpwr_1794120391"
set DCP "C:/tmp_impl_board_b2nttdram4_20261108_103559/placed.dcp"

open_checkpoint $DCP
create_clock -period 10.000 [get_ports clk]

# --- Route (single-threaded: route_design failed in Phase 5.1 Global Iteration 0
# when multi-threaded on this host; single-thread is the reliable path) ---
catch {set_param general.maxThreads 1}
route_design
catch {set_param general.maxThreads 1}
write_checkpoint -force "$OUT/gl_routed.dcp"
puts "ROUTE_DONE"

# --- Baseline power (vectorless) on the ROUTED design ---
report_power -no_propagation -file $OUT/gl_power_routed_baseline.rpt
puts "ROUTED_BASELINE_DONE"

# --- Fill missing input-port activity, then read SAIF + annotate ---
set inports [get_ports -filter {DIRECTION == IN}]
puts "INPUT_PORTS: [llength $inports]"
set_switching_activity $inports -toggle_rate 0.05 -static_probability 0.5
read_saif -strip_path ipx_aoi_sec_board_top $OUT/power_activity_v5.saif
report_power -no_propagation -file $OUT/gl_power_routed_io_annot.rpt
puts "ROUTED_ANNOT_DONE"

# --- Post-route timing recheck on the routed design (confirm still closed) ---
catch {set_param general.maxThreads 1}
report_timing_summary -file $OUT/gl_routed_timing.rpt -delay_type min_max -max_paths 5
puts "ROUTED_TIMING_DONE"

puts "ROUTED_POWER_OK"
exit
