#!/bin/bash
#delete old files
rm -rf main.hex mem.vhd main.elf
#generate hex
# options --nooverlay --stack-auto might be usefull, or not 
sdcc-sdcc -mhc08 -c mullong.c
sdcc-sdcc -mhc08 -c mult1.c
sdcc-sdcc  -DMULTEST -mhc08 --data-loc 0xc000 --stack-loc 0xdfff --code-loc 0xe000 --code-size 0x2000 -o main.hex --out-fmt-ihx main.c mullong.rel mult1.rel
#convert to vhdl
srec_cat main.hex -intel  -O mem.vhd -vhdl
#copy mem file
if [ -f mem.vhd ] 
then
    cp mem.vhd ../hdl/
else
    echo "Compile failed"
    return
fi
#generate elf
sdcc-sdcc -DMULTEST -mhc08 --data-loc 0xc000 --stack-loc 0xdfff --code-loc 0xe000 --code-size 0x2000 -o main.elf --out-fmt-elf main.c  mult1.rel
#get size
size main.elf
#generate binary file via elf output
objcopy main.elf -I elf32-big main.bin -O binary
#hexdump of binary can be viewed with:
# hexdump -C main.bin
#
#update bit
/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/data2mem -bt ../ise/hc08_mini.bit -o b down.bit -bm hc08_bd.bmm -bd main.elf
# optionally dump bit
#/opt/Xilinx/14.7/ISE_DS/ISE/bin/lin64/data2mem -bt down.bit -bm hc08_bd.bmm -d > down.list
if [ -f down.bit ] 
then
    echo "bitfile down.bit generated"
else
    echo "bitfile failed"
fi

