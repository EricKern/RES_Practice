library ieee;
use ieee.numeric_std.all;


package mypackage is
    constant num_inputs : positive  := 6; -- works for even number of inputs
    constant bit_width : positive  := 6;
    type addInput is array (num_inputs-1 downto 0) of signed (bit_width-1 downto 0);
    -- type addInput is array (0 to 31) of integer range 0 to 255;
    -- type addInput is array (num_inputs downto 0) of signed range -(2**(bit_width-1)) to 2**(bit_width-1)-1;
end package;