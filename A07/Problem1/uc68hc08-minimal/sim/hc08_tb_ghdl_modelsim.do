transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -2008 -work work {../hdl/eprom_defs_pack.vhd}
vcom -2008 -work work {../sw/mem_simple.vhd}

vcom -2008 -work work {../hdl/arch/ramRom_d_cyc.vhd}
vcom -2008 -work work {../hdl/arch/clkgen_cyc1000.vhd}
vcom -2008 -work work {../hdl/arch/clkgen_cyc.vhd}
vcom -2008 -work work {../hdl/arch/hc08_cyc.vhd}
vcom -2008 -work work {../hdl/uart_tx.vhd}
vcom -2008 -work work {../hdl/uart_rx.vhd}
vcom -2008 -work work {../hdl/hc08_div.vhd}
vcom -2008 -work work {../hdl/hc08_core.vhd}
vcom -2008 -work work {../hdl/gpio.vhd}
vcom -2008 -work work {../hdl/fifo.vhd}
vcom -2008 -work work {../hdl/eprom_defs_pack.vhd}
vcom -2008 -work work {../hdl/baudPack.vhd}
vcom -2008 -work work {../hdl/baudgen.vhd}
vcom -2008 -work work {../hdl/hc08_math.vhd}
vcom -2008 -work work {../hdl/hc08_mul.vhd}
vcom -2008 -work work {../hdl/ramRom.vhd}
vcom -2008 -work work {../hdl/hc08_top.vhd}
vcom -2008 -work work {../hdl/uart.vhd}
vcom -2008 -work work {../hdl/bootCtl.vhd}
vcom -2008 -work work {../hdl/arch/ramRom_s.vhd}

vcom -2008 -work work {../sim/hc08_tb.vhd}
vcom -2008 -work work {../sim/hc08_tb_ghdl.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclone10lp -L rtl_work -L work -voptargs="+acc"  hc08_tb_ghdl

radix hex

add wave -position insertpoint  \
sim:/hc08_tb_ghdl/uut/uut/core/clk \
sim:/hc08_tb_ghdl/uut/uut/core/rst_n \
sim:/hc08_tb_ghdl/uut/uut/cpuRst \
sim:/hc08_tb_ghdl/uut/uut/uclk \
sim:/hc08_tb_ghdl/uut/uut/rclk \
sim:/hc08_tb_ghdl/uut/gpin \
sim:/hc08_tb_ghdl/uut/gpout \
sim:/hc08_tb_ghdl/uut/uut/core/addr \
sim:/hc08_tb_ghdl/uut/uut/core/datain \
sim:/hc08_tb_ghdl/uut/uut/core/dataout \
sim:/hc08_tb_ghdl/uut/uut/core/wr \
sim:/hc08_tb_ghdl/uut/uut/core/irq \
sim:/hc08_tb_ghdl/uut/uut/core/wt \
sim:/hc08_tb_ghdl/uut/uut/core/regA \
sim:/hc08_tb_ghdl/uut/uut/core/regHX \
sim:/hc08_tb_ghdl/uut/uut/core/regSP \
sim:/hc08_tb_ghdl/uut/uut/core/regPC \
sim:/hc08_tb_ghdl/uut/uut/core/flagV \
sim:/hc08_tb_ghdl/uut/uut/core/flagH \
sim:/hc08_tb_ghdl/uut/uut/core/flagI \
sim:/hc08_tb_ghdl/uut/uut/core/flagN \
sim:/hc08_tb_ghdl/uut/uut/core/flagZ \
sim:/hc08_tb_ghdl/uut/uut/core/flagC

view structure
view signals
run 1 ms

