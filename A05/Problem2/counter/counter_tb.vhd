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

--component mypll IS
--	PORT
--	(
--		areset		: IN STD_LOGIC  := '0';
--		inclk0		: IN STD_LOGIC  := '0';
--		c0				: OUT STD_LOGIC ;
--		locked		: OUT STD_LOGIC 
--	);
--END component;

signal clk			:  std_logic;
signal reset		:  std_logic;
signal counter_o	:  std_logic_vector(3 downto 0);

constant CLK_PERIOD : time := 10 ns;

begin

	uut : counter
	generic map (bit_width => 4)
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
	assert counter_o = x"0" report "counter mismatch!" severity failure;
	reset <= '0';
	wait for CLK_PERIOD;
	assert counter_o = x"1" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"2" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"3" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"4" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"5" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"6" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"7" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"8" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"9" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"A" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"B" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"C" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"D" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"E" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"F" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"0" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"1" report "counter mismatch!" severity failure;
	reset <= '1';
	wait for CLK_PERIOD;
	assert counter_o = x"0" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
	assert counter_o = x"0" report "counter mismatch!" severity failure;
	wait for CLK_PERIOD;
    report "No errors" severity note;
	wait ;

end process;

end test;
