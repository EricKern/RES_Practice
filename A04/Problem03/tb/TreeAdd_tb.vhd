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
        sum_out	: out signed (intermediate_wires_width downto 0)
      );
    END COMPONENT;


    signal tb_input : addInput := (others=>(others =>'0'));
    signal tb_reset : std_logic := '0';
    signal tb_sum_out	: signed (intermediate_wires_width downto 0) := (others =>'0');

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
        tb_input(0) <= to_signed(1, tb_input(0)'length);
        tb_input(1) <= to_signed(1, tb_input(0)'length);
        wait for 5*ckTime;
        assert tb_sum_out = to_signed(2, tb_sum_out'length) report "Addition faild, expected result: 2" severity failure;

        for i in tb_input(0)'RANGE loop
            tb_input(i) <= to_signed(31, tb_input(0)'length);
        end loop;
        wait for 5*ckTime;
        assert tb_sum_out = to_signed(186, tb_sum_out'length) report "Addition faild, expected result: 186" severity failure;
        for i in tb_input(0)'RANGE loop
            tb_input(i) <= to_signed(0, tb_input(0)'length);
        end loop;
        tb_input(0) <= to_signed(31, tb_input(0)'length);
        tb_input(1) <= to_signed(-32, tb_input(0)'length);
        wait for 5*ckTime;
        assert tb_sum_out = to_signed(-1, tb_sum_out'length) report "Addition faild, expected result: -1" severity failure;

        tb_input(0) <= to_signed(1, tb_input(0)'length);
        tb_input(1) <= to_signed(2, tb_input(0)'length);
        wait for 1*ckTime;
        tb_input(0) <= to_signed(1, tb_input(0)'length);
        tb_input(1) <= to_signed(3, tb_input(0)'length);
        wait for 1*ckTime;
        tb_input(0) <= to_signed(1, tb_input(0)'length);
        tb_input(1) <= to_signed(4, tb_input(0)'length);
        wait for 1*ckTime;
        assert tb_sum_out = to_signed(3, tb_sum_out'length) report "Addition faild, expected result: 3" severity failure;
        wait for 1*ckTime;
        assert tb_sum_out = to_signed(4, tb_sum_out'length) report "Addition faild, expected result: 4" severity failure;
        wait for 1*ckTime;
        assert tb_sum_out = to_signed(5, tb_sum_out'length) report "Addition faild, expected result: 5" severity failure;

        report "No errors" severity note;
        wait ;
    end process;
 

END;