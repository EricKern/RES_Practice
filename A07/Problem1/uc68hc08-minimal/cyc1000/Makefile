###################################################################
# Origin: https://github.com/mfischer/Altera-Makefile/blob/master/quartus/Makefile
###################################################################

###################################################################
# Project Configuration:
#
# Specify the name of the design (project) and the Quartus II
# Settings File (.qsf)
###################################################################

PROJECT = hc08_mini
TOP_LEVEL_ENTITY = hc08_mini
ASSIGNMENT_FILES = $(PROJECT).qpf $(PROJECT).qsf

###################################################################
# Part, Family, Boardfile DE1 or DE2
FAMILY = "Cyclone 10 LP"
PART = 10CL025YU256C8G
#BOARDFILE = DE2Pins
###################################################################

###################################################################
# Setup your sources here
SRCS = \
../hdl/arch/hc08_mini_cyc.vhd \
../hdl/eprom_defs_pack.vhd \
../sw/mem_simple.vhd \
../ip/cycSdram/clkbuf_altclkctrl_0.v \
../hdl/arch/ramRom_s.vhd \
../hdl/arch/ramRom_d_cyc.vhd \
../hdl/arch/clkgen_cyc1000.vhd \
../hdl/arch/clkgen_cyc.vhd \
../hdl/uart_tx.vhd \
../hdl/uart_rx.vhd \
../hdl/uart.vhd \
../hdl/hc08_div.vhd \
../hdl/hc08_core.vhd \
../hdl/gpio.vhd \
../hdl/fifo.vhd \
../hdl/bootCtl.vhd \
../hdl/baudPack.vhd \
../hdl/baudgen.vhd \
../hdl/hc08_math.vhd \
../hdl/hc08_mul.vhd \
../hdl/ramRom.vhd \
../hdl/hc08_top.vhd \
hc08.sdc \
hc08.stp


###################################################################
# Main Targets
#
# all: build everything
# clean: remove output files and database
# program: program your device with the compiled design
###################################################################

all: smart.log $(PROJECT).asm.rpt $(PROJECT).sta.rpt

clean:
	rm -rf *.rpt *.chg smart.log *.htm *.eqn *.pin *.sof *.pof db incremental_db

map: smart.log $(PROJECT).map.rpt
fit: smart.log $(PROJECT).fit.rpt
asm: smart.log $(PROJECT).asm.rpt
sta: smart.log $(PROJECT).sta.rpt
smart: smart.log

###################################################################
# Executable Configuration
###################################################################

MAP_ARGS = --read_settings_files=on $(addprefix --source=,$(SRCS))

FIT_ARGS = --part=$(PART) --read_settings_files=on
ASM_ARGS =
STA_ARGS =

###################################################################
# Target implementations
###################################################################

STAMP = echo done >

$(PROJECT).map.rpt: map.chg $(SOURCE_FILES)
	quartus_map $(MAP_ARGS) $(PROJECT)
	$(STAMP) fit.chg

$(PROJECT).fit.rpt: fit.chg $(PROJECT).map.rpt
	quartus_fit $(FIT_ARGS) $(PROJECT)
	$(STAMP) asm.chg
	$(STAMP) sta.chg

$(PROJECT).asm.rpt: asm.chg $(PROJECT).fit.rpt
	quartus_asm $(ASM_ARGS) $(PROJECT)

$(PROJECT).sta.rpt: sta.chg $(PROJECT).fit.rpt
	quartus_sta $(STA_ARGS) $(PROJECT)

smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(PROJECT) > smart.log

###################################################################
# Project initialization
###################################################################

#$(ASSIGNMENT_FILES):
#	quartus_sh --prepare -f $(FAMILY) -t $(TOP_LEVEL_ENTITY) $(PROJECT)
#	-cat $(BOARDFILE) >> $(PROJECT).qsf

map.chg:
	$(STAMP) map.chg
fit.chg:
	$(STAMP) fit.chg
sta.chg:
	$(STAMP) sta.chg
asm.chg:
	$(STAMP) asm.chg

###################################################################
# Programming the device
###################################################################

program: output_files/$(PROJECT).sof
	quartus_pgm --no_banner --mode=jtag -o "P;output_files/$(PROJECT).sof"


