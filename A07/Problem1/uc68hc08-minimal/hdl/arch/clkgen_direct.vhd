----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    12:15:23 07/27/2017
-- Design Name:
-- Module Name:    baudgen - Behavioral
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

--! Architecture independent abstraction of clock generator. Simulation only
entity clkgen is
    generic (
        mhz: integer := 30;
        cgmult: integer := 2 -- rclk frequency multiplier
    );
    PORT(
	  CLK_IN1           : in     std_logic;
	  -- Clock out ports
	  PixClk          : out    std_logic;
	  Uclk          : out    std_logic;
	  rclk        : out    std_logic;
	  mclk        : out    std_logic;
	  -- Status and control signals
	  RESET             : in     std_logic;
	  LOCKED            : out    std_logic
        );
end clkgen;

architecture Behavioral of clkgen is

    -- compute just one period!
    constant rperiod : time := 1000 ns / (mhz * cgmult);
    signal rc: std_logic := '0';
    signal uc: std_logic := '0';
    signal mc: std_logic := '0';

    -- pixel clock is fixed to 25 MHz
    constant pperiod : time := 40 ns;
    signal pc: std_logic := '0';

    -- internal rst
    signal rst_i : std_logic;

begin

        -- lock logic
        process(CLK_IN1, reset)
            variable c: integer range 0 to 100;
        begin
            if reset = '1' then
                rst_i <= '1';
                locked <= '0';
                c := 0;
            elsif rising_edge(CLK_IN1) then
                if c = 100 then
                    locked <= '1';
                    rst_i <= '0';
                else
                    c := c + 1;
                    locked <= '0';
                    rst_i <= '1';
                end if;
            end if;
        end process;


        -- video clock
        process
        begin
            pc <= '0';
            wait for pperiod/2;
            if rst_i = '0' then
                pc <= '1';
            end if;
            wait for pperiod/2;
        end process;


        -- rclock
        process
        begin
            rc <= '0';
            wait for rperiod/2;
            if rst_i = '0' then
                rc <= '1';
            end if;
            wait for rperiod/2;
        end process;

        -- uclock
        process(rst_i,rc)
            variable u: integer;
        begin
            if rst_i = '1' then
                uc <= '0';
                u := 0;
            elsif rc'event then
                if u < cgmult - 1 then
                    u := u + 1;
                else
                    u := 0;
                    uc <= not uc;
                end if;
            end if;
        end process;

        -- mclock: fixed to 100MHz
        process
        begin
            mc <= '0';
            wait for 5 ns;
            if rst_i = '0' then
                mc <= '1';
            end if;
            wait for 5 ns;
        end process;

        uclk <= uc;
        rclk <= rc;
        pixClk <= pc;
        mclk <= mc;


end Behavioral;

