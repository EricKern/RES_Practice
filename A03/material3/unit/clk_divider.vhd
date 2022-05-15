LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;

ENTITY clk_divider IS
	PORT(clock : IN	STD_LOGIC;
         div_factor: IN positive :=2; -- only defined for div_factor >= 2
		 clock_0	: OUT	STD_LOGIC := '0';
         clock_1	: OUT	STD_LOGIC := '0';
         clock_2	: OUT	STD_LOGIC := '0');
END clk_divider ;

ARCHITECTURE a_clk_divider  OF clk_divider  IS
    constant numerator    : INTEGER := 35;
    constant denominator  : INTEGER := 6;
    constant rounded_div  : INTEGER := 6;

    signal my_count : INTEGER  := -2; -- doesn't initialize correctly? Allways 2 too much

    signal my_count2 : INTEGER  := -2; -- doesn't initialize correctly? Allways 2 too much
    signal my_count3 : INTEGER  := -2; -- doesn't initialize correctly? Allways 2 too much

    signal o0_buf   : std_logic := '0';
    signal o1_buf   : std_logic := '0';
    signal o2_buf   : std_logic := '0';
begin

    -- rising and falling edge counter
PROCESS (clock)
BEGIN
    if my_count /= div_factor-1 then
        my_count <= my_count + 1;
    else
        my_count <= 0;
    end if;

END PROCESS;

-- rising and falling edge counter2
PROCESS (clock)
BEGIN
    if my_count2 /= rounded_div-1 then
        my_count2 <= my_count2 + 1;
    else
        my_count2 <= 0;
    end if;

    if my_count3 /= numerator-1 then
        my_count3 <= my_count3 + 1;
    else
        my_count3 <= 0;
        my_count2 <= 0;
    end if;

END PROCESS;

process(my_count)
begin
    if my_count = 0 then
		o0_buf <= not o0_buf;
    end if;
    
    if my_count = 0 then
		o1_buf <= not o1_buf;
    end if;

end process;

process(my_count2, my_count3)
begin
  if my_count2 = 0 OR my_count3 = 0 then
		o2_buf <= not o2_buf;
  end if;

end process;

clock_0 <= o0_buf;
clock_1 <= o1_buf;
clock_2 <= o2_buf;

end ARCHITECTURE;