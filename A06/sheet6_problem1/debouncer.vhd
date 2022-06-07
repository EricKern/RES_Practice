LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;

ENTITY debouncer IS
	PORT(
		button_in 	: IN	STD_LOGIC;
		clock 		: IN	STD_LOGIC;
		dbounc_out	: OUT	STD_LOGIC
	);
END debouncer;

ARCHITECTURE a_debouncer  OF debouncer  IS

	component counter is
		generic (
			bit_width : positive
		);
		port(
			clk			: in std_logic;
			reset			: in std_logic;
			counter_o	: out std_logic_vector(bit_width-1 downto 0)
		);
	end component;

	constant max_count: positive := 1000;

	signal debounce_buf  :  std_logic := '0';
	signal reset_count   : std_logic := '0';
	signal counter_reg   : std_logic_vector(10-1 downto 0) := (others => '0');
	
	begin

	my_counter : counter
	generic map (bit_width => 10)
	port map(
		clk 			=> clock,
		reset			=> reset_count,
		counter_o	=> counter_reg
	);

	-- Debounce Button: Filters out mechanical switch bounce for around 40Ms.
	-- Debounce clock should be approximately 10ms
	process(clock, button_in)
	begin
		if button_in = debounce_buf then
			reset_count <= '1';
		else
			-- counter counts up
			reset_count <= '0';
			if unsigned(counter_reg) = max_count then
				debounce_buf <= not debounce_buf;
			end if;
		end if;
	end process;
	
	dbounc_out <= debounce_buf;
	
end ARCHITECTURE;