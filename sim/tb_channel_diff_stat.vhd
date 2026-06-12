library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_channel_diff_stat is
end entity;

architecture sim of tb_channel_diff_stat is
    ----------------------------------------------------------------
    -- Parametry
    ----------------------------------------------------------------
    constant W          : integer := 80;
    constant LEN        : integer := 8*W;      -- pełny cykl
    constant CLK_PERIOD : time    := 10 ns;    -- 100 MHz

    ----------------------------------------------------------------
    -- DUT I/O
    ----------------------------------------------------------------
    signal aclk     : std_logic := '0';
    signal aresetn  : std_logic := '0';

    signal ch0, ch1, ch2, ch3, ch4, ch5, ch6 : std_logic_vector(W-1 downto 0) := (others=>'0');

    signal diff_valid : std_logic;
    signal ch01_diff, ch02_diff, ch03_diff, ch04_diff, ch05_diff, ch06_diff : std_logic_vector(8 downto 0);

    ----------------------------------------------------------------
    -- Baza: 8*W, pierwsza połowa '1', druga połowa '0'
    ----------------------------------------------------------------
    signal base_seq : std_logic_vector(LEN-1 downto 0);
    -- globalny ring-shift (inkrementowany co takt)
    signal gshift   : integer := 0;

    ----------------------------------------------------------------
    -- Funkcje pomocnicze
    ----------------------------------------------------------------
    -- zawijane pobranie elementu z base_seq (0..LEN-1)
    function at_wrap(slv : std_logic_vector; idx : integer) return std_logic is
        variable j : integer := idx mod slv'length;
    begin
        if j < 0 then j := j + slv'length; end if;
        return slv(j);
    end function;

    -- wycięcie okna o długości W zaczynając od start (rosnąco), z zawijaniem
    -- wynik ma indeksy (W-1 downto 0), gdzie bit j odpowiada pozycji start+j
    function window80(slv : std_logic_vector; start : integer) return std_logic_vector is
        variable v : std_logic_vector(W-1 downto 0);
    begin
        for j in 0 to W-1 loop
            v(j) := at_wrap(slv, start + j);
        end loop;
        return v;
    end function;

    -- ograniczenie wartości do zakresu [a,b]
    function clamp(x, a, b : integer) return integer is
    begin
        if x < a then return a; elsif x > b then return b; else return x; end if;
    end function;

begin
    ----------------------------------------------------------------
    -- 1) ZEGAR
    ----------------------------------------------------------------
    clk_proc : process
    begin
        aclk <= '0'; wait for CLK_PERIOD/2;
        aclk <= '1'; wait for CLK_PERIOD/2;
    end process;

    ----------------------------------------------------------------
    -- DUT
    ----------------------------------------------------------------
    dut : entity work.channel_diff_stat
        generic map ( channel_width => W )
        port map (
            aclk       => aclk,
            aresetn    => aresetn,
            ch0        => ch0,
            ch1        => ch1,
            ch2        => ch2,
            ch3        => ch3,
            ch4        => ch4,
            ch5        => ch5,
            ch6        => ch6,
            diff_valid => diff_valid,
            ch01_diff  => ch01_diff,
            ch02_diff  => ch02_diff,
            ch03_diff  => ch03_diff,
            ch04_diff  => ch04_diff,
            ch05_diff  => ch05_diff,
            ch06_diff  => ch06_diff
        );

    ----------------------------------------------------------------
    -- 2) KONTROLA (reset, czas symulacji)
    ----------------------------------------------------------------
    ctrl_proc : process
    begin
        -- inicjalizacja base_seq: 4W jedynek, 4W zer
        for i in 0 to LEN-1 loop
            if i < 4*W then
                base_seq(i) <= '1';
            else
                base_seq(i) <= '0';
            end if;
        end loop;

        aresetn <= '0';
        wait for 200 ns;
        aresetn <= '1';

        -- czas trwania symulacji
        wait for 20 us;
        report "TB done." severity note;
        wait;
    end process;

    ----------------------------------------------------------------
    -- 3) SYGNAŁY (ring-shift + stałe offsety kanałów, wycinek 80 bit)
    ----------------------------------------------------------------
    sig_proc : process
        -- stałe przesunięcia kanałów względem ch0 (te same przez całą symulację)
        constant d1 : integer := -3;
        constant d2 : integer := -1;
        constant d3 : integer := +1;
        constant d4 : integer := +2;
        constant d5 : integer := -2;
        constant d6 : integer := +3;

        variable s0, s1, s2, s3, s4, s5, s6 : integer;
    begin
        -- po resecie wejścia na 0
        ch0 <= (others=>'0');
        ch1 <= (others=>'0');
        ch2 <= (others=>'0');
        ch3 <= (others=>'0');
        ch4 <= (others=>'0');
        ch5 <= (others=>'0');
        ch6 <= (others=>'0');

        -- czekamy na zwolnienie resetu
        wait until aresetn = '1';
        wait until rising_edge(aclk);

        -- główna pętla: co takt zwiększamy globalny przesuw i podajemy okna
        while true loop
            -- globalny ring shift (wspólny dla wszystkich)
            gshift <= (gshift + 1) mod LEN;

            -- pozycje startu okna dla kanałów (ten sam gshift, różne stałe offsety)
            s0 := gshift;
            s1 := gshift + d1;
            s2 := gshift + d2;
            s3 := gshift + d3;
            s4 := gshift + d4;
            s5 := gshift + d5;
            s6 := gshift + d6;

            -- okna 80-bitowe z zawijaniem
            ch0 <= window80(base_seq, s0);
            ch1 <= window80(base_seq, s1);
            ch2 <= window80(base_seq, s2);
            ch3 <= window80(base_seq, s3);
            ch4 <= window80(base_seq, s4);
            ch5 <= window80(base_seq, s5);
            ch6 <= window80(base_seq, s6);

            wait until rising_edge(aclk);
        end loop;
    end process;

end architecture;
