// `define FPGA

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
module  FPGA_asysFIFO #(
    parameter FREQUENCY = 5)
(
    input                           I_clk_src_p        ,
    input                           I_clk_src_n        ,
    input                           I_rst       ,
    input                           I_SW0            , // SW2: 1-8
    input                           I_SW1            ,
    input                           I_SW_N            ,
    input                           I_SW_C            ,
    input                           I_SW4            ,
    input                           I_SW5            ,
    output                          O_FPGA_clk_locked, // GPIO_LED_1_LS

    output                          Hold_I_spi_data ,

    output reg                         O_SW_clk        , // switch of clk_chip
    output                          O_reset_n       , // rst_n of whole chip

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
wire                                    cfg_val;
reg                                     cfg_rdy;
reg                                     cfg_rdy_neg;

reg                                     wr_rdy_neg;
wire                                    wr_val;
reg                                     wr_rdy;

reg                                     rd_val_neg;
reg                                     rd_val;
wire                                    rd_rdy;
reg [ 8 -1 : 0] cnt_block;
//==============================================================================
// Logic Design :
//==============================================================================

//==============================================================================
// Ports
assign rst_n            = ~I_rst || O_reset_n;
// Mode Choose
assign O_bypass         = I_SW0;
assign O_bypass_fifo    = I_SW1;

// Reset/Start
wire trigger_SW_clk;
wire trigger_O_reset_n;
`ifdef FPGA
    always @ ( posedge clk or negedge rst_n ) begin
        if ( !rst_n ) begin
            O_SW_clk <= 0;
        end else if ( trigger_SW_clk ) begin
            O_SW_clk <= 1;
        end
    end


    flutter_free #(
        .FREQUENCY(FREQUENCY))
    flutter_free_trigger_SW_clk (
            .clk    (clk),
            .rst_n  (rst_n),
            .btn    (I_SW_N),
            .signal (trigger_SW_clk)
        );


    flutter_free #(
        .FREQUENCY(FREQUENCY))
    flutter_free_trigger_O_reset_n (
            .clk    (clk),
            .rst_n  (rst_n),
            .btn    (I_SW_C),
            .signal (trigger_O_reset_n)
        );
`else
    assign trigger_SW_clk = I_SW_N;
    assign trigger_O_reset_n = I_SW_C;
    assign clk = I_clk_src_p;
`endif

assign O_reset_n        = ~I_rst || ~trigger_O_reset_n;

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
assign IO_spi_data      = ~O_OE_req ? O_spi_data : 'bz;
// assign GBIF_wr_data  = IO_spi_data;
// Avoid synth out
assign Hold_I_spi_data  = |IO_spi_data && |cnt_block; 
assign O_spi_sck        = clk;
assign O_Monitor_En     = I_Monitor_OutVld & |I_Monitor_Out & I_DLL_lock & I_clk_out & I_sck_out;
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
reg [ 10 : 0]                                            flag_pre_rd;
reg [ 20          - 1 : 0 ] rd_size      ;

// reg config_ready;
wire config_req;
reg [20 -1 :0] Cfg_RD_Num;

localparam IDLE = 0, CONFIG = 1, WAIT = 2, RD_DATA = 3, RD_STILL = 4, WR_DATA = 5;  
always @(*) begin
    next_state = state;
    case (state)
      IDLE    : if ( config_req ) 
                  next_state = CONFIG;

      CONFIG  : next_state = WAIT;

      WAIT    : next_state = RD_DATA;

      RD_DATA : if ( rd_size == Cfg_RD_Num ) 
                  next_state = IDLE;

      // RD_STILL : if(state_ddd == RD_STILL) //
      //             next_state = IDLE;
    endcase
end

assign O_OE_req = state == RD_DATA ? 0 : 1; // ?? enough time for pad convert

// ====================================================================================================================
// pull down O_spi_cs_n
 reg O_spi_cs_n_;
 always @(negedge clk or negedge rst_n) begin : proc_O_spi_cs_rx
  if(!rst_n) begin
    O_spi_cs_n_ <= 1;
  end else if( state == RD_DATA ) begin
        O_spi_cs_n_ <= 0;
  end else 
        O_spi_cs_n_ <= 1;
end

assign O_spi_cs_n = O_spi_cs_n_; //ahead 1 sck pull down;

// ====================================================================================================================
// O_spi_data

always @(negedge clk or negedge rst_n) begin : proc_O_spi_mosi 
    if( !rst_n ) begin
        O_spi_data <= 0;
        rd_size    <= 0;
        Cfg_RD_Num <= 0;
    end else if (state == CONFIG) begin
        // if (I_switch_rdwr) // 
        case(cfg_info)
          `IFCODE_CFG   :  Cfg_RD_Num <= `RD_SIZE_CFG-32*flag_pre_rd[cfg_info];
          `IFCODE_WEIADDR: Cfg_RD_Num <= `RD_SIZE_WEIADDR - 32*flag_pre_rd[cfg_info];
          `IFCODE_ACT   :  Cfg_RD_Num <= `RD_SIZE_ACT-32*flag_pre_rd[cfg_info];
          `IFCODE_FLGACT:  Cfg_RD_Num <= `RD_SIZE_FLGACT-32*flag_pre_rd[cfg_info];
          `IFCODE_WEI   :  Cfg_RD_Num <= `RD_SIZE_WEI-32*flag_pre_rd[cfg_info];
          `IFCODE_FLGWEI:  Cfg_RD_Num <= `RD_SIZE_FLGWEI-32*flag_pre_rd[cfg_info];

          `IFCODE_FLGOFM:  Cfg_RD_Num <= `WR_SIZE_FLGOFM; 
          `IFCODE_OFM   :  Cfg_RD_Num <= `WR_SIZE_OFM;
          default       :  Cfg_RD_Num   <= 2048;
        endcase
        rd_size <= 0;
        O_spi_data <= 0;
    end else if( state == RD_DATA ) begin
        O_spi_data  <= rd_data;
        rd_size <= rd_size + 1;
    end else
        O_spi_data <= 128'dz;
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cfg_info <= 0;
    end else if ( next_state == CONFIG ) begin // update
        cfg_info <= IO_spi_data[21:18];
    end
end
reg [4 - 1: 0] cfg_info_pre_rd [0:100];
reg [ 8 -1: 0] addr_pre_rd;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cfg_info_pre_rd[0] <= 3; // sck period = 20; clk_chip =14;
        cfg_info_pre_rd[1] <= 6;
        cfg_info_pre_rd[2] <= 3;
        cfg_info_pre_rd[3] <= 3;
        cfg_info_pre_rd[4] <= 6;
    end 
end

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        flag_pre_rd <= 0;
        addr_pre_rd <= 0;
    end else if ( state == RD_DATA && next_state == IDLE && !I_switch_rdwr) begin // update
        flag_pre_rd[cfg_info_pre_rd[addr_pre_rd]] <= 1;
    end else if ( flag_pre_rd && state == CONFIG && cfg_info == cfg_info_pre_rd[addr_pre_rd] ) begin
        flag_pre_rd[cfg_info_pre_rd[addr_pre_rd]] <= 0;
        addr_pre_rd <= addr_pre_rd + 1;
    end
end


// generate rd_data
reg [8 - 1 : 0]wei_addr_addr;
wire [16        -1 : 0] wei_base_addr0;
wire [16        -1 : 0] wei_base_addr1;
wire [16        -1 : 0] wei_base_addr2;
wire [16        -1 : 0] wei_base_addr3;
wire [16        -1 : 0] wei_base_addr4;
wire [16        -1 : 0] wei_base_addr5;
wire [16        -1 : 0] wei_base_addr6;
wire [16        -1 : 0] wei_base_addr7;

always @ ( * )begin
    if (state == RD_DATA) begin
        if (cfg_info == 0) begin
            rd_data = { 1'd0,
                            6'd10, 8'd1, 11'd1, 6'd3, 10'd1,
                            4'd1, 4'd2,4'd1, 4'd4,
                            4'd1,4'd1, 4'd4,
                            12'd4, 8'd2,
                            { 20'd1, 8'd0, 1'd1, 1'd0, 3'd2 }};

        end else if (cfg_info == 3) begin
            // rd_data = {{14+ wei_base_addr},{12 + 16*wei_addr_addr}[0+:16], {10 + 16*wei_addr_addr}[0+:16], {8 + 16*wei_addr_addr}[0+:16],
            //            {6 + 16*wei_addr_addr}[0+:16],{4  + 16*wei_addr_addr}[0+:16], {2  + 16*wei_addr_addr}[0+:16], {0 + 16*wei_addr_addr}[0+:16] };
            rd_data = { wei_base_addr7, wei_base_addr6, wei_base_addr5, wei_base_addr4,
                        wei_base_addr3, wei_base_addr2, wei_base_addr1, wei_base_addr0 };
        end else if (cfg_info == 4) begin
            rd_data = {16{8'd1}};
        end else if (cfg_info == 5) begin
            rd_data = {64{2'b10}};
        end else if (cfg_info == 6) begin
            rd_data = {16{8'd1}};
        end else if (cfg_info == 7) begin
            rd_data = {64{2'b10}};
        end else begin
            rd_data = 0;
        end
    end else begin
        rd_data = 0;
    end
end


assign wei_base_addr0 = wei_addr_addr*16 + 0;
assign wei_base_addr1 = wei_addr_addr*16 + 2;
assign wei_base_addr2 = wei_addr_addr*16 + 4;
assign wei_base_addr3 = wei_addr_addr*16 + 6;
assign wei_base_addr4 = wei_addr_addr*16 + 8;
assign wei_base_addr5 = wei_addr_addr*16 + 10;
assign wei_base_addr6 = wei_addr_addr*16 + 12;
assign wei_base_addr7 = wei_addr_addr*16 + 14;

// negedge update

always @ (negedge clk or negedge rst_n)begin
    if (~rst_n) begin
        wei_addr_addr <= 0;                     
    end else if (state == RD_DATA && cfg_info == 3) begin
        if(I_switch_rdwr)
            if (!O_spi_cs_n) begin
                wei_addr_addr <= (wei_addr_addr == 54 * 2 - 1) ? 0 : wei_addr_addr + 1;
            end
        else 
            if ( rd_size <= 32 && !flag_pre_rd[3]) // need to pre write wei_addr
                wei_addr_addr <= (wei_addr_addr == 54 * 2 - 1) ? 0 : wei_addr_addr + 1;
    end
end

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
    ) inst_Delay_state_d (
        .CLK     (clk),
        .RESET_N (rst_n),
        .DIN     (next_state),
        .DOUT    (state)
    );

//==============================================================================
// FPGA ILA :
//==============================================================================

`ifdef FPGA
// reg [10 : 0] cnt_block;
// always @ ( posedge clk or negedge rst_n ) begin
//     if ( !rst_n ) begin
//         cnt_block <= 0;
//     end else if ( state == IDLE && next_state == CONFIG ) begin
//         cnt_block <= cnt_block + 1;
//     end
// end


wire clk_ibufg;
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
// Status and control signals
.locked(O_FPGA_clk_locked), // output locked
// Clock in ports
.clk_in1(clk_ibufg));

//assign clk_debug = clk_ibufg;

// ILA_16bit ILA_Setup ( // Trigger: O_SW_clk edge
//     .clk(clk_debug), // input wire clk
//     .probe0({O_clk_in, O_FPGA_clk_locked, I_DLL_lock, O_SW1, O_SW0, O_reset_n, O_SW_clk, O_bypass_fifo, O_bypass}) // input wire [159:0] probe0
// );  

ILA_200bit ILA_data (
    .clk(clk_ibufg), // input wire clk

    .probe0(IO_spi_data), // input wire [127:0]  probe0  
    .probe1(cfg_info), // input wire [3:0]  probe1 
    .probe2(I_config_req), // input wire [7:0]  probe2 
    .probe3({I_config_req,  I_switch_rdwr, O_OE_req, O_spi_cs_n, O_spi_sck}), // input wire [5:0]  probe3 
    .probe4({O_clk_in, O_spi_sck, I_clk_out, I_sck_out, I_LAST_CLOCK_OUT, I_LAST_SCK}), // input wire [5:0]  probe4 
    .probe5(O_OE_req), // input wire [0:0]  probe5 
    .probe6(flag_pre_rd[9:0]), // input wire [9:0]  probe6 
    .probe7({wei_addr_addr[0 +: 7],rd_size[0 +: 10], addr_pre_rd[0 +: 3], state }), // input wire [30:0]  probe7
    .probe8({O_clk_in, O_FPGA_clk_locked, I_DLL_lock, O_SW1, O_SW0, O_reset_n, O_SW_clk, O_bypass_fifo, O_bypass})
);
`endif

endmodule
