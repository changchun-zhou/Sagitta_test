//======================================================
// Copyright (C) 2020 By zhoucc
// All Rights Reserved
//======================================================
// Module : MAC
// Author : CC zhou
// Contact : 
// Date : 6 . 12.2020
//=======================================================
// Description :
//========================================================
`include "../source/include/dw_params_presim.vh"
module MAC
    (
    input                                   clk     ,
    input                                   rst_n   ,

    output                                  MACMUX_Val,
    output reg [`PSUM_ADDR_WIDTH    -1 : 0] MACMUX_Addr,       
    output reg[ `PSUM_WIDTH            -1 : 0] MACMUX_Psum, // reg
    input                                   MUXMAC_Rdy,
    output                                  MACMUX_Empty,

    output                                  MACARB_ReqHelp, // reg
    input                                   ARBMAC_Rst,
    // input [ `REGACT_ADDR_WIDTH      -1 : 0] ARBMAC_OffsetRow,// how many valid data in a row 
    input [ 2                       -1 : 0] PEBMAC_WeiCol, // W0 W1 or W2 for MACMUX_Addr AddrBase
    input [`REGFLGACT_ADDR_WIDTH                        -1 : 0] AddrRowFlgAct,
    input [ `ACT_NUM_WIDTH         -1 : 0] AddrRowAct,
    input [ `ADDR_WIDTH_ALL                                    -1 : 0] AddrBlockWei,
    
    input [ `BLOCK_DEPTH            -1 : 0] MAC_FlgWei,
    input                                   MAC_FlgWei_Val,

    output                                  MAC_AddrFlgAct_Rdy,
    output reg [ `REGFLGACT_ADDR_WIDTH-1:0] MAC_AddrFlgAct,
    input                                   MAC_FlgAct_Val,
    input [ `BLOCK_DEPTH            -1 : 0] MAC_FlgAct,

    output                                  MAC_AddrAct_Rdy,
    output reg[ `ACT_NUM_WIDTH     -1 : 0] MAC_AddrAct,
    input                                   MAC_Act_Val,
    input [ `DATA_WIDTH             -1 : 0] MAC_Act,

    output                                  MAC_AddrWei_Rdy,
    output reg[ `MAX_DEPTH_WIDTH     -1 : 0] MAC_AddrWei,
    input                                   MAC_Wei_Val,
    input [ `DATA_WIDTH             -1 : 0] MAC_Wei // trans     
);
//=====================================================================================================================
// Constant Definition :
//=====================================================================================================================


//=====================================================================================================================
// Variable Definition :
//=====================================================================================================================
wire                                    MAC_Fnh;

wire[`C_LOG_2(`BLOCK_DEPTH)     : 0] MACAW_OffsetAct;
wire[`C_LOG_2(`BLOCK_DEPTH)     : 0] MACAW_OffsetWei;

wire                                    MACAW_ValOffset;
wire                                    MAC_FnhRow;

wire                                    ActWei_Val;
wire                                    pipe;
reg                                     MAC_Addr_val, fnh;

wire                                    MAC_Empty;
reg [`PSUM_ADDR_WIDTH + 1      -1 : 0]  Cnt_Comp;

reg                                     val_comp; 

wire                                    en_mac;

wire                                    O_OffsetAct_val; reg O_OffsetAct_val_d;
wire                                    O_OffsetWei_val; reg O_OffsetWei_val_d;
//=====================================================================================================================
// Logic Design :
//=====================================================================================================================

localparam IDLE    = 0;
localparam WAITFLG = 1;
localparam COMP    = 2;
localparam WAITMUX = 3;
reg [2 -1 : 0           ] state;
reg [2 -1 : 0           ] next_state;

always @(*) begin
  if(!rst_n) begin
    next_state <= IDLE;
  end else begin
    case (state)
        IDLE  : if ( ARBMAC_Rst )
                    next_state <= WAITFLG;
                else 
                    next_state <= IDLE;
        WAITFLG:   if (MAC_FlgWei_Val&&MAC_FlgAct_Val  )
                    next_state <= COMP; // Compute all chns of a location
                else 
                    next_state <= WAITFLG;
        COMP:   if ( MAC_FnhRow && ( (~val_comp&&en_mac) || ~MAC_Addr_val) ) // after compute psum then
                    next_state <= IDLE;
                else if ( MAC_Fnh && ( (~val_comp&&en_mac) || ~MAC_Addr_val))
                    next_state <= WAITFLG;
                else if ( MAC_Fnh && val_comp && en_mac) // ~zero flag -> Compute PSUM and WAITMUX
                    next_state <= WAITMUX;
                else 
                    next_state <= COMP;
        WAITMUX:if(MUXMAC_Rdy)
                    if(MAC_FnhRow)
                        next_state <= IDLE;
                    else
                        next_state <= WAITFLG;
                else 
                    next_state <= WAITMUX;
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
assign MAC_Sta = state==WAITFLG && next_state==COMP; // paulse REG/////////////


assign MAC_AddrFlgAct_Rdy = state == WAITFLG;// 

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        MAC_AddrFlgAct <= 0;
    end else if ( ARBMAC_Rst ) begin
        MAC_AddrFlgAct <= AddrRowFlgAct; // or 16
    end else if ( MAC_Sta ) begin
        MAC_AddrFlgAct <= MAC_AddrFlgAct + 1;
    end
end

assign MAC_FnhRow = Cnt_Comp == 16 && MAC_Fnh; //computed a row

localparam IDLE_REQ = 0;
localparam CMP_REQ = 1;

reg [1 -1 : 0           ] state_req;
reg [1 -1 : 0           ] next_state_req;

always @(*) begin
    if(!rst_n) begin
        next_state_req <= IDLE_REQ;
    end else begin
        case(state_req)
            IDLE_REQ : if (ARBMAC_Rst)
                            next_state_req <= CMP_REQ;
                        else 
                            next_state_req <= IDLE_REQ;
            CMP_REQ :   if ( MAC_Empty ) // Cut down logic with register
                            next_state_req <= IDLE_REQ;
                        else 
                            next_state_req <= CMP_REQ;
            default :   next_state_req <= IDLE_REQ;
        endcase
    end 
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        state_req <= IDLE_REQ;
    end else begin
        state_req <= next_state_req;
    end
end
// cut down with next_state
// MACARB_ReqHelp must be with ARBMAC_Rst;
assign MACARB_ReqHelp = next_state_req == IDLE_REQ; 


always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Cnt_Comp <= 0;
    end else if ( ARBMAC_Rst ) begin
        Cnt_Comp <= 0;
    end else if (MAC_Sta ) begin
        Cnt_Comp <= Cnt_Comp + 1;
    end
end

// ~MAC_Addr_val || Addr_rdy: when begin: val=0, pipe; when val=1, rdy pipe;
assign pipe = (~MAC_Addr_val || ActWei_Val) && state ==COMP ; 
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        {MAC_AddrAct, MAC_Addr_val, fnh} <= 0; // 
        O_OffsetAct_val_d <= 0;
        O_OffsetWei_val_d <= 0;
    end else if (ARBMAC_Rst) begin
        {MAC_AddrAct, MAC_Addr_val, fnh} <= {AddrRowAct -1,1'b0, 1'b1}; // 
        O_OffsetAct_val_d <= 0;
        O_OffsetWei_val_d <= 0;
    end else if ( MAC_Sta) begin
        O_OffsetAct_val_d <= 0;
        O_OffsetWei_val_d <= 0;
        {MAC_AddrAct, MAC_Addr_val, fnh} <= {MAC_AddrAct,1'b0, 1'b1}; // 
    end else if ( pipe ) begin // pipeline
        {MAC_AddrAct, MAC_Addr_val, fnh} <= {MAC_AddrAct + MACAW_OffsetAct, MACAW_ValOffset,MAC_Fnh};
        O_OffsetAct_val_d <= O_OffsetAct_val;
        O_OffsetWei_val_d <= O_OffsetWei_val;
    end
end

assign MAC_AddrAct_Rdy = MAC_Addr_val && O_OffsetAct_val_d; // ARBMAC_Rst || MACAW_ValOffset;// Make sure that Array isn't empty
assign MAC_AddrWei_Rdy = MAC_Addr_val && O_OffsetWei_val_d;

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        MAC_AddrWei <= 0;
    end else if (ARBMAC_Rst) begin
        MAC_AddrWei <= AddrBlockWei -1;
    end else if (MAC_Sta) begin
        MAC_AddrWei <= AddrBlockWei -1;
    end else if (pipe  ) begin
        MAC_AddrWei <= MAC_AddrWei + MACAW_OffsetWei;
    end
end

assign ActWei_Val = (MAC_Wei_Val&&MAC_Act_Val) && MAC_Addr_val;
//=====================================================================================================================
// Sub-Module :
//=====================================================================================================================

FLGOFFSET #(
        .DATA_WIDTH(`BLOCK_DEPTH)
    ) inst_FLGOFFSET (
        .clk        (clk),
        .rst_n      (rst_n),
        .I_Sta      (MAC_Sta),
        .I_Pipe (pipe ),// can compute next address
        .I_ActFlag  (MAC_FlgAct),
        .I_WeiFlag  (MAC_FlgWei),
        .O_Offset_val  (MACAW_ValOffset),// >>>>>??
        .O_OffsetAct_val(O_OffsetAct_val),
        .O_OffsetWei_val(O_OffsetWei_val),
        .O_fnh     (MAC_Fnh),
        .O_Offset_Act (MACAW_OffsetAct),
        .O_Offset_Wei (MACAW_OffsetWei)
    );
assign en_mac = ActWei_Val && MAC_Addr_val && ~fnh;
always @ ( posedge clk or negedge rst_n ) begin
    if ( ~rst_n ) begin
        MACMUX_Psum <= 0;
    end else if ( MAC_Sta ) begin
        MACMUX_Psum <= 0;
    end else if ( en_mac ) begin
        MACMUX_Psum <= $signed(MACMUX_Psum) + $signed(MAC_Act) * $signed(MAC_Wei);
    end
end


always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        MACMUX_Addr <= 0;
        val_comp    <= 0;
    end else if (ARBMAC_Rst  ) begin
        MACMUX_Addr <= (0 - PEBMAC_WeiCol);// W0:0; W1:-1; W2:-2
        val_comp    <= 0;
    end else if ( MAC_Sta  ) begin// posedge
        MACMUX_Addr <= MACMUX_Addr + 1; // Save's address in PSUM_ARRAY
        val_comp    <=  1 <= (MACMUX_Addr + 1) && (MACMUX_Addr + 1) <= 14;
    end
end

// reg reg_MACMUX_Val;

// always @ ( posedge clk or negedge rst_n ) begin
//     if ( !rst_n ) begin
//         reg_MACMUX_Val <= 0;
//     end else if ( MAC_Sta ) begin
//         reg_MACMUX_Val <= 0;
//     // 1.addr isn't valid -> skip compute psum; 2.addr is valid -> same with psum
//     end else if ( state == COMP && MAC_Fnh && ( ~MAC_Addr_val || en_mac)) begin 
//         reg_MACMUX_Val <= 1;
//     end
// end


assign MACMUX_Val = state == WAITMUX && ~MUXMAC_Rdy; // ~MUXMAC_Rdy because Val delay 2 clk after rdy
assign MACMUX_Empty = state == IDLE;


Delay #(
    .NUM_STAGES(1),
    .DATA_WIDTH(1)
    )Delay_MAC_FnhRow_d(
    .CLK(clk),
    .RESET_N(rst_n),
    .DIN(next_state==IDLE && state != IDLE), // turn to IDLE
    .DOUT(MAC_Empty)
    );

// *****************************************************
reg [40     -1 : 0] Summary_MAC_compute;
reg [40     -1 : 0] Summary_MAC_compute_sta;
reg [40     -1 : 0] Summary_all;
reg [40     -1 : 0] Summary_MAC_macwork;
reg [40     -1 : 0] Summary_MAC_wait_flgwei;
reg [40     -1 : 0] Summary_MAC_wait_flgact;
reg [40     -1 : 0] Summary_MAC_wait_wei;
reg [40     -1 : 0] Summary_MAC_wait_act;
reg [40     -1 : 0] Summary_MAC_wait_psum;

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Summary_MAC_compute <= 0;
    end else if ( en_mac ) begin
        Summary_MAC_compute <= Summary_MAC_compute + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Summary_MAC_compute_sta <= 0;
    end else if ( MAC_Sta ||  en_mac ) begin
        Summary_MAC_compute_sta <= Summary_MAC_compute_sta + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Summary_all <= 0;
    end else begin
        Summary_all <= Summary_all + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Summary_MAC_macwork <= 0;
    end else if( state != IDLE) begin
        Summary_MAC_macwork <= Summary_MAC_macwork + 1;
    end
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Summary_MAC_wait_flgwei <= 0;
    end else if( state == WAITFLG && !MAC_FlgWei_Val) begin
        Summary_MAC_wait_flgwei <= Summary_MAC_wait_flgwei + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Summary_MAC_wait_flgact <= 0;
    end else if( state == WAITFLG && !MAC_FlgAct_Val) begin
        Summary_MAC_wait_flgact <= Summary_MAC_wait_flgact + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Summary_MAC_wait_wei <= 0;
    end else if( state != IDLE && MAC_AddrWei_Rdy && !MAC_Wei_Val) begin
        Summary_MAC_wait_wei <= Summary_MAC_wait_wei + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Summary_MAC_wait_act <= 0;
    end else if( state != IDLE && MAC_AddrAct_Rdy && !MAC_Act_Val) begin
        Summary_MAC_wait_act <= Summary_MAC_wait_act + 1;
    end
end
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        Summary_MAC_wait_psum <= 0;
    end else if( state == WAITMUX ) begin
        Summary_MAC_wait_psum <= Summary_MAC_wait_psum + 1;
    end
end

endmodule