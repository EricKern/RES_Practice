library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use std.textio.all;

entity vhdl2008_tb is
end entity;

architecture tb of vhdl2008_tb is

  signal A       : unsigned (3 downto 0) := "XXXX";
  signal B       : unsigned (3 downto 0) := "XXXX";
  signal Y       : unsigned (1 downto 0);
  signal c : std_logic;
  signal d : std_logic;
  signal q : std_logic;
  signal Request : std_logic_vector(3 downto 0) := "XXXX";
  signal Grant   : std_logic_vector(3 downto 0);
  signal NS1     : integer range 0 to 15 := 0;

component vhdl2008
generic (
  len: integer := 1
);
port (
  A       : in  unsigned (3 downto 0);
  B       : in  unsigned (3 downto 0);
  Y       : out unsigned (1 downto 0);
  c : in std_logic;
  d : in std_logic;
  q : out std_logic;
  Request : in  std_logic_vector(3 downto 0);
  Grant   : out std_logic_vector(3 downto 0);
  NS1     : out integer range 0 to 15
);
end component vhdl2008;

begin

/*
Demonstrate some of the new vhdl 2008 features
  simplified formatted output
  simplified conditional assignements in processes
  readback of output ports
  else clause on generate
  arbitrary width literals
  case match (doesn't work with ghdl however)
*/

process
  begin
  for i in 0 to 15 loop
    -- output time and value as hex
    write(output, justify(to_string(now,ns), field => 10) & LF);
    write(output, to_string(i) & LF);
    write(output, to_hstring(to_unsigned(i,8)) & LF);
    write(output, justify(to_string(now,ns), field => 10) & justify(to_hstring(to_unsigned(i,16)), field => 6 ) & LF);
    wait for 10 ns;
    Request <= std_logic_vector(to_unsigned(i,4));
  end loop;
  wait;
end process;

process begin
  for ia in 0 to 15 loop
    wait for 6 ns;
    A <= to_unsigned(ia,4);
    for ib in 0 to 15 loop
      wait for 7 ns;
      B <= to_unsigned(ib,4);
    end loop;
  end loop;
end process;

process begin
  c <= '1';
  wait for 10 ns;
  assert (c = '1') report "no clock" severity failure; -- error, warning,note
  c <= '0';
  wait for 10 ns;
  assert (c = '0') report "no clock" severity failure; -- error, warning,note
end process;

process
begin
  write(output, "-- start of file" & LF);         -- no type qualification required
  d <= '0';
  wait for 123 ns;
  write(output, justify(to_string(now,ns), field => 10) & " DATA:" & justify(to_string(d)  , field => 2 )  & LF  );
  d <= '1';
  wait for 111 ns;
  write(output, justify(to_string(now,ns), field => 10) & " DATA:"  & justify(to_string(d)  , field => 2 )  & LF  );
  d <= '0';
  report "D-Q test done" severity note;
  wait;
end process;


uut: vhdl2008 generic map(len => 0) port map (a,b,y,c,d,q,request,grant,ns1);



end tb;
