LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

 
ENTITY timer_peripheral_tb IS
END timer_peripheral_tb;


ARCHITECTURE behavior OF timer_peripheral_tb IS 
 

 

    
   constant CLK_PERIOD : time := 10 ns;

   --Inputs
   --signal div_factor_tb : positive := 2;
   signal clk_tb : std_logic;
   signal reset_tb : std_logic;
   
   signal write_en_tb : std_logic;
   signal read_en_tb : std_logic;
   
   signal data_in_tb : std_logic_vector(7 downto 0);
   signal address_tb : std_logic_vector(3 downto 0);

 	--Outputs
	signal data_out_tb : std_logic_vector(7 downto 0);
    signal interrupt_request_tb	: std_logic;
 
BEGIN
		
	-- Instantiate the Unit Under Test (UUT)
    uut: entity work.timer32A(arch1) PORT MAP(
      clk				=> clk_tb,
		reset				=> reset_tb,
  		w_ena			=> write_en_tb,
		r_ena				=> read_en_tb,
		data_in				=> data_in_tb,
  		address				=> address_tb,
    	data_out			=> data_out_tb,
    	ir	=> interrupt_request_tb
    );
 
   -- generate the clock
   ckProc : process
   begin
      clk_tb <= '1';
      wait for CLK_PERIOD/2;
      clk_tb <= '0';
      wait for CLK_PERIOD/2;
   end process;


    -- Stimulus process
    testProc : process
    begin
    
    -- Reset timer peripheral
    reset_tb <= '0';
    wait for CLK_PERIOD;
    reset_tb <= '1';
    wait for CLK_PERIOD;
    reset_tb <= '0';
    
    -- Disbale counting (bit 0, lsb), disable reload (bit 1), disable interrupt (bit 2)
    	data_in_tb <= b"00000000"; -- DATA
        address_tb <= b"1000";  -- control register
        write_en_tb <= '1';  -- WRITE INTENT
        
        -- wait a clock cycle
        wait for CLK_PERIOD;
    	
        
    -- Write load value register (all four bytes) 
        data_in_tb <= x"19"; -- DATA 25
        address_tb <= b"0000";  -- Load value byte 0
        write_en_tb <= '1';  -- WRITE INTENT
        
        -- wait a clock cycle
        wait for CLK_PERIOD;
        
        data_in_tb <= x"00"; -- DATA
        address_tb <= b"0001";  -- Load value byte 1
        write_en_tb <= '1';  -- WRITE INTENT
        
        -- wait a clock cycle
        wait for CLK_PERIOD;
        
        data_in_tb <= x"00"; -- DATA
        address_tb <= b"0010";  -- Load value byte 2
        write_en_tb <= '1';  -- WRITE INTENT
        
        -- wait a clock cycle
        wait for CLK_PERIOD;
        
        data_in_tb <= x"00"; -- DATA
        address_tb <= b"0011";  -- Load value byte 3
        write_en_tb <= '1';  -- WRITE INTENT
        
        
        -- wait two clock cycles
        wait for CLK_PERIOD;
        write_en_tb <= '0';
        wait for CLK_PERIOD;
        
        
	-- Read load value register (all four bytes)
        address_tb <= b"0000";  -- Load value byte 0
        read_en_tb <= '1';  -- READ INTENT
		  wait for CLK_PERIOD;
        assert data_out_tb = x"19" report "data out has wrong value for address 0000" severity warning;
        
        
        address_tb <= b"0001";  -- Load value byte 1
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
        wait for CLK_PERIOD;
        assert data_out_tb = x"00" report "data out has wrong value for address 0001" severity warning;
        
        
        address_tb <= b"0010";  -- Load value byte 2
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
        wait for CLK_PERIOD;
        assert data_out_tb = x"00" report "data out has wrong value for address 0010" severity warning;
        
        
        address_tb <= b"0011";  -- Load value byte 3
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
        wait for CLK_PERIOD;
        assert data_out_tb = x"00" report "data out has wrong value for address 0011" severity warning;
        
        
        -- remove read intent
        read_en_tb <= '0';
        
        -- wait a clock cycle
        wait for CLK_PERIOD;
		  
		  	-- Enable counting, enable reload, disable interrupt
		  data_in_tb <= b"00000011"; -- enable count (0) uns load_val (1) 
        address_tb <= b"1000";  -- control register
        write_en_tb <= '1';
        -- also remove read intent
        --read_en_tb <= '0';  -- READ INTENT
        
    
  	-- Reset
        reset_tb <= '0';
        wait for CLK_PERIOD;
        reset_tb <= '1';
        wait for CLK_PERIOD;
        reset_tb <= '0';
        
		  wait for CLK_PERIOD;
        
    -- Read current value register (all four bytes)
    	address_tb <= b"0100";  -- curr value byte 0
        read_en_tb <= '1';  -- READ INTENT
        -- We loaded x"0000_0019" this is 25
        -- Since we enabled counting one clock cycle has passed -> value should be 24 (x"18")
        -- also remove write intent
        write_en_tb <= '0';
    	-- wait a clock cycle
        wait for CLK_PERIOD;
        assert data_out_tb = x"18" report "data out has wrong value for address 0100" severity warning;
    
        
        address_tb <= b"0101";  -- curr value byte 1
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
        wait for CLK_PERIOD;
        assert data_out_tb = x"00" report "data out has wrong value for address 0101" severity warning;
        
        
        address_tb <= b"0110";  -- curr value byte 2
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
       wait for CLK_PERIOD;
        assert data_out_tb = x"00" report "data out has wrong value for address 0110" severity warning;
        
        
        address_tb <= b"0111";  -- curr value byte 3
        read_en_tb <= '1';  -- READ INTENT
        assert data_out_tb = x"00" report "data out has wrong value for address 0111" severity warning;
        
	-- Wait some time and see if reload from load value register works
    
    	 -- wait for 20 clock cycles for roll-over
        wait for 22 * CLK_PERIOD;
        
        -- this is the value we expect after reloading !!!TODO: MAYBE HERE OFF BY ONE/TWO ERROR!!!
        address_tb <= b"0100";  -- curr value byte 0
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
        wait for CLK_PERIOD;
        assert data_out_tb = x"19" report "data out has wrong value for address 0100" severity warning;
        
		  
		  address_tb <= b"0101";  -- curr value byte 1
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
        wait for CLK_PERIOD;
        assert data_out_tb = x"00" report "data out has wrong value for address 0101" severity warning;
        
        
        address_tb <= b"0110";  -- curr value byte 2
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
       wait for CLK_PERIOD;
        assert data_out_tb = x"00" report "data out has wrong value for address 0110" severity warning;
        
        
        address_tb <= b"0111";  -- curr value byte 3
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
        wait for CLK_PERIOD;
        assert data_out_tb = x"00" report "data out has wrong value for address 0111" severity warning;
		  
        
	-- Wait some time and see if the timer rolls over from 0x0 to 0xFFFF_FFFF
    	-- Disable reload, enable interrupt      	
    	data_in_tb <= b"00000101"; -- enable count (0) don't use load_val (1) enable ir(2)
        address_tb <= b"1000";  -- control register
        write_en_tb <= '1';
        -- also remove read intent
        read_en_tb <= '0';  -- READ INTENT
        
        -- wait for 22+1 clock cycles
        wait for CLK_PERIOD;
        write_en_tb <= '0';
        wait for 21 * CLK_PERIOD;
        
        -- If reloading is disabled value should underflow to x"FFFFFFFF"
        -- Here only the first byte is checked
        address_tb <= b"0100";  -- curr value byte 0
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
        wait for CLK_PERIOD;
        assert data_out_tb = x"FF" report "data out has wrong value for address 0100" severity warning;
        
        
	-- See if interrupt is raised when timer reached 0x0
    	address_tb <= b"1001";  -- status register
        read_en_tb <= '1';  -- READ INTENT
        -- wait a clock cycle
        wait for CLK_PERIOD;
        assert data_out_tb = x"01" report "status register doesn't show interrupt request" severity warning;
        
        -- also check interrupt_request_tb
        assert interrupt_request_tb = '1' report "Interrupt request should be 1" severity warning;
    	
              
        -- Clear interrupt
        data_in_tb <= x"00"; -- DATA
        address_tb <= b"1010";  -- clear register
        write_en_tb <= '1';  -- WRITE INTENT
        -- also remove read intent
        read_en_tb <= '0';
        
        -- wait a clock cycle
        wait for 2*CLK_PERIOD;
		  assert interrupt_request_tb = '0' report "Meh Interrupt request should be 0" severity warning;
        
        
        -- See if interrupt is gone
    	address_tb <= b"1001";  -- status register
        read_en_tb <= '1';  -- READ INTENT
        -- also remove write intent
        write_en_tb <= '0';
        
        -- also check interrupt_request_tb
        wait for CLK_PERIOD;
        assert data_out_tb = x"00" report "data out has wrong value for address 1001" severity warning;
        
        -- wait a clock cycle
        wait for 2* CLK_PERIOD;
        
    	report "No errors yo! :)" severity note;
    wait ;
    end process;
 

END;