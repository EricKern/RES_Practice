
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity idiv is   -- 17 bit dividend, 9 bit divisor
  port (
    dividend  : in  std_logic_vector(16 downto 0);
    divisor   : in  std_logic_vector(8 downto 0);
    quotient  : out std_logic_vector(8 downto 0);
    remainder : out std_logic_vector(8 downto 0)
  );
end entity idiv;

architecture behavior of idiv is

  component divcas9 
  port (
    dividend  : in  std_logic_vector(16 downto 0);
    divisor   : in  std_logic_vector(8 downto 0);
    quotient  : out std_logic_vector(8 downto 0);
    remainder : out std_logic_vector(8 downto 0)
  );
  end component divcas9;

begin

process(dividend, divisor)
	variable dv: natural; -- std_logic_vector(16 downto 0);
	variable ds: natural; -- std_logic_vector(16 downto 0);
	variable q: natural; -- std_logic_vector(16 downto 0);
	variable r: natural; -- std_logic_vector(16 downto 0);
begin
	dv := to_integer(unsigned(dividend));
	ds := to_integer(unsigned(divisor));
	q := dv / ds;
	r := dv mod ds;
	quotient <= std_logic_vector(to_unsigned(q,9));
	remainder <= std_logic_vector(to_unsigned(r,9));
end process;

end architecture behavior; -- idiv

-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity imul is   -- 8*8=>16
  generic (oldMath: boolean := true);
  port (
    a    : in  std_logic_vector(7 downto 0);
    b    : in  std_logic_vector(7 downto 0);
    prod : out std_logic_vector(15 downto 0)
  );
end entity imul;

architecture behavior of imul is

  component mul8 
  port(
    a    : in  std_logic_vector(7 downto 0);
    b    : in  std_logic_vector(7 downto 0);
    prod : out std_logic_vector(15 downto 0)
    );
  end component mul8;


begin

--process(a,b)
--	variable p: integer range 0 to 2**a'length - 1;
--begin
--        p := to_integer(unsigned(a)) * to_integer(unsigned(b));
--        prod <= std_logic_vector(to_unsigned(p,prod'length));
--end process;


  mul: mul8 port map(
    a    => a,
    b    => b,
    prod => prod
  );


end architecture behavior; -- idiv
