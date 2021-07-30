create_clock -period 5.000 -name sysclk [get_ports I_clk_src_p]
set_input_delay -clock [get_clocks clk_out1_clk_wiz] -clock_fall -max -add_delay 1.000 [get_ports IO_spi_data*]
set_input_delay -clock [get_clocks clk_out1_clk_wiz] -clock_fall -min -add_delay 0.000 [get_ports IO_spi_data*]
set_output_delay -clock [get_clocks clk_out1_clk_wiz] -max -add_delay 10.000 [get_ports IO_spi_data*]
set_output_delay -clock [get_clocks clk_out1_clk_wiz] -min -add_delay 0.000 [get_ports IO_spi_data*]
# SYSCLK 200MHz
set_property IOSTANDARD LVDS [get_ports I_clk_src_p]
set_property PACKAGE_PIN E19 [get_ports I_clk_src_p]
set_property PACKAGE_PIN E18 [get_ports I_clk_src_n]
set_property IOSTANDARD LVDS [get_ports I_clk_src_n]

# CPU Reset (Switch 8)
set_property PACKAGE_PIN AV40 [get_ports I_rst]
set_property IOSTANDARD LVCMOS18 [get_ports I_rst]

# DIP Switches
set_property PACKAGE_PIN AV30 [get_ports I_SW0]
set_property IOSTANDARD LVCMOS18 [get_ports I_SW0]
set_property PACKAGE_PIN AY33 [get_ports I_SW1]
set_property IOSTANDARD LVCMOS18 [get_ports I_SW1]
set_property PACKAGE_PIN BA31 [get_ports I_SW2]
set_property IOSTANDARD LVCMOS18 [get_ports I_SW2]
set_property PACKAGE_PIN BA32 [get_ports I_SW3]
set_property IOSTANDARD LVCMOS18 [get_ports I_SW3]
set_property PACKAGE_PIN AW30 [get_ports I_SW4]
set_property IOSTANDARD LVCMOS18 [get_ports I_SW4]
set_property PACKAGE_PIN AY30 [get_ports I_SW5]
set_property IOSTANDARD LVCMOS18 [get_ports I_SW5]

# LEDs
set_property PACKAGE_PIN AM39 [get_ports Hold_I_spi_data]
set_property IOSTANDARD LVCMOS18 [get_ports Hold_I_spi_data]
set_property PACKAGE_PIN AN39 [get_ports O_FPGA_clk_locked]
set_property IOSTANDARD LVCMOS18 [get_ports O_FPGA_clk_locked]

############################################################
# FMC
############################################################

################## JP1 #####################################
# FMC1_HPC_HA01_CC_N
set_property PACKAGE_PIN D36 [get_ports {IO_spi_data[30]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[30]}]

# FMC1_HPC_HA01_CC_P
set_property PACKAGE_PIN D35 [get_ports {IO_spi_data[29]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[29]}]

# FMC1_HPC_LA00_CC_N
set_property PACKAGE_PIN K40 [get_ports {IO_spi_data[26]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[26]}]

set_property PACKAGE_PIN K39 [get_ports {IO_spi_data[25]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[25]}]

# FMC1_HPC_LA03_N
set_property PACKAGE_PIN L42 [get_ports {IO_spi_data[24]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[24]}]

set_property PACKAGE_PIN M42 [get_ports {IO_spi_data[23]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[23]}]

# FMC1_HPC_HA03_N
set_property PACKAGE_PIN G33 [get_ports {IO_spi_data[19]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[19]}]

set_property PACKAGE_PIN H33 [get_ports {IO_spi_data[18]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[18]}]

# FMC1_HPC_LA02_N
set_property PACKAGE_PIN N41 [get_ports {IO_spi_data[15]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[15]}]

set_property PACKAGE_PIN P41 [get_ports {IO_spi_data[14]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[14]}]

# FMC1_HPC_HA06_N
set_property PACKAGE_PIN G37 [get_ports {IO_spi_data[13]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[13]}]

set_property PACKAGE_PIN G36 [get_ports {IO_spi_data[12]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[12]}]

# FMC1_HPC_HA11_N
set_property PACKAGE_PIN J38 [get_ports {IO_spi_data[11]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[11]}]

set_property PACKAGE_PIN J37 [get_ports {IO_spi_data[20]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[20]}]

# FMC1_HPC_LA07_N
set_property PACKAGE_PIN G42 [get_ports {IO_spi_data[17]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[17]}]

set_property PACKAGE_PIN G41 [get_ports {IO_spi_data[16]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[16]}]

# FMC1_HPC_HA17_CC_N
set_property PACKAGE_PIN C36 [get_ports {IO_spi_data[10]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[10]}]

set_property PACKAGE_PIN C35 [get_ports {IO_spi_data[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[7]}]

# FMC1_HPC_HA18_N
set_property PACKAGE_PIN E39 [get_ports {IO_spi_data[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[6]}]

set_property PACKAGE_PIN F39 [get_ports {IO_spi_data[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[5]}]

# FMC1_HPC_LA15_N
set_property PACKAGE_PIN L37 [get_ports {IO_spi_data[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[1]}]

set_property PACKAGE_PIN M36 [get_ports {IO_spi_data[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[0]}]

# FMC1_HPC_HA23_N
set_property PACKAGE_PIN A36 [get_ports {IO_spi_data[9]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[9]}]

set_property PACKAGE_PIN A35 [get_ports {IO_spi_data[8]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[8]}]

# FMC1_HPC_HB01_N
set_property PACKAGE_PIN H29 [get_ports {IO_spi_data[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[4]}]

set_property PACKAGE_PIN H28 [get_ports {IO_spi_data[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[3]}]

# FMC1_HPC_LA21_N
set_property PACKAGE_PIN N29 [get_ports {IO_spi_data[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[2]}]

set_property PACKAGE_PIN N28 [get_ports O_bypass_fifo]
set_property IOSTANDARD LVCMOS18 [get_ports O_bypass_fifo]

# FMC1_HPC_HB06_CC_N
set_property PACKAGE_PIN J23 [get_ports O_SW_clk]
set_property IOSTANDARD LVCMOS18 [get_ports O_SW_clk]

set_property PACKAGE_PIN K23 [get_ports O_spi_cs_n]
set_property IOSTANDARD LVCMOS18 [get_ports O_spi_cs_n]

# FMC1_HPC_HB11_N
set_property PACKAGE_PIN J22 [get_ports I_sck_out]
set_property IOSTANDARD LVCMOS18 [get_ports I_sck_out]

set_property PACKAGE_PIN K22 [get_ports I_near_full]
set_property IOSTANDARD LVCMOS18 [get_ports I_near_full]


# FMC1_HPC_LA28_N
set_property PACKAGE_PIN L30 [get_ports I_switch_rdwr]
set_property IOSTANDARD LVCMOS18 [get_ports I_switch_rdwr]

set_property PACKAGE_PIN L29 [get_ports I_DLL_lock]
set_property IOSTANDARD LVCMOS18 [get_ports I_DLL_lock]


# FMC1_HPC_HB14_N
set_property PACKAGE_PIN H21 [get_ports O_in_1]
set_property IOSTANDARD LVCMOS18 [get_ports O_in_1]

set_property PACKAGE_PIN J21 [get_ports O_in_2]
set_property IOSTANDARD LVCMOS18 [get_ports O_in_2]


# FMC1_HPC_LA30_N
set_property PACKAGE_PIN V31 [get_ports O_OE_req]
set_property IOSTANDARD LVCMOS18 [get_ports O_OE_req]

set_property PACKAGE_PIN V30 [get_ports I_config_req]
set_property IOSTANDARD LVCMOS18 [get_ports I_config_req]

# FMC1_HPC_HB18_P
set_property PACKAGE_PIN G21 [get_ports O_SW0]
set_property IOSTANDARD LVCMOS18 [get_ports O_SW0]

set_property PACKAGE_PIN G22 [get_ports O_SW1]
set_property IOSTANDARD LVCMOS18 [get_ports O_SW1]

################## JP2 #####################################
# FMC1_HPC_HA00_CC_N
set_property PACKAGE_PIN E35 [get_ports {IO_spi_data[46]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[46]}]

set_property PACKAGE_PIN E34 [get_ports {IO_spi_data[47]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[47]}]

# FMC1_HPC_LA01_CC_N
set_property PACKAGE_PIN J41 [get_ports {IO_spi_data[48]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[48]}]

set_property PACKAGE_PIN J40 [get_ports {IO_spi_data[49]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[49]}]

# FMC1_HPC_HA08_N
set_property PACKAGE_PIN H36 [get_ports {IO_spi_data[50]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[50]}]

set_property PACKAGE_PIN J36 [get_ports {IO_spi_data[51]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[51]}]

# FMC1_HPC_LA05_N
set_property PACKAGE_PIN L41 [get_ports {IO_spi_data[52]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[52]}]

set_property PACKAGE_PIN M41 [get_ports {IO_spi_data[53]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[53]}]

# FMC1_HPC_HA02_P
set_property PACKAGE_PIN E33 [get_ports {IO_spi_data[54]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[54]}]

set_property PACKAGE_PIN D33 [get_ports {IO_spi_data[55]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[55]}]

# FMC1_HPC_HA07_P
set_property PACKAGE_PIN C38 [get_ports {IO_spi_data[56]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[56]}]

set_property PACKAGE_PIN C39 [get_ports {IO_spi_data[57]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[57]}]

# FMC1_HPC_LA04_P
set_property PACKAGE_PIN H40 [get_ports {IO_spi_data[59]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[59]}]

set_property PACKAGE_PIN H41 [get_ports {IO_spi_data[58]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[58]}]

# FMC1_HPC_HA10_P
set_property PACKAGE_PIN H38 [get_ports {IO_spi_data[63]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[63]}]

set_property PACKAGE_PIN G38 [get_ports {IO_spi_data[60]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[60]}]

# FMC1_HPC_HA14_P
set_property PACKAGE_PIN E37 [get_ports {IO_spi_data[64]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[64]}]

set_property PACKAGE_PIN E38 [get_ports {IO_spi_data[61]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[61]}]

# FMC1_HPC_LA11_P
set_property PACKAGE_PIN F40 [get_ports {IO_spi_data[65]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[65]}]

set_property PACKAGE_PIN F41 [get_ports {IO_spi_data[62]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[62]}]

# FMC1_HPC_HA21_P 21-22
set_property PACKAGE_PIN D37 [get_ports {IO_spi_data[66]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[66]}]

set_property PACKAGE_PIN D38 [get_ports {IO_spi_data[45]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[45]}]

# FMC1_HPC_HA22_P
set_property PACKAGE_PIN F36 [get_ports {IO_spi_data[44]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[44]}]

set_property PACKAGE_PIN F37 [get_ports {IO_spi_data[43]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[43]}]

# FMC1_HPC_LA19_P
set_property PACKAGE_PIN W30 [get_ports {IO_spi_data[42]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[42]}]

set_property PACKAGE_PIN W31 [get_ports {IO_spi_data[41]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[41]}]

# FMC1_HPC_HB00_P
set_property PACKAGE_PIN J25 [get_ports {IO_spi_data[40]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[40]}]

set_property PACKAGE_PIN J26 [get_ports {IO_spi_data[39]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[39]}]

# FMC1_HPC_HB07_P
set_property PACKAGE_PIN G26 [get_ports {IO_spi_data[38]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[38]}]

set_property PACKAGE_PIN G27 [get_ports {IO_spi_data[37]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[37]}]


# FMC1_HPC_LA24_P
set_property PACKAGE_PIN R30 [get_ports {IO_spi_data[36]}]

set_property PACKAGE_PIN P31 [get_ports {IO_spi_data[35]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[36]}]

# FMC1_HPC_HB10_N 33-34
set_property PACKAGE_PIN L22 [get_ports {IO_spi_data[28]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[28]}]

set_property PACKAGE_PIN M22 [get_ports {IO_spi_data[27]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[27]}]

# FMC1_HPC_HB15_N
set_property PACKAGE_PIN L21 [get_ports {IO_spi_data[22]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[22]}]

set_property PACKAGE_PIN M21 [get_ports {IO_spi_data[21]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[21]}]

# FMC1_HPC_HB17_N
set_property PACKAGE_PIN L24 [get_ports {IO_spi_data[34]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[34]}]

set_property PACKAGE_PIN M24 [get_ports {IO_spi_data[33]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[33]}]

# FMC1_HPC_LA32_N
set_property PACKAGE_PIN U29 [get_ports {IO_spi_data[32]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[32]}]

set_property PACKAGE_PIN V29 [get_ports {IO_spi_data[31]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[31]}]

################## JP3 #####################################
# FMC1_HPC_HA05_N 1-2
set_property PACKAGE_PIN F32 [get_ports {IO_spi_data[71]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[71]}]

set_property PACKAGE_PIN G32 [get_ports {IO_spi_data[67]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[67]}]

# FMC1_HPC_HA04_N
set_property PACKAGE_PIN F35 [get_ports {IO_spi_data[69]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[69]}]

set_property PACKAGE_PIN F34 [get_ports {IO_spi_data[68]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[68]}]

# FMC1_HPC_LA08_N
set_property PACKAGE_PIN M38 [get_ports {IO_spi_data[72]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[72]}]

set_property PACKAGE_PIN M37 [get_ports {IO_spi_data[70]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[70]}]

# FMC1_HPC_HA12_N
set_property PACKAGE_PIN B38 [get_ports {IO_spi_data[74]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[74]}]

set_property PACKAGE_PIN B37 [get_ports {IO_spi_data[73]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[73]}]

# FMC1_HPC_HA09_N 9-10
set_property PACKAGE_PIN D32 [get_ports {IO_spi_data[75]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[75]}]

set_property PACKAGE_PIN E32 [get_ports {IO_spi_data[76]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[76]}]

# FMC1_HPC_LA06_N
set_property PACKAGE_PIN J42 [get_ports {IO_spi_data[81]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[81]}]

set_property PACKAGE_PIN K42 [get_ports {IO_spi_data[77]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[77]}]

# FMC1_HPC_HA15_N
set_property PACKAGE_PIN C34 [get_ports {IO_spi_data[83]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[83]}]

set_property PACKAGE_PIN C33 [get_ports {IO_spi_data[78]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[78]}]

# FMC1_HPC_LA16_N
set_property PACKAGE_PIN K38 [get_ports {IO_spi_data[80]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[80]}]

set_property PACKAGE_PIN K37 [get_ports {IO_spi_data[79]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[79]}]

# FMC1_HPC_HA16_N
set_property PACKAGE_PIN A39 [get_ports {IO_spi_data[96]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[96]}]

set_property PACKAGE_PIN B39 [get_ports {IO_spi_data[82]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[82]}]

# FMC1_HPC_HA20_N 19-20
set_property PACKAGE_PIN A34 [get_ports {IO_spi_data[102]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[102]}]

set_property PACKAGE_PIN B34 [get_ports {IO_spi_data[97]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[97]}]


# FMC1_HPC_LA23_N
set_property PACKAGE_PIN N31 [get_ports {IO_spi_data[84]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[84]}]

set_property PACKAGE_PIN P30 [get_ports {IO_spi_data[103]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[103]}]

# FMC1_HPC_HB04_N
set_property PACKAGE_PIN G24 [get_ports {IO_spi_data[86]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[86]}]

set_property PACKAGE_PIN H24 [get_ports {IO_spi_data[85]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[85]}]

# FMC1_HPC_LA26_N
set_property PACKAGE_PIN H30 [get_ports {IO_spi_data[88]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[88]}]

set_property PACKAGE_PIN J30 [get_ports {IO_spi_data[87]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[87]}]

# FMC1_HPC_LA25_N
set_property PACKAGE_PIN K30 [get_ports {IO_spi_data[91]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[91]}]

set_property PACKAGE_PIN K29 [get_ports {IO_spi_data[89]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[89]}]

# FMC1_HPC_HB09_P 29-30
set_property PACKAGE_PIN H23 [get_ports {IO_spi_data[93]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[93]}]

set_property PACKAGE_PIN G23 [get_ports {IO_spi_data[90]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[90]}]

# FMC1_HPC_HB13_P
set_property PACKAGE_PIN P25 [get_ports {IO_spi_data[95]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[95]}]

set_property PACKAGE_PIN P26 [get_ports {IO_spi_data[92]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[92]}]

# FMC1_HPC_HB12_P
set_property PACKAGE_PIN K24 [get_ports {IO_spi_data[99]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[99]}]

set_property PACKAGE_PIN K25 [get_ports {IO_spi_data[94]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[94]}]

# FMC1_HPC_LA31_P
set_property PACKAGE_PIN M28 [get_ports O_spi_sck]
set_property IOSTANDARD LVCMOS18 [get_ports O_spi_sck]

# FMC1_HPC_HB21_P
set_property PACKAGE_PIN P22 [get_ports I_LAST_CLOCK_OUT]
set_property IOSTANDARD LVCMOS18 [get_ports I_LAST_CLOCK_OUT]

# FMC1_HPC_HB20_P 39-40
set_property PACKAGE_PIN P21 [get_ports I_LAST_SCK]
set_property IOSTANDARD LVCMOS18 [get_ports I_LAST_SCK]

################## JP4 #####################################
# FMC1_HPC_LA09_N 1-2
set_property PACKAGE_PIN P42 [get_ports {IO_spi_data[101]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[101]}]

set_property PACKAGE_PIN R42 [get_ports {IO_spi_data[98]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[98]}]

# FMC1_HPC_LA12_N
set_property PACKAGE_PIN P40 [get_ports {IO_spi_data[107]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[107]}]

set_property PACKAGE_PIN R40 [get_ports {IO_spi_data[100]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[100]}]

# FMC1_HPC_LA13_N
set_property PACKAGE_PIN G39 [get_ports {IO_spi_data[110]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[110]}]

set_property PACKAGE_PIN H39 [get_ports {IO_spi_data[108]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[108]}]

# FMC1_HPC_HA19_N
set_property PACKAGE_PIN B33 [get_ports {IO_spi_data[112]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[112]}]

set_property PACKAGE_PIN B32 [get_ports {IO_spi_data[109]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[109]}]

# FMC1_HPC_LA17_CC_N 9-10
set_property PACKAGE_PIN K32 [get_ports {IO_spi_data[114]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[114]}]

set_property PACKAGE_PIN L31 [get_ports {IO_spi_data[111]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[111]}]

# FMC1_HPC_LA20_N
set_property PACKAGE_PIN Y30 [get_ports {IO_spi_data[118]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[118]}]

set_property PACKAGE_PIN Y29 [get_ports {IO_spi_data[113]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[113]}]

# FMC1_HPC_HA13_N
set_property PACKAGE_PIN A37 [get_ports {IO_spi_data[104]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[104]}]

set_property PACKAGE_PIN B36 [get_ports {IO_spi_data[117]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[117]}]

# FMC1_HPC_LA10_N
set_property PACKAGE_PIN M39 [get_ports {IO_spi_data[106]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[106]}]

set_property PACKAGE_PIN N38 [get_ports {IO_spi_data[105]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[105]}]

# FMC1_HPC_LA14_N
set_property PACKAGE_PIN N40 [get_ports {IO_spi_data[116]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[116]}]

set_property PACKAGE_PIN N39 [get_ports {IO_spi_data[115]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[115]}]

# FMC1_HPC_HB02_N 19-20
set_property PACKAGE_PIN J28 [get_ports {IO_spi_data[121]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[121]}]

set_property PACKAGE_PIN K28 [get_ports {IO_spi_data[122]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[122]}]

# FMC1_HPC_HB03_N
set_property PACKAGE_PIN G29 [get_ports {IO_spi_data[125]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[125]}]

set_property PACKAGE_PIN G28 [get_ports {IO_spi_data[124]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[124]}]

# FMC1_HPC_LA22_P
set_property PACKAGE_PIN R28 [get_ports {I_Monitor_Out[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {I_Monitor_Out[6]}]

set_property PACKAGE_PIN P28 [get_ports {I_Monitor_Out[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {I_Monitor_Out[7]}]

# FMC1_HPC_LA18_CC_P
set_property PACKAGE_PIN M32 [get_ports {IO_spi_data[119]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[119]}]

set_property PACKAGE_PIN L32 [get_ports {I_Monitor_Out[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {I_Monitor_Out[5]}]

# FMC1_HPC_HB05_P
set_property PACKAGE_PIN K27 [get_ports {IO_spi_data[123]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[123]}]

set_property PACKAGE_PIN J27 [get_ports {IO_spi_data[120]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[120]}]

# FMC1_HPC_LA27_P 29-30
set_property PACKAGE_PIN J31 [get_ports {IO_spi_data[127]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[127]}]

set_property PACKAGE_PIN H31 [get_ports {IO_spi_data[126]}]
set_property IOSTANDARD LVCMOS18 [get_ports {IO_spi_data[126]}]

# FMC1_HPC_HB08_P
set_property PACKAGE_PIN H25 [get_ports O_Monitor_En]
set_property IOSTANDARD LVCMOS18 [get_ports O_Monitor_En]

set_property PACKAGE_PIN H26 [get_ports {I_Monitor_Out[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {I_Monitor_Out[4]}]

# FMC1_HPC_LA29_P
set_property PACKAGE_PIN T29 [get_ports {I_Monitor_Out[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {I_Monitor_Out[3]}]

set_property PACKAGE_PIN T30 [get_ports I_Monitor_OutVld]
set_property IOSTANDARD LVCMOS18 [get_ports I_Monitor_OutVld]

# FMC1_HPC_HB19_P
set_property PACKAGE_PIN L25 [get_ports {I_Monitor_Out[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {I_Monitor_Out[2]}]

set_property PACKAGE_PIN L26 [get_ports {I_Monitor_Out[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {I_Monitor_Out[1]}]

# FMC1_HPC_HB16_P
set_property PACKAGE_PIN N25 [get_ports I_clk_out]
set_property IOSTANDARD LVCMOS18 [get_ports I_clk_out]

set_property PACKAGE_PIN N26 [get_ports {I_Monitor_Out[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {I_Monitor_Out[0]}]

# FMC1_HPC_LA33_P 39-40
set_property PACKAGE_PIN U31 [get_ports O_reset_n]
set_property IOSTANDARD LVCMOS18 [get_ports O_reset_n]

set_property PACKAGE_PIN T31 [get_ports O_bypass]
set_property IOSTANDARD LVCMOS18 [get_ports O_bypass]






