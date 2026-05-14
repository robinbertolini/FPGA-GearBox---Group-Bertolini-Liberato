// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Tue Apr 14 10:15:33 2026
// Host        : PcBobin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bram_sim_netlist.v
// Design      : bram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bram,blk_mem_gen_v8_4_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_12,Vivado 2025.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [4:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [15:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [15:0]douta;

  wire [4:0]addra;
  wire clka;
  wire [15:0]dina;
  wire [15:0]douta;
  wire ena;
  wire [0:0]wea;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [15:0]NLW_U0_doutb_UNCONNECTED;
  wire [4:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [4:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [15:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "5" *) 
  (* C_ADDRB_WIDTH = "5" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.87285 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "bram.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "0" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "32" *) 
  (* C_READ_DEPTH_B = "32" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "16" *) 
  (* C_READ_WIDTH_B = "16" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "32" *) 
  (* C_WRITE_DEPTH_B = "32" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "16" *) 
  (* C_WRITE_WIDTH_B = "16" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_blk_mem_gen_v8_4_12 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[15:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[4:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[4:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[15:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2025.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
YqH9kwIC39+qbZg4PSfFsXuB9k9wnuxNryS/CfnEri6Ci9fSC6fsrQ/T/hnt3u/yolbJ8DJa1Qu6
Qnm24A9jLbA+fu3Nsmm6/rM6a4vU6OfVl/gTFd/CiWDutv6Dhn6Lim4uUNPahoOR/A2Yc4Zo2tdI
kMLO9gn9WlH2l3O2oXs=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XJYO2VHd/cnMxQd3i7/2qRhl57dl+doEKuhAunQyv3vpGRG/jlNxj8PqrgLoF0HMdqE3qJUVE/oq
kBSapqjVjLDMOrNGQ+Tc6VGsKMZH8FE/TXHQJ/IM5Iuiu2eozEwwVUomF+7cfqn+9OsVsqCONQ1M
g0oRlangiqasJDhhMfnlGGqwAwmgWRGQA6dmhTuua1s8zdvIv540zY6p5au8cAKVhqyyKK7wbxEE
SGuFqX+NYoyRV+rfWCcWM+hJEmnWS8LNAKkd13YE2+17sPYzUdZ23DmTxXK6KlAxKFW27CBySUfg
qdNXp2DSs2KAQYih27pBNMuHfGbM/ATFPWFvxg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
lYoEi/e8HsDTz6N11EDe/B/iitERmeYndlCklmCluwgb0N4W80JUGVlkd7NlRZHRNhxaNBJPkcjC
n61nO0tb17NwsMwjbY5TF8JWRYTNw1JXCFacvQYrdKv4/7QNQEtwVGiCLxFhOA8aHlWMZIrc2fri
VRMVWaEBcPwCGorlVIM=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QEw9fEsWFbdX0OQLvYs/gl+zyEOW3ak9TdQVaq+0AXXOT3LIqF7wDxJ6ZBnlf9mNbdsUVH5tAz1o
H8u7ihJl1L3THEvugW+TS8hkvVbEA9rKO2vV15KAj4Lla7UdFT/xDfe79RFarlLI7yGrubjgdoRi
QWy//UKsffG7IWNwmoSuppWiWB4ZHJtkunNyIkm70JPGyZF62VxJg1MTT+5LUbZG5vZjjuHZud9w
xJaKv1tFP/x8RVqLU5gPOqGqTW7/nKO2S+450Vo4D9vAmBVVcXpaL1EbSmCvQ+qJmcQKtf9qYFRV
Zko08hbpHjPxstqvTDro01jRzB8592m4xU2TWA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
TC7q853CWBPPJgbRfgDV1lmjUwSAtliljShAyNFg8sfRfwDzchthzoSPH1UCHV++E2JXacEKq1lB
UWsNP92U4Xh0/Gu+6esOI0pJb8I+TRTxyBN1I4cRQEfQHcwfhbSdeH3yX9OV3opLEqYmT37hWU+J
zCawYnxVESI0FtRzEXve9gdEWlrKKckrT/hp4mvxxOjvOkOSQBvy0elgUOqh6mEOZl+JnUbsR+Wm
CoZLE1eefMZy3FnVmyDNPv3JPXi88aLXMyimal0MYFkTiS4XJiGT3eAIMIbksehXY+eYi/KFpZWQ
GHpX+lG3UmiWWLwyPakFwKEHbrBc70AlJ2eV9g==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2025.1-2029.x", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
j9nmCKgjPWNChPbpSW6EWLrMA6oCG2JGPoum8px09v0PEAh0DRXZi0J8HPzXUsZgOEMcKpA7X54u
YFcDDCLAQ+urha/eSPbQYHQh4yGCursxAQ1C6LEyNQ2wJ0eLlO2bJeAl/gof06zqsYVM2lLJVNv5
wao1k2bmgPdfpfY3c9vPD0fSMuZPS41EoRS0cQhO5GTZnKdjxm6tEUL3GnTjB8ynSCIbCJUsMtAX
4FRHNa52gudx5B5fagR+lXgFhE7e++rWTJELr7SYB+r5Es8qZLTpCH8TrQxEkV0rY/+e4sAjNE2D
gHw8GD7VcUtc15B8y1BbVmh29qc8Nd3V2i/miA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
UkCD6I/Vye4qNoNoa3hIexBXG3xyKUJPAHAjIo7UcNVCDXpMQiYEtPDqExZMfiPlJn2nswCYIfIJ
FYWqMCloKSQyyI/7yZ2EtbyWEklb/P5IyZyvGi6hhFUo/JFTb12b4bK0gZPr+bCDdlVQKTx5GVHz
wptdUJO2omSj8axVMPbLRRtVzlJIZ29dTJ2ATXVXAcBxPnFfHRAMnYYKLeeLExX61vQvpqrkLQHm
XG7hpVzJi56gYKAzxa2BLq072OCVpVS70bfWlhlSTVcSlCrUf+EcarEk4FD8+Ih2NCvrqremG6yn
TtcBn8Xr8M/6zhOYvLi6AD6eArDMKA8n+Ccv8A==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
A5y5QVZU8yjPexRVPioSiAGohCHD5DX5FVobuMyhcgQRExLUhPvnnS8HOtxTj/2IapEcz68gFMGG
Hpi+m725u85/om/Vze9pGIW9Mn328Kz2FIg3W5EvGstfGwY+48LiAGAmTR269JS4lJGVYWYOz7Xk
S8cEsFd2m7j8iyKtARJzD90+UdXq/cIIh725jC9i8nbgxB364zddvm1Z/DF3JRw1qFp6GGcuRai1
KNcJ1j8c9wtIgktpsteU3e5+bxHEw8NT3gWXUFYjm00NDq97Jals8Jjktmum2nQxoF7ivPacfEey
gnSF6jRMkTsZObzc30hAhs0CEtc33hZLhPLHSn8pQ0WyvKJLHdd5s2yckgTZtqxC1Sbwe7WEgNXe
ZMX3pIkz+aoXsAL7GBLyVBMVQcyMoF0w8QGAaTe8sqatABwPqXidYRqNROTf62IYcMpV89XYgaTv
EwIn/oni9KOFd2BFVxRZbFGGC4IjvigsTBUijI+Dk6kVnDh240clGcc4

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Omtp+lCaqUx7Z4qdFj2zrN8LpCkit2eX4hlMtig+ielGm/x4FSZkpjoFmiqdKFPi2eg0pg09MSai
XyGH68UzAR7Xrj8f1jlIoUmMKp4GcxfdqfTeuu7kWGOJEP6cvgTjSJFj2gawDv7f4yZcltnK2x0L
e4GW/rBTmGvZtKWb2ahjINLxPuh3dDaSaWdb+zVgbtyrI5FrjxBkq+aOxSjyNsqnCx1L0uWbxnkl
88NbXN3dTaECXHNm/fsleayM5hKis7kTv9BFajJMGy+BhQlmIYpE+F5zchnTTFUFJZCz1sX9Fc8e
HcY7irB8mR3ajdzjUZLBQEMktp096Nheq3U75A==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
hpeBLwN9x2ZFDwroYLlUe5GjjDepHik2l0c2s3/6S7JPCRkzQSyt2V1Ad/JewAs/QNp5SXSbYYB4
rQl0My1LDMF3xw43r0g2IbcyHVpPhGp0W5msuQdF67afnsRv90iJYWLMI3QkYGCTWAzl4HrLxFSg
3z8XZRK670IcxznOrlvgHmIKsvubZrBkuc1EynrVb9Nw16QnIx2rc4WgcEXeFf+4i1RoYLDd3gXK
NFCNMdtaRYUThunFP6Z4ViZ5UnDmKq+IMhd31jTaqIlWOBDxPI1+v5RJYxIyTbn4rxlKR2fNbl5/
z4OUjBTd+1GH3I2OXlqmAOvIhpe2Z2HH7nZu/A==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Mt2RhTSUwEIEWeNARbyL+EdfS1UF6nPaL/fKl/7oO2gina93egwCWDLl1fbBtkfaPco0cu4MJ9K3
OraAsyHRlY+MNShmJ1LzAIA1LjZx4y55lu9dlQqSUXR7AW7wVbkg1864mK+hM/1XygU0jvebKNW9
B7xSER+asLO6pxi0mt7uC2PHxLPAYEszFhmnap82TtbDGdQ2qtyekY+ngs+N2fAdsblxVwJruiMl
e6XJ127M8N1mYwhWU2HtRpBOSnnKoHgD9fG51XK/rhk8DxT66QnX9uLPB+H25eDupBJGi1Y5o6x8
hOwZiSUVlBLh7brfzevh7+eRn+7es6wBas0+3w==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 20384)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
