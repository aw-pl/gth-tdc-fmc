----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/02/2025 01:31:14 AM
-- Design Name: 
-- Module Name: cdc_fifo_min - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cdc_fifo_min is
  generic (
    WIDTH        : positive := 32;      -- szerokość słowa
    ADDR_BITS    : positive := 4;       -- głębia = 2**ADDR_BITS
    SYNC_STAGES  : positive := 3;       -- FF w synchronizatorze (>=2)
    DROP_ON_FULL : boolean  := true     -- true: po cichu porzuć wpis; false: assert
  );
  port (
    -- write side (brak w_ready)
    w_clk   : in  std_logic;
    w_rst_n : in  std_logic;
    w_valid : in  std_logic;
    w_data  : in  std_logic_vector(WIDTH-1 downto 0);

    -- read side
    r_clk   : in  std_logic;
    r_rst_n : in  std_logic;
    r_ready : in  std_logic;                            -- możesz zew. związać do '1'
    r_valid : out std_logic;
    r_data  : out std_logic_vector(WIDTH-1 downto 0);

    -- sterowanie w domenie r_clk
    r_flush : in  std_logic := '0';                     -- opróżnij (tylko read ptr)
    g_clear : in  std_logic := '0';                     -- GLOBAL CLEAR: wyzeruj wskaźniki w obu domenach

    -- status w domenie r_clk
    r_level          : out unsigned(ADDR_BITS downto 0);-- liczba słów w FIFO
    r_overflow_seen  : out std_logic                    -- sticky overflow (clear przez g_clear/reset)
  );
end entity;

architecture rtl of cdc_fifo_min is
  constant DEPTH : natural := 2**ADDR_BITS;
  subtype ptr_t  is unsigned(ADDR_BITS downto 0); -- +1 bit wrap

  -- pamięć (LUTRAM, FWFT: asynch. odczyt)
  type ram_t is array (0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);
  signal ram : ram_t;

  -- write domain
  signal w_bin, w_bin_next   : ptr_t := (others => '0');
  signal w_gray, w_gray_next : ptr_t := (others => '0');
  signal full_reg, full_next : std_logic := '0';

  -- read domain
  signal r_bin, r_bin_next   : ptr_t := (others => '0');
  signal r_gray, r_gray_next : ptr_t := (others => '0');
  signal empty_reg, empty_next : std_logic := '1';

  -- zsynchronizowane wskaźniki (Gray)
  type gray_vec is array (natural range <>) of ptr_t;
  signal rgray_wsync : gray_vec(0 to SYNC_STAGES-1);  -- r_gray -> w_clk
  signal wgray_rsync : gray_vec(0 to SYNC_STAGES-1);  -- w_gray -> r_clk
  signal r_gray_sync_in_w : ptr_t;
  signal w_gray_sync_in_r : ptr_t;

  -- handshakes
  signal w_fire : std_logic;
  signal r_fire : std_logic;

  -- overflow flag: toggle w_clk -> r_clk
  signal ovf_tgl_w : std_logic := '0';
  signal ovf_w_pulse : std_logic;
  signal ovf_tgl_rsync : std_logic_vector(0 to SYNC_STAGES-1) := (others => '0');
  signal ovf_tgl_r_last : std_logic := '0';
  signal r_overflow_seen_reg : std_logic := '0';

  -- global clear: toggle z r_clk do w_clk
  signal clr_tgl_r      : std_logic := '0';
  signal clr_tgl_r_d    : std_logic := '0';
  signal clr_tgl_wsync  : std_logic_vector(0 to SYNC_STAGES-1) := (others => '0');
  signal clr_tgl_w_last : std_logic := '0';
  signal g_clear_edge   : std_logic;

  -- utils
  function bin2gray(b : ptr_t) return ptr_t is
  begin
    return b xor ('0' & b(b'high downto 1));
  end function;

  function gray2bin(g : ptr_t) return ptr_t is
    variable b : ptr_t := (others => '0');
  begin
    b(b'high) := g(g'high);
    for i in b'high-1 downto 0 loop
      b(i) := b(i+1) xor g(i);
    end loop;
    return b;
  end function;

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of rgray_wsync  : signal is "TRUE";
  attribute ASYNC_REG of wgray_rsync  : signal is "TRUE";
  attribute ASYNC_REG of ovf_tgl_rsync: signal is "TRUE";
  attribute ASYNC_REG of clr_tgl_wsync: signal is "TRUE";
begin
  -- =========================
  --   READ->WRITE sync (r_gray)
  -- =========================
  sync_r_to_w : process(w_clk, w_rst_n)
  begin
    if w_rst_n = '0' then
      for i in 0 to SYNC_STAGES-1 loop
        rgray_wsync(i) <= (others => '0');
      end loop;
    elsif rising_edge(w_clk) then
      rgray_wsync(0) <= r_gray;
      for i in 1 to SYNC_STAGES-1 loop
        rgray_wsync(i) <= rgray_wsync(i-1);
      end loop;
    end if;
  end process;
  r_gray_sync_in_w <= rgray_wsync(SYNC_STAGES-1);

  -- =========================
  --   WRITE DOMAIN
  -- =========================
  -- full detection with Gray ptrs
  w_fire      <= w_valid and (not full_reg);
  w_bin_next  <= w_bin + (0 => w_fire, others => '0');
  w_gray_next <= bin2gray(w_bin_next);

  full_next <= '1' when
    (w_gray_next(ADDR_BITS downto ADDR_BITS-1) = not r_gray_sync_in_w(ADDR_BITS downto ADDR_BITS-1)) and
    (w_gray_next(ADDR_BITS-2 downto 0)         =     r_gray_sync_in_w(ADDR_BITS-2 downto 0))
  else '0';

  -- overflow pulse (tylko gdy próbujemy pisać przy full)
  ovf_w_pulse <= w_valid and full_reg;

  pw: process(w_clk, w_rst_n)
  begin
    if w_rst_n = '0' then
      w_bin    <= (others => '0');
      w_gray   <= (others => '0');
      full_reg <= '0';
      ovf_tgl_w<= '0';
      clr_tgl_w_last <= '0';
    elsif rising_edge(w_clk) then
      -- global clear (zsynchronizowany toggle z r_clk)
      if clr_tgl_wsync(SYNC_STAGES-1) /= clr_tgl_w_last then
        w_bin    <= (others => '0');
        w_gray   <= (others => '0');
        full_reg <= '0';
        clr_tgl_w_last <= clr_tgl_wsync(SYNC_STAGES-1);
      else
        if w_fire = '1' then
          ram(to_integer(w_bin(ADDR_BITS-1 downto 0))) <= w_data;
          w_bin  <= w_bin_next;
          w_gray <= w_gray_next;
        end if;
        full_reg <= full_next;
      end if;

      if ovf_w_pulse = '1' then
        ovf_tgl_w <= not ovf_tgl_w;
      end if;
    end if;
  end process;

  -- opcjonalna asercja (synteza ją utnie, przydatne w sim)
  assert (DROP_ON_FULL or (not (w_valid = '1' and full_reg = '1')))
    report "cdc_fifo_min: write attempted while FULL (set DROP_ON_FULL=true to drop silently)"
    severity failure;

  -- =========================
  --   WRITE->READ sync (w_gray)
  -- =========================
  sync_w_to_r : process(r_clk, r_rst_n)
  begin
    if r_rst_n = '0' then
      for i in 0 to SYNC_STAGES-1 loop
        wgray_rsync(i) <= (others => '0');
      end loop;
    elsif rising_edge(r_clk) then
      wgray_rsync(0) <= w_gray;
      for i in 1 to SYNC_STAGES-1 loop
        wgray_rsync(i) <= wgray_rsync(i-1);
      end loop;
    end if;
  end process;
  w_gray_sync_in_r <= wgray_rsync(SYNC_STAGES-1);

  -- FWFT: dane obecne pod r_bin (asynch. read)
  r_data  <= ram(to_integer(r_bin(ADDR_BITS-1 downto 0)));
  r_valid <= not empty_reg;

  r_fire      <= r_ready and (not empty_reg);
  r_bin_next  <= r_bin + (0 => r_fire, others => '0');
  r_gray_next <= bin2gray(r_bin_next);

  empty_next <= '1' when (r_gray = w_gray_sync_in_r) else '0';

  -- occupancy (bin różnicy w domenie r_clk)
  r_level <= gray2bin(w_gray_sync_in_r) - r_bin;

  -- =========================
  --   GLOBAL CLEAR (r_clk -> oba)
  -- =========================
  g_clear_edge <= g_clear and not clr_tgl_r_d;

  pr: process(r_clk, r_rst_n)
  begin
    if r_rst_n = '0' then
      r_bin     <= (others => '0');
      r_gray    <= (others => '0');
      empty_reg <= '1';
      clr_tgl_r_d <= '0';
      clr_tgl_r   <= '0';
      ovf_tgl_r_last <= '0';
      r_overflow_seen_reg <= '0';
    elsif rising_edge(r_clk) then
      -- rejestracja poziomu g_clear + wygenerowanie toggle
      clr_tgl_r_d <= g_clear;
      if g_clear_edge = '1' then
        clr_tgl_r <= not clr_tgl_r;  -- toggle do w_clk
        -- lokalne wyzerowanie read ptr
        r_bin     <= (others => '0');
        r_gray    <= (others => '0');
        empty_reg <= '1';
        r_overflow_seen_reg <= '0';
      else
        -- r_flush tylko po czytającej: zrównać z write ptr
        if r_flush = '1' then
          r_gray    <= w_gray_sync_in_r;
          r_bin     <= gray2bin(w_gray_sync_in_r);
          empty_reg <= '1';
        else
          if r_fire = '1' then
            r_bin  <= r_bin_next;
            r_gray <= r_gray_next;
          end if;
          empty_reg <= empty_next;
        end if;
      end if;

      -- overflow toggle z w_clk -> sticky flag
      ovf_tgl_rsync(0) <= ovf_tgl_w;
      for i in 1 to SYNC_STAGES-1 loop
        ovf_tgl_rsync(i) <= ovf_tgl_rsync(i-1);
      end loop;

      if ovf_tgl_rsync(SYNC_STAGES-1) /= ovf_tgl_r_last then
        r_overflow_seen_reg <= '1';
        ovf_tgl_r_last <= ovf_tgl_rsync(SYNC_STAGES-1);
      end if;
    end if;
  end process;

  r_overflow_seen <= r_overflow_seen_reg;

  -- =========================
  --   SYNC of clear toggle into w_clk
  -- =========================
  sync_clr_to_w : process(w_clk, w_rst_n)
  begin
    if w_rst_n = '0' then
      for i in 0 to SYNC_STAGES-1 loop
        clr_tgl_wsync(i) <= '0';
      end loop;
    elsif rising_edge(w_clk) then
      clr_tgl_wsync(0) <= clr_tgl_r;
      for i in 1 to SYNC_STAGES-1 loop
        clr_tgl_wsync(i) <= clr_tgl_wsync(i-1);
      end loop;
    end if;
  end process;

  -- sanity
  assert ADDR_BITS >= 1
    report "cdc_fifo_min: ADDR_BITS must be >= 1 (depth >= 2)"
    severity failure;
end architecture;
