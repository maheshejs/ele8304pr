# 100 MHz system clock
create_clock -period 20 -name clk [get_ports i_clk]

set_input_delay -clock clk -max   0.5  [get_ports * -filter {DIRECTION == IN && NAME !~ "i_clk"}]
set_input_delay -clock clk -min  -0.5  [get_ports * -filter {DIRECTION == IN && NAME !~ "i_clk"}]

set_output_delay -clock clk -max  -2  [all_outputs]
set_output_delay -clock clk -min -0.1 [all_outputs]
