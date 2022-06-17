----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.signal_generator_pkg.all;

-- entity
entity signal_generator is
port (
	period : in time;
	pulse_count : in integer;
	signal raw_signal : out std_logic := '0'
);
end signal_generator;

-- architecture
architecture top_level of signal_generator is


-- architecure implementations
begin

-- process
raw_signal_generator : process is
begin

	-- delay
	wait for 1 * period; -- pause
	
	-- pulse train
	generate_pulse_train ( 
		width => period / 2, 
		separation => period - period / 3,
		number => pulse_count,
		s => raw_signal 
	);

end process raw_signal_generator;

end architecture top_level;
