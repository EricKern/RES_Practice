LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity load_counter_tb is
end entity;

architecture tb of load_counter_tb is

constant c_width : positive := 3;
constant CLK_PERIOD : time := 10 ns;


signal clk_tb			:  std_logic;
signal en_tb			:  std_logic;
signal reset_tb		:  std_logic;
signal use_load_tb	:  std_logic;
signal load_val_tb	:	std_logic_vector(c_width-1 downto 0);
signal counter_o_tb	:  std_logic_vector(c_width-1 downto 0);


begin

	dut : entity work.load_counter(arch1)
		generic map (bit_width => c_width)
		port map (
			clk 			=> clk_tb,
			en				=> en_tb,
			reset			=> reset_tb,
			use_load		=> use_load_tb,
			load_val		=> load_val_tb,
			counter_o	=> counter_o_tb
		);


-- clocking process
clk_proc: process
begin
	clk_tb <= '0';
	wait for CLK_PERIOD/2;
	clk_tb <= '1';
	wait for CLK_PERIOD/2;
end process clk_proc;

-- brute force, just manually toggling signals
process
begin
	en_tb <= '1';
	use_load_tb <= '0';
	load_val_tb <= "000";
	reset_tb <= '1';
	wait for 2*CLK_PERIOD;
	--assert counter_o = x"0" report "counter mismatch!" severity failure;
	reset_tb <= '0';
	wait for 9*CLK_PERIOD;
	
	use_load_tb <= '1';
	load_val_tb <= "100";
	reset_tb <= '1';
	wait for 2*CLK_PERIOD;
	reset_tb <= '0';
	wait for 9*CLK_PERIOD;
	
	en_tb <= '0';
	use_load_tb <= '0';
	load_val_tb <= "000";
	wait for 2*CLK_PERIOD;
	--assert counter_o = x"0" report "counter mismatch!" severity failure;
	reset_tb <= '0';
	wait for 9*CLK_PERIOD;
	
	use_load_tb <= '1';
	load_val_tb <= "100";
	reset_tb <= '1';
	wait for 2*CLK_PERIOD;
	reset_tb <= '0';
	wait for 9*CLK_PERIOD;


    report "No errors" severity note;
	wait ;

end process;

end tb;
