library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

Library xpm;
use xpm.vcomponents.all;

entity channel_diff_stat is
    generic (
        channel_width : integer := 80
    );
    port (
        clk     : in  std_logic;
        aclk    : in  std_logic;
        resetn  : in  std_logic;
        en       : in std_logic;

        ch0      : in  std_logic_vector(channel_width-1 downto 0);
        ch1      : in  std_logic_vector(channel_width-1 downto 0);
        ch2      : in  std_logic_vector(channel_width-1 downto 0);
        ch3      : in  std_logic_vector(channel_width-1 downto 0);
        ch4      : in  std_logic_vector(channel_width-1 downto 0);
        ch5      : in  std_logic_vector(channel_width-1 downto 0);
        ch6      : in  std_logic_vector(channel_width-1 downto 0);
        ch0_out      : out  std_logic_vector((2*channel_width)-1 downto 0);
        ch1_out      : out  std_logic_vector((2*channel_width)-1 downto 0);
        ch2_out      : out  std_logic_vector((2*channel_width)-1 downto 0);
        ch3_out      : out  std_logic_vector((2*channel_width)-1 downto 0);
        ch4_out      : out  std_logic_vector((2*channel_width)-1 downto 0);
        ch5_out      : out  std_logic_vector((2*channel_width)-1 downto 0);
        ch6_out      : out  std_logic_vector((2*channel_width)-1 downto 0);


        diff_valid : out std_logic;
        ch0_pos  : out std_logic_vector(8 downto 0);
        ch1_pos  : out std_logic_vector(8 downto 0);
        ch2_pos  : out std_logic_vector(8 downto 0);
        ch3_pos  : out std_logic_vector(8 downto 0);
        ch4_pos  : out std_logic_vector(8 downto 0);
        ch5_pos  : out std_logic_vector(8 downto 0);
        ch6_pos  : out std_logic_vector(8 downto 0);
 
        -- diff stats
        ch01_diff  : out std_logic_vector(8 downto 0);
        ch02_diff  : out std_logic_vector(8 downto 0);
        ch03_diff  : out std_logic_vector(8 downto 0);
        ch04_diff  : out std_logic_vector(8 downto 0);
        ch05_diff  : out std_logic_vector(8 downto 0);
        ch06_diff  : out std_logic_vector(8 downto 0)
        
    );
end channel_diff_stat;


architecture Behavioral of channel_diff_stat is

 
    -- Zwraca indeks bitu '1' z poprzedzającym (bardziej znaczącym) '0'.
    -- Wejście: std_logic_vector(downto). Brak -> 0.
    function bit_position(vec : std_logic_vector) return integer is
    variable cnt_vec : std_logic_vector(2*channel_width-1 downto 0 );
    begin
        cnt_vec := vec;
        for i in 1 to cnt_vec'length-1 loop
            if (cnt_vec(i) = '1') and (cnt_vec(i-1) = '0') then
                return i;
            end if;
        end loop;
        return 0;
    end function;
    
    -- Różnica ze znakiem (pos_a - pos_b) w 9 bitach (two's complement)
    function diff(a, b : integer) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(a-b, 9));
    end function;
    


    signal chn_storage0 : std_logic_vector(channel_width-1 downto 0) := (others => '0');
    signal chn_storage1 : std_logic_vector(channel_width-1 downto 0) := (others => '0');
    signal chn_storage2 : std_logic_vector(channel_width-1 downto 0) := (others => '0');
    signal chn_storage3 : std_logic_vector(channel_width-1 downto 0) := (others => '0');
    signal chn_storage4 : std_logic_vector(channel_width-1 downto 0) := (others => '0');
    signal chn_storage5 : std_logic_vector(channel_width-1 downto 0) := (others => '0');
    signal chn_storage6 : std_logic_vector(channel_width-1 downto 0) := (others => '0');
    signal chn_doubleframe0 : std_logic_vector(2*channel_width-1 downto 0) := (others => '0');
    signal chn_doubleframe1 : std_logic_vector(2*channel_width-1 downto 0) := (others => '0');
    signal chn_doubleframe2 : std_logic_vector(2*channel_width-1 downto 0) := (others => '0');
    signal chn_doubleframe3 : std_logic_vector(2*channel_width-1 downto 0) := (others => '0');
    signal chn_doubleframe4 : std_logic_vector(2*channel_width-1 downto 0) := (others => '0');
    signal chn_doubleframe5 : std_logic_vector(2*channel_width-1 downto 0) := (others => '0');
    signal chn_doubleframe6 : std_logic_vector(2*channel_width-1 downto 0) := (others => '0');


    signal pos0 : integer range -256 to 255;  
    signal pos1 : integer range -256 to 255;
    signal pos2 : integer range -256 to 255;
    signal pos3 : integer range -256 to 255;
    signal pos4 : integer range -256 to 255;
    signal pos5 : integer range -256 to 255;
    signal pos6 : integer range -256 to 255;

    signal ch_diff_01 : std_logic_vector(8 downto 0);
    signal ch_diff_02 : std_logic_vector(8 downto 0);
    signal ch_diff_03 : std_logic_vector(8 downto 0);
    signal ch_diff_04 : std_logic_vector(8 downto 0);
    signal ch_diff_05 : std_logic_vector(8 downto 0);
    signal ch_diff_06 : std_logic_vector(8 downto 0);
    
    signal diff_valid_int : std_logic;
    signal resetn_sync : std_logic;    
    signal en_sync: std_logic;
    
begin


    chn_doubleframe0 <= ch0 & chn_storage0;
    chn_doubleframe1 <= ch1 & chn_storage1;
    chn_doubleframe2 <= ch2 & chn_storage2;
    chn_doubleframe3 <= ch3 & chn_storage3;
    chn_doubleframe4 <= ch4 & chn_storage4;
    chn_doubleframe5 <= ch5 & chn_storage5;
    chn_doubleframe6 <= ch6 & chn_storage6;

    pos0 <= bit_position(chn_doubleframe0);
    pos1 <= bit_position(chn_doubleframe1);
    pos2 <= bit_position(chn_doubleframe2);
    pos3 <= bit_position(chn_doubleframe3);
    pos4 <= bit_position(chn_doubleframe4);
    pos5 <= bit_position(chn_doubleframe5);
    pos6 <= bit_position(chn_doubleframe6);

    ch_diff_01 <= diff(pos0, pos1);
    ch_diff_02 <= diff(pos0, pos2);
    ch_diff_03 <= diff(pos0, pos3);
    ch_diff_04 <= diff(pos0, pos4);
    ch_diff_05 <= diff(pos0, pos5);
    ch_diff_06 <= diff(pos0, pos6);
    
   -- sync reset
--   xpm_cdc_async_rst_inst : xpm_cdc_async_rst
--   generic map (
--      DEST_SYNC_FF => 2,    -- DECIMAL; range: 2-10
--      INIT_SYNC_FF => 0,    -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
--      RST_ACTIVE_HIGH => 0  -- DECIMAL; 0=active low reset, 1=active high reset
--   )
--   port map (
--      dest_arst => resetn_sync, -- 1-bit output: src_arst asynchronous reset signal synchronized to destination
--                              -- clock domain. This output is registered. NOTE: Signal asserts asynchronously
--                              -- but deasserts synchronously to dest_clk. Width of the reset signal is at least
--                              -- (DEST_SYNC_FF*dest_clk) period.

--      dest_clk => clk,   -- 1-bit input: Destination clock.
--      src_arst => resetn    -- 1-bit input: Source asynchronous reset signal.
--   );

    xpm_cdc_en : xpm_cdc_single
    generic map (
        DEST_SYNC_FF => 2,
        SRC_INPUT_REG => 1
    )
    port map (
        src_clk  => aclk, 
        src_in   => en,
        dest_clk => clk,
        dest_out => en_sync
    );
    
   -- main : process(clk, resetn)
   main : process(clk)

    begin
        if rising_edge(clk) then

            if resetn = '0' then
                diff_valid_int <= '0';

                chn_storage0 <= (others =>'0');
                chn_storage1 <= (others =>'0');
                chn_storage2 <= (others =>'0');
                chn_storage3 <= (others =>'0');
                chn_storage4 <= (others =>'0');
                chn_storage5 <= (others =>'0');
                chn_storage6 <= (others =>'0');

                ch0_out <= (others =>'0');
                ch1_out <= (others =>'0');
                ch2_out <= (others =>'0');
                ch3_out <= (others =>'0');
                ch4_out <= (others =>'0');
                ch5_out <= (others =>'0');
                ch6_out <= (others =>'0');


                ch0_pos <= (others =>'0'); 
                ch1_pos <= (others =>'0'); 
                ch2_pos <= (others =>'0'); 
                ch3_pos <= (others =>'0'); 
                ch4_pos <= (others =>'0'); 
                ch5_pos <= (others =>'0'); 
                ch6_pos <= (others =>'0'); 

                ch01_diff <= (others =>'0');
                ch02_diff <= (others =>'0');
                ch03_diff <= (others =>'0');
                ch04_diff <= (others =>'0');
                ch05_diff <= (others =>'0');
                ch06_diff <= (others =>'0');   
                
            else
                chn_storage0 <= ch0;
                chn_storage1 <= ch1;
                chn_storage2 <= ch2;
                chn_storage3 <= ch3;
                chn_storage4 <= ch4;
                chn_storage5 <= ch5;
                chn_storage6 <= ch6;

                ch0_out <= chn_doubleframe0; 
                ch1_out <= chn_doubleframe1;
                ch2_out <= chn_doubleframe2;
                ch3_out <= chn_doubleframe3;
                ch4_out <= chn_doubleframe4;
                ch5_out <= chn_doubleframe5;
                ch6_out <= chn_doubleframe6;


                ch0_pos <= std_logic_vector(to_signed(pos0,9)); 
                ch1_pos <= std_logic_vector(to_signed(pos1,9)); 
                ch2_pos <= std_logic_vector(to_signed(pos2,9)); 
                ch3_pos <= std_logic_vector(to_signed(pos3,9)); 
                ch4_pos <= std_logic_vector(to_signed(pos4,9)); 
                ch5_pos <= std_logic_vector(to_signed(pos5,9)); 
                ch6_pos <= std_logic_vector(to_signed(pos6,9)); 

                ch01_diff <= ch_diff_01;
                ch02_diff <= ch_diff_02;
                ch03_diff <= ch_diff_03;
                ch04_diff <= ch_diff_04;
                ch05_diff <= ch_diff_05;
                ch06_diff <= ch_diff_06;

                if ((pos0 > 0) and (pos1 > 0) and (pos2 > 0) and
                    (pos3 > 0) and (pos4 > 0) and (pos5 > 0) and (pos6 > 0)) 
                    and en_sync = '1' and diff_valid_int='0' then
                    diff_valid_int <= '1';
                else
                    diff_valid_int <= '0';
                end if;

            end if;
       
        end if;   
    end process;
    
    diff_valid <= diff_valid_int;
    

end Behavioral;
    