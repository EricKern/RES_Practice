library ieee;
use ieee.std_logic_1164.all;

entity timer32A is

	port(
		clk		: in  std_logic;
		reset		: in  std_logic;
		w_ena		: in  std_logic;
		r_ena		: in  std_logic;
		data_in	: in  std_logic_vector(7 downto 0);
		address	: in  std_logic_vector(3 downto 0);
		data_out	: out std_logic_vector(7 downto 0);
		ir			: out std_logic
	  );
end timer32A;



architecture arch1 of timer32A is
-- Points for Imporvement:
-- You have to read the current_val_register completely to get a new value. Only reset possible

constant all_zero32 		:	std_logic_vector(31 downto 0) := (others => '0');

signal control_reg		:  std_logic_vector(7 downto 0);
signal status_reg	   	:  std_logic_vector(7 downto 0) := (others => '0');
signal clear_reg	   	:  std_logic_vector(7 downto 0);
signal load_val_reg		:	std_logic_vector(31 downto 0);
signal current_val_reg	:	std_logic_vector(31 downto 0);
signal counter_o_wire	:	std_logic_vector(31 downto 0);

signal read_flags	   	:  std_logic_vector(3 downto 0);

signal clear_toggler_lst:  std_logic := '0';  -- used to clear interrupt no matter what is written to the clear register
signal clear_toggler    :  std_logic := '0';  -- used to clear interrupt no matter what is written to the clear register
	 

begin

	counter : entity work.load_counter(arch1)
		generic map (bit_width => 32)
		port map (
			clk 			=> clk,
			en				=> control_reg(0),
			reset			=> reset,
			use_load		=> control_reg(1),
			load_val		=> load_val_reg,
			counter_o	=> counter_o_wire
		);


	set_ir:
	process(clk) is
	begin
		if(rising_edge(clk)) then
			if(clear_toggler_lst /= clear_toggler) then
				status_reg(0) <= '0';
			elsif(counter_o_wire = all_zero32 AND control_reg(2) = '1') then
				status_reg(0) <= '1';
			else
				status_reg(0) <= status_reg(0);
			end if;
		end if;
	end process;
	
	ir <= status_reg(0);
	

	lock_curr_val : process (reset, clk)
	begin
		if reset = '1' then
			read_flags <= "0000";
			current_val_reg <= (others => '0');
		elsif rising_edge(clk)then
			if read_flags = "0000" then
				current_val_reg <= counter_o_wire;
				else
				current_val_reg	<= current_val_reg;
			end if;
				
			if r_ena = '1' then
				case address is
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
	process(clk, reset) is
	begin 
		if(reset = '1') then
			clear_reg 	<= (others => '0');
			
		elsif(rising_edge(clk)) then
			if(w_ena = '1') then
				case address is
					when B"0000" => -- Load value byte 0
						 load_val_reg(7 downto 0) <= data_in;
						 
					when B"0001" => -- Load value byte 1
						 load_val_reg(15 downto 8) <= data_in;
						 
					when B"0010" => -- Load value byte 2
						 load_val_reg(23 downto 16) <= data_in;
						 
					when B"0011" => -- Load value byte 3
						 load_val_reg(31 downto 24) <= data_in;
						 
					when B"1000" => -- control register
						 control_reg <= data_in;
						 
					when B"1010" => -- clear register
						 clear_reg <= data_in;
						 clear_toggler_lst <= clear_toggler;
						 clear_toggler <= NOT clear_toggler;
						 
					when others => -- 'U', 'X', '-', etc.
					
				end case;
			end if;
		end if;
	end process;
	
	
	read_data:
	process(reset, r_ena, address, load_val_reg, current_val_reg, control_reg, status_reg, clear_reg) is
	begin
		if(reset = '1') then
				data_out <= (others => '0');
				
		elsif(r_ena = '1') then
			case address is
				when B"0000" => -- Load value byte 0
					 data_out <= load_val_reg(7 downto 0);
					 
				when B"0001" => -- Load value byte 1
					 data_out <= load_val_reg(15 downto 8);
					 
				when B"0010" => -- Load value byte 2
					 data_out <= load_val_reg(23 downto 16);
					 
				when B"0011" => -- Load value byte 3
					 data_out <= load_val_reg(31 downto 24);
					 
					 
				when B"0100" => -- curr value byte 0
					data_out <= current_val_reg(7 downto 0);
					 
				when B"0101" => -- curr value byte 1
					data_out <= current_val_reg(15 downto 8);
					 
				when B"0110" => -- curr value byte 2
					data_out <= current_val_reg(23 downto 16);
					 
				when B"0111" => -- curr value byte 3
					data_out <= current_val_reg(31 downto 24);
					 
				when B"1000" => -- control register
					 data_out <= control_reg;
					 
				when B"1001" => -- status register
					 data_out <= status_reg;
					 
				when B"1010" => -- clear register
					 data_out <= clear_reg;
					 
				when others => -- 'U', 'X', '-'
					 data_out <= (others => 'X');
			end case;
		else
			data_out <= (others => '0');	
		end if;
	
	end process;
	

end arch1;
