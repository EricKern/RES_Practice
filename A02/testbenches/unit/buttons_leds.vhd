library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity button_leds is
  port (
    clk		: in std_logic;
    reset	: in std_logic;
    din		: in std_logic;
    leds	: out std_logic_vector(3 downto 0)
  );
end entity button_leds;

architecture behavior of button_leds is

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
  signal counter_reg : std_logic_vector(1 downto 0);

  begin


    myshiftreg : shift_register
    generic map (bit_width => 4)
    port map(
      clk 	=> clk,
      reset 	=> reset,
      din		=> din,
      dout	=> shift_buf
    );


-- counter
      process(clk, reset)
      begin
        if(reset = '1') then
          counter_reg <= (others => '0');
        elsif (rising_edge(clk)) then
          counter_reg <= std_logic_vector( unsigned(counter_reg) + 1 );
        end if;
      end process;

--counter end

    process(clk, reset)
    begin
      if(reset = '1') then
        leds <= (others => '0');
      elsif (rising_edge(clk) and counter_reg = "00") then
         leds <= shift_buf;
      end if;
    end process;


end architecture behavior;
