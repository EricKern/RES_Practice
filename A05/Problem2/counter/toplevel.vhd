--------------------------------------------------------------------------------
-- Design     : toplevel
  
-- Author     : Sebastian DITTMEIER
-- Created    : 13.05.2022 Last Modified: xx.xx.xxxx
-- Comments   : Simple interface with minimal ports for the CYC1000 FPGA board
--          
-- xx.yy.zzzz : note on changes; author LASTNAME
----------------
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

signal inner_clock	:  std_logic;
signal inner_reset	:  std_logic;
signal not_user_btn	:  std_logic;
signal counter_o	:  std_logic_vector(31 downto 0);

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

component mypll is
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0				: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
end component;

begin

-- instantation section

uut : counter
	generic map (bit_width => 32) -- for visibility a larger counter was created (32 instad of 8)
	port map(
		clk 		=> inner_clock,
		reset		=> inner_reset,
		counter_o	=> counter_o
	);
	
timer: mypll
	port map(
		areset		=> not_user_btn,
		inclk0		=> CLK12M,
		c0		      => inner_clock,
		locked		=> inner_reset);

not_user_btn <= NOT USER_BTN;
LED <= counter_o(24 downto 17);

end rtl;