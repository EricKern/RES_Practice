#!/bin/bash
# update for vhdl2008 (partially)
rm -rf sim
mkdir sim
cd sim
#analyse all files
echo "Analyzing"
for i in ../unit/*.vhd; do ghdl -a --std=08 --ieee=standard $i; done
for i in ../tb/*.vhd; do ghdl -a --std=08 --ieee=standard $i; done
#elaborate all tb entities
echo "Elaborating"
for i in ../tb/*.vhd; do ghdl -e --std=08 --ieee=standard `basename $i .vhd`; done
#run all tbs
echo "Running"
# for i in ../tb/*.vhd; do ghdl -r --std=08 --ieee=standard `basename $i .vhd` --vcd=`basename $i .vhd`.vcd --stop-time=10us > `basename $i .vhd`.log 2> `basename $i .vhd`.err ; done
for i in ../tb/*.vhd; do ghdl -r --std=08 --ieee=standard `basename $i .vhd` --wave=`basename $i .vhd`.ghw --stop-time=10us > `basename $i .vhd`.log 2> `basename $i .vhd`.err ; done
#logs and error
echo "Logs and errors in sim/<unit>.log, sim/<unit>.err"
ls -l *.log
ls -l *.err
#view waveforms ...
echo "View waveforms: gtkwave sim/<unit>.ghw"
ls *.ghw
cd ..

