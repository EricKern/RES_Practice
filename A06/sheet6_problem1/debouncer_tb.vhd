LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;
--use work.mypackage.all;
 
ENTITY debouncer_tb IS
END debouncer_tb;
 
ARCHITECTURE behavior OF debouncer_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
	COMPONENT debouncer
		PORT(
			button_in 	:	IN  std_logic;
			clock 		: 	IN  std_logic;
			dbounc_out 	:	OUT  std_logic
		);
	END COMPONENT;

	COMPONENT signal_generator
		PORT(
			period : IN  time;
			pulse_count : IN  integer;
			raw_signal : OUT  std_logic
		);
	END COMPONENT;

	--Clock
	constant ckTime : time := 1 us;
	signal clk_tb : std_logic;

   --Inputs
   signal period : time := 25 ns;
   signal pulse_count : integer := 7; 
   signal button_bouncy : std_logic;

 	--Outputs
   signal button_debounced : std_logic;
 
BEGIN
   -- Instantiate the Unit Under Test (UUT)
	uut : debouncer PORT MAP(
		button_in 	=> button_bouncy,
		clock			=> clk_tb,
		dbounc_out 	=> button_debounced
	);

	sig_g : signal_generator PORT MAP (
		period 		=> period,
		pulse_count => pulse_count,
		raw_signal 	=> button_bouncy
	);

	-- generate the clock
	clk_proc : process
	begin
		clk_tb <= '0';
		wait for ckTime/2;
		clk_tb <= '1';
		wait for ckTime/2;
	end process;


	-- Stimulus process
	testProc : process
	begin
		wait for 300 ns;
		period <= 1 ms;
		pulse_count <= 3;

		wait for 1 ms;
		period <= 2500 us;
		pulse_count <= 3;

		report "No errors" severity note;
		wait ;
	end process;
END;