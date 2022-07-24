//======================================================
// Copyright (C) 2019 By zhoucc
// All Rights Reserved
//======================================================
// Module : PEB
// Author : CC zhou
// Contact : 
// Date : 6 .13 .2019
//=======================================================
// Description :
//========================================================
`include "../source/include/dw_params_presim.vh"
module PEB (
    input                               clk     ,
    input                               rst_n   ,

    input                               next_block,// paulse:reset wei/arb
    input                               reset_act,// paulse
    input                               reset_wei,
    output                              PEBCCU_Fnh, // level
    input                               PELACT_Handshake_n,
    output                              ACTGB_Rdy,
    input                               GBACT_Val,
    input    [`BUSWIDTH_ACT     -1 : 0] GBACT_Data, // 16B

    output                              FLGACTGB_rdy,
    input                               GBFLGACT_val,
    input   [`BUSWIDTH_FLGACT   -1 : 0] GBFLGACT_data,  // 4B

    input                               PEBACT_rdy,//PEB
    output                              ACTPEB_val,
    output [ `BUSWIDTH_ACT      -1 : 0] ACTPEB_data,

    input                               PEBFLGACT_rdy,//PEB
    output                              FLGACTPEB_val,
    output [`BUSWIDTH_FLGACT    -1 : 0] FLGACTPEB_data,

    input                               GBWEI_Instr_Rdy,
    output                              WEIGB_Instr_Val,
    output  [`DATA_WIDTH        -1 : 0] WEIGB_Instr_Data,

    output                              WEIGB_Rdy,
    input                               GBWEI_Val,
    input  [`BUSWIDTH_WEI       -1 : 0] GBWEI_Data,

    output                              FLGWEIGB_Rdy,
    input                               GBFLGWEI_Val,
    input  [`BUSWIDTH_FLGWEI    -1 : 0] GBFLGWEI_Data,

    output                              PSUMGB_val0,// PE0
    output [ `BUSWIDTH_PSUM     -1 : 0] PSUMGB_data0,
    input                               GBPSUM_rdy0,

    output                              PSUMGB_val1,// PE1
    output [ `BUSWIDTH_PSUM     -1 : 0] PSUMGB_data1,
    input                               GBPSUM_rdy1, 

    output                              PSUMGB_val2,// PE2
    output [ `BUSWIDTH_PSUM     -1 : 0] PSUMGB_data2,
    input                               GBPSUM_rdy2,

    output                              PSUMGB_rdy0,// Psum In
    input [ `BUSWIDTH_PSUM      -1 : 0] GBPSUM_data0,
    input                               GBPSUM_val0,

    output                              PSUMGB_rdy1,// Psum In
    input [ `BUSWIDTH_PSUM      -1 : 0] GBPSUM_data1,
    input                               GBPSUM_val1,

    output                              PSUMGB_rdy2,// Psum In
    input [ `BUSWIDTH_PSUM      -1 : 0] GBPSUM_data2,
    input                               GBPSUM_val2
    // output [ 325                -1 : 0] PEBMONITOR
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================




//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire [ `MAC_NUM                             -1 : 0] MACMUX_Val;
wire [`PSUM_ADDR_WIDTH                      -1 : 0] MACMUX_Addr[0: `MAC_NUM - 1];
wire [`PSUM_WIDTH                           -1 : 0] MACMUX_Psum [0: `MAC_NUM - 1];
wire [`MAC_NUM                              -1 : 0] MACARB_ReqHelp;
wire [`MAC_NUM                              -1 : 0] ARBMAC_Rst;
wire [`MAC_NUM                              -1 : 0] Stop_Psum_All;
wire [ `MAC_NUM_WIDTH                       -1 : 0] ARBMAC_IDWei[ 0 : `MAC_NUM       -1];// << 5
wire [1 * `MAC_NUM                          -1 :0 ] ARBMAC_NewRow;// << 5

wire [ `REGFLGACT_ADDR_WIDTH                -1 : 0] Regarray_FlgActout_addr[0 : `MAC_NUM -1];
wire [`BLOCK_DEPTH                          -1 : 0] Regarray_FlgActout[ 0 : `MAC_NUM -1];

wire [ `ACT_NUM_WIDTH                     -1 : 0] REGARRAY_ACT_RdAddr[ 0 : `MAC_NUM -1];
wire [ `DATA_WIDTH                          -1 : 0] Regarray_Actout[0 : `MAC_NUM -1];
wire [ 1*`MAC_NUM                           -1 : 0] Regarray_Actout_Rdy;
wire [ 1*`MAC_NUM                           -1 : 0] Regarray_Actout_Val;

wire [ `BLOCK_DEPTH * `MAC_NUM              -1 : 0] regarray_flgweiout;
wire [ `MAX_DEPTH_WIDTH* `MAC_NUM           -1 : 0] Regarray_weiout_addr;
wire  [ `MAC_NUM                            -1 : 0] Regarray_weiout_Rdy;
// reg  [ `MAC_NUM                             -1 : 0] Regarray_weiout_Rdy_tmp;
wire [  `MAC_NUM                            -1 : 0] Regarray_weiout_Val;
wire [ `DATA_WIDTH * `MAC_NUM               -1 : 0] Regarray_weiout;

wire [ `MAC_NUM                             -1 : 0] SRAM_WEI_dataout_rdy;
wire [ `MAX_DEPTH_WIDTH*`MAC_NUM            -1 : 0] SRAM_WEI_dataout_addr;
wire [ `MAC_NUM                             -1 : 0] SRAM_WEI_dataout_val;
wire [ `REGWEI_WR_WIDTH                     -1 : 0] SRAM_WEI_dataout;

wire                                                REGARRAY_ACT_WrReq;
wire                                                REGARRAY_ACT_WrEn;
wire [ `REGACT_WR_WIDTH                     -1 : 0] REGARRAY_ACT_WrDat;

wire                                                REGARRAY_FLGACT_WrReq;
wire                                                REGARRAY_FLGACT_WrEn;
wire [ `REGFLGACT_WR_WIDTH                  -1 : 0] REGARRAY_FLGACT_WrDat;

wire                                                REGARRAY_FLGWEI_WrReq;
wire                                                REGARRAY_FLGWEI_WrEn;
wire [ `REGFLGWEI_WR_WIDTH                  -1 : 0] REGARRAY_FLGWEI_WrDat;


wire [ `PSUM_ADDR_WIDTH * `MAC_NUM          -1 : 0] PSUMARB_AddrPsum;

wire [ `MAC_NUM_WIDTH * `MAC_NUM*2          -1 : 0] ARBCHN_IDMAC_Help;
wire                                                ARBPSUM_PlsNewRow;
wire [ `REGFLGWEI_ADDR_WIDTH * `MAC_NUM     -1 : 0] regarray_flgweiout_offset;
wire [ 1* `MAC_NUM                          -1 : 0] regarray_flgweiout_rdy;
wire [ 1* `MAC_NUM                          -1 : 0] regarray_flgweiout_val;
wire [ `MAC_NUM                             -1 : 0] ARBPSUM_PlsMux;

wire [2*`MAC_NUM                            -1 : 0] ARBCHN_Switch;

wire [ `MAC_NUM                             -1 : 0] Regarray_FlgActout_Val;
wire [ `MAC_NUM                             -1 : 0] Regarray_FlgActout_Rdy;
wire  [ `MAC_NUM                            -1 : 0] MUXMAC_Rdy;
reg  [ `MAC_NUM                             -1 : 0] MACMUX_Empty;
// wire [ `MAC_NUM/3                           -1 : 0] PSUMARB_rdy;
wire [ `MAC_NUM/3                           -1 : 0] PSUMARB_empty;
wire [ `MAC_NUM/3                           -1 : 0] ARBPSUM_fnh;

// Row Address
reg [ `ACT_NUM_WIDTH                        -1 : 0] AddrRowAct[0 : `LENROW -1];
reg [ `MAX_DEPTH_WIDTH                      -1 : 0] AddrBlockWei [0 : `MAC_NUM -1]; // 1024
wire [ `MAX_DEPTH_WIDTH*`MAC_NUM            -1 : 0] AddrBlockWei_array; // 1024
wire [ `MAX_DEPTH_WIDTH                     -1 : 0] AddrWei [0 : 27 -1]; // 1024

wire                                                wr_en_accpoint;
reg [ `ACT_NUM_WIDTH                        -1 : 0] wr_addr_AddrRowAct;
wire [ `C_LOG_2(`REGFLGACT_WR_WIDTH)        -1 : 0] count_act_point;
reg  [ `ACT_NUM_WIDTH                                -1 : 0] count_act_row;

wire [ `C_LOG_2(`LENROW)                    -1 : 0] ARBMAC_IDActRow[ 0 : `MAC_NUM -1 ];

wire [ (`MAC_NUM_WIDTH+1)*`MAC_NUM      -1 : 0] ARBMAC_IDCHN;
wire [ `MAC_NUM                         -1 : 0] MAC_AddrWei_Rdy;

wire [ `MAC_NUM*2                       -1 : 0] MUX_datain_rdy;
wire [ `MAC_NUM*2                       -1 : 0] CHN_rdy;

wire [ `MAC_NUM * 9                     -1 : 0] ARBPSUM_SwitchOnMAC;

wire [ 9                                -1 : 0] PSUMMAC_rdy;
wire [ 4                                -1 : 0] ARBMAC_IDPSUM   [ 0 : `MAC_NUM  -1];
wire [ 4                                -1 : 0] MEM_ARBMAC_IDPSUM [ 0 : `MAC_NUM -1];

reg [ 5                                 -1 : 0] x_axis;
reg [ `MAC_NUM_WIDTH                    -1 : 0] IDMAC_push[ 0 : 9 -1];

wire [ `MAC_NUM                         -1 : 0] ARBMAC_Switch;

wire [ `ACT_NUM_WIDTH                   -1 : 0] PEBARB_RowCntFlg;
wire                                            inc_block;
wire [ `BLK_WIDTH + `FRAME_WIDTH        -1 : 0] cnt_block;

wire                                            ARBACT_RowOn;
wire[ `C_LOG_2(`LENROW)                 -1 : 0] ARBPEB_RowArb;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================






//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================
generate
    genvar i;
    for(i=0;i<`MAC_NUM;i=i+1) begin: MAC
        // wire MAC_Stop_Psum;
        wire [`ACT_NUM_WIDTH    -1 : 0] MAC_AddrAct;//????+ `CHN_DEPTH_WIDTH
        wire [`REGFLGACT_ADDR_WIDTH -1 : 0] MAC_AddrFlgAct;//?+ `CHN_DEPTH_WIDTH
        wire [`MAX_DEPTH_WIDTH    -1 : 0] MAC_AddrWei;//?+ `CHN_DEPTH_WIDTH
        wire                                MAC_AddrFlgAct_Rdy;
        wire                                MAC_FlgAct_Val;
        wire [`BLOCK_DEPTH          -1: 0 ] MAC_FlgAct;
        wire [`BLOCK_DEPTH          -1: 0 ] MAC_FlgWei;
        wire [`DATA_WIDTH           -1 : 0] MAC_Act;
        wire [`DATA_WIDTH           -1 : 0] MAC_Wei;
        wire [ 2                    -1 : 0] PEBMAC_WeiCol;
        wire                                MAC_Wei_Val;
        wire [ 4                    -1 : 0] IDActRow;
        wire  [`REGFLGACT_ADDR_WIDTH                    -1 : 0] AddrRowFlgAct;
        // assign IDActRow = 
        MAC inst_MAC
            (
            .clk                (clk),
            .rst_n              (rst_n),

            .MACMUX_Val         (MACMUX_Val[i]),
            .MACMUX_Addr        (MACMUX_Addr[i]),
            .MACMUX_Psum        (MACMUX_Psum[i]),
            .MUXMAC_Rdy         (MUXMAC_Rdy[i]),
            .MACMUX_Empty       (MACMUX_Empty[i]),

            .MACARB_ReqHelp      (MACARB_ReqHelp[i]),
            .ARBMAC_Rst         (ARBMAC_Rst[i]),
            .PEBMAC_WeiCol      (PEBMAC_WeiCol  ),
            .AddrRowFlgAct      (AddrRowFlgAct ),
            .AddrRowAct         (AddrRowAct[ARBMAC_IDActRow[i]]),
            .AddrBlockWei       (AddrBlockWei[ARBMAC_IDWei[i]]),

            .MAC_FlgWei         (MAC_FlgWei),
            .MAC_FlgWei_Val     (MAC_FlgWei_Val),

            .MAC_AddrFlgAct_Rdy ( MAC_AddrFlgAct_Rdy),
            .MAC_AddrFlgAct     (MAC_AddrFlgAct),//// + 5bit width <<
            .MAC_FlgAct_Val     ( MAC_FlgAct_Val),
            .MAC_FlgAct         (MAC_FlgAct),

            .MAC_AddrAct_Rdy    ( MAC_AddrAct_Rdy),
            .MAC_AddrAct        (MAC_AddrAct),// + 5bit width <<
            .MAC_Act_Val        ( MAC_Act_Val),
            .MAC_Act            (MAC_Act),

            .MAC_AddrWei_Rdy    ( MAC_AddrWei_Rdy[i]),
            .MAC_AddrWei        (MAC_AddrWei),// + 5bit width <<
            .MAC_Wei_Val        ( MAC_Wei_Val),
            .MAC_Wei            (MAC_Wei)
            );

assign PEBMAC_WeiCol =  ( ARBMAC_IDWei[i] == 0  )? 0  : 
                        ( ARBMAC_IDWei[i] == 1  )? 1  :
                        ( ARBMAC_IDWei[i] == 2  )? 2  : 
                        ( ARBMAC_IDWei[i] == 3  )? 0  :
                        ( ARBMAC_IDWei[i] == 4  )? 1  :
                        ( ARBMAC_IDWei[i] == 5  )? 2  : 
                        ( ARBMAC_IDWei[i] == 6  )? 0  :
                        ( ARBMAC_IDWei[i] == 7  )? 1  :
                        ( ARBMAC_IDWei[i] == 8  )? 2  : 
                        ( ARBMAC_IDWei[i] == 9  )? 0  :
                        ( ARBMAC_IDWei[i] == 10 )? 1  :
                        ( ARBMAC_IDWei[i] == 11 )? 2  : 
                        ( ARBMAC_IDWei[i] == 12 )? 0  :
                        ( ARBMAC_IDWei[i] == 13 )? 1  :
                        ( ARBMAC_IDWei[i] == 14 )? 2  : 
                        ( ARBMAC_IDWei[i] == 15 )? 0  :
                        ( ARBMAC_IDWei[i] == 16 )? 1  :
                        ( ARBMAC_IDWei[i] == 17 )? 2  :
                        ( ARBMAC_IDWei[i] == 18 )? 0  : 
                        ( ARBMAC_IDWei[i] == 19 )? 1  :
                        ( ARBMAC_IDWei[i] == 20 )? 2  :
                        ( ARBMAC_IDWei[i] == 21 )? 0  : 
                        ( ARBMAC_IDWei[i] == 22 )? 1  :
                        ( ARBMAC_IDWei[i] == 23 )? 2  :
                        ( ARBMAC_IDWei[i] == 24 )? 0  : 
                        ( ARBMAC_IDWei[i] == 25 )? 1  : 
                        ( ARBMAC_IDWei[i] == 26 )? 2  :
                        0;
 
        assign Regarray_FlgActout_Rdy[i ] = MAC_AddrFlgAct_Rdy;
        
        assign AddrRowFlgAct = `LENROW*`LENROW*cnt_block + `LENROW*ARBMAC_IDActRow[i];
        assign Regarray_FlgActout_addr[i] = 
                MAC_AddrFlgAct; // + ( AddrRowFlgAct << 4 ); // *16
        assign MAC_FlgAct_Val = Regarray_FlgActout_Val[i];
        assign MAC_FlgAct = Regarray_FlgActout[i];// <<

        assign Regarray_Actout_Rdy[i] = MAC_AddrAct_Rdy;
        assign REGARRAY_ACT_RdAddr[i] = 
                MAC_AddrAct; // + AddrRowAct[ARBMAC_IDActRow[4*i +: 4]];
        assign MAC_Act = Regarray_Actout[i];
        assign MAC_Act_Val = Regarray_Actout_Val[i];

        assign regarray_flgweiout_rdy[i] = 1;

        assign MAC_FlgWei = regarray_flgweiout[ `BLOCK_DEPTH*ARBMAC_IDWei[i] +: `BLOCK_DEPTH];
        assign MAC_FlgWei_Val = regarray_flgweiout_val[ARBMAC_IDWei[i]];

        assign AddrWei[i] = MAC_AddrWei; // + AddrBlockWei[ARBMAC_IDWei[`MAC_NUM_WIDTH*i +:`MAC_NUM_WIDTH ]];

        wire                            regarray_weiin_rdy;
        wire                            regarray_weiin_val;
        wire [ `REGWEI_WR_WIDTH    -1 : 0] regarray_weiin;

        wire [ `MAX_DEPTH_WIDTH               -1 : 0] Regarray_weiin_addr;
        REGWEI #( // bond with MAC
            .DATA_WIDTH (`DATA_WIDTH),
            .ADDR_WIDTH (`MAX_DEPTH_WIDTH),
            .REG_ADDR_WIDTH(3),
            .WR_NUM (`REGWEI_WR_WIDTH / `DATA_WIDTH),
            .RD_NUM (1)) // two read channels
            REGARRAY_WEI // only a wei
            (
                .clk            (clk   ),
                .rst_n          (rst_n),
                .reset          (ARBMAC_Rst[i] ),
                .datain_rdy     (regarray_weiin_rdy),
                .datain_addr    (Regarray_weiin_addr),
                .datain_val     (regarray_weiin_val),
                .datain         (regarray_weiin),
                .dataout_addr   (AddrWei[i]),
                .dataout_rdy    (MAC_AddrWei_Rdy[i]), // to MAC
                .dataout_sw     (ARBMAC_Switch[i]),
                .dataout_val    (MAC_Wei_Val),
                .dataout        (MAC_Wei)
            );
        assign SRAM_WEI_dataout_rdy[i] = regarray_weiin_rdy;
        assign SRAM_WEI_dataout_addr[`MAX_DEPTH_WIDTH*i +: `MAX_DEPTH_WIDTH] = Regarray_weiin_addr;
        assign regarray_weiin_val = SRAM_WEI_dataout_val[i];
        assign regarray_weiin = SRAM_WEI_dataout;
        // always @ (*) begin
        //     MUXMAC_Rdy[i] = 0;
        // end
        assign MUXMAC_Rdy[i] = (i == IDMAC_push[MEM_ARBMAC_IDPSUM[i]])? PSUMMAC_rdy[MEM_ARBMAC_IDPSUM[i]] : 0;
        assign MEM_ARBMAC_IDPSUM[i] = ARBMAC_IDPSUM[i];
    end
endgenerate


SRAM_ACT #(
    .DATA_WIDTH(`REGACT_WR_WIDTH),
    .ADDR_WIDTH(5),
    .RD_NUM(2)
    )inst_SRAM_ACT // 1 input; 2 output FIFO
    (
        .clk            (clk                ),
        .rst_n          (rst_n              ),
        .reset          (reset_act              ),
        .PELACT_Handshake_n(PELACT_Handshake_n),
        .datain_rdy     (ACTGB_Rdy          ),
        .datain_val     (GBACT_Val          ),
        .datain         (GBACT_Data         ),
        .dataout_rdy0   (REGARRAY_ACT_WrReq ),
        .dataout_val0   (REGARRAY_ACT_WrEn  ),
        .dataout0       (REGARRAY_ACT_WrDat ),
        .dataout_rdy1   (PEBACT_rdy         ),
        .dataout_val1   (ACTPEB_val         ),
        .dataout1       (ACTPEB_data        )
    );
wire [ `C_LOG_2(`LENROW)        -1 : 0] tmp_addrrow = `LENROW*cnt_block + ARBPEB_RowArb;
wire [ `ACT_NUM_WIDTH    -1 : 0] AddrRowAct_Act = AddrRowAct[tmp_addrrow];

REGARRAY #(
    .DATA_WIDTH (`DATA_WIDTH),
    .ADDR_WIDTH(`ACT_NUM_WIDTH),
    .REG_ADDR_WIDTH(5),
    .WR_NUM (`REGACT_WR_WIDTH/`DATA_WIDTH),
    .RD_NUM (`MAC_NUM))
REGARRAY_ACT
    (
        .clk            (clk),
        .rst_n          (rst_n),
        .reset          (reset_act),
        .datain_rdy     (REGARRAY_ACT_WrReq),
        .datain_val     (REGARRAY_ACT_WrEn),
        .datain         (REGARRAY_ACT_WrDat),
        .dataout_addr   (REGARRAY_ACT_RdAddr),
        .dataout_rdy    (Regarray_Actout_Rdy),
        .dataout_sw     (ARBMAC_Switch),
        .ARBACT_RowOn   (ARBACT_RowOn),
        .AddrRowAct     (AddrRowAct_Act),
        .dataout_val    (Regarray_Actout_Val),
        .dataout        (Regarray_Actout)
    );

SRAM_ACT #(
    .DATA_WIDTH(`REGFLGACT_WR_WIDTH),
    .ADDR_WIDTH(6), // 64
    .RD_NUM (2)
    )inst_SRAM_FLGACT
    (
        .clk          (clk                    ),
        .rst_n        (rst_n                  ),
        .reset          (reset_act              ),
        .PELACT_Handshake_n(PELACT_Handshake_n),
        .datain_rdy   (FLGACTGB_rdy        ),
        .datain_val   (GBFLGACT_val         ),
        .datain       (GBFLGACT_data        ),
        .dataout_rdy0 (REGARRAY_FLGACT_WrReq  ),
        .dataout_val0 (REGARRAY_FLGACT_WrEn   ),
        .dataout0     (REGARRAY_FLGACT_WrDat  ),
        .dataout_rdy1 (PEBFLGACT_rdy        ),
        .dataout_val1 (FLGACTPEB_val        ),
        .dataout1     (FLGACTPEB_data        )
    );
    
wire [ `REGFLGACT_ADDR_WIDTH    -1 : 0] AddrRowAct_FlgAct = `LENROW*`LENROW*cnt_block + `LENROW*ARBPEB_RowArb;
REGARRAY #(
    .DATA_WIDTH (`BLOCK_DEPTH),
    .ADDR_WIDTH(`REGFLGACT_ADDR_WIDTH),//256*1024/32 = 256*32 -> 13
    .REG_ADDR_WIDTH(4),
    .WR_NUM (`REGFLGACT_WR_WIDTH/`BLOCK_DEPTH),
    .RD_NUM (`MAC_NUM))
REGARRAY_FLGACT
    (
        .clk            (clk),
        .rst_n          (rst_n),
        .reset          (reset_act),
        .datain_rdy     (REGARRAY_FLGACT_WrReq),
        .datain_val     (REGARRAY_FLGACT_WrEn),
        .datain         (REGARRAY_FLGACT_WrDat),
        .dataout_addr   (Regarray_FlgActout_addr),
        .dataout_rdy    (Regarray_FlgActout_Rdy),
        .dataout_sw     (ARBMAC_Switch),
        .ARBACT_RowOn   (ARBACT_RowOn),
        .AddrRowAct     (AddrRowAct_FlgAct),
        .dataout_val    (Regarray_FlgActout_Val ),
        .dataout        (Regarray_FlgActout)
    );

// enable: acc a point's valid data
assign wr_en_accpoint = REGARRAY_FLGACT_WrEn; // because ACT.datain_val delay datain_rdy a clk;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        wr_addr_AddrRowAct <= 1; // from 1 begin write
    end else if ( reset_act) begin  // reset
        wr_addr_AddrRowAct <= 1;
    end else if ( x_axis == 16 ) begin
        wr_addr_AddrRowAct <= wr_addr_AddrRowAct + 1;
    end
end


always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        AddrRowAct[0] <= 0; // baseaddr0 == 0
    end else if ( reset_act ) begin 
        AddrRowAct[0] <= 0;
    end else if ( x_axis == 16 ) begin
        AddrRowAct[wr_addr_AddrRowAct[0 +: 4]] <= count_act_row; // 0-15
    end
end

// the i-th row whose flag is counted : 0 ~ 15

assign PEBARB_RowCntFlg = wr_addr_AddrRowAct - 1 - `LENROW * cnt_block;
assign inc_block = next_block;

// wire [ `BLK_WIDTH + `FRAME_WIDTH        -1 : 0] 
counter #(
    .COUNT_WIDTH(`BLK_WIDTH + `FRAME_WIDTH)
    ) counter_Blk(
        .CLK       (clk         ),
        .RESET_N   (rst_n       ),
        .CLEAR     (reset_act   ),
        .DEFAULT   ({{`BLK_WIDTH + `FRAME_WIDTH}{1'b0} } ),
        .INC       (inc_block   ),
        .DEC       (1'b0           ),
        .MIN_COUNT ({{`BLK_WIDTH + `FRAME_WIDTH}{1'b0}}  ),
        .MAX_COUNT ({{`BLK_WIDTH + `FRAME_WIDTH}{1'b1} }),
        .OVERFLOW  (            ),
        .UNDERFLOW (            ),
        .COUNT     (cnt_block   )
    );

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        count_act_row <= 0;
    end else if ( reset_act) begin 
        count_act_row <= 0;
    end else if ( wr_en_accpoint ) begin
        count_act_row <= count_act_row + count_act_point;
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        x_axis <= 0;
    end else if ( reset_act ) begin 
        x_axis <= 0;
    end else if ( x_axis == 16 && !wr_en_accpoint  ) begin
        x_axis <= 0;
    end else if ( x_axis == 16 && wr_en_accpoint  ) begin
        x_axis <= 1; 
    end else if ( wr_en_accpoint ) begin
        x_axis <= x_axis + 1;
    end
end

COUNT1 #(
    .DATA_WIDTH(`REGFLGACT_WR_WIDTH))
    COUNT1_FLGACT(
    .din(REGARRAY_FLGACT_WrDat),
    .dout(count_act_point));


SRAM_WEI #(
    .IN_DATA_WIDTH ( `SRAMWEI_WR_WIDTH),
    .OUT_DATA_WIDTH( `REGWEI_WR_WIDTH), // 8B or 16B??
    .RD_NUM ( `MAC_NUM),
    .ADDR_WIDTH(2),
    .ADDR_WIDTH_ALL(`MAX_DEPTH_WIDTH)
 )inst_SRAM_WEI( 
    .clk            (clk),
    .rst_n          (rst_n),
    .reset          (reset_wei),
    .instrout_rdy (GBWEI_Instr_Rdy ),
    .instrout_val (WEIGB_Instr_Val ),
    .instrout     (WEIGB_Instr_Data),
    .datain_rdy   (WEIGB_Rdy       ),
    .datain_val   (GBWEI_Val       ),
    .datain       (GBWEI_Data      ),
    .AddrBlockWei (AddrBlockWei_array),
    .ARBMAC_IDWei (ARBMAC_IDWei),
    .dataout_rdy  (SRAM_WEI_dataout_rdy),
    .dataout_addr (SRAM_WEI_dataout_addr),
    .dataout_val  (SRAM_WEI_dataout_val),
    .dataout      (SRAM_WEI_dataout)
);

REGFLGWEI #(
    .DATA_WIDTH (`BLOCK_DEPTH),
    .ADDR_WIDTH(`REGFLGWEI_ADDR_WIDTH),
    .WR_NUM (`REGFLGWEI_WR_WIDTH/`BLOCK_DEPTH),
    .RD_NUM (`MAC_NUM))
REGFLGWEI
    (
        .clk            (clk),
        .rst_n          (rst_n),
        .reset          (next_block),
        .datain_rdy     (FLGWEIGB_Rdy),
        .datain_val     (GBFLGWEI_Val),
        .datain         (GBFLGWEI_Data), // 8B
        .dataout_val    (regarray_flgweiout_val),
        .dataout        (regarray_flgweiout)
    );
generate
    genvar wei;
    for(wei=0;wei<`MAC_NUM;wei=wei+1) begin : GEN_ADDRBLOCKWEI
        wire                            wr_en_AddrBlockWei;
        wire [ `C_LOG_2(`BLOCK_DEPTH)   -1 : 0] count_wei;
        assign wr_en_AddrBlockWei = next_block;

        always @ ( posedge clk or negedge rst_n ) begin
            if ( !rst_n ) begin
                AddrBlockWei[wei] <= 0; // baseaddr0 == 0
            end else if ( reset_wei ) begin 
                AddrBlockWei[wei] <= 0;
            end else if ( wr_en_AddrBlockWei ) begin
                AddrBlockWei[wei] <= AddrBlockWei[wei] + count_wei;
            end
        end
        COUNT1 #(
            .DATA_WIDTH(`BLOCK_DEPTH))
            COUNT1_WEI(
            .din(regarray_flgweiout[`BLOCK_DEPTH*wei +: `BLOCK_DEPTH]),
            .dout(count_wei));
        assign AddrBlockWei_array[`MAX_DEPTH_WIDTH*wei +: `MAX_DEPTH_WIDTH] = AddrBlockWei[wei];
    end
endgenerate

// generate
//     genvar block;
//     for(block=0;block<32;block=block+1) begin
//         assign AddrBlockWei_array[`MAX_DEPTH_WIDTH*block +: `MAX_DEPTH_WIDTH] = AddrBlockWei[block];
//     end
    
// endgenerate

wire [ `MAC_NUM_WIDTH        -1 : 0] MEM_ARBCHN_IDMAC_Help [0: `MAC_NUM*2 -1] ;
wire                                ARBPEB_Fnh;
ARB #(
    .ROW_NUM_WIDTH(`MAX_DEPTH_WIDTH)
    )inst_ARB
    (
        .clk                (clk),
        .rst_n              (rst_n),
        .PEBARB_Sta         (next_block),
        .ARBPEB_Fnh         (ARBPEB_Fnh), // level
        .PEBARB_RowCntFlg      (PEBARB_RowCntFlg[ 0 +: 4]),

        .MAC_ReqHelp        (MACARB_ReqHelp),
        // .PSUMARB_rdy        (PSUMARB_rdy),
        .PSUMARB_empty        (PSUMARB_empty),

        .ARBMAC_Rst         (ARBMAC_Rst),
        .ARBMAC_IDActRow    (ARBMAC_IDActRow),
        .ARBMAC_IDWei       (ARBMAC_IDWei),
        .ARBMAC_IDPSUM       (ARBMAC_IDPSUM),
        .ARBMAC_Switch      (ARBMAC_Switch),
        .ARBACT_RowOn       (ARBACT_RowOn),
        .ARBPEB_RowArb      (ARBPEB_RowArb),
        .ARBPSUM_fnh        (ARBPSUM_fnh)
    );




generate
    genvar j;
    for(j=0;j<9;j=j+1) begin: PSUM // ??????
        wire                    reset_psum;
        reg                                     datain_val;
        wire                                    datain_rdy;
        reg [ `PSUM_WIDTH + `PSUM_ADDR_WIDTH-1 : 0] datain;
        wire                                    dataout_val;
        wire                                    dataout_rdy;
        wire [ `PSUM_WIDTH + `PSUM_ADDR_WIDTH-1 : 0] dataout;

        reg                                     MACPSUM_empty;

        wire                                    PSUMGB_val;
        wire [ `PSUM_WIDTH * `LENROW    -1 : 0] PSUMGB_data;
        wire                                    GBPSUM_rdy ;
        wire                                    GBPSUM_val;
        wire [ `PSUM_WIDTH * `LENROW    -1 : 0] GBPSUM_data;
        wire                                    PSUMGB_rdy ;

        assign PSUMMAC_rdy [j] = datain_rdy;
        reg                     scanf_fnh;
        reg                     scanf_fnh_fnh;
        integer                 mac;

        always @ ( posedge clk or negedge rst_n)begin // posedge clk
            if ( !rst_n) begin 
                datain_val      = 0;
                IDMAC_push[j]   = 31;
                scanf_fnh       = 0;
                scanf_fnh_fnh   = 0;
                MACPSUM_empty   = 1;
                datain          = 0;
            end else begin 
                datain_val      = 0;
                IDMAC_push[j]   = 31;
                scanf_fnh       = 0;
                scanf_fnh_fnh   = 0;
                MACPSUM_empty   = 1;
                datain          = 0;
                for(mac=0; mac<`MAC_NUM; mac=mac+1) begin
                    if(MEM_ARBMAC_IDPSUM[mac] == j && ~scanf_fnh) begin
                        if (MACMUX_Val[mac]) begin
                            IDMAC_push [j]  = mac;
                            datain_val      = 1;
                            scanf_fnh       = 1;
                            datain          = {  MACMUX_Psum[mac], MACMUX_Addr[mac]};
                        end
                    end else begin
                        datain = datain;
                    end
                    if(MEM_ARBMAC_IDPSUM[mac] == j && ARBMAC_Switch[mac] && ~MACARB_ReqHelp[mac] && ~scanf_fnh_fnh) begin
                            MACPSUM_empty = 0;
                            scanf_fnh_fnh =1;
                    end
                end
            end
        end

        Mux_2I #(
            .DATA_WIDTH(`PSUM_WIDTH + `PSUM_ADDR_WIDTH ),
            .FIFO_ADDR_WIDTH(1)
            )Mux_2I(
            .clk(clk),
            .rst_n(rst_n),
            .datain_val0(datain_val),
            .datain0(datain),
            .datain_rdy0(datain_rdy),
            .datain_val1(1'b0),
            .datain1({{`PSUM_WIDTH + `PSUM_ADDR_WIDTH}{1'b0}}),
            .datain_rdy1(),
            .dataout_rdy(dataout_rdy),
            .dataout(dataout),
            .dataout_val(dataout_val)
            );
        PSUM inst_PSUM
        (
            .clk          (clk),
            .rst_n        (rst_n),
            .reset        (reset_psum),
            .ARBPSUM_fnh  (ARBPSUM_fnh[j]),
            .PSUMARB_empty  (PSUMARB_empty[j]),
            .MACPSUM_empty  (MACPSUM_empty ), // level
            .psumaddr_val (dataout_val),
            .psumaddr     (dataout),
            .psumaddr_rdy (dataout_rdy),
            .datain_val     (GBPSUM_val ),
            .datain         (GBPSUM_data),
            .datain_rdy     (PSUMGB_rdy),
            .dataout_val    (PSUMGB_val),
            .dataout        (PSUMGB_data),
            .dataout_rdy    (GBPSUM_rdy )
        );

    end
endgenerate

generate // SET PSUM  One by One
    genvar gv_pec;
    for(gv_pec=0; gv_pec <3; gv_pec = gv_pec+1) begin: GEN_PEC 
        localparam IDLE = 2'b00;
        localparam SET_PSUM0 = 2'b01;
        localparam SET_PSUM1 = 2'b10;
        localparam SET_PSUM2 = 2'b11;
        reg [ 2         -1 : 0] state;
        always @ ( posedge clk or negedge rst_n ) begin
            if ( !rst_n ) begin
                state <= IDLE;
            end else
                case(state)
                    IDLE    : if(next_block)
                                state <= SET_PSUM0;
                    SET_PSUM0   : if( PSUM[3*gv_pec + 0].GBPSUM_val && PSUM[3*gv_pec + 0].PSUMGB_rdy )
                                state <= SET_PSUM1;
                    SET_PSUM1   : if( PSUM[3*gv_pec + 1].GBPSUM_val && PSUM[3*gv_pec + 1].PSUMGB_rdy )
                                state <= SET_PSUM2;
                    SET_PSUM2   : if ( PSUM[3*gv_pec + 2].GBPSUM_val && PSUM[3*gv_pec + 2].PSUMGB_rdy )
                                state <= IDLE;
                    default : state <= IDLE;
                endcase
        end
        assign PSUM[3*gv_pec + 0].reset_psum = state == SET_PSUM0; // set first row's value
        assign PSUM[3*gv_pec + 1].reset_psum = state == SET_PSUM1; // After last
        assign PSUM[3*gv_pec + 2].reset_psum = state == SET_PSUM2;


        wire clr_psumwrrow, inc_psumwrrow;
        wire PSUMGB_val, GBPSUM_rdy;
        wire overflow_psumwrrow;
        assign clr_psumwrrow = next_block;
        assign inc_psumwrrow = PSUMGB_val && GBPSUM_rdy;
        counter #(
            .COUNT_WIDTH(4)
            ) counter_psumwrrow(
                .CLK       (clk         ),
                .RESET_N   (rst_n       ),
                .CLEAR     (clr_psumwrrow   ),
                .DEFAULT   (4'd0           ),
                .INC       (inc_psumwrrow   ),
                .DEC       (1'b0           ),
                .MIN_COUNT (4'd0           ),
                .MAX_COUNT (4'd14       ), // 7 15
                .OVERFLOW  (overflow_psumwrrow ),
                .UNDERFLOW (            ),
                .COUNT     (    )
            );
    end
endgenerate

wire                        PSUMPEB_wr_fnh;
assign GEN_PEC[0].PSUMGB_val = PSUMGB_val0;
assign GEN_PEC[1].PSUMGB_val = PSUMGB_val1;
assign GEN_PEC[2].PSUMGB_val = PSUMGB_val2;
assign GEN_PEC[0].GBPSUM_rdy = GBPSUM_rdy0;
assign GEN_PEC[1].GBPSUM_rdy = GBPSUM_rdy1;
assign GEN_PEC[2].GBPSUM_rdy = GBPSUM_rdy2;
assign PSUMPEB_wr_fnh = GEN_PEC[0].overflow_psumwrrow && GEN_PEC[1].overflow_psumwrrow && GEN_PEC[2].overflow_psumwrrow;
assign PEBCCU_Fnh = ARBPEB_Fnh && PSUMPEB_wr_fnh;
// Psum In 
assign PSUM[0].GBPSUM_val = GBPSUM_val0;
assign PSUM[1].GBPSUM_val = GBPSUM_val0;
assign PSUM[2].GBPSUM_val = GBPSUM_val0;
assign PSUM[3].GBPSUM_val = GBPSUM_val1;
assign PSUM[4].GBPSUM_val = GBPSUM_val1;
assign PSUM[5].GBPSUM_val = GBPSUM_val1;
assign PSUM[6].GBPSUM_val = GBPSUM_val2;
assign PSUM[7].GBPSUM_val = GBPSUM_val2;
assign PSUM[8].GBPSUM_val = GBPSUM_val2;

assign PSUM[0].GBPSUM_data = GBPSUM_data0;
assign PSUM[1].GBPSUM_data = GBPSUM_data0;
assign PSUM[2].GBPSUM_data = GBPSUM_data0;
assign PSUM[3].GBPSUM_data = GBPSUM_data1;
assign PSUM[4].GBPSUM_data = GBPSUM_data1;
assign PSUM[5].GBPSUM_data = GBPSUM_data1;
assign PSUM[6].GBPSUM_data = GBPSUM_data2;
assign PSUM[7].GBPSUM_data = GBPSUM_data2;
assign PSUM[8].GBPSUM_data = GBPSUM_data2;

assign PSUMGB_rdy0 = PSUM[0].PSUMGB_rdy || PSUM[1].PSUMGB_rdy || PSUM[2].PSUMGB_rdy;
assign PSUMGB_rdy1 = PSUM[3].PSUMGB_rdy || PSUM[4].PSUMGB_rdy || PSUM[5].PSUMGB_rdy;
assign PSUMGB_rdy2 = PSUM[6].PSUMGB_rdy || PSUM[7].PSUMGB_rdy || PSUM[8].PSUMGB_rdy;


// Psum Out
assign PSUMGB_data0 =   PSUM[0].PSUMGB_val? PSUM[0].PSUMGB_data : 
                        PSUM[1].PSUMGB_val? PSUM[1].PSUMGB_data :
                        PSUM[2].PSUMGB_val? PSUM[2].PSUMGB_data : 0;
assign PSUMGB_data1 =   PSUM[3].PSUMGB_val? PSUM[3].PSUMGB_data : 
                        PSUM[4].PSUMGB_val? PSUM[4].PSUMGB_data :
                        PSUM[5].PSUMGB_val? PSUM[5].PSUMGB_data : 0;
assign PSUMGB_data2 =   PSUM[6].PSUMGB_val? PSUM[6].PSUMGB_data : 
                        PSUM[7].PSUMGB_val? PSUM[7].PSUMGB_data :
                        PSUM[8].PSUMGB_val? PSUM[8].PSUMGB_data : 0;

assign PSUMGB_val0 = PSUM[0].PSUMGB_val || PSUM[1].PSUMGB_val || PSUM[2].PSUMGB_val;
assign PSUMGB_val1 = PSUM[3].PSUMGB_val || PSUM[4].PSUMGB_val || PSUM[5].PSUMGB_val;
assign PSUMGB_val2 = PSUM[6].PSUMGB_val || PSUM[7].PSUMGB_val || PSUM[8].PSUMGB_val;
assign PSUM[0].GBPSUM_rdy = GBPSUM_rdy0;
assign PSUM[1].GBPSUM_rdy = GBPSUM_rdy0;
assign PSUM[2].GBPSUM_rdy = GBPSUM_rdy0;
assign PSUM[3].GBPSUM_rdy = GBPSUM_rdy1;
assign PSUM[4].GBPSUM_rdy = GBPSUM_rdy1;
assign PSUM[5].GBPSUM_rdy = GBPSUM_rdy1;
assign PSUM[6].GBPSUM_rdy = GBPSUM_rdy2;
assign PSUM[7].GBPSUM_rdy = GBPSUM_rdy2;
assign PSUM[8].GBPSUM_rdy = GBPSUM_rdy2;

// assign PEBMONITOR = { // 27 * 11 + 9*2 + 10 = 325
        // SRAM_WEI_dataout_rdy, // 27
        // SRAM_WEI_dataout_val, // 27
        // regarray_flgweiout_val, // 27
        // Regarray_FlgActout_Val, // 27
        // REGARRAY_FLGACT_WrReq, // 27
        // REGARRAY_FLGACT_WrEn , // 27
        // MACMUX_Val, // 27
        // Regarray_weiout_Rdy, // 27
//     MACARB_ReqHelp, // 27
//     PSUMARB_empty, // 9
//     ARBMAC_Rst, // 27
    // // ARBMAC_IDActRow, // 
    // // ARBMAC_IDWei,
    // // ARBMAC_IDPSUM,
//     ARBMAC_Switch, // 27
//     ARBACT_RowOn, // 1
//     ARBPEB_RowArb, // 4
//     ARBPSUM_fnh, // 9
//     PEBARB_RowCntFlg[ 0 +: 4] // 4
//     // ACTGB_Rdy,
//     // GBACT_Val,
//     // FLGACTGB_rdy,
//     // GBFLGACT_val
// };


endmodule

module Mux_2I #( // Handshake protocol
    parameter DATA_WIDTH = 8,
    parameter FIFO_ADDR_WIDTH = 2
    )(
    input                           clk,
    input                           rst_n,
    input                           datain_val0,
    input   [ DATA_WIDTH    -1 : 0] datain0,
    output                          datain_rdy0,//paulse

    input                           datain_val1,
    input   [ DATA_WIDTH    -1 : 0] datain1,
    output                          datain_rdy1,//paulse

    input                           dataout_rdy,
    output  [ DATA_WIDTH    -1 : 0] dataout,
    output                          dataout_val //paulse
    );
    wire        fifo_push;
    wire        fifo_push0;
    wire        fifo_push1;
    wire        fifo_pop;
    wire        fifo_empty;
    wire        fifo_full;
    wire [ DATA_WIDTH   -1 : 0] fifo_in;
    wire [ DATA_WIDTH   -1 : 0] fifo_out;
    assign datain_rdy0 = ~fifo_full; //Supest level
    assign datain_rdy1 = ~fifo_full && ~(datain_rdy0 && datain_val0);

    // actually, posedge is GetOut ahead a clk
    assign fifo_push = datain_rdy0 && datain_val0 || datain_rdy1 && datain_val1;
    assign fifo_in = datain_rdy0 && datain_val0 ? datain0 : datain1;

    fifo_fwft #(
            .DATA_WIDTH(DATA_WIDTH),
            .ADDR_WIDTH(FIFO_ADDR_WIDTH)
        ) inst_fifo_fwft (
            .clk        (clk),
            .Reset      (1'b0),
            .rst_n      (rst_n),
            .push       (fifo_push),
            .pop        (fifo_pop),
            .data_in    (fifo_in),
            .data_out   (fifo_out),
            .empty      (fifo_empty),
            .full       (fifo_full),
            .fifo_count ()
        );

    assign dataout = fifo_out;
    assign fifo_pop = dataout_rdy && ~fifo_empty;
    assign dataout_val = ~fifo_empty;// fifo_fwft?????? short delay

endmodule


module COUNT1 #(
    parameter DATA_WIDTH = 10,
    parameter ADDR_WIDTH = `C_LOG_2(DATA_WIDTH)
    )(
    input [ DATA_WIDTH    -1 : 0] din,
    output reg[ ADDR_WIDTH    -1 : 0] dout
    );
wire [ (DATA_WIDTH -1)*ADDR_WIDTH -1 : 0] count;

integer i;
always@(*) begin
    dout = 0;
    for(i=0; i< DATA_WIDTH; i=i+1) begin
        if(din[i])
            dout = dout + 1;
    end
end 

endmodule
