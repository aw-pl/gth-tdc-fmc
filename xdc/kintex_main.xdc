# ===============================
# Clocks - AFCKU
# ===============================
set_property IOSTANDARD DIFF_SSTL15 [get_ports fpga_clk1_p]
set_property PACKAGE_PIN AF9 [get_ports fpga_clk1_p]
set_property PACKAGE_PIN AG9 [get_ports fpga_clk1_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports fpga_clk1_n]

# ===============================
# Clocks - AFCKU
# ===============================
# not used since duplicated constraint by CLKWIZ
# 125 MHz default clock
#create_clock -period 8.000 -name fpga_clk1_p [get_ports fpga_clk1_p]
# ===============================
# Clocks - FMC
# ===============================
create_clock -period 6.400 -name GBTCLK0_M2C_P -waveform {0.000 3.200} [get_ports GBTCLK0_M2C_P]

set_clock_groups -name axi_gth_async_group -asynchronous -group [get_clocks -of_objects [get_pins design_1_i/clk_wiz_0/inst/mmcme3_adv_inst/CLKOUT0]] -group [get_clocks -of_objects [get_pins design_1_i/gth_wrapper_0/U0/u_gtwizard_ultrascale_0/inst/gen_gtwizard_gthe3_top.gtwizard_ultrascale_0_gtwizard_gthe3_inst/gen_gtwizard_gthe3.gen_rx_user_clocking_internal.gen_single_instance.gtwiz_userclk_rx_inst/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O]]

# ===============================
# TDC-GTH - valid
# ===============================
set_property PACKAGE_PIN P5 [get_ports GBTCLK0_M2C_N]
set_property PACKAGE_PIN P6 [get_ports GBTCLK0_M2C_P]

#set_property PACKAGE_PIN K1  [get_ports {gthrxn_in_0[0]}]
#set_property PACKAGE_PIN K2  [get_ports {gthrxp_in_0[0]}]

#set_property PACKAGE_PIN H1  [get_ports {gthrxn_in_0[1]}]
#set_property PACKAGE_PIN H2  [get_ports {gthrxp_in_0[1]}]

#set_property PACKAGE_PIN F1  [get_ports {gthrxn_in_0[2]}]
#set_property PACKAGE_PIN F2  [get_ports {gthrxp_in_0[2]}]

#set_property PACKAGE_PIN Y1  [get_ports {gthrxn_in_0[3]}]
#set_property PACKAGE_PIN Y2  [get_ports {gthrxp_in_0[3]}]

#set_property PACKAGE_PIN V1  [get_ports {gthrxn_in_0[4]}]
#set_property PACKAGE_PIN V2  [get_ports {gthrxp_in_0[4]}]

#set_property PACKAGE_PIN T1  [get_ports {gthrxn_in_0[5]}]
#set_property PACKAGE_PIN T2  [get_ports {gthrxp_in_0[5]}]

#set_property PACKAGE_PIN P1  [get_ports {gthrxn_in_0[6]}]
#set_property PACKAGE_PIN P2  [get_ports {gthrxp_in_0[6]}]


# ===============================
# UART Interface - valid
# ===============================
set_property PACKAGE_PIN F27 [get_ports uart_fmc_tx]
set_property IOSTANDARD LVCMOS18 [get_ports uart_fmc_tx]
set_property PACKAGE_PIN C27 [get_ports uart_fmc_rx]
set_property IOSTANDARD LVCMOS18 [get_ports uart_fmc_rx]


## LA20_P -> TX
#set_property PACKAGE_PIN AG31 [get_ports uart_fmc_tx]
#set_property IOSTANDARD LVCMOS18 [get_ports uart_fmc_tx]
#set_property PACKAGE_PIN V33 [get_ports uart_fmc_rx]
#set_property IOSTANDARD LVCMOS18 [get_ports uart_fmc_rx]



set_property PACKAGE_PIN AP29 [get_ports uart_pri_tx]
set_property IOSTANDARD LVCMOS18 [get_ports uart_pri_tx]
set_property PACKAGE_PIN AP28 [get_ports uart_pri_rx]
set_property IOSTANDARD LVCMOS18 [get_ports uart_pri_rx]

# ===============================
# DAC RST - valid
# ===============================
#D14 HA22_P -> TDC_DAC_RST
set_property PACKAGE_PIN D14 [get_ports {DAC_RST_tri_io[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {DAC_RST_tri_io[0]}]
# ===============================
# CONTROL Signals PLL - valid
# ===============================
# B15 HA18_P -> RESET
# B19 HA19_N -> CLK_SEL0
# C19 HA19_P -> CLK_SEL1
# C18 HA20_P -> STATUS_LD1
# C17 HA20_N -> STATUS_LD2
set_property PACKAGE_PIN B19 [get_ports {PLL_CTRL_tri_io[1]}]
set_property PACKAGE_PIN C19 [get_ports {PLL_CTRL_tri_io[2]}]
set_property PACKAGE_PIN C18 [get_ports {PLL_CTRL_tri_io[3]}]
set_property PACKAGE_PIN C17 [get_ports {PLL_CTRL_tri_io[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {PLL_CTRL_tri_io[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {PLL_CTRL_tri_io[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {PLL_CTRL_tri_io[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {PLL_CTRL_tri_io[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {PLL_CTRL_tri_io[0]}]
# ===============================
# SYNCSE
# ===============================
#C11 HB07_P -> !SYNCSE
# ===============================
# ADC CONTROL - valid
# ===============================
# E10 HB08_P -> PD
# F8  HB10_P -> CALTRIG
# D9  HB11_P -> ORA0
# J8  HB12_P -> ORA1
# L12 HB14_P -> ORB0
# L13 HB15_P -> ORB1
# K10 HB18_P -> CALSTAT
set_property PACKAGE_PIN E10 [get_ports {gpio_o_adc_ctrl[0]}]
set_property PACKAGE_PIN F8 [get_ports {gpio_o_adc_ctrl[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {gpio_o_adc_ctrl[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {gpio_o_adc_ctrl[0]}]
# ===============================
# IIC - valid
# ===============================
set_property PACKAGE_PIN Y22 [get_ports FMC_I2C_sda_io]
set_property PACKAGE_PIN Y21 [get_ports FMC_I2C_scl_io]
set_property IOSTANDARD LVCMOS18 [get_ports FMC_I2C_scl_io]
set_property IOSTANDARD LVCMOS18 [get_ports FMC_I2C_sda_io]
# ===============================
# PLL/DAC SPI Interface - valid
# ===============================
# F18 HA17_CC_P -> SCK
# L19 HA14_P -> SDI
# J19 HA15_P -> SDO
# A19 HA21_P -> SS PLL
# B14 HA23_P -> SS DAC
set_property PACKAGE_PIN F18 [get_ports sck_0]
set_property PACKAGE_PIN L19 [get_ports io0_0]
set_property PACKAGE_PIN J19 [get_ports io1_0]
set_property PACKAGE_PIN A19 [get_ports ss0_0]
set_property PACKAGE_PIN B14 [get_ports ss1_0]
set_property IOSTANDARD LVCMOS18 [get_ports io0_0]
set_property IOSTANDARD LVCMOS18 [get_ports io1_0]
set_property IOSTANDARD LVCMOS18 [get_ports sck_0]
set_property IOSTANDARD LVCMOS18 [get_ports ss0_0]
set_property IOSTANDARD LVCMOS18 [get_ports ss1_0]
# ===============================
# ADC SPI Interface - valid
# ===============================
# E28 LA19_P -> SCS
# T22 LA14_P -> SDI
# U26 LA15_P -> SDO
# U24 LA16_P -> SCK
set_property PACKAGE_PIN E28 [get_ports {SPI_ADC_ss_io[0]}]
set_property PACKAGE_PIN T22 [get_ports SPI_ADC_io0_io]
set_property PACKAGE_PIN U26 [get_ports SPI_ADC_io1_io]
set_property PACKAGE_PIN U24 [get_ports SPI_ADC_sck_io]
set_property IOSTANDARD LVCMOS18 [get_ports {SPI_ADC_ss_io[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports SPI_ADC_io0_io]
set_property IOSTANDARD LVCMOS18 [get_ports SPI_ADC_io1_io]
set_property IOSTANDARD LVCMOS18 [get_ports SPI_ADC_sck_io]

## ===============================
## ADC CLOCK differential pair for PORTA - valid
## ===============================
#set_property PACKAGE_PIN W23 [get_ports portA_adcclk_in_p];   # LA00_CC_P -> CLK_P
#set_property IOSTANDARD LVDS [get_ports portA_adcclk_in_p];
#set_property PACKAGE_PIN W24 [get_ports portA_adcclk_in_n];   # LA00_CC_N -> CLK_N
#set_property IOSTANDARD LVDS [get_ports portA_adcclk_in_n];
## ===============================
## STROBE differential pair for PORTA - valid
## ===============================
#set_property PACKAGE_PIN AA24 [get_ports portA_strobe_in_p];   # LA01_CC_P -> STR_P
#set_property IOSTANDARD LVDS [get_ports portA_strobe_in_p];
#set_property PACKAGE_PIN AA25 [get_ports portA_strobe_in_n];   # LA01_CC_N -> STR_N
#set_property IOSTANDARD LVDS [get_ports portA_strobe_in_n];
## ===============================
## DATA differential pairs for PORTA - valid
## ===============================
## Bit 0
#set_property PACKAGE_PIN Y26 [get_ports {portA_data_in_p[0]}]; # LA05_P -> D0_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[0]}];
#set_property PACKAGE_PIN Y27 [get_ports {portA_data_in_n[0]}]; # LA05_N -> D0_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[0]}];
## Bit 1
#set_property PACKAGE_PIN AC26 [get_ports {portA_data_in_p[1]}]; # LA04_P -> D1_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[1]}];
#set_property PACKAGE_PIN AC27 [get_ports {portA_data_in_n[1]}]; # LA04_N -> D1_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[1]}];
## Bit 2
#set_property PACKAGE_PIN AB24 [get_ports {portA_data_in_p[2]}]; # LA03_P -> D2_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[2]}];
#set_property PACKAGE_PIN AC24 [get_ports {portA_data_in_n[2]}]; # LA03_N -> D2_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[2]}];
## Bit 3
#set_property PACKAGE_PIN AA27 [get_ports {portA_data_in_p[3]}]; # LA06_P -> D3_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[3]}];
#set_property PACKAGE_PIN AB27 [get_ports {portA_data_in_n[3]}]; # LA06_N -> D3_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[3]}];
## Bit 4
#set_property PACKAGE_PIN AD25 [get_ports {portA_data_in_p[4]}]; # LA02_P -> D4_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[4]}];
#set_property PACKAGE_PIN AD26 [get_ports {portA_data_in_n[4]}]; # LA02_N -> D4_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[4]}];
## Bit 5
#set_property PACKAGE_PIN W28 [get_ports {portA_data_in_p[5]}]; # LA08_P -> D5_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[5]}];
#set_property PACKAGE_PIN Y28 [get_ports {portA_data_in_n[5]}]; # LA08_N -> D5_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[5]}];
## Bit 6
#set_property PACKAGE_PIN V26 [get_ports {portA_data_in_p[6]}]; # LA07_P -> D6_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[6]}];
#set_property PACKAGE_PIN W26 [get_ports {portA_data_in_n[6]}]; # LA07_N -> D6_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[6]}];
## Bit 7
#set_property PACKAGE_PIN V22 [get_ports {portA_data_in_p[7]}]; # LA09_P -> D7_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[7]}];
#set_property PACKAGE_PIN V23 [get_ports {portA_data_in_n[7]}]; # LA09_N -> D7_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[7]}];
## Bit 8
#set_property PACKAGE_PIN V29 [get_ports {portA_data_in_p[8]}]; # LA12_P -> D8_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[8]}];
#set_property PACKAGE_PIN W29 [get_ports {portA_data_in_n[8]}]; # LA12_N -> D8_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[8]}];
## Bit 9
#set_property PACKAGE_PIN V21 [get_ports {portA_data_in_p[9]}]; # LA11_P -> D9_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[9]}];
#set_property PACKAGE_PIN W21 [get_ports {portA_data_in_n[9]}]; # LA11_N -> D9_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[9]}];
## Bit 10
#set_property PACKAGE_PIN V27 [get_ports {portA_data_in_p[10]}]; # LA10_P -> D10_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[10]}];
#set_property PACKAGE_PIN V28 [get_ports {portA_data_in_n[10]}]; # LA10_N -> D10_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[10]}];
## Bit 11
#set_property PACKAGE_PIN U21 [get_ports {portA_data_in_p[11]}]; # LA13_P -> D11_P
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_p[11]}];
#set_property PACKAGE_PIN U22 [get_ports {portA_data_in_n[11]}]; # LA13_N -> D11_N
#set_property IOSTANDARD LVDS [get_ports {portA_data_in_n[11]}];

## ===============================
## ADC CLOCK differential pair for PORTB - valid
## ===============================
#set_property PACKAGE_PIN E25 [get_ports portB_adcclk_in_p];   # LA17_CC_P -> CLK_P
#set_property IOSTANDARD LVDS [get_ports portB_adcclk_in_p];
#set_property PACKAGE_PIN D25 [get_ports portB_adcclk_in_n];   # LA17_CC_N -> CLK_N
#set_property IOSTANDARD LVDS [get_ports portB_adcclk_in_n];
## ===============================
## STROBE differential pair for PORTB - valid
## ===============================
#set_property PACKAGE_PIN D24 [get_ports portB_strobe_in_p];   # LA18_CC_P -> STR_P
#set_property IOSTANDARD LVDS [get_ports portB_strobe_in_p];
#set_property PACKAGE_PIN C24 [get_ports portB_strobe_in_n];   # LA18_CC_N -> STR_N
#set_property IOSTANDARD LVDS [get_ports portB_strobe_in_n];
## ===============================
## DATA differential pairs for PORTB - valid
## ===============================
## Bit 0
#set_property PACKAGE_PIN B25 [get_ports {portB_data_in_p[0]}]; # LA31_P -> D0_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[0]}];
#set_property PACKAGE_PIN A25 [get_ports {portB_data_in_n[0]}]; # LA31_N -> D0_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[0]}];
## Bit 1
#set_property PACKAGE_PIN A27 [get_ports {portB_data_in_p[1]}]; # LA29_P -> D1_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[1]}];
#set_property PACKAGE_PIN A28 [get_ports {portB_data_in_n[1]}]; # LA29_N -> D1_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[1]}];
## Bit 2
#set_property PACKAGE_PIN C26 [get_ports {portB_data_in_p[2]}]; # LA28_P -> D2_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[2]}];
#set_property PACKAGE_PIN B26 [get_ports {portB_data_in_n[2]}]; # LA28_N -> D2_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[2]}];
## Bit 3
#set_property PACKAGE_PIN B24 [get_ports {portB_data_in_p[3]}]; # LA30_P -> D3_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[3]}];
#set_property PACKAGE_PIN A24 [get_ports {portB_data_in_n[3]}]; # LA30_N -> D3_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[3]}];
## Bit 4
#set_property PACKAGE_PIN B20 [get_ports {portB_data_in_p[4]}]; # LA32_P -> D4_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[4]}];
#set_property PACKAGE_PIN A20 [get_ports {portB_data_in_n[4]}]; # LA32_N -> D4_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[4]}];
## Bit 5
#set_property PACKAGE_PIN B29 [get_ports {portB_data_in_p[5]}]; # LA24_P -> D5_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[5]}];
#set_property PACKAGE_PIN A29 [get_ports {portB_data_in_n[5]}]; # LA24_N -> D5_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[5]}];
## Bit 6
#set_property PACKAGE_PIN B21 [get_ports {portB_data_in_p[6]}]; # LA33_P -> D6_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[6]}];
#set_property PACKAGE_PIN B22 [get_ports {portB_data_in_n[6]}]; # LA33_N -> D6_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[6]}];
## Bit 7
#set_property PACKAGE_PIN C21 [get_ports {portB_data_in_p[7]}]; # LA27_P -> D7_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[7]}];
#set_property PACKAGE_PIN C22 [get_ports {portB_data_in_n[7]}]; # LA27_N -> D7_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[7]}];
## Bit 8
#set_property PACKAGE_PIN D28 [get_ports {portB_data_in_p[8]}]; # LA21_P -> D8_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[8]}];
#set_property PACKAGE_PIN C28 [get_ports {portB_data_in_n[8]}]; # LA21_N -> D8_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[8]}];
## Bit 9
#set_property PACKAGE_PIN E22 [get_ports {portB_data_in_p[9]}]; # LA22_P -> D9_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[9]}];
#set_property PACKAGE_PIN E23 [get_ports {portB_data_in_n[9]}]; # LA22_N -> D9_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[9]}];
## Bit 10
#set_property PACKAGE_PIN D20 [get_ports {portB_data_in_p[10]}]; # LA26_P -> D10_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[10]}];
#set_property PACKAGE_PIN D21 [get_ports {portB_data_in_n[10]}]; # LA26_N -> D10_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[10]}];
## Bit 11
#set_property PACKAGE_PIN D23 [get_ports {portB_data_in_p[11]}]; # LA23_P -> D11_P
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_p[11]}];
#set_property PACKAGE_PIN C23 [get_ports {portB_data_in_n[11]}]; # LA23_N -> D11_N
#set_property IOSTANDARD LVDS [get_ports {portB_data_in_n[11]}];

## ===============================
## ADC CLOCK differential pair for PORTC - valid
## ===============================
#set_property PACKAGE_PIN E16 [get_ports portC_adcclk_in_p];   # HA01_CC_P -> CLK_P
#set_property IOSTANDARD LVDS [get_ports portC_adcclk_in_p];
#set_property PACKAGE_PIN D16 [get_ports portC_adcclk_in_n];   # HA01_CC_N -> CLK_N
#set_property IOSTANDARD LVDS [get_ports portC_adcclk_in_n];
## ===============================
## STROBE differential pair for PORTC - valid
## ===============================
#set_property PACKAGE_PIN G17 [get_ports portC_strobe_in_p];   # HA00_CC_P -> STR_P
#set_property IOSTANDARD LVDS [get_ports portC_strobe_in_p];
#set_property PACKAGE_PIN G16 [get_ports portC_strobe_in_n];   # HA00_CC_N -> STR_N
#set_property IOSTANDARD LVDS [get_ports portC_strobe_in_n];
## ===============================
## DATA differential pairs for PORTC - valid
## ===============================
## Bit 0
#set_property PACKAGE_PIN K18 [get_ports {portC_data_in_p[0]}]; # HA10_P -> D0_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[0]}];
#set_property PACKAGE_PIN K17 [get_ports {portC_data_in_n[0]}]; # HA10_N -> D0_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[0]}];
## Bit 1
#set_property PACKAGE_PIN K16 [get_ports {portC_data_in_p[1]}]; # HA04_P -> D1_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[1]}];
#set_property PACKAGE_PIN J16 [get_ports {portC_data_in_n[1]}]; # HA04_N -> D1_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[1]}];
## Bit 2
#set_property PACKAGE_PIN B17 [get_ports {portC_data_in_p[2]}]; # HA11_P -> D2_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[2]}];
#set_property PACKAGE_PIN B16 [get_ports {portC_data_in_n[2]}]; # HA11_N -> D2_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[2]}];
## Bit 3
#set_property PACKAGE_PIN E15 [get_ports {portC_data_in_p[3]}]; # HA06_P -> D3_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[3]}];
#set_property PACKAGE_PIN D15 [get_ports {portC_data_in_n[3]}]; # HA06_N -> D3_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[3]}];
## Bit 4
#set_property PACKAGE_PIN G15 [get_ports {portC_data_in_p[4]}]; # HA07_P -> D4_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[4]}];
#set_property PACKAGE_PIN G14 [get_ports {portC_data_in_n[4]}]; # HA07_N -> D4_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[4]}];
## Bit 5
#set_property PACKAGE_PIN H17 [get_ports {portC_data_in_p[5]}]; # HA02_P -> D5_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[5]}];
#set_property PACKAGE_PIN H16 [get_ports {portC_data_in_n[5]}]; # HA02_N -> D5_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[5]}];
## Bit 6
#set_property PACKAGE_PIN L15 [get_ports {portC_data_in_p[6]}]; # HA03_P -> D6_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[6]}];
#set_property PACKAGE_PIN K15 [get_ports {portC_data_in_n[6]}]; # HA03_N -> D6_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[6]}];
## Bit 7
#set_property PACKAGE_PIN D19 [get_ports {portC_data_in_p[7]}]; # HA08_P -> D7_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[7]}];
#set_property PACKAGE_PIN D18 [get_ports {portC_data_in_n[7]}]; # HA08_N -> D7_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[7]}];
## Bit 8
#set_property PACKAGE_PIN J15 [get_ports {portC_data_in_p[8]}]; # HA05_P -> D8_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[8]}];
#set_property PACKAGE_PIN J14 [get_ports {portC_data_in_n[8]}]; # HA05_N -> D8_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[8]}];
## Bit 9
#set_property PACKAGE_PIN F15 [get_ports {portC_data_in_p[9]}]; # HA12_P -> D9_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[9]}];
#set_property PACKAGE_PIN F14 [get_ports {portC_data_in_n[9]}]; # HA12_N -> D9_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[9]}];
## Bit 10
#set_property PACKAGE_PIN G19 [get_ports {portC_data_in_p[10]}]; # HA13_P -> D10_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[10]}];
#set_property PACKAGE_PIN F19 [get_ports {portC_data_in_n[10]}]; # HA13_N -> D10_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[10]}];
## Bit 11
#set_property PACKAGE_PIN H19 [get_ports {portC_data_in_p[11]}]; # HA09_P -> D11_P
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_p[11]}];
#set_property PACKAGE_PIN H18 [get_ports {portC_data_in_n[11]}]; # HA09_N -> D11_N
#set_property IOSTANDARD LVDS [get_ports {portC_data_in_n[11]}];

## ===============================
## ADC CLOCK differential pair for PORTD - valid
## ===============================
#set_property PACKAGE_PIN G10 [get_ports portD_adcclk_in_p];   # HB06_CC_P -> CLK_P
#set_property IOSTANDARD LVDS [get_ports portD_adcclk_in_p];
#set_property PACKAGE_PIN F10 [get_ports portD_adcclk_in_n];   # HB06_CC_N -> CLK_N
#set_property IOSTANDARD LVDS [get_ports portD_adcclk_in_n];
## ===============================
## STROBE differential pair for PORTD - valid
## ===============================
#set_property PACKAGE_PIN H12 [get_ports portD_strobe_in_p];   # HB00_CC_P -> STR_P
#set_property IOSTANDARD LVDS [get_ports portD_strobe_in_p];
#set_property PACKAGE_PIN G12 [get_ports portD_strobe_in_n];   # HB00_CC_N -> STR_N
#set_property IOSTANDARD LVDS [get_ports portD_strobe_in_n];
## ===============================
## DATA differential pairs for PORTD - valid
## ===============================
## Bit 0
#set_property PACKAGE_PIN K11 [get_ports {portD_data_in_p[0]}]; # HB16_P -> D0_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[0]}];
#set_property PACKAGE_PIN J11 [get_ports {portD_data_in_n[0]}]; # HB16_N -> D0_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[0]}];
## Bit 1
#set_property PACKAGE_PIN B10 [get_ports {portD_data_in_p[1]}]; # HB02_P -> D1_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[1]}];
#set_property PACKAGE_PIN A10 [get_ports {portD_data_in_n[1]}]; # HB02_N -> D1_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[1]}];
## Bit 2
#set_property PACKAGE_PIN L8 [get_ports {portD_data_in_p[2]}]; # HB19_P -> D2_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[2]}];
#set_property PACKAGE_PIN K8 [get_ports {portD_data_in_n[2]}]; # HB19_N -> D2_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[2]}];
## Bit 3
#set_property PACKAGE_PIN H11 [get_ports {portD_data_in_p[3]}]; # HB17_CC_P -> D3_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[3]}];
#set_property PACKAGE_PIN G11 [get_ports {portD_data_in_n[3]}]; # HB17_CC_N -> D3_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[3]}];
## Bit 4
#set_property PACKAGE_PIN D8 [get_ports {portD_data_in_p[4]}]; # HB20_P -> D4_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[4]}];
#set_property PACKAGE_PIN C8 [get_ports {portD_data_in_n[4]}]; # HB20_N -> D4_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[4]}];
## Bit 5
#set_property PACKAGE_PIN J9 [get_ports {portD_data_in_p[5]}]; # HB21_P -> D5_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[5]}];
#set_property PACKAGE_PIN H9 [get_ports {portD_data_in_n[5]}]; # HB21_N -> D5_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[5]}];
## Bit 6
#set_property PACKAGE_PIN A13 [get_ports {portD_data_in_p[6]}]; # HB03_P -> D6_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[6]}];
#set_property PACKAGE_PIN A12 [get_ports {portD_data_in_n[6]}]; # HB03_N -> D6_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[6]}];
## Bit 7
#set_property PACKAGE_PIN J13 [get_ports {portD_data_in_p[7]}]; # HB13_P -> D7_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[7]}];
#set_property PACKAGE_PIN H13 [get_ports {portD_data_in_n[7]}]; # HB13_N -> D7_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[7]}];
## Bit 8
#set_property PACKAGE_PIN D13 [get_ports {portD_data_in_p[8]}]; # HB05_P -> D8_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[8]}];
#set_property PACKAGE_PIN C13 [get_ports {portD_data_in_n[8]}]; # HB05_N -> D8_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[8]}];
## Bit 9
#set_property PACKAGE_PIN C12 [get_ports {portD_data_in_p[9]}]; # HB04_P -> D9_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[9]}];
#set_property PACKAGE_PIN B12 [get_ports {portD_data_in_n[9]}]; # HB04_N -> D9_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[9]}];
## Bit 10
#set_property PACKAGE_PIN E11 [get_ports {portD_data_in_p[10]}]; # HB09_P -> D10_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[10]}];
#set_property PACKAGE_PIN D11 [get_ports {portD_data_in_n[10]}]; # HB09_N -> D10_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[10]}];
## Bit 11
#set_property PACKAGE_PIN B9 [get_ports {portD_data_in_p[11]}]; # HB01_P -> D11_P
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_p[11]}];
#set_property PACKAGE_PIN A9 [get_ports {portD_data_in_n[11]}]; # HB01_N -> D11_N
#set_property IOSTANDARD LVDS [get_ports {portD_data_in_n[11]}];




set_property PACKAGE_PIN B15 [get_ports {PLL_CTRL_tri_io[0]}]

#create_clock -period 6.400 -name gth_clk_out -waveform {0.000 3.200} [get_pins {design_1_i/gth_wrapper_0/gtwiz_userclk_rx_usrclk2_out[0]}]

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
