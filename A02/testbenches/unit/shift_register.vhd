library ieee;
use ieee.std_logic_1164.all;

entity shift_register is
	generic (
		bit_width: integer := 4
	);
	port (
		clk		: in std_logic;
		reset	: in std_logic;
		din		: in std_logic;
		dout	: out std_logic_vector(bit_width-1 downto 0)
	);
end entity;


architecture my_shift_reg of shift_register is

  signal dout_reg : std_logic_vector(bit_width-1 downto 0);

  begin
    process(clk, reset)
  	begin
  		if(reset = '1') then
        dout_reg <= (others => '0');
  		elsif (rising_edge(clk)) then
        dout_reg <= din & dout_reg(bit_width-1 downto 1);
  		end if;
  	end process;

    dout <= dout_reg;
end architecture my_shift_reg;
