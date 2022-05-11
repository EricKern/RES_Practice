library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;

entity fsm_tb is
end entity;

architecture a of fsm_tb is

  constant dbits : integer  := 4;
  signal d_in_tb       : std_logic;
  signal led_tb       : std_logic;
  signal clk_tb       : std_logic;
  signal reset_tb     : std_logic;

  component fsm is
    port (
          clk: in std_logic;
          reset : in std_logic;
	        d_in: in std_logic;
	        led: out std_logic);
  end component;

  constant ckTime : time := 10 ns;

begin

  uut : fsm
    port map (
      clk   => clk_tb,
      reset => reset_tb,
      d_in  => d_in_tb,
      led   => led_tb);

  -- generate the clock
  ckProc : process
  begin
    clk_tb <= '0';
    wait for ckTime/2;
    clk_tb <= '1';
    wait for ckTime/2;
  end process;


  -- rProc : process
  -- begin

  --   -- reset
  --   reset_tb <= '1';
  --   wait for 5 * ckTime;
  --   reset_tb <= '0';
  --   wait for 10 * ckTime;

  --   wait;

  -- end process;

  testProc : process
  begin
    d_in_tb <= '0';
    reset_tb <= '1';
    wait for ckTime;
    assert led_tb = '0' report "leds are not off during reset" severity failure;
    reset_tb <= '0';
    wait for 2*ckTime;
    assert led_tb = '0' report "leds are not off even though d_in has not been pressed" severity failure;
    d_in_tb <= '1';
    wait for ckTime;
    assert led_tb = '0' report "leds are not off in state 1" severity failure;
    wait for 3*ckTime;
    d_in_tb <= '0';
    wait for ckTime;
    assert led_tb = '0' report "leds are not off in state 0" severity failure;

    d_in_tb <= '1';
    wait for ckTime;
    assert led_tb = '0' report "leds are not off in state 1" severity failure;
    wait for 4*ckTime;
    assert led_tb = '1' report "leds are off in state 2" severity failure;
    d_in_tb <= '0';
    wait for ckTime;
    assert led_tb = '0' report "leds are not off in state 0" severity failure;
    d_in_tb <= '1';
    wait for ckTime;
    assert led_tb = '0' report "leds are not off in state 1" severity failure;
    wait for 4*ckTime;
    assert led_tb = '1' report "leds are off in state 2" severity failure;
    wait for ckTime;
    assert led_tb = '0' report "leds are not off in state 3" severity failure;
    wait for ckTime;
    assert led_tb = '0' report "leds are not off in state 3" severity failure;
    d_in_tb <= '0';
    wait for ckTime;
    assert led_tb = '0' report "leds are not off in state 0" severity failure;

    report "No errors" severity note;
    wait ;
  end process;


end a;
