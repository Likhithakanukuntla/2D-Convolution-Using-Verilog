create_clock -period 10.000 -name virtual -waveform {0.000 5.000} -add [get_ports clk]

# Set input delays (adjust t1 and t2 based on your design requirements)
set_input_delay -clock virtual -min 1.000 [get_ports {inputs}]
set_input_delay -clock virtual -max 3.000 [get_ports {inputs}]

# Set output delays (adjust t1 and t2 based on your design requirements)
set_output_delay -clock virtual -min 1.000 [get_ports {outputs}]