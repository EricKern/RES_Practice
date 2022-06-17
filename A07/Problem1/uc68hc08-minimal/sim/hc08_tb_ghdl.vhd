--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:00:38 07/27/2017
-- Design Name:   
-- Module Name:   /home/kugel/temp/hc08//hc08_tb.vhd
-- Project Name:  hc08
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: X68UR08
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

-- !!! the memory settings must match software compiler configuration !!!
 
ENTITY hc08_tb_ghdl IS
	generic (
            ni: integer := 8; -- number of 4k blocks instruction ram
            nd: integer := 2; -- number of 4k blocks data ram
            mb: integer := 16; -- total number of address bits
			dualport: boolean := false; --true;
			mhz: integer := 25;
			pwms: integer := 4;
			hasVideo: boolean := true;
			hasI2c: boolean := true;
			hasSpi: boolean := false;
			hasSdram: boolean := true;
			simulation: boolean := true
	 );
END hc08_tb_ghdl;
 
ARCHITECTURE behavior OF hc08_tb_ghdl IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT hc08_tb
	generic (
            ni: integer := 2; -- number of 4k blocks instruction ram
            nd: integer := 2; -- number of 4k blocks data ram
            mb: integer := 16; -- total number of address bits
			dualport: boolean := false; --true;
			mhz: integer := 30;
			pwms: integer := 6;
			hasVideo: boolean := false;
			hasI2c: boolean := true;
			hasSpi: boolean := false;
			hasSdram: boolean := true;
			simulation: boolean := false
	 );
    END COMPONENT;

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: hc08_tb 
		generic map (
                ni => ni,
                nd => nd,
                mb => mb,
		dualport => dualport,
			mhz => mhz,
			pwms => pwms,
			hasVideo => hasVideo,
			hasI2c => hasI2c,
			hasSpi => hasSpi,
			hasSdram => hasSdram,
			simulation => simulation
		);

	


END;
