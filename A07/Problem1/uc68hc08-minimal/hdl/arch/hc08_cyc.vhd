----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:15:23 07/27/2017 
-- Design Name: 
-- Module Name:    hc08_top - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity hc08_cyc is
	generic (
            ni: integer := 8; -- number of 4k blocks instruction ram, must be power of 2
            nd: integer := 2; -- number of 4k blocks data ram
            mb: integer := 16; -- total number of address bits

				dualport: boolean := false; --true;
			mhz: integer := 25; -- 12 mhz input
            gpInvIn: boolean := false; -- invert input
            gpInvOut: boolean := false; -- invert output
			hasVideo: boolean := true;
			pwms: integer := 0; -- no pwms with cam-vga adapter
			hasI2c: boolean := true;
			hasSpi: boolean := false; -- but ss_n needed to enable i2c
			hasSdram: boolean := true;
			sdr_sdabits: integer := 12;
			sdr_dbits: integer := 16;
			simulation: boolean := false
	 );
    PORT(
         clk : IN  std_logic;
         rst_n : IN  std_logic;
         rx : IN  std_logic;
         tx : out  std_logic;
-- 			gpin: in std_logic_vector(7 downto 0);
         vgaHS : out std_logic;
         vgaVS : out std_logic;
         vgaR : out std_logic;
         vgaG : out std_logic;
         vgaB : out std_logic;
          pulse: out std_logic_vector(pwms - 1 downto 0);
--  		mosi    : OUT    STD_LOGIC;                             --master out, slave in
--  		miso    : IN     STD_LOGIC;                             --master in, slave out
--  		sclk    : out STD_LOGIC;                             --spi clock
--  		ss_n    : out STD_LOGIC := '1';   			     --slave select
        -- sdram
        sdr_addr: out std_logic_vector(sdr_sdabits - 1 downto 0);
        sdr_ba: out std_logic_vector(1 downto 0);
        sdr_cas_n: out std_logic;
        sdr_cke: out std_logic;
        sdr_clk: inout std_logic_vector(0 downto 0);
        sdr_cs_n: out std_logic;
        sdr_dq: inout std_logic_vector(sdr_dbits - 1 downto 0);
        sdr_dqm: out std_logic_vector(sdr_dbits/8 - 1 downto 0);
        sdr_ras_n: out std_logic;
        sdr_we_n: out std_logic;
        --
         sda       : inOUT  STD_LOGIC;
         scl       : inOUT  STD_LOGIC;
			-- lis3 sensor interface is i2c/spi dual purpose
			-- pull ss_n high to enable i2c. data out is address a0 in that case. pull low by default
			i2c_en: out std_logic := '1'; -- static
			i2c_a0: out std_logic := '0'; -- static
			
	gpout: out std_logic_vector(7 downto 0)
        );
end entity;

architecture Behavioral of hc08_cyc is

    COMPONENT hc08_top
	generic (
            ni: integer := 2; -- number of 4k blocks instruction ram
            nd: integer := 2; -- number of 4k blocks data ram
            mb: integer := 16; -- total number of address bits
            dualport: boolean := false; --true;
            mhz: integer := 30;
            gpInvIn: boolean := false; -- invert input
            gpInvOut: boolean := false; -- invert output
            hasVideo: boolean := true;
            pwms: integer := 6;
            hasI2c: boolean := true;
            hasSpi: boolean := false;
			hasSdram: boolean := true;
			target: string := "simple";
			sdr_sdabits: integer := 12;
			sdr_dbits: integer := 16;
            simulation: boolean := false
        );
    PORT(
        clk : IN  std_logic;
        rst_n : IN  std_logic;
        rx : IN  std_logic;
        tx : out  std_logic;
		  -- debugger
        sim_task: out std_logic_vector(7 downto 0) := (others => '0');
        sim_mbv: out std_logic_vector(7 downto 0) := (others => '0');
        sim_mbb: out std_logic_vector(7 downto 0) := (others => '0');
        sim_mxt: out std_logic_vector(7 downto 0) := (others => '0');
        sim_mxb: out std_logic_vector(7 downto 0) := (others => '0');
        sim_addr: out std_logic_vector(15 downto 0) := (others => '0');
        sim_irq: out std_logic := '0';
		  --
        vgaHS : out std_logic;
        vgaVS : out std_logic;
        vgaR : out std_logic;
        vgaG : out std_logic;
        vgaB : out std_logic;
        pulse: out std_logic_vector(pwms - 1 downto 0);
        sdr_addr: out std_logic_vector(sdr_sdabits - 1 downto 0);
        sdr_ba: out std_logic_vector(1 downto 0);
        sdr_cas_n: out std_logic;
        sdr_cke: out std_logic;
        sdr_clk: inout std_logic_vector(0 downto 0);
        sdr_cs_n: out std_logic;
        sdr_dq: inout std_logic_vector(sdr_dbits - 1 downto 0);
        sdr_dqm: out std_logic_vector(sdr_dbits/8 - 1 downto 0);
        sdr_ras_n: out std_logic;
        sdr_we_n: out std_logic;
        sda       : inOUT  STD_LOGIC;
        scl       : inOUT  STD_LOGIC;
        miso    : IN     STD_LOGIC;                             --master in, slave out
        sclk    : out STD_LOGIC;                             --spi clock
        ss_n    : out STD_LOGIC;   			     --slave select
        mosi    : OUT    STD_LOGIC;                             --master out, slave in
        gpin: in std_logic_vector(7 downto 0);
        gpout: out std_logic_vector(7 downto 0)
    );
    END COMPONENT;

--signal vgaHS :  std_logic;
--signal vgaVS :  std_logic;
--signal vgaR :  std_logic;
--signal vgaG :  std_logic;
--signal vgaB :  std_logic;
--signal pulse:  std_logic_vector(pwms - 1 downto 0);
--signal sda       :   STD_LOGIC := '0';
--signal scl       :   STD_LOGIC := '0';
signal miso    :      STD_LOGIC := '0';                             --master in, slave out
signal mosi    :     STD_LOGIC;                             --master out, slave in
signal sclk    :  STD_LOGIC;                             --spi clock
signal ss_n    :  STD_LOGIC;   			     --slave select
signal gpin: std_logic_vector(7 downto 0) := (others => '0');
    
		-- debugger signals
    signal sim_addr: std_logic_vector(15 downto 0);
    signal sim_task: std_logic_vector(7 downto 0);
    signal sim_mbv: std_logic_vector(7 downto 0);
    signal sim_mbb: std_logic_vector(7 downto 0);
    signal sim_mxt: std_logic_vector(7 downto 0);
    signal sim_mxb: std_logic_vector(7 downto 0);
    signal sim_irq: std_logic;
	-- must be kept for debugger
	ATTRIBUTE keep : BOOLEAN;
	ATTRIBUTE keep OF sim_addr : SIGNAL IS true;
	ATTRIBUTE keep OF sim_task : SIGNAL IS true;
	ATTRIBUTE keep OF sim_mbv : SIGNAL IS true;
	ATTRIBUTE keep OF sim_mbb : SIGNAL IS true;
	ATTRIBUTE keep OF sim_mxt : SIGNAL IS true;
	ATTRIBUTE keep OF sim_mxb : SIGNAL IS true;
	ATTRIBUTE keep OF sim_irq : SIGNAL IS true;
	 
	 
begin

   uc: hc08_top 
		generic map (
			 ni => ni,
			 nd => nd,
			 mb => mb,
			dualport => dualport,
			mhz => mhz,
			gpInvIn => gpInvIn,
			gpInvOut => gpInvOut,
			hasVideo => hasVideo,
			pwms => pwms,
			hasI2c => hasI2c,
			hasSpi => hasSpi,
			hasSdram => hasSdram,
			target => "cyclone10lp",
            sdr_dbits => sdr_dbits,
            sdr_sdabits => sdr_sdabits,
			simulation => simulation
		)
		PORT MAP (
          clk => clk,
          rst_n => rst_n,
			 rx => rx,
			 tx => tx,
			 -- debugger
            sim_addr => sim_addr,
            sim_task => sim_task,
            sim_mbv => sim_mbv,
            sim_mbb => sim_mbb,
            sim_mxt => sim_mxt,
            sim_mxb => sim_mxb,
            sim_irq => sim_irq,
			 --
            vgaHS  => vgaHs,
            vgaVS => vgaVs,
            vgaR => vgaR,
            vgaG => vgaG,
            vgaB => vgaB,
            sdr_addr        => sdr_addr, 
            sdr_ba          => sdr_ba,   
            sdr_cas_n       => sdr_cas_n,
            sdr_cke         => sdr_cke,  
            sdr_clk         => sdr_clk,  
            sdr_cs_n        => sdr_cs_n, 
            sdr_dq          => sdr_dq,   
            sdr_dqm         => sdr_dqm,
            sdr_ras_n       => sdr_ras_n,
            sdr_we_n        => sdr_we_n,
			 pulse => pulse,
			 scl => scl,
			 sda => sda,
        miso => miso,
        sclk => sclk,
        ss_n => ss_n,
        mosi => mosi,
          gpin => gpin,
          gpout => gpout
        );

		

		
	
end Behavioral;

