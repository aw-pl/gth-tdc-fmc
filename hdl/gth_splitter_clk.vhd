----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/23/2025 10:51:21 PM
-- Design Name: 
-- Module Name: gth_splitter_clk - Behavioral
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

entity gth_splitter_clk is
    generic (
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
    
    regs_p: process(aclk)
    begin
        if rising_edge(aclk) then
            output_0 <= splitter_array(0);
            output_1 <= splitter_array(1);
            output_2 <= splitter_array(2);
            output_3 <= splitter_array(3);
            output_4 <= splitter_array(4);
            output_5 <= splitter_array(5);
            output_6 <= splitter_array(6);
        end if;
    end process;
        

    
end Behavioral;