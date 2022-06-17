library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity load_counter is
  generic (
		bit_width: integer := 4
	);
  port(
  	clk			: in std_logic;
	en				: in std_logic;
  	reset			: in std_logic;
	use_load		: in std_logic;
	load_val		: in std_logic_vector(bit_width-1 downto 0);
  	counter_o	: out std_logic_vector(bit_width-1 downto 0)
  );
end entity;

architecture arch1 of load_counter is

	constant all_zeros : std_logic_vector(counter_o'range) := (others => '0');
	
	
	
	signal counter_reg : std_logic_vector(bit_width-1 downto 0);
	signal actual_load_val : std_logic_vector(bit_width-1 downto 0);

  begin
	 actual_load_val <= load_val when use_load = '1' else (others => '1');
  
  
    process(clk, reset, actual_load_val)
    begin
      if(reset = '1') then
			counter_reg <= actual_load_val;
      elsif (rising_edge(clk)) then
			if(en = '1') then
				if(counter_reg = all_zeros) then -- checks if all zeros
					if use_load = '1' then
						counter_reg <= load_val;
					else
						counter_reg <= std_logic_vector( unsigned(counter_reg) - 1 );
					end if;
				else
					counter_reg <= std_logic_vector( unsigned(counter_reg) - 1 );
				end if;
				
			else
				counter_reg <= counter_reg;
			end if;
			
      end if;
    end process;

    counter_o <= counter_reg;

end architecture arch1;

