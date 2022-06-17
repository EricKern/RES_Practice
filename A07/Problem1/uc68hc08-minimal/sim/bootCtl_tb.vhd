----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:40:06 08/10/2017 
-- Design Name: 
-- Module Name:    bootCtl - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;


-- all commands 2 bytes.
-- data stream: N words
-- write control
-- write address byte (0..n), value
-- stream data (size W), count N 
-- streaming, N*W values

entity bootCtl_tb is

end entity;

architecture Behavioral of bootCtl_tb is

component bootCtl
    generic (
        mhz: integer;
        abytes: integer := 2;
        dbytes: integer := 1;
        cbits: integer := 1
    );
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         rx : IN  std_logic;
         wrt : out  std_logic := '0';
         ctl : out  std_logic_vector(cbits - 1 downto 0);
         addr : out  std_logic_vector(abytes * 8 - 1 downto 0);
         data : out  std_logic_vector(dbytes * 8 - 1 downto 0)
        );
end component;

        constant mhz: integer := 8; --30;
        constant abytes: integer := 2;
        constant dbytes: integer := 1;
        constant cbits: integer := 1;

         signal clk :   std_logic;
         signal rst :   std_logic;
         signal tx :   std_logic;
         signal wrt :   std_logic;
         signal ctl :   std_logic_vector(cbits - 1 downto 0);
         signal addr :   std_logic_vector(abytes * 8 - 1 downto 0);
         signal data :   std_logic_vector(dbytes * 8 - 1 downto 0);
	
	constant cmdC: integer := 1; -- control
	constant cmdA: integer := 2; -- address
	constant cmdD: integer := 3; -- data length
	constant cmdS: integer := 4; -- data stream
	constant cmdI: integer := 5; -- initialize
	
	type mt is array (0 to 2) of std_logic_vector(7 downto 0);
	constant magic: mt := ( X"58",X"59",X"5a" ); -- X,Y,Z

	constant period : time := 1000 ns / mhz;
	constant bitPeriod : time := 1000000 us / 115200;

	procedure send (d: std_logic_vector( 7 downto 0); signal tx: out std_logic) is
            variable td: std_logic_vector(9 downto 0) := '1' & d & '0';
	begin
            for i in 0 to 9 loop
                tx <= td(i);
                wait for bitperiod;
            end loop;
	end procedure;
	
begin

    process
    begin
        clk <= '0';
        wait for period/2;
        clk <= '1';
        wait for period/2;
    end process;

    process
    begin
        rst <= '1';
        wait for 10 * period;
        rst <= '0';
        wait;
    end process;

    process
    begin
        tx <= '1';
        wait until rst = '0';
        wait for 100 * bitperiod;
        
        send(X"11", tx);
        wait for 10 * period;
        send(X"58", tx);
        wait for 10 * period;
        send(X"59", tx);
        wait for 10 * period;
        send(X"5a", tx);
        wait for 10 * period;
		  -- control
        send(X"10", tx);
        wait for 10 * period;
        send(X"01", tx);
        wait for 10 * period;
		  -- address
        send(X"20", tx);
        wait for 10 * period;
        send(X"12", tx);
        wait for 10 * period;
        send(X"21", tx);
        wait for 10 * period;
        send(X"e0", tx);
        wait for 10 * period;
		  -- dcount. actual is one more
        send(X"30", tx);
        wait for 10 * period;
        send(X"03", tx);
        wait for 10 * period;
        send(X"31", tx);
        wait for 10 * period;
        send(X"00", tx);
        wait for 10 * period;
		  -- data
        send(X"40", tx);
        wait for 10 * period;
        send(X"51", tx);
        wait for 10 * period;
        send(X"52", tx);
        wait for 10 * period;
        send(X"53", tx);
        wait for 10 * period;
        send(X"54", tx);
        wait for 10 * period;
-- 		  -- dcount (0x200). actual is one more
--         send(X"30", tx);
--         wait for 10 * period;
--         send(X"ff", tx);
--         wait for 10 * period;
--         send(X"31", tx);
--         wait for 10 * period;
--         send(X"01", tx);
--         wait for 10 * period;
-- 		  -- data
--         send(X"40", tx);
--         wait for 10 * period;
--         for i in 0 to 511 loop
--         send(std_logic_vector(to_unsigned(i,8)), tx);
--         wait for 10 * period;
--         end loop;
        -- vector address
        send(X"20", tx);
        wait for 10 * period;
        send(X"fc", tx);
        wait for 10 * period;
        send(X"21", tx);
        wait for 10 * period;
        send(X"ff", tx);
        wait for 10 * period;
		  -- dcount
        send(X"30", tx);
        wait for 10 * period;
        send(X"03", tx);
        wait for 10 * period;
        send(X"31", tx);
        wait for 10 * period;
        send(X"00", tx);
        wait for 10 * period;
		  -- data
        send(X"40", tx);
        wait for 10 * period;
        send(X"5a", tx);
        wait for 10 * period;
        send(X"a5", tx);
        wait for 10 * period;
        send(X"c6", tx);
        wait for 10 * period;
        send(X"6c", tx);
        wait for 10 * period;
		  -- control
        send(X"10", tx);
        wait for 10 * period;
        send(X"00", tx);
        wait for 10 * period;
		  -- reinit or finish 
        send(X"50", tx); -- reinit
        --send(X"00", tx); -- finish
        wait for 10 * period;
    
        send(X"11", tx);
        wait for 10 * period;
        send(X"58", tx);
        wait for 10 * period;
        send(X"59", tx);
        wait for 10 * period;
        send(X"5a", tx);
        wait for 10 * period;
		  -- control
        send(X"10", tx);
        wait for 10 * period;
        send(X"01", tx);
        wait for 100 * period;
    
		  -- control
        send(X"10", tx);
        wait for 10 * period;
        send(X"00", tx);
        wait for 10 * period;

end process;
    
    bc: bootCtl
    generic map (
		mhz => mhz,
		abytes => abytes,
		dbytes => dbytes,
		cbits => cbits
	 )
	PORT MAP(
		clk => clk,
		rst => rst,
		rx => tx,
		wrt => wrt,
		ctl => ctl,
		addr => addr,
		data => data
	);
    

end Behavioral;

