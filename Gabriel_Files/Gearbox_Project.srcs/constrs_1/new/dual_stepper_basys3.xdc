###############################################################################
# CLOCK (100 MHz)
###############################################################################
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.000 [get_ports clk]

###############################################################################
# RESET BUTTON
# btnC
###############################################################################
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

###############################################################################
# ENABLE SWITCH
# sw0
###############################################################################
set_property PACKAGE_PIN V17 [get_ports enable]
set_property IOSTANDARD LVCMOS33 [get_ports enable]

###############################################################################
# DIRECTION SWITCH
# sw1
###############################################################################
set_property PACKAGE_PIN V16 [get_ports fixed_dir]
set_property IOSTANDARD LVCMOS33 [get_ports fixed_dir]

###############################################################################
# DUTY CYCLE INPUT
# sw[9:2]
###############################################################################
set_property PACKAGE_PIN W16 [get_ports {duty_cycle[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {duty_cycle[0]}]

set_property PACKAGE_PIN W17 [get_ports {duty_cycle[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {duty_cycle[1]}]

set_property PACKAGE_PIN W15 [get_ports {duty_cycle[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {duty_cycle[2]}]

set_property PACKAGE_PIN V15 [get_ports {duty_cycle[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {duty_cycle[3]}]

set_property PACKAGE_PIN W14 [get_ports {duty_cycle[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {duty_cycle[4]}]

set_property PACKAGE_PIN W13 [get_ports {duty_cycle[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {duty_cycle[5]}]

set_property PACKAGE_PIN V2 [get_ports {duty_cycle[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {duty_cycle[6]}]

set_property PACKAGE_PIN T3 [get_ports {duty_cycle[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {duty_cycle[7]}]

###############################################################################
# MOTOR OUTPUTS
###############################################################################
# JA1
set_property PACKAGE_PIN J1 [get_ports motor_a]
set_property IOSTANDARD LVCMOS33 [get_ports motor_a]

# JA2
set_property PACKAGE_PIN L2 [get_ports motor_b]
set_property IOSTANDARD LVCMOS33 [get_ports motor_b]