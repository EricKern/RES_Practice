----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    12:15:23 07/27/2017
-- Design Name:
-- Module Name:    ramRom_d - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- need for simulation
-- synthesis translate_off
use work.eprom_defs_pack.all;
use work.eprom_pack.all;
-- synthesis translate_on


entity ramRom_d is
	generic (
			mabits: integer := 14; -- changes here require update of bmm file
			simulation: boolean := false;
			xilinx: boolean := true
	 );
    PORT(
        -- cpu side
         uclk : IN  std_logic;
         uwr : IN  std_logic;
         uaddr : in  std_logic_vector(mabits - 1 downto 0);
         udin : in  std_logic_vector(7 downto 0);
         udout : out  std_logic_vector(7 downto 0);
         -- boot side
         bclk : IN  std_logic;
         bwr : IN  std_logic;
         baddr : in  std_logic_vector(mabits - 1 downto 0);
         bdin : in  std_logic_vector(7 downto 0);
         bdout : out  std_logic_vector(7 downto 0)
        );
end ramRom_d;

architecture Behavioral of ramRom_d is

-- data ram
	type lramType is array(0 to 2**mabits - 1) of std_logic_vector(7 downto 0) ;
	-- function to initialize ram from eprom. works for both sim and syn
	-- but is used here for sim only
	function initRamFromRom(size:integer) return lramType is
	variable r : lramType := (others => X"00");
	begin
-- synthesis translate_off
		for i in 0 to size - 1 loop
			r(i) := eprom_rom(65536 - size + i);
		end loop;
-- synthesis translate_on
		return r;
	end function;
	-- Xilinx: use a shared variable for the DPR
	shared variable lram: lramType := InitRamFromRom(2**mabits);


begin

	-- instruction/data ram
	urdram:process
	begin
		wait until rising_edge(uclk);
		udout <= lram(to_integer(unsigned(uaddr)));
	end process;

	uwrram:process
	begin
		wait until rising_edge(uclk);
		if uwr = '1' then
			lram(to_integer(unsigned(uaddr))) := udin;
		end if;
	end process;

	-- boot memory access
	brdram:process
	begin
		wait until rising_edge(bclk);
		bdout <= lram(to_integer(unsigned(baddr)));
	end process;

end Behavioral;

