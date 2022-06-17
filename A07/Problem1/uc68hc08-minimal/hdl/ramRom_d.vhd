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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

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
    constant depth: integer := 2**mabits;
    type rt is array (0 to depth - 1) of std_logic_vector(7 downto 0);

    type dprt is protected
        impure function geta(a: STD_LOGIC_vector) return std_logic_vector;
        impure function getb(a: STD_LOGIC_vector) return std_logic_vector;
        procedure seta(a: STD_LOGIC_vector; d: STD_LOGIC_vector);
        procedure setb(a: STD_LOGIC_vector; d: STD_LOGIC_vector);
	procedure initRamFromRom(size:integer);
    end protected dprt;

    type dprt is protected body
        variable r: rt := (others => X"00");
        impure function geta(a: STD_LOGIC_vector) return std_logic_vector is
        begin
            return r(to_integer(unsigned(a)));
        end function;

        impure function getb(a: STD_LOGIC_vector) return std_logic_vector is
        begin
            return r(to_integer(unsigned(a)));
        end function;

        procedure seta(a: STD_LOGIC_vector; d: STD_LOGIC_vector) is
        begin
            r(to_integer(unsigned(a))) := d;
        end procedure;

        procedure setb(a: STD_LOGIC_vector; d: STD_LOGIC_vector) is
        begin
            r(to_integer(unsigned(a))) := d;
        end procedure;

	procedure initRamFromRom(size:integer) is
	begin
		for i in 0 to size - 1 loop
			r(i) := eprom_rom(65536 - size + i);
		end loop;
	end procedure;

    end protected body;

    shared variable lram: dprt; -- := lram.InitRamFromRom(2**mabits);


begin

    init: process
    begin
          lram.InitRamFromRom(2**mabits);
          wait;
    end process;


    -- SIDE A
    urdram:process
    begin
            wait until rising_edge(uclk);
            udout <= lram.geta(uaddr);
    end process;

    uwrram:process
    begin
            wait until rising_edge(uclk);
            if uwr = '1' then
                    lram.seta(uaddr, udin);
            end if;
    end process;

    -- SIDE B
    brdram:process
    begin
            wait until rising_edge(bclk);
            bdout <= lram.getb(baddr);
    end process;

    bwrram:process
    begin
            wait until rising_edge(bclk);
            if bwr = '1' then
                    lram.setb(baddr, bdin);
            end if;
    end process;

end Behavioral;

