LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;
--use work.mypackage.all;

entity counter_tb is
end entity;

architecture test of counter_tb is

component counter is
generic (
	bit_width : positive := 32
);
port(
	clk			: in std_logic;
	reset		: in std_logic;
	counter_o	: out std_logic_vector(bit_width-1 downto 0)
);
end component;

signal clk			:  std_logic;
signal reset		:  std_logic;
signal counter_o	:  std_logic_vector(31 downto 0);

constant CLK_PERIOD : time := 83.333333 ns; --10ns

begin

	uut : counter
	generic map (bit_width => 32)
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
	assert to_integer(unsigned(counter_o)) = 0 report "counter mismatch!" severity failure;
	reset <= '0';
	wait for CLK_PERIOD;
	assert to_integer(unsigned(counter_o)) = 1 report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert to_integer(unsigned(counter_o)) = 2 report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert to_integer(unsigned(counter_o)) = 3 report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert to_integer(unsigned(counter_o)) = 4 report "counter mismatch!" severity failure;
	wait for 5*CLK_PERIOD;
	assert to_integer(unsigned(counter_o)) = 9 report "counter mismatch!" severity failure;
	reset <= '1';
	wait for CLK_PERIOD;
	assert to_integer(unsigned(counter_o)) = 0 report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert to_integer(unsigned(counter_o)) = 0 report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
   report "No errors" severity note;
	wait ;

end process;

end test;
