----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/02/2025 05:46:53 PM
-- Design Name: 
-- Module Name: spi_mux - Behavioral
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

entity spi_mux is
port(

i_mosi : in std_logic;
o_miso : out std_logic;
i_sclk  : in std_logic;
i_ss : in STD_LOGIC_VECTOR(1 DOWNTO 0);


io0 : INOUT STD_LOGIC;
io1 : INOUT STD_LOGIC;
sck : OUT STD_LOGIC;
ss0 : OUT STD_LOGIC;
ss1 : OUT STD_LOGIC
);
end spi_mux;

architecture Behavioral of spi_mux is

signal io0_i_iobuf : STD_LOGIC;
signal io0_o_iobuf : STD_LOGIC;
signal io0_t_iobuf : STD_LOGIC;

signal io1_i_iobuf : STD_LOGIC;
signal io1_o_iobuf : STD_LOGIC;
signal io1_t_iobuf : STD_LOGIC;

signal ss0_not : std_logic;

begin
    -- case pll io0-as-miso  io1-as-mosi  ss0
    -- case dac io0-as-mosi  io1-as-miso  ss1
    ss0_not <= i_ss(0);
    
    -- DAC CASE
    io0_i_iobuf <=  i_mosi;
    -- PLL CASE
    io1_i_iobuf <=  i_mosi;           
    
    -- PLL/DAC TRISTATE CTRL t = 1 input t = 0 output
    io0_t_iobuf <=  '1' when i_ss(0) = '1' and i_ss(1) = '1' else -- PLL  
                    '0' when i_ss(1) = '0' and i_ss(0) = '0' else -- DAC
                    '1'; -- safety input -> High Z on both           

    io1_t_iobuf <=  '0' when i_ss(0) = '1' and i_ss(1) = '1' else -- PLL
                    '1' when i_ss(1) = '0' and i_ss(0) = '0' else -- DAC
                    '1'; -- safety input -> High Z on both
    -- PLL/DAC MISO Control
    o_miso <=       io0_o_iobuf when i_ss(0) = '1' and i_ss(1) = '1' else --PLL
                    io1_o_iobuf when i_ss(1) = '0' and i_ss(0) = '0' else --DAC
                    '0';
    
    

    IO0_inst : IOBUF
    port map (
        O => io0_o_iobuf,     -- Buffer output
        IO => io0,   -- Buffer inout port (connect directly to top-level port)
        I => io0_i_iobuf,     -- Buffer input
        T => io0_t_iobuf      -- 3-state enable input, high=input, low=output 
    );

    IO1_inst : IOBUF
    port map (
        O => io1_o_iobuf,     -- Buffer output
        IO => io1,   -- Buffer inout port (connect directly to top-level port)
        I => io1_i_iobuf,     -- Buffer input
        T => io1_t_iobuf      -- 3-state enable input, high=input, low=output 
    );

    SCLK_inst : OBUF
    port map (
        O => sck,     -- Buffer output (connect directly to top-level port)
        I => i_sclk      -- Buffer input 
    );

    SS0_inst : OBUF
    port map (
        O => ss0,     -- Buffer output (connect directly to top-level port)
        I => ss0_not      -- Buffer input 
    );

    SS1_inst : OBUF
    port map (
        O => ss1,     -- Buffer output (connect directly to top-level port)
        I => i_ss(1)      -- Buffer input 
    );
end Behavioral;
