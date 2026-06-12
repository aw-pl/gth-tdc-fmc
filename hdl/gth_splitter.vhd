----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/23/2025 07:35:55 PM
-- Design Name: 
-- Module Name: gth_splitter - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity gth_splitter is
    generic (
        TOTAL_WIDTH : integer := 560;
        NUM_OUTPUTS : integer := 7;
        SEGMENT_WIDTH : integer := 80
    );
    port (
        input_vector : in  std_logic_vector(TOTAL_WIDTH - 1 downto 0);
        output_0     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_1     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_2     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_3     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_4     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_5     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0);
        output_6     : out std_logic_vector(SEGMENT_WIDTH - 1 downto 0)
    );
end gth_splitter;

architecture Behavioral of gth_splitter is

type splitter_array_t is array (0 to NUM_OUTPUTS-1) of std_logic_vector(SEGMENT_WIDTH-1 downto 0);
signal splitter_array : splitter_array_t;

function reverse_bits(v : std_logic_vector) return std_logic_vector is
    variable r : std_logic_vector(0 to v'length-1);
begin
    for i in 0 to v'length-1 loop
        r(i) := v(v'low + (v'length-1 - i));
    end loop;
    return r;
end function;

begin

  
    splitter_gen: for i in 0 to NUM_OUTPUTS-1 generate
        splitter_array(i) <= input_vector((i+1)*SEGMENT_WIDTH-1 downto i*SEGMENT_WIDTH);
    end generate;

    output_0 <= splitter_array(0);
    output_1 <= splitter_array(1);
    output_2 <= splitter_array(2);
    output_3 <= splitter_array(3);
    output_4 <= splitter_array(4);
    output_5 <= splitter_array(5);
    output_6 <= splitter_array(6);
    -- output_0 <= reverse_bits(splitter_array(0));
    -- output_1 <= reverse_bits(splitter_array(1));
    -- output_2 <= reverse_bits(splitter_array(2));
    -- output_3 <= reverse_bits(splitter_array(3));
    -- output_4 <= reverse_bits(splitter_array(4));
    -- output_5 <= reverse_bits(splitter_array(5));
    -- output_6 <= reverse_bits(splitter_array(6));
    
end Behavioral;
