library ieee;
use ieee.std_logic_1164.all;

entity shift_register_tb is
end entity;

architecture test of shift_register_tb is

component shift_register is
generic (
	bit_width : positive := 4
);
port(
	clk		: in std_logic;
	reset	: in std_logic;
	din		: in std_logic;
	dout	: out std_logic_vector(bit_width-1 downto 0)
);
end component;

signal clk		:  std_logic;
signal reset	:  std_logic;
signal din		:  std_logic;
signal dout		:  std_logic_vector(3 downto 0);

begin

	uut : shift_register
	generic map (bit_width => 4)
	port map(
		clk 	=> clk,
		reset 	=> reset,
		din		=> din,
		dout	=> dout
	);

-- brute force, just manually toggling signals
process
begin
	reset <= '1';
	clk	  <= '0';
	din	  <= '0';
	wait for 10 ns;
	reset <= '0';
	wait for 10 ns;

	assert dout = "0000" report "shift register pattern mismatch!" severity failure;
	wait for 5 ns;

	din	 <= '1';
	wait for 5 ns;
	clk	 <= '1';
	wait for 5 ns;
	clk  <= '0';

	assert dout = "1000" report "shift register pattern mismatch!" severity failure;
	wait for 5 ns;

	din	 <= '0';
	wait for 5 ns;
	clk	 <= '1';
	wait for 5 ns;
	clk  <= '0';

	assert dout = "0100" report "shift register pattern mismatch!" severity failure;
	wait for 5 ns;

	din	 <= '1';
	wait for 5 ns;
	clk	 <= '1';
	wait for 5 ns;
	clk  <= '0';

	assert dout = "1010" report "shift register pattern mismatch!" severity failure;
	wait for 5 ns;

	din	 <= '1';
	wait for 5 ns;
	clk	 <= '1';
	wait for 5 ns;
	clk  <= '0';

	assert dout = "1101" report "shift register pattern mismatch!" severity failure;
	wait for 5 ns;

	din	 <= '0';
	wait for 5 ns;
	clk	 <= '1';
	wait for 5 ns;
	clk  <= '0';

	assert dout = "0110" report "shift register pattern mismatch!" severity failure;
	wait for 5 ns;

	reset <= '1';
	wait for 10 ns;
	assert dout = "0000" report "shift register pattern mismatch!" severity failure;

	wait for 10 ns;
    report "No errors" severity note;
	wait ;

end process;

end test;
