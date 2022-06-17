#!/bin/bash
# we need 3 parameters to specify the software type, the testbench and the configuration
if (($# != 3))
then
echo "Usage:"
echo "sim.sh <software type> <testbench> <config>"
echo "software types: simple | kernel"
echo "testbenches: hc08_tb | hc08_tb_ghdl | hc08_mxo_tb "
echo "config: mini | full"

else
export SW=$1
export TL=$2
export WAVE="$2_$1"
export CFG=$3
echo "Software type: $SW"
echo "Testbench: $TL"
echo "Wave file: $WAVE"

if (($SW = "simple")) 
then
 TM="30ms"
else
 TM="5ms"
fi

rm -rf out
mkdir out
cd out

rm -rf *.o work-obj08.cf $WAVE.vcd $WAVE.ghw $TL
#ghdl -a --std=08 --ieee=standard ../../../examples/text/text_util.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/eprom_defs_pack.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/baudPack.vhd
ghdl -a --std=08 --ieee=standard ../../sw/mem_$SW.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/baudgen.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/bootCtl.vhd
#don't compile vendor clkgen yet
#ghdl -a --std=08 --ieee=standard ../../hdl/clkgen.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/arch/clkgen_direct.vhd
if [ $CFG = "full" ]
then
# optional peripherals
echo "Compiling optional peripherals"
ghdl -a --std=08 --ieee=standard ../../hdl/extensions/pwm.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/extensions/pwmCtl.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/extensions/i2c_master.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/extensions/i2c.vhd
ghdl -a --std=08 --ieee=standard ../../sim/i2c_prom.vhd # simulation model
ghdl -a --std=08 --ieee=standard ../../hdl/extensions/spi_master.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/extensions/spi.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/extensions/vgaTiming.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/extensions/vgaTimeCtl.vhd
# sdram
echo "Compiling sdram"
# for cyc10lp we need the altera library and need to relax rules for attributes
ghdl -a --std=08 --ieee=standard -frelaxed-rules  -P../cyc10lp   ../../hdl/extensions/sdram_wrap.vhd
ghdl -a --std=08 --ieee=standard ../../ip/cycSdram/sdram_ctl.vhd
ghdl -a --std=08 --ieee=standard ../../ip/cycSdram/sdram_efifo.vhd
ghdl -a --std=08 --ieee=standard ../../ip/cycSdram/model/ramModel.vhd
fi
#
ghdl -a --std=08 --ieee=standard ../../hdl/fifo.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/gpio.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/arch/ramRom_s.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/ramRom_d.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/ramRom.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/timer.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/uart_rx.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/uart_tx.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/uart.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/hc08_mul.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/hc08_div.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/hc08_math.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/hc08_core.vhd
ghdl -a --std=08 --ieee=standard ../../hdl/hc08_top.vhd

#select the configuration
echo "Using configuration top level: hc08_$CFG.vhd"
ghdl -a --std=08 --ieee=standard ../../hdl/hc08_$CFG.vhd

# basic testbench must be compiled
ghdl -a --std=08 --ieee=standard ../../sim/hc08_tb.vhd

#select test bench. might be basic, results in second compilation. don't care ...
echo "Using testbench: $TL.vhd"
ghdl -a --std=08 --ieee=standard ../../sim/$TL.vhd

ghdl -e --std=08 --ieee=standard -frelaxed-rules  -P../cyc10lp  $TL
# echo "Generating standard vcd file"
# ghdl -r --std=08 --ieee=standard $TL --vcd=$WAVE.vcd --stop-time=30ms --ieee-asserts=disable
#echo "Not generating vcd, see trace file"
#ghdl -r --std=08 --ieee=standard $TL --stop-time=30ms --ieee-asserts=disable
#echo "Generating extended ghw file"
#ghdl -r --std=08 --ieee=standard $TL --wave=$$WAVE.ghw --stop-time=20ms
# for larger memory setting, ghdl may run out of stack. in this case, call the executable directly
# with special stack setting like
# ./hc08_tb_ghdl --max-stack-alloc=1000000 --wave=hc08_tb_ghdl.ghw --stop-time=30ms --ieee-asserts=disable
#./$TL --max-stack-alloc=1000000 --wave=$WAVE.ghw --stop-time=30ms --ieee-asserts=disable
echo "Generating vcd file using extended stack specs"
./$TL --max-stack-alloc=1000000 --vcd=$WAVE.vcd --stop-time=$TM --ieee-asserts=disable

cd ..

fi
