library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity counter is
  generic (
		bit_width: integer := 4
	);
  port(
  	clk			: in std_logic;
  	reset		: in std_logic;
  	counter_o	: out std_logic_vector(bit_width-1 downto 0)
  );
end entity;

architecture my_counter of counter is

  signal counter_reg : std_logic_vector(bit_width-1 downto 0);

  begin
    process(clk, reset)
    begin
      if(reset = '1') then
        counter_reg <= (others => '0');
      elsif (rising_edge(clk)) then
        counter_reg <= std_logic_vector( unsigned(counter_reg) + 1 );
      end if;
    end process;

    counter_o <= counter_reg;

end architecture my_counter;
