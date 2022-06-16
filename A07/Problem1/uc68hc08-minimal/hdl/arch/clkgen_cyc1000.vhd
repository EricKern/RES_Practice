
LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity clkgen is
    generic (
        mhz: integer := 30;  -- unused, so far
        cgmult: integer := 2 -- unused, so far
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

ARCHITECTURE a OF clkgen IS

component clkgen_cyc 
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		c2		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC 
	);
END component;

    signal slowClk, fastClk, veryFastClk: std_logic;

begin

    cyclk: clkgen_cyc
    port map (
        areset	=> reset,
        inclk0	=> clk_in1,
        c0 => slowClk,
        c1 => fastClk,
        c2 => veryFastClk,
        locked	=> locked
    );
    
    pixclk <= slowClk;
    uclk <= slowClk;
    rclk <= fastClk;
	 mclk <= veryFastClk;

end a;
