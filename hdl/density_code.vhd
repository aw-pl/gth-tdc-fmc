----------------------------------------------------------------------------------
-- Company: PW
-- Engineer: Kamil Borkowski
-- 
-- Create Date: 06/03/2025 07:02:06 PM
-- Design Name: 
-- Module Name: density_code - Behavioral
-- Project Name: 
-- Target Devices: XCKU035/
-- Tool Versions: 
-- Description: Code-Density Test (CDT) histogram builder:  
--              split a 4×32-bit input stream into per-channel tap vectors, 
--              detect first rising edge per channel, and increment histogram.
-- 
-- Dependencies: IEEE, UNISIM (for eventual instantiation of any Xilinx primitives)
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- If you need any Xilinx primitives (e.g. BUFG, IBUF, etc.), uncomment:
-- library UNISIM;
-- use UNISIM.VComponents.all;

entity density_code is
  generic (
    N_CHANNELS : integer := 4;    -- number of channels (4 or 8)
    VEC_LEN    : integer := 32    -- input vector length per channel
  );
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    -- A single wide input: N_CHANNELS × VEC_LEN bits, indexed downto for easy slicing here.
    ch_in : in  std_logic_vector(N_CHANNELS*VEC_LEN-1 downto 0);
    -- TODO: add outputs (e.g. histogram readback interface, status flags, etc.)

        -- AXI4-Lite slave interface
    s_axi_awaddr  : in  std_logic_vector(31 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;

    s_axi_wdata   : in  std_logic_vector(31 downto 0);
    s_axi_wstrb   : in  std_logic_vector(3 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;

    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;

    s_axi_araddr  : in  std_logic_vector(31 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;

    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic
  );
end entity;

architecture Behavioral of density_code is



  type axi_fsm is (IDLE,READ_RESP,WRITE_RESP);
  signal state : axi_fsm := IDLE;
  -- Split the flat ch_in into an array of N_CHANNELS sub-vectors, each (0 to VEC_LEN-1).
  type t_ch_array is array (natural range <>) of std_logic_vector(0 to VEC_LEN-1);
  signal ch_array : t_ch_array(0 to N_CHANNELS-1);

  -- Histogram: one 32-bit unsigned counter per tap, total size = N_CHANNELS * VEC_LEN
  type unsigned_vector is array (natural range <>) of unsigned(31 downto 0);
  signal reg_cfg : std_logic_vector(31 downto 0);
  signal reg_status : std_logic_vector(31 downto 0);
  signal cdt_data : unsigned_vector(0 to (N_CHANNELS*VEC_LEN-1));
  constant cdt_data_start : integer := 2;
  constant cdt_data_end : integer := N_CHANNELS*VEC_LEN +1;

  -- Track the last MSB of each channel for "edge across the sample boundary"
  signal vector_last_bit : std_logic_vector(0 to N_CHANNELS-1) := (others => '0');


signal axi_awready_int : std_logic := '0';
signal axi_wready_int  : std_logic := '0';
signal axi_bvalid_int  : std_logic := '0';
signal axi_arready_int : std_logic := '0';
signal axi_rvalid_int  : std_logic := '0';
signal axi_rdata_int   : std_logic_vector(31 downto 0) := (others => '0');
signal axi_bresp_int   : std_logic_vector(1 downto 0) := (others => '0');
signal axi_rresp_int   : std_logic_vector(1 downto 0) := (others => '0');


  --------------------------------------------------------------------------
  -- Function: reverse_vector
  -- Purpose : Flip a std_logic_vector so that bit 0 ends up at index 0
  --           This is only needed if you want to re-index the slice from 
  --           (downto) into (0 to VEC_LEN-1). If your higher-level code 
  --           can feed ch_in in "natural ascending" order, you could skip this.
  --------------------------------------------------------------------------
  function reverse_vector(input : std_logic_vector) return std_logic_vector is
    variable output : std_logic_vector(input'reverse_range);
  begin
    for i in input'range loop
      output(i) := input(input'left + input'right - i);
    end loop;
    return output;
  end function;

  --------------------------------------------------------------------------
  -- Function: detect_redge
  -- Purpose : Given a VEC_LEN-wide vector "vec" (indices 0..VEC_LEN-1) 
  --           and the previous last_bit (std_logic), return the index (0..VEC_LEN-1) 
  --           of the first rising edge "0 → 1" across that extended vector. 
  --           If no rising edge is found, return -1.
  --------------------------------------------------------------------------
  function detect_redge(
    vec      : std_logic_vector(0 to VEC_LEN-1);
    last_bit : std_logic
  ) return integer is
    -- Create a temporary (VEC_LEN+1)-wide vector: last_bit & vec
    variable extended : std_logic_vector(0 to VEC_LEN);
  begin
    extended := last_bit & vec;
    for i in 1 to VEC_LEN loop
      if (extended(i-1) = '0') and (extended(i) = '1') then
        -- Return the 0-based index within vec where the rising edge occurred
        return i-1;
      end if;
    end loop;
    return -1;  -- no edge detected
  end function;

begin

  ----------------------------------------------------------------------------
  -- 1) Unpack the flat  (downto-indexed) ch_in into per-channel vectors 
  --    of range (0 to VEC_LEN-1), using reverse_vector to flip bit order.
  ----------------------------------------------------------------------------
  gen_split: for i in 0 to N_CHANNELS-1 generate
    ch_array(i) <= reverse_vector( ch_in((i+1)*VEC_LEN - 1 downto i*VEC_LEN) );
  end generate;

  ----------------------------------------------------------------------------
  -- 2) Main process: on each rising clock edge, either reset or 
  --    detect per-channel rising edges and increment the appropriate bin.
  ----------------------------------------------------------------------------
  process(clk)
    -- Local variables for the detected index (0..VEC_LEN-1) and global bin
    variable idx  : integer;
    variable bin  : integer;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        -- Reset ALL histogram counters to zero
        cdt_data <= (others => (others => '0'));

        -- Initialize last_bit(s) to '0' (or '1', depending on your convention).
        vector_last_bit <= (others => '1');
      else
        -- For each channel, detect a rising edge and increment the histogram
        for ch_idx in 0 to N_CHANNELS-1 loop
          idx := detect_redge(ch_array(ch_idx), vector_last_bit(ch_idx));
          if idx >= 0 then
            -- Compute the *global* bin index using interleaved scheme:
            -- bin = (bit_index * N_CHANNELS) + channel_index
            bin := idx * N_CHANNELS + ch_idx;
            -- Increment that 32-bit unsigned counter
            if bin >= 0 and bin < cdt_data'length then
              cdt_data(bin) <= cdt_data(bin) + 1;
            end if;
          end if;
        end loop;

        -- Update "last_bit" for each channel for next cycle's boundary check
        for ch_idx in 0 to N_CHANNELS-1 loop
          vector_last_bit(ch_idx) <= ch_array(ch_idx)(VEC_LEN-1);
        end loop;
      end if;
    end if;
  end process;


  -- 3) AXI4-Lite slave logic
  process(clk)
    variable addr_index : integer range 0 to 511;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state           <= IDLE;
        axi_awready_int <= '0';
        axi_wready_int  <= '0';
        axi_bvalid_int  <= '0';
        axi_arready_int <= '0';
        axi_rvalid_int  <= '0';
        axi_rdata_int   <= (others => '0');
        axi_bresp_int   <= "00";  -- OKAY
        axi_rresp_int   <= "00";  -- OKAY
      else
        case state is
          when IDLE =>
            axi_awready_int <= '0';
            axi_wready_int  <= '0';
            axi_bvalid_int  <= '0';
            axi_rvalid_int  <= '0';
            axi_bresp_int   <= "00";
            axi_rresp_int   <= "00";


            if (axi_rvalid_int = '0') then
              axi_arready_int <= '1';
            else
              axi_arready_int <= '0';
            end if;


            if s_axi_awvalid = '1' and s_axi_wvalid = '1' then
              axi_awready_int <= '1';
              axi_wready_int  <= '1';
              addr_index := to_integer(unsigned(s_axi_awaddr(9 downto 2)));
              state <= WRITE_RESP;
            elsif s_axi_arvalid = '1' then
              axi_arready_int <= '1';
              addr_index := to_integer(unsigned(s_axi_araddr(9 downto 2)));
              state <= READ_RESP;
            end if;

          when WRITE_RESP =>
            axi_awready_int <= '0';
            axi_wready_int  <= '0';
            axi_bvalid_int  <= '1';
            axi_bresp_int   <= "00";  -- OKAY

            if addr_index = 0 then
              reg_cfg <= s_axi_wdata;
            end if;

            if s_axi_bready = '1' then
              axi_bvalid_int <= '0';
              state <= IDLE;
            end if;

          when READ_RESP =>
            axi_arready_int <= '0';
            axi_rvalid_int  <= '1';
            axi_rresp_int   <= "00";  -- OKAY

            if addr_index = 0 then
              axi_rdata_int <= reg_cfg;
            elsif addr_index = 1 then
              axi_rdata_int <= reg_status;
            elsif addr_index >= cdt_data_start and addr_index < cdt_data_end then
              axi_rdata_int <= std_logic_vector(cdt_data(addr_index-2));
            else
              axi_rdata_int <= (others => '0');
            end if;

            if s_axi_rready = '1' then
              axi_rvalid_int <= '0';
              state <= IDLE;
            end if;

          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

 -- 4) Outputs
  s_axi_awready <= axi_awready_int;
  s_axi_wready  <= axi_wready_int;
  s_axi_bvalid  <= axi_bvalid_int;
  s_axi_bresp   <= axi_bresp_int;
  s_axi_arready <= axi_arready_int;
  s_axi_rvalid  <= axi_rvalid_int;
  s_axi_rdata   <= axi_rdata_int;
  s_axi_rresp   <= axi_rresp_int;


end Behavioral;