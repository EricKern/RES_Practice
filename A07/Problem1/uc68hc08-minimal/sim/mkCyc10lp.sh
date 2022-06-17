#!/bin/bash
# not sure which library to put the primitives into ...
intel=/opt/intel/fpga/18.1/quartus/libraries/vhdl
#intel=/opt/install/intel/fpga/libraries
rm -rf cyc10lp
mkdir cyc10lp
cd cyc10lp
# altera_primitives needs relaxed rules for vhdl2008 mode!
ghdl -a --std=08 --work=altera -frelaxed-rules ${intel}/altera/altera_primitives_components.vhd
ghdl -a --std=08 --work=altera_mf ${intel}/altera_mf/altera_mf_components.vhd
ghdl -a --std=08 --work=cyclone10lp ${intel}/cyclone10lp/cyclone10lp_components.vhd
cd ..

