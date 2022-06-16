library ieee;
use ieee.std_logic_1164.all;

entity timer32A is

	port(
		clk		: in  std_logic;
		rst		: in  std_logic;
		we		: in  std_logic;
		re		: in  std_logic;
		din	: in  std_logic_vector(7 downto 0);
		addr	: in  std_logic_vector(3 downto 0);
		dout	: out std_logic_vector(7 downto 0);
		irq			: out std_logic
	  );
end timer32A;



architecture arch1 of timer32A is
-- Points for Imporvement:
-- You have to read the current_val_register completely to get a new value. Only rst possible

constant all_zero32 		:	std_logic_vector(31 downto 0) := (others => '0');

signal control_reg		:  std_logic_vector(7 downto 0);
signal status_reg	   	:  std_logic_vector(7 downto 0) := (others => '0');
signal clear_reg	   	:  std_logic_vector(7 downto 0);
signal load_val_reg		:	std_logic_vector(31 downto 0);
signal current_val_reg	:	std_logic_vector(31 downto 0);
signal counter_o_wirqe	:	std_logic_vector(31 downto 0);

signal read_flags	   	:  std_logic_vector(3 downto 0);

signal clear_toggler_lst:  std_logic := '0';  -- used to clear interrupt no matter what is written to the clear register
signal clear_toggler    :  std_logic := '0';  -- used to clear interrupt no matter what is written to the clear register
	 

begin

	counter : entity work.load_counter(arch1)
		generic map (bit_width => 32)
		port map (
			clk 			=> clk,
			en				=> control_reg(0),
			reset			=> rst,
			use_load		=> control_reg(1),
			load_val		=> load_val_reg,
			counter_o	=> counter_o_wirqe
		);


	set_irq:
	process(clk) is
	begin
		if(rising_edge(clk)) then
			if(clear_toggler_lst /= clear_toggler) then
				status_reg(0) <= '0';
			elsif(counter_o_wirqe = all_zero32 AND control_reg(2) = '1') then
				status_reg(0) <= '1';
			else
				status_reg(0) <= status_reg(0);
			end if;
		end if;
	end process;
	
	irq <= status_reg(0);
	

	lock_curr_val : process (rst, clk)
	begin
		if rst = '1' then
			read_flags <= "0000";
			current_val_reg <= (others => '0');
		elsif rising_edge(clk)then
			if read_flags = "0000" then
				current_val_reg <= counter_o_wirqe;
				else
				current_val_reg	<= current_val_reg;
			end if;
				
			if re = '1' then
				case addr is
					when B"0100" => -- curr value byte 0
						read_flags <= "1111";
						read_flags(0) <= '0';
							
					when B"0101" => -- curr value byte 1
						read_flags(1) <= '0';
							
					when B"0110" => -- curr value byte 2
						read_flags(2) <= '0';
							
					when B"0111" => -- curr value byte 3
						read_flags(3) <= '0';
					when others => -- 'U', 'X', '-', etc.
						read_flags <= read_flags;
				end case;
			else
				read_flags <= read_flags;
			end if;
		end if;
	end process lock_curr_val;
	
	
	write_data:
	process(clk, rst) is
	begin 
		if(rst = '1') then
			clear_reg 	<= (others => '0');
			
		elsif(rising_edge(clk)) then
			if(we = '1') then
				case addr is
					when B"0000" => -- Load value byte 0
						 load_val_reg(7 downto 0) <= din;
						 
					when B"0001" => -- Load value byte 1
						 load_val_reg(15 downto 8) <= din;
						 
					when B"0010" => -- Load value byte 2
						 load_val_reg(23 downto 16) <= din;
						 
					when B"0011" => -- Load value byte 3
						 load_val_reg(31 downto 24) <= din;
						 
					when B"1000" => -- control register
						 control_reg <= din;
						 
					when B"1010" => -- clear register
						 clear_reg <= din;
						 clear_toggler_lst <= clear_toggler;
						 clear_toggler <= NOT clear_toggler;
						 
					when others => -- 'U', 'X', '-', etc.
					
				end case;
			end if;
		end if;
	end process;
	
	
	read_data:
	process(rst, re, addr, load_val_reg, current_val_reg, control_reg, status_reg, clear_reg) is
	begin
		if(rst = '1') then
				dout <= (others => '0');
				
		elsif(re = '1') then
			case addr is
				when B"0000" => -- Load value byte 0
					 dout <= load_val_reg(7 downto 0);
					 
				when B"0001" => -- Load value byte 1
					 dout <= load_val_reg(15 downto 8);
					 
				when B"0010" => -- Load value byte 2
					 dout <= load_val_reg(23 downto 16);
					 
				when B"0011" => -- Load value byte 3
					 dout <= load_val_reg(31 downto 24);
					 
					 
				when B"0100" => -- curr value byte 0
					dout <= current_val_reg(7 downto 0);
					 
				when B"0101" => -- curr value byte 1
					dout <= current_val_reg(15 downto 8);
					 
				when B"0110" => -- curr value byte 2
					dout <= current_val_reg(23 downto 16);
					 
				when B"0111" => -- curr value byte 3
					dout <= current_val_reg(31 downto 24);
					 
				when B"1000" => -- control register
					 dout <= control_reg;
					 
				when B"1001" => -- status register
					 dout <= status_reg;
					 
				when B"1010" => -- clear register
					 dout <= clear_reg;
					 
				when others => -- 'U', 'X', '-'
					 dout <= (others => 'X');
			end case;
		else
			dout <= (others => '0');	
		end if;
	
	end process;
	

end arch1;
