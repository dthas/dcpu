# Copyright (C) 1991-2011 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.

# Quartus II Version 10.1 Build 197 01/19/2011 Service Pack 1 SJ Web Edition
# File: C:/user/openmips/project/20150815_1/openmips_min_sopc/openmips_min_sopc.tcl
# Generated on: Tue Sep 15 10:03:28 2015

package require ::quartus::project

set_location_assignment PIN_D13 -to clk
set_location_assignment PIN_Y14 -to flash_addr_o[21]
set_location_assignment PIN_Y15 -to flash_addr_o[20]
set_location_assignment PIN_AA15 -to flash_addr_o[19]
set_location_assignment PIN_AB15 -to flash_addr_o[18]
set_location_assignment PIN_AC15 -to flash_addr_o[17]
set_location_assignment PIN_AE16 -to flash_addr_o[16]
set_location_assignment PIN_AD16 -to flash_addr_o[15]
set_location_assignment PIN_AC16 -to flash_addr_o[14]
set_location_assignment PIN_W15 -to flash_addr_o[13]
set_location_assignment PIN_W16 -to flash_addr_o[12]
set_location_assignment PIN_AF17 -to flash_addr_o[11]
set_location_assignment PIN_AE17 -to flash_addr_o[10]
set_location_assignment PIN_AC17 -to flash_addr_o[9]
set_location_assignment PIN_AD17 -to flash_addr_o[8]
set_location_assignment PIN_AA16 -to flash_addr_o[7]
set_location_assignment PIN_N25 -to gpio_i[0]
set_location_assignment PIN_N26 -to gpio_i[1]
set_location_assignment PIN_P25 -to gpio_i[2]
set_location_assignment PIN_AE14 -to gpio_i[3]
set_location_assignment PIN_AF14 -to gpio_i[4]
set_location_assignment PIN_AD13 -to gpio_i[5]
set_location_assignment PIN_AC13 -to gpio_i[6]
set_location_assignment PIN_C13 -to gpio_i[7]
set_location_assignment PIN_B13 -to gpio_i[8]
set_location_assignment PIN_A13 -to gpio_i[9]
set_location_assignment PIN_N1 -to gpio_i[10]
set_location_assignment PIN_P1 -to gpio_i[11]
set_location_assignment PIN_P2 -to gpio_i[12]
set_location_assignment PIN_T7 -to gpio_i[13]
set_location_assignment PIN_U3 -to gpio_i[14]
set_location_assignment PIN_U4 -to gpio_i[15]
set_location_assignment PIN_V2 -to rst
set_location_assignment PIN_AF10 -to gpio_o[0]
set_location_assignment PIN_AB12 -to gpio_o[1]
set_location_assignment PIN_AC12 -to gpio_o[2]
set_location_assignment PIN_AD11 -to gpio_o[3]
set_location_assignment PIN_AE11 -to gpio_o[4]
set_location_assignment PIN_V14 -to gpio_o[5]
set_location_assignment PIN_V13 -to gpio_o[6]
set_location_assignment PIN_V20 -to gpio_o[8]
set_location_assignment PIN_V21 -to gpio_o[9]
set_location_assignment PIN_W21 -to gpio_o[10]
set_location_assignment PIN_Y22 -to gpio_o[11]
set_location_assignment PIN_AA24 -to gpio_o[12]
set_location_assignment PIN_AA23 -to gpio_o[13]
set_location_assignment PIN_AB24 -to gpio_o[14]
set_location_assignment PIN_AB23 -to gpio_o[16]
set_location_assignment PIN_V22 -to gpio_o[17]
set_location_assignment PIN_AC25 -to gpio_o[18]
set_location_assignment PIN_AC26 -to gpio_o[19]
set_location_assignment PIN_AB26 -to gpio_o[20]
set_location_assignment PIN_AB25 -to gpio_o[21]
set_location_assignment PIN_Y24 -to gpio_o[22]
set_location_assignment PIN_Y23 -to gpio_o[24]
set_location_assignment PIN_AA25 -to gpio_o[25]
set_location_assignment PIN_AA26 -to gpio_o[26]
set_location_assignment PIN_Y26 -to gpio_o[27]
set_location_assignment PIN_Y25 -to gpio_o[28]
set_location_assignment PIN_U22 -to gpio_o[29]
set_location_assignment PIN_W24 -to gpio_o[30]
set_location_assignment PIN_AC18 -to flash_addr_o[0]
set_location_assignment PIN_AB18 -to flash_addr_o[1]
set_location_assignment PIN_AE19 -to flash_addr_o[2]
set_location_assignment PIN_AF19 -to flash_addr_o[3]
set_location_assignment PIN_AE18 -to flash_addr_o[4]
set_location_assignment PIN_AF18 -to flash_addr_o[5]
set_location_assignment PIN_Y16 -to flash_addr_o[6]
set_location_assignment PIN_AD19 -to flash_data_i[0]
set_location_assignment PIN_AC19 -to flash_data_i[1]
set_location_assignment PIN_AF20 -to flash_data_i[2]
set_location_assignment PIN_AE20 -to flash_data_i[3]
set_location_assignment PIN_AB20 -to flash_data_i[4]
set_location_assignment PIN_AC20 -to flash_data_i[5]
set_location_assignment PIN_AF21 -to flash_data_i[6]
set_location_assignment PIN_AE21 -to flash_data_i[7]
set_location_assignment PIN_AA17 -to flash_we_o
set_location_assignment PIN_AA18 -to flash_rst_o
set_location_assignment PIN_W17 -to flash_oe_o
set_location_assignment PIN_V17 -to flash_ce_o
set_location_assignment PIN_T6 -to sdr_addr_o[0]
set_location_assignment PIN_V4 -to sdr_addr_o[1]
set_location_assignment PIN_V3 -to sdr_addr_o[2]
set_location_assignment PIN_W2 -to sdr_addr_o[3]
set_location_assignment PIN_W1 -to sdr_addr_o[4]
set_location_assignment PIN_U6 -to sdr_addr_o[5]
set_location_assignment PIN_U7 -to sdr_addr_o[6]
set_location_assignment PIN_U5 -to sdr_addr_o[7]
set_location_assignment PIN_W4 -to sdr_addr_o[8]
set_location_assignment PIN_W3 -to sdr_addr_o[9]
set_location_assignment PIN_Y1 -to sdr_addr_o[10]
set_location_assignment PIN_V5 -to sdr_addr_o[11]
set_location_assignment PIN_V6 -to sdr_dq_io[0]
set_location_assignment PIN_AA2 -to sdr_dq_io[1]
set_location_assignment PIN_AA1 -to sdr_dq_io[2]
set_location_assignment PIN_Y3 -to sdr_dq_io[3]
set_location_assignment PIN_Y4 -to sdr_dq_io[4]
set_location_assignment PIN_R8 -to sdr_dq_io[5]
set_location_assignment PIN_T8 -to sdr_dq_io[6]
set_location_assignment PIN_V7 -to sdr_dq_io[7]
set_location_assignment PIN_W6 -to sdr_dq_io[8]
set_location_assignment PIN_AB2 -to sdr_dq_io[9]
set_location_assignment PIN_AB1 -to sdr_dq_io[10]
set_location_assignment PIN_AA4 -to sdr_dq_io[11]
set_location_assignment PIN_AA3 -to sdr_dq_io[12]
set_location_assignment PIN_AC2 -to sdr_dq_io[13]
set_location_assignment PIN_AC1 -to sdr_dq_io[14]
set_location_assignment PIN_AA5 -to sdr_dq_io[15]
set_location_assignment PIN_AE2 -to sdr_ba_o[0]
set_location_assignment PIN_AE3 -to sdr_ba_o[1]
set_location_assignment PIN_AB3 -to sdr_cas_n_o
set_location_assignment PIN_AA6 -to sdr_cke_o
set_location_assignment PIN_AA7 -to sdr_clk_o
set_location_assignment PIN_AC3 -to sdr_cs_n_o
set_location_assignment PIN_AD3 -to sdr_we_n_o
set_location_assignment PIN_AD2 -to sdr_dqm_o[0]
set_location_assignment PIN_Y5 -to sdr_dqm_o[1]
set_location_assignment PIN_AB4 -to sdr_ras_n_o
set_location_assignment PIN_C25 -to uart_in
set_location_assignment PIN_B25 -to uart_out
