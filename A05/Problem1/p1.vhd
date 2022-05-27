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

entity p1 is
port(
  CLK12M    : in std_logic;
  USER_BTN  : in std_logic;
  LED       : out std_logic_vector(7 downto 0)
);
end entity p1;

architecture rtl of p1 is

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


begin
	uut : counter
	generic map (bit_width => 28)
	port map(
		clk 		=> CLK12M,
		reset		=> USER_BTN,
		counter_o (27 downto 20)	=> LED
	);

end rtl;