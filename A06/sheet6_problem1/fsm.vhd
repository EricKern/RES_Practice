-- --------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------

-- typical FSM implementations use 3 stages distributed across 2 or 3 processes,
-- depending on the generation of the output signals

-- 1) Input logic
-- A combinatorial stage to define the next state depending on the current state
-- and the input conditions.
-- NEVER NEVER NEVER allow any asynchronous signal to get into the input logic !!!

-- 2) State logic
-- A sequential stages to update the current state from the next state

-- 3) Output logic
-- The third stage is used to define the outputs from the state (Moore machine) or
-- from the state and input values (Mealy machine) either by combinatorial or sequential logic
-- To generate output registers which are in-phase with the state register, you will need
-- to drive the register with the same logic used to drive the state register, either in
-- the same process or in a seperate process .
--

-- we use a simple 3-process Moore machine here
-- Note that the outputs may glitch, as they are not registered. If they drive sequential
-- logic, this is normally not a problem.

-- --------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity fsm is
	port(
		clk: in std_logic;
		reset: in std_logic;
		button: in std_logic;
		write_enable: out std_logic;
		read_enable: out std_logic;
		reset_line: out std_logic
	);
end entity;

architecture a of fsm is
	constant counter_width : positive := 26;

	-- fsm states
	type fsmStates is (State0, State1, State2, State3, State4o, State5o, State6o);
	signal current_state, next_state: fsmStates := State0;

	signal counter_reg: std_logic_vector(counter_width-1 downto 0) := (others => '0');
	signal reset_count: std_logic := '0';
	signal counter_int: integer;
	--signal reached_4: std_logic := '0';

	component counter is
	generic (
		bit_width : positive := counter_width
	);
	port(
		clk			: in std_logic;
		reset		: in std_logic;
		counter_o	: out std_logic_vector(bit_width-1 downto 0)
	);
	end component;

begin

	fsm_counter : counter
	generic map (bit_width => counter_width)
	port map(
		clk 		=> clk,
		reset		=> reset_count,
		counter_o	=> counter_reg
	);
    --reached_4 <= '1' when unsigned(counter_reg) >= 3 else '0';

	-- combinatorial input stage
	ip: process(button, counter_reg)
	begin
	-- in the combinatorial stage we need a default assignement for next_state
	-- to prevent latch inference and to enable FSM detection
	-- next_state <= current_state after 1 ns; -- default assignement

	case current_state is
		when State0 => 
			if button = '1' then -- button pressed
				reset_count <= '1';
				next_state <= State1;
			end if;
			
		when State1 => --no change button still pressed
			reset_count <= '0';
			next_state <= State2;
				
		when State2 =>
			if button = '1' then -- button was released or pressed again
				next_state <= State3;
			end if;
			
		when State3 =>
			counter_int <= to_integer(unsigned(counter_reg));
			if counter_int >= 24000000 then --longer than 2 seconds 12MHZ => Counter = 12000000
				next_state <= State4o;
			elsif counter_int >= 12000000 then -- between 1 and 2 seconds 12MHZ => Counter = 6000000
				next_state <= State5o;
			else --shorter than 1 second
				next_state <= State6o;
			end if;
			
		when State4o => --Return to start
			next_state <= State0;
			
		when State5o => --Return to start
			next_state <= State0;

		when State6o => --Return to start
			next_state <= State0;
			
		when others => -- shouldn't happen
			assert true report "FSM has encountered an invalid state" severity failure;
			next_state <= State0;
		end case;
	end process;

	-- sequential stage
	-- we don't have a reset here. If you need one, prefer synchronous reset
	-- or use a synchronized signal for the asynchronous reset
	sp: process
	begin
		wait until rising_edge(clk);
		if reset = '1' then
			current_state <= State0;
		else
			current_state <= next_state;
		end if;
	end process;

	-- combinatorial output stage
	-- the "others" clause prevents the latch in this case
	op: process(current_state) -- Moore: only state. Mealy: also senstive to inputs!
	begin
		case current_state is
			when State6o =>
				write_enable 	<= '1';
				read_enable 	<= '0';
				reset_line 		<= '0';
			when State5o =>
				write_enable 	<= '0';
				read_enable 	<= '1';
				reset_line 		<= '0';
			when State4o =>
				write_enable 	<= '0';
				read_enable 	<= '0';
				reset_line 		<= '1';
			when others =>
				write_enable 	<= '0';
				read_enable 	<= '0';
				reset_line 		<= '0';
		end case;
	end process;
end a;