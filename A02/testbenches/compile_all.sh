#!/bin/bash
rm -rf sim
mkdir sim
cd sim
ghdl -a ../unit/shift_register.vhd
ghdl -a ../unit/counter.vhd
ghdl -a ../unit/buttons_leds.vhd
ghdl -a ../tb/shift_register_tb.vhd
ghdl -a ../tb/counter_tb.vhd
ghdl -a ../tb/buttons_leds_tb.vhd
ghdl -e shift_register_tb
ghdl -e counter_tb
ghdl -e buttons_leds_tb
ghdl -r  shift_register_tb --wave=shift_register_tb.ghw > shift_register_tb.log 2> shift_register_tb.err
ghdl -r  counter_tb --wave=counter_tb.ghw --stop-time=300ns > counter_tb.log 2> counter_tb.err
ghdl -r  buttons_leds_tb --wave=button_leds_tb.ghw --stop-time=300ns > buttons_leds_tb.log 2> buttons_leds_tb.err
cd ..
