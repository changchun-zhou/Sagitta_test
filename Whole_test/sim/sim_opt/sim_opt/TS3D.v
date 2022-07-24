// This is a simple example.
// You can make a your own header file and set its path to settings.
// (Preferences > Package Settings > Verilog Gadget > Settings - User)
//
//      "header": "Packages/Verilog Gadget/template/verilog_header.v"
//
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : zhouchch@pku.edu.cn
// File   : TS3D.v
// Create : 2020-07-14 08:56:43
// Revise : 2020-08-10 21:11:33
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

// `include
// `ifdef SYNTH
`include "../source/include/dw_params_presim.vh"
// `endif
module TS3D (
    input                               clk             ,
    input                               rst_n           ,
    // output                              Reset           ,
    // Interface 
    input                               IFGB_cfg_rdy    ,
    output                              GBIF_cfg_val    ,
    output[ 4                   -1 : 0] GBIF_cfg_info   , // {id, w/r}
    // 
    input                               IFGB_wr_rdy     ,
    output                              GBIF_wr_val     ,
    output[ `PORT_WIDTH         -1 : 0] GBIF_wr_data    ,
    // flagwei > wei_address > wei > flagact > act
    input                               IFGB_rd_val     ,
    output                              GBIF_rd_rdy     ,
    input [`PORT_WIDTH          -1 : 0] IFGB_rd_data    ,
    output [ `MONITOR_IN_WIDTH  -1 : 0] TS3DMONITOR
 

);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================





//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire                              CFGIF_rdy               ;
wire                              IFCFG_val               ;
wire [ `PORT_WIDTH        -1 : 0] IFCFG_data              ;
wire                              GBCFG_rdy               ;
wire                              CFGGB_val               ;
wire [ 4                  -1 : 0] CFGGB_num_alloc_wei     ;
wire [ 4                  -1 : 0] CFGGB_num_alloc_flgwei  ;
wire [ 4                  -1 : 0] CFGGB_num_alloc_flgact  ;
wire [ 4                  -1 : 0] CFGGB_num_alloc_act     ;
wire [ 5                  -1 : 0] CFGGB_num_total_flgwei  ;
wire [ 5                  -1 : 0] CFGGB_num_total_flgact  ;
wire [ 6                  -1 : 0] CFGGB_num_total_act     ;
wire [12                  -1 : 0] CFGGB_num_loop_wei      ;
wire [8                   -1 : 0] CFGGB_num_loop_act      ;
wire                              CCUGB_pullback_wei      ;
wire                              CCUGB_pullback_act      ;
wire                              CCUGB_reset_all         ;
wire                              POOLCFG_rdy             ;
wire                              CFGPOOL_val             ;
wire [`POOLCFG_WIDTH      -1 : 0] CFGPOOL_data            ;
wire                              CCUPOOL_reset           ;
wire  [ 1*`NUM_PEB         -1 : 0] CCUPEB_next_block       ;
wire  [ 1*`NUM_PEB         -1 : 0] CCUPEB_reset_act        ;
wire  [ 1*`NUM_PEB         -1 : 0] CCUPEB_reset_wei        ;
wire  [ 1*`NUM_PEB         -1 : 0] PEBCCU_fnh_block        ;


wire [ 1*`NUM_PEB                                    -1 : 0] ARBPEB_Fnh      ;
wire [ 1*1                                           -1 : 0] ACTGB_rdy       ;
wire [ 1*1                                           -1 : 0] GBACT_val       ;
wire [`BUSWIDTH_ACT*1                                -1 : 0] GBACT_data      ;
wire [ 1*1                                           -1 : 0] FLGACTGB_rdy    ;
wire [ 1*1                                           -1 : 0] GBFLGACT_val    ;
wire [`BUSWIDTH_FLGACT*1                             -1 : 0] GBFLGACT_data   ;
wire [ 1*1                                           -1 : 0] PEBACT_rdy      ;
wire [ 1*1                                           -1 : 0] ACTPEB_val      ;
wire [ `BUSWIDTH_ACT*1                               -1 : 0] ACTPEB_data     ;
wire [ 1*1                                           -1 : 0] PEBFLGACT_rdy   ;
wire [ 1*1                                           -1 : 0] FLGACTPEB_val   ;
wire [`BUSWIDTH_FLGACT*1                             -1 : 0] FLGACTPEB_data  ;
wire [ 1*`NUM_PEB                                     -1 : 0] GBWEI_instr_rdy ;
wire [ 1*`NUM_PEB                                     -1 : 0] WEIGB_instr_val ;
wire [`DATA_WIDTH*`NUM_PEB                            -1 : 0] WEIGB_instr_data;
wire [ 1*`NUM_PEB                                     -1 : 0] WEIGB_rdy       ;
wire [ 1*`NUM_PEB                                     -1 : 0] GBWEI_val       ;
wire [ `BUSWIDTH_WEI                                  -1 : 0] GBWEI_data      ;
wire [ 1*`NUM_PEB                                     -1 : 0] FLGWEIGB_rdy    ;
wire [ 1*`NUM_PEB                                     -1 : 0] GBFLGWEI_val    ;
wire [ `BUSWIDTH_FLGWEI                               -1 : 0] GBFLGWEI_data   ;
wire [ 1*3*`NUM_PEB                                   -1 : 0] PSUMGB_val      ;
wire [ (`PSUM_WIDTH*`LENROW)*3*`NUM_PEB               -1 : 0] PSUMGB_data     ;
wire [ 1*3*`NUM_PEB                                   -1 : 0] GBPSUM_rdy      ;
wire [ 1*3*`NUM_PEB                                   -1 : 0] PSUMGB_rdy      ;
wire [ `BUSWIDTH_PSUM                                 -1 : 0] GBPSUM_data     ;
wire [ 1*3*`NUM_PEB                                   -1 : 0] GBPSUM_val      ;


wire                               GBPSUMCFG_rdy        ;
wire                               CFGGBPSUM_val        ;
wire [6                    -1 : 0] CFGGBPSUM_num_frame  ;
wire [6                    -1 : 0] CFGGBPSUM_num_block  ;
wire                               CCUGB_reset_patch    ;
wire [6*`NUM_PEB                    -1 : 0] CCUGB_frame          ;
wire [6*`NUM_PEB                    -1 : 0] CCUGB_block          ;

wire [`PSUM_WIDTH*`NUM_PEB   -1 : 0] GBPOOL_data     ;
wire [`DATA_WIDTH           -1 : 0] POOLGB_addr     ;
wire                               GBPOOL_val      ;
wire                               POOLGB_rdy      ;
wire                               POOLGB_fnh      ;

wire                                  CCUPOOL_En      ;
// wire                                  POOLGB_fnh;
wire                                  CCUPOOL_ValFrm  ;
wire                                  CCUPOOL_ValDelta;
wire                                  BF_rdy          ;
wire                                  BF_val          ;
wire [`DATA_WIDTH              -1 : 0] BF_addr         ;
wire [`DATA_WIDTH              -1 : 0] BF_data         ;
wire                                  BF_flg_rdy      ;
wire                                  BF_flg_val      ;
wire [`NUM_PEB              -1 : 0] BF_flg_data     ;

wire                       CCUPOOL_layer_fnh       ;
wire                       POOLCCU_clear_up        ;
wire                       IFPOOL_rdy      ;
wire                       POOLIF_val      ;
wire [`PORT_WIDTH   -1 : 0] POOLIF_data     ;
wire                       IFPOOL_flg_rdy  ;
wire                       POOLIF_flg_val  ;
wire [`PORT_WIDTH   -1 : 0] POOLIF_flg_data ;


wire [ 212                   -1 : 0] CCUMONITOR;
wire [ 100                   -1 : 0] GBMONITOR;
wire [ 128*`NUM_PEB+24         -1 : 0] GBPSUMMONITOR;
wire [ 100                  -1 : 0] PELMONITOR;
wire [ 64                   -1 : 0] POOLOUTMONITOR;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
assign TS3DMONITOR = {
    GBPSUMMONITOR,
    GBMONITOR,
    PELMONITOR,
    POOLOUTMONITOR,
    CCUMONITOR
};

//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
assign ASICCCU_start = 1'b1;
CCU #(
    .NUM_PEB(`NUM_PEB),
    .PORT_WIDTH(`PORT_WIDTH),
    .POOL_WIDTH(`POOLCFG_WIDTH),
    .FIFO_ADDR_WIDTH(`LAYER_WIDTH)
    ) inst_CCU (
        .clk                    (clk),
        .rst_n                  (rst_n),
        .ASICCCU_start          (ASICCCU_start),
        .CFGIF_rdy              (CFGIF_rdy),
        .IFCFG_val              (IFCFG_val),
        .IFCFG_data             (IFCFG_data),
        .GBCFG_rdy              (GBCFG_rdy),
        .CFGGB_val              (CFGGB_val),
        .CFGGB_num_alloc_wei    (CFGGB_num_alloc_wei),
        .CFGGB_num_alloc_flgwei (CFGGB_num_alloc_flgwei),
        .CFGGB_num_alloc_flgact (CFGGB_num_alloc_flgact),
        .CFGGB_num_alloc_act    (CFGGB_num_alloc_act),
        .CFGGB_num_total_flgwei (CFGGB_num_total_flgwei),
        .CFGGB_num_total_flgact (CFGGB_num_total_flgact),
        .CFGGB_num_total_act    (CFGGB_num_total_act),
        .CFGGB_num_loop_wei     (CFGGB_num_loop_wei),
        .CFGGB_num_loop_act     (CFGGB_num_loop_act),
        .CCUGB_pullback_wei     (CCUGB_pullback_wei),
        .CCUGB_pullback_act     (CCUGB_pullback_act),
        .CCUGB_reset_all        (CCUGB_reset_all),
        .POOLCFG_rdy            (POOLCFG_rdy),
        .CFGPOOL_val            (CFGPOOL_val),
        .CFGPOOL_data           (CFGPOOL_data),
        .CCUPOOL_reset          (CCUPOOL_reset),
        .CCUPEB_next_block      (CCUPEB_next_block),
        .CCUPEB_reset_act       (CCUPEB_reset_act),
        .CCUPEB_reset_wei       (CCUPEB_reset_wei),
        .PEBCCU_fnh_block       (PEBCCU_fnh_block),
        .GBPSUMCFG_rdy          (GBPSUMCFG_rdy          ),
        .CFGGBPSUM_val          (CFGGBPSUM_val          ),
        .CFGGBPSUM_num_frame    (CFGGBPSUM_num_frame    ),
        .CFGGBPSUM_num_block    (CFGGBPSUM_num_block    ),
        .CCUGB_reset_patch      (CCUGB_reset_patch      ),
        .PSUMGB_val             (PSUMGB_val),
        .CCUGB_frame            (CCUGB_frame            ),
        .CCUGB_block            (CCUGB_block            ),
        .CCUPOOL_En             (CCUPOOL_En             ),
        .POOLGB_fnh             (POOLGB_fnh),
        .CCUPOOL_ValFrm         (CCUPOOL_ValFrm         ),
        .CCUPOOL_ValDelta       (CCUPOOL_ValDelta       ),
        .CCUPOOL_layer_fnh      (CCUPOOL_layer_fnh      ),
        .POOLCCU_clear_up       (POOLCCU_clear_up       ),
        .CCUMONITOR             (CCUMONITOR)
    );

assign PELMONITOR = { // 100
    ACTGB_rdy, 
    GBACT_val,
    FLGACTGB_rdy,
    GBFLGACT_val,
    GBWEI_instr_rdy, // 16
    WEIGB_instr_val, // 16
    WEIGB_rdy, // 16
    GBWEI_val, // 16
    FLGWEIGB_rdy, // 16
    GBFLGWEI_val // 16
};


PEL #(
        .NUM_PEB(`NUM_PEB)
    ) inst_PEL (
        .clk              (clk),
        .rst_n            (rst_n),
        .next_block       (CCUPEB_next_block),
        .reset_act        (CCUPEB_reset_act),
        .reset_wei        (CCUPEB_reset_wei),
        .ARBPEB_Fnh       (PEBCCU_fnh_block),
        .ACTGB_Rdy        (ACTGB_rdy),
        .GBACT_Val        (GBACT_val),
        .GBACT_Data       (GBACT_data),
        .FLGACTGB_rdy     (FLGACTGB_rdy),
        .GBFLGACT_val     (GBFLGACT_val),
        .GBFLGACT_data    (GBFLGACT_data),
        // .PEBACT_rdy       (PEBACT_rdy),
        // .ACTPEB_val       (ACTPEB_val),
        // .ACTPEB_data      (ACTPEB_data),
        // .PEBFLGACT_rdy    (PEBFLGACT_rdy),
        // .FLGACTPEB_val    (FLGACTPEB_val),
        // .FLGACTPEB_data   (FLGACTPEB_data),
        .GBWEI_Instr_Rdy  (GBWEI_instr_rdy),
        .WEIGB_Instr_Val  (WEIGB_instr_val),
        .WEIGB_Instr_Data (WEIGB_instr_data),
        .WEIGB_Rdy        (WEIGB_rdy),
        .GBWEI_Val        (GBWEI_val),
        .GBWEI_Data       (GBWEI_data),
        .FLGWEIGB_Rdy     (FLGWEIGB_rdy),
        .GBFLGWEI_Val     (GBFLGWEI_val),
        .GBFLGWEI_Data    (GBFLGWEI_data),
        .PSUMGB_val       (PSUMGB_val),
        .PSUMGB_data      (PSUMGB_data),
        .GBPSUM_rdy       (GBPSUM_rdy),
        .PSUMGB_rdy       (PSUMGB_rdy),
        .GBPSUM_data      (GBPSUM_data),
        .GBPSUM_val       (GBPSUM_val)
    );

GB #(
    .PORT_WIDTH(`PORT_WIDTH),
    .INSTR_WIDTH(`DATA_WIDTH),
    .NUM_PEB(`NUM_PEB),
    .WEI_WR_WIDTH(`BUSWIDTH_WEI),
    .FLGWEI_WR_WIDTH(`BUSWIDTH_FLGWEI),
    .ACT_WR_WIDTH(`BUSWIDTH_ACT),
    .FLGACT_WR_WIDTH(`BUSWIDTH_FLGACT)
    ) inst_GB (
    .clk                    (clk),
    .rst_n                  (rst_n),
    .GBCFG_rdy              (GBCFG_rdy),
    .CFGGB_val              (CFGGB_val),
    .CFGGB_num_alloc_wei    (CFGGB_num_alloc_wei),
    .CFGGB_num_alloc_flgwei (CFGGB_num_alloc_flgwei),
    .CFGGB_num_alloc_flgact (CFGGB_num_alloc_flgact),
    .CFGGB_num_alloc_act    (CFGGB_num_alloc_act),
    .CFGGB_num_total_flgwei ({1'b0,CFGGB_num_total_flgwei}),
    .CFGGB_num_total_flgact ({1'b0,CFGGB_num_total_flgact}),
    .CFGGB_num_total_act    (CFGGB_num_total_act),
    .CFGGB_num_loop_wei     (CFGGB_num_loop_wei),
    .CFGGB_num_loop_act     (CFGGB_num_loop_act),
    .CCUGB_pullback_wei     (CCUGB_pullback_wei),
    .CCUGB_pullback_act     (CCUGB_pullback_act),
    .CCUGB_reset_all        (CCUGB_reset_all),
    .IFGB_cfg_rdy           (IFGB_cfg_rdy),
    .GBIF_cfg_val           (GBIF_cfg_val),
    .GBIF_cfg_info          (GBIF_cfg_info),
    .IFGB_wr_rdy            (IFGB_wr_rdy),
    .GBIF_wr_val            (GBIF_wr_val),
    .GBIF_wr_data           (GBIF_wr_data),
    .IFGB_rd_val            (IFGB_rd_val),
    .GBIF_rd_rdy            (GBIF_rd_rdy),
    .IFGB_rd_data           (IFGB_rd_data),
    .GBWEI_instr_rdy        (GBWEI_instr_rdy),
    .WEIGB_instr_val        (WEIGB_instr_val),
    .WEIGB_instr_data       (WEIGB_instr_data),
    .WEIGB_rdy              (WEIGB_rdy),
    .GBWEI_val              (GBWEI_val),
    .GBWEI_data             (GBWEI_data),
    .FLGWEIGB_rdy           (FLGWEIGB_rdy),
    .GBFLGWEI_val           (GBFLGWEI_val),
    .GBFLGWEI_data          (GBFLGWEI_data),
    .ACTGB_rdy              (ACTGB_rdy),
    .GBACT_val              (GBACT_val),
    .GBACT_data             (GBACT_data),
    .FLGACTGB_rdy           (FLGACTGB_rdy),
    .GBFLGACT_val           (GBFLGACT_val),
    .GBFLGACT_data          (GBFLGACT_data),
    .IFPOOL_flg_rdy         (IFPOOL_flg_rdy),
    .POOLIF_flg_val         (POOLIF_flg_val),
    .POOLIF_flg_data        (POOLIF_flg_data),
    .IFPOOL_rdy             (IFPOOL_rdy),
    .POOLIF_val             (POOLIF_val),
    .POOLIF_data            (POOLIF_data),
    .CFGIF_rdy              (CFGIF_rdy),
    .IFCFG_val              (IFCFG_val),
    .IFCFG_data             (IFCFG_data),
    .GBMONITOR              (GBMONITOR)
    );
GB_PSUM #(
        .NUM_PEB(`NUM_PEB),
        .PSUM_WIDTH(`PSUM_WIDTH),
        .PSUMBUS_WIDTH(`BUSWIDTH_PSUM)
    ) inst_GB_PSUM (
        .clk               (clk),
        .rst_n             (rst_n),
        .GBCFG_rdy         (GBPSUMCFG_rdy),
        .CFGGB_val         (CFGGBPSUM_val),
        .CFGGB_num_frame   (CFGGBPSUM_num_frame),
        .CFGGB_num_block   (CFGGBPSUM_num_block),
        .CCUGB_reset_patch (CCUGB_reset_patch),
        .CCUGB_frame       (CCUGB_frame),
        .CCUGB_block       (CCUGB_block),
        .PSUMGB_rdy        (PSUMGB_rdy),
        .GBPSUM_val        (GBPSUM_val),
        .GBPSUM_data       (GBPSUM_data),
        .GBPSUM_rdy        (GBPSUM_rdy),
        .PSUMGB_val        (PSUMGB_val),
        .PSUMGB_data       (PSUMGB_data),
        .GBPOOL_data       (GBPOOL_data),
        .POOLGB_addr       (POOLGB_addr),
        .GBPOOL_val        (GBPOOL_val),
        .POOLGB_rdy        (POOLGB_rdy),
        .POOLGB_fnh        (POOLGB_fnh),
        .GBPSUM_debug      (GBPSUMMONITOR) 
    );

POOL #(
        .DATA_WIDTH(`DATA_WIDTH),
        .FLAG_WIDTH(`NUM_PEB)
    ) inst_POOL (
        .clk              (clk),
        .rst_n            (rst_n),
        .CCUPOOL_reset    (CCUPOOL_reset),
        .POOLCFG_rdy      (POOLCFG_rdy),
        .CFGPOOL_val      (CFGPOOL_val),
        .CFGPOOL_data     (CFGPOOL_data),
        .CCUPOOL_En       (CCUPOOL_En),
        .CCUPOOL_ValFrm   (CCUPOOL_ValFrm),
        .CCUPOOL_ValDelta (CCUPOOL_ValDelta),
        .POOLGB_rdy       (POOLGB_rdy),
        .POOLGB_fnh        (POOLGB_fnh),
        .POOLGB_addr      (POOLGB_addr),
        .GBPOOL_val       (GBPOOL_val),
        .GBPOOL_data      (GBPOOL_data),
        .BF_rdy           (BF_rdy),
        .BF_val           (BF_val),
        .BF_addr          (BF_addr),
        .BF_data          (BF_data),
        .BF_flg_rdy       (BF_flg_rdy),
        .BF_flg_val       (BF_flg_val),
        .BF_flg_data      (BF_flg_data)
    );

POOL_OUT #(
        .PORT_WIDTH(`PORT_WIDTH),
        .DATA_WIDTH(`DATA_WIDTH),
        .FLAG_WIDTH(`NUM_PEB)
    ) inst_POOL_OUT (
        .clk             (clk),
        .rst_n           (rst_n),
        .POOLOUT_debug   (POOLOUTMONITOR),
        .layer_fnh       (CCUPOOL_layer_fnh),
        .clear_up        (POOLCCU_clear_up),
        .BF_rdy          (BF_rdy),
        .BF_val          (BF_val),
        .BF_addr         (BF_addr),
        .BF_data         (BF_data),
        .BF_flg_rdy      (BF_flg_rdy),
        .BF_flg_val      (BF_flg_val),
        .BF_flg_data     (BF_flg_data),
        .IFPOOL_rdy      (IFPOOL_rdy),
        .POOLIF_val      (POOLIF_val),
        .POOLIF_data     (POOLIF_data),                                 
        .IFPOOL_flg_rdy  (IFPOOL_flg_rdy),
        .POOLIF_flg_val  (POOLIF_flg_val),
        .POOLIF_flg_data (POOLIF_flg_data)
    );

`ifdef DELAY_SRAM
reg [40         -1 : 0] Summary_all;
wire [40         -1 : 0] Summary_TS3D_all;
wire [40         -1 : 0] Summary_TS3D_final_all;
reg  [40         -1 : 0] Summary_theory_ASIC;
wire  [40         -1 : 0] Summary_TS3D_MAC_compute_sta;
wire  [40         -1 : 0] Summary_TS3D_MAC_compute;
wire [40         -1 : 0] Summary_TS3D_MAC_wait;
wire [40         -1 : 0] Summary_MAC_work_wait_act;
wire [40         -1 : 0] Summary_MAC_work_wait_wei;
wire [40         -1 : 0] Summary_MAC_work_wait_flgact;
wire [40         -1 : 0] Summary_MAC_work_wait_flgwei;
wire [40         -1 : 0] Summary_MAC_work_wait_psum;
wire [40         -1 : 0] Summary_TS3D_PSUM_wait;
wire [40         -1 : 0] Summary_TS3D_PEB_wait_in;
wire [40         -1 : 0] Summary_TS3D_PEL_async;
wire [40         -1 : 0] Summary_TS3D_ARB_MAC_wait_avg;
wire [40         -1 : 0] Summary_TS3D_ARB_MAC_wait_flagcompwei_avg;
wire [40         -1 : 0] Summary_TS3D_ARB_MAC_wait_PSUM_avg;
wire [40         -1 : 0] Summary_TS3D_ARB_MAC_wait_final_avg;
// integer i,j;
// always @(*) begin
//     Summary_TS3D_MAC_compute_sta = 0;
//     for(i=0; i< `NUM_PEB; i=i+1) 
//         for(j=0; j<27; j=j+1)
//             Summary_TS3D_MAC_compute_sta = Summary_TS3D_MAC_compute_sta + top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.Summary_MAC_compute_sta;
//     Summary_TS3D_MAC_compute_sta = Summary_TS3D_MAC_compute_sta/(`NUM_PEB*27);
// end

// compute and pipeline delay
assign Summary_TS3D_MAC_compute_sta = ( inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.Summary_MAC_compute_sta 
                                      + inst_PEL.PEB[0].inst_PEB.MAC[13].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[0].inst_PEB.MAC[26].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[4].inst_PEB.MAC[0].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[4].inst_PEB.MAC[13].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[4].inst_PEB.MAC[26].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[7].inst_PEB.MAC[0].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[7].inst_PEB.MAC[13].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[7].inst_PEB.MAC[26].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[11].inst_PEB.MAC[0].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[11].inst_PEB.MAC[13].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[11].inst_PEB.MAC[26].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[15].inst_PEB.MAC[0].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[15].inst_PEB.MAC[13].inst_MAC.Summary_MAC_compute_sta
                                      + inst_PEL.PEB[15].inst_PEB.MAC[26].inst_MAC.Summary_MAC_compute_sta
                                      )/15;
assign Summary_TS3D_MAC_compute      = (inst_PEL.PEB[0 ].inst_PEB.MAC[0 ].inst_MAC.Summary_MAC_compute 
                                      + inst_PEL.PEB[0 ].inst_PEB.MAC[13].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[0 ].inst_PEB.MAC[26].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[4 ].inst_PEB.MAC[0 ].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[4 ].inst_PEB.MAC[13].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[4 ].inst_PEB.MAC[26].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[7 ].inst_PEB.MAC[0 ].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[7 ].inst_PEB.MAC[13].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[7 ].inst_PEB.MAC[26].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[11].inst_PEB.MAC[0 ].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[11].inst_PEB.MAC[13].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[11].inst_PEB.MAC[26].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[15].inst_PEB.MAC[0 ].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[15].inst_PEB.MAC[13].inst_MAC.Summary_MAC_compute
                                      + inst_PEL.PEB[15].inst_PEB.MAC[26].inst_MAC.Summary_MAC_compute
                                      )/15;
// input delay
assign Summary_TS3D_MAC_wait = Summary_MAC_work_wait_act + Summary_MAC_work_wait_wei + Summary_MAC_work_wait_flgact + Summary_MAC_work_wait_flgwei + Summary_MAC_work_wait_psum;

assign Summary_MAC_work_wait_act = 
                                ( inst_PEL.PEB[0 ].inst_PEB.MAC[0 ].inst_MAC.Summary_MAC_wait_act 
                                + inst_PEL.PEB[0 ].inst_PEB.MAC[13].inst_MAC.Summary_MAC_wait_act
                                + inst_PEL.PEB[0 ].inst_PEB.MAC[26].inst_MAC.Summary_MAC_wait_act
                                ) / 3 + 1;
assign Summary_MAC_work_wait_wei = 
                                ( inst_PEL.PEB[0 ].inst_PEB.MAC[0 ].inst_MAC.Summary_MAC_wait_wei 
                                + inst_PEL.PEB[0 ].inst_PEB.MAC[13].inst_MAC.Summary_MAC_wait_wei
                                + inst_PEL.PEB[0 ].inst_PEB.MAC[26].inst_MAC.Summary_MAC_wait_wei
                                ) /3 ;
assign Summary_MAC_work_wait_flgact = 
                                ( inst_PEL.PEB[0 ].inst_PEB.MAC[0 ].inst_MAC.Summary_MAC_wait_flgact 
                                + inst_PEL.PEB[0 ].inst_PEB.MAC[13].inst_MAC.Summary_MAC_wait_flgact
                                + inst_PEL.PEB[0 ].inst_PEB.MAC[26].inst_MAC.Summary_MAC_wait_flgact 
                                ) /3;
assign Summary_MAC_work_wait_flgwei = 
                                ( inst_PEL.PEB[0 ].inst_PEB.MAC[0 ].inst_MAC.Summary_MAC_wait_flgwei 
                                + inst_PEL.PEB[0 ].inst_PEB.MAC[13].inst_MAC.Summary_MAC_wait_flgwei
                                + inst_PEL.PEB[0 ].inst_PEB.MAC[26].inst_MAC.Summary_MAC_wait_flgwei
                                ) / 3;
assign Summary_MAC_work_wait_psum = 
                                ( inst_PEL.PEB[0 ].inst_PEB.MAC[0 ].inst_MAC.Summary_MAC_wait_psum 
                                + inst_PEL.PEB[0 ].inst_PEB.MAC[13].inst_MAC.Summary_MAC_wait_psum
                                + inst_PEL.PEB[0 ].inst_PEB.MAC[26].inst_MAC.Summary_MAC_wait_psum    
                                ) / 3;
// output delay
assign Summary_TS3D_PSUM_wait = (inst_PEL.PEB[0].inst_PEB.PSUM[4].inst_PSUM.Summary_PSUM_waitin + 
                                inst_PEL.PEB[4].inst_PEB.PSUM[4].inst_PSUM.Summary_PSUM_waitin + 
                                inst_PEL.PEB[8].inst_PEB.PSUM[4].inst_PSUM.Summary_PSUM_waitin + 
                                inst_PEL.PEB[12].inst_PEB.PSUM[4].inst_PSUM.Summary_PSUM_waitin +
                                inst_PEL.PEB[15].inst_PEB.PSUM[4].inst_PSUM.Summary_PSUM_waitin)/5;
assign Summary_TS3D_PEB_wait_in = inst_PEL.PEB[0].inst_PEB.Summary_PEB_wait_flgact; 
                                    // + inst_PEL.PEB[4].inst_PEB.Summary_PEB_wait_flgact
                                    // + inst_PEL.PEB[8].inst_PEB.Summary_PEB_wait_flgact
                                    // + inst_PEL.PEB[12].inst_PEB.Summary_PEB_wait_flgact
                                    // + inst_PEL.PEB[15].inst_PEB.Summary_PEB_wait_flgact)/5
                                    // ;
// ~ compute/compute_sta -> ~density
assign Summary_TS3D_PEL_async = inst_CCU.Summary_CCU_PEB_async + 1; // *Summary_TS3D_MAC_compute/Summary_TS3D_MAC_compute_sta; 

assign Summary_TS3D_ARB_MAC_wait_avg = ( 
                                      inst_PEL.PEB[0 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[1 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[2 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[3 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[4 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[5 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[6 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[7 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[8 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[9 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[10].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[11].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[12].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[13].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[14].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    + inst_PEL.PEB[15].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_avg
                                    ) / 16;

// because of no wei to allocate
assign Summary_TS3D_ARB_MAC_wait_flagcompwei_avg = ( 
                                      inst_PEL.PEB[0 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[1 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[2 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[3 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[4 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[5 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[6 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[7 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[8 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[9 ].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[10].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[11].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[12].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[13].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[14].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    + inst_PEL.PEB[15].inst_PEB.inst_ARB.Summary_ARB_MAC_wait_flagcompwei_avg
                                    ) / 16;
assign Summary_TS3D_ARB_MAC_wait_PSUM_avg = Summary_TS3D_ARB_MAC_wait_avg - Summary_TS3D_ARB_MAC_wait_flagcompwei_avg;
assign Summary_TS3D_ARB_MAC_wait_final_avg = Summary_TS3D_ARB_MAC_wait_flagcompwei_avg + Summary_TS3D_ARB_MAC_wait_PSUM_avg;
assign Summary_TS3D_all = Summary_TS3D_MAC_compute_sta + Summary_TS3D_MAC_wait 
                             + Summary_TS3D_PEL_async + inst_CCU.Summary_CCU_pool;
assign Summary_TS3D_final_all = Summary_TS3D_all + Summary_TS3D_ARB_MAC_wait_final_avg;

always @(posedge clk or negedge rst_n)
if(!rst_n) begin
    Summary_theory_ASIC <= 0;
end else begin
Summary_theory_ASIC <= 
                            Summary_TS3D_MAC_compute_sta 
                        +   Summary_MAC_work_wait_act + Summary_MAC_work_wait_flgact 
                        +   Summary_MAC_work_wait_wei / ( 60 + Summary_TS3D_MAC_compute*10/Summary_TS3D_MAC_compute_sta )*10
                        +   Summary_MAC_work_wait_flgwei / ( 20 + Summary_TS3D_MAC_compute*10/Summary_TS3D_MAC_compute_sta )*10

                        +   Summary_TS3D_PEL_async
                        +   inst_CCU.Summary_CCU_pool / 2
                        +   Summary_TS3D_ARB_MAC_wait_flagcompwei_avg/4 + Summary_TS3D_ARB_MAC_wait_PSUM_avg/ ( 40 + Summary_TS3D_MAC_compute*10/Summary_TS3D_MAC_compute_sta )*10;
end


always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Summary_all <= 0;
    end else begin
        Summary_all <= Summary_all + 1;
    end
end


// FFZS performance
assign Summary_MAC = 
                            Summary_TS3D_MAC_compute_sta 
                        +   Summary_MAC_work_wait_act + Summary_MAC_work_wait_flgact 
                        +   Summary_MAC_work_wait_wei / ( 60 + Summary_TS3D_MAC_compute*10/Summary_TS3D_MAC_compute_sta )*10
                        +   Summary_MAC_work_wait_flgwei / ( 20 + Summary_TS3D_MAC_compute*10/Summary_TS3D_MAC_compute_sta )*10;




`endif

endmodule

// module max #(
//        parameter int DATA_WIDTH = 16,
//        parameter int DEPTH = 8
// )
// (
//        input   [DATA_WIDTH-1:0] a [DEPTH-1:0],
//        output  [DATA_WIDTH-1:0] z
// );

// always @* begin

//        z = a[0];
//        for (int i=1; i<DEPTH; i++) begin
//            if(a[i] > z) begin
//                z = a[i];
//            end
//        end
// end
// endmodule