-----------------------------------------------------------------------------------
--  68HC08 microcontroller implementation
--  Ulrich Riedel
--  v1.0  2005.11.24  first version
-----------------------------------------------------------------------------------
-- Update by Andreas Kugel, 2018 for FPGA implemenation
-- Tested on Lattix MXO, Xilinx Spartan3, Spartan6 and Zynq, Intel Cyclone10LP
-----------------------------------------------------------------------------------
-- divider.vhd  parallel division
-- based on non-restoring division, uncorrected remainder
-- Controlled add/subtract "cas" cell (NOT CSA)
-- "T" is sub_add signal in div_ser.vhdl
-- begin of 68HC08
LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;

ENTITY hc08_core IS
   PORT(
     clk     : in  std_logic;
     rst_n     : in  std_logic;
     irq     : in  std_logic;
     addr    : out std_logic_vector(15 downto 0);
     wr      : out std_logic;
     wt    : in std_logic := '0';
     datain  : in  std_logic_vector(7 downto 0);
     state   : out std_logic_vector(3 downto 0);
     dataout : out std_logic_vector(7 downto 0)
   );
END hc08_core;

ARCHITECTURE behavior OF hc08_core IS

  component imul
  port(
    a    : in  std_logic_vector(7 downto 0);
    b    : in  std_logic_vector(7 downto 0);
    prod : out std_logic_vector(15 downto 0)
    );
  end component imul;

--  component idiv
--  port (
--    dividend  : in  std_logic_vector(16 downto 0);
--    divisor   : in  std_logic_vector(8 downto 0);
--    quotient  : out std_logic_vector(8 downto 0);
--    remainder : out std_logic_vector(8 downto 0)
--  );
--  end component idiv;

component idiv_s
    generic (
        ubits: integer := 16; -- upper bits
        lbits: integer := 8; -- lower bits
        rbits: integer := 8 -- result bits
    );
    port (
        clk: in std_logic;
        rst: in std_logic;
        start: in std_logic;
        done: out std_logic;
        dividend: in std_logic_vector(ubits - 1 downto 0);
        divisor: in std_logic_vector(lbits - 1 downto 0);
        quotient: out std_logic_vector(rbits - 1 downto 0);
        remainder: out std_logic_vector(rbits - 1 downto 0);
        zero: out std_logic;
        err: out std_logic
    );
end component;

  -- std_logic_vector + int
  function "+" (a: std_logic_vector; b: integer) return std_logic_vector is
  begin
    --return std_logic_vector( unsigned(a) + to_unsigned(b,a'length) ) );
    return std_logic_vector( unsigned(a) + to_unsigned(b,a'length) );
  end function;

  function "-" (a: std_logic_vector; b: integer) return std_logic_vector is
  begin
    --return std_logic_vector( unsigned(a) + to_unsigned(b,a'length) ) );
    return std_logic_vector( unsigned(a) - to_unsigned(b,a'length) );
  end function;

  function "<" (a: std_logic_vector; b: integer) return boolean is
  begin
    --return std_logic_vector( unsigned(a) + to_unsigned(b,a'length) ) );
    return ( unsigned(a) < to_unsigned(b,a'length) );
  end function;

  function ">" (a: std_logic_vector; b: integer) return boolean is
  begin
    --return std_logic_vector( unsigned(a) + to_unsigned(b,a'length) ) );
    return ( unsigned(a) > to_unsigned(b,a'length) );
  end function;

  -- 2*std_logic_vector
  function "+" (a: std_logic_vector; b: std_logic_vector) return std_logic_vector is
  begin
    return std_logic_vector( unsigned(a) + unsigned(b));
  end function;

  function "-" (a: std_logic_vector; b: std_logic_vector) return std_logic_vector is
  begin
    return std_logic_vector( unsigned(a) - unsigned(b));
  end function;

  constant CPUread  : std_logic := '1';
  constant CPUwrite : std_logic := '0';
  constant addrPC : std_logic_vector(2 downto 0) := "000";
  constant addrSP : std_logic_vector(2 downto 0) := "001";
  constant addrHX : std_logic_vector(2 downto 0) := "010";
  constant addrTM : std_logic_vector(2 downto 0) := "011";
  constant addrX2 : std_logic_vector(2 downto 0) := "100";
  constant addrS2 : std_logic_vector(2 downto 0) := "101";
  constant addrX1 : std_logic_vector(2 downto 0) := "110";
  constant addrS1 : std_logic_vector(2 downto 0) := "111";
  constant outA    : std_logic_vector(3 downto 0) := "0000";
  constant outH    : std_logic_vector(3 downto 0) := "0001";
  constant outX    : std_logic_vector(3 downto 0) := "0010";
  constant outSPL  : std_logic_vector(3 downto 0) := "0011";
  constant outSPH  : std_logic_vector(3 downto 0) := "0100";
  constant outPCL  : std_logic_vector(3 downto 0) := "0101";
  constant outPCH  : std_logic_vector(3 downto 0) := "0110";
  constant outTL   : std_logic_vector(3 downto 0) := "0111";
  constant outTH   : std_logic_vector(3 downto 0) := "1000";
  constant outHelp : std_logic_vector(3 downto 0) := "1001";
  constant outCode : std_logic_vector(3 downto 0) := "1010";


  -- AKU
  --type    masker is array (0 to 7) of std_logic_vector(7 downto 0);
  --signal mask0  : masker;
  --signal mask1  : masker;

  -- masking functions
  -- mask0: one 0 bit
  function mask0(i:integer) return std_logic_vector is
	variable t: std_logic_vector(7 downto 0);
  begin
	for j in 0 to 7 loop
		t(j) := '1';
		if i = j then
			t(j) := '0';
		end if;
	end loop;
	return t;
  end function;

  -- mask1: one 1 bit
  function mask1(i:integer) return std_logic_vector is
	variable t: std_logic_vector(7 downto 0);
  begin
	for j in 0 to 7 loop
		t(j) := '0';
		if i = j then
			t(j) := '1';
		end if;
	end loop;
	return t;
  end function;
  --

  signal regA   : std_logic_vector(7 downto 0);
  signal regHX  : std_logic_vector(15 downto 0);
  signal regSP  : std_logic_vector(15 downto 0);
  signal regPC  : std_logic_vector(15 downto 0);
  signal flagV  : std_logic;
  signal flagH  : std_logic;
  signal flagI  : std_logic;
  signal flagN  : std_logic;
  signal flagZ  : std_logic;
  signal flagC  : std_logic;
  signal help   : std_logic_vector(7 downto 0);
  signal temp   : std_logic_vector(15 downto 0);
  signal mainFSM : std_logic_vector(3 downto 0);
  signal addrMux : std_logic_vector(2 downto 0);
  signal dataMux : std_logic_vector(3 downto 0);
  signal opcode  : std_logic_vector(7 downto 0);
  signal escape9E : std_logic;
  signal prod     : std_logic_vector(15 downto 0);
  signal dividend : std_logic_vector(16 downto 0);
  signal divisor  : std_logic_vector(8 downto 0);
  signal quotient : std_logic_vector(8 downto 0);
  signal remainder: std_logic_vector(8 downto 0);
  -- signal irq_d      : std_logic;
  signal irqRequest : std_logic;

  signal trace       : std_logic;
  signal trace_i     : std_logic;
  signal traceOpCode : std_logic_vector(7 downto 0);

  -- wait support
  signal run: std_logic := '1';
  signal wtCmd: std_logic := '0';
  signal divCmd: std_logic := '0';
  signal divStart: std_logic := '0';
  signal divDone: std_logic := '0';
  signal divErr: std_logic := '0';
  signal divZero: std_logic := '0';
  signal rst: std_logic;

begin

  mul: imul
  port map(
    a    => regA,
    b    => regHX(7 downto 0),
    prod => prod
  );

    dividend <= "0" & regHX(15 downto 8) & regA;
    divisor  <= "0" & regHX(7 downto 0);
    quotient(8) <= '0';
    remainder(8) <= '0';
--   div: idiv
--   port map(
--     dividend  => dividend,
--     divisor   => divisor,
--     quotient  => quotient,
--     remainder => remainder
--   );

    rst <= not rst_n;
    div_s: idiv_s
    port map (
        clk => clk,
        rst => rst,
        start => divStart,
        done => divDone,
        dividend => dividend(15 downto 0),
        divisor => divisor(7 downto 0),
        quotient => quotient(7 downto 0),
        remainder => remainder(7 downto 0),
        zero => divZero,
        err => divErr
    );


  addr <= regPC          when addrMux = addrPC else
          regSP          when addrMux = addrSP else
          regHX          when addrMux = addrHX else
          temp           when addrMux = addrTM else
          (regHX + temp) when addrMux = addrX2 else
          (regSP + temp) when addrMux = addrS2 else
          (regHX + (x"00" & temp(7 downto 0))) when addrMux = addrX1 else
          (regSP + (x"00" & temp(7 downto 0)));
  dataout <= regA               when dataMux = outA else
             regHX(15 downto 8) when dataMux = outH else
             regHX( 7 downto 0) when dataMux = outX else
             regSP( 7 downto 0) when dataMux = outSPL else
             regSP(15 downto 8) when dataMux = outSPH else
             regPC( 7 downto 0) when dataMux = outPCL else
             regPC(15 downto 8) when dataMux = outPCH else
             temp ( 7 downto 0) when dataMux = outTL  else
             temp (15 downto 8) when dataMux = outTH  else
             help               when dataMux = outHelp else
             traceOpCode;

  -- AKU wait logic, to be tested but looks OK so far
  process(rst_n, irq, wt, wtCmd, divCmd, divDone)
  begin
    run <= '1';
    if rst_n = '1' then
        if wt = '1' then
            run <= '0';
        elsif irq = '0' and wtCmd = '1' then
            run <= '0';
        elsif divDone = '0' and divCmd = '1' then
            run <= '0';
        end if;
    end if;
  end process;

  ---
  state <= mainFSM;
  process(clk, rst_n)
    variable tres : std_logic_vector(7 downto 0);
    variable lres : std_logic_vector(15 downto 0);
  begin
    if rst_n = '0' then
      trace    <= '0';
      trace_i  <= '0';
      escape9E <= '0';
      wr <= CPUread;
      flagV <= '0';
      flagH <= '0';
      flagI <= '1'; -- irq disabled
      flagN <= '0';
      flagZ <= '0';
      flagC <= '0';
      regA    <= x"00";
      regHX   <= x"0000";  -- clear H register for 6805 compatible mode
      regSP   <= x"00FF";
      regPC   <= x"FFFE";
      temp    <= x"FFFE";
      help    <= x"00";
      dataMux <= outA;
      addrMux <= addrTM;
      -- irq_d   <= '1';
      irqRequest <= '0';
      mainFSM <= "0000";
      wtCmd <= '0';
      divCmd <= '0';
      divStart <= '0';
      -- AKU wait inserted
    elsif rising_edge(clk) then
        if run = '1' then
            -- irq_d <= irq;
            -- AKU if (irq = '0') and (irq_d = '1') and (flagI = '0') then -- irq falling edge ?
            if (irq = '1') and (flagI = '0') then -- irq level sensitive
            irqRequest <= '1';
            end if;
            wtCmd <= '0';
            divCmd <= '0';
            divStart <= '0';
            case mainFSM is
            when "0000" => --############# reset fetch PCH from FFFE
                regPC(15 downto 8) <= datain;
                temp    <= temp + 1;
                mainFSM <= "0001";
            when "0001" => --############# reset fetch PCL from FFFF
                regPC(7 downto 0)  <= datain;
                addrMux <= addrPC;
                mainFSM <= "0010";

            when "0010" => --##################### fetch opcode, instruction cycle 1
                trace <= trace_i;
                if trace = '1' then
                opcode      <= x"83"; -- special SWI trace
                traceOpCode <= datain;
                addrMux     <= addrSP;
                mainFSM     <= "0011";
                elsif irqRequest = '1' then
                opcode      <= x"83"; -- special SWI interrupt
                addrMux     <= addrSP;
                mainFSM     <= "0011";
                else
                opcode <= datain;
                case datain is
                    when x"82" =>  -- RTT return trace special propietary instruction
                    trace_i <= '1';  -- arm trace for next instruction
                    regSP   <= regSP + 1;
                    addrMux <= addrSP;
                    mainFSM <= "0011";
                    when x"9E" =>  -- escape byte for SP address
                    escape9E <= '1';
                    regPC    <= regPC + 1;
                    mainFSM  <= "0010";
                    when x"00" | x"02" | x"04" | x"06" | x"08" | x"0A" | x"0C" | x"0E" |   -- BRSET n,opr8a,rel
                        x"01" | x"03" | x"05" | x"07" | x"09" | x"0B" | x"0D" | x"0F" |   -- BRCLR n,opr8a,rel
                        x"10" | x"12" | x"14" | x"16" | x"18" | x"1A" | x"1C" | x"1E" |   -- BSET n,opr8a
                        x"11" | x"13" | x"15" | x"17" | x"19" | x"1B" | x"1D" | x"1F" |   -- BCLR n,opr8a
                        x"30" | x"31" | x"33" | x"34" |   -- NEG opr8a, CBEQ opr8a,rel, COM opr8a, LSR opr8a
                        x"35" | x"36" | x"37" | x"38" |   -- STHX opr8a, ROR opr8a, ASR opr8a, LSL opr8a
                        x"39" | x"3A" | x"3B" | x"3C" |   -- ROL opr8a, DEC opr8a, DBNZ opr8a,rel, INC opr8a
                        x"3D" | x"3F" | x"4E" | x"55" |  -- TST opr8a, CLR opr8a, MOV opr8a,opr8a, LDHX opr
                        x"5E" | x"6E" | x"75" |  -- MOV opr8a,X+, MOV #opr8i,opr8a, CPHX opr
                        x"B0" | x"B1" | x"B2" | x"B3" |  -- SUB opr8a, CMP opr8a, SBC opr8a, CPX opr8a
                        x"B4" | x"B5" | x"B6" | x"B7" |  -- AND opr8a, BIT opr8a, LDA opr8a, STA opr8a
                        x"B8" | x"B9" | x"BA" | x"BB" |  -- EOR opr8a, ADC opr8a, ORA opr8a, ADD opr8a
                        x"BC" | x"BE" | x"BF" =>         -- JMP opr8a, LDX opr8a, STX opr8a
                    temp    <= x"0000";
                    regPC   <= regPC + 1;
                    mainFSM <= "0011";
                    when x"20" | x"21" | x"22" | x"23" | x"24" | x"25" | x"26" | x"27" |
                        x"28" | x"29" | x"2A" | x"2B" | x"2C" | x"2D" | x"2E" | x"2F" |   -- branches
                        x"41" | x"45" | x"51" | x"65" |  -- CBEQA #opr8i,rel, LDHX #opr, CBEQX #opr8i,rel, CPHX #opr
                        x"90" | x"91" | x"92" | x"93" |  -- branches
                        x"C0" | x"C1" | x"C2" | x"C3" |  -- SUB opr16a, CMP opr16a, SBC opr16a, CPX opr16a
                        x"C4" | x"C5" | x"C6" | x"C7" |  -- AND opr16a, BIT opr16a, LDA opr16a, STA opr16a
                        x"C8" | x"C9" | x"CA" | x"CB" |  -- EOR opr16a, ADC opr16a, ORA opr16a, ADD opr16a
                        x"CC" | x"CE" | x"CF" |          -- JMP opr16a, LDX opr16a, STX opr16a
                        x"D0" | x"D1" | x"D2" | x"D3" |  -- SUB oprx16,X, CMP oprx16,X, SBC oprx16,X, CPX oprx16,X
                        x"D4" | x"D5" | x"D6" | x"D7" |  -- AND oprx16,X, BIT oprx16,X, LDA oprx16,X, STA oprx16,X
                        x"D8" | x"D9" | x"DA" | x"DB" |  -- EOR oprx16,X, ADC oprx16,X, ORA oprx16,X, ADD oprx16,X
                        x"DC" | x"DE" | x"DF" =>         -- JMP oprx16,X, LDX oprx16,X, STX oprx16,X
                    regPC <= regPC + 1;
                    mainFSM <= "0011";
                    when x"70" | x"71" | x"73" | x"74" | x"76" | x"77" |  -- NEG ,X, CBEQ ,X+,rel, COM ,X, LSR ,X, ROR ,X, ASR ,X
                        x"78" | x"79" | x"7A" | x"7B" | x"7C" | x"7D" |  -- LSL ,X, ROL ,X, DEC ,X, DBNZ ,X,rel, INC ,X, TXT ,X
                        x"7E" =>  -- MOV ,X+,opr8a
                    addrMux <= addrHX;
                    regPC   <= regPC + 1;
                    mainFSM <= "0100";
                    when x"A0" | x"A1" | x"A2" | x"A3" |  -- SUB #opr8i, CMP #opr8i, SBC #opr8i, CPX #opr8i
                        x"A4" | x"A5" | x"A6" | x"A7" |  -- AND #opr8i, BIT #opr8i, LDA #opr8i, AIS
                        x"A8" | x"A9" | x"AA" | x"AB" |  -- EOR #opr8i, ADC #opr8i, ORA #opr8i, ADD #opr8i
                        x"AE" | x"AF" =>  -- LDX #opr8i, AIX
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                    when x"E0" | x"E1" | x"E2" | x"E3" |  -- SUB oprx8,X, CMP oprx8,X, SBC oprx8,X, CPX oprx8,X
                        x"E4" | x"E5" | x"E6" | x"E7" |  -- AND oprx8,X, BIT oprx8,X, LDA oprx8,X, STA oprx8,X
                        x"E8" | x"E9" | x"EA" | x"EB" |  -- EOR oprx8,X, ADC oprx8,X, ORA oprx8,X, ADD oprx8,X
                        x"EC" | x"EE" | x"EF" =>         -- JMP oprx8,X, LDX oprx8,X, STX oprx8,X
                    regPC <= regPC + 1;
                    mainFSM <= "0100";
                    when x"F0" | x"F1" | x"F2" | x"F3" |  -- SUB ,X, CMP ,X, SBC ,X, CPX ,X
                        x"F4" | x"F5" | x"F6" |          -- AND ,X, BIT ,X, LDA ,X
                        x"F8" | x"F9" | x"FA" | x"FB" |  -- EOR ,X, ADC ,X, ORA ,X, ADD ,X
                        x"FE" =>                         -- LDX ,X
                    addrMux <= addrHX;
                    regPC   <= regPC + 1;
                    mainFSM <= "0101";
                    when x"FC" =>  -- JMP ,X
                    regPC <= regHX;
                    mainFSM <= "0010";
                    when x"F7" =>  -- STA ,X
                    wr <= CPUwrite;
                    flagV <= '0';
                    flagN <= regA(7);
                    if regA = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    dataMux <= outA;
                    addrMux <= addrHX;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                    when x"FF" =>  -- STX ,X
                    wr <= CPUwrite;
                    flagV <= '0';
                    flagN <= regHX(7);
                    if regHX(7 downto 0) = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    dataMux <= outX;
                    addrMux <= addrHX;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                    when x"40" =>  -- NEGA
                    regA    <= x"00" - regA;
                    tres    := x"00" - regA;
                    flagV   <= tres(7) and regA(7);
                    flagN   <= tres(7);
                    if tres = x"00" then
                        flagZ <= '1';
                        flagC <= '0';
                    else
                        flagC <= '1';
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"42" =>  -- MUL
                    flagH <= '0';
                    flagC <= '0';
                    regA              <= prod(7 downto 0);
                    regHX(7 downto 0) <= prod(15 downto 8);
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"43" =>  -- COMA
                    regA    <= regA xor x"FF";
                    tres    := regA xor x"FF";
                    flagV   <= '0';
                    flagC   <= '1';
                    flagN   <= tres(7);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"44" =>  -- LSRA
                    regA    <= "0" & regA(7 downto 1);
                    tres    := "0" & regA(7 downto 1);
                    flagV   <= regA(0);
                    flagN   <= '0';
                    flagC   <= regA(0);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"46" =>  -- RORA
                    regA    <= flagC & regA(7 downto 1);
                    tres    := flagC & regA(7 downto 1);
                    flagN   <= flagC;
                    flagC   <= regA(0);
                    flagV   <= flagC xor regA(0);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"47" =>  -- ASRA
                    regA    <= regA(7) & regA(7 downto 1);
                    tres    := regA(7) & regA(7 downto 1);
                    flagN   <= regA(7);
                    flagC   <= regA(0);
                    flagV   <= regA(7) xor regA(0);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"48" =>  -- LSLA
                    regA    <= regA(6 downto 0) & "0";
                    tres    := regA(6 downto 0) & "0";
                    flagN   <= regA(6);
                    flagC   <= regA(7);
                    flagV   <= regA(7) xor regA(6);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"49" =>  -- ROLA
                    regA    <= regA(6 downto 0) & flagC;
                    tres    := regA(6 downto 0) & flagC;
                    flagN   <= regA(6);
                    flagC   <= regA(7);
                    flagV   <= regA(7) xor regA(6);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"4A" =>  -- DECA
                    regA    <= regA - 1;
                    tres    := regA - 1;
                    flagN   <= tres(7);
                    if regA = x"80" then
                        flagV <= '1';
                    else
                        flagV <= '0';
                    end if;
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"4B" =>  -- DBNZA rel
                    regA <= regA - 1;
                    tres := regA - 1;
                    if tres = x"00" then
                        regPC <= regPC + 2;
                        mainFSM <= "0010";
                    else
                        regPC <= regPC + 1;
                        mainFSM <= "0011";
                    end if;
                    when x"4C" =>  -- INCA
                    regA    <= regA + 1;
                    tres    := regA + 1;
                    flagN   <= tres(7);
                    if regA = x"7F" then
                        flagV <= '1';
                    else
                        flagV <= '0';
                    end if;
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"4D" =>  -- TSTA
                    flagN   <= regA(7);
                    flagV   <= '0';
                    if regA = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"4F" =>  -- CLRA
                    regA <= x"00";
                    flagV <= '0';
                    flagN <= '0';
                    flagZ <= '1';
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"50" =>  -- NEGX
                    regHX(7 downto 0) <= x"00" - regHX(7 downto 0);
                    tres    := x"00" - regHX(7 downto 0);
                    flagV   <= tres(7) and regHX(7);
                    flagN   <= tres(7);
                    if tres = x"00" then
                        flagZ <= '1';
                        flagC <= '0';
                    else
                        flagC <= '1';
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"52" =>  -- DIV
                    divStart <= '1';
                    divCmd <= '1';
                    regPC <= regPC + 1;
                    mainFSM <= "0011";
                    when x"53" =>  -- COMX
                    regHX(7 downto 0) <= regHX(7 downto 0) xor x"FF";
                    tres    := regHX(7 downto 0) xor x"FF";
                    flagV   <= '0';
                    flagC   <= '1';
                    flagN   <= tres(7);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"54" =>  -- LSRX
                    regHX(7 downto 0) <= "0" & regHX(7 downto 0)(7 downto 1);
                    tres    := "0" & regHX(7 downto 0)(7 downto 1);
                    flagV   <= regHX(0);
                    flagN   <= '0';
                    flagC   <= regHX(0);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"56" =>  -- RORX
                    regHX(7 downto 0) <= flagC & regHX(7 downto 1);
                    tres    := flagC & regHX(7 downto 1);
                    flagN   <= flagC;
                    flagC   <= regHX(0);
                    flagV   <= flagC xor regHX(0);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"57" =>  -- ASRX
                    regHX(7 downto 0) <= regHX(7) & regHX(7 downto 1);
                    tres    := regHX(7) & regHX(7 downto 1);
                    flagN   <= regHX(7);
                    flagC   <= regHX(0);
                    flagV   <= regHX(7) xor regHX(0);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"58" =>  -- LSLX
                    regHX(7 downto 0) <= regHX(6 downto 0) & "0";
                    tres    := regHX(6 downto 0) & "0";
                    flagN   <= regHX(6);
                    flagC   <= regHX(7);
                    flagV   <= regHX(7) xor regHX(6);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"59" =>  -- ROLX
                    regHX(7 downto 0) <= regHX(6 downto 0) & flagC;
                    tres    := regHX(6 downto 0) & flagC;
                    flagN   <= regHX(6);
                    flagC   <= regHX(7);
                    flagV   <= regHX(7) xor regHX(6);
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"5A" =>  -- DECX
                    regHX(7 downto 0) <= regHX(7 downto 0) - 1;
                    tres    := regHX(7 downto 0) - 1;
                    flagN   <= tres(7);
                    if regHX(7 downto 0) = x"80" then
                        flagV <= '1';
                    else
                        flagV <= '0';
                    end if;
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"5B" =>  -- DBNZX rel
                    regHX(7 downto 0) <= regHX(7 downto 0) - 1;
                    tres := regHX(7 downto 0) - 1;
                    if tres = x"00" then
                        regPC <= regPC + 2;
                        mainFSM <= "0010";
                    else
                        regPC <= regPC + 1;
                        mainFSM <= "0011";
                    end if;
                    when x"5C" =>  -- INCX
                    regHX(7 downto 0) <= regHX(7 downto 0) + 1;
                    tres    := regHX(7 downto 0) + 1;
                    flagN   <= tres(7);
                    if regHX(7 downto 0) = x"7F" then
                        flagV <= '1';
                    else
                        flagV <= '0';
                    end if;
                    if tres = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"5D" =>  -- TSTX
                    flagN   <= regHX(7);
                    flagV   <= '0';
                    if regHX(7 downto 0) = x"00" then
                        flagZ <= '1';
                    else
                        flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"5F" =>  -- CLRX
                    regHX(7 downto 0) <= x"00";
                    flagV <= '0';
                    flagN <= '0';
                    flagZ <= '1';
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                    when x"60" | x"61" | x"63" | x"64" | x"66" | -- NEG oprx8,X, CBEQ oprx8,X+,rel, COM oprx8,X, LSR oprx8,X, ROR oprx8,X
                        x"67" | x"68" | x"69" | x"6A" | x"6B" |  -- ASR oprx8,X, LSL oprx8,X, ROL oprx8,X, DEC oprx8,X, DBNZ oprx8,X,rel
                        x"6C" | x"6D" | x"6F" =>  -- INC oprx8,X, TST oprx8,X, CLR oprx8,X
                    if escape9E = '1' then
                        if datain /= x"61" then
                        escape9E <= '0';
                        end if;
                        temp <= regSP;
                    else
                        temp <= regHX;
                    end if;
                    regPC   <= regPC + 1;
                    mainFSM <= "0011";
                    when x"62" =>  -- NSA
                    escape9E <= '0';
                    regA <= regA(3 downto 0) & regA(7 downto 4);
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"72" =>  -- DAA
                    if flagC = '0' then
                        if flagH = '0' then
                        if (regA(7 downto 4) < 10) and (regA(3 downto 0) < 10) then
                            if regA = x"00" then
                            flagZ <= '1';
                            else
                            flagZ <= '0';
                            end if;
                            flagN <= regA(7);
                        elsif (regA(7 downto 4) < 9) and (regA(3 downto 0) > 9) then
                            regA <= regA + x"06";
                            tres := regA + x"06";
                            flagN <= tres(7);
                            if tres = x"00" then
                            flagZ <= '1';
                            else
                            flagZ <= '0';
                            end if;
                        elsif (regA(7 downto 4) > 9) and (regA(3 downto 0) < 10) then
                            regA <= regA + x"60";
                            tres := regA + x"60";
                            flagC <= '1';
                            flagN <= tres(7);
                            if tres = x"00" then
                            flagZ <= '1';
                            else
                            flagZ <= '0';
                            end if;
                        elsif (regA(7 downto 4) > 8) and (regA(3 downto 0) > 9) then
                            regA <= regA + x"66";
                            tres := regA + x"66";
                            flagC <= '1';
                            flagN <= tres(7);
                            if tres = x"00" then
                            flagZ <= '1';
                            else
                            flagZ <= '0';
                            end if;
                        end if;
                        else
                        if (regA(7 downto 4) < 10) and (regA(3 downto 0) < 4) then
                            regA <= regA + x"06";
                            tres := regA + x"06";
                            flagN <= tres(7);
                            if tres = x"00" then
                            flagZ <= '1';
                            else
                            flagZ <= '0';
                            end if;
                        elsif (regA(7 downto 4) > 9) and (regA(3 downto 0) < 4) then
                            regA <= regA + x"66";
                            tres := regA + x"66";
                            flagC <= '1';
                            flagN <= tres(7);
                            if tres = x"00" then
                            flagZ <= '1';
                            else
                            flagZ <= '0';
                            end if;
                        end if;
                        end if;
                    else
                        if flagH = '0' then
                        if (regA(7 downto 3) < 3) and (regA(3 downto 0) < 10) then
                            regA <= regA + x"60";
                            tres := regA + x"60";
                            flagC <= '1';
                            flagN <= tres(7);
                            if tres = x"00" then
                            flagZ <= '1';
                            else
                            flagZ <= '0';
                            end if;
                        elsif (regA(7 downto 3) < 3) and (regA(3 downto 0) > 9) then
                            regA <= regA + x"66";
                            tres := regA + x"66";
                            flagC <= '1';
                            flagN <= tres(7);
                            if tres = x"00" then
                            flagZ <= '1';
                            else
                            flagZ <= '0';
                            end if;
                        end if;
                        else
                        if (regA(7 downto 3) < 4) and (regA(3 downto 0) < 4) then
                            regA <= regA + x"66";
                            tres := regA + x"66";
                            flagC <= '1';
                            flagN <= tres(7);
                            if tres = x"00" then
                            flagZ <= '1';
                            else
                            flagZ <= '0';
                            end if;
                        end if;
                        end if;
                    end if;
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"7F" =>  -- CLR ,X
                    flagV <= '0';
                    flagN <= '0';
                    flagZ <= '1';
                    addrMux <= addrHX;
                    dataMux <= outHelp;
                    wr <= CPUwrite;
                    help <= x"00";
                    regPC <= regPC + 1;
                    mainFSM <= "0011";
                    when x"80" | x"81" =>  -- RTI, RTS
                    regSP   <= regSP + 1;
                    addrMux <= addrSP;
                    mainFSM <= "0011";
                    when x"83" =>  -- SWI
                    regPC   <= regPC + 1;
                    addrMux <= addrSP;
                    mainFSM <= "0011";
                    when x"84" =>  -- TAP
                    flagN <= regA(7);
                    flagH <= regA(4);
                    flagI <= regA(3);
                    flagN <= regA(2);
                    flagZ <= regA(1);
                    flagC <= regA(0);
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"85" =>  -- TPA
                    regA(7) <= flagN;
                    regA(6) <= '1';
                    regA(5) <= '1';
                    regA(4) <= flagH;
                    regA(3) <= flagI;
                    regA(2) <= flagN;
                    regA(1) <= flagZ;
                    regA(0) <= flagC;
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"86" | x"88" | x"8A" =>  -- PULA, PULX, PULH
                    addrMux <= addrSP;
                    regSP   <= regSP + 1;
                    regPC   <= regPC + 1;
                    mainFSM <= "0011";
                    when x"87" =>  -- PSHA
                    wr <= CPUwrite;
                    dataMux <= outA;
                    addrMux <= addrSP;
                    regPC   <= regPC + 1;
                    mainFSM <= "0011";
                    when x"89" =>  -- PSHX
                    wr <= CPUwrite;
                    dataMux <= outX;
                    addrMux <= addrSP;
                    regPC   <= regPC + 1;
                    mainFSM <= "0011";
                    when x"8B" =>  -- PSHH
                    wr <= CPUwrite;
                    dataMux <= outH;
                    addrMux <= addrSP;
                    regPC   <= regPC + 1;
                    mainFSM <= "0011";
                    when x"8C" =>  -- CLRH
                    regHX(15 downto 8) <= x"00";
                    flagV <= '0';
                    flagN <= '0';
                    flagZ <= '1';
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"8E" =>  -- STOP currently unsupported
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"8F" =>  -- WAIT currently unsupported
                    -- AKU: test wait command
                    wtCmd <= '1';
                    flagI <= '0';
                    -- end test ---
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"94" =>  -- TXS
                    regSP <= regHX - 1;
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"95" =>  -- TSX
                    regHX <= regSP + 1;
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"97" =>  -- TAX
                    regHX(7 downto 0) <= regA;
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"98" | x"99" =>  -- CLC, SEC
                    flagC <= datain(0);
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"9A" | x"9B" =>  -- CLI, SEI  ATTENTION!!!
                    flagI <= datain(0);
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"9C" =>  -- RSP
                    regSP <= x"00FF";
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"9D" =>  -- NOP
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"9F" =>  -- TXA
                    regA <= regHX(7 downto 0);
                    regPC   <= regPC + 1;
                    mainFSM <= "0010";
                    when x"AD" | x"BD" | x"ED" =>  -- BSR rel, JSR opr8a, JSR oprx8,X
                    temp    <= regPC + 2;
                    regPC   <= regPC + 1;
                    mainFSM <= "0011";
                    when x"CD" | x"DD" =>  -- JSR opr16a, JSR oprx16,X
                    temp    <= regPC + 3;
                    regPC   <= regPC + 1;
                    mainFSM <= "0011";
                    when x"FD" =>  -- JSR ,X
                    temp    <= regPC + 1;
                    wr      <= CPUwrite;
                    addrMux <= addrSP;
                    dataMux <= outTL;
                    regPC   <= regPC + 1;
                    mainFSM <= "0100";


                    when others =>
                    mainFSM <= "0000";
                end case; -- datain
                end if; -- trace = '1'

            when "0011" => --##################### instruction cycle 2
                case opcode is
                when x"00" | x"02" | x"04" | x"06" | x"08" | x"0A" | x"0C" | x"0E" |   -- BRSET n,opr8a,rel
                    x"01" | x"03" | x"05" | x"07" | x"09" | x"0B" | x"0D" | x"0F" |   -- BRCLR n,opr8a,rel
                    x"10" | x"12" | x"14" | x"16" | x"18" | x"1A" | x"1C" | x"1E" |   -- BSET n,opr8a
                    x"11" | x"13" | x"15" | x"17" | x"19" | x"1B" | x"1D" | x"1F" |   -- BCLR n,opr8a
                    x"30" | x"31" | x"33" | x"34" | x"36" |          -- NEG opr8a, CBEQ opr8a,rel, COM opr8a, LSR opr8a, ROR opr8a
                    x"37" | x"38" | x"39" | x"3A" | x"3B" | x"3C" |  -- ASR opr8a, LSL opr8a, ROL opr8a, DEC opr8a, DBNZ opr8a,rel, INC opr8a
                    x"3D" | x"4E" | x"55" | x"5E" | x"75" =>         -- TST opr8a, MOV opr8a,opr8a, LDHX opr, MOV opr8a,X+, CPHX opr
                    temp(7 downto 0) <= datain;
                    addrMux <= addrTM;
                    regPC <= regPC + 1;
                    mainFSM <= "0100";
                when x"C0" | x"C1" | x"C2" | x"C3" |  -- SUB opr16a, CMP opr16a, SBC opr16a, CPX opr16a
                    x"C4" | x"C5" | x"C6" | x"C7" |  -- AND opr16a, BIT opr16a, LDA opr16a, STA opr16a
                    x"C8" | x"C9" | x"CA" | x"CB" |  -- EOR opr16a, ADC opr16a, ORA opr16a, ADD opr16a
                    x"CC" | x"CE" | x"CF" |          -- JMP opr16a, LDX opr16a, STX opr16a
                    x"D0" | x"D1" | x"D2" | x"D3" |  -- SUB oprx16,X, CMP oprx16,X, SBC oprx16,X, CPX oprx16,X
                    x"D4" | x"D5" | x"D6" | x"D7" |  -- AND oprx16,X, BIT oprx16,X, LDA oprx16,X, STA oprx16,X
                    x"D8" | x"D9" | x"DA" | x"DB" |  -- EOR oprx16,X, ADC oprx16,X, ORA oprx16,X, ADD oprx16,X
                    x"DC" | x"DE" | x"DF" =>         -- JMP oprx16,X, LDX oprx16,X, STX oprx16,X
                    temp(15 downto 8) <= datain;
                    regPC <= regPC + 1;
                    mainFSM <= "0100";
                when x"52" =>  -- DIV
                    -- AKU div command
                    divStart <= '0';
                    divCmd <= '0';
                    -- ------------
                    flagZ <= divZero;
                    flagC <= divErr;
                    regA <= quotient(7 downto 0);
                    regHX(15 downto 8) <= remainder(7 downto 0);
--                     if quotient(7 downto 0) = x"00" then
--                     flagZ <= '1';
--                     else
--                     flagZ <= '0';
--                     end if;
--                     if regHX(7 downto 0) = x"00" then -- divide by zero
--                         flagC <= '1';
--                     else
--                         if regHX(15 downto 8) < regHX(7 downto 0) then
--                             flagC <= '0';
--                             regA  <= quotient(7 downto 0);
--                             if remainder(8) = '1' then
--                             lres  := ("0000000" & remainder) + (x"00" & regHX(7 downto 0));
--                             else
--                             lres  :=  "0000000" & remainder;
--                             end if;
--                             regHX(15 downto 8) <= lres(7 downto 0);
--                         else
--                             flagC <= '1';
--                         end if;
--                     end if;
                    ----------------------------
                    mainFsm <= "0010";
                when x"B7" =>  -- STA opr8a
                    wr <= CPUwrite;
                    dataMux <= outA;
                    temp(7 downto 0) <= datain;
                    addrMux <= addrTM;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                when x"BF" =>  -- STX opr8a
                    wr <= CPUwrite;
                    dataMux <= outX;
                    temp(7 downto 0) <= datain;
                    addrMux <= addrTM;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                when x"B0" | x"B1" | x"B2" | x"B3" |  -- SUB opr8a, CMP opr8a, SBC opr8a, CPX opr8a
                    x"B4" | x"B5" | x"B6" |          -- AND opr8a, BIT opr8a, LDA opr8a
                    x"B8" | x"B9" | x"BA" | x"BB" |  -- EOR opr8a, ADC opr8a, ORA opr8a, ADD opr8a
                    x"BE" =>                         -- LDX opr8a
                    temp(7 downto 0) <= datain;
                    addrMux <= addrTM;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";

                when x"20" | x"4B" | x"5B" =>  -- BRA, DBNZA rel, DBNZX rel
                    if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    mainFSM <= "0010";
                when x"21" =>  -- BRN
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                when x"22" | x"23" =>  -- BHI, BLS
                    if (flagC or flagZ) = opcode(0) then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"24" | x"25" =>  -- BCC, BCS
                    if (flagC = opcode(0)) then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"26" | x"27" =>  -- BNE, BEQ
                    if (flagZ = opcode(0)) then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"28" | x"29" =>  -- BHCC, BHCS
                    if (flagH = opcode(0)) then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"2A" | x"2B" =>  -- BPL, BMI
                    if (flagN = opcode(0)) then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"2C" | x"2D" =>  -- BMC, BMS
                    if (flagI = opcode(0)) then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"2E" | x"2F" =>  -- BIL, BIH
                    if (irq = opcode(0)) then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"35" =>  -- STHX opr8a
                    wr <= CPUwrite;
                    dataMux <= outH;
                    temp(7 downto 0) <= datain;
                    addrMux <= addrTM;
                    regPC <= regPC + 1;
                    flagV <= '0';
                    flagN <= regHX(15);
                    if regHX = x"0000" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    mainFSM <= "0100";
                when x"3F" | x"6F" =>  -- CLR opr8a, CLR oprx8,X
                    wr <= CPUwrite;
                    case opcode is
                    when x"3F" =>
                        temp(7 downto 0) <= datain;
                    when x"6F" =>
                        temp    <= temp + (x"00" & datain);
                    when others =>
                        temp <= x"0000";
                    end case;
                    addrMux <= addrTM;
                    dataMux <= outHelp;
                    flagZ   <= '1';
                    flagV   <= '0';
                    flagN   <= '0';
                    help    <= x"00";
                    regPC   <= regPC + 1;
                    mainFSM <= "0100";
                when x"41" =>  -- CBEQA #opr8i,rel
                    if datain = regA then
                    regPC <= regPC + 1;
                    mainFSM <= "0100";
                    else
                    regPC <= regPC + 2;
                    mainFSM <= "0010";
                    end if;
                when x"45" =>  -- LDHX #opr
                    regHX(15 downto 8) <= datain;
                    flagN   <= datain(7);
                    flagV   <= '0';
                    regPC   <= regPC + 1;
                    mainFSM <= "0100";
                when x"51" =>  -- CBEQA #opr8i,rel
                    if datain = regHX(7 downto 0) then
                    regPC <= regPC + 1;
                    mainFSM <= "0100";
                    else
                    regPC <= regPC + 2;
                    mainFSM <= "0010";
                    end if;
                when x"60" | x"61" | x"63" | x"64" | x"66" |  -- NEG oprx8,X, CBEQ oprx8,X+,rel, COM oprx8,X, LSR oprx8,X, ROR oprx8,X
                    x"67" | x"68" | x"69" | x"6A" | x"6B" |  -- ASR oprx8,X, LSL oprx8,X, ROL oprx8,X, DEC oprx8,X, DBNZ oprx8,X,rel
                    x"6C" | x"6D" =>  -- INC oprx8,X, TST oprx8,X
                    temp    <= temp + (x"00" & datain);
                    regPC   <= regPC + 1;
                    addrMux <= addrTM;
                    mainFSM <= "0100";
                when x"65" | x"6E" =>  -- CPHX #opr, MOV #opr8i,opr8a
                    escape9E <= '0';
                    help    <= datain;
                    regPC   <= regPC + 1;
                    mainFSM <= "0100";
                when x"7F" =>  -- CLR ,X
                    wr <= CPUread;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"80" | x"82" =>  -- RTI, RTT
                    flagV <= datain(7);
                    flagH <= datain(4);
                    flagI <= datain(3);  ------- PLEASE RESTORE AT LATER TIME
                    flagN <= datain(2);
                    flagZ <= datain(1);
                    flagC <= datain(0);
                    regSP <= regSP + 1;
                    mainFSM <= "0100";
                when x"81" =>  -- RTS
                    regPC(15 downto 8) <= datain;
                    regSP <= regSP + 1;
                    mainFSM <= "0100";
                when x"83" =>  -- SWI
                    wr <= CPUwrite;
                    dataMux <= outPCL;
                    mainFSM <= "0100";
                when x"86" =>  -- PULA
                    regA <= datain;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"87" | x"89" | x"8B" =>  -- PSHA, PSHX, PSHH
                    wr <= CPUread;
                    regSP <= regSP - 1;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"88" =>  -- PULX
                    regHX(7 downto 0) <= datain;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"8A" =>  -- PULH
                    regHX(15 downto 8) <= datain;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"90" | x"91" =>  -- BGE, BLT
                    if ((flagN xor flagV) = opcode(0)) then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"92" | x"93" =>  -- BGT, BLE
                    if ((flagZ or (flagN xor flagV)) = opcode(0)) then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"AD" | x"BD" | x"ED" =>  -- BSR rel, JSR opr8a, JSR oprx8,X
                    regPC <= regPC + 1;
                    wr   <= CPUwrite;
                    help <= datain;
                    addrMux <= addrSP;
                    dataMux <= outPCL;
                    mainFSM <= "0100";
                when x"BC" =>  -- JMP opr8a
                    regPC <= (x"00" & datain);
                    mainFSM <= "0010";
                when x"CD" | x"DD" =>  -- JSR opr16a, JSR oprx16,X
                    temp(15 downto 8) <= datain;
                    regPC <= regPC + 1;
                    mainFSM <= "0100";

                when others =>
                    mainFSM <= "0000";
                end case; -- opcode

            when "0100" => --##################### instruction cycle 3
                case opcode is
                when x"00" | x"02" | x"04" | x"06" | x"08" | x"0A" | x"0C" | x"0E" |   -- BRSET n,opr8a,rel
                    x"01" | x"03" | x"05" | x"07" | x"09" | x"0B" | x"0D" | x"0F" =>  -- BRCLR n,opr8a,rel
                    if (datain and mask1(to_integer(unsigned(opcode(3 downto 1))))) /= x"00" then
                    flagC <= '1';
                    else
                    flagC <= '0';
                    end if;
                    addrMux <= addrPC;
                    mainFSM <= "0101";
                when x"10" | x"12" | x"14" | x"16" | x"18" | x"1A" | x"1C" | x"1E" |   -- BSET n,opr8a
                    x"11" | x"13" | x"15" | x"17" | x"19" | x"1B" | x"1D" | x"1F" =>  -- BCLR n,opr8a
                    wr <= CPUwrite;
                    dataMux <= outHelp;
                    if opcode(0) = '0' then
                    help <= datain or  mask1(to_integer(unsigned(opcode(3 downto 1))));
                    else
                    help <= datain and mask0(to_integer(unsigned(opcode(3 downto 1))));
                    end if;
                    mainFSM <= "0101";
                when x"C0" | x"C1" | x"C2" | x"C3" |  -- SUB opr16a, CMP opr16a, SBC opr16a, CPX opr16a
                    x"C4" | x"C5" | x"C6" |          -- AND opr16a, BIT opr16a, LDA opr16a
                    x"C8" | x"C9" | x"CA" | x"CB" |  -- EOR opr16a, ADC opr16a, ORA opr16a, ADD opr16a
                    x"CE" |                          -- LDX opr16a
                    x"D0" | x"D1" | x"D2" | x"D3" |  -- SUB oprx16,X, CMP oprx16,X, SBC oprx16,X, CPX oprx16,X
                    x"D4" | x"D5" | x"D6" |          -- AND oprx16,X, BIT oprx16,X, LDA oprx16,X
                    x"D8" | x"D9" | x"DA" | x"DB" |  -- EOR oprx16,X, ADC oprx16,X, ORA oprx16,X, ADD oprx16,X
                    x"DE" |                          -- LDX oprx16,X
                    x"E0" | x"E1" | x"E2" | x"E3" |  -- SUB oprx8,X, CMP oprx8,X, SBC oprx8,X, CPX oprx8,X
                    x"E4" | x"E5" | x"E6" |          -- AND oprx8,X, BIT oprx8,X, LDA oprx8,X
                    x"E8" | x"E9" | x"EA" | x"EB" |  -- EOR oprx8,X, ADC oprx8,X, ORA oprx8,X, ADD oprx8,X
                    x"EE" =>                         -- LDX oprx8,X
                    temp(7 downto 0) <= datain;
                    case opcode(7 downto 4) is
                    when x"C" =>
                        addrMux <= addrTM;
                    when x"D" =>
                        if escape9E = '0' then
                        addrMux <= addrX2;
                        else
                        escape9E <= '0';
                        addrMux <= addrS2;
                        end if;
                    when x"E" =>
                        if escape9E = '0' then
                        addrMux <= addrX1;
                        else
                        escape9E <= '0';
                        addrMux <= addrS1;
                        end if;
                    when others =>
                        null;
                    end case;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                when x"CC" =>  -- JMP opr16a
                    regPC <= temp(15 downto 8) & datain;
                    mainFSM <= "0010";
                when x"DC" =>  -- JMP oprx16,X
                    regPC <= (temp(15 downto 8) & datain) + regHX;
                    mainFSM <= "0010";
                when x"EC" =>  -- JMP oprx8,X
                    regPC <= (x"00" & datain) + regHX;
                    mainFSM <= "0010";
                when x"C7" =>  -- STA opr16a
                    wr <= CPUwrite;
                    flagV <= '0';
                    flagN <= regA(7);
                    if regA = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    dataMux <= outA;
                    temp(7 downto 0) <= datain;
                    addrMux <= addrTM;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                when x"D7" =>  -- STA oprx16,X
                    wr <= CPUwrite;
                    flagV <= '0';
                    flagN <= regA(7);
                    if regA = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    dataMux <= outA;
                    temp(7 downto 0) <= datain;
                    if escape9E = '0' then
                    addrMux <= addrX2;
                    else
                    escape9E <= '0';
                    addrMux <= addrS2;
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                when x"E7" =>  -- STA oprx8,X
                    wr <= CPUwrite;
                    flagV <= '0';
                    flagN <= regA(7);
                    if regA = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    dataMux <= outA;
                    temp(7 downto 0) <= datain;
                    if escape9E = '0' then
                    addrMux <= addrX1;
                    else
                    escape9E <= '0';
                    addrMux <= addrS1;
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                when x"CF" =>  -- STX opr16a
                    wr <= CPUwrite;
                    flagV <= '0';
                    flagN <= regHX(7);
                    if regHX(7 downto 0) = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    dataMux <= outX;
                    temp(7 downto 0) <= datain;
                    addrMux <= addrTM;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                when x"DF" =>  -- STX oprx16,X
                    wr <= CPUwrite;
                    flagV <= '0';
                    flagN <= regHX(7);
                    if regHX(7 downto 0) = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    dataMux <= outX;
                    temp(7 downto 0) <= datain;
                    if escape9E = '0' then
                    addrMux <= addrX2;
                    else
                    escape9E <= '0';
                    addrMux <= addrS2;
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                when x"EF" =>  -- STX oprx8,X
                    wr <= CPUwrite;
                    flagV <= '0';
                    flagN <= regHX(7);
                    if regHX(7 downto 0) = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    dataMux <= outX;
                    temp(7 downto 0) <= datain;
                    if escape9E = '0' then
                    addrMux <= addrX1;
                    else
                    escape9E <= '0';
                    addrMux <= addrS1;
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0101";
                when x"30" | x"60" | x"70" =>  -- NEG opr8a, NEG oprx8,X, NEG ,X
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    help    <= x"00" - datain;
                    tres    := x"00" - datain;
                    flagV   <= tres(7) and datain(7);
                    flagN   <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    flagC <= '0';
                    else
                    flagC <= '1';
                    flagZ <= '0';
                    end if;
                    mainFSM <= "0101";
                when x"31" =>  -- CBEQ opr8a,rel
                    help    <= datain;
                    addrMux <= addrPC;
                    mainFSM <= "0101";
                when x"33" | x"63" | x"73" =>  -- COM opr8a, COM oprx8,X, COM ,X
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    help    <= datain xor x"FF";
                    tres    := datain xor x"FF";
                    flagV   <= '0';
                    flagC   <= '1';
                    flagN   <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    mainFSM <= "0101";
                when x"34" | x"64" | x"74" =>  -- LSR opr8a, LSR oprx8,X, LSR ,X
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    help    <= "0" & datain(7 downto 1);
                    tres    := "0" & datain(7 downto 1);
                    flagV   <= datain(0);
                    flagN   <= '0';
                    flagC   <= datain(0);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    mainFSM <= "0101";
                when x"35" =>  -- STHX opr8a
                    dataMux <= outX;
                    temp <= temp + 1;
                    mainFSM <= "0101";
                when x"36" | x"66" | x"76" =>  -- ROR opr8a, ROR oprx8,X, ROR ,X
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    help    <= flagC & datain(7 downto 1);
                    tres    := flagC & datain(7 downto 1);
                    flagN   <= flagC;
                    flagC   <= datain(0);
                    flagV   <= flagC xor datain(0);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    mainFSM <= "0101";
                when x"37" | x"67" | x"77" =>  -- ASR opr8a, ASR oprx8,X, ASR ,X
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    help    <= datain(7) & datain(7 downto 1);
                    tres    := datain(7) & datain(7 downto 1);
                    flagN   <= datain(7);
                    flagC   <= datain(0);
                    flagV   <= datain(7) xor datain(0);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    mainFSM <= "0101";
                when x"38" | x"68" | x"78" =>  -- LSL opr8a, LSL oprx8,X, LSL ,X
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    help    <= datain(6 downto 0) & "0";
                    tres    := datain(6 downto 0) & "0";
                    flagN   <= datain(6);
                    flagC   <= datain(7);
                    flagV   <= datain(7) xor datain(6);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    mainFSM <= "0101";
                when x"39" | x"69" | x"79" =>  -- ROL opr8a, ROL oprx8,X, ROL ,X
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    help    <= datain(6 downto 0) & flagC;
                    tres    := datain(6 downto 0) & flagC;
                    flagN   <= datain(6);
                    flagC   <= datain(7);
                    flagV   <= datain(7) xor datain(6);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    mainFSM <= "0101";
                when x"3A" | x"6A" | x"7A" =>  -- DEC opr8a, DEC oprx8,X, DEC ,X
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    help    <= datain - 1;
                    tres    := datain - 1;
                    flagN   <= tres(7);
                    if datain = x"80" then
                    flagV <= '1';
                    else
                    flagV <= '0';
                    end if;
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    mainFSM <= "0101";
                when x"3B" | x"6B" | x"7B" =>  -- DBNZ opr8a,rel, DBNZ oprx8,X,rel, DBNZ ,X,rel
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    help    <= datain - 1;
                    mainFSM <= "0101";
                when x"3C" | x"6C" | x"7C" =>  -- INC opr8a, INC oprx8,X, INC ,X
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    help    <= datain + 1;
                    tres    := datain + 1;
                    flagN   <= tres(7);
                    if datain = x"7F" then
                    flagV <= '1';
                    else
                    flagV <= '0';
                    end if;
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    mainFSM <= "0101";
                when x"3D" | x"6D" | x"7D" =>  -- TST opr8a, TST oprx8,X, TST ,X
                    flagV   <= '0';
                    flagN   <= datain(7);
                    if datain = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"3F" | x"6F" =>  -- CLR opr8a, CLR oprx8,X
                    wr <= CPUread;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"41" =>  -- CBEQA #opr8i,rel
                    if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    mainFSM <= "0010";
                when x"45" =>  -- LDHX #opr
                    regHX(7 downto 0) <= datain;
                    if regHX(15 downto 8) = x"00" and datain = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                when x"4E" =>  -- MOV opr8a,opr8a
                    help    <= datain;
                    flagV   <= '0';
                    flagN   <= datain(7);
                    if datain = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    addrMux <= addrPC;
                    mainFSM <= "0101";
                    --- AKU fixme
                when x"51" =>  -- CBEQX #opr8i,rel
                    if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    mainFSM <= "0010";
                    --- AKU
                when x"55" =>  -- LDHX opr
                    regHX(15 downto 8) <= datain;
                    temp <= temp + 1;
                    mainFSM <= "0101";
                when x"5E" =>  -- MOV opr8a,X+
                    help  <= datain;
                    flagV <= '0';
                    flagN <= datain(7);
                    if datain = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    dataMux <= outHelp;
                    addrMux <= addrHX;
                    wr      <= CPUwrite;
                    mainFSM <= "0101";
                when x"61" =>  -- CBEQ oprx8,X+,rel
                    if escape9E = '0' then
                    regHX   <= regHX + 1;
                    else
                    escape9E <= '0';
                    end if;
                    addrMux <= addrPC;
                    if datain = regA then
                    mainFSM <= "0101";
                    else
                    regPC <= regPC + 2;
                    mainFSM <= "0010";
                    end if;
                when x"65" =>  -- CPHX #opr
                    lres := regHX - (help & datain);
                    flagN <= lres(15);
                    if lres = x"0000" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= (regHX(15) and (not help(7)) and (not lres(15))) or
                            ((not regHX(15)) and help(7) and lres(15));
                    flagC <= ((not regHX(15)) and help(7)) or
                            (help(7) and lres(15)) or
                            (lres(15) and (not help(7)));
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                when x"6E" =>  -- MOV #opr8i,opr8a
                    temp(7 downto 0) <= datain;
                    flagV <= '0';
                    flagN <= help(7);
                    if help = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    wr      <= CPUwrite;
                    dataMux <= outHelp;
                    addrMux <= addrTM;
                    regPC   <= regPC + 1;
                    mainFSM <= "0101";
                when x"71" =>  -- CBEQ ,X+,rel
                    addrMux <= addrPC;
                    regHX <= regHX + 1;
                    if datain = regA then
                    mainFSM <= "0101";
                    else
                    regPC <= regPC + 2;
                    mainFSM <= "0010";
                    end if;
                when x"75" =>  -- CPHX opr
                    help <= datain;
                    temp <= temp + 1;
                    mainFSM <= "0101";
                when x"7E" =>  -- MOV ,X+,opr8a
                    help <= datain;
                    temp <= x"0000";
                    addrMux <= addrPC;
                    mainFSM <= "0101";
                when x"80" | x"82" =>  -- RTI, RTT
                    regA  <= datain;
                    regSP <= regSP + 1;
                    mainFSM <= "0101";
                when x"81" =>  -- RTS
                    regPC(7 downto 0) <= datain;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"83" =>  -- SWI
                    regSP <= regSP - 1;
                    dataMux <= outPCH;
                    mainFSM <= "0101";
                when x"AD" | x"BD" | x"ED" =>  -- BSR rel, JSR opr8a, JSR oprx8,X
                    regSP <= regSP - 1;
                    dataMux <= outPCH;
                    mainFSM <= "0101";
                when x"FD" =>  -- JSR ,X
                    regSP <= regSP - 1;
                    dataMux <= outTH;
                    mainFSM <= "0101";
                when x"CD" | x"DD" =>  -- JSR opr16a, JSR oprx16,X
                    wr   <= CPUwrite;
                    temp(7 downto 0) <= datain;
                    regPC   <= regPC + 1;
                    addrMux <= addrSP;
                    dataMux <= outPCL;
                    mainFSM <= "0101";

                when others =>
                    mainFSM <= "0000";
                end case; -- opcode

            when "0101" => --##################### instruction cycle 4
                case opcode is
                when x"00" | x"02" | x"04" | x"06" | x"08" | x"0A" | x"0C" | x"0E" |   -- BRSET n,opr8a,rel
                    x"01" | x"03" | x"05" | x"07" | x"09" | x"0B" | x"0D" | x"0F" =>  -- BRCLR n,opr8a,rel
                    if (opcode(0) xor flagC) = '1' then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"10" | x"12" | x"14" | x"16" | x"18" | x"1A" | x"1C" | x"1E" |   -- BSET n,opr8a
                    x"11" | x"13" | x"15" | x"17" | x"19" | x"1B" | x"1D" | x"1F" |   -- BCLR n,opr8a
                    x"30" | x"33" | x"34" | x"35" | x"36" |  -- NEG opr8a, COM opr8a, LSR opr8a, STHX opr8a, ROR opr8a
                    x"37" | x"38" | x"39" | x"3A" | x"3C" |  -- ASR opr8a, LSL opr8a, ROL opr8a, DEC opr8a, INC opr8a
                    x"60" | x"63" | x"64" | x"66" | x"67" |  -- NEG oprx8,X, COM oprx8,X, LSR oprx8,X, ROR oprx8,X, ASR oprx8,X
                    x"68" | x"69" | x"6A" | x"6C" | x"6E" |  -- LSL oprx8,X, ROL oprx8,X, DEC oprx8,X, INC oprx8,X, MOV #opr8i,opr8a
                    x"70" | x"73" | x"74" | x"76" | x"77" | x"78" | x"79" | -- NEG ,X, COM ,X, LSR ,X, ROR ,X, ASR ,X, LSL ,X, ROL ,X
                    x"7A" | x"7C" |   -- DEC ,X, INC ,X
                    x"B7" | x"BF" | x"C7" | x"CF" |  -- STA opr8a, STX opr8a, STA opr16a, STX opr16a
                    x"D7" | x"DF" | x"E7" | x"EF" |  -- STA oprx16,X, STX oprx16,X, STA oprx8,X, STX oprx8,X
                    x"F7" | x"FF" =>  -- STA ,X, STX ,X
                    wr      <= CPUread;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"31" =>  -- CBEQ opr8a,rel
                    if regA = help then
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    else
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"3B" | x"6B" | x"7B" =>  -- DBNZ opr8a,rel, DBNZ oprx8,X,rel, DBNZ ,X,rel
                    wr      <= CPUread;
                    addrMux <= addrPC;
                    mainFSM <= "0110";
                when x"4E" =>  -- MOV opr8a,opr8a
                    temp(7 downto 0) <= datain;
                    regPC <= regPC + 1;
                    wr <= CPUwrite;
                    addrMux <= addrTM;
                    dataMux <= outHelp;
                    mainFSM <= "0110";
                when x"55" =>  -- LDHX opr
                    regHX(7 downto 0) <= datain;
                    flagV <= '0';
                    flagN <= regHX(15);
                    if (datain = x"00") and (regHX(15 downto 8) = x"00") then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"5E" =>  -- MOV opr8a,X+
                    wr      <= CPUread;
                    addrMux <= addrPC;
                    regHX   <= regHX + 1;
                    mainFSM <= "0010";
                when x"61" | x"71" =>  -- CBEQ oprx8,X+,rel, CBEQ ,X+,rel
                    if datain(7) = '0' then
                    regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                    regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    mainFSM <= "0010";
                when x"75" =>  -- CPHX opr
                    lres := regHX - (help & datain);
                    flagN <= lres(15);
                    if lres = x"0000" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= (regHX(15) and (not help(7)) and (not lres(15))) or
                            ((not regHX(15)) and help(7) and lres(15));
                    flagC <= ((not regHX(15)) and help(7)) or
                            (help(7) and lres(15)) or
                            (lres(15) and (not help(7)));
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"7E" =>  -- MOV ,X+,opr8a
                    flagV <= '0';
                    flagN <= help(7);
                    if help = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    temp(7 downto 0) <= datain;
                    wr <= CPUwrite;
                    dataMux <= outHelp;
                    addrMux <= addrTM;
                    regPC   <= regPC + 1;
                    regHX   <= regHX + 1;
                    mainFSM <= "0110";
                when x"80" | x"82" =>  -- RTI, RTT
                    regHX(7 downto 0) <= datain;
                    regSP <= regSP + 1;
                    mainFSM <= "0110";
                when x"83" =>  -- SWI
                    regSP <= regSP - 1;
                    dataMux <= outX;
                    help(7) <= flagV;
                    help(6) <= '1';
                    help(5) <= '1';
                    help(4) <= flagH;
                    help(3) <= flagI;
                    help(2) <= flagN;
                    help(1) <= flagZ;
                    help(0) <= flagC;
                    mainFSM <= "0110";
                when x"A0" | x"B0" | x"C0" | x"D0" | x"E0" | x"F0" =>  -- SUB #opr8i, SUB opr8a, SUB opr16a, SUB oprx16,X, SUB oprx8,X, SUB ,X
                    addrMux <= addrPC;
                    regA <= regA - datain;
                    tres := regA - datain;
                    flagN <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= (regA(7) and (not datain(7)) and (not tres(7))) or
                            ((not regA(7)) and datain(7) and tres(7));
                    flagC <= ((not regA(7)) and datain(7)) or
                            (datain(7) and tres(7)) or
                            (tres(7) and (not regA(7)));
                    if opcode = x"A0" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"A1" | x"B1" | x"C1" | x"D1" | x"E1" | x"F1" =>  -- CMP #opr8i, CMP opr8a, CMP opr16a, CMP oprx16,X, CMP oprx8,X, CMP ,X
                    addrMux <= addrPC;
                    tres := regA - datain;
                    flagN <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= (regA(7) and (not datain(7)) and (not tres(7))) or
                            ((not regA(7)) and datain(7) and tres(7));
                    flagC <= ((not regA(7)) and datain(7)) or
                            (datain(7) and tres(7)) or
                            (tres(7) and (not regA(7)));
                    if opcode = x"A1" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"A2" | x"B2" | x"C2" | x"D2" | x"E2" | x"F2" =>  -- SBC #opr8i, SBC opr8a, SBC opr16a, SBC oprx16,X, SBC oprx8,X, SBC ,X
                    addrMux <= addrPC;
                    regA <= regA - datain - ("0000000" & flagC);
                    tres := regA - datain - ("0000000" & flagC);
                    flagN <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= (regA(7) and (not datain(7)) and (not tres(7))) or
                            ((not regA(7)) and datain(7) and tres(7));
                    flagC <= ((not regA(7)) and datain(7)) or
                            (datain(7) and tres(7)) or
                            (tres(7) and (not regA(7)));
                    if opcode = x"A2" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"A3" | x"B3" | x"C3" | x"D3" | x"E3" | x"F3" =>  -- CPX #opr8i, CPX opr8a, CPX opr16a, CPX oprx16,X, CPX oprx8,X, CPX ,X
                    addrMux <= addrPC;
                    tres := regHX(7 downto 0) - datain;
                    flagN <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= (regHX(7) and (not datain(7)) and (not tres(7))) or
                            ((not regHX(7)) and datain(7) and tres(7));
                    flagC <= ((not regHX(7)) and datain(7)) or
                            (datain(7) and tres(7)) or
                            (tres(7) and (not regHX(7)));
                    if opcode = x"A3" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"A4" | x"B4" | x"C4" | x"D4" | x"E4" | x"F4" =>  -- AND #opr8i, AND opr8a, AND opr16a, AND oprx16,X, AND oprx8,X, AND ,X
                    addrMux <= addrPC;
                    regA <= regA and datain;
                    tres := regA and datain;
                    flagN <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= '0';
                    if opcode = x"A4" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"A5" | x"B5" | x"C5" | x"D5" | x"E5" | x"F5" =>  -- BIT #opr8i, BIT opr8a, BIT opr16a, BIT oprx16,X, BIT oprx8,X, BIT ,X
                    addrMux <= addrPC;
                    tres := regA and datain;
                    flagN <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= '0';
                    if opcode = x"A5" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"A6" | x"B6" | x"C6" | x"D6" | x"E6" | x"F6" =>  -- LDA #opr8i, LDA opr8a, LDA opr16a, LDA oprx16,X, LDA oprx8,X, LDA ,X
                    addrMux <= addrPC;
                    regA <= datain;
                    flagN <= datain(7);
                    if datain = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= '0';
                    if opcode = x"A6" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"A7" =>  -- AIS
                    if datain(7) = '0' then
                    regSP <= regSP + (x"00" & datain);
                    else
                    regSP <= regSP + (x"FF" & datain);
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                when x"A8" | x"B8" | x"C8" | x"D8" | x"E8" | x"F8" =>  -- EOR #opr8i, EOR opr8a, EOR opr16a, EOR oprx16,X, EOR oprx8,X, EOR ,X
                    addrMux <= addrPC;
                    regA <= regA xor datain;
                    tres := regA xor datain;
                    flagN <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= '0';
                    if opcode = x"A8" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"A9" | x"B9" | x"C9" | x"D9" | x"E9" | x"F9" =>  -- ADC #opr8i, ADC opr8a, ADC opr16a, ADC oprx16,X, ADC oprx8,X, ADC ,X
                    addrMux <= addrPC;
                    regA <= regA + datain + ("0000000" & flagC);
                    tres := regA + datain + ("0000000" & flagC);
                    flagN <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagH <= (regA(3) and datain(3)) or
                            (datain(3) and (not tres(3))) or
                            ((not tres(3)) and regA(3));
                    flagV <= (regA(7) and datain(7) and (not tres(7))) or
                            ((not regA(7)) and (not datain(7)) and tres(7));
                    flagC <= (regA(7) and datain(7)) or
                            (datain(7) and (not tres(7))) or
                            ((not tres(7)) and regA(7));
                    if opcode = x"A9" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"AA" | x"BA" | x"CA" | x"DA" | x"EA" | x"FA" =>  -- ORA #opr8i, ORA opr8a, ORA opr16a, ORA oprx16,X, ORA oprx8,X, ORA ,X
                    addrMux <= addrPC;
                    regA <= regA or datain;
                    tres := regA or datain;
                    flagN <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= '0';
                    if opcode = x"AA" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"AB" | x"BB" | x"CB" | x"DB" | x"EB" | x"FB" =>  -- ADD #opr8i, ADD opr8a, ADD opr16a, ADD oprx16,X, ADD oprx8,X, ADD ,X
                    addrMux <= addrPC;
                    regA <= regA + datain;
                    tres := regA + datain;
                    flagN <= tres(7);
                    if tres = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagH <= (regA(3) and datain(3)) or
                            (datain(3) and (not tres(3))) or
                            ((not tres(3)) and regA(3));
                    flagV <= (regA(7) and datain(7) and (not tres(7))) or
                            ((not regA(7)) and (not datain(7)) and tres(7));
                    flagC <= (regA(7) and datain(7)) or
                            (datain(7) and (not tres(7))) or
                            ((not tres(7)) and regA(7));
                    if opcode = x"AB" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"AE" | x"BE" | x"CE" | x"DE" | x"EE" | x"FE" =>  -- LDX #opr8i, LDX opr8a, LDX opr16a, LDX oprx16,X, LDX oprx8,X, LDX ,X
                    addrMux <= addrPC;
                    regHX(7 downto 0) <= datain;
                    flagN <= datain(7);
                    if datain = x"00" then
                    flagZ <= '1';
                    else
                    flagZ <= '0';
                    end if;
                    flagV <= '0';
                    if opcode = x"AE" then
                    regPC <= regPC + 1;
                    end if;
                    mainFSM <= "0010";
                when x"AF" =>  -- AIX
                    if datain(7) = '0' then
                    regHX <= regHX + (x"00" & datain);
                    else
                    regHX <= regHX + (x"FF" & datain);
                    end if;
                    regPC <= regPC + 1;
                    mainFSM <= "0010";
                when x"AD" =>  -- BSR rel
                    wr <= CPUread;
                    addrMux <= addrPC;
                    if help(7) = '0' then
                    regPC <= regPC + (x"00" & help);
                    else
                    regPC <= regPC + (x"FF" & help);
                    end if;
                    regSP <= regSP - 1;
                    mainFSM <= "0010";
                when x"BD" =>  -- JSR opr8a
                    wr <= CPUread;
                    addrMux <= addrPC;
                    regPC <= x"00" & help;
                    regSP <= regSP - 1;
                    mainFSM <= "0010";
                when x"CD" | x"DD" =>  -- JSR opr16a, JSR oprx16,X
                    regSP <= regSP - 1;
                    dataMux <= outPCH;
                    mainFSM <= "0110";
                when x"ED" =>  -- JSR oprx8,X
                    wr <= CPUread;
                    addrMux <= addrPC;
                    regPC <= (x"00" & help) + regHX;
                    regSP <= regSP - 1;
                    mainFSM <= "0010";
                when x"FD" =>  -- JSR ,X
                    wr <= CPUread;
                    addrMux <= addrPC;
                    regPC <= regHX;
                    regSP <= regSP - 1;
                    mainFSM <= "0010";

                when others =>
                    mainFSM <= "0000";
                end case; -- opcode

            when "0110" => --##################### instruction cycle 5
                case opcode is
                when x"3B" | x"6B" | x"7B" => -- DBNZ opr8a,rel, DBNZ oprx8,X,rel, DBNZ ,X,rel
                    if help = x"00" then
                    regPC <= regPC + 1;
                    else
                    if datain(7) = '0' then
                        regPC <= regPC + (x"00" & datain) + x"0001";
                    else
                        regPC <= regPC + (x"FF" & datain) + x"0001";
                    end if;
                    end if;
                    mainFSM <= "0010";
                when x"4E" | x"7E" =>  -- MOV opr8a,opr8a, MOV ,X+,opr8a
                    wr <= CPUread;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"80" | x"82" =>  -- RTI, RTT
                    regPC(15 downto 8) <= datain;
                    regSP <= regSP + 1;
                    mainFSM <= "0111";
                when x"83" =>  -- SWI
                    regSP <= regSP - 1;
                    dataMux <= outA;
                    mainFSM <= "0111";
                when x"CD" =>  -- JSR opr16a
                    wr <= CPUread;
                    addrMUX <= addrPC;
                    regSP <= regSP - 1;
                    regPC <= temp;
                    mainFSM <= "0010";
                when x"DD" =>  -- JSR oprx16,X
                    wr <= CPUread;
                    addrMUX <= addrPC;
                    regSP <= regSP - 1;
                    regPC <= temp + regHX;
                    mainFSM <= "0010";

                when others =>
                    mainFSM <= "0000";
                end case; -- opcode

            when "0111" => --##################### instruction cycle 6
                case opcode is
                when x"80" | x"82" =>  -- RTI, RTT
                    regPC(7 downto 0) <= datain;
                    addrMux <= addrPC;
                    mainFSM <= "0010";
                when x"83" =>  -- SWI
                    regSP   <= regSP - 1;
                    dataMux <= outHelp;
                    flagI   <= '1';
                    if trace = '0' then
                    if irqRequest = '0' then
                        temp    <= x"FFFC"; -- SWI vector
                    else
                        irqRequest <= '0';
                        temp    <= x"FFFA"; -- IRQ vector
                    end if;
                    mainFSM <= "1000";
                    else
                    temp    <= x"FFF8"; -- trace vector
                    mainFSM <= "1011";
                    end if;

                when others =>
                    mainFSM <= "0000";
                end case; -- opcode
            when "1000" => --##################### instruction cycle 7
                case opcode is
                when x"83" =>  -- SWI
                    wr <= CPUread;
                    addrMux <= addrTM;
                    regSP   <= regSP - 1;
                    mainFSM <= "1001";

                when others =>
                    mainFSM <= "0000";
                end case;
            when "1001" => --##################### instruction cycle 8
                case opcode is
                when x"83" =>  -- SWI
                    regPC(15 downto 8) <= datain;
                    temp <= temp + 1;
                    mainFSM <= "1010";

                when others =>
                    mainFSM <= "0000";
                end case;
            when "1010" => --##################### instruction cycle 9
                case opcode is
                when x"83" =>  -- SWI
                    regPC(7 downto 0) <= datain;
                    addrMux <= addrPC;
                    mainFSM <= "0010";

                when others =>
                    mainFSM <= "0000";
                end case;
            when "1011" => --##################### instruction cycle 6a, trace
                regSP   <= regSP - 1;
                dataMux <= outCode;
                trace   <= '0';
                trace_i <= '0';
                mainFSM <= "1000";

            when others =>
                mainFSM <= "0000";
            end case; -- mainFSM
        end if;
    end if;
  end process;

end behavior;
