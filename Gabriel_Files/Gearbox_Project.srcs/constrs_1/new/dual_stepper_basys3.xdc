############################################################
# CLOCK (100MHz)
############################################################
set_property PACKAGE_PIN W5  [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

############################################################
# BUTTON RESET (Center Button)
############################################################
set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]

############################################################
# SWITCHES SW0 - SW15
############################################################
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[3]}]
set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[4]}]
set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[5]}]
set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[6]}]
set_property PACKAGE_PIN W13 [get_ports {sw[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[7]}]
set_property PACKAGE_PIN V2  [get_ports {sw[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[8]}]
set_property PACKAGE_PIN T3  [get_ports {sw[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[9]}]
set_property PACKAGE_PIN T2  [get_ports {sw[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[10]}]
set_property PACKAGE_PIN R3  [get_ports {sw[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[11]}]
set_property PACKAGE_PIN W2  [get_ports {sw[12]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[12]}]
set_property PACKAGE_PIN U1  [get_ports {sw[13]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[13]}]
set_property PACKAGE_PIN T1  [get_ports {sw[14]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[14]}]
set_property PACKAGE_PIN R2  [get_ports {sw[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[15]}]

############################################################
# DIAGNOSTIC LEDs
# LED0: S1 Calibrated | LED1: S2 Calibrated
# LED2: S1 Busy       | LED3: S2 Busy
############################################################
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN V19 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN W18 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]

############################################################
# DC MOTOR (JA HEADER)
# JA[2] = Direction pin (G2)
# JA[3] = PWM/Enable pin (G3)
############################################################
set_property PACKAGE_PIN G2 [get_ports {JA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[2]}]
set_property PACKAGE_PIN G3 [get_ports {JA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JA[3]}]

############################################################
# STEPPER 1 (JXADC pins 1-4)
# Connected to JB in the Top Module
############################################################
set_property PACKAGE_PIN J3 [get_ports {JB[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[0]}]
set_property PACKAGE_PIN L3 [get_ports {JB[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[1]}]
set_property PACKAGE_PIN M2 [get_ports {JB[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[2]}]
set_property PACKAGE_PIN N2 [get_ports {JB[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JB[3]}]

############################################################
# STEPPER 2 (JXADC pins 7-10)
# Connected to JC in the Top Module
############################################################
set_property PACKAGE_PIN K3 [get_ports {JC[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[0]}]
set_property PACKAGE_PIN M3 [get_ports {JC[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[1]}]
set_property PACKAGE_PIN M1 [get_ports {JC[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[2]}]
set_property PACKAGE_PIN N1 [get_ports {JC[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {JC[3]}]

# Buttons
set_property PACKAGE_PIN U18 [get_ports btnC]
set_property IOSTANDARD LVCMOS33 [get_ports btnC]
set_property PACKAGE_PIN T18 [get_ports btnU]
set_property IOSTANDARD LVCMOS33 [get_ports btnU]
set_property PACKAGE_PIN W19 [get_ports btnL]
set_property IOSTANDARD LVCMOS33 [get_ports btnL]
set_property PACKAGE_PIN T17 [get_ports btnR]
set_property IOSTANDARD LVCMOS33 [get_ports btnR]
set_property PACKAGE_PIN U17 [get_ports btnD]
set_property IOSTANDARD LVCMOS33 [get_ports btnD]