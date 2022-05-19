LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;
use work.mypackage.all;
 
ENTITY treeadd_tb IS
END treeadd_tb;
 
ARCHITECTURE behavior OF treeadd_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT TreeAdd IS
    port(
        clk     : in std_logic;
        inputs  : in addInput;
        reset	: in std_logic;
        sum_out	: out signed (bit_width downto 0)
      );
    END COMPONENT;


    signal tb_input : addInput := (others=>(others =>'0'));
    signal tb_reset : std_logic := '0';
    signal tb_sum_out	: signed (bit_width downto 0);

    signal clk_tb : std_logic := '0';

    constant ckTime : time := 10 ns;
 
BEGIN-- Instantiate the Unit Under Test (UUT)
    uut: TreeAdd PORT MAP(
        clk         => clk_tb,
        inputs      => tb_input,
        reset       => tb_reset,
        sum_out     => tb_sum_out
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
        report "No errors" severity note;
        wait ;
    end process;
 

END;