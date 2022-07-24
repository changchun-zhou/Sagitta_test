// ****************************************************************************
// Hyper-parameter
// ****************************************************************************
`define DATA_WIDTH 8
`define NUMPEB 16
`define NUMPEC 3*`NUMPEB
`define PORT_DATAWIDTH `DATA_WIDTH * 12


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