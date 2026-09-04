-- Andrzej Wojenski, Warsaw University of Technology
-- Updates to support one quad per IP for using LOC constraints

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity gth_splitter_clk is
    generic (
        -- version for splitted GTH for fixing LOC placement
        -- this nneds to be divided into lower number of ports to support quads
        TOTAL_WIDTH : integer := 560;
        NUM_OUTPUTS : integer := 7;
        SEGMENT_WIDTH : integer := 80
    );
    port (
        aclk : in std_logic;
        input_vector : in  std_logic_vector(TOTAL_WIDTH - 1 downto 0);
        output_0     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_1     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_2     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_3     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_4     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_5     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_6     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0)
    );
end gth_splitter_clk;

architecture Behavioral of gth_splitter_clk is

type splitter_array_t is array (0 to NUM_OUTPUTS-1) of std_logic_vector(SEGMENT_WIDTH-1 downto 0);
signal splitter_array : splitter_array_t;
begin

  
    splitter_gen: for i in 0 to NUM_OUTPUTS-1 generate
        splitter_array(i) <= input_vector((i+1)*SEGMENT_WIDTH-1 downto i*SEGMENT_WIDTH);
    end generate;
    
    -- TODO IDEAS
    -- to obtain maybe more stability, for the first 2 regs (make extra) lets make a process with async regs
    -- and those lets place by loc constraints next to GTH RX/CHx blocks
    
    -- how those 80bits are done in GTH component?
    
    -- what comes from a channel is directly:
    -- rxctrl0 [15:0]
    -- rxctrl1 [15:0]
    -- rxdata [127:0]
    
    -- from other the same
    -- rxctrl0 [15:0]
    -- rxctrl1 [15:0]
    -- rxdata [127:0]
     
    regs_p: process(aclk)
    begin
        if rising_edge(aclk) then
            output_0 <= splitter_array(0);
            output_1 <= splitter_array(1);
            output_2 <= splitter_array(2);
            if (NUM_OUTPUTS > 3) then
                output_3 <= splitter_array(3);
            else
                output_3 <= (others => '0');
            end if;
            if (NUM_OUTPUTS > 4) then
                output_4 <= splitter_array(4);
            else
                output_4 <= (others => '0');
            end if;
            if (NUM_OUTPUTS > 5) then
                output_5 <= splitter_array(5);
            else
                output_5 <= (others => '0');
            end if;
            
            if (NUM_OUTPUTS > 6) then
                output_6 <= splitter_array(6);
            else
                output_6 <= (others => '0');
            end if;
        end if;
    end process;
    
end Behavioral;