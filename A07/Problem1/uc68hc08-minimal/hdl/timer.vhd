-- Author: Sebastian Dittmeier
-- Update: 01.06.2021 - got rid of latches!
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
port(
	clk		: in std_logic;
	rst		: in std_logic;
	we			: in std_logic;
	re			: in std_logic;
	din		: in std_logic_vector(7 downto 0);
	addr		: in std_logic_vector(3 downto 0);
	dout		: out std_logic_vector(7 downto 0);
	irq		: out std_logic
);
end entity timer;

architecture rtl of timer is

signal load_value			: std_logic_vector(31 downto 0);	-- R/W
signal current_value 	: std_logic_vector(31 downto 0);	-- R/O
signal ctrl_reg		 		: std_logic_vector(7 downto 0);		-- R/W
signal stat_reg		 		: std_logic_vector(7 downto 0);		-- R/O
signal clear_reg		 	: std_logic_vector(7 downto 0);		-- R/W

signal cur_val_read   : std_logic_vector(3 downto 0);
signal rst_cur_val_read : std_logic;

signal counter : unsigned(31 downto 0);
signal first_start : std_logic;

-- address map:
-- 0000 load 7..0
-- 0001 load 15..8
-- 0010 load 23..16
-- 0011 load 31..24

-- 0100 current 7..0
-- 0101 current 15..8
-- 0110 current 23..16
-- 0111 current 31..24

-- 1000 ctrl 7..0
-- 1001 stat 7..0
-- 1010 clear 7..0

signal enable_cnt	: std_logic;
signal enable_rld : std_logic;
signal enable_irq : std_logic;

signal irq_active : std_logic;
signal irq_rst	: std_logic;
-- added a self clearing interrupt clear register
signal irq_cleared : std_logic;

-- bit map:
-- ctrl 0: enable_cnt
-- ctrl_1: enable_rld
-- ctrl 2: enable_irq

-- stat 0: irq_active
-- clear0: irq_rst

begin

	wr_proc: process(rst, clk)	--
	begin
		if rst = '1' then				-- async rst
			load_value	<= (others => '0');
			ctrl_reg		<= (others => '0');
			clear_reg		<= (others => '0');
		elsif(rising_edge(clk))then
			if(we = '1')then
				case addr is
					-- load value
					when "0000" =>
						load_value(7 downto 0) <= din;
					when "0001" =>
						load_value(15 downto 8) <= din;
					when "0010" =>
						load_value(23 downto 16) <= din;
					when "0011" =>
						load_value(31 downto 24) <= din;
					-- current cannot be written!
					-- next is ctrl
					when "1000" =>
						ctrl_reg <= din;
					-- stat cannot be written
					-- next is clear
					when "1010" =>
						clear_reg <= x"01";--din;
					when others =>
						null;
				end case;
			-- automatically clearing the rst of the interrupt again!
			elsif irq_cleared = '1' and irq_rst = '1' then
				clear_reg(0) <= '0';
			end if;
		end if;
	end process wr_proc;

-- bit mapping
	enable_cnt 	<= ctrl_reg(0);
	enable_rld	<= ctrl_reg(1);
	enable_irq	<= ctrl_reg(2);

	stat_reg(7 downto 1) <= "0000000";
	stat_reg(0)	<= irq_active;

	irq_rst		<= clear_reg(0);

	irq	<= irq_active;

	rd_proc: process(rst, re, addr, load_value, current_value, ctrl_reg, stat_reg, clear_reg)
	begin
		if rst = '1' then
			dout <= (others => '0');
		elsif re = '1' then
			case addr is
				when "0000" =>
					dout <= load_value(7 downto 0);
				when "0001" =>
					dout <= load_value(15 downto 8);
				when "0010" =>
					dout <= load_value(23 downto 16);
				when "0011" =>
					dout <= load_value(31 downto 24);

				when "0100" =>
					dout <= current_value(7 downto 0);
				when "0101" =>
					dout <= current_value(15 downto 8);
				when "0110" =>
					dout <= current_value(23 downto 16);
				when "0111" =>
					dout <= current_value(31 downto 24);

				when "1000" =>
					dout <= ctrl_reg;
				when "1001" =>
					dout <= stat_reg;
				when "1010" =>
					dout <= clear_reg;
				when others =>
					dout <= (others => '0');

			end case;
		else
			dout <= (others => '0');
		end if;
	end process rd_proc;

	count_proc : process(rst, clk)
	begin
		if rst = '1'then
			counter <= (others => '0');
			first_start <= '0';
		elsif(rising_edge(clk))then
			if (enable_cnt = '1') then
				first_start <= '1';
				counter <= counter - 1;
				if(counter = 0)then
					if(enable_rld = '1')then
						counter <= unsigned(load_value);
					else
						counter <= x"FFFFFFFF";
					end if;
				end if;
			end if;
		end if;
	end process count_proc;

	cur_proc : process (rst, clk)
	begin
		if rst = '1' then
			cur_val_read <= x"0";
			current_value <= (others => '0');
		elsif rising_edge(clk)then
			cur_val_read <= cur_val_read;
			if cur_val_read = x"0" then
				current_value <= std_logic_vector(counter);
			else
				current_value	<= current_value;
			end if;
			if re = '1' and addr(3 downto 2) = "01" then
				cur_val_read(to_integer(unsigned(addr(1 downto 0))))  <= '1';
				current_value	<= current_value;
			elsif rst_cur_val_read = '1' then
				cur_val_read	<= x"0";
			end if;
		end if;
	end process cur_proc;

	rst_cur_proc: process(rst, clk)
	begin
		if rst = '1' then
			rst_cur_val_read <= '0';
		elsif rising_edge(clk) then
			if cur_val_read = x"F"then
				rst_cur_val_read <= '1';
			else
				rst_cur_val_read <= '0';
			end if;
		end if;
	end process rst_cur_proc;

	irq_proc : process(rst, clk)-- counter, irq_rst, irq_active, irq_cleared, enable_irq)
	begin
		if rst = '1' then
			irq_active <= '0';
			irq_cleared <= '0';
		elsif(rising_edge(clk))then
			irq_active	<= irq_active;
			irq_cleared	<= irq_cleared;
			if counter = 0 and first_start = '1' then
				if enable_irq = '1' then
					irq_active <= '1';
				end if;
			end if;
			if irq_rst = '1' and irq_active = '1' then
				irq_active 	<= '0';
				irq_cleared <= '1';
			end if;
			if irq_rst = '0' and irq_cleared = '1' then
				irq_cleared 	<= '0';
			end if;
		end if;
	end process irq_proc;

end rtl;