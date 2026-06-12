----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/27/2025 03:33:54 PM
-- Design Name: 
-- Module Name: gth_rst_controller - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

Library xpm;
use xpm.vcomponents.all;


entity gth_rst_controller is
  port (
    clk                                 : in    std_logic;
    rstn                                : in    std_logic;
    gtwiz_userclk_rx_reset           : out std_logic_vector(0 to 0);
    gtwiz_buffbypass_rx_reset        : out std_logic_vector(0 to 0);
    gtwiz_buffbypass_rx_start_user   : out std_logic_vector(0 to 0);
    gtwiz_reset_all                  : out std_logic_vector(0 to 0);
    gtwiz_reset_rx_pll_and_datapath  : out std_logic_vector(0 to 0);
    gtwiz_reset_rx_datapath          : out std_logic_vector(0 to 0);

    rxcdrhold                        : out std_logic_vector(6 downto 0);
    rxcdrovrden                      : out std_logic_vector(6 downto 0);
    rxlpmen                          : out STD_LOGIC_VECTOR(6 downto 0);
    rxlpmhfovrden                    : out STD_LOGIC_VECTOR(6 downto 0);
    rxlpmlfklovrden                  : out STD_LOGIC_VECTOR(6 downto 0);
    rxosovrden                       : out STD_LOGIC_VECTOR(6 downto 0);


    gtwiz_userclk_rx_active     : in std_logic_vector(0 to 0);
    gtwiz_buffbypass_rx_done    : in std_logic_vector(0 to 0);
    gtwiz_buffbypass_rx_error   : in std_logic_vector(0 to 0);
    gtwiz_reset_rx_cdr_stable   : in std_logic_vector(0 to 0);
    gtwiz_reset_rx_done         : in std_logic_vector(0 to 0);
    qpll0lock                   : in std_logic_vector(1 downto 0);
    qpll0refclklost             : in std_logic_vector(1 downto 0);
    gtpowergood                 : in std_logic_vector(6 downto 0);
    rxpmaresetdone              : in std_logic_vector(6 downto 0);

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

architecture Behavioral of gth_rst_controller is



type axi_fsm is (AXI_IDLE,AXI_READ_RESP,AXI_WRITE_RESP);
signal state : axi_fsm := AXI_IDLE;


signal reg_resets   : std_logic_vector(31 downto 0);
signal reg_cdr_controls : std_logic_vector(31 downto 0);
signal reg_gth_configs : std_logic_vector(31 downto 0);

signal reg_resets_status : std_logic_vector(31 downto 0);
signal reg_status : std_logic_vector(31 downto 0);

signal axi_awready_int : std_logic := '0';
signal axi_wready_int  : std_logic := '0';
signal axi_bvalid_int  : std_logic := '0';
signal axi_arready_int : std_logic := '0';
signal axi_rvalid_int  : std_logic := '0';
signal axi_rdata_int   : std_logic_vector(31 downto 0) := (others => '0');
signal axi_bresp_int   : std_logic_vector(1 downto 0) := (others => '0');
signal axi_rresp_int   : std_logic_vector(1 downto 0) := (others => '0');


begin
    
    gtwiz_reset_all(0)                 <= reg_resets(0);                
    gtwiz_reset_rx_pll_and_datapath(0) <= reg_resets(1);
    gtwiz_reset_rx_datapath(0)         <= reg_resets(2);   
    gtwiz_userclk_rx_reset(0)          <= reg_resets(3);         
    gtwiz_buffbypass_rx_reset(0)       <= reg_resets(4);      
    gtwiz_buffbypass_rx_start_user(0)  <= reg_resets(5);      

    rxcdrhold   <=  reg_cdr_controls(6 downto 0);
    rxcdrovrden <=  reg_cdr_controls(14 downto 8);

    rxlpmen         <=  reg_gth_configs(6  downto 0);
    rxlpmhfovrden   <=  reg_gth_configs(14 downto 8);
    rxlpmlfklovrden <=  reg_gth_configs(22 downto 16);
    rxosovrden      <=  reg_gth_configs(30 downto 24);

    reg_resets_status(0) <= gtwiz_userclk_rx_active(0);   
    reg_resets_status(1) <= gtwiz_buffbypass_rx_done(0);  
    reg_resets_status(2) <= gtwiz_buffbypass_rx_error(0); 
    reg_resets_status(3) <= gtwiz_reset_rx_cdr_stable(0); 
    reg_resets_status(4) <= gtwiz_reset_rx_done(0);       

    reg_status(6 downto 0) <= gtpowergood;       
    reg_status(14 downto 8) <= rxpmaresetdone;   
    reg_status(17 downto 16) <= qpll0lock;       
    reg_status(19 downto 18) <= qpll0refclklost; 

  -- 1) AXI4-Lite slave logic
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

                reg_resets <= (others =>'0');
                reg_cdr_controls <= (others =>'0');
                reg_gth_configs <= (others =>'0');
            else
                case state is
                when AXI_IDLE =>

                    if s_axi_awvalid = '1' and s_axi_wvalid = '1' and s_axi_bready = '1' then

                        axi_wready_int  <= '1';
                        addr_index := to_integer(unsigned(s_axi_awaddr(9 downto 2)));
                        axi_awready_int <= '0';

                        if addr_index = 0 then
                            reg_resets  <= s_axi_wdata;
                        elsif addr_index = 1 then
                            reg_cdr_controls <= s_axi_wdata;
                        elsif addr_index = 2 then
                            reg_gth_configs <= s_axi_wdata;
                        end if;
                    
                        state <= AXI_WRITE_RESP;

                    elsif s_axi_arvalid = '1' and axi_arready_int = '1' and s_axi_rready = '1' then

                        axi_arready_int <= '0';
                        addr_index := to_integer(unsigned(s_axi_araddr(9 downto 2)));
                        axi_rvalid_int  <= '1';
                        axi_rresp_int   <= "00";  -- OKAY

                        if addr_index = 0 then
                            axi_rdata_int <= reg_resets;
                        elsif addr_index = 1 then
                            axi_rdata_int <= reg_cdr_controls;
                        elsif addr_index = 2 then
                            axi_rdata_int <= reg_gth_configs;
                        elsif addr_index = 3 then
                            axi_rdata_int <= reg_resets_status;
                        elsif addr_index = 4 then
                            axi_rdata_int <= reg_status;
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