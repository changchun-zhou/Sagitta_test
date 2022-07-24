
// `define SYNTH_MINI //
// `define SYNTH_FREQ
`define SYNTH_AC // With SRAM

// ****************************************************************************
// ONLY PRE-Sim parameter
// ****************************************************************************
`define CLOCK_PERIOD_ASIC 10 // 10ns clock period for sim
`define CLOCK_PERIOD_FPGA 12 // 12ns clock period

// ****************************************************************************
// Hyper-parameter
// ****************************************************************************
`define DATA_WIDTH 8
`define NUM_PEB 16
`define PORT_WIDTH `DATA_WIDTH * 16

`define MONITOR_IN_WIDTH  212+100+128*`NUM_PEB+24+100+64
`define MONITOR_OUT_WIDTH  8
// ****************************************************************************
// Neural Networks parameter
// ****************************************************************************
`define BLOCK_DEPTH 32
`define KERNEL_SIZE 9
`define MAX_DEPTH 8192*4 // c3d's conv:512 i3d's conv:1024; fc: 8192
`define LENROW 16
`define LENPSUM 14
`define POOLCFG_WIDTH 33 // 20 + 8 + 1 + 1 + 3

// ************* Config parameters *****************
`define FRAME_WIDTH 6
`define PATCH_WIDTH 8
`define FTRGRP_WIDTH `C_LOG_2( `MAX_DEPTH /  `NUM_PEB )
`define BLK_WIDTH   `C_LOG_2(`MAX_DEPTH/`BLOCK_DEPTH)   //ONLY FOR CONV, FC? 5
`define LAYER_WIDTH 6 //64 layers
`define NUM_CFG_WIDTH `LAYER_WIDTH


// ****************************************************************************
// Global Buffer parameter
// ****************************************************************************

`define PSUM_WIDTH 32 // Because of test_data_presim

// ****************************************************************************
// Interface parameter
// ****************************************************************************
`define ASYSFIFO_ADDRWIDTH 5

`define IFCODE_CFG      0
`define IFCODE_WEIADDR  3
`define IFCODE_FLGWEI   5
`define IFCODE_WEI      4
`define IFCODE_FLGACT   7
`define IFCODE_ACT      6

`define IFCODE_FLGOFM 1
`define IFCODE_OFM 2
`define IFCODE_EMPTY 15

`define RD_SIZE_CFG 64 //12B x 256 all layers of NNs
`define RD_SIZE_WEIADDR 54 //12B x 256 all layers of NNs
`define RD_SIZE_FLGWEI  512 //8KB
`define RD_SIZE_WEI 512
`define RD_SIZE_FLGACT 512 //24 8KB
`define RD_SIZE_ACT 512
`define WR_SIZE_FLGOFM 64 // 1KB
`define WR_SIZE_OFM 64

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

// ***** Load Balance parameters *******************
`define PSUM_ADDR_WIDTH 4
`define MAC_NUM 27
`define MAC_NUM_WIDTH `C_LOG_2(`MAC_NUM) // 27
`define ADDR_WIDTH_ALL `C_LOG_2(`MAX_DEPTH)
`define MAX_DEPTH_WIDTH `C_LOG_2(`MAX_DEPTH)
// `define REGACT_ADDR_WIDTH 13 // 8192
`define REGFLGACT_ADDR_WIDTH `C_LOG_2(`MAX_DEPTH*`LENROW*`LENROW/`BLOCK_DEPTH) //
// `define REGWEI_ADDR_WIDTH 4 // 16
`define REGFLGWEI_ADDR_WIDTH 5 // 32

`define ACT_NUM_WIDTH `C_LOG_2(`MAX_DEPTH*`LENROW*`LENROW) + `FRAME_WIDTH

`define CHN_DEPTH_WIDTH 5

`define REGACT_WR_WIDTH 8*16
`define REGFLGACT_WR_WIDTH 8*4
`define REGFLGWEI_WR_WIDTH 8*8
`define REGWEI_WR_WIDTH 8*8
`define SRAMWEI_WR_WIDTH 8*16 // 16B

`define LINE 1

// *****************************************************************************
// BUS parameters
// *****************************************************************************
`define BUSWIDTH_PSUM `PSUM_WIDTH*`LENROW // One Row
`define BUSWIDTH_FLGWEI `DATA_WIDTH*8
`define BUSWIDTH_WEI  `DATA_WIDTH*16 + `C_LOG_2(`MAC_NUM)
`define BUSWIDTH_FLGACT `DATA_WIDTH*4
`define BUSWIDTH_ACT   `DATA_WIDTH*16
// *****************************************************************************
// PEB's Cache parameters
// *****************************************************************************
