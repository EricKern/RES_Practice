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

use work.baudPack.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- all commands 2 bytes.
-- data stream: N words
-- write control
-- write address byte (0..n), value
-- stream data (size W), count N 
-- streaming, N*W values

entity bootCtl is
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
end bootCtl;

architecture Behavioral of bootCtl is

	signal a, anext: unsigned(abytes * 8 - 1 downto 0);
	signal dc, dcNext: unsigned(abytes * 8 - 1 downto 0);
	signal d, dnext: std_logic_vector(dbytes * 8 - 1 downto 0);
	signal c, cnext: std_logic_vector(cbits - 1 downto 0);
	signal w, wnext: std_logic;

	signal baudtick: std_logic;
	
	constant divider: integer := bdDiv(mhz);

	component UART_RX
                generic (oversampling: integer := 16);
		 port (
			  clk: in std_logic;
			  rst : in std_logic;
			  b_tick : in std_logic;
			  rx : in std_logic;
			  rx_done : out std_logic;
			  rx_brk : out std_logic;
			  dout: out std_logic_vector(7 downto 0)
		 );
	end component;
	
	signal rxv : std_logic;
	signal rxd : std_logic_vector(7 downto 0);
	
	-- fsm types
	-- idle, magic0/1/2, cmd0/1, stream, locked)
	type fsmType is (ST_I,ST_A,ST_C0,ST_C,ST_D, ST_M0,ST_M1,ST_L,ST_S); 
	signal state, stateNext: fsmType := ST_I;
	
	constant cmdL: integer := 0; -- invlaid/lock
	constant cmdC: integer := 1; -- control
	constant cmdA: integer := 2; -- address
	constant cmdD: integer := 3; -- data length
	constant cmdS: integer := 4; -- data stream
	constant cmdI: integer := 5; -- initialize
	
	constant errMax: integer := 20;
	signal err, errNext: integer range 0 to errMax - 1;
	-- signal dc, dcNext: integer range 0 to dbytes * 256 - 1;
	signal idx, idxNext: integer range 0 to 4; -- dual use
	
	type mt is array (0 to 2) of std_logic_vector(7 downto 0);
	constant magic: mt := ( X"58",X"59",X"5a" ); -- X,Y,Z
	
begin

    -- fsm core
    process
    begin
        wait until rising_edge(clk);
        if rst = '1' then
            state <= ST_I;
            err <= 0;
				a <= (others => '0');
				c <= (others => '0');
				d <= (others => '0');
				dc <= (others => '0');
				idx <= 0;
				w <= '0';
		  elsif state = ST_L then
				a <= (others => '0');
				c <= (others => '0');
				d <= (others => '0');
				w <= '0';
        else
            state <= stateNext;
            err <= errNext;
				if (w = '0') then
					a <= anext;
				else
					a <= a + 1;
				end if;
				c <= cnext;
				d <= dnext;
				dc <= dcNext;
				idx <= idxNext;
				w <= wnext;
        end if;
    end process;
    
    --fsm logic 
    process(state, err, a, c, d, rxd, rxv, idx, dc)
		variable cmd: integer range 0 to 15;
		
    begin
			-- defaults
        stateNext <= state;
		  errNext <= err;
		  anext <= a;
		  cnext <= c;
		  dnext <= d;
		  dcNext <= dc;
		  idxNext <= idx;
		  wnext <= '0';

			cmd := to_integer(unsigned(rxd(7 downto 4)));
        
		  -- transtitions
        case state is
            when ST_I =>
					if rxv = '1' then
						if rxd = magic(0) then
							stateNext <= ST_M0;
						else
							if err < errMax - 1 then
								errNext <= err + 1;
							else
								stateNext <= ST_L; -- too many errors
							end if;
						end if;
					end if;
            
            when ST_M0 =>
					if rxv = '1' then
						if rxd = magic(1) then
							stateNext <= ST_M1;
						else
							if err < errMax - 1 then
								errNext <= err + 1;
								stateNext <= ST_I;
							else
								stateNext <= ST_L; -- too many errors
							end if;
						end if;
					end if;

            when ST_M1 =>
					if rxv = '1' then
						if rxd = magic(2) then
							stateNext <= ST_C0;
						else
							if err < errMax - 1 then
								errNext <= err + 1;
								stateNext <= ST_I;
							else
								stateNext <= ST_L; -- too many errors
							end if;
						end if;
					end if;
            
				-- command decoder
            when ST_C0 =>
					if rxv = '1' then
						idxNext <= to_integer(unsigned(rxd(1 downto 0)));
						case cmd is
							when cmdC =>
								stateNext <= ST_C;
							when cmdA =>
								stateNext <= ST_A;
							when cmdD =>
								stateNext <= ST_D;
							when cmdS =>
                                idxNext <= dbytes - 1;
								stateNext <= ST_S;
							when cmdI =>
                                errNext <= 0;
								stateNext <= ST_I;
							when cmdL => 
								stateNext <= ST_L;	-- error
							when others => 
								stateNext <= ST_I;	-- got to init
							end case;
						end if;
            
	-- control
            when ST_C =>
					if rxv = '1' then
						cnext <= rxd(cbits - 1 downto 0);
						stateNext <= ST_C0;
					end if;
            -- address bytes
            when ST_A =>
					if rxv = '1' then
						anext(idx*8 + 7 downto idx * 8) <= unsigned(rxd);
						stateNext <= ST_C0;
					end if;
            -- data count bytes
            when ST_D =>
					if rxv = '1' then
						dcNext(idx*8 + 7 downto idx * 8) <= unsigned(rxd);
						stateNext <= ST_C0;
					end if;
            -- data stream, in words
            when ST_S =>
					if rxv = '1' then
						dnext(idx*8 + 7 downto idx * 8) <= rxd;
						if idx > 0 then
							-- next byte
							idxNext <= idx - 1;
						else
							-- write pulse
							wnext <= '1';
							-- more data ?
							if dc = 0 then
								stateNext <= ST_C0;
                            else
								dcNext <= dc - 1;
								idxNext <= dbytes - 1;
							end if;
						end if;
					end if;
           -- error locked
           when ST_L =>
                null;
            when others => null;
            
        end case;    
        
    end process;
    

	-- bd tick
    process
        variable cnt: integer range 0 to divider;
    begin
        wait until rising_edge(clk);
        baudtick <= '0';
        if rst = '1' then
            cnt := 0; 
        elsif cnt < divider - 1 then
            cnt := cnt + 1;
        else
            cnt := 0;
            baudtick <= '1';
        end if;
    end process;

	urx: UART_RX
	generic map (oversampling => ovSamp(mhz))
    port map(
		clk => clk,
		rst => rst,
      b_tick => baudtick,
	  rx => rx,
	  rx_done => rxv,
	  rx_brk => open,
	  dout => rxd
    );

	-- outputs
	ctl <= c;
	addr <= std_logic_vector(a);
	data <= d;	
	wrt <= w;

end Behavioral;

