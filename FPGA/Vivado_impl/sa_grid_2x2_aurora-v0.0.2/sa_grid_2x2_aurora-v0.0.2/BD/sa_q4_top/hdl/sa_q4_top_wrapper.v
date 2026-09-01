//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2024.2 (lin64) Build 5239630 Fri Nov 08 22:34:34 MST 2024
//Date        : Wed Aug 19 14:57:20 2026
//Host        : hp6g4-mlab-5 running 64-bit Ubuntu 22.04.5 LTS
//Command     : generate_target sa_q4_top_wrapper.bd
//Design      : sa_q4_top_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module sa_q4_top_wrapper
   (GT_DIFF_REFCLK1_0_clk_n,
    GT_DIFF_REFCLK1_0_clk_p,
    GT_SERIAL_RX_0_rxn,
    GT_SERIAL_RX_0_rxp,
    GT_SERIAL_RX_1_rxn,
    GT_SERIAL_RX_1_rxp,
    GT_SERIAL_RX_2_rxn,
    GT_SERIAL_RX_2_rxp,
    GT_SERIAL_RX_3_rxn,
    GT_SERIAL_RX_3_rxp,
    GT_SERIAL_TX_0_txn,
    GT_SERIAL_TX_0_txp,
    GT_SERIAL_TX_1_txn,
    GT_SERIAL_TX_1_txp,
    GT_SERIAL_TX_2_txn,
    GT_SERIAL_TX_2_txp,
    GT_SERIAL_TX_3_txn,
    GT_SERIAL_TX_3_txp);
  input GT_DIFF_REFCLK1_0_clk_n;
  input GT_DIFF_REFCLK1_0_clk_p;
  input [0:0]GT_SERIAL_RX_0_rxn;
  input [0:0]GT_SERIAL_RX_0_rxp;
  input [0:0]GT_SERIAL_RX_1_rxn;
  input [0:0]GT_SERIAL_RX_1_rxp;
  input [0:0]GT_SERIAL_RX_2_rxn;
  input [0:0]GT_SERIAL_RX_2_rxp;
  input [0:0]GT_SERIAL_RX_3_rxn;
  input [0:0]GT_SERIAL_RX_3_rxp;
  output [0:0]GT_SERIAL_TX_0_txn;
  output [0:0]GT_SERIAL_TX_0_txp;
  output [0:0]GT_SERIAL_TX_1_txn;
  output [0:0]GT_SERIAL_TX_1_txp;
  output [0:0]GT_SERIAL_TX_2_txn;
  output [0:0]GT_SERIAL_TX_2_txp;
  output [0:0]GT_SERIAL_TX_3_txn;
  output [0:0]GT_SERIAL_TX_3_txp;

  wire GT_DIFF_REFCLK1_0_clk_n;
  wire GT_DIFF_REFCLK1_0_clk_p;
  wire [0:0]GT_SERIAL_RX_0_rxn;
  wire [0:0]GT_SERIAL_RX_0_rxp;
  wire [0:0]GT_SERIAL_RX_1_rxn;
  wire [0:0]GT_SERIAL_RX_1_rxp;
  wire [0:0]GT_SERIAL_RX_2_rxn;
  wire [0:0]GT_SERIAL_RX_2_rxp;
  wire [0:0]GT_SERIAL_RX_3_rxn;
  wire [0:0]GT_SERIAL_RX_3_rxp;
  wire [0:0]GT_SERIAL_TX_0_txn;
  wire [0:0]GT_SERIAL_TX_0_txp;
  wire [0:0]GT_SERIAL_TX_1_txn;
  wire [0:0]GT_SERIAL_TX_1_txp;
  wire [0:0]GT_SERIAL_TX_2_txn;
  wire [0:0]GT_SERIAL_TX_2_txp;
  wire [0:0]GT_SERIAL_TX_3_txn;
  wire [0:0]GT_SERIAL_TX_3_txp;

  sa_q4_top sa_q4_top_i
       (.GT_DIFF_REFCLK1_0_clk_n(GT_DIFF_REFCLK1_0_clk_n),
        .GT_DIFF_REFCLK1_0_clk_p(GT_DIFF_REFCLK1_0_clk_p),
        .GT_SERIAL_RX_0_rxn(GT_SERIAL_RX_0_rxn),
        .GT_SERIAL_RX_0_rxp(GT_SERIAL_RX_0_rxp),
        .GT_SERIAL_RX_1_rxn(GT_SERIAL_RX_1_rxn),
        .GT_SERIAL_RX_1_rxp(GT_SERIAL_RX_1_rxp),
        .GT_SERIAL_RX_2_rxn(GT_SERIAL_RX_2_rxn),
        .GT_SERIAL_RX_2_rxp(GT_SERIAL_RX_2_rxp),
        .GT_SERIAL_RX_3_rxn(GT_SERIAL_RX_3_rxn),
        .GT_SERIAL_RX_3_rxp(GT_SERIAL_RX_3_rxp),
        .GT_SERIAL_TX_0_txn(GT_SERIAL_TX_0_txn),
        .GT_SERIAL_TX_0_txp(GT_SERIAL_TX_0_txp),
        .GT_SERIAL_TX_1_txn(GT_SERIAL_TX_1_txn),
        .GT_SERIAL_TX_1_txp(GT_SERIAL_TX_1_txp),
        .GT_SERIAL_TX_2_txn(GT_SERIAL_TX_2_txn),
        .GT_SERIAL_TX_2_txp(GT_SERIAL_TX_2_txp),
        .GT_SERIAL_TX_3_txn(GT_SERIAL_TX_3_txn),
        .GT_SERIAL_TX_3_txp(GT_SERIAL_TX_3_txp));
endmodule
