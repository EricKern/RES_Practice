LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

 
ENTITY clk_divider_tb IS
END clk_divider_tb;
 
ARCHITECTURE behavior OF clk_divider_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT clk_divider IS
	PORT(clock : IN	STD_LOGIC;
         div_factor: IN positive;
		 clock_0	: OUT	STD_LOGIC;
         clock_1	: OUT	STD_LOGIC;
         clock_2	: OUT	STD_LOGIC);
    END COMPONENT;
 

    
   constant ckTime : time := 10 ns;

   --Inputs
   signal div_factor_tb : positive := 2;
   signal clk_tb : std_logic;

 	--Outputs
   signal clock_0_tb : std_logic;
   signal clock_1_tb : std_logic;
   signal clock_2_tb : std_logic;
 
BEGIN-- Instantiate the Unit Under Test (UUT)
    uut: clk_divider PORT MAP(
        clock       => clk_tb,
        div_factor  => div_factor_tb,
        clock_0     => clock_0_tb,
        clock_1     => clock_1_tb,
        clock_2     => clock_2_tb
    );
 
   -- generate the clock
   ckProc : process
   begin
      clk_tb <= '0';
      wait for ckTime/2;
      clk_tb <= '1';
      wait for ckTime/2;
   end process;


    -- Stimulus process
    testProc : process
    begin
        div_factor_tb <= 2;
        wait for 12*ckTime;
        div_factor_tb <= 4;
        wait for 12*ckTime;
        div_factor_tb <= 3;
        wait for 12*ckTime;
        div_factor_tb <= 5;
        wait for 12*ckTime;
        div_factor_tb <= 6;
        wait for 12*ckTime;

    report "No errors" severity note;
    wait ;
    end process;
 

END;