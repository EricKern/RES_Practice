library ieee;
use ieee.numeric_std.all;
use IEEE.math_real.all;
-- USE ieee.math_real.log2;
-- USE ieee.math_real.ceil;

package mypackage is
    constant num_inputs : positive  := 6; -- works for even number of inputs
    constant bit_width : positive  := 6;
    constant intermediate_wires_width : positive := bit_width+num_inputs/2 - 1;
    -- constant intermediate_wires_width : positive := INTEGER( ceil( log2 ( real((2**bit_width)-1 * num_inputs))));

    type addInput is array (num_inputs-1 downto 0) of signed (bit_width-1 downto 0);
    -- type addInput is array (0 to 31) of integer range 0 to 255;
    -- type addInput is array (num_inputs downto 0) of signed range -(2**(bit_width-1)) to 2**(bit_width-1)-1;
end package;