
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity gth_wrapper is
    Port (
        -- INPUTS (all grouped first)
        gtwiz_userclk_tx_reset_in        : in  std_logic_vector(0 to 0);
        gtwiz_userclk_rx_reset_in        : in  std_logic_vector(0 to 0);
        gtwiz_buffbypass_tx_reset_in     : in  std_logic_vector(0 to 0);
        gtwiz_buffbypass_tx_start_user_in: in  std_logic_vector(0 to 0);
        gtwiz_buffbypass_rx_reset_in     : in  std_logic_vector(0 to 0);
        gtwiz_buffbypass_rx_start_user_in: in  std_logic_vector(0 to 0);
        gtwiz_reset_clk_freerun_in       : in  std_logic_vector(0 to 0);
        gtwiz_reset_all_in               : in  std_logic_vector(0 to 0);
        gtwiz_reset_tx_pll_and_datapath_in : in  std_logic_vector(0 to 0);
        gtwiz_reset_tx_datapath_in       : in  std_logic_vector(0 to 0);
        gtwiz_reset_rx_pll_and_datapath_in : in  std_logic_vector(0 to 0);
        gtwiz_reset_rx_datapath_in       : in  std_logic_vector(0 to 0);
        gtwiz_userdata_tx_in             : in  std_logic_vector(559 downto 0);
        gtrefclk                         : in  std_logic;
        gthrxn_in                        : in  std_logic_vector(6 downto 0);
        gthrxp_in                        : in  std_logic_vector(6 downto 0);

        -- OUTPUTS (all grouped after inputs)
        gtwiz_userclk_tx_srcclk_out      : out std_logic_vector(0 to 0);
        gtwiz_userclk_tx_usrclk_out      : out std_logic_vector(0 to 0);
        gtwiz_userclk_tx_usrclk2_out     : out std_logic_vector(0 to 0);
        gtwiz_userclk_tx_active_out      : out std_logic_vector(0 to 0);
        gtwiz_userclk_rx_srcclk_out      : out std_logic_vector(0 to 0);
        gtwiz_userclk_rx_usrclk_out      : out std_logic_vector(0 to 0);
        gtwiz_userclk_rx_usrclk2_out     : out std_logic_vector(0 to 0);
        gtwiz_userclk_rx_active_out      : out std_logic_vector(0 to 0);
        gtwiz_buffbypass_tx_done_out     : out std_logic_vector(0 to 0);
        gtwiz_buffbypass_tx_error_out    : out std_logic_vector(0 to 0);
        gtwiz_buffbypass_rx_done_out     : out std_logic_vector(0 to 0);
        gtwiz_buffbypass_rx_error_out    : out std_logic_vector(0 to 0);
        gtwiz_reset_rx_cdr_stable_out    : out std_logic_vector(0 to 0);
        gtwiz_reset_tx_done_out          : out std_logic_vector(0 to 0);
        gtwiz_reset_rx_done_out          : out std_logic_vector(0 to 0);
        gtwiz_userdata_rx_out            : out std_logic_vector(559 downto 0);
        qpll0outclk_out                  : out std_logic_vector(1 downto 0);
        qpll0outrefclk_out               : out std_logic_vector(1 downto 0);
        qpll0lock_out                    : out std_logic_vector(1 downto 0);
        qpll0refclklost_out              : out std_logic_vector(1 downto 0);
        gthtxn_out                       : out std_logic_vector(6 downto 0);
        gthtxp_out                       : out std_logic_vector(6 downto 0);
        gtpowergood_out                  : out std_logic_vector(6 downto 0);
        rxpmaresetdone_out               : out std_logic_vector(6 downto 0);
        txpmaresetdone_out               : out std_logic_vector(6 downto 0);
        txprgdivresetdone_out            : out std_logic_vector(6 downto 0);
        rxcdrhold_in                     : in std_logic_vector(6 downto 0);
        rxcdrovrden_in                   : in std_logic_vector(6 downto 0);
         rxlpmen_in : in STD_LOGIC_VECTOR ( 6 downto 0 );
         rxlpmhfovrden_in : in STD_LOGIC_VECTOR ( 6 downto 0 );
         rxlpmlfklovrden_in : in STD_LOGIC_VECTOR ( 6 downto 0 );
         rxosovrden_in : in STD_LOGIC_VECTOR ( 6 downto 0 )

    );
end gth_wrapper;

architecture rtl of gth_wrapper is

    component gtwizard_ultrascale_0
        Port (
            gtwiz_userclk_tx_reset_in        : in  std_logic_vector(0 to 0);
            gtwiz_userclk_tx_srcclk_out      : out std_logic_vector(0 to 0);
            gtwiz_userclk_tx_usrclk_out      : out std_logic_vector(0 to 0);
            gtwiz_userclk_tx_usrclk2_out     : out std_logic_vector(0 to 0);
            gtwiz_userclk_tx_active_out      : out std_logic_vector(0 to 0);
            gtwiz_userclk_rx_reset_in        : in  std_logic_vector(0 to 0);
            gtwiz_userclk_rx_srcclk_out      : out std_logic_vector(0 to 0);
            gtwiz_userclk_rx_usrclk_out      : out std_logic_vector(0 to 0);
            gtwiz_userclk_rx_usrclk2_out     : out std_logic_vector(0 to 0);
            gtwiz_userclk_rx_active_out      : out std_logic_vector(0 to 0);
            gtwiz_buffbypass_tx_reset_in     : in  std_logic_vector(0 to 0);
            gtwiz_buffbypass_tx_start_user_in: in  std_logic_vector(0 to 0);
            gtwiz_buffbypass_tx_done_out     : out std_logic_vector(0 to 0);
            gtwiz_buffbypass_tx_error_out    : out std_logic_vector(0 to 0);
            gtwiz_buffbypass_rx_reset_in     : in  std_logic_vector(0 to 0);
            gtwiz_buffbypass_rx_start_user_in: in  std_logic_vector(0 to 0);
            gtwiz_buffbypass_rx_done_out     : out std_logic_vector(0 to 0);
            gtwiz_buffbypass_rx_error_out    : out std_logic_vector(0 to 0);
            gtwiz_reset_clk_freerun_in       : in  std_logic_vector(0 to 0);
            gtwiz_reset_all_in               : in  std_logic_vector(0 to 0);
            gtwiz_reset_tx_pll_and_datapath_in : in  std_logic_vector(0 to 0);
            gtwiz_reset_tx_datapath_in       : in  std_logic_vector(0 to 0);
            gtwiz_reset_rx_pll_and_datapath_in : in  std_logic_vector(0 to 0);
            gtwiz_reset_rx_datapath_in       : in  std_logic_vector(0 to 0);
            gtwiz_reset_rx_cdr_stable_out    : out std_logic_vector(0 to 0);
            gtwiz_reset_tx_done_out          : out std_logic_vector(0 to 0);
            gtwiz_reset_rx_done_out          : out std_logic_vector(0 to 0);
            gtwiz_userdata_tx_in             : in  std_logic_vector(559 downto 0);
            gtwiz_userdata_rx_out            : out std_logic_vector(559 downto 0);
            gtrefclk00_in                    : in  std_logic_vector(1 downto 0);
            qpll0outclk_out                  : out std_logic_vector(1 downto 0);
            qpll0outrefclk_out               : out std_logic_vector(1 downto 0);
            qpll0lock_out                    : out std_logic_vector(1 downto 0);
            qpll0refclklost_out              : out std_logic_vector(1 downto 0);
            gthrxn_in                        : in  std_logic_vector(6 downto 0);
            gthrxp_in                        : in  std_logic_vector(6 downto 0);
            gthtxn_out                       : out std_logic_vector(6 downto 0);
            gthtxp_out                       : out std_logic_vector(6 downto 0);
            gtpowergood_out                  : out std_logic_vector(6 downto 0);
            rxpmaresetdone_out               : out std_logic_vector(6 downto 0);
            txpmaresetdone_out               : out std_logic_vector(6 downto 0);
            txprgdivresetdone_out            : out std_logic_vector(6 downto 0);
            rxcdrhold_in                     : in std_logic_vector(6 downto 0);
            rxcdrovrden_in                   : in std_logic_vector(6 downto 0);
            rxlpmen_in : in STD_LOGIC_VECTOR ( 6 downto 0 );
            rxlpmhfovrden_in : in STD_LOGIC_VECTOR ( 6 downto 0 );
            rxlpmlfklovrden_in : in STD_LOGIC_VECTOR ( 6 downto 0 );
            rxosovrden_in : in STD_LOGIC_VECTOR ( 6 downto 0 )
        );
    end component;

    signal gtrefclk00_sig : std_logic_vector(1 downto 0);

begin

    -- Only first element is used, rest are '0'
    gtrefclk00_sig(0) <= gtrefclk;
    gtrefclk00_sig(1) <= gtrefclk;

    u_gtwizard_ultrascale_0 : gtwizard_ultrascale_0
        port map (
            gtwiz_userclk_tx_reset_in         => gtwiz_userclk_tx_reset_in,
            gtwiz_userclk_tx_srcclk_out       => gtwiz_userclk_tx_srcclk_out,
            gtwiz_userclk_tx_usrclk_out       => gtwiz_userclk_tx_usrclk_out,
            gtwiz_userclk_tx_usrclk2_out      => gtwiz_userclk_tx_usrclk2_out,
            gtwiz_userclk_tx_active_out       => gtwiz_userclk_tx_active_out,
            gtwiz_userclk_rx_reset_in         => gtwiz_userclk_rx_reset_in,
            gtwiz_userclk_rx_srcclk_out       => gtwiz_userclk_rx_srcclk_out,
            gtwiz_userclk_rx_usrclk_out       => gtwiz_userclk_rx_usrclk_out,
            gtwiz_userclk_rx_usrclk2_out      => gtwiz_userclk_rx_usrclk2_out,
            gtwiz_userclk_rx_active_out       => gtwiz_userclk_rx_active_out,
            gtwiz_buffbypass_tx_reset_in      => gtwiz_buffbypass_tx_reset_in,
            gtwiz_buffbypass_tx_start_user_in => gtwiz_buffbypass_tx_start_user_in,
            gtwiz_buffbypass_tx_done_out      => gtwiz_buffbypass_tx_done_out,
            gtwiz_buffbypass_tx_error_out     => gtwiz_buffbypass_tx_error_out,
            gtwiz_buffbypass_rx_reset_in      => gtwiz_buffbypass_rx_reset_in,
            gtwiz_buffbypass_rx_start_user_in => gtwiz_buffbypass_rx_start_user_in,
            gtwiz_buffbypass_rx_done_out      => gtwiz_buffbypass_rx_done_out,
            gtwiz_buffbypass_rx_error_out     => gtwiz_buffbypass_rx_error_out,
            gtwiz_reset_clk_freerun_in        => gtwiz_reset_clk_freerun_in,
            gtwiz_reset_all_in                => gtwiz_reset_all_in,
            gtwiz_reset_tx_pll_and_datapath_in => gtwiz_reset_tx_pll_and_datapath_in,
            gtwiz_reset_tx_datapath_in        => gtwiz_reset_tx_datapath_in,
            gtwiz_reset_rx_pll_and_datapath_in => gtwiz_reset_rx_pll_and_datapath_in,
            gtwiz_reset_rx_datapath_in        => gtwiz_reset_rx_datapath_in,
            gtwiz_reset_rx_cdr_stable_out     => gtwiz_reset_rx_cdr_stable_out,
            gtwiz_reset_tx_done_out           => gtwiz_reset_tx_done_out,
            gtwiz_reset_rx_done_out           => gtwiz_reset_rx_done_out,
            gtwiz_userdata_tx_in              => gtwiz_userdata_tx_in,
            gtwiz_userdata_rx_out             => gtwiz_userdata_rx_out,
            gtrefclk00_in                     => gtrefclk00_sig,
            qpll0outclk_out                   => qpll0outclk_out,
            qpll0outrefclk_out                => qpll0outrefclk_out,
            qpll0lock_out                 => qpll0lock_out,
            qpll0refclklost_out           => qpll0refclklost_out,
            gthrxn_in                         => gthrxn_in,
            gthrxp_in                         => gthrxp_in,
            gthtxn_out                        => gthtxn_out,
            gthtxp_out                        => gthtxp_out,
            gtpowergood_out                   => gtpowergood_out,
            rxpmaresetdone_out                => rxpmaresetdone_out,
            txpmaresetdone_out                => txpmaresetdone_out,
            txprgdivresetdone_out             => txprgdivresetdone_out,
            rxcdrhold_in                      => rxcdrhold_in,
            rxcdrovrden_in                    => rxcdrovrden_in,
             rxlpmen_in                        => rxlpmen_in,
             rxlpmhfovrden_in                  =>rxlpmhfovrden_in,
             rxlpmlfklovrden_in                =>rxlpmlfklovrden_in,
             rxosovrden_in                     => rxosovrden_in
        );

end rtl;
