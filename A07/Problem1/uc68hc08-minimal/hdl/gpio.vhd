----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:15:23 07/27/2017 
-- Design Name: 
-- Module Name:    gpio - Behavioral 
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


entity gpio is
    generic (
		mhz: integer := 30;
		bounce: boolean := true;
		gpInvIn: boolean := false; -- invert input
		gpInvOut: boolean := false; -- invert output
			-- configs
                hasVideo: boolean := false;
		simulation: boolean := false
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
end gpio;

architecture Behavioral of gpio is

    -- gpio addr 0
    signal gpin_r0, gpin_r: std_logic_vector(7 downto 0);
    signal edge: std_logic_vector(7 downto 0);
	attribute ASYNC_REG: string;
	attribute ASYNC_REG of gpin_r0: signal is "TRUE";
	attribute ASYNC_REG of gpin_r: signal is "TRUE";

	function inv(v: std_logic_vector; i: boolean) return std_logic_vector is
        variable vi: std_logic_vector(v'length - 1 downto 0);
	begin
        if i then 
            for i in 0 to v'length - 1 loop
                vi(i) := not v(i);
            end loop;
            return vi;
        else
            return v;
        end if;
	end function;
	
	function cfgBit (v: boolean) return std_logic is
	begin
            if v then
                return  '1';
            else
                return '0';
            end if;
	end function;
	
    -- control addr 1..2
    signal ien: std_logic_vector(7 downto 0) := (others => '0');
    signal clr: std_logic := '1';

    -- irq. status bit 0 addr 1
    signal irq_i: std_logic;

	 function sim (s: boolean) return std_logic is
	 begin
		if s then 
			return '1';
		else
			return '0';
		end if;
	 end sim;

     -- addr2 : perihperal config: config 0
	 -- peripheral config0 : bit 0..6 of addr 2
         -- simulation bit: LSB of addr 2

	 -- addr 3 : config 1: frequency
	 -- addr 4: config 2: bit 0 = hasVideo on read

	 -- addr 5,6: write optional video offset
	 
	 -- standard debounce time 1 ms
	 constant debounce : integer := mhz * 1000;
    
begin

    -- register write
    process
    begin
        wait until rising_edge(clk);
        if rst = '1' then
            gpout <= (others => '0');
				clr <= '1';
				ien <= (others => '0');
        else
				clr <= '0';
				if we = '1' then
					case addr is 
						 when X"0" =>
							  gpout <= inv(din, gpInvOut);
						 when X"1" =>
							  ien <= din;
						 when X"2" =>
							  clr <= '1';
                                -- optional video offset
						 when X"5" =>
							  vgaOffs(7 downto 0) <= din;
						 when X"6" =>
							  vgaOffs(15 downto 8) <= din;
						 when others =>
							  null;
					end case;
			end if;
        end if;
    end process;

    -- direct mode
    dm: if not bounce generate
    begin
        dl: for i in 0 to gpin'length - 1 generate
        begin
            process
            begin
                                    wait until rising_edge(clk);
                                    if rst = '1' then
                                                    gpin_r0(i) <= '0';
                                                    gpin_r(i) <= '0';
                                                    edge(i) <= '0';
                                    else
                                                    edge(i) <= '0';
                                                    gpin_r0(i) <= inv(gpin, gpInvIn)(i);  --gpin(i);
                                                    gpin_r(i) <= gpin_r0(i);
                                                    if (gpin_r0(i) = gpin_r(i)) then 
                                                        edge(i) <= '1';
                                                    end if;
                                    end if;
            end process;
        end generate;
    end generate;
    
    -- debounce
    bm: if bounce generate
    begin
        dl: for i in 0 to gpin'length - 1 generate
        begin
            process
                    variable cnt: integer range 0 to debounce - 1;
            begin
                                    wait until rising_edge(clk);
                                    if rst = '1' then
                                                    gpin_r0(i) <= '0';
                                                    gpin_r(i) <= '0';
                                                    edge(i) <= '0';
                                    else
                                                    edge(i) <= '0';
                                                    -- check value
                                                    gpin_r0(i) <= inv(gpin, gpInvIn)(i);  --
                                                    if (gpin_r0(i) = gpin_r(i)) then 
                                                                    cnt := 0;	-- reset counter if match
                                                    elsif cnt < debounce - 1 then
                                                                    cnt := cnt + 1;	-- count if no match
                                                    else 
                                                                    gpin_r(i) <= gpin_r0(i);	-- update on timeout
                                                                    edge(i) <= '1';
                                                                    cnt := 0;
                                                    end if;
                                    end if;
            end process;
        end generate;
    end generate;
    
    
    -- register read
    process(addr, re, gpin_r, irq_i, periphs)
    begin
        dout <= (others => '0');
        if re = '1' then
            case addr is 
                when X"0" =>
                    dout <= gpin_r;
                when X"1" =>
                    dout <= "0000000" & irq_i;
                when X"2" => 
			  dout <= periphs(7 downto 1) & sim(simulation);
                when X"3" =>
                    dout <= std_logic_vector(to_unsigned(mhz,8));
                when X"4" =>
                    dout <= "0000000" & cfgBit(hasVideo);
                when others =>
                    null;
            end case;
        end if;
    end process;
    
    -- int control
    process
    begin
        wait until rising_edge(clk);
        if rst = '1' then
                irq_i <= '0';
        elsif clr = '1' then
                irq_i <= '0';
        else
            for i in 0 to 7 loop
                if ien(i) = '1' and edge(i) = '1' then
                    irq_i <= '1';
                end if;
            end loop;
        end if;
    end process;
    irq <= irq_i;


end Behavioral;

