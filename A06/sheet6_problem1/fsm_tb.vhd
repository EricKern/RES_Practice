library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;

entity fsm_tb is
end entity;

architecture a of fsm_tb is

	signal clk_tb				: std_logic;
	signal reset_tb			: std_logic;
	signal button_tb			: std_logic;
	signal write_enable_tb	: std_logic;
	signal read_enable_tb	: std_logic;
	signal reset_line_tb		: std_logic;

	component fsm is
		port (
			clk			: in std_logic;
			reset			: in std_logic;
			button		: in std_logic;
			write_enable: out std_logic;
			read_enable	: out std_logic;
			reset_line	: out std_logic
		);
	end component;

	constant CLK_PERIOD : time := 10 ns;

begin

	uut : fsm 
	port map (
		clk => clk_tb,
		reset => reset_tb,
		button => button_tb,
		write_enable => write_enable_tb,
		read_enable => read_enable_tb,
		reset_line => reset_line_tb
	);

	-- generate the clock
	clkProc : process
	begin
		clk_tb <= '0';
		wait for CLK_PERIOD/2;
		clk_tb <= '1';
		wait for CLK_PERIOD/2;
	end process;

	testProc : process
	begin
		-- Start with nothing pressed
		button_tb <= '0';
		reset_tb <= '1';
		wait for CLK_PERIOD;
		reset_tb <= '0';
		assert write_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert read_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert reset_line_tb = '0' report "leds are not off during reset" severity failure;
		wait for CLK_PERIOD;
		
		-- Press button less than 1 second
		button_tb <= '1';
		wait for 400 ms;
		button_tb <= '0';
		wait for CLK_PERIOD;
		assert write_enable_tb = '1' report "leds are not off during reset" severity failure;
		assert read_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert reset_line_tb = '0' report "leds are not off during reset" severity failure;
		wait for CLK_PERIOD;
		assert write_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert read_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert reset_line_tb = '0' report "leds are not off during reset" severity failure;
		wait for CLK_PERIOD;
		
		-- Press button more than 1 second and less than 2 seconds
		button_tb <= '1';
		wait for 1500 ms;
		button_tb <= '0';
		wait for CLK_PERIOD;
		assert write_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert read_enable_tb = '1' report "leds are not off during reset" severity failure;
		assert reset_line_tb = '0' report "leds are not off during reset" severity failure;
		wait for CLK_PERIOD;
		assert write_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert read_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert reset_line_tb = '0' report "leds are not off during reset" severity failure;
		wait for CLK_PERIOD;
		
		-- Press button more than 2 seconds
		button_tb <= '1';
		wait for 2100 ms;
		button_tb <= '0';
		wait for CLK_PERIOD;
		assert write_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert read_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert reset_line_tb = '1' report "leds are not off during reset" severity failure;
		wait for CLK_PERIOD;
		assert write_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert read_enable_tb = '0' report "leds are not off during reset" severity failure;
		assert reset_line_tb = '0' report "leds are not off during reset" severity failure;
		
		report "No errors" severity note;
		wait ;
	end process;
end a;
