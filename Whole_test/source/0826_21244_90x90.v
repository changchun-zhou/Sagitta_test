`timescale 1ns/1ps

`ifndef SIM 
    `define FPGA
`endif

`define RD_SIZE_CFG 64 //12B x 256 all layers of NNs
`define RD_SIZE_WEIADDR 54 //12B x 256 all layers of NNs
`define RD_SIZE_FLGWEI  512 //8KB
`define RD_SIZE_WEI 512 
`define RD_SIZE_FLGACT 512 //24 8KB
`define RD_SIZE_ACT 512 
`define WR_SIZE_FLGOFM 64 // 1KB
`define WR_SIZE_OFM 64

`define IFCODE_CFG      0
`define IFCODE_WEIADDR  3
`define IFCODE_FLGWEI   5
`define IFCODE_WEI      4
`define IFCODE_FLGACT   7
`define IFCODE_ACT      6

`define IFCODE_FLGOFM 1
`define IFCODE_OFM 2
`define IFCODE_EMPTY 15

`define NumBlk_weiaddr  2
`define NumBlk_flgwei   1
`define NumBlk_wei      2
`define NumBlk_flgact   4
`define NumBlk_act      4

`define BASEADDR_CFG        32'h0000_0000
`define BASEADDR_WEIADDR    `BASEADDR_CFG + 64 
`define BASEADDR_FLGWEI     `BASEADDR_WEIADDR + 64*`NumBlk_weiaddr
`define BASEADDR_WEI        `BASEADDR_FLGWEI + 512*`NumBlk_flgwei
`define BASEADDR_FLGACT     `BASEADDR_WEI + 512*`NumBlk_wei
`define BASEADDR_ACT        `BASEADDR_FLGACT + 512*`NumBlk_flgact
`define BASEADDR_OFM        `BASEADDR_ACT + 512*`NumBlk_act
`define BASEADDR_FLGOFM     `BASEADDR_OFM + 64*4
module  FPGA_asysFIFO #(
    parameter FREQUENCY = 5000)
(
    input                           I_clk_src_p        ,
    input                           I_clk_src_n        ,
    input                           I_rst       , // Not used
    input                           I_SW0            , // SW2: 1-8
    input                           I_SW1            ,
    input                           I_SW_N            ,
    input                           I_SW_C            ,
    input                           I_SW_S             ,
    input                           I_SW4            ,
    input                           I_SW5            ,
    output                          O_FPGA_clk_locked, // GPIO_LED_1_LS

    output                          Hold_I_spi_data ,

    output reg                         O_SW_clk        , // switch of clk_chip
    output reg                         O_reset_n       , // rst_n of whole chip

    output                          O_clk_in        , // clk_in of whole chip : clk_in of DLL

    output                          O_bypass        , // DLL
    output                          O_SW0           ,
    output                          O_SW1           ,
    input                           I_DLL_lock      ,
    input                           I_clk_out       , // clk_out of bypass_fifo
    input                           I_sck_out       , // clk_out of bypass_fifo
    input                           I_LAST_CLOCK_OUT,
    input                           I_LAST_SCK      ,

    inout[ 128              -1 : 0] IO_spi_data     , 

    input                           I_config_req    , // cfg_val : config_req 
    input                           I_near_full     , // wr_val  : near_full  
    input                           I_switch_rdwr   , // rd_rdy  : switch_rdwr  1:rd 0:wr
    output                          O_OE_req        , // OE_req_rd : pad_OE
    output                          O_spi_cs_n      , // ASICGB_cfg_rdy : I_spi_cs_n
    output                          O_spi_sck       , // clk_in of asyncFIFO

    output                          O_in_1          , // ASICGB_wr_rdy
    output                          O_in_2          , // ASICGB_rd_val

    output                          O_bypass_fifo   ,

    output                          O_Monitor_En    ,
   input [ 8               -1 : 0] I_Monitor_Out   ,
    input                           I_Monitor_OutVld
    
);  
    
//==============================================================================
// Constant Definition :
//==============================================================================
wire                                    clk;
wire                                    rst_n;
wire                                    clk_debug;

reg [ 4                         -1 : 0] cfg_info_d;
reg[ 4                         -1 : 0] cfg_info;
reg [ 128                       -1 : 0] O_spi_data_neg;
reg [ 128                       -1 : 0] rd_data;
reg  [ 128  - 1 : 0 ]                O_spi_data;
wire  [ 128  - 1 : 0 ]                O_spi_data_blk_ram;
wire  [ 128  - 1 : 0 ]                O_spi_data_blk_ram2;
wire                                    cfg_val;
reg                                     cfg_rdy;
reg                                     cfg_rdy_neg;

reg                                     wr_rdy_neg;
wire                                    wr_val;
reg                                     wr_rdy;

reg                                     rd_val_neg;
reg                                     rd_val;
wire                                    rd_rdy;
reg [ 20 -1 : 0] cnt_block[0 : 20];

wire[128    -1 : 0] blk_mem_dout;

reg rst_n_auto;
wire btn_reset_n;
wire btn_rst_n_auto;
reg [10 -1: 0] cnt_rst_n_auto;
wire btn_rst_n;
//==============================================================================
// Logic Design :
//==============================================================================

//==============================================================================
// Ports
wire error_config_req;

wire [3 -1 : 0]state_rst;
reg [3 -1 : 0]next_state_rst;
localparam IDLE_RST = 0, PULLDOWN_SW = 1, PULLDOWN_RST_N = 2, PULLUP_RST_N = 3, PULLUP_SW = 4;  
always @(*) begin
    next_state_rst = state_rst;
    case (state_rst)
      IDLE_RST    : if ( btn_reset_n )
                  next_state_rst = PULLDOWN_SW;

      PULLDOWN_SW  : next_state_rst = PULLDOWN_RST_N;

      PULLDOWN_RST_N    : next_state_rst = PULLUP_RST_N;

      PULLUP_RST_N : next_state_rst = PULLUP_SW;
    PULLUP_SW : if ( cnt_block[`IFCODE_WEIADDR] >= 3 | error_config_req)
                            next_state_rst = IDLE_RST;

      default : next_state_rst = IDLE_RST;
    endcase
end

always @ ( posedge clk or negedge btn_reset_n ) begin
    if ( !btn_reset_n ) begin
        O_reset_n <= 1;
    end else if ( next_state_rst == PULLDOWN_RST_N ) begin
        O_reset_n <= 0;
    end else if (next_state_rst == PULLUP_RST_N) begin
        O_reset_n <= 1;
    end
end
assign rst_n = O_reset_n;

always @ ( posedge clk or negedge btn_reset_n ) begin
    if ( !btn_reset_n ) begin
        O_SW_clk <= 0;
    end else if ( next_state_rst == PULLDOWN_SW ) begin
        O_SW_clk <= 0;
    end else if ( next_state_rst == PULLUP_SW ) begin
        O_SW_clk <= 1;
    end
end

// Mode Choose
assign O_bypass         = I_SW0;
assign O_bypass_fifo    = I_SW1;

// Reset/Start
wire trigger_SW_clk;
wire trigger_O_reset;
wire trigger_rst_auto;
wire [10 -1: 0]cnt_rst_n_auto_5d;



    flutter_free #(
        .FREQUENCY(FREQUENCY))
    flutter_free_trigger_SW_clk (
            .clk    (clk),
            .rst_n  (!I_SW_S),
            .btn    (I_SW_N),
            .signal (trigger_SW_clk)
        );


    flutter_free #(
        .FREQUENCY(FREQUENCY))
    flutter_free_trigger_O_reset (
            .clk    (clk),
            .rst_n  (!I_SW_S),
            .btn    (I_SW_C),
            .signal (trigger_O_reset)
        );
    flutter_free #(
        .FREQUENCY(FREQUENCY))
    flutter_free_trigger_rst_auto (
            .clk    (clk),
            .rst_n  (rst_n),
            .btn    (I_SW_S),
            .signal (trigger_rst_auto)
        );
`ifdef FPGA
    wire                                    clk_200M;
`else
    reg                                    clk_200M;
    // assign trigger_SW_clk = I_SW_N;
    // assign trigger_O_reset = I_SW_C;
    // assign trigger_rst_auto = I_SW_S;
    assign clk = I_clk_src_p;
`endif

assign btn_reset_n        =  ~trigger_O_reset;
assign btn_rst_n_auto        =  ~trigger_rst_auto;

// PLL Mode Choose
assign O_SW0            = I_SW4;
assign O_SW1            = I_SW5;

// 
assign O_clk_in         = clk;

// ASIC config
assign cfg_val          =  I_config_req;
// assign O_spi_cs_n       = O_bypass_fifo ? cfg_rdy_neg : 1'b0;

// ASIC read
assign rd_rdy           = I_switch_rdwr;
assign O_in_2           = rd_val_neg;

// ASIC write
assign O_in_1           = wr_rdy_neg;
assign wr_val           = I_near_full;

// IO_spi_data
assign IO_spi_data      = ~O_OE_req ? O_spi_data: 'bz;
// assign GBIF_wr_data  = IO_spi_data;
// Avoid synth out
assign Hold_I_spi_data  = |IO_spi_data ; 
assign O_spi_sck        = clk;
assign O_Monitor_En     = 0;
// ====================================================================================================================
// Top Control


// ====================================================================================================================
// state FSM
// ====================================================================================================================
reg [ 128                      - 1 : 0 ] O_data_out;
wire                                            spi_fifo_in_empty;
wire                                            spi_fifo_push;
reg [ 20                   - 1 : 0 ] wr_count;
wire[ 3                               - 1 : 0 ] state;
wire[ 3                               - 1 : 0 ] state_d,state_dd;
wire[ 3                               - 1 : 0 ] state_ddd;
reg [ 3                               - 1 : 0 ] next_state;
reg [ 10 : 0]                                            patch_flag_pre_rd;
reg [ 20          - 1 : 0 ] rd_size      ;

// reg config_ready;
wire config_req;
reg [20 -1 :0] Cfg_RD_Num;

localparam IDLE = 0, CONFIG = 1, WAIT = 2, RD_DATA = 3, RD_STILL = 4;  
always @(*) begin
    next_state = state;
    case (state)
      IDLE    : if ( config_req ) 
                  next_state = CONFIG;

      CONFIG  : next_state = WAIT;

      WAIT    : next_state = RD_DATA;

      RD_DATA : if ( rd_size == Cfg_RD_Num ) 
                  next_state = IDLE;

      default : next_state = IDLE;
    endcase
end

assign O_OE_req = ( state == RD_DATA || state_d == RD_DATA ) ? 0 : 1; // ?? enough time for pad convert
wire config_req_d;
assign error_config_req = (config_req==1 & config_req_d ==0) & state != 0 ;
// ====================================================================================================================
// pull down O_spi_cs_n
 reg O_spi_cs_n_;
 wire pullup_ahead_cs_n;

 always @(negedge clk or negedge rst_n) begin : proc_O_spi_cs_rx
  if(!rst_n) begin
    O_spi_cs_n_ <= 1;
  end else if( state == RD_DATA ) begin
        O_spi_cs_n_ <= 0;
  end else 
        O_spi_cs_n_ <= 1;
end

assign O_spi_cs_n = O_spi_cs_n_ || pullup_ahead_cs_n; //ahead 1 sck pull down;

reg [ 20 : 0] cnt_clk_200M;

always @ ( posedge clk_200M or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt_clk_200M <= 0;
    end else if ( clk && rd_size == Cfg_RD_Num && ~O_spi_cs_n_ ) begin // count half_clk when sending last rd data 
        cnt_clk_200M <= cnt_clk_200M + 1;
    end else
        cnt_clk_200M <= 0;
end

assign pullup_ahead_cs_n = cnt_clk_200M >= 3? 1: 0; // hold 20ns
// ====================================================================================================================
// O_spi_data

always @(negedge clk or negedge rst_n) begin : proc_O_spi_mosi 
    if( !rst_n ) begin
        O_spi_data <= 0;
        Cfg_RD_Num <= 0;
    end else if (state == CONFIG) begin
        // if (I_switch_rdwr) // 
        case(cfg_info)
          `IFCODE_CFG   :  Cfg_RD_Num <= `RD_SIZE_CFG-32*patch_flag_pre_rd[cfg_info];

          `IFCODE_WEIADDR: Cfg_RD_Num <= `RD_SIZE_WEIADDR - 32*patch_flag_pre_rd[cfg_info];
          `IFCODE_ACT   :  Cfg_RD_Num <= `RD_SIZE_ACT-32*patch_flag_pre_rd[cfg_info];
          `IFCODE_FLGACT:  Cfg_RD_Num <= `RD_SIZE_FLGACT-32*patch_flag_pre_rd[cfg_info];
          `IFCODE_WEI   :  Cfg_RD_Num <= `RD_SIZE_WEI-32*patch_flag_pre_rd[cfg_info];
          `IFCODE_FLGWEI:  Cfg_RD_Num <= `RD_SIZE_FLGWEI-32*patch_flag_pre_rd[cfg_info];

          `IFCODE_FLGOFM:  Cfg_RD_Num <= `WR_SIZE_FLGOFM; 
          `IFCODE_OFM   :  Cfg_RD_Num <= `WR_SIZE_OFM;
          default       :  Cfg_RD_Num   <= 2048;
        endcase
        O_spi_data <= 0;
    end else if( state == RD_DATA ) begin
        O_spi_data  <= blk_mem_dout;
    end else
        O_spi_data <= 128'dz;
end

always @ ( negedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        rd_size    <= 0;
    end else if ( state == CONFIG || state == IDLE ) begin
        rd_size <= 0;
    end else if ( state == RD_DATA ) begin
        rd_size <= rd_size + 1;
    end
end



always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cfg_info <= 0;
    end else if ( next_state == CONFIG ) begin // update
        cfg_info <= IO_spi_data[21:18]; // origin time when read
    end
end

reg [4 - 1: 0] patch_cfg_info_pre_rd [0:100];
reg [ 8 -1: 0] patch_addr_pre_rd;
reg [ 4-1: 0] patch_cfg_info_rd; // any time when need read data to asysFIFO
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        patch_cfg_info_rd <= 0;
    end else if ( next_state == CONFIG ) begin // update
        if (I_switch_rdwr)
            patch_cfg_info_rd <= IO_spi_data[21:18];
        else
            patch_cfg_info_rd <= patch_cfg_info_pre_rd[patch_addr_pre_rd];
    end
end

// integer k;
// always @ ( posedge clk or negedge rst_n ) begin
//     if ( !rst_n ) begin
//         for (k=0; k<100; k=k+1) begin
//             patch_cfg_info_pre_rd[k] <= 3; // sck period = 20; clk_chip =14;
//         end 
//     end 
// end


integer k;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        patch_cfg_info_pre_rd[0] <= 7; // sck period = 20; clk_chip =14;
        patch_cfg_info_pre_rd[1] <= 6;
        patch_cfg_info_pre_rd[2] <= 7;
        patch_cfg_info_pre_rd[3] <= 6;
        patch_cfg_info_pre_rd[4] <= 7;
        for(k=5; k<100; k=k+1)
            patch_cfg_info_pre_rd[k] <= 3;

    end 
end


always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        patch_flag_pre_rd <= 0;
        patch_addr_pre_rd <= 0;
    end else if ( state == RD_DATA && next_state == IDLE && !I_switch_rdwr) begin // update when write
        patch_flag_pre_rd[patch_cfg_info_pre_rd[patch_addr_pre_rd]] <= 1;
    end else if ( patch_flag_pre_rd && state == CONFIG && cfg_info == patch_cfg_info_pre_rd[patch_addr_pre_rd] ) begin
        patch_flag_pre_rd[patch_cfg_info_pre_rd[patch_addr_pre_rd]] <= 0;
        patch_addr_pre_rd <= patch_addr_pre_rd + 1;
    end
end

//==============================================================================
// read BRAM to prepare data

// when state == CONFIG; baseaddr like memcontroller_rd.v
// en_rd
reg [32     -1 : 0] blk_mem_baseaddr [0 : 15];
reg [32     -1 : 0] BASEADDR [0 : 15];
reg [32     -1 : 0] NumRd [0 : 15];
reg [32     -1 : 0] NumBlk [0 : 15];

reg [32     -1 : 0] blk_mem_addr;
wire                blk_mem_en;


always @(posedge clk or negedge rst_n) begin 
    if( !rst_n ) begin
        blk_mem_baseaddr[`IFCODE_CFG]       <= `BASEADDR_CFG;
        blk_mem_baseaddr[`IFCODE_WEIADDR]   <= `BASEADDR_WEIADDR;
        blk_mem_baseaddr[`IFCODE_WEI]       <= `BASEADDR_WEI;
        blk_mem_baseaddr[`IFCODE_FLGWEI]    <= `BASEADDR_FLGWEI;
        blk_mem_baseaddr[`IFCODE_FLGACT]    <= `BASEADDR_FLGACT;
        blk_mem_baseaddr[`IFCODE_ACT]       <= `BASEADDR_ACT;
        blk_mem_baseaddr[`IFCODE_OFM]       <= `BASEADDR_OFM;
        blk_mem_baseaddr[`IFCODE_FLGOFM]    <= `BASEADDR_FLGOFM;

        BASEADDR[`IFCODE_CFG]       <= `BASEADDR_CFG;
        BASEADDR[`IFCODE_WEIADDR]   <= `BASEADDR_WEIADDR;
        BASEADDR[`IFCODE_WEI]       <= `BASEADDR_WEI;
        BASEADDR[`IFCODE_FLGWEI]    <= `BASEADDR_FLGWEI;
        BASEADDR[`IFCODE_FLGACT]    <= `BASEADDR_FLGACT;
        BASEADDR[`IFCODE_ACT]       <= `BASEADDR_ACT;
        BASEADDR[`IFCODE_OFM]       <= `BASEADDR_OFM;
        BASEADDR[`IFCODE_FLGOFM]    <= `BASEADDR_FLGOFM;

        NumRd[`IFCODE_CFG]       <= 64;
        NumRd[`IFCODE_WEIADDR]   <= 54;
        NumRd[`IFCODE_WEI]       <= 512;
        NumRd[`IFCODE_FLGWEI]    <= 512;
        NumRd[`IFCODE_FLGACT]    <= 512;
        NumRd[`IFCODE_ACT]       <= 512;
        NumRd[`IFCODE_OFM]       <= 64;
        NumRd[`IFCODE_FLGOFM]    <= 64;

        NumBlk[`IFCODE_CFG]       <= 1;
        NumBlk[`IFCODE_WEIADDR]   <= `NumBlk_weiaddr;
        NumBlk[`IFCODE_WEI]       <= `NumBlk_wei;
        NumBlk[`IFCODE_FLGWEI]    <= `NumBlk_flgwei   ;
        NumBlk[`IFCODE_FLGACT]    <= `NumBlk_flgact;
        NumBlk[`IFCODE_ACT]       <= `NumBlk_act   ;
        NumBlk[`IFCODE_OFM]       <= 1024;
        NumBlk[`IFCODE_FLGOFM]    <= 1024;
    // update only when real read finish 
    end else if (state == RD_DATA && next_state == IDLE && I_switch_rdwr) begin
        // loop read 
        blk_mem_baseaddr[cfg_info] <= (blk_mem_baseaddr[cfg_info] - BASEADDR[cfg_info] + NumRd[cfg_info] >= NumRd[cfg_info]*NumBlk[cfg_info])?
                                    (blk_mem_baseaddr[cfg_info] + NumRd[cfg_info] - NumRd[cfg_info]*NumBlk[cfg_info]) : 
                                    (blk_mem_baseaddr[cfg_info] + NumRd[cfg_info]);
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        blk_mem_addr <= 0;
    end else if ( state == RD_DATA && next_state == IDLE ) begin // reset
        blk_mem_addr <= 0;
    end else if ( state == CONFIG ) begin // set
        blk_mem_addr <= blk_mem_baseaddr[patch_cfg_info_rd];
    end else if ( blk_mem_en ) begin // update
        blk_mem_addr <= blk_mem_addr + 1;
    end
end

// ahead 1 clk to sysn dout and RD_DATA

assign blk_mem_en = next_state == RD_DATA;

integer i;
always @ ( posedge clk or negedge btn_reset_n ) begin
    if ( !btn_reset_n ) begin
        for(i=0; i<=20; i=i+1)
            cnt_block[i] <= 0;
    end else if ( state_rst != PULLUP_SW) begin
        for(i=0; i<=20; i=i+1)
            cnt_block[i] <= 0;
    end else if ( state == CONFIG ) begin
            cnt_block[cfg_info] <= cnt_block[cfg_info] + 1;
    end
end

reg [20      -1 : 0] total_block;

always @ ( posedge clk or negedge btn_reset_n ) begin
    if ( !btn_reset_n ) begin
        total_block <= 0;
    end else if ( state == CONFIG ) begin
        total_block <= total_block + 1;
    end
end

//==============================================================================
// FPGA ILA :
//==============================================================================

`ifdef FPGA

    wire clk_ibufg;
    wire    clk_400M;
    IBUFGDS #
    (
    .DIFF_TERM ("FALSE"),
    .IBUF_LOW_PWR ("FALSE")
    )
    u_ibufg_sys_clk
    (
    .I (I_clk_src_p), //差分时钟正端输入
    .IB (I_clk_src_n), // 差分时钟负端输入
    .O (clk_ibufg) //时钟缓冲输出
    );

    clk_wiz clk_wiz
    (
    // Clock out ports
    .clk_out1(clk), // output clk_out1&nbsp;&nbsp;5MHZ&nbsp;&nbsp;
    .clk_out2(clk_200M),
    // Status and control signals
    .locked(O_FPGA_clk_locked), // output locked
    // Clock in ports
    .clk_in1(clk_ibufg));
     
    blk_mem_gen_0 blk_mem_128x2_18 (
      .clka(clk),    // input wire clka
      .ena(blk_mem_en),
      .addra(blk_mem_addr*16),  // input wire [31 : 0] addra
      .douta(blk_mem_dout)  // output wire [127 : 0] douta
    );

    ILA_200bit ILA_data (
        .clk(clk_ibufg), // input wire clk

        .probe0(IO_spi_data), // input wire [127:0]  probe0  
        .probe1(patch_addr_pre_rd[0 +: 3]), // input wire [3:0]  probe1 
        .probe2({I_SW_C, I_SW_N,rst_n, rst_n_auto, trigger_SW_clk,  I_config_req, pullup_ahead_cs_n}), // input wire [7:0]  probe2 
        .probe3({I_config_req,  I_switch_rdwr, O_OE_req, O_spi_cs_n, O_spi_sck}), // input wire [5:0]  probe3 
        .probe4({O_clk_in, O_spi_sck, I_clk_out, I_sck_out, I_LAST_CLOCK_OUT, I_LAST_SCK}), // input wire [5:0]  probe4 
        .probe5(O_OE_req), // input wire [0:0]  probe5 
        .probe6(patch_flag_pre_rd[9:0]), // input wire [9:0]  probe6 
        .probe7({patch_cfg_info_rd[0 +: 4], rd_size[0 +: 10], cfg_info, state }), // input wire [30:0]  probe7
        .probe8({O_clk_in, O_FPGA_clk_locked, I_DLL_lock, O_SW1, O_SW0, btn_reset_n, O_SW_clk, O_reset_n,O_bypass_fifo, O_bypass}), //16
        .probe9({blk_mem_dout, total_block[0 +: 8]}), // 128
        .probe10({blk_mem_addr, blk_mem_en}), // 32
        .probe11({cnt_block[`IFCODE_WEIADDR]})// 16
    );
`else 
    initial begin
        clk_200M = 1'b0;
        forever #(2.5) clk_200M = ~clk_200M;
    end

    ROM #(
            .DATA_WIDTH(128),
            .INIT("/workspace/home/zhoucc/Share/Chip_test/Whole_test/scripts/test_data_set/1244_90x90/ROM_data/ROM_distribution_modify.txt"),
            .ADDR_WIDTH(16),
            .INITIALIZE_FIFO("yes")
        ) inst_ROM (
            .clk      (clk),
            .address  (blk_mem_addr),
            .enable   (blk_mem_en),
            .data_out (blk_mem_dout)
        );


`endif

//==============================================================================
Delay #(
        .NUM_STAGES(1),
        .DATA_WIDTH(1)
    ) inst_Delay_config_req (
        .CLK     (clk),
        .RESET_N (rst_n),
        .DIN     (I_config_req),
        .DOUT    (config_req)
    );
Delay #(
        .NUM_STAGES(1),
        .DATA_WIDTH(1)
    ) inst_Delay_config_req_d (
        .CLK     (clk),
        .RESET_N (rst_n),
        .DIN     (config_req),
        .DOUT    (config_req_d)
    );

Delay #(
        .NUM_STAGES(1),
        .DATA_WIDTH(3)
    ) inst_Delay_state (
        .CLK     (clk),
        .RESET_N (rst_n),
        .DIN     (next_state),
        .DOUT    (state)
    );
Delay #(
        .NUM_STAGES(1),
        .DATA_WIDTH(3)
    ) inst_Delay_state_d (
        .CLK     (clk),
        .RESET_N (rst_n),
        .DIN     (state),
        .DOUT    (state_d)
    );

Delay #(
        .NUM_STAGES(5),
        .DATA_WIDTH(10)
    ) inst_Delay_cnt_rst_n_auto_5d (
        .CLK     (clk),
        .RESET_N (btn_reset_n),
        .DIN     (cnt_rst_n_auto),
        .DOUT    (cnt_rst_n_auto_5d)
    );

Delay #(
        .NUM_STAGES(1),
        .DATA_WIDTH(3)
    ) inst_Delay_state_rst (
        .CLK     (clk),
        .RESET_N (btn_reset_n),
        .DIN     (next_state_rst),
        .DOUT    (state_rst)
    );
endmodule
