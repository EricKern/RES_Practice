--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

package eprom_defs_pack is
   type eprom_rom_array is array (0 to 65535) of std_logic_vector(7 downto 0);
   constant eprom_dont_care : std_logic_vector(7 downto 0) := X"00"; -- (others=>'-');

	function eprom_entry(data:natural) return std_logic_vector;
	
end package eprom_defs_pack;

package body eprom_defs_pack is
	function eprom_entry(data:natural) return std_logic_vector is
	begin
		return std_logic_vector(to_unsigned(data,8));
	end eprom_entry;
	
end package body eprom_defs_pack;

