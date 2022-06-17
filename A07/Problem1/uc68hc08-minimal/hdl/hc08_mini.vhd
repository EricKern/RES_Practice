----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:15:23 07/27/2017 
-- Design Name: 
-- Module Name:    hc08_top - Behavioral 
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

entity hc08_mini is
	generic (
			mabits: integer := 13; -- actual size is 2x
			dualport: boolean := false; --true;
			-- spartan6 runs at 30MHz, spartan3 at 20MHz, Lattice MachXO3 at 7.5MHz (use value: 8)
			mhz: integer := 25; -- 12 mhz input
            gpInvIn: boolean := false; -- invert input
            gpInvOut: boolean := false; -- invert output
	        cgmult: integer := 2;
			hasVideo: boolean := true;
			pwms: integer := 0;
			hasI2c: boolean := false;
			hasSpi: boolean := false;
			simulation: boolean := false
	 );
    PORT(
         clk : IN  std_logic;
         rst_n : IN  std_logic;
         rx : IN  std_logic;
         tx : out  std_logic;
			gpin: in std_logic_vector(7 downto 0);
			gpout: out std_logic_vector(7 downto 0);
        vgaHS : out std_logic;
        vgaVS : out std_logic;
        vgaR : out std_logic;
        vgaG : out std_logic;
        vgaB : out std_logic;
         pulse: out std_logic_vector(pwms - 1 downto 0);
		miso    : IN     STD_LOGIC;                             --master in, slave out
		sclk    : out STD_LOGIC;                             --spi clock
		ss_n    : out STD_LOGIC;   			     --slave select
		mosi    : OUT    STD_LOGIC;                             --master out, slave in
        sda       : inOUT  STD_LOGIC;
        scl       : inOUT  STD_LOGIC
        );
end hc08_mini;

architecture Behavioral of hc08_mini is

    COMPONENT hc08_top
	generic (
			mabits: integer := 14; -- changes here require update of bmm file
			dualport: boolean := false; --true;
			mhz: integer := 30;
            gpInvIn: boolean := false; -- invert input
            gpInvOut: boolean := false; -- invert output
	        cgmult: integer := 2; 
			hasVideo: boolean := true;
			pwms: integer := 6;
			hasI2c: boolean := true;
			hasSpi: boolean := false;
			simulation: boolean := false
                );
    PORT(
         clk : IN  std_logic;
         rst_n : IN  std_logic;
         rx : IN  std_logic;
         tx : out  std_logic;
        vgaHS : out std_logic;
        vgaVS : out std_logic;
        vgaR : out std_logic;
        vgaG : out std_logic;
        vgaB : out std_logic;
         pulse: out std_logic_vector(pwms - 1 downto 0);
        sda       : inOUT  STD_LOGIC;
        scl       : inOUT  STD_LOGIC;
		miso    : IN     STD_LOGIC;                             --master in, slave out
		sclk    : out STD_LOGIC;                             --spi clock
		ss_n    : out STD_LOGIC;   			     --slave select
		mosi    : OUT    STD_LOGIC;                             --master out, slave in
			gpin: in std_logic_vector(7 downto 0);
			gpout: out std_logic_vector(7 downto 0)
        );
    END COMPONENT;

begin

   uc: hc08_top 
		generic map (
            mabits => mabits,
            dualport => dualport,
			mhz => mhz,
			gpInvIn => gpInvIn,
			gpInvOut => gpInvOut,
			hasVideo => hasVideo,
			pwms => pwms,
			hasI2c => hasI2c,
			hasSpi => hasSpi,
			simulation => simulation
		)
		PORT MAP (
          clk => clk,
          rst_n => rst_n,
			 rx => rx,
			 tx => tx,
            vgaHS  => vgaHs,
            vgaVS => vgaVs,
            vgaR => vgaR,
            vgaG => vgaG,
            vgaB => vgaB,
			 pulse => pulse,
			 scl => scl,
			 sda => sda,
        miso => miso,
        sclk => sclk,
        ss_n => ss_n,
        mosi => mosi,
          gpin => gpin,
          gpout => gpout
        );

	
end Behavioral;

