--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
--Date        : Fri Aug 14 12:18:17 2026
--Host        : hp6g4-mlab-5 running 64-bit Ubuntu 22.04.5 LTS
--Command     : generate_target sa_q4_top_wrapper.bd
--Design      : sa_q4_top_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity sa_q4_top_wrapper is
end sa_q4_top_wrapper;

architecture STRUCTURE of sa_q4_top_wrapper is
  component sa_q4_top is
  end component sa_q4_top;
begin
sa_q4_top_i: component sa_q4_top
 ;
end STRUCTURE;
