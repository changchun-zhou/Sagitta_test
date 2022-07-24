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
// File   : ARB.v
// Create : 2020-07-13 22:18:18
// Revise : 2020-08-11 10:28:59
// Editor : sublime text3, tab size (4)
// -----------------------------------------------------------------------------

`include "../source/include/dw_params_presim.vh"
module ARB #(
    parameter ROW_NUM_WIDTH = `BLK_WIDTH + `FRAME_WIDTH + `C_LOG_2(`LENROW)
    )(
    input                                           clk         ,
    input                                           rst_n       ,
    input                                           PEBARB_Sta  ,
    output                                          ARBPEB_Fnh  , // finish a block's arb
    // 4bit because of arbow 4bits
    input       [ `ACT_NUM_WIDTH                         -1 : 0] PEBARB_RowCntFlg, // control arbrow+1: when row's flag was counted

// Finish a row computation: + intra signal:corresponding Weight is first or second row
    input       [ `MAC_NUM                  -1 : 0] MAC_ReqHelp ,
    // input       [ `MAC_NUM/3                -1 : 0] PSUMARB_rdy ,
    input       [ `MAC_NUM/3                -1 : 0] PSUMARB_empty , // level:state == IDLE

    output  reg [ `MAC_NUM                  -1 : 0] ARBMAC_Rst  ,
    output  reg [ `C_LOG_2(`LENROW)         -1 : 0] ARBMAC_IDActRow [ 0 : `MAC_NUM  -1],
    output  reg [ `MAC_NUM_WIDTH            -1 : 0] ARBMAC_IDWei    [ 0 : `MAC_NUM  -1],// for Weight
    output  reg [ 4                         -1 : 0] ARBMAC_IDPSUM   [ 0 : `MAC_NUM  -1],
    output  reg [ `MAC_NUM                  -1 : 0] ARBMAC_Switch,

    output  reg                                     ARBACT_RowOn, // 1: current row's MAC all switch on
    output  wire[ `C_LOG_2(`LENROW)         -1 : 0] ARBPEB_RowArb, // current arb row 
    // output  reg [ 9                         -1 : 0] ARBPSUM_Sta,
    output  reg [ 9                         -1 : 0] ARBPSUM_fnh
                
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================



//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================

// i-th Weight Require being helped
reg [ `MAC_NUM              -1 : 0] WEI_ReqHelped   ; 
reg [ `MAC_NUM_WIDTH        -1 : 0] IDWei_Helped    ;
wire                                Help            ;
wire[ `MAC_NUM              -1 : 0] MAC_Help_One    ;
reg [ `C_LOG_2(`LENROW)     -1 : 0] arbrow          ; // arb which actrow;
wire                                arb_en          ;
wire[ `MAC_NUM_WIDTH        -1 : 0] IDMAC_Help      ;
reg [ 4                     -1 : 0] IDPSUM_Helped   ;
wire[ 4*9*3                 -1 : 0] IDARRAY_wei2psum;
integer                             wei             ;
reg                                 fnh             ;
reg [ 4                     -1 : 0] psum            ;

reg [ 4                     -1 : 0] PSUM_CntMAC[0 : 9 -1];

// Current row's weight whether need to be computed：0.need 1.not need
reg [ `MAC_NUM*`LENROW  -1 : 0] flagcompwei_row     ; 
wire[ `MAC_NUM          -1 : 0] flagcompwei_currow  ; 

//=====================================================================================================================
// Logic Design :
//=====================================================================================================================
// **************************************************************************
localparam IDLE = 0;
localparam ARB  = 1;
localparam COMP = 2;
reg [2          -1 : 0] state       ;
reg [2          -1 : 0] next_state  ;

always @(*) begin
  if(!rst_n) begin
    next_state <= IDLE;
  end else begin
    case (state)
        IDLE  : if ( PEBARB_Sta )
                    next_state <= ARB;
                else 
                    next_state <= IDLE;
        ARB:    if( (arbrow == `LENROW -1) && ~(|ARBMAC_Switch) )// all MAC finish
                    next_state <= IDLE;
                else 
                    next_state <= ARB;
      default: next_state <= IDLE;
    endcase
  end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end

// **************************************************************************
// WEI_ReqHelped
// **************************************************************************

// 1.flagcompwei_row
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        arbrow <= 0; // 
    end else if ( next_state == IDLE ) begin
        arbrow <= 0;
    // For Activation's RowAct: after count currow's flag
    // For Weight's blockwei: is ready when new block
    end else if ( &flagcompwei_currow && (arbrow + 1) <= PEBARB_RowCntFlg && arbrow < 15 ) begin // 
        arbrow <= arbrow + 1;
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin // reset, which column need to be computed
        flagcompwei_row <=
                           {{9'b000_111_111,9'b000_111_111,9'b000_111_111},
                            {9'b000_000_111,9'b000_000_111,9'b000_000_111},
                            {378'd0}, // 27*14
                            {9'b111_000_000,9'b111_000_000,9'b111_000_000},
                            {9'b111_111_000,9'b111_111_000,9'b111_111_000}}; 
    end else if ( next_state == IDLE ) begin // every block reset
        flagcompwei_row <=
                           {{9'b000_111_111,9'b000_111_111,9'b000_111_111},
                            {9'b000_000_111,9'b000_000_111,9'b000_000_111},
                            {378'd0}, // 27*14
                            {9'b111_000_000,9'b111_000_000,9'b111_000_000},
                            {9'b111_111_000,9'b111_111_000,9'b111_111_000}}; 
    end else if ( arb_en ) begin // arb a weight -> 1;
        flagcompwei_row[`MAC_NUM*arbrow + IDWei_Helped] <= 1;
    end
end

assign flagcompwei_currow = flagcompwei_row[`MAC_NUM*arbrow +: `MAC_NUM];

assign arb_en     = Help && state == ARB;
assign ARBPEB_Fnh = state == IDLE; //
// assign Help       = (|MAC_ReqHelp) && (|WEI_ReqHelped);
assign Help       = |(MAC_ReqHelp & WEI_ReqHelped);


ARRAY2ID ARRAY2ID_IDMAC_Help ( // Help other
    .Array(MAC_ReqHelp & WEI_ReqHelped),
    .ID(IDMAC_Help),
    .Array_One(MAC_Help_One)
    );
// **************************************************************************

// **************************************************************************
// Arb result out
// **************************************************************************


always @ ( * ) begin
    fnh           = 0;
    WEI_ReqHelped = 0;
    psum          = 0;
    IDPSUM_Helped = 0;
    IDPSUM_Helped = 0;
    IDWei_Helped  = 0;
    for(wei=0; wei<`MAC_NUM; wei=wei+1) begin
        psum = IDARRAY_wei2psum[4*wei +: 4];
        if( ~flagcompwei_currow[wei] && (~ARBPSUM_fnh[psum] || PSUMARB_empty[psum]) && ~fnh) begin
            IDWei_Helped        = wei;
            IDPSUM_Helped       = psum;
            fnh                 = 1;
            WEI_ReqHelped[wei]  = 1;
        // end
        end else begin
            IDWei_Helped        = IDWei_Helped      ; // hold
            IDPSUM_Helped       = IDPSUM_Helped     ;
            fnh                 = fnh               ;
            WEI_ReqHelped[wei]  = WEI_ReqHelped[wei];
        end
    end
end

// 1. to MAC
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ARBMAC_Rst      <= 0;
    end else if( arb_en ) begin // Need to help each other
        ARBMAC_Rst     <= MAC_Help_One ;//by bit or, then ~ & other   
    end else begin 
        ARBMAC_Rst <= 0; // arb at most one
    end
end

generate
    genvar mac;
    for(mac=0; mac < `MAC_NUM; mac=mac+1) begin : GEN_ARBMAC
        always @ ( posedge clk or negedge rst_n ) begin
            if ( !rst_n ) begin
                ARBMAC_IDActRow[mac] <= 0;
                ARBMAC_IDWei   [mac] <= 0;
                ARBMAC_IDPSUM  [mac] <= 0;
            end else if ( PEBARB_Sta ) begin
                ARBMAC_IDActRow[mac] <= 0;
                ARBMAC_IDWei   [mac] <= 0;
                ARBMAC_IDPSUM  [mac] <= 0;
            end else if (arb_en && mac == IDMAC_Help ) begin
                ARBMAC_IDActRow[mac] <= arbrow;
                ARBMAC_IDWei   [mac] <= IDWei_Helped;
                ARBMAC_IDPSUM  [mac] <= IDPSUM_Helped;//which MAC will help
            end
        end

    end
    
endgenerate


always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ARBMAC_Switch   <= 0;
    end else if ( PEBARB_Sta ) begin
        ARBMAC_Switch   <= 0;
    end else begin
        ARBMAC_Switch  <= (arb_en ? 1 << IDMAC_Help : 0) | (ARBMAC_Switch &  ~MAC_ReqHelp);
    end
end

// 2. to CHN from IDWei_Helped to CHN's switch, to get weight's rdy
wire [ 4*9                      -1 : 0] Base_wei2psum0  ;
wire [ 4*9                      -1 : 0] Base_wei2psum1  ;
wire [ 4*9                      -1 : 0] Base_wei2psum2  ;
reg  [ 4*9                      -1 : 0] shift_wei2psum0 ;
reg  [ 4*9                      -1 : 0] shift_wei2psum1 ;
reg  [ 4*9                      -1 : 0] shift_wei2psum2 ;
assign Base_wei2psum0 = { 4'd1, 4'd1, 4'd1, 4'd2, 4'd2, 4'd2, 4'd0, 4'd0, 4'd0}; //A_row0 => w_row1 w_row2 w_row0
assign Base_wei2psum1 = { 4'd4, 4'd4, 4'd4, 4'd5, 4'd5, 4'd5, 4'd3, 4'd3, 4'd3}; //A_row0 => w_row1 w_row2 w_row0
assign Base_wei2psum2 = { 4'd7, 4'd7, 4'd7, 4'd8, 4'd8, 4'd8, 4'd6, 4'd6, 4'd6}; //A_row0 => w_row1 w_row2 w_row0

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        shift_wei2psum0 <= Base_wei2psum0;
        shift_wei2psum1 <= Base_wei2psum1;
        shift_wei2psum2 <= Base_wei2psum2;
    end else if ( next_state == IDLE ) begin // Reset
        shift_wei2psum0 <= Base_wei2psum0;
        shift_wei2psum1 <= Base_wei2psum1;
        shift_wei2psum2 <= Base_wei2psum2;
    end else if ( &flagcompwei_currow && ~ARBACT_RowOn ) begin // Every New Row -> Shift
        shift_wei2psum0 <= { shift_wei2psum0, shift_wei2psum0[4*6 +: 4*3]};
        shift_wei2psum1 <= { shift_wei2psum1, shift_wei2psum1[4*6 +: 4*3]};
        shift_wei2psum2 <= { shift_wei2psum2, shift_wei2psum2[4*6 +: 4*3]};
    end
end

assign IDARRAY_wei2psum = {shift_wei2psum2, shift_wei2psum1, shift_wei2psum0};

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        ARBACT_RowOn <= 0;
    end else begin
        ARBACT_RowOn <= &flagcompwei_currow;
    end
end

assign ARBPEB_RowArb = arbrow;

generate
    genvar gv_psum;
    for(gv_psum=0; gv_psum<9; gv_psum=gv_psum+1) begin : GEN_ARBPSUM
        always @ ( posedge clk or negedge rst_n ) begin
            if ( !rst_n ) begin
                PSUM_CntMAC[gv_psum] <= 0;
            end else if (PEBARB_Sta) begin 
                PSUM_CntMAC[gv_psum] <= 0;
            end else if (ARBPSUM_fnh[gv_psum] && ~PSUMARB_empty[gv_psum] ) begin// PSUM reset
                PSUM_CntMAC[gv_psum] <= 0;
            end else if ( arb_en && IDPSUM_Helped == gv_psum ) begin // Bug
                PSUM_CntMAC[gv_psum] <= PSUM_CntMAC[gv_psum] + 1; 
            end
        end
        always @ ( posedge clk or negedge rst_n ) begin
            if ( !rst_n ) begin
                ARBPSUM_fnh[gv_psum] <= 1;
            end else if (PEBARB_Sta) begin 
                ARBPSUM_fnh[gv_psum] <= 1;
            end else if ( PSUMARB_empty[gv_psum] && arb_en && IDPSUM_Helped == gv_psum) begin // PSUM is IDLE && wei->psum
                ARBPSUM_fnh[gv_psum] <= 0; // PSUM reset
            end else if (PSUM_CntMAC[gv_psum]==8 && arb_en && IDPSUM_Helped == gv_psum ) begin // Next clk -> 9MAC
                ARBPSUM_fnh[gv_psum] <= 1;
            end
        end
    
    end
endgenerate


reg [40         -1 : 0] Summary_ARB_MAC_wait[0 : 26];
reg [40         -1 : 0] Summary_ARB_MAC_wait_flagcompwei[0 : 26];
wire [40         -1 : 0] Summary_ARB_MAC_wait_PSUM[0 : 26];
wire [40         -1 : 0] Summary_ARB_MAC_wait_avg;
wire [40         -1 : 0] Summary_ARB_MAC_wait_flagcompwei_avg;
wire [40         -1 : 0] Summary_ARB_MAC_wait_PSUM_avg;
generate
    genvar mac_sum;
    for (mac_sum=0; mac_sum < 27; mac_sum = mac_sum + 1) begin
        always @ ( posedge clk or negedge rst_n ) begin
            if ( !rst_n ) begin
                Summary_ARB_MAC_wait[mac_sum] <= 0;
            end else if ( state == ARB && MAC_ReqHelp[mac_sum] ) begin
                Summary_ARB_MAC_wait[mac_sum] <= Summary_ARB_MAC_wait[mac_sum] + 1;
            end
        end

        always @ ( posedge clk or negedge rst_n ) begin
            if ( !rst_n ) begin
                Summary_ARB_MAC_wait_flagcompwei[mac_sum] <= 0;
            end else if ( state == ARB && MAC_ReqHelp[mac_sum] && &flagcompwei_currow ) begin
                Summary_ARB_MAC_wait_flagcompwei[mac_sum] <= Summary_ARB_MAC_wait_flagcompwei[mac_sum] + 1;
            end
        end

        assign Summary_ARB_MAC_wait_PSUM[mac_sum] = Summary_ARB_MAC_wait[mac_sum] - Summary_ARB_MAC_wait_flagcompwei[mac_sum];

    end
endgenerate

assign Summary_ARB_MAC_wait_avg = (
                                    Summary_ARB_MAC_wait[0] + Summary_ARB_MAC_wait[1] + Summary_ARB_MAC_wait[2]
                                  + Summary_ARB_MAC_wait[3] + Summary_ARB_MAC_wait[4] + Summary_ARB_MAC_wait[5]
                                  + Summary_ARB_MAC_wait[6] + Summary_ARB_MAC_wait[7] + Summary_ARB_MAC_wait[8]
                                  + Summary_ARB_MAC_wait[9] + Summary_ARB_MAC_wait[10] + Summary_ARB_MAC_wait[11]
                                  + Summary_ARB_MAC_wait[12] + Summary_ARB_MAC_wait[13] + Summary_ARB_MAC_wait[14]
                                  + Summary_ARB_MAC_wait[15] + Summary_ARB_MAC_wait[16] + Summary_ARB_MAC_wait[17]
                                  + Summary_ARB_MAC_wait[18] + Summary_ARB_MAC_wait[19] + Summary_ARB_MAC_wait[20]
                                  + Summary_ARB_MAC_wait[21] + Summary_ARB_MAC_wait[22] + Summary_ARB_MAC_wait[23]
                                  + Summary_ARB_MAC_wait[24] + Summary_ARB_MAC_wait[25] + Summary_ARB_MAC_wait[26]
                                  )/27;

assign Summary_ARB_MAC_wait_flagcompwei_avg = (
                                    Summary_ARB_MAC_wait_flagcompwei[0 ] + Summary_ARB_MAC_wait_flagcompwei[1 ] + Summary_ARB_MAC_wait_flagcompwei[2 ]
                                  + Summary_ARB_MAC_wait_flagcompwei[3 ] + Summary_ARB_MAC_wait_flagcompwei[4 ] + Summary_ARB_MAC_wait_flagcompwei[5 ]
                                  + Summary_ARB_MAC_wait_flagcompwei[6 ] + Summary_ARB_MAC_wait_flagcompwei[7 ] + Summary_ARB_MAC_wait_flagcompwei[8 ]
                                  + Summary_ARB_MAC_wait_flagcompwei[9 ] + Summary_ARB_MAC_wait_flagcompwei[10] + Summary_ARB_MAC_wait_flagcompwei[11]
                                  + Summary_ARB_MAC_wait_flagcompwei[12] + Summary_ARB_MAC_wait_flagcompwei[13] + Summary_ARB_MAC_wait_flagcompwei[14]
                                  + Summary_ARB_MAC_wait_flagcompwei[15] + Summary_ARB_MAC_wait_flagcompwei[16] + Summary_ARB_MAC_wait_flagcompwei[17]
                                  + Summary_ARB_MAC_wait_flagcompwei[18] + Summary_ARB_MAC_wait_flagcompwei[19] + Summary_ARB_MAC_wait_flagcompwei[20]
                                  + Summary_ARB_MAC_wait_flagcompwei[21] + Summary_ARB_MAC_wait_flagcompwei[22] + Summary_ARB_MAC_wait_flagcompwei[23]
                                  + Summary_ARB_MAC_wait_flagcompwei[24] + Summary_ARB_MAC_wait_flagcompwei[25] + Summary_ARB_MAC_wait_flagcompwei[26]
                                  )/27;

assign Summary_ARB_MAC_wait_PSUM_avg = (
                                    Summary_ARB_MAC_wait_PSUM[0 ] + Summary_ARB_MAC_wait_PSUM[1 ] + Summary_ARB_MAC_wait_PSUM[2 ]
                                  + Summary_ARB_MAC_wait_PSUM[3 ] + Summary_ARB_MAC_wait_PSUM[4 ] + Summary_ARB_MAC_wait_PSUM[5 ]
                                  + Summary_ARB_MAC_wait_PSUM[6 ] + Summary_ARB_MAC_wait_PSUM[7 ] + Summary_ARB_MAC_wait_PSUM[8 ]
                                  + Summary_ARB_MAC_wait_PSUM[9 ] + Summary_ARB_MAC_wait_PSUM[10] + Summary_ARB_MAC_wait_PSUM[11]
                                  + Summary_ARB_MAC_wait_PSUM[12] + Summary_ARB_MAC_wait_PSUM[13] + Summary_ARB_MAC_wait_PSUM[14]
                                  + Summary_ARB_MAC_wait_PSUM[15] + Summary_ARB_MAC_wait_PSUM[16] + Summary_ARB_MAC_wait_PSUM[17]
                                  + Summary_ARB_MAC_wait_PSUM[18] + Summary_ARB_MAC_wait_PSUM[19] + Summary_ARB_MAC_wait_PSUM[20]
                                  + Summary_ARB_MAC_wait_PSUM[21] + Summary_ARB_MAC_wait_PSUM[22] + Summary_ARB_MAC_wait_PSUM[23]
                                  + Summary_ARB_MAC_wait_PSUM[24] + Summary_ARB_MAC_wait_PSUM[25] + Summary_ARB_MAC_wait_PSUM[26]
                                  )/27;


//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================

endmodule

module ARRAY2ID #(
    parameter ARRAY_WIDTH = `MAC_NUM
    )(
    input       [ ARRAY_WIDTH                -1 : 0] Array      ,
    output  reg [ `C_LOG_2(ARRAY_WIDTH)      -1 : 0] ID         ,
    output  reg [ ARRAY_WIDTH                -1 : 0] Array_One  
    );

integer             i   ;
reg                 fnh ;
always @ ( Array) begin
    fnh = 0;
    Array_One = 0;
    ID = 0;
    for(i=0;i<ARRAY_WIDTH; i=i+1)begin
        if(Array[i] && !fnh) begin
            ID  = i;
            fnh = 1;
            Array_One[i] = 1; 
        end
    end
end

endmodule
