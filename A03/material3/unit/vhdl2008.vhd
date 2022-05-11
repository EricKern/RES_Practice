
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity vhdl2008 is
generic (
  len: integer := 1
);
port (
A : in unsigned (3 downto 0) ;
B : in unsigned (3 downto 0) ;
Y : out unsigned (1 downto 0) ;

c : in std_logic;
d : in std_logic;
q : out std_logic;

Request: in std_logic_vector(3 downto 0);
Grant: out std_logic_vector(3 downto 0);
NS1: out integer range 0 to 15

);
end entity;

architecture a of vhdl2008 is

-- any bit width literals
constant ONE1 : unsigned(1 downto 0) := 2UX"3" ;
constant CHOICE2 : unsigned(3 downto 0) := 2X"0" & ONE1 ;

-- state types
type state_type is (s0,s1,s2);
signal s: state_type := s0;

begin

-- case doesn't support case? with don't care
process (A, B)
begin
case A xor B is
when "0000" => Y <= "00" ;
when CHOICE2 => Y <= "01" ;
when "0110" => Y <= "10" ;
when ONE1 & "00" => Y <= "11" ;
when others => Y <= "XX" ;
end case ;
end process ;


-- new case? (case match) for don't care with "-" 
-- doesn't work with GHDL
/*
process (Request)
begin
	case? Request is
	when "1---" => Grant <= "1000" ;
	when "01--" => Grant <= "0100" ;
	when "001-" => Grant <= "0010" ;
	when "0001" => Grant <= "0010" ;
	when others => Grant <= "0000";
end case? ;
end process ;
*/

-- simplified conditional in process
-- also shows output port readback works
process(all) begin
	NS1 <= 3 when (Request(0) = '1' and q = '0') else 5 ;
end process;

-- also works on states
process(all) begin
	case s is
		when s0 =>
			s <= s1  after 3 ns when a = "1010";
		when s1 =>
			s <= s2 after 10 ns;
		when others =>
			s <= s0 after 100 ns;
	end case;
end process;


-- else on generate
g1: if len = 0 generate begin
        q <= d after 2 ns;
    elsif len = 1 generate begin
        process begin
          wait until rising_edge(c);
          q <= d after 2 ns;
        end process;
    else generate begin
      process
        variable sr: std_logic_vector(len - 1 downto 0);
      begin
        wait until rising_edge(c);
				sr(0) := d;
				q <= sr(sr'length - 1) after 2 ns;
        for i in sr'length - 1 downto 1 loop
          sr(i) := sr(i-1);
        end loop;
      end process;

  end generate;



end a;
