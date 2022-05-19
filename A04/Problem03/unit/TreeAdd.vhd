library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.mypackage.all;

entity TreeAdd is
  port(
    clk     : in std_logic;
    inputs  : in addInput;
  	reset		: in std_logic;
  	sum_out	: out signed (bit_width+(num_inputs+1/2) downto 0)
  );
end entity;

architecture logic of TreeAdd is
  -- num_inputs-3: there are (num_inputs-1) Inputs and therefore two less intermediate_wires
  type WireType is array (0 to num_inputs-3) of signed (bit_width+(num_inputs+1/2) downto 0);

  signal intermediate_wires : WireType;


begin

  sum_out <= (others =>'0');

  process(clk)
  begin
    for i in 0 to (num_inputs)/2 loop
      if i > 0 then
        intermediate_wires(2*i - 1) <= inputs(2*i) + inputs(2*i+1);
      else
        intermediate_wires(0) <= inputs(2*i) + inputs(2*i+1);
      end if;
    end loop;

    for j in 1 to (num_inputs)/2-1 loop
      intermediate_wires(2*j) <= intermediate_wires(2*j-1) + intermediate_wires(2*j-2);
    end loop;

    sum_out <= intermediate_wires(intermediate_wires'LENGTH-1) + intermediate_wires(intermediate_wires'LENGTH-2);
  end process;

end architecture logic;
