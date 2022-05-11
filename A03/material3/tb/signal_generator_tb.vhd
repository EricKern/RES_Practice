--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

 
ENTITY signal_generator_tb IS
END signal_generator_tb;
 
ARCHITECTURE behavior OF signal_generator_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT signal_generator
    PORT(
         period : IN  time;
         pulse_count : IN  integer;
         raw_signal : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   constant period : time := 25 ns;
   constant pulse_count : integer := 7; 

 	--Outputs
   signal raw_signal : std_logic;
 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: signal_generator PORT MAP (
          period => period,
          pulse_count => pulse_count,
          raw_signal => raw_signal
        );

 

   -- Stimulus process
   stim_proc: process
   begin		

      wait for period*10;
   end process;

END;
