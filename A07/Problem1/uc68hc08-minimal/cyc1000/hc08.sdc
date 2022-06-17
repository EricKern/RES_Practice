## Generated SDC file "hc08_mini.out.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.1.1 Internal Build 593 12/11/2017 SJ Lite Edition"

## DATE    "Thu Mar 22 13:41:38 2018"

##
## DEVICE  "10CL025YU256C6G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk} -period 83.333 -waveform { 0.000 41.666 } [get_ports {clk}]




#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name uclk -source [get_pins {uc|cg|cyclk|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 25 -divide_by 12 -master_clock {clk} [get_pins {uc|cg|cyclk|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name rclk -source [get_pins {uc|cg|cyclk|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 25 -divide_by 6 -master_clock {clk} [get_pins {uc|cg|cyclk|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {mclk} -source [get_pins {uc|cg|cyclk|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50/1 -multiply_by 25 -divide_by 3 -master_clock {clk} [get_pins {uc|cg|cyclk|altpll_component|auto_generated|pll1|clk[2]}] 

create_generated_clock -name {sdr_clk} -source [get_pins {uc|cg|cyclk|altpll_component|auto_generated|pll1|clk[2]}] -master_clock {mclk} [get_ports {sdr_clk[0]}] 



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty -add 


#**************************************************************
# JTAG lines
#**************************************************************
set_input_delay -add_delay  -clock [get_clocks {altera_reserved_tck}]  5.000 [get_ports {altera_reserved_tms}]
set_input_delay -add_delay  -clock [get_clocks {altera_reserved_tck}]  5.000 [get_ports {altera_reserved_tdi}]
set_output_delay -add_delay  -clock [get_clocks {altera_reserved_tck}]  5.000 [get_ports {altera_reserved_tdo}]


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[0]}]
#set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[0]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[1]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[2]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[3]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[4]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[5]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[6]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[7]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[8]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[9]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[10]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[11]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[12]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[13]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[14]}]
set_input_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[15]}]

set_input_delay -add_delay  -clock [get_clocks {uclk}]  5.000 [get_ports {xgpin[0]}]
set_input_delay -add_delay  -clock [get_clocks {uclk}]  5.000 [get_ports {xgpin[1]}]
set_input_delay -add_delay  -clock [get_clocks {uclk}]  5.000 [get_ports {xgpin[2]}]
set_input_delay -add_delay  -clock [get_clocks {uclk}]  5.000 [get_ports {xgpin[3]}]
set_input_delay -add_delay  -clock [get_clocks {uclk}]  5.000 [get_ports {xgpin[4]}]



#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[0]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[1]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[2]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[3]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[4]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[5]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[6]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[7]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[8]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[9]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[10]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_addr[11]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_ba[0]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_ba[1]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_cas_n}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_cke}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_clk[0]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_cs_n}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[0]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[1]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[2]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[3]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[4]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[5]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[6]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[7]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[8]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[9]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[10]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[11]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[12]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[13]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[14]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dq[15]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dqm[0]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_dqm[1]}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_ras_n}]
set_output_delay -add_delay  -clock [get_clocks sdr_clk]  2.000 [get_ports {sdr_we_n}]


set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {gpout[0]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {gpout[1]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {gpout[2]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {gpout[3]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {gpout[4]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {gpout[5]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {gpout[6]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {gpout[7]}]	

set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {pulse[0]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {pulse[1]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {pulse[2]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {pulse[3]}]	

set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {scl}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {sda}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {tx}]	

set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaR[0]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaR[1]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaR[2]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaR[3]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaG[0]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaG[1]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaG[2]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaG[3]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaB[0]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaB[1]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaB[2]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaB[3]}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaHS}]	
set_output_delay -add_delay  -clock [get_clocks uclk]  5.000 [get_ports {vgaVS}]	


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path  -from  [get_clocks {clk}]  -to  [get_clocks {sdr_clk}]
set_false_path  -from  [get_clocks {sdr_clk}]  -to  [get_clocks {uclk}]
set_false_path  -from  [get_clocks {rclk}]  -to  [get_clocks {uclk}]
set_false_path  -from  [get_clocks {uclk}]  -to  [get_clocks {sdr_clk}]

set_false_path -from [get_keepers {*write_delay_cycle*}] -to [get_keepers {*dffpipe_rs_dgwp|dffpipe_fd9:dffpipe3|dffe4a*}]
set_false_path -from [get_keepers {*write_delay_cycle*}] -to [get_keepers {*dffpipe_rs_dgwp|dffpipe_ed9:dffpipe8|dffe9a*}]
set_false_path -from [get_ports {rst_n}] -to [get_clocks {clk}]
set_false_path -from [get_ports {rst_n}] 

# false paths for uart rx and i2c
set_false_path -from [get_ports {rx}] 
set_false_path -from [get_ports {scl}] 
set_false_path -from [get_ports {sda}] 


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

