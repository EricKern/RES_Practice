library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter_tb is
end entity;

architecture test of counter_tb is

component counter is
generic (
	bit_width : positive := 4
);
port(
	clk			: in std_logic;
	reset		: in std_logic;
	counter_o	: out std_logic_vector(bit_width-1 downto 0)
);
end component;

signal clk			:  std_logic;
signal reset		:  std_logic;
signal counter_o	:  std_logic_vector(7 downto 0);

constant CLK_PERIOD : time := 83 ns;

begin

	uut : counter
	generic map (bit_width => 8)
	port map(
		clk 		=> clk,
		reset		=> reset,
		counter_o	=> counter_o
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
	reset <= '1';
	wait for 2*CLK_PERIOD;
	reset <= '0';
	wait for 5*CLK_PERIOD;


	wait ;

end process;

end test;
