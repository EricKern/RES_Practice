library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use work.mypackage.all;

entity TreeAdd is
  port(
    clk     : in std_logic;
    inputs  : in addInput;
  	reset		: in std_logic;
  	sum_out	: out signed (intermediate_wires_width downto 0) := (others =>'0')
  );
end entity;

architecture logic of TreeAdd is
  

  -- num_inputs-3: there are (num_inputs-1) Inputs and therefore two l ess intermediate_wires
  type WireType is array (num_inputs-3 downto 0) of signed (intermediate_wires_width downto 0);

  signal intermediate_wires : WireType := (others=>(others =>'0'));


begin

  process(clk)
  begin
    if (rising_edge(clk)) then
      for i in 0 to (num_inputs)/2-1 loop
        if i > 0 then
          intermediate_wires(2*i - 1) <= resize(inputs(2*i), intermediate_wires(i)'LENGTH) + resize(inputs(2*i+1), intermediate_wires(i)'LENGTH);


          -- intermediate_wires(i) <= resize(inputs(i), intermediate_wires(i)'LENGTH) + resize(inputs(i), intermediate_wires(i)'LENGTH);
        else
          intermediate_wires(0) <= resize(inputs(2*i),intermediate_wires(i)'LENGTH) + resize(inputs(2*i+1), intermediate_wires(i)'LENGTH);
        end if;
      end loop;

      for j in 1 to (num_inputs)/2-2 loop
        intermediate_wires(2*j) <= intermediate_wires(2*j-1) + intermediate_wires(2*j-2);
      end loop;

    sum_out <= intermediate_wires(intermediate_wires'LENGTH-1) + intermediate_wires(intermediate_wires'LENGTH-2);

    end if;
  end process;

end architecture logic;
