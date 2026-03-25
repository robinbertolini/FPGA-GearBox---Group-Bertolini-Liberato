## ============================================================================
## Constraints file: dual_stepper_basys3.xdc
## Board : Digilent Basys3 (xc7a35tcpg236-1)
## ============================================================================

## -- Clock (100 MHz on-board oscillator) ------------------------------------
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## -- Centre push-button (reset) ---------------------------------------------
set_property -dict { PACKAGE_PIN U18  IOSTANDARD LVCMOS33 } [get_ports btnC]

## -- Slide switches (sw[0..3]) ----------------------------------------------
set_property -dict { PACKAGE_PIN V17  IOSTANDARD LVCMOS33 } [get_ports {sw[0]}]
set_property -dict { PACKAGE_PIN V16  IOSTANDARD LVCMOS33 } [get_ports {sw[1]}]
set_property -dict { PACKAGE_PIN W16  IOSTANDARD LVCMOS33 } [get_ports {sw[2]}]
set_property -dict { PACKAGE_PIN W17  IOSTANDARD LVCMOS33 } [get_ports {sw[3]}]

## -- Pmod JA – Motor 1 (IN1..IN4 on upper row, pins 1-4) -------------------
## JA pin 1  → IN1
set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports {JA[0]}]
## JA pin 2  → IN2
set_property -dict { PACKAGE_PIN L2   IOSTANDARD LVCMOS33 } [get_ports {JA[1]}]
## JA pin 3  → IN3
set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports {JA[2]}]
## JA pin 4  → IN4
set_property -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 } [get_ports {JA[3]}]

## -- Pmod JB – Motor 2 (IN1..IN4 on upper row, pins 1-4) -------------------
## JB pin 1  → IN1
set_property -dict { PACKAGE_PIN A14  IOSTANDARD LVCMOS33 } [get_ports {JB[0]}]
## JB pin 2  → IN2
set_property -dict { PACKAGE_PIN A16  IOSTANDARD LVCMOS33 } [get_ports {JB[1]}]
## JB pin 3  → IN3
set_property -dict { PACKAGE_PIN B15  IOSTANDARD LVCMOS33 } [get_ports {JB[2]}]
## JB pin 4  → IN4
set_property -dict { PACKAGE_PIN B16  IOSTANDARD LVCMOS33 } [get_ports {JB[3]}]
