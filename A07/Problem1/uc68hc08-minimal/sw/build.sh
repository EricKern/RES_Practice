#!/bin/bash
if (($# != 1)) 
then 
echo "Usage:"
echo "build.sh <simple | kernel>"
else

if [ "$1" = "simple" ] 
then 
export SW="_simple"
else
export SW="_kernel"
fi

export OBJ="./obj"
export SRC="./src"
export INC="./inc"
rm -rf $OBJ
mkdir $OBJ

export CC=sdcc
export AS=sdas6808
export LD=sdld6808

#check compiler
which sdcc-sdcc
if (( $? == 0 ))
then
export CC=sdcc-sdcc
export AS=sdcc-sdas6808
export LD=sdcc-sdld6808
fi
echo "Using SDCC: `which $CC`"
#export CFLAGS="--stack-auto --stack-loc 0xdfff --code-size 0x2000 -DDSEG=0xc000  -I $INC "
#export CFLAGS="--stack-auto --stack-loc 0xdfff -I $INC "
#smaller ram: move stack
#export CFLAGS="--stack-auto --stack-loc 0xbfff -I $INC "
#default: 8k rom, 8kram
#export LFLAGS="-C 0x2000 -b HOME=0xe000 -b XSEG=0xc000 -b DSEG=0x0000"
#larger rom, smaller ram
#export LFLAGS="-b HOME=0xc000 -C 0x4000 -b XSEG=0xb000 -X =0x1000 -b DSEG=0x0000 -I 0x80"
#
###############################################################
#### cyc1000: 32k rom, 8k ram
export CSIZE=0x8000
export DSIZE=0x2000
export CLOC=$((0x10000 - $CSIZE))
export SLOC=$(($CLOC - 1))
export DLOC=$(($CLOC - $DSIZE))
# we need to pass the DSEG location for the framebuffer
export CFLAGS="--stack-auto --stack-loc $SLOC -I $INC  -DXSEG=$DLOC "
export LFLAGS="-b HOME=$CLOC -C $CSIZE -b XSEG=$DLOC -X $DSIZE -b DSEG=0x0000 -I 0x80"
###############################################################

##
$CC -mhc08 -c $CFLAGS  $SRC/main$SW.c -o $OBJ/ 
$AS -g -l -a -o $OBJ/main$SW.asm 

if [ $SW = "_kernel" ]
then
#for kernel compile + link scheduler
$CC -mhc08 -c $CFLAGS src/scheduler.c -o $OBJ/
$AS -g -l -a -o $OBJ/scheduler.asm 
$LD $LFLAGS -k ./lib -l hclib -u -i $OBJ/main$SW.hex  $OBJ/main$SW.rel $OBJ/scheduler.rel  -m
#generate elf
$LD $LFLAGS -k ./lib -l hclib -E $OBJ/main$SW.elf  $OBJ/main$SW.rel $OBJ/scheduler.rel 
else
$LD $LFLAGS -k ./lib -l hclib -u -i $OBJ/main$SW.hex  $OBJ/main$SW.rel  -m
#generate elf
$LD $LFLAGS -k ./lib -l hclib -E $OBJ/main$SW.elf  $OBJ/main$SW.rel 
fi
#
srec_cat $OBJ/main$SW.ihx -intel  -O mem$SW.vhd -vhdl
#get size
size -A $OBJ/main$SW.elf
#generate binary file via elf output
objcopy $OBJ/main$SW.elf -I elf32-big $OBJ/main$SW.bin -O binary
#hexdump of binary can be viewed with:
# hexdump -C main$SW.bin
########################################
############ reentrant library ###############
# kernel need reentrant library! 
# compile library sources from /usr/share/sdcc/lib/src/ and /usr/share/sdcc/lib/src/hc08/
# cd ../lib
# rm hclib.lib 
# compile with --stack-auto
# for i in /usr/share/sdcc/lib/src/*.c; do $CC -mhc08 -c --stack-auto $i; done
# for i in /usr/share/sdcc/lib/src/hc08/*.c; do $CC -mhc08 -c --stack-auto $i; done
# create library
# $CClib hclib.lib *.rel
# list modules
# $CClib m hclib.lib
# ############################################
echo "Compilation of $SW version completed"
echo "Code size: $CSIZE, data size: $DSIZE"
echo "Code loc: $CLOC, data loc: $DLOC, stack: $SLOC"
echo "LFLAGS: $LFLAGS"
echo ""

fi
