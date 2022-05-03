library ieee;
use ieee.std_logic_1164.all;

entity button_leds is
  port (
    clk		: in std_logic;
    reset	: in std_logic;
    din		: in std_logic;
    leds	: out std_logic_vector(3 downto 0)
  );
end entity button_leds;

architecture behavior of button_leds is

  component counter is
  generic (
  	bit_width : positive := 4
  );
  port(
  	clk			: in std_logic;
  	reset		: in std_logic;
  	counter_o	: out std_logic_vector(bit_width-1 downto 0)
  );
  end component;

  component shift_register is
  generic (
  	bit_width : positive := 4
  );
  port(
  	clk		: in std_logic;
  	reset	: in std_logic;
  	din		: in std_logic;
  	dout	: out std_logic_vector(bit_width-1 downto 0)
  );
  end component;

  signal shift_buf: std_logic_vector(3 downto 0);
  signal cout_buf: std_logic_vector(1 downto 0);

  begin

  	mycounter : counter
  	generic map (bit_width => 2)
  	port map(
  		clk 		=> clk,
  		reset		=> reset,
  		counter_o	=> cout_buf
  	);

    myshiftreg : shift_register
    generic map (bit_width => 4)
    port map(
      clk 	=> clk,
      reset 	=> reset,
      din		=> din,
      dout	=> shift_buf
    );

-- TEST
    begin
      process(clk, reset)
      begin
        if(reset = '1') then
          leds <= (others => '0');
          shift_buf <= (others => '0');
          cout_buf <= (others => '0');
        elsif (cout_buf = "11") then
          leds <= shift_buf;
        end if;
      end process;
-- TEST end

    process(reset)
    begin
      if(reset = '1') then
        leds <= (others => '0');
        shift_buf <= (others => '0');
        cout_buf <= (others => '0');
      end if;
    end process;

    process(clk, reset)
    begin
      if(reset = '0') then
        if cout_buf = "11" then
          leds <= shift_buf;
        end if;
      end if;
    end process;

end architecture behavior;
