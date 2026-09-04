----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/22/2025 12:45:34 AM
-- Design Name: 
-- Module Name: channel_hist - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Library xpm;
use xpm.vcomponents.all;


entity channel_hist is
  generic (
    N_HISTOGRAMS : integer := 16    -- number of channels (4 or 8)
  );
  port (
    clk   : in  std_logic;
    rstn   : in  std_logic;

    -- gth stats signals
    gth_domain_clk : in std_logic;
    gth_valid_in : in std_logic;
    gth_diff_in : in std_logic_vector (8 downto 0); 
    gth_minmax_in : in std_logic_vector (31 downto 0); 
    -- TODO: add outputs (e.g. histogram readback interface, status flags, etc.)
    
    ch_hist_idle : out std_logic;
    ch_hist_finished : out std_logic;

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

architecture Behavioral of channel_hist is



type axi_fsm is (AXI_IDLE,AXI_READ_RESP,AXI_WRITE_RESP);
signal state : axi_fsm := AXI_IDLE;

type hist_fsm is (IDLE,GATHERDATA,FINISH);
signal hist_state : hist_fsm := IDLE;

-- Histogram: one 32-bit unsigned counter per tap, total size = N_CHANNELS
type signed_vector is array (natural range <>) of signed(31 downto 0);
signal gth_reg_cfg : std_logic_vector(31 downto 0);
signal gth_reg_status : std_logic_vector(31 downto 0);
signal gth_reg_sum : std_logic_vector(31 downto 0);
signal gth_reg_base : std_logic_vector(31 downto 0);
signal gth_reg_hist : signed_vector(0 to (N_HISTOGRAMS-1));

signal gth_reg_minmax : std_logic_vector(31 downto 0);

signal axi_reg_cfg : std_logic_vector(31 downto 0);
signal axi_reg_status : std_logic_vector(31 downto 0);
signal axi_reg_sum : std_logic_vector(31 downto 0);
signal axi_reg_base : std_logic_vector(31 downto 0);
signal axi_reg_hist : signed_vector(0 to (N_HISTOGRAMS-1));
signal axi_reg_minmax : std_logic_vector(31 downto 0);

signal axi_awready_int : std_logic := '0';
signal axi_wready_int  : std_logic := '0';
signal axi_bvalid_int  : std_logic := '0';
signal axi_arready_int : std_logic := '0';
signal axi_rvalid_int  : std_logic := '0';
signal axi_rdata_int   : std_logic_vector(31 downto 0) := (others => '0');
signal axi_bresp_int   : std_logic_vector(1 downto 0) := (others => '0');
signal axi_rresp_int   : std_logic_vector(1 downto 0) := (others => '0');

  -- synchronizers --
signal rstn_cdc  : std_logic;

signal w_ch_hist_idle     : std_logic := '0';
signal w_ch_hist_finished : std_logic := '0';

begin


    -- ==============================================================
    -- CDC: konfiguracja (AXI -> GTH)
    -- ==============================================================

    xpm_cdc_cfg : xpm_cdc_array_single
    generic map (
        DEST_SYNC_FF => 2,
        SRC_INPUT_REG => 1,
        WIDTH => 32
    )
    port map (
        src_clk  => clk,               -- AXI
        src_in   => axi_reg_cfg,
        dest_clk => gth_domain_clk,    -- GTH
        dest_out => gth_reg_cfg
    );

    xpm_cdc_base : xpm_cdc_array_single
    generic map (
        DEST_SYNC_FF => 2,
        SRC_INPUT_REG => 1,
        WIDTH => 32
    )
    port map (
        src_clk  => clk,               -- AXI
        src_in   => axi_reg_base,
        dest_clk => gth_domain_clk,    -- GTH
        dest_out => gth_reg_base
    );

    -- ==============================================================
    -- CDC: status/sum/histogram (GTH -> AXI)
    -- ==============================================================

    xpm_cdc_status : xpm_cdc_array_single
    generic map (
        DEST_SYNC_FF => 2,
        SRC_INPUT_REG => 1,
        WIDTH => 32
    )
    port map (
        src_clk  => gth_domain_clk,    -- GTH
        src_in   => gth_reg_status,
        dest_clk => clk,               -- AXI
        dest_out => axi_reg_status
    );

    xpm_cdc_sum : xpm_cdc_array_single
    generic map (
        DEST_SYNC_FF => 2,
        SRC_INPUT_REG => 1,
        WIDTH => 32
    )
    port map (
        src_clk  => gth_domain_clk,    -- GTH
        src_in   => gth_reg_sum,
        dest_clk => clk,               -- AXI
        dest_out => axi_reg_sum
    );

    xpm_cdc_minmax : xpm_cdc_array_single
    generic map (
        DEST_SYNC_FF => 2,
        SRC_INPUT_REG => 1,
        WIDTH => 32
    )
    port map (
        src_clk  => gth_domain_clk,    -- GTH
        src_in   => gth_reg_minmax,
        dest_clk => clk,               -- AXI
        dest_out => axi_reg_minmax
    );
    
    gen_hist_cdc : for i in 0 to N_HISTOGRAMS-1 generate
        signal lane_src : std_logic_vector(31 downto 0);
        signal lane_dst : std_logic_vector(31 downto 0)
        ;
        begin
        lane_src <= std_logic_vector(gth_reg_hist(i));

        xpm_cdc_hist_i : xpm_cdc_array_single
        generic map (
            DEST_SYNC_FF  => 2,
            SRC_INPUT_REG => 1,
            WIDTH         => 32
        )
        port map (
            src_clk  => gth_domain_clk,
            src_in   => lane_src,
            dest_clk => clk,
            dest_out => lane_dst
        );

        axi_reg_hist(i) <= signed(lane_dst);
    end generate;


    -- reset do domeny GTH (gth_domain_clk)
    xpm_cdc_async_rst_gth : xpm_cdc_async_rst
    generic map (
        DEST_SYNC_FF => 2,
        INIT_SYNC_FF => 0,
        RST_ACTIVE_HIGH => 0 
    )
    port map (
        src_arst => rstn,
        dest_clk => gth_domain_clk,
        dest_arst => rstn_cdc
    );
  ----------------------------------------------------------------------------
  -- 1) Main process:
  ----------------------------------------------------------------------------
    hist: process(gth_domain_clk) 
        variable hist_indx : integer range 0 to N_HISTOGRAMS-1;
        -- we only check spread -8/+7 values with reference to lane0
        variable chn_diff : integer range  (-N_HISTOGRAMS/2) to (N_HISTOGRAMS/2 -1); 
        variable local_sum : integer;
    begin
    
        if rising_edge(gth_domain_clk) then
            if rstn_cdc = '0' then
                gth_reg_status <= (others => '0');
                
                gth_reg_minmax <= (others => '0');

                for i in 0 to N_HISTOGRAMS-1 loop
                    gth_reg_hist(i) <= (others => '0');
                end loop;
                hist_state <= IDLE;
                local_sum  := 0;
                gth_reg_sum     <= (others => '0');
                gth_reg_status    <= (others => '0');
                gth_reg_hist    <= (others => (others=>'0'));
            else
                case hist_state is

                when IDLE =>
                    for i in 0 to N_HISTOGRAMS-1 loop
                        gth_reg_hist(i) <= (others => '0');
                    end loop;
                    local_sum := 0;
                    gth_reg_status(1) <= '0'; 
                    gth_reg_status(0) <= '0';  
                    gth_reg_sum <= std_logic_vector(to_signed(0,32));

                    if gth_reg_cfg(0) = '1' then
                        hist_state <= GATHERDATA;
                    end if;


                when GATHERDATA =>
                    gth_reg_status(0) <= '1';
                    if (gth_valid_in = '1') then
                        chn_diff  := to_integer(signed(gth_diff_in));
                        hist_indx := chn_diff + N_HISTOGRAMS/2;
                        if (hist_indx >= 0) and (hist_indx < N_HISTOGRAMS) then
                            gth_reg_hist(hist_indx) <= gth_reg_hist(hist_indx) + 1;
                            local_sum := local_sum + 1;
                            gth_reg_sum <= std_logic_vector(to_signed(local_sum, 32));
                        end if;
                        
                        gth_reg_minmax <= gth_minmax_in;
                    end if;

                    if to_unsigned(local_sum,32) >= unsigned(gth_reg_base) then
                        hist_state <= FINISH;
                    end if;

                    if gth_reg_cfg(0) = '0' then
                        hist_state <= IDLE;
                    end if;
                    
                when FINISH =>
                    gth_reg_status(1) <= '1';
                    if(gth_reg_cfg(0) = '0') then
                        hist_state <= IDLE;
                    end if;
            end case;

        end if;
        end if;
        
    end process;

-- control signals for min/max algorithm
    hist_status: process(gth_domain_clk)
    begin    
        if rising_edge(gth_domain_clk) then
            if rstn_cdc = '0' then
               --w_ch_hist_idle <= '1';
               w_ch_hist_finished <= '0';
            else            
--                if (hist_state = IDLE) then
--                    w_ch_hist_idle <= '1';
--                else
--                    w_ch_hist_idle <= '0';
--                end if;               
                if (hist_state = FINISH) then
                    w_ch_hist_finished <= '1';
                else
                    w_ch_hist_finished <= '0';
                end if;
            end if;
        end if;        
    end process;
    
ch_hist_idle <= (not gth_reg_cfg(0)); -- idle/reset == 0
ch_hist_finished <= w_ch_hist_finished;

  -- 2) AXI4-Lite slave logic
    axifsm :process(clk)
        variable addr_index : integer range 0 to 511;
    begin
        if rising_edge(clk) then
            if rstn = '0' then
                state           <= AXI_IDLE;
                axi_awready_int <= '0';
                axi_wready_int  <= '0';
                axi_bvalid_int  <= '0';
                axi_arready_int <= '0';
                axi_rvalid_int  <= '0';
                axi_rdata_int   <= (others => '0');
                axi_bresp_int   <= "00";  -- OKAY
                axi_rresp_int   <= "00";  -- OKAY
                axi_reg_cfg     <= (others => '0');
                axi_reg_base    <= (others => '0');
            else
                case state is
                when AXI_IDLE =>

                    if s_axi_awvalid = '1' and s_axi_wvalid = '1' and s_axi_bready = '1' then

                        axi_wready_int  <= '1';
                        addr_index := to_integer(unsigned(s_axi_awaddr(9 downto 2)));
                        axi_awready_int <= '0';

                        if addr_index = 0 then
                            axi_reg_cfg  <= s_axi_wdata;
                        elsif addr_index = 1 then
                            axi_reg_base <= s_axi_wdata;
                        end if;
                    
                        state <= AXI_WRITE_RESP;

                    elsif s_axi_arvalid = '1' and axi_arready_int = '1' and s_axi_rready = '1' then

                        axi_arready_int <= '0';
                        addr_index := to_integer(unsigned(s_axi_araddr(9 downto 2)));
                        axi_rvalid_int  <= '1';
                        axi_rresp_int   <= "00";  -- OKAY

                        if addr_index = 0 then
                            axi_rdata_int <= axi_reg_cfg;
                        elsif addr_index = 1 then
                            axi_rdata_int <= axi_reg_base;
                        elsif addr_index = 2 then
                            axi_rdata_int <= axi_reg_status;
                        elsif addr_index = 3 then
                            axi_rdata_int <= axi_reg_sum;
                        elsif addr_index >= 4 and addr_index < (4+N_HISTOGRAMS) then
                            axi_rdata_int <= std_logic_vector(axi_reg_hist(addr_index-4));
                        elsif addr_index = (4 + N_HISTOGRAMS) then
                            axi_rdata_int <= axi_reg_minmax;
                        else
                            axi_rdata_int <= x"DEADBEEF";
                        end if;
                        state <= AXI_READ_RESP;

                    else 
                        -- read part
                        axi_arready_int <= '1';
                        axi_rvalid_int  <= '0';
                        axi_rresp_int   <= "00";
                        -- write part
                        axi_awready_int <= '1';
                        axi_wready_int  <= '0';
                        axi_bvalid_int  <= '0';
                        axi_bresp_int   <= "00";
                    end if;
                
                when AXI_WRITE_RESP =>
                    if s_axi_bready = '1' then
                        axi_bvalid_int  <= '1';
                        axi_bresp_int <= "00";
                        state <= AXI_IDLE;
                    end if;

                when AXI_READ_RESP =>
                    
                    axi_rresp_int   <= "00";  -- OKAY

                    if s_axi_rready = '1' then
                        axi_rvalid_int <= '0';
                        state <= AXI_IDLE;
                    end if;

                when others =>
                        state <= AXI_IDLE;
                end case;
            end if;
        end if;
    end process;

    -- 3) Outputs
    s_axi_awready <= axi_awready_int;
    s_axi_wready  <= axi_wready_int;
    s_axi_bvalid  <= axi_bvalid_int;
    s_axi_bresp   <= axi_bresp_int;
    s_axi_arready <= axi_arready_int;
    s_axi_rvalid  <= axi_rvalid_int;
    s_axi_rdata   <= axi_rdata_int;
    s_axi_rresp   <= axi_rresp_int;


end Behavioral;