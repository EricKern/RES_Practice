
library IEEE;
use IEEE.std_logic_1164.all;

entity fadd is               -- full adder stage, interface
  port(a    : in  std_logic;
       b    : in  std_logic;
       cin  : in  std_logic;
       s    : out std_logic;
       cout : out std_logic);
end entity fadd;

architecture behavior of fadd is  -- full adder stage, body
begin  -- circuits of fadd
  s <= a xor b xor cin after 1 ns;
  cout <= (a and b) or (a and cin) or (b and cin) after 1 ns;
end architecture behavior; -- fadd
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
entity add8 is             -- simple 8 bit ripple carry adder
  port(a    : in  std_logic_vector(7 downto 0);
       b    : in  std_logic_vector(7 downto 0);
       cin  : in  std_logic; 
       sum  : out std_logic_vector(7 downto 0);
       cout : out std_logic);
end entity add8;

architecture behavior of add8 is
  signal c : std_logic_vector(0 to 6); -- internal carry signals
  component fadd   -- duplicates entity port
  port(a    : in  std_logic;
       b    : in  std_logic;
       cin  : in  std_logic;
       s    : out std_logic;
       cout : out std_logic);
  end component fadd ;
begin
  a0:            fadd port map(a(0), b(0), cin, sum(0), c(0));
  stage: for I in 1 to 6 generate
             as: fadd port map(a(I), b(I), c(I-1) , sum(I), c(I));
         end generate stage;
  a31:           fadd port map(a(7), b(7), c(6) , sum(7), cout);
end architecture behavior;  -- add8

-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity add8c is          -- one stage of carry save adder for multiplier
  port(
    b       : in  std_logic;                     -- a multiplier bit
    a       : in  std_logic_vector(7 downto 0);  -- multiplicand
    sum_in  : in  std_logic_vector(7 downto 0);  -- sums from previous stage
    cin     : in  std_logic_vector(7 downto 0);  -- carrys from previous stage
    sum_out : out std_logic_vector(7 downto 0);  -- sums to next stage
    cout    : out std_logic_vector(7 downto 0)); -- carrys to next stage
end add8c;

architecture behavior of add8c is
  constant zero : std_logic_vector(7 downto 0) := x"00";
  signal aa   : std_logic_vector(7 downto 0);
  component fadd
    port(a    : in  std_logic;
         b    : in  std_logic;
         cin  : in  std_logic;
         s    : out std_logic;
         cout : out std_logic);
  end component fadd;
begin
  aa <= a when b = '1' else zero after 1 ns;
  stage: for I in 0 to 7 generate
    sta: fadd port map(aa(I), sum_in(I), cin(I) , sum_out(I), cout(I));
  end generate stage;  
end architecture behavior; -- add8csa

-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity mul8 is  -- 8 x 8 = 16 bit unsigned product multiplier
  port(a    : in  std_logic_vector(7 downto 0);  -- multiplicand
       b    : in  std_logic_vector(7 downto 0);  -- multiplier
       prod : out std_logic_vector(15 downto 0)); -- product
end mul8;

architecture behavior of mul8 is
  constant zero : std_logic_vector(7 downto 0) := x"00";
  type arr8 is array(0 to 7) of std_logic_vector(7 downto 0);
  signal s    : arr8; -- partial sums
  signal c    : arr8; -- partial carries
  signal ss   : arr8; -- shifted sums

  component add8c is
    port(b       : in  std_logic;
         a       : in  std_logic_vector(7 downto 0);
         sum_in  : in  std_logic_vector(7 downto 0);
         cin     : in  std_logic_vector(7 downto 0);
         sum_out : out std_logic_vector(7 downto 0);
         cout    : out std_logic_vector(7 downto 0));
  end component add8c;
  component add8
    port(a    : in  std_logic_vector(7 downto 0);
         b    : in  std_logic_vector(7 downto 0);
         cin  : in  std_logic; 
         sum  : out std_logic_vector(7 downto 0);
         cout : out std_logic);
  end component add8;
begin
  st0: add8c port map(b(0), a, zero , zero, s(0), c(0));  -- CSA stage
  ss(0) <= '0' & s(0)(7 downto 1) after 1 ns;
  prod(0) <= s(0)(0) after 1 ns;

  stage: for I in 1 to 7 generate
    st: add8c port map(b(I), a, ss(I-1) , c(I-1), s(I), c(I));  -- CSA stage
    ss(I) <= '0' & s(I)(7 downto 1) after 1 ns;
    prod(I) <= s(I)(0) after 1 ns;
  end generate stage;
  
  add: add8 port map(ss(7), c(7), '0' , prod(15 downto 8), open);  -- adder
end architecture behavior; -- mul8
-------------------------------------------------------------------------
