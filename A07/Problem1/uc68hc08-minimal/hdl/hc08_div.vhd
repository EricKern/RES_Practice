-----------------------------------------------

-- restoring divider

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity idiv_s is
    generic (
        seq: boolean := false;
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
end entity;



ARCHITECTURE a OF idiv_s IS

    signal start_i, done_i : std_logic;
    type stype is RANGE 0 TO 3;
    signal st, stn: stype := 0;

begin

    process
    begin
        wait until rising_edge(clk);
        if rst = '1' then
            st <= 0;
        else
            st <= stn;
        end if;
    end process;

    process(start, done_i, st)
    begin
        start_i <= '0';
        done <= '1';
        stn <= st;
        case st is
            when 0 =>
                if start = '1' then 
                    start_i <= '1';
                    done <= '0';
                    stn <= 1;
                end if;
            when 1 =>
                done <= '0';
                if done_i = '1' then
                    stn <= 2;
                end if;
            when 2 =>
                done <= '1';
                stn <= 3;
            when 3 =>
                if start = '0' then
                    stn <= 0;
                end if;
        end case;
    end process;

    process
        variable a,aa: unsigned(ubits - 1 downto 0);
        variable b,d,p,tp: unsigned(lbits - 1 downto 0);
        variable q: unsigned(ubits - 1 downto 0);
        variable r: integer range 0 to 2**ubits - 1;
        variable c: integer range 0 to ubits;
    begin
        wait until rising_edge(clk);
        if start_i = '1' then
            a := unsigned(dividend);
            aa := unsigned(dividend);
            b := unsigned(divisor);
            p := (others => '0');
            q := (others => '0');
            done_i <= '0';
            c := 0;
            err <= '0';
            zero <= '0';
            if a = 0 then
				err <= '0';
                zero <= '1';
                c := ubits;  -- done
            elsif b = 0 then
                zero <= '0';
                err <= '1';
                c := ubits;  -- done
            end if;
        -- elsif c < rbits - 1 then
        elsif c < ubits then
			zero <= '0';
			err <= '0';
            -- shift left
            p := p(lbits - 2 downto 0) & a(ubits - 1); -- 
            a := a(ubits - 2 downto 0) & '0';  
            -- compare and sub, update q
            if p < b then
                q := q(ubits - 2 downto 0) & '0';
            else
                p := p - b;
                q := q(ubits - 2 downto 0) & '1';
            end if;
            c := c + 1;
        else
            done_i <= '1';
            quotient <= std_logic_vector(q(rbits - 1 downto 0));
            r := to_integer(aa) - to_integer(q)*to_integer(b);
            remainder <= std_logic_vector(to_unsigned(r,rbits));
			zero <= '0';
			err <= '0';
            if r > 2**rbits - 1 then
                err <= '1';
            end if;
        end if;
    end process;


end a;

