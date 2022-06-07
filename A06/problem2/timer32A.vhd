entity timer32A is

	port(
		clk		: in  std_logic;
		reset		: in  std_logic;
		w_ena		: in  std_logic;
		r_ena		: in  std_logic;
		data_in	: in  std_logic_vector(7 downto 0);
		address	: in  std_logic_vector(7 downto 0);
		data_out	: out std_logic_vector(7 downto 0);
		ir			: out std_logic;
	  );
end timer32A;


-- Library Clause(s) (optional)
-- Use Clause(s) (optional)

architecture arch1 of timer32A is

	-- Declarations (optional)

begin

	-- Process Statement (optional)

	-- Concurrent Procedure Call (optional)

	-- Concurrent Signal Assignment (optional)

	-- Conditional Signal Assignment (optional)

	-- Selected Signal Assignment (optional)

	-- Component Instantiation Statement (optional)

	-- Generate Statement (optional)

end arch1;
