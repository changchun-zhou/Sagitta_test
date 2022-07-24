
// `define SYNTH_MINI //
// `define SYNTH_FREQ
`define SYNTH_AC // With SRAM

// ****************************************************************************
// ONLY PRE-Sim parameter
// ****************************************************************************
`define CLOCK_PERIOD_ASIC 5 // 10ns clock period for sim
`define CLOCK_PERIOD_FPGA 12 // 12ns clock period
`define DELAY_SRAM // define with SRAM Sim= presim

// ****************************************************************************
// Hyper-parameter
// ****************************************************************************
`define DATA_WIDTH 8
`define NUMPEB 16
`define NUMPEC 3*`NUMPEB
`define PORT_DATAWIDTH `DATA_WIDTH * 12

// ****************************************************************************
// Neural Networks parameter
// ****************************************************************************
`define BLOCK_DEPTH 32
`define KERNEL_SIZE 9
`define MAX_DEPTH 8192 // c3d's conv:512 i3d's conv:1024; fc: 8192
`define LENROW 16
`define LENPSUM 14
`define POOL_WIDTH 32 // 20 + 8 + 1 + 3
//`define POOL_WIDTH 2//Stride

// ************* Config parameters *****************
`define FRAME_WIDTH 5
`define PATCH_WIDTH 8
`define FTRGRP_WIDTH `C_LOG_2( `MAX_DEPTH /  `NUMPEB )
`define BLK_WIDTH   `C_LOG_2(1024/`BLOCK_DEPTH)   //ONLY FOR CONV, FC? 5
`define LAYER_WIDTH 8 //256 layers
`define NUM_CFG_WIDTH `LAYER_WIDTH


// ****************************************************************************
// Global Buffer parameter
// ****************************************************************************
`define GBFWEI_ADDRWIDTH 8  //?64 > log2(BLOCK_DEPTH* KERNEL_SIZE * NumPEC * NumPEB * NumBlk) = 32x9x3x2x2 = 3456
`define GBFWEI_DATAWIDTH `DATA_WIDTH * `KERNEL_SIZE // avoid * 9 Not GBF but DISWEI

`define GBFFLGWEI_ADDRWIDTH 5 //12B x 32
`define GBFFLGWEI_DATAWIDTH `BLOCK_DEPTH * `KERNEL_SIZE //288 Not GBF but DISWEI

`define GBFACT_ADDRWIDTH 8 // log2( 16x16x32x NumBlk x NumFrmx (1-sparsity) )= 2048x32
 `define GBFFLGACT_ADDRWIDTH 5

//`define GBFOFM_ADDRWIDTH  `C_LOG_2(`LENPSUM*`LENPSUM*`NUMPEB/(`PORT_DATAWIDTH/`DATA_WIDTH)) // 9b
`define GBFOFM_ADDRWIDTH  8 // 8b
`define GBFFLGOFM_ADDRWIDTH  `C_LOG_2(`LENPSUM*`LENPSUM*`NUMPEB/(`PORT_DATAWIDTH))//5
// PEL parameter
`define PSUM_WIDTH 30 // Because of test_data_presim
//(`DATA_WIDTH *2 + `C_LOG_2(`KERNEL_SIZE*`MAX_DEPTH) )//29

`define BUSPEC_WIDTH (9 + `BLOCK_DEPTH + `DATA_WIDTH * `BLOCK_DEPTH)
`define BUSPEB_WIDTH `BUSPEC_WIDTH

// DISWEI parameter
`define FIFO_DISWEI_ADDRWIDTH 2 // 4 PEC
// ****************************************************************************
// Interface parameter
// ****************************************************************************
`define IFSCHEDULE_WIDTH 8

`define REQ_CNT_WIDTH 10 // Max time of GBF overflowing
`define ASYSFIFO_ADDRWIDTH 5

`define IFCODE_CFG 0
`define IFCODE_FLGWEI 8
`define IFCODE_WEI 6
`define IFCODE_FLGACT 4
`define IFCODE_ACT 2
`define IFCODE_FLGOFM 10
`define IFCODE_OFM 11
`define IFCODE_EMPTY 15

`define RD_SIZE_CFG 2**`NUM_CFG_WIDTH //12B x 256 all layers of NNs
`define RD_SIZE_FLGWEI  2**`GBFFLGWEI_ADDRWIDTH * 3/4//24
`define RD_SIZE_WEI 2**`GBFWEI_ADDRWIDTH * 3/4
`define RD_SIZE_FLGACT 2** `GBFFLGACT_ADDRWIDTH * 3/4//24
`define RD_SIZE_ACT 2** `GBFACT_ADDRWIDTH * 3/4
`define WR_SIZE_FLGOFM 2**`GBFFLGOFM_ADDRWIDTH *3/4
`define WR_SIZE_OFM 2**`GBFOFM_ADDRWIDTH * 3/4

// C3D DDR ADDR Allocation
// 12MB

// Layer base ADDR
`define ACT_ADDR        32'h0800_0000  // Max 6MB=> 60_0000
//`define FLGACT_ADDR     32'h0860_0000 // Max 1MB 8_0000
//`define WEI_ADDR        32'h0880_0000 // Max 32MB => 200_0000
//`define FLGWEI_ADDR     32'h0A80_0000 // Max 4MB => 40_0000
`define CFG_ADDR        32'h0AC0_0000 // 256 Layer 256x12 = 3072 < 2KB  _0800
`define OFM_ADDR 32'h0AC0_0800 // Max 6MB => 60_0000
`define FLGOFM_ADDR 32'h0B20_0800 // Max 1MB 10_0000

`define LAYER0_ACT_DDR_BASE 32'h0800_0000
`define LAYER1_ACT_DDR_BASE 32'h080A_5600
`define LAYER2_ACT_DDR_BASE 32'h0841_7600
`define LAYER3_ACT_DDR_BASE 32'h084F_3E00
`define LAYER4_ACT_DDR_BASE 32'h086A_CE00
`define LAYER5_ACT_DDR_BASE 32'h086E_4000
`define LAYER6_ACT_DDR_BASE 32'h0875_2400
`define LAYER7_ACT_DDR_BASE 32'h0876_0080

`define LAYER0_FLGACT_DDR_BASE 32'h0809_3000
`define LAYER1_FLGACT_DDR_BASE 32'h083B_5600
`define LAYER2_FLGACT_DDR_BASE 32'h084D_B600
`define LAYER3_FLGACT_DDR_BASE 32'h0867_BE00
`define LAYER4_FLGACT_DDR_BASE 32'h086D_DE00
`define LAYER5_FLGACT_DDR_BASE 32'h0874_6000
`define LAYER6_FLGACT_DDR_BASE 32'h0875_E800
`define LAYER7_FLGACT_DDR_BASE 32'h0876_C480


`define LAYER0_WEI_DDR_BASE 32'h0880_0000
`define LAYER1_WEI_DDR_BASE 32'h0880_16C8
`define LAYER2_WEI_DDR_BASE 32'h0883_E2C8
`define LAYER3_WEI_DDR_BASE 32'h0893_12C8
`define LAYER4_WEI_DDR_BASE 32'h08B1_72C8
`define LAYER5_WEI_DDR_BASE 32'h08EE_32C8
`define LAYER6_WEI_DDR_BASE 32'h0967_B2C8
`define LAYER7_WEI_DDR_BASE 32'h09E1_32C8


`define LAYER0_FLGWEI_DDR_BASE 32'h0880_1440
`define LAYER1_FLGWEI_DDR_BASE 32'h0883_76C8
`define LAYER2_FLGWEI_DDR_BASE 32'h0891_62C8
`define LAYER3_FLGWEI_DDR_BASE 32'h08AE_12C8
`define LAYER4_FLGWEI_DDR_BASE 32'h08E7_72C8
`define LAYER5_FLGWEI_DDR_BASE 32'h095A_32C8
`define LAYER6_FLGWEI_DDR_BASE 32'h09D3_B2C8
`define LAYER7_FLGWEI_DDR_BASE 32'h0A4D_32C8


// **********************************************************************
// Test File
// *********************************************************************************

// *********** THE layer's activations and weights are continous ******************

// `define FILE_DDR_ACT "../testbench/Data/dequant_data/prune_quant_extract_proportion/Activation_45_pool1_data.dat"
// `define FILE_DDR_FLGACT "../testbench/Data/dequant_data/prune_quant_extract_proportion/Activation_45_pool1_flag.dat"
// `define FILE_DDR_WEI "../testbench/Data/dequant_data/prune_quant_extract_proportion/Weight_45_conv2.float_weight_data.dat"
// `define FILE_DDR_FLGWEI "../testbench/Data/dequant_data/prune_quant_extract_proportion/Weight_45_conv2.float_weight_flag.dat"

// THE layer's activations and weights are split(every patch)
`define FILE_DDR_ADDR "../testbench/Data/GenTest/Patch_DDR_BASE_File.dat"

`define FILE_GBFFLGWEI "../testbench/Data/dequant_data/prune_quant_extract_proportion/Weight_45_conv2.float_weight_flag.dat"
`define FILE_GBFFLGWEI_FTRGRPADDR "../testbench/Data/GenTest/GBFFLGWEI_FrtGrpAddr.dat"
`define FILE_GBFWEI "../testbench/Data/GenTest/GBFWEI_DatWr.dat"
`define FILE_GBFWEI_FTRGRPADDR "../testbench/Data/GenTest/GBFWEI_FtrGrpAddr.dat"

`define FILE_GBFFLGACT "../testbench/Data/GenTest/GBFFLGACT_DatWr.dat"
`define FILE_GBFFLGACT_PATCHADDR "../testbench/Data/GenTest/GBFFLGACT_FtrGrpAddr.dat"
`define FILE_GBFACT "../testbench/Data/GenTest/GBFACT_DatWr.dat"
`define FILE_GBFACT_PATCHADDR "../testbench/Data/GenTest/GBFACT_FtrGrpAddr.dat"

`define FILE_GBFFLGOFM "../testbench/Data/GenTest/RAM_GBFFLGOFM_12B.dat"
`define FILE_GBFOFM "../testbench/Data/GenTest/RAM_GBFOFM_12B.dat"


`define FILE_PECMAC_FLGACT "../testbench/Data/GenTest/PECMAC_FlgAct_Gen.dat"
`define FILE_PECMAC_FLGACT_PATCHADDR "../testbench/Data/GenTest/PECMAC_FLGACT_PatchAddr.dat"

`define FILE_PECMAC_ACT "../testbench/Data/GenTest/PECMAC_Act_Gen.dat"
`define FILE_PECMAC_ACT_PATCHADDR `FILE_PECMAC_FLGACT_PATCHADDR // same line number

`define FILE_PECMAC_FLGWEI "../testbench/Data/GenTest/PECMAC_FlgWei_Ref.dat"
`define FILE_PECMAC_FLGWEI_FTRGRPADDR "../Data/GenTest/PECMAC_FLGWEI_FtrGrpAddr.dat"

`define FILE_PECMAC_WEI "../testbench/Data/GenTest/PECMAC_Wei_Ref.dat"
`define FILE_PECMAC_WEI_FTRGRPADDR "../Data/GenTest/PECMAC_WEI_FtrGrpAddr.dat"


//-----------------------------------------------------------
//Simple Log2 calculation function
//-----------------------------------------------------------
//up compute <=16 =>4
`define C_LOG_2(n) (\
(n) <= (1<<0) ? 0 : (n) <= (1<<1) ? 1 :\
(n) <= (1<<2) ? 2 : (n) <= (1<<3) ? 3 :\
(n) <= (1<<4) ? 4 : (n) <= (1<<5) ? 5 :\
(n) <= (1<<6) ? 6 : (n) <= (1<<7) ? 7 :\
(n) <= (1<<8) ? 8 : (n) <= (1<<9) ? 9 :\
(n) <= (1<<10) ? 10 : (n) <= (1<<11) ? 11 :\
(n) <= (1<<12) ? 12 : (n) <= (1<<13) ? 13 :\
(n) <= (1<<14) ? 14 : (n) <= (1<<15) ? 15 :\
(n) <= (1<<16) ? 16 : (n) <= (1<<17) ? 17 :\
(n) <= (1<<18) ? 18 : (n) <= (1<<19) ? 19 :\
(n) <= (1<<20) ? 20 : (n) <= (1<<21) ? 21 :\
(n) <= (1<<22) ? 22 : (n) <= (1<<23) ? 23 :\
(n) <= (1<<24) ? 24 : (n) <= (1<<25) ? 25 :\
(n) <= (1<<26) ? 26 : (n) <= (1<<27) ? 27 :\
(n) <= (1<<28) ? 28 : (n) <= (1<<29) ? 29 :\
(n) <= (1<<30) ? 30 : (n) <= (1<<31) ? 31 : 32)
//-----------------------------------------------------------

`define CEIL(a,b) ( \
 (a%b)? (a/b+1):(a/b) \
)

// `ifdef SYNTH_AC
//    //?
//   `define GBFWEI_ADDRWIDTH 8  //? 9 KBSSS< `BLOCK_DEPTH * `NUMPEC = 32 * 48 = 1536
//   `define GBFACT_ADDRWIDTH 11 //? 16KB
// `elsif SYNTH_FREQ
//   `define NUMPEB 16
//   `define GBFWEI_ADDRWIDTH 1  //?64 > 16*3
//   `define GBFACT_ADDRWIDTH 2 //?
// `elsif SYNTH_MINI
//   `define NUMPEB 16
//   `define GBFWEI_ADDRWIDTH 8  //?64 > log2(BLOCK_DEPTH* KERNEL_SIZE * NumPEC * NumPEB * NumBlk) = 32x9x3x2x2 = 3456
//   `define GBFACT_ADDRWIDTH 8 // log2( 16x16x32x NumBlk x NumFrmx (1-sparsity) )= 2048x32
// `endif
//

// ***** Load Balance parameters *******************
`define PSUM_ADDR_WIDTH 4
`define MAC_NUM 27
`define MAC_NUM_WIDTH `C_LOG_2(`MAC_NUM) // 27
`define REGACT_ADDR_WIDTH 7 // 128
`define REGFLGACT_ADDR_WIDTH 5 // 32
`define REGWEI_ADDR_WIDTH 4 // 16
`define REGFLGWEI_ADDR_WIDTH 5 // 16
`define CHN_DEPTH_WIDTH 5
`define REGACT_WR_WIDTH 8*16
`define REGFLGACT_WR_WIDTH 8*4
`define REGFLGWEI_WR_WIDTH 8*4
`define REGWEI_WR_WIDTH 8*8