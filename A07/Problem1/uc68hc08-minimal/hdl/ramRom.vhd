----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    12:15:23 07/27/2017
-- Design Name:
-- Module Name:    ramRom - Behavioral
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

--! Memory abstraction with 2 ports, architecture independent.

entity ramRom is
	generic (
			dualport: boolean := true;
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
         bclk : IN  std_logic;
         bwr : IN  std_logic;
         baddr : in  std_logic_vector(mabits - 1 downto 0);
         bdin : in  std_logic_vector(7 downto 0);
         bdout : out  std_logic_vector(7 downto 0)
        );
end ramRom;

architecture Behavioral of ramRom is

	COMPONENT ramRom_d
	generic (
			mabits: integer := 14; -- changes here require update of bmm file
			simulation: boolean := false
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
	END COMPONENT;

	COMPONENT ramRom_s
	generic (
			mabits: integer := 14; -- changes here require update of bmm file
			simulation: boolean := false
	 );
    PORT(
        -- cpu side
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
	END COMPONENT;

begin

	dr: if dualport generate
	begin

		-- instruction/data ram
		rr: ramRom_d
		generic map(
				mabits => mabits,
				simulation => simulation
		)
		PORT MAP(
			uclk => uclk,
			uwr => uwr,
			uaddr => uaddr,
			udin => udin,
			udout => udout,
			bclk => bclk,
			bwr => bwr,
			baddr => baddr,
			bdin => bdin,
			bdout => bdout
		);

	end generate;

	sr: if not dualport generate
	begin

		-- instruction/data ram
		rr: ramRom_s
		generic map(
				mabits => mabits,
				simulation => simulation
		)
		PORT MAP(
			uclk => uclk,
			uwr => uwr,
			uaddr => uaddr,
			udin => udin,
			udout => udout,
			bctl => bctl,
			bwr => bwr,
			baddr => baddr,
			bdin => bdin,
			bdout => open
		);

	end generate;

end Behavioral;

