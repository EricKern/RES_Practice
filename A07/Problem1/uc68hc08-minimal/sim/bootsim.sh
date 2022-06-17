#!/bin/bash
rm -rf boot
mkdir boot
cd boot
ghdl -a --std=08 --ieee=standard ../../hdl/baudPack.vhd ../../hdl/bootCtl.vhd ../../sim/bootCtl_tb.vhd ../../hdl/uart_tx.vhd ../../hdl/uart_rx.vhd
ghdl -e --std=08 --ieee=standard  bootCtl_tb
ghdl -r --std=08 --ieee=standard bootCtl_tb --vcd=boot.vcd --stop-time=50ms
echo "Generating extended ghw file"
ghdl -r --std=08 --ieee=standard bootCtl_tb --wave=boot.ghw --stop-time=50ms
cd ..

