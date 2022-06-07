LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;
--use work.mypackage.all;
 
ENTITY toplevel_tb IS
END entity;
 
ARCHITECTURE behavior OF toplevel_tb IS 
 
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT toplevel IS
		port(
			CLK12M    : in std_logic;
			USER_BTN  : in std_logic;
			LED       : out std_logic_vector(7 downto 0)
		);
	END COMPONENT; 

	signal clk12M_tb : std_logic;
	signal user_btn_tb : std_logic := '0';
	signal led_tb	: std_logic_vector(7 downto 0) := (others =>'0');

	constant CLK_PERIOD : time := 10 ns;
 
BEGIN-- Instantiate the Unit Under Test (UUT)
	uut: toplevel 
	PORT MAP(
		CLK12M  	=> clk12M_tb,
		USER_BTN => user_btn_tb,
		LED     	=> led_tb
	);

   -- generate the clock
	clkProc : process
	begin
		clk12M_tb <= '0';
		wait for CLK_PERIOD/2;
		clk12M_tb <= '1';
		wait for CLK_PERIOD/2;
	end process;

    -- Stimulus process
	testProc : process
	begin 
		--write test
		user_btn_tb <= '0';
		wait for 150000000*CLK_PERIOD; -- do 150.000.000 count cycles
		user_btn_tb <= '1';
		wait for 500 ms; -- do 50.000.000 count cycles
		user_btn_tb <= '0';
		wait for CLK_PERIOD;
		--200.000.000 counter => 1011 1110 1011 1100 0010 0000 0000  (unsigned)
		assert led_tb = "00001011" report "Addition faild, expected result: 2" severity failure;
		wait for CLK_PERIOD;
		
		--read test
		user_btn_tb <= '1';
		wait for 1500 ms; -- do 150.000.000 count cycles
		user_btn_tb <= '0';
		wait for CLK_PERIOD;
		--350.000.002 counter => 1011 1110 1011 1100 0010 0000 0010  (unsigned)
		assert led_tb = "10111011" report "Addition faild, expected result: 2" severity failure;
		wait for CLK_PERIOD;
		
		--write test 2
		user_btn_tb <= '1';
		wait for 500 ms; -- do 50.000.000 count cycles
		user_btn_tb <= '0';
		wait for CLK_PERIOD;
		--400.000.004 counter => 1 0111 1101 0111 1000 0100 0000 0100 (unsigned)
		assert led_tb = "10110111" report "Addition faild, expected result: 2" severity failure;
		wait for CLK_PERIOD;
		
		--reset test 
		user_btn_tb <= '1';
		wait for 2500 ms; -- do 250.000.000 count cycles
		user_btn_tb <= '0';
		wait for CLK_PERIOD;
		--650.000.006 counter => 10 0110 1011 1110 0011 0110 1000 0110 (unsigned)
		assert led_tb = "00000000" report "Addition faild, expected result: 2" severity failure;
		wait for CLK_PERIOD;

		report "No errors" severity note;
		wait ;
	end process;
END;