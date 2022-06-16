--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   09:00:38 07/27/2017
-- Design Name:
-- Module Name:   /home/kugel/temp/hc08//hc08_tb.vhd
-- Project Name:  hc08
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: X68UR08
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use std.textio.all;

-- update to ivhdl2008 for textio
-- package text_util not needed any more

ENTITY hc08_tb IS
	generic (
            ni: integer := 2; -- number of 4k blocks instruction ram
            nd: integer := 2; -- number of 4k blocks data ram
            mb: integer := 16; -- total number of address bits
			dualport: boolean := false; --true;
			mhz: integer := 40;
			cgmult: integer := 2;
			gpInvIn: boolean := false; -- invert input
			gpInvOut: boolean := false; -- invert output
			pwms: integer := 6;
			hasVideo: boolean := true;
			hasI2c: boolean := true;
			hasSpi: boolean := false;
			hasSdram: boolean := false;
			simulation: boolean := true
	 );
END hc08_tb;

ARCHITECTURE behavior OF hc08_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT hc08_top
	generic (
            ni: integer := 2; -- number of 4k blocks instruction ram
            nd: integer := 2; -- number of 4k blocks data ram
            mb: integer := 16; -- total number of address bits
			dualport: boolean := false; --true;
			mhz: integer := 30;
			cgmult: integer := 2;
			gpInvIn: boolean := false; -- invert input
			gpInvOut: boolean := false; -- invert output
			pwms: integer := 6;
			hasVideo: boolean := false;
			hasI2c: boolean := true;
			hasSpi: boolean := false;
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
         pulse: out std_logic_vector(pwms - 1 downto 0);
        sda       : inOUT  STD_LOGIC;
        scl       : inOUT  STD_LOGIC;
		miso    : IN     STD_LOGIC;                             --master in, slave out
		sclk    : out STD_LOGIC;                             --spi clock
		ss_n    : out STD_LOGIC;   			     --slave select
		mosi    : OUT    STD_LOGIC;                             --master out, slave in
        vgaHS : out std_logic;
        vgaVS : out std_logic;
        vgaR : out std_logic;
        vgaG : out std_logic;
        vgaB : out std_logic;
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
        -- kernel trace simulation outputs
        sim_task: out std_logic_vector(7 downto 0) := (others => '0');
        sim_mbv: out std_logic_vector(7 downto 0) := (others => '0');
        sim_mbb: out std_logic_vector(7 downto 0) := (others => '0');
        sim_mxt: out std_logic_vector(7 downto 0) := (others => '0');
        sim_mxb: out std_logic_vector(7 downto 0) := (others => '0');
        sim_addr: out std_logic_vector(15 downto 0) := (others => '0');
        sim_irq: out std_logic := '0';
        --
			gpin: in std_logic_vector(7 downto 0);
			gpout: out std_logic_vector(7 downto 0)
        );
    END COMPONENT;


   signal clk : std_logic := '0';
   signal rst_n : std_logic := '0';
   signal gpin: std_logic_vector(7 downto 0) := (others => '0');
   signal gpout: std_logic_vector(7 downto 0);
   signal rx : std_logic := '1';
   signal tx : std_logic;

    signal pulse:  std_logic_vector(pwms - 1 downto 0);
    signal sda       :   STD_LOGIC;
    signal scl       :   STD_LOGIC;

    signal miso       :   STD_LOGIC;
    signal mosi       :   STD_LOGIC;
    signal sclk       :   STD_LOGIC;
    signal ss_n       :   STD_LOGIC;

	signal vgaHS :  std_logic;
	signal vgaVS :  std_logic;
	signal vgaR :  std_logic;
	signal vgaG :  std_logic;
	signal vgaB :  std_logic;


    constant sdr_sdabits: integer := 12;
    constant sdr_dbits: integer := 16;
    signal sdr_addr:  std_logic_vector(sdr_sdabits - 1 downto 0);
    signal sdr_ba:  std_logic_vector(1 downto 0);
    signal sdr_cas_n:  std_logic;
    signal sdr_cke:  std_logic;
    signal sdr_clk:  std_logic_vector(0 downto 0);
    signal sdr_cs_n:  std_logic;
    signal sdr_dq:  std_logic_vector(sdr_dbits - 1 downto 0);
    signal sdr_dqm:  std_logic_vector(sdr_dbits/8 - 1 downto 0);
    signal sdr_ras_n:  std_logic;
    signal sdr_we_n:  std_logic;

	signal sdr_clk_out: std_logic;


    -- Clock period definitions
   constant clk_period : time := 1000 ns / mhz;

    signal sim_task: std_logic_vector(7 downto 0);
    signal sim_mbv: std_logic_vector(7 downto 0);
    signal sim_mbb: std_logic_vector(7 downto 0);
    signal sim_mxt: std_logic_vector(7 downto 0);
    signal sim_mxb: std_logic_vector(7 downto 0);
    signal sim_addr: std_logic_vector(15 downto 0);
    signal sim_irq: std_logic;
    file logfile: text;
    file logfile2: text;
    signal running: boolean := true;


    -- external modules
	component i2c_prom
	 generic (device : string(1 to 5) := "24C02");  --select from 24C16, 24C08, 24C04, 24C02 and 24C01
	 port (
	  STRETCH            : IN    time := 1 ns;      --pull SCL low for this time-value;
	  E0                 : IN    std_logic := 'L';  --leave unconnected for 24C16, 24C08, 24C04
	  E1                 : IN    std_logic := 'L';  --leave unconnected for 24C16, 24C08
	  E2                 : IN    std_logic := 'L';  --leave unconnected for 24C16
	  WC                 : IN    std_logic := 'L';  --tie high to disable write mode
	  SCL                : INOUT std_logic;
	  SDA                : INOUT std_logic
	);
	END component;

COMPONENT ramModel
    GENERIC (
        -- Timing Parameters for -7E and CAS Latency = 2
        tAC       : TIME    :=  5.4 ns;
        tHZ       : TIME    :=  5.4 ns;
        tOH       : TIME    :=  2.7 ns;
        tMRD      : INTEGER :=  2;          -- 2 Clk Cycles
        tRAS      : TIME    := 37.0 ns;
        tRC       : TIME    := 60.0 ns;
        tRCD      : TIME    := 15.0 ns;
        tRP       : TIME    := 15.0 ns;
        tRRD      : TIME    := 14.0 ns;
        tWRa      : TIME    :=  7.0 ns;     -- A2 Version - Auto precharge mode only (1 Clk + 7 ns)
        tWRp      : TIME    := 14.0 ns;     -- A2 Version - Precharge mode only (14 ns)

        tAH       : TIME    :=  0.8 ns;
        tAS       : TIME    :=  1.5 ns;
        tCH       : TIME    :=  2.5 ns;
        tCL       : TIME    :=  2.5 ns;
        tCK       : TIME    :=  7.5 ns;
        tDH       : TIME    :=  0.8 ns;
        tDS       : TIME    :=  1.5 ns;
        tCKH      : TIME    :=  0.8 ns;
        tCKS      : TIME    :=  1.5 ns;
        tCMH      : TIME    :=  0.8 ns;
        tCMS      : TIME    :=  1.5 ns;

        addr_bits : INTEGER := 12;
        data_bits : INTEGER := 16;
        col_bits  : INTEGER :=  9
        );
    PORT (
        Dq    : INOUT STD_LOGIC_VECTOR (data_bits - 1 DOWNTO 0) := (OTHERS => 'Z');
        Addr  : IN    STD_LOGIC_VECTOR (addr_bits - 1 DOWNTO 0) := (OTHERS => '0');
        Ba    : IN    STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
        Clk   : IN    STD_LOGIC := '0';
        Cke   : IN    STD_LOGIC := '1';
        Cs_n  : IN    STD_LOGIC := '1';
        Cas_n : IN    STD_LOGIC := '1';
        Ras_n : IN    STD_LOGIC := '1';
        We_n  : IN    STD_LOGIC := '1';
        Dqm       : IN    STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0')
    );
END COMPONENT;


BEGIN

    -- log params
    process
        variable l: line;
    begin
        write(l,string'("Configuration:"));
        writeline(output,l);
        write(l,string'("Total address bits: "));
        write(l,mb);
        writeline(output,l);
        write(l,string'("Instruction ram 4k blocks: "));
        write(l,ni);
        writeline(output,l);
        write(l,string'("Data ram 4k blocks: "));
        write(l,nd);
        writeline(output,l);
        write(l,string'("Frequency: "));
        write(l,mhz);
        writeline(output,l);
        write(l,string'("PWMs: "));
        write(l,pwms);
        writeline(output,l);
        write(l,string'("cgmult: "));
        write(l,cgmult);
        writeline(output,l);
        write(l,string'("GPIN inverted: "));
        write(l,gpInvIn);
        writeline(output,l);
        write(l,string'("GPOUT inverted: "));
        write(l,gpInvOut);
        writeline(output,l);
        write(l,string'("Dualport ram: "));
        write(l,dualport);
        writeline(output,l);
        write(l,string'("Video: "));
        write(l,hasVideo);
        writeline(output,l);
        write(l,string'("I2C: "));
        write(l,hasI2c);
        writeline(output,l);
        write(l,string'("SPI: "));
        write(l,hasSpi);
        writeline(output,l);
        write(l,string'("SDRAM: "));
        write(l,hasSdram);
        writeline(output,l);

        wait;
    end process;

	-- Instantiate the Unit Under Test (UUT)
   uut: hc08_top
		generic map (
		ni => ni,
		nd => nd,
		mb => mb,
            dualport => dualport,
			mhz => mhz,
			cgmult => cgmult,
			gpInvIn => gpInvIn,
			gpInvOut => gpInvOut,
			pwms => pwms,
			hasVideo => hasVideo,
			hasI2c => hasI2c,
			hasSpi => hasSpi,
			hasSdram => hasSdram,
            sdr_dbits => sdr_dbits,
            sdr_sdabits => sdr_sdabits,
			simulation => simulation
		)
		PORT MAP (
          clk => clk,
          rst_n => rst_n,
			 rx => rx,
			 tx => tx,
			 pulse => pulse,
			 scl => scl,
			 sda => sda,
            miso => miso,
            sclk => sclk,
            ss_n => ss_n,
            mosi => mosi,
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
            sim_addr => sim_addr,
            sim_task => sim_task,
            sim_mbv => sim_mbv,
            sim_mbb => sim_mbb,
            sim_mxt => sim_mxt,
            sim_mxb => sim_mxb,
            sim_irq => sim_irq,
          gpin => gpin,
          gpout => gpout
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;


   -- Stimulus process
   stim_proc: process
   begin
      -- hold reset state for 100 ns.
      running <= true;
		rst_n <= '0';
      wait for 100 ns;
		rst_n <= '1';

      wait for clk_period*10;

		gpin(2) <= '1';
      wait for clk_period*1000;
		gpin(2) <= '0';
      wait for clk_period*1000;

		gpin(2) <= '1';
      wait for clk_period*4*mhz*1000;
		gpin(2) <= '0';
      wait for clk_period*4*mhz*1000;

	-- test gpio interrupt
		wait until gpout = X"04";
		gpin(2) <= '1';
      wait for clk_period*4*mhz*1000;
		gpin(2) <= '0';
      wait for clk_period*4*mhz*1000;

		wait until gpout = X"08";
		gpin(4) <= '1';
      wait for clk_period*4*mhz*1000;
		gpin(4) <= '0';
      wait for clk_period*4*mhz*1000;

      running <= false;
      wait;
   end process;


   withI2c: if hasI2c generate begin
    -- external i2c
        i2c : i2c_prom
        port map (
        SCL => scl,
        SDA => sda
        );
        -- i2c pullups
        scl <= 'H';
        sda <= 'H';

	end generate;

	withSdram: if hasSdram generate begin
	sdr_clk_out <= sdr_clk(0);
    mem: ramModel
        generic map(
        addr_bits => sdr_sdabits,
        data_bits => sdr_dbits,
        col_bits =>  8
        )
        PORT MAP(
            Dq      => sdr_dq,
            Addr    => sdr_addr,
            Ba      => sdr_ba,
            Clk     => sdr_clk_out,
            Cke     => sdr_cke,
            Cs_n    => sdr_cs_n,
            Ras_n   => sdr_ras_n,
            Cas_n   => sdr_cas_n,
            We_n    => sdr_we_n,
            Dqm       => sdr_dqm
        );

	end generate;


  -- software trace
  process
        variable log: line;
        variable addr: std_logic_vector(15 downto 0) := (others => '0');
        variable c: integer := 0;
        variable track:std_logic_vector(40 downto 0);
        variable t0 : time := now;
        variable lt: line;
    begin
                file_open(logfile,"hc08_full_trace.csv",WRITE_MODE);
                write(log,string'("cycle,time,address,hexAddress,task,mbv,mbb,mxt,mxb,irq"));
                writeline(logfile, log);

                file_open(logfile2,"hc08_short_trace.csv",WRITE_MODE);
                write(log,string'("cycle,time,address,hexAddress,task,mbv,mbb,mxt,mxb,irq"));
                writeline(logfile2, log);
                report "Logfiles opened" severity note;

                while running loop

                    wait until rising_edge(clk);
                    wait for 2 ns;
                    -- full trace
                    if addr /= sim_addr then
                        if sim_addr /= X"XXXX" then
                            write(log,c/4); -- 4 phases per cycles
                            write(log,string'(","));
                            write(log,c*(1000/mhz)); -- time in ns
                            write(log,string'(","));
                            write(log,to_integer(unsigned(sim_addr)));
                            write(log,string'(",0x"));
                            write(log,to_hstring(sim_addr));
                            write(log,string'(","));
                            write(log,to_hstring(sim_task));
                            write(log,string'(","));
                            write(log,to_hstring(sim_mbv));
                            write(log,string'(","));
                            write(log,to_hstring(sim_mbb));
                            write(log,string'(","));
                            write(log,to_hstring(sim_mxt));
                            write(log,string'(","));
                            write(log,to_hstring(sim_mxb));
                            write(log,string'(","));
                            write(log,sim_irq);
                            writeline(logfile, log);
                            end if;
                    end if;
                    -- short trace, without address tracking
                    if track /= sim_task & sim_mbv & sim_mbb & sim_mxt & sim_mxb & sim_irq then
                        if sim_addr /= X"XXXX" then
                            write(log,c/4); -- 4 phases per cycles
                            write(log,string'(","));
                            write(log,c*(1000/mhz)); -- time in ns
                            write(log,string'(","));
                            write(log,to_integer(unsigned(sim_addr)));
                            write(log,string'(",0x"));
                            write(log,to_hstring(sim_addr));
                            write(log,string'(","));
                            write(log,to_hstring(sim_task));
                            write(log,string'(","));
                            write(log,to_hstring(sim_mbv));
                            write(log,string'(","));
                            write(log,to_hstring(sim_mbb));
                            write(log,string'(","));
                            write(log,to_hstring(sim_mxt));
                            write(log,string'(","));
                            write(log,to_hstring(sim_mxb));
                            write(log,string'(","));
                            write(log,sim_irq);
                            writeline(logfile2, log);
                            end if;
                    end if;
                    addr := sim_addr;
                    c := c + 1;
                    track := sim_task & sim_mbv & sim_mbb & sim_mxt & sim_mxb & sim_irq;

                    if now > t0 + 1 ms then
                        t0 := now;
                        write(lt,string'("Simulation time: "));
                        write(lt,now);
                        writeline(output,lt);
                    end if;

                end loop;

                file_close(logfile);
                file_close(logfile2);
                report "Logfile closed" severity note;

            wait;
  end process;



END;
