library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
  port(
  	clk			: in std_logic;
  	input		: in std_logic;
  	output	: out std_logic
  );
end entity;

architecture my_edge_detector of edge_detector is

  signal input_buffer : std_logic_vector(1 downto 0);

  begin
    process(clk)
    begin
    	if rising_edge(clk) then
      		input_buffer(1) <= input_buffer(0);
			    input_buffer(0) <= input;
      end if;
    end process;

    output <= '1' when (input_buffer(0) /= input_buffer(1)) else '0';

end architecture my_edge_detector;
