-- Andrzej Wojenski, Warsaw University of Technology
-- Keep this separate since we want diff_stat to be LOC near GTH
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

Library xpm;
use xpm.vcomponents.all;

entity channel_minmax_stat is
    port (
        clk     : in  std_logic;
        aclk     : in  std_logic;
        resetn  : in  std_logic;
        en       : in std_logic;

        -- control signals        
        ch_hist_idle : in std_logic;
        ch_hist_finished : in std_logic;
         
        -- diff stats
        diff_valid : in std_logic;
        
        ch01_diff  :in std_logic_vector(8 downto 0);
        ch02_diff  :in std_logic_vector(8 downto 0);
        ch03_diff  :in std_logic_vector(8 downto 0);
        ch04_diff  :in std_logic_vector(8 downto 0);
        ch05_diff  :in std_logic_vector(8 downto 0);
        ch06_diff  :in std_logic_vector(8 downto 0);
        
        ch01_min  : out std_logic_vector(8 downto 0);        
        ch02_min  : out std_logic_vector(8 downto 0);
        ch03_min  : out std_logic_vector(8 downto 0);
        ch04_min  : out std_logic_vector(8 downto 0);
        ch05_min  : out std_logic_vector(8 downto 0);
        ch06_min  : out std_logic_vector(8 downto 0);

        ch01_max  : out std_logic_vector(8 downto 0); 
        ch02_max  : out std_logic_vector(8 downto 0); 
        ch03_max  : out std_logic_vector(8 downto 0); 
        ch04_max  : out std_logic_vector(8 downto 0); 
        ch05_max  : out std_logic_vector(8 downto 0); 
        ch06_max  : out std_logic_vector(8 downto 0); 
       
        ch01_minmax  : out std_logic_vector(31 downto 0);        
        ch02_minmax  : out std_logic_vector(31 downto 0);
        ch03_minmax  : out std_logic_vector(31 downto 0);
        ch04_minmax  : out std_logic_vector(31 downto 0);
        ch05_minmax  : out std_logic_vector(31 downto 0);
        ch06_minmax  : out std_logic_vector(31 downto 0)
        
    );

end channel_minmax_stat;

architecture Behavioral of channel_minmax_stat is

    signal resetn_sync : std_logic;    
    signal en_sync: std_logic;
    
    -- min/max section
    constant NUM_SIGNALS : integer := 6;

    type data_array_t is array (0 to NUM_SIGNALS-1)
        of signed(8 downto 0);
        --of integer range -256 to 255;  
        
    signal pos_array : data_array_t;
    signal min_reg   : data_array_t;
    signal max_reg   : data_array_t;

begin

    pos_array <= (
        0 => signed(ch01_diff), -- or ch01_diff
        1 => signed(ch02_diff),
        2 => signed(ch03_diff),
        3 => signed(ch04_diff),
        4 => signed(ch05_diff),
        5 => signed(ch06_diff)                
    );   
    
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

            if resetn = '0' or ch_hist_idle = '1' then -- we reset module when it's not measuring
            
                for i in 0 to NUM_SIGNALS-1 loop
                    min_reg(i) <= to_signed(255, 9); --   255;
                    max_reg(i) <= to_signed(-256, 9); -- -256;                    
                end loop;
                
            else
                -- works only if histograms are working, so from channel hist we take 
                -- IDLE as reset
                -- FINISHED as done
                if (en_sync = '1' and diff_valid = '1' and ch_hist_finished = '0') then
                        -- storing min/max values of the DIFF (since position will always be different)
                        -- assuming that pos values are always expected to be the same                
                        for i in 0 to NUM_SIGNALS-1 loop
                            --if pos_array(i) < min_reg(i) and pos_array(i) /= 0 then
                            if pos_array(i) < min_reg(i) then
                                min_reg(i) <= pos_array(i);
                            end if;
                        
                            --if pos_array(i) > max_reg(i) and pos_array(i) /= 0  then
                            if pos_array(i) > max_reg(i) then
                                max_reg(i) <= pos_array(i);
                            end if;
                        end loop;
                end if;

            end if;
       
        end if;   
    end process;

--    -- mapping to output ports
    ch01_minmax <= std_logic_vector(resize(max_reg(0), 16)) &
                  std_logic_vector(resize (min_reg(0), 16));  
                  
    ch02_minmax <= std_logic_vector(resize(max_reg(1), 16)) &
                   std_logic_vector(resize(min_reg(1), 16));
                 
    ch03_minmax <= std_logic_vector(resize(max_reg(2), 16)) &
                  std_logic_vector(resize (min_reg(2), 16));
                  
    ch04_minmax <= std_logic_vector(resize(max_reg(3), 16)) &
                  std_logic_vector(resize (min_reg(3), 16));  
                                  
    ch05_minmax <= std_logic_vector(resize(max_reg(4), 16)) &
                  std_logic_vector(resize (min_reg(4), 16));
                  
    ch06_minmax <= std_logic_vector(resize(max_reg(5), 16)) &
                  std_logic_vector(resize (min_reg(5), 16)); 
                                   

    ch01_min <= std_logic_vector(min_reg(0));
    ch02_min <= std_logic_vector(min_reg(1)); 
    ch03_min <= std_logic_vector(min_reg(2)); 
    ch04_min <= std_logic_vector(min_reg(3)); 
    ch05_min <= std_logic_vector(min_reg(4)); 
    ch06_min <= std_logic_vector(min_reg(5)); 
            
    ch01_max <= std_logic_vector(max_reg(0));
    ch02_max <= std_logic_vector(max_reg(1));  
    ch03_max <= std_logic_vector(max_reg(2));  
    ch04_max <= std_logic_vector(max_reg(3));  
    ch05_max <= std_logic_vector(max_reg(4));  
    ch06_max <= std_logic_vector(max_reg(5));  
                   
end Behavioral;
