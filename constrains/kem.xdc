# Clock and port constraints for kyber_kem standalone synth
# Target: Artix-7 xc7a100tcsg324-1 (Nexys DDR4 / Arty A7-100)
# 100 MHz clock (20 ns period)

create_clock -period 10.0 [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks -of_objects [get_ports clk]]
set_input_jitter 0.1 [get_clocks -of_objects [get_ports clk]]

# Reset is async low-active; keep it unconstrained for now.
set_false_path -from [get_ports rst_n]
