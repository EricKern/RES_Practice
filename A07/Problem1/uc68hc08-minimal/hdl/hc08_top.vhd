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
use IEEE.NUMERIC_STD.ALL;


entity hc08_top is
	generic (
            ni: integer := 2; --! number of 4k blocks instruction ram
            nd: integer := 2; --! number of 4k blocks data ram
            mb: integer := 16; --! total number of address bits

            dualport: boolean := false; --! Dual ported memories;
            -- spartan6 runs at 30MHz, spartan3 at 20MHz, Lattice MachXO3 at 7.5MHz (use value: 8)
            mhz: integer := 30; --! Clock speed. Depends on external clock and/or internal clock iP
            simulation: boolean := false; --! Set to false for implementation
            cgmult: integer := 2; --! Multiplier factor for target IP
            gpInvIn: boolean := false; --! invert input
            gpInvOut: boolean := false; --! invert output
			hasTimer: boolean := false; --! Just for mini mini mode. Normally True !!!
            pwms: integer := 0; --! Number of PWM outputs
            hasVideo: boolean := false; --! Video available. No statement about framebuffer type yet
            hasI2c: boolean := false; --! I2C
			hasSdram: boolean := true; --! SDRAM. to be tested still
			target: string := "simple"; --! Target architecture. configures various IP implementations
			sdr_sdabits: integer := 12; --! SDRAM address bits
			sdr_dbits: integer := 16; --! SDRAM data bits
            hasSpi: boolean := false --! SPI
	 );
    PORT(
         clk : IN  std_logic;
         rst_n : IN  std_logic;
         rx : IN  std_logic;
         tx : out  std_logic;
         -- optional peripiheral ports
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
        -- end optional
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
end hc08_top;

architecture Behavioral of hc08_top is

    -- -------------------------------------------
    -- ram selection. ram allocated in multiples of 4k blocks
    constant bb: integer := 12; -- address bits for 4k block
    constant bk: integer := 2**(mb - bb); -- number of blocks

    -- instruction ram selection
    function isel (a: std_logic_vector(mb - 1 downto 0)) return boolean is
    begin
        if to_integer(unsigned(a(mb - 1 downto bb))) >= (bk - ni) then
            return true;
        else
            return false;
        end if;
    end function;

    -- data ram selection
    function dsel (a: std_logic_vector(mb - 1 downto 0)) return boolean is
    begin
        if
            to_integer(unsigned(a(mb - 1 downto bb))) < (bk - ni) and
            to_integer(unsigned(a(mb - 1 downto bb))) >= (bk - ni - nd) then
            return true;
        else
            return false;
        end if;
    end function;

    -- ram bits
    function mbits(b: integer) return integer is
    begin
        for i in 0 to bk - 1 loop
            if 2**i = b then
                return (i + bb);
            elsif 2**i > b then
                return (i + bb);
            end if;
        end loop;
    end function;

    -- higher iram addresses: return exact number of bits
    function iaddr(a: std_logic_vector(mb - 1 downto 0)) return std_logic_vector is
        variable r: std_logic_vector(mb - bb - 1 downto 0) := a(mb - 1 downto bb);
        variable b: integer;
    begin
        b := to_integer(unsigned(r));
        for i in 0 to ni - 1 loop -- loop over ni blocks
            if (i + bk - ni) = to_integer(unsigned(r)) then
                b := i;
                --return std_logic_vector(to_unsigned(i,mb - bb)) & a(bb - 1 downto 0);
            end if;
        end loop;
        return std_logic_vector(to_unsigned(b,mbits(ni) - bb)) & a(bb - 1 downto 0);
    end function;

    -- higher dram addresses: return exact number of bits
    function daddr(a: std_logic_vector(mb - 1 downto 0)) return std_logic_vector is
        variable r: std_logic_vector(mb - bb - 1 downto 0) := a(mb - 1 downto bb);
        variable b: integer;
    begin
        b := to_integer(unsigned(r));
        for i in 0 to nd - 1 loop -- loop over ni blocks
            if (i + bk - ni - nd) = to_integer(unsigned(r)) then
                b := i;
                --return std_logic_vector(to_unsigned(i,mb - bb)) & a(bb - 1 downto 0);
            end if;
        end loop;
        return std_logic_vector(to_unsigned(b,mbits(nd) - bb)) & a(bb - 1 downto 0);
    end function;


    -- -------------------------------------------


    COMPONENT hc08_core
    PORT(
         clk : IN  std_logic;
         rst_n : IN  std_logic;
         irq : IN  std_logic;
         addr : OUT  std_logic_vector(15 downto 0);
         wr : OUT  std_logic;
         wt    : in std_logic := '0';
         datain : IN  std_logic_vector(7 downto 0);
         state : OUT  std_logic_vector(3 downto 0);
         dataout : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;

   signal datain : std_logic_vector(7 downto 0) := (others => '0');
   signal addr : std_logic_vector(15 downto 0);
   signal wr_n : std_logic;
   signal dataout : std_logic_vector(7 downto 0);
    signal state : std_logic_vector(3 downto 0);
    signal wt: std_logic := '0';
    constant wtMax: integer := 4;
    signal wtCnt: integer range 0 to wtMax := 0;

	-- on spartan 6, core runs @ 30MHz
   signal uclk, rclk : std_logic := '0';
   signal clk_rst, clk_locked : std_logic := '0';
	signal cpuRst, cpuRst_n: std_logic;

	-- mem ranges: 0 for register ram, 1..8 for peripherals in page 0, 9 for aux ram, 10 for main ram/ram
	constant peripherals: integer := 8;
	-- percfg: length is one less as we will replace gpio with simulation
	signal perCfg: std_logic_vector(peripherals - 1 downto 1) := (others => '0');
	constant memRanges: integer := 3;
	constant decoderRanges: integer := peripherals + memRanges;
	signal mwr: std_logic_vector(decoderRanges - 1 downto 0);
	signal mrd: std_logic_vector(decoderRanges - 1 downto 0);
	type rdType is array(0 to decoderRanges - 1) of std_logic_vector(7 downto 0);
	signal rdData: rdType;
	signal busErr: std_logic := '1';
        -- video address
	signal vidAddr: std_logic_vector(mbits(nd) - 1 downto 0) := (others => '0');
	signal vidData: std_logic_vector(7 downto 0);

	-- page 0 ram
	type ramType is array(0 to 127) of std_logic_vector(7 downto 0);
	signal ram: ramType;

	constant ones: std_logic_vector(15 downto 0) := (others => '1');
	constant zeros: std_logic_vector(15 downto 0) := (others => '0');

	signal intr: std_logic_vector(peripherals -1 downto 0) := (others => '0');
	signal irq: std_logic;

	signal rst0, rst: std_logic;
	attribute ASYNC_REG: string;
	attribute ASYNC_REG of rst0: signal is "TRUE";
	attribute ASYNC_REG of rst: signal is "TRUE";

	-- range ids, peripherals start with 0, followed by memory ranges
	constant gpioId: integer := 0;
	constant timerId: integer := 1;
	constant uartId: integer := 2;
	constant pwmId: integer := 3;
	constant i2cId: integer := 4;
	constant spiId: integer := 5;
	constant sdrId: integer := 6;
	constant rfu2: integer := 7;
	constant lowRamId: integer := decoderRanges - memRanges;
	constant dataRamId: integer := decoderRanges - 2;
	constant instrRamId: integer := decoderRanges - 1;



	component timer
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         re : IN  std_logic;
         we : IN  std_logic;
         addr : IN  std_logic_vector(3 downto 0);
         din : IN  std_logic_vector(7 downto 0);
         dout : out  std_logic_vector(7 downto 0);
         irq : OUT  std_logic
        );
	end component;

	component gpio
		 generic (
			mhz: integer;
			bounce: boolean;
            gpInvIn: boolean := false; -- invert input
            gpInvOut: boolean := false; -- invert output
			-- configs
                hasVideo: boolean := false;
			simulation: boolean := simulation
		 );
		 PORT(
				clk : IN  std_logic;
				rst : IN  std_logic;
                periphs: std_logic_vector(7 downto 1);
				gpin: in std_logic_vector(7 downto 0);
				gpout: out std_logic_vector(7 downto 0);
				re : IN  std_logic;
				we : IN  std_logic;
				addr : IN  std_logic_vector(3 downto 0);
				din : IN  std_logic_vector(7 downto 0);
				dout : out  std_logic_vector(7 downto 0);
                                vgaOffs: out std_logic_vector(15 downto 0);
				irq : OUT  std_logic
			  );
	end component;
        signal gpout_i: std_logic_vector(7 downto 0);
        signal vgaOffset: std_logic_vector(15 downto 0);


	component uart
    generic (
        mhz: integer := 25
    );
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         re : IN  std_logic;
         we : IN  std_logic;
         rx : IN  std_logic;
         tx : out  std_logic;
         addr : IN  std_logic_vector(3 downto 0);
         din : IN  std_logic_vector(7 downto 0);
         dout : out  std_logic_vector(7 downto 0);
         irq : OUT  std_logic
        );
	end component;

	signal rx_r, rx_s: std_logic;
	attribute ASYNC_REG of rx_r: signal is "TRUE";
	attribute ASYNC_REG of rx_s: signal is "TRUE";



	-- clocking
	component clkgen
    generic (
        mhz: integer := 30;
        cgmult: integer := 2 -- rclk frequency multiplier
    );
	port
	 (-- Clock in ports
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
	end component;

	signal PixClk          :     std_logic;
	signal memClk          :     std_logic;

	-- boot control
	COMPONENT bootCtl
	generic (
		mhz: integer;
		abytes: integer := 2;
		dbytes: integer := 1;
		cbits: integer := 1
	);
	PORT(
		clk : IN std_logic;
		rst : IN std_logic;
		rx : IN std_logic;
      wrt : out  std_logic := '0';
		ctl : OUT std_logic_vector(cbits - 1 downto 0);
		addr : OUT std_logic_vector(abytes * 8 - 1 downto 0);
		data : OUT std_logic_vector(dbytes * 8 - 1 downto 0)
		);
	END COMPONENT;

	signal btCtl :  std_logic_vector(3 downto 0);
	signal btWrt :  std_logic;
	signal btAddr :  std_logic_vector(15 downto 0);
	signal btData :  std_logic_vector(7 downto 0);

	-- we need to keep the boot signals for the debugger
	ATTRIBUTE keep : BOOLEAN;
	ATTRIBUTE keep OF btCtl : SIGNAL IS true;
	ATTRIBUTE keep OF btWrt : SIGNAL IS true;
	ATTRIBUTE keep OF btAddr : SIGNAL IS true;
	ATTRIBUTE keep OF btData : SIGNAL IS true;


	-- code/data ram
	COMPONENT ramRom
	generic (
			dualport: boolean := true;
			mabits: integer := 14; -- changes here require update of bmm file
			simulation: boolean := false
	 );
    PORT(
        -- cpu side
         uclk : IN  std_logic;
         uwr : IN  std_logic;
         uaddr : in  std_logic_vector(mabits - 1 downto 0);
         udin : in  std_logic_vector(7 downto 0);
         udout : out  std_logic_vector(7 downto 0);
         -- boot side
			bctl: in std_logic;
         bclk : IN  std_logic;
         bwr : IN  std_logic;
         baddr : in  std_logic_vector(mabits - 1 downto 0);
         bdin : in  std_logic_vector(7 downto 0);
         bdout : out  std_logic_vector(7 downto 0)
        );
	END COMPONENT;

        -- pwm
    COMPONENT pwmCtl
    generic (
                mhz : integer := 30;
                channels:integer := 8
	 );
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         pulse: out std_logic_vector(channels - 1 downto 0);
         re : IN  std_logic;
         we : IN  std_logic;
         addr : IN  std_logic_vector(3 downto 0);
         din : IN  std_logic_vector(7 downto 0);
         dout : out  std_logic_vector(7 downto 0);
         irq : OUT  std_logic
        );
    end COMPONENT;
    signal pulse_i: std_logic_vector(pwms - 1 downto 0);

    -- i2c
    COMPONENT i2c
    generic (
		mhz: integer := 30
	 );
    PORT(
        clk : IN  std_logic;
        rst : IN  std_logic;
        re : IN  std_logic;
        we : IN  std_logic;
        addr : IN  std_logic_vector(3 downto 0);
        din : IN  std_logic_vector(7 downto 0);
        dout : out  std_logic_vector(7 downto 0);
        sda       : inOUT  STD_LOGIC;                    --serial data output of i2c bus
        scl       : inOUT  STD_LOGIC;                   --serial clock output of i2c bus
        irq : OUT  std_logic
        );
    END COMPONENT;
    --signal sda_i : STD_LOGIC;
    --signal scl_i : STD_LOGIC;

    component spi
    generic (
		mhz: integer := 30
	 );
    PORT(
        clk : IN  std_logic;
        rst : IN  std_logic;
        re : IN  std_logic;
        we : IN  std_logic;
        addr : IN  std_logic_vector(3 downto 0);
        din : IN  std_logic_vector(7 downto 0);
        dout : out  std_logic_vector(7 downto 0);
		miso    : IN     STD_LOGIC;                             --master in, slave out
		sclk    : out STD_LOGIC;                             --spi clock
		ss_n    : out STD_LOGIC;   			     --slave select
		mosi    : OUT    STD_LOGIC;                             --master out, slave in
        irq : OUT  std_logic
        );
    END COMPONENT;

    component vgaTiming
    -- no generics here just plain vga
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           row : out  STD_LOGIC_VECTOR (11 downto 0);
           col : out  STD_LOGIC_VECTOR (11 downto 0);
           hsc : out  STD_LOGIC;
           vsc : out  STD_LOGIC;
           act : out  STD_LOGIC
        );
end component;

    signal vgaRow :   STD_LOGIC_VECTOR (11 downto 0);
    signal vgaCol :   STD_LOGIC_VECTOR (11 downto 0);
    signal vgaPixCol: STD_LOGIC_VECTOR (2 downto 0);
    signal vidPixCol: STD_LOGIC_VECTOR (2 downto 0);
    signal vidPixCol_r: STD_LOGIC_VECTOR (2 downto 0);
    signal vgaHsc, vgaHsc_r0, vgaHsc_r1, vgaHsc_r2 :   STD_LOGIC;
    signal vgaVsc, vgaVsc_r0, vgaVsc_r1, vgaVsc_r2 :   STD_LOGIC;
    signal vgaAct, vgaAct_r0,vgaAct_r1, vgaAct_r2 :   STD_LOGIC;
	-- pipeline regs
	signal hs0,hs1,vs0, vs1: std_logic;

   signal vgaAddr : std_logic_vector(11 downto 0);


   -- sdram so far, intel only
    component sdram_wrap

    generic (
		target: string := "simple";
        dbits: integer := 16;
        abits: integer := 22;
        sdabits: integer := 12;
        mhz: integer := 100
        );
    port (
        -- control
        clk : IN  std_logic;
        memclk : IN  std_logic;
        rst : IN  std_logic;
        re : IN  std_logic;
        we : IN  std_logic;
        addr : IN  std_logic_vector(3 downto 0);
        din : IN  std_logic_vector(7 downto 0);
        dout : out  std_logic_vector(7 downto 0);

        -- sdram io
        sdr_addr: out std_logic_vector(sdabits - 1 downto 0);
        sdr_ba: out std_logic_vector(1 downto 0);
        sdr_cas_n: out std_logic;
        sdr_cke: out std_logic;
        sdr_clk: inout std_logic_vector(0 downto 0);
        sdr_cs_n: out std_logic;
        sdr_dq: inout std_logic_vector(dbits - 1 downto 0);
        sdr_dqm: out std_logic_vector(dbits/8 - 1 downto 0);
        sdr_ras_n: out std_logic;
        sdr_we_n: out std_logic
    );
end component;

    constant sdr_abits: integer := 22;

    function sdramTarget return string is
    begin
        if simulation then
            return "simple";
        else
            return "cyclone10lp";
        end if;
    end function;


begin


    -- clock generator. use device specific implementation
    clk_rst <= not rst_n;

    cg : clkgen
        generic map(
            mhz => mhz,
            cgmult => cgmult
        )
        port map
            (
                CLK_IN1 => clk,
                Uclk => uclk,
                rclk => rclk,
                -- future use ...
                PixClk => PixClk,
					 Mclk => memClk,
                -- end future
                RESET  => clk_rst,
                LOCKED => clk_LOCKED);

        process(uclk,clk_LOCKED)
        begin
                if clk_LOCKED = '0' then
                            rst0 <= '1';
                            rst <= '1';
                elsif rising_edge(uclk) then
                            rst0 <= not clk_locked;
                            rst <= rst0;
                end if;
        end process;

	-- cpu reset must be delayed until after locked
	process
		variable rsdelay: integer;
	begin
		wait until rising_edge(uclk);
		if rst = '1' or btCtl(0) = '1' then
			cpuRst <= '1';
			rsdelay := 100;
		elsif rsdelay > 0 then
			rsdelay := rsdelay - 1;
		else
			cpuRst <= '0';
		end if;
	end process;
	cpuRst_n <= not cpuRst;


   core: hc08_core
   PORT MAP (
          clk => uclk,
          rst_n => cpuRst_n,
          irq => irq,
          addr => addr,
          wr => wr_n,
          wt => wt,
          datain => datain,
          state => state,
          dataout => dataout
        );

    -- address decoder. remember, we start with peripherals
	decode: process(addr, wr_n)
	begin
		mrd <= (others => '0');
		mwr <= (others => '0');
		busErr <= '1';
		-- top: instruction/data ram
		--if addr(15 downto mabits) = ones(15 downto mabits) then
		if isel(addr) then
			mrd(instrRamId) <= wr_n;
			mwr(instrRamId) <= not wr_n;
			busErr <= '0';
		-- second top: aux ram, same size as main ram
		-- elsif addr(15 downto mabits) = ones(15 downto mabits + 1) & '0' then
		elsif dsel(addr) then
			mrd(dataRamId) <= wr_n;
			mwr(dataRamId) <= not wr_n;
			busErr <= '0';
		-- page 0 ram, 128 byte, above peripherals
		elsif addr(15 downto 7) = zeros(15 downto 7) then
			mrd(lowRamId) <= wr_n;
			mwr(lowRamId) <= not wr_n;
			busErr <= '0';
		-- periphs, 128 byte => 16 addr per periheral
		elsif addr(15 downto 7) = zeros(15 downto 8) & '1' then
			for i in 0 to peripherals - 1 loop
				if addr(6 downto 4) = std_logic_vector(to_unsigned(i,3)) then
					mrd(i) <= wr_n;
					mwr(i) <= not wr_n;
					busErr <= '0';
				end if;
			end loop;
		end if;
	end process;

	-- no internal wait 
    wt <= '0';

	-- mux
	mux: process(mrd, rdData)
	begin
		dataIn <= X"5A";
		for i in 0 to decoderRanges - 1 loop
			if mrd(i) = '1' then
				dataIn <= rdData(i);
			end if;
		end loop;
	end process;

	--irq
	process(intr)
		variable irq_i: std_logic;
	begin
		irq_i := '0';
		for i in 0 to intr'length - 1 loop
			if intr(i) = '1' then
				irq_i := '1';
			end if;
		end loop;
		irq <= irq_i;
	end process;

	-- small ram
	rdram0:process
	begin
		wait until rising_edge(rclk);
		rdData(lowRamId) <= ram(to_integer(unsigned(addr(6 downto 0))));
	end process;

	wrram0:process
	begin
		wait until rising_edge(rclk); -- uclk
		if mwr(lowRamId) = '1' then
			ram(to_integer(unsigned(addr(6 downto 0)))) <= dataout;
		end if;
	end process;

	-- in simulation mode copy address and value of ram from 0x08 to trace output
	-- don't start at 0, the first locations are used during memory initialisation
	-- and make noise ....
	-- simtrace: if simulation generate begin
	simtrace: if true generate begin
            process begin
                wait until rising_edge(rclk); -- uclk
					 sim_addr <= addr;
					 sim_irq <= irq;
                if (mwr(lowRamId) = '1') and (addr(6 downto 0) = "0001000") then
                        sim_task <= dataout;
                elsif (mwr(lowRamId) = '1') and (addr(6 downto 0) = "0001010") then
                        sim_mbv <= dataout;
                elsif (mwr(lowRamId) = '1') and (addr(6 downto 0) = "0001011") then
                        sim_mbb <= dataout;
                elsif (mwr(lowRamId) = '1') and (addr(6 downto 0) = "0001100") then
                        sim_mxt <= dataout;
                elsif (mwr(lowRamId) = '1') and (addr(6 downto 0) = "0001101") then
                        sim_mxb <= dataout;
                end if;
            end process;
	end generate;


	-- instruction ram
	ir: ramRom
	generic map(
			dualport => dualport,
			mabits => mbits(ni),
			simulation => simulation
	)
	PORT MAP(
		uclk => rclk,
		uwr => mwr(instrRamId),
		uaddr => iaddr(addr),
		udin => dataout,
		udout => rdData(instrRamId),
		bctl => btctl(0),
		bclk => uclk,
		bwr => btWrt,
		baddr => btAddr(mbits(ni) - 1 downto 0),
		bdin => btData,
		bdout => open
	);

	-- data ram. is dual ported for future use
	dr: ramRom
	generic map(
			dualport => true,
			mabits => mbits(nd),
			simulation => simulation
	)
	PORT MAP(
		uclk => rclk,
		uwr => mwr(dataRamId),
		uaddr => daddr(addr),
		udin => dataout,
		udout => rdData(dataRamId),
		bctl => '0',
		bclk => PixClk,
		bwr => '0',
		baddr => vidAddr(mbits(nd) - 1 downto 0),
		bdin => X"00",
		bdout => vidData
	);

	--------------------- peripherals --------------------
	-- gpio: has no percfg bit!
	gp: gpio
    generic map (mhz => mhz,
	bounce => true,
    gpInvIn => gpInvIn,
    gpInvOut => gpInvOut,
    hasVideo => hasVideo,
	 simulation => simulation
	 )
    PORT map(
         clk => uclk,
         rst => cpuRst,
         re => mrd(gpioId),
         we => mwr(gpioId),
         periphs => perCfg,
         addr => addr(3 downto 0),
         din => dataout,
         dout => rdData(gpioId),
			gpin => gpin,
			gpout => gpout_i,
         vgaOffs => vgaOffset,
         irq => intr(gpioId)
        );

	-- timer
    -- allow to compile without timer for mini-mini mode 
	withTimer: if hasTimer generate begin
	perCfg(timerId) <= '1';
	tm: timer
    PORT map(
         clk => uclk,
         rst => cpuRst,
         re => mrd(timerId),
         we => mwr(timerId),
         addr => addr(3 downto 0),
         din => dataout,
         dout => rdData(timerId),
         irq => intr(timerid)
        );
	end generate;

	-- uart
	perCfg(uartId) <= '1';
	-- rx sync
	process -- 2 stage sync
	begin
		wait until rising_edge(uclk);
		rx_r <= rx;
		rx_s <= rx_r;
	end process;
	ur: uart
    generic map (
        mhz => mhz
    )
    PORT map(
         clk => uclk,
         rst => cpuRst,
         re => mrd(uartId),
         we => mwr(uartId),
         addr => addr(3 downto 0),
         din => dataout,
         dout => rdData(uartId),
			rx => rx_s,
			tx => tx,
         irq => intr(uartId)
        );

     -- optional peripherlals
        -- pwm
    withPwm: if pwms > 0 generate
    begin
	perCfg(pwmId) <= '1';
    pwm: pwmCtl
    generic map (
                mhz => mhz,
                channels => pwms
	 )
    PORT map(
         clk => uclk,
         rst => cpuRst,
         re => mrd(pwmId),
         we => mwr(pwmId),
         addr => addr(3 downto 0),
         din => dataout,
         dout => rdData(pwmId),
         pulse => pulse_i,
         irq => intr(pwmId)
        );
    pulse <= pulse_i;
    end generate;

    -- i2c
    withI2c: if hasI2c generate
    begin
	perCfg(i2cId) <= '1';
    iic: i2c
    generic map (mhz => mhz)
    PORT map (
         clk => uclk,
         rst => cpuRst,
         re => mrd(i2cId),
         we => mwr(i2cId),
         addr => addr(3 downto 0),
         din => dataout,
         dout => rdData(i2cId),
         sda => sda,
         scl => scl,
         irq => intr(i2cId)
        );
    end generate;

    -- spi
    withSpi: if hasSpi generate
    begin
	perCfg(spiId) <= '1';
   spiInst : spi
    generic map (mhz => mhz)
    PORT map (
         clk => uclk,
         rst => cpuRst,
         re => mrd(spiId),
         we => mwr(spiId),
         addr => addr(3 downto 0),
         din => dataout,
         dout => rdData(spiId),
        miso => miso,
        sclk => sclk,
        ss_n => ss_n,
        mosi => mosi,
         irq => intr(spiId)
        );
    end generate;


  -- vga video
  withVideo: if hasVideo generate
  begin
    vga: vgaTiming
    -- no options here, use vga default
    port map (
        clk => PixClk,
        rst => cpuRst,
        row => vgaRow,
        col => vgaCol,
        hsc => vgaHsc,
        vsc => vgaVsc,
        act => vgaAct
    );

    -- address mapping
    process
            variable r,c: integer; -- unsigned(addr'length - 1 downto 0);
            variable a: integer; --unsigned(addr'length + 1 downto 0);
    begin
            wait until rising_edge(pixClk);
            -- divide rows and columns by 4 => format 160 * 120
            -- divide column also by 8 for pixel addressing
            r := to_integer(unsigned(vgaRow(11 downto 2)));
            c := to_integer(unsigned(vgaCol(11 downto 2 + 3)));
            -- row inclremet is 640 / 4 / 8 = 20
            a := r * 20 + c;
            vgaAddr <= std_logic_vector(to_unsigned(a,vgaAddr'length));
            vgaPixCol <= vgaCol(2 + 2 downto 2 + 0);
            vgaAct_r0 <= vgaAct;
            vgaHsc_r0 <= vgaHsc;
            vgaVsc_r0 <= vgaVsc;
    end process;

    -- map address to ram address
    process(vgaAddr, vgaOffset)
        variable a: integer range 0 to 2**mbits(nd) - 1;
    begin
        a := to_integer(unsigned(vgaOffset)) + to_integer(unsigned(vgaAddr));
        vidAddr <= std_logic_vector(to_unsigned(a, mbits(nd)));
        vidPixCol <= vgaPixCol;
        vgaAct_r1 <= vgaAct_r0;
        vgaHsc_r1 <= vgaHsc_r0;
        vgaVsc_r1 <= vgaVsc_r0;
    end process;

    -- capture data from ram and pipeline sync signals. NB: data is one cycle delayed
    process
        variable i: integer range 0 to 7;
	variable vr,vg,vb: std_logic;
    begin
            wait until rising_edge(pixClk);
            vidPixCol_r <= vidPixCol;
            vgaAct_r2 <= vgaAct_r1;
            vgaHsc_r2 <= vgaHsc_r1;
            vgaVsc_r2 <= vgaVsc_r1;
            -- bit index from pixel column
            i := to_integer(unsigned(vidPixCol_r));

            if vgaAct_r2 = '1' then
                vr := vidData(i);
                vg := vidData(i);
                vb := vidData(i);
            else
                vr := '0';
                vg := '0';
                vb := '0';
            end if;

	-- vga has inverted syncs
            -- hs0 <= vgaHsc_r2;
            vgaHS <= not vgaHsc_r2; -- hs0;

            -- vs0 <= vgaVsc_r2;
            vgaVS <= not vgaVsc_r2; -- vs0;

            vgaR <= vr;
            vgaG <= vg;
            vgaB <= vb;
    end process;

end generate;

        ---------------------------------------------------------------
        ---------------------------------------------------------------
    -- sdram
    withSdram: if hasSdram generate
    begin
	perCfg(sdrId) <= '1';
   sdramInst : sdram_wrap
        generic map (
            target => sdramTarget,
            dbits => sdr_dbits,
            abits => sdr_abits,
            sdabits => sdr_sdabits,
				-- adjust mhz according to used clock
            mhz => mhz * 4
        )
        PORT map (
            clk => uclk,
				memclk => memclk, -- or uclk or rclk
            rst => cpuRst,
            re => mrd(sdrId),
            we => mwr(sdrId),
            addr => addr(3 downto 0),
            din => dataout,
            dout => rdData(sdrId),
            sdr_addr        => sdr_addr,
            sdr_ba          => sdr_ba,
            sdr_cas_n       => sdr_cas_n,
            sdr_cke         => sdr_cke,
            sdr_clk         => sdr_clk,
            sdr_cs_n        => sdr_cs_n,
            sdr_dq          => sdr_dq,
            sdr_dqm         => sdr_dqm,
            sdr_ras_n       => sdr_ras_n,
            sdr_we_n        => sdr_we_n
        );
    end generate;

        ---------------------------------------------------------------
        ---------------------------------------------------------------
	-- boot control. don't use cpuRst here!
	bc: bootCtl
    generic map (
		mhz => mhz,
		abytes => 2,
		dbytes => 1,
		cbits => 4
	 )
	PORT MAP(
		clk => uclk,
		rst => rst,
		rx => rx_s,
		wrt => btWrt,
		ctl => btctl,
		addr => btAddr,
		data => btData
	);

	-- mux gpout
	process
	begin
		wait until rising_edge(uclk);
		if btCtl(0) = '1' then
			gpout <= btctl(3 downto 0) & X"5";
		else
			gpout <= gpout_i;
            end if;
	end process;


end Behavioral;

