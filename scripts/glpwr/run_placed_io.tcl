# run_placed_io.tcl
# placed DCP + fill missing input-port activity via set_switching_activity.
set OUT "C:/tmp/glpwr_1794120391"
set DCP "C:/tmp_impl_board_b2nttdram4_20261108_103559/placed.dcp"
open_checkpoint $DCP
create_clock -period 10.000 [get_ports clk]

# Count input ports
set inports [get_ports -filter {DIRECTION == IN}]
puts "INPUT_PORTS: [llength $inports]"

# Give every input port an activity (fill the >5% missing I/O)
set_switching_activity $inports -toggle_rate 0.05 -static_probability 0.5

read_saif -strip_path ipx_aoi_sec_board_top $OUT/power_activity_v5.saif
report_power -no_propagation -file $OUT/gl_power_placed_io_annot.rpt
puts "RUN_PLACED_IO_DONE"
