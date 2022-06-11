library ieee;
use ieee.std_logic_1164.all;

entity toplevel is
	port(
		CLK12M    : in std_logic;
		USER_BTN  : in std_logic;
		LED       : out std_logic_vector(7 downto 0)
	);
end entity toplevel;

architecture rtl of toplevel is

-- declaration section
signal btn_debounced	:  std_logic;
signal btn_debounced_edge	:  std_logic;
signal button_in_wire	:  std_logic;

constant counter_width : positive := 32;
signal counter_reg : std_logic_vector(counter_width-1 downto 0) := (others => '0');
signal fifo_output : std_logic_vector(3 downto 0) := (others => '0');

signal cntr_reset	:  std_logic := '0';
signal cntr_w_en	:  std_logic := '0';
signal cntr_r_en	:  std_logic := '0';

signal fsm_reset : std_logic := '0'; --unused

signal fifo_empty : std_logic := '0';
signal fifo_full : std_logic := '0';

signal make_read_req : std_logic := '0';
signal make_write_req : std_logic := '0';

component debouncer is
port(
	button_in	: in std_logic;
	clock		: in std_logic;
	dbounc_out	: out std_logic
);
end component;

component edge_detector is
port(
	clk		: in std_logic;
	input	: in std_logic;
	output	: out std_logic
);
end component;

component fsm is
port(
	clk				: in std_logic;
	reset				: in std_logic;
	button			: in std_logic;
	write_enable	: out std_logic;
	read_enable		: out std_logic;
	reset_line		: out std_logic
);
end component;

component my_fifo is
	port
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
end component;

component counter is
generic (
	bit_width: integer := 32
);
port(
	clk			: in std_logic;
  	reset		: in std_logic;
  	counter_o	: out std_logic_vector(bit_width-1 downto 0)
);
end component;

begin

-- instantation section
button_in_wire <= NOT USER_BTN;

debouncer_top : debouncer
	port map(
		button_in	=> button_in_wire,
		clock		=> CLK12M,
		dbounc_out	=> btn_debounced
	);
	
edge_detector_top : edge_detector
	port map(
		clk		=> CLK12M,
		input	=> btn_debounced,
		output	=> btn_debounced_edge
	);

fsm_top : fsm
	port map(
		clk				=> CLK12M,
		reset				=> fsm_reset,
		button			=> btn_debounced_edge,
		write_enable	=> cntr_w_en,
		read_enable		=> cntr_r_en,
		reset_line		=> cntr_reset
	);

	make_read_req <= (NOT fifo_empty AND cntr_r_en);
	make_write_req <= (NOT fifo_full AND cntr_w_en);
	
fifo_top : my_fifo
	port map (
		aclr		=> '0',
		clock		=> CLK12M,
		data		=> counter_reg(28 downto 25),
		rdreq		=> make_read_req,
		wrreq		=> make_write_req,
		empty		=> fifo_empty,
		full		=> fifo_full,
		q			=> fifo_output
	);

-- free running counter
counter_top : counter
	generic map (bit_width => counter_width)
	port map(
		clk 		=> CLK12M,
		reset		=> cntr_reset,
		counter_o	=> counter_reg
	);
		
LED(3 downto 0) <= counter_reg(28 downto 25);
LED(7 downto 4) <= fifo_output;

end rtl;