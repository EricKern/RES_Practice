library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buttons_leds_tb is
end entity;

architecture test of buttons_leds_tb is

component button_leds is
  port (
    clk		: in std_logic;
    reset	: in std_logic;
    din		: in std_logic;
    leds	: out std_logic_vector(3 downto 0)
  );
end component;

signal clk			  :  std_logic;
signal reset		  :  std_logic;
signal din        :  std_logic;
signal leds	      :  std_logic_vector(3 downto 0);

constant CLK_PERIOD : time := 10 ns;

begin

	uut : button_leds
	port map(
		clk 		=> clk,
		reset		=> reset,
		din	    => din,
    leds    => leds
	);

-- clocking process
clk_proc: process
begin
	clk <= '0';
	wait for CLK_PERIOD/2;
	clk <= '1';
	wait for CLK_PERIOD/2;
end process clk_proc;

-- brute force, just manually toggling signals
process
begin
  din <= '0';
  reset <= '0';
  wait for CLK_PERIOD;
	reset <= '1';
	wait for 2*CLK_PERIOD;
	assert leds = x"0" report "leds are not off during reset" severity failure;
	reset <= '0';
	wait for CLK_PERIOD;

  din <= '1';
	--assert counter_o = x"1" report "counter mismatch!" severity failure;
	wait for 3*CLK_PERIOD;
	assert leds = "0111" report "counter mismatch!" severity failure;

	wait for CLK_PERIOD;
    report "No errors" severity note;
	wait ;

end process;

end test;
