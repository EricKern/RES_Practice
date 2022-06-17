@page Address_Map Address Map
# Address Map
## This is the memory layout of the example implementation

## Program memory
Program memory is separated into 2 distinct areas. The upper range, up to 0xffff is used a ROM and will be initialized when the VHDL code is compiled. The ROM can be updated using a special utility which downloads the binary directly into the assosciated block RAMs. The area below is the data area, which gets initialized by the program startup code. It keeps all data and variables, with sme exceptions as described under [tracing](@ref Tracing).

The size of both areas can be specified via VHDL generics in multiples of 4kB (powers of 2 * 4K), the default is 8 blocks (32 kB) instruction and 2 blocks (8 kB) data.
The same settings must be used by the compile script.

### VHDL Specification
The generics `ni` and `nd` specify the number of 4k blocks for instruction (ni) and data (nd) ram.

    entity hc08_mini_cyc is
	   generic (
        ni: integer := 8; -- number of 4k blocks instruction ram, must be power of 2
        nd: integer := 2; -- number of 4k blocks data ram
        ... more generics
        simulation: boolean := false
	   );


### Compiler Settings
To match the compiler settings with the VHDL configuration, specify `CSIZE` and `DSIZE` as follows in the build script:

    #### cyc1000: 32k rom, 8k ram
    export CSIZE=0x8000
    export DSIZE=0x2000
    export CLOC=$((0x10000 - $CSIZE))
    export SLOC=$(($CLOC - 1))
    export DLOC=$(($CLOC - $DSIZE))
    # we need to pass the DSEG location for the framebuffer
    export CFLAGS="--stack-auto --stack-loc $SLOC -I $INC  -DXSEG=$DLOC "
    export LFLAGS="-b HOME=$CLOC -C $CSIZE -b XSEG=$DLOC -X $DSIZE -b DSEG=0x0000 -I 0x80"




## Peripherals
All basic peripherals are mapped into the address range from 0x80 to 0xff. The range below 0x80 is resevered for RAM and keeps for example the kernel related variables like task, mailbox and mutex states.

Therefore, the peripherals can be acessed using the fast HC08 direct addressing mode, which only works in page 0 (0x00 .. 0xff).

The external SDRAM can be accessed via a register set which allows to read or write sequentially, after setting the start address.

  * [General purpose I/O (LED, Buttons)](@ref GPIO)
  * [Timer](@ref TIMER)
  * [UART](@ref UART)
  * [Pulse width modulation](@ref PWM)
  * [I2C](@ref I2C)
  * [SDRAM](@ref SDRAM)



