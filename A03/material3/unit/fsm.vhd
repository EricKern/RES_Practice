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

port (clk: in std_logic;
      reset : in std_logic;
	  d_in: in std_logic;
	  led: out std_logic);
end entity;

architecture a of fsm is
    constant counter_width : positive := 4;

	-- fsm states
	type fsmStates is (State0, State1, State2, State3);
	signal current_state, next_state: fsmStates := State0;

    signal counter_reg: std_logic_vector(counter_width-1 downto 0) := (others => '0');
    signal reset_count: std_logic := '0';
    signal reached_4: std_logic := '0';

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

    state2_counter : counter
	generic map (bit_width => 4)
	port map(
		clk 		=> clk,
		reset		=> reset_count,
		counter_o	=> counter_reg
	);

    reached_4 <= '1' when unsigned(counter_reg) >= 3 else '0';

	-- combinatorial input stage
	ip: process(d_in, current_state, reached_4)
	begin
		-- in the combinatorial stage we need a default assignement for next_state
		-- to prevent latch inference and to enable FSM detection
		next_state <= current_state after 1 ns; -- default assignement

		case current_state is
			when State0 =>
				if  d_in = '1' then
					next_state <= State1 after 1 ns;
                    reset_count <= '1';
				end if;

			when State1 =>
				if  d_in = '1' then
                    reset_count <= '0';
				else
                    reset_count <= '1';
					next_state <= State0 after 1 ns;
				end if;

                if reached_4 = '1' then
                    next_state <= State2 after 1 ns;
                end if;

			when State2 =>
				if  d_in = '1' then
					next_state <= State3 after 1 ns;
				else
                    next_state <= State0 after 1 ns;
				end if;

			when State3 =>
				if  d_in = '0' then
					next_state <= State0 after 1 ns;
				end if;

			when others =>
				-- shouldn't happen
				assert true report "FSM has encountered an invalid state" severity failure;
				next_state <= State0 after 1 ns;

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
        when State0 =>
            led <= '0' after 1 ns;
        when State1 =>
            led <= '0' after 1 ns;
        when State2 =>
            led <= '1' after 1 ns;
        when State3 =>
            led <= '0' after 1 ns;
        when others =>
            led <= '0' after 1 ns;
        end case;
	end process;
end a;