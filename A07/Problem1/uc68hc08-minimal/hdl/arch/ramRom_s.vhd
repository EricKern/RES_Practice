----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:15:23 07/27/2017 
-- Design Name: 
-- Module Name:    ramRom_s - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

-- need for simulation
-- syn -- thesis translate_off
use work.eprom_defs_pack.all;
use work.eprom_pack.all;
-- syn -- thesis translate_on


entity ramRom_s is
	generic (
			mabits: integer := 14; -- changes here require update of bmm file
			simulation: boolean := false 
	 );
    PORT(
        -- cou side
         uclk : IN  std_logic;
         uwr : IN  std_logic;
         uaddr : in  std_logic_vector(mabits - 1 downto 0);
         udin : in  std_logic_vector(7 downto 0);
         udout : out  std_logic_vector(7 downto 0);
         -- boot side
         bctl: in std_logic;
         bwr : IN  std_logic;
         baddr : in  std_logic_vector(mabits - 1 downto 0);
         bdin : in  std_logic_vector(7 downto 0);
         bdout : out  std_logic_vector(7 downto 0)
        );
end ramRom_s;

architecture Behavioral of ramRom_s is

    signal w :   std_logic;
    signal a :   std_logic_vector(mabits - 1 downto 0);
    signal d :   std_logic_vector(7 downto 0);
    signal q : std_logic_vector(7 downto 0);

         -- data ram
	type lramType is array(0 to 2**mabits - 1) of std_logic_vector(7 downto 0) ;
	-- function to initialize ram from eprom. works for both sim and syn
	-- but is used here for sim only
	function initRamFromRom(size:integer) return lramType is
	variable r : lramType := (others => X"00");
	begin
-- synt -- hesis translate_off
		for i in 0 to size - 1 loop
			r(i) := eprom_rom(65536 - size + i);
		end loop;
-- syn -- thesis translate_on
		return r;
	end function;
	-- Xilinx: use a shared variable for the DPR
	signal lram: lramType := InitRamFromRom(2**mabits); 
	

begin

    -- mux
    process(uwr,uaddr,udin,bwr,baddr,bdin,bctl)
    begin
        if bctl = '0' then
            w <= uwr;
            a <= uaddr;
            d <= udin;
        else
            w <= bwr;
            a <= baddr;
            d <= bdin;
        end if;
    end process;
    
    -- output
    udout <= q;
    bdout <= q;

	-- instruction/data ram
	rdram:process
	begin
		wait until rising_edge(uclk);
		q <= lram(to_integer(unsigned(a)));
	end process;
	
	wrram:process
	begin
		wait until rising_edge(uclk); 
		if w = '1' then
			lram(to_integer(unsigned(a))) <= d;
		end if;
	end process;

	
end Behavioral;

