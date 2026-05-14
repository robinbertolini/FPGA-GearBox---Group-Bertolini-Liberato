// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
// Date        : Tue Apr 14 10:15:34 2026
// Host        : PcBobin running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               {c:/Users/robin/Documents/GitHub/FPGA-GearBox---Group-Bertolini-Liberato/dual_stepper_motor/VIVADO
//               FILES/project_9.gen/sources_1/ip/bram/bram_sim_netlist.v}
// Design      : bram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bram,blk_mem_gen_v8_4_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_12,Vivado 2025.2" *) 
(* NotValidForBitStream *)
module bram
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
  bram_blk_mem_gen_v8_4_12 U0
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 20272)
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
