LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;
--use work.mypackage.all;
 
ENTITY edge_detector_tb IS
END edge_detector_tb;

ARCHITECTURE behavior OF edge_detector_tb IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT edge_detector IS
		port(
			clk		: in std_logic;
			input		: in std_logic;
			output	: out std_logic
		);
	END COMPONENT; 


	signal clk_tb 		: std_logic := '0';
	signal input_tb	: std_logic;
	signal output_tb	: std_logic;

	constant CLK_PERIOD : time := 10 ns;

	BEGIN-- Instantiate the Unit Under Test (UUT)
		uut: edge_detector PORT MAP(
			clk      => clk_tb,
			input    => input_tb,
			output	=> output_tb
		);

		-- generate the clock
		clk_proc : process
		begin
			clk_tb <= '0';
			wait for CLK_PERIOD/2;
			clk_tb <= '1';
			wait for CLK_PERIOD/2;
		end process;


		-- Stimulus process
		testProc : process
		begin 		 
			input_tb <= '1';
			wait for CLK_PERIOD;
			assert output_tb = '1' report "failed" severity failure;
			input_tb <= '0';
			wait for CLK_PERIOD;
			assert output_tb = '1' report "failed" severity failure;
			input_tb <= '0';
			wait for 3*CLK_PERIOD;
			assert output_tb = '0' report "failed" severity failure;
			input_tb <= '1';
			wait for CLK_PERIOD;
			assert output_tb = '1' report "failed" severity failure;
			report "No errors" severity note;
			wait ;
		 end process;
END;