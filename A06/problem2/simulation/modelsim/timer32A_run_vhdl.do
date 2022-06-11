transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {E:/RES_Practice/A06/problem2/load_counter.vhd}
vcom -93 -work work {E:/RES_Practice/A06/problem2/timer32A.vhd}

vcom -93 -work work {E:/RES_Practice/A06/problem2/timer32A_tb.vhd}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L cyclone10lp -L rtl_work -L work -voptargs="+acc"  timer_peripheral_tb



onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /timer_peripheral_tb/clk_tb
add wave -noupdate /timer_peripheral_tb/reset_tb
add wave -noupdate /timer_peripheral_tb/write_en_tb
add wave -noupdate /timer_peripheral_tb/read_en_tb
add wave -noupdate /timer_peripheral_tb/data_in_tb
add wave -noupdate /timer_peripheral_tb/address_tb
add wave -noupdate -radix unsigned /timer_peripheral_tb/data_out_tb
add wave -noupdate /timer_peripheral_tb/interrupt_request_tb
add wave -noupdate /timer_peripheral_tb/uut/clk
add wave -noupdate /timer_peripheral_tb/uut/reset
add wave -noupdate /timer_peripheral_tb/uut/w_ena
add wave -noupdate /timer_peripheral_tb/uut/r_ena
add wave -noupdate /timer_peripheral_tb/uut/data_in
add wave -noupdate /timer_peripheral_tb/uut/address
add wave -noupdate /timer_peripheral_tb/uut/data_out
add wave -noupdate /timer_peripheral_tb/uut/ir
add wave -noupdate /timer_peripheral_tb/uut/control_reg
add wave -noupdate /timer_peripheral_tb/uut/status_reg
add wave -noupdate /timer_peripheral_tb/uut/clear_reg
add wave -noupdate /timer_peripheral_tb/uut/load_val_reg
add wave -noupdate -radix unsigned /timer_peripheral_tb/uut/current_val_reg
add wave -noupdate /timer_peripheral_tb/uut/counter_o_wire
add wave -noupdate /timer_peripheral_tb/uut/read_flags
add wave -noupdate /timer_peripheral_tb/uut/clear_toggler_lst
add wave -noupdate /timer_peripheral_tb/uut/clear_toggler
add wave -noupdate /timer_peripheral_tb/uut/counter/clk
add wave -noupdate /timer_peripheral_tb/uut/counter/en
add wave -noupdate /timer_peripheral_tb/uut/counter/reset
add wave -noupdate /timer_peripheral_tb/uut/counter/use_load
add wave -noupdate /timer_peripheral_tb/uut/counter/load_val
add wave -noupdate /timer_peripheral_tb/uut/counter/counter_o
add wave -noupdate /timer_peripheral_tb/uut/counter/counter_reg
add wave -noupdate /timer_peripheral_tb/uut/read_flags
add wave -noupdate /timer_peripheral_tb/uut/current_val_reg
add wave -noupdate -radix unsigned /timer_peripheral_tb/uut/counter_o_wire
add wave -noupdate /timer_peripheral_tb/uut/load_val_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {192029 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 277
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {147113 ps} {252756 ps}

view structure
view signals
run 750 ns
