`define FPGA
module  FPGA #(
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
    output                          O_reset_n       , // reset of whole chip

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
    input                           I_switch_rdwr   , // rd_rdy  : switch_rdwr
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

// wire [ 8               -1 : 0] I_Monitor_Out;


//==============================================================================
// Variable Definition :
//==============================================================================
wire                                    clk;
wire                                    rst_n;
wire                                    clk_debug;

reg [ 4                         -1 : 0] cfg_info_d;
wire[ 4                         -1 : 0] cfg_info;
reg [ 128                       -1 : 0] O_spi_data_neg;
reg [ 128                       -1 : 0] rd_data;

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
assign rst_n            =  O_reset_n;
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

assign O_reset_n        =  ~trigger_O_reset_n;

// PLL Mode Choose
assign O_SW0            = I_SW4;
assign O_SW1            = I_SW5;

// 
assign O_clk_in         = clk;

// ASIC config
assign cfg_val          =  I_config_req;
assign O_spi_cs_n       = O_bypass_fifo ? cfg_rdy_neg : 1'b0;

// ASIC read
assign rd_rdy           = I_switch_rdwr;
assign O_in_2           = rd_val_neg;

// ASIC write
assign O_in_1           = wr_rdy_neg;
assign wr_val           = I_near_full;

// IO_spi_data
assign IO_spi_data      = ~O_OE_req ? O_spi_data_neg : 'bz;
// assign GBIF_wr_data  = IO_spi_data;
// Avoid synth out
assign Hold_I_spi_data  = |IO_spi_data && |cnt_block; 
assign O_spi_sck        = clk;
assign O_Monitor_En     = I_Monitor_OutVld & |I_Monitor_Out & I_DLL_lock & I_clk_out & I_sck_out;

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cfg_info_d <= 0;
    end else if ( cfg_val && cfg_rdy ) begin
        cfg_info_d <= IO_spi_data;
    end
end
assign cfg_info = cfg_val && cfg_rdy ? IO_spi_data : cfg_info_d;
assign O_OE_req = cfg_val && cfg_rdy ? 1'b1 : ~cfg_info_d[0];

always @ ( negedge clk ) begin
        O_spi_data_neg  <= rd_data  ;
        cfg_rdy_neg<= cfg_rdy;
        wr_rdy_neg <= wr_rdy ;
        rd_val_neg <= rd_val ;
end

// *****************************************************************************
//
// *****************************************************************************

//============================= generate cfg_rdy =================================
reg [1 : 0]State, next_State;
parameter IDLE = 2'b00, TRANS = 2'b01, DONE = 2'b11;

reg [9 : 0]total_trans_num;
reg [9 : 0]trans_cnt;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        State <= IDLE;
    end else begin
        State <= next_State;
    end
end

always @( * ) begin
    if (~rst_n) begin
        next_State = IDLE;
    end else begin
        case(State)
            IDLE: if (cfg_val & cfg_rdy) begin
                next_State = TRANS;
            end else begin
                next_State = IDLE;
            end

            TRANS: if ((trans_cnt == total_trans_num) && ((rd_val & rd_rdy) == 1 || (wr_val & wr_rdy) == 1)) begin
                next_State = DONE;
            end else begin
                next_State = TRANS;
            end

            DONE: next_State = IDLE;

            default: next_State = IDLE;
        endcase
    end
end



always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        total_trans_num <= 0;
    end else if (State == IDLE) begin
        if (cfg_val & cfg_rdy) begin
            if (cfg_info[3 : 1] == 0) begin
                total_trans_num    <= 63;
            end else if (cfg_info[3 : 1] == 1) begin
                total_trans_num    <= 63;
            end else if (cfg_info[3 : 1] == 2) begin
                total_trans_num    <= 63;
            end else if (cfg_info[3 : 1] == 3) begin
                total_trans_num    <= 53;
            end else begin
                total_trans_num    <= 511;
            end
        end
    end
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        trans_cnt <= 0;
    end else if (State == IDLE || State == DONE) begin
        trans_cnt <= 0;
    end else begin
        if (cfg_info[3 : 1] == 0) begin
            if (rd_val & rd_rdy) begin
                trans_cnt <= (trans_cnt == total_trans_num) ? 0 : trans_cnt + 1;
            end
        end else if (cfg_info[3 : 1] == 1) begin
            if (wr_val & wr_rdy) begin
                trans_cnt <= (trans_cnt == total_trans_num) ? 0 : trans_cnt + 1;
            end
        end else if (cfg_info[3 : 1] == 2) begin
            if (wr_val & wr_rdy) begin
                trans_cnt <= (trans_cnt == total_trans_num) ? 0 : trans_cnt + 1;
            end
        end else if (cfg_info[3 : 1] == 3) begin
            if (rd_val & rd_rdy) begin
                trans_cnt <= (trans_cnt == total_trans_num) ? 0 : trans_cnt + 1;
            end
        end else begin
            if (rd_val & rd_rdy) begin
                trans_cnt <= (trans_cnt == total_trans_num) ? 0 : trans_cnt + 1;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        cfg_rdy <= 0;
    end else if (State == IDLE) begin
        if (cfg_rdy) begin
            if (cfg_val) begin
                cfg_rdy <= 0;
            end
        end else begin
            if (cfg_rdy) begin
                cfg_rdy <= 1;
            end else begin
                cfg_rdy <= 1;
            end
        end
    end else begin
        cfg_rdy <= 0;
    end
end

//============== generate wr_rdy ==============
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        wr_rdy <= 0;
    end else if (next_State == TRANS && (cfg_info[3 : 1] == 1 || cfg_info[3 : 1] == 2)) begin
        if (wr_rdy) begin
            if (wr_val) begin
                wr_rdy <= 1;
            end
        end else begin
            wr_rdy <= 1;
        end
    end else begin
        wr_rdy <= 0;
    end
end

//============== generate rd_rdy ==============
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        rd_val <= 0;
    end else if (next_State == TRANS && (cfg_info[3 : 1] == 0 || cfg_info[3 : 1] == 3 || cfg_info[3 : 1] == 4 || cfg_info[3 : 1] == 5 || cfg_info[3 : 1] == 6 || cfg_info[3 : 1] == 7)) begin
        if (rd_val) begin
            if (rd_rdy) begin
                rd_val <= 1;
            end
        end else begin
            rd_val <= 1;
        end
    end else begin
        rd_val <= 0;
    end
end


//============== generate rd_data ==============

reg [8 - 1 : 0]wei_addr_addr;
wire [16        -1 : 0] wei_base_addr0;
wire [16        -1 : 0] wei_base_addr1;
wire [16        -1 : 0] wei_base_addr2;
wire [16        -1 : 0] wei_base_addr3;
wire [16        -1 : 0] wei_base_addr4;
wire [16        -1 : 0] wei_base_addr5;
wire [16        -1 : 0] wei_base_addr6;
wire [16        -1 : 0] wei_base_addr7;

assign wei_base_addr0 = wei_addr_addr*16 + 0;
assign wei_base_addr1 = wei_addr_addr*16 + 2;
assign wei_base_addr2 = wei_addr_addr*16 + 4;
assign wei_base_addr3 = wei_addr_addr*16 + 6;
assign wei_base_addr4 = wei_addr_addr*16 + 8;
assign wei_base_addr5 = wei_addr_addr*16 + 10;
assign wei_base_addr6 = wei_addr_addr*16 + 12;
assign wei_base_addr7 = wei_addr_addr*16 + 14;

always @ (posedge clk or negedge rst_n)begin
    if (~rst_n) begin
        wei_addr_addr <= 0;
    // end else if (top.ASIC_U.TS3D.inst_CCU.Delay_inc_layer_d.DIN) begin
        // wei_addr_addr <= 0;                        
    end else if (State == TRANS && cfg_info[3 : 1] == 3) begin
        if (rd_val & rd_rdy) begin
            wei_addr_addr <= (wei_addr_addr == 54 * 2 - 1) ? 0 : wei_addr_addr + 1;
        end
    end
end


//========================== cfg ==============================
always @ ( * )begin
    if (State == TRANS) begin
        if (cfg_info[3 : 1] == 0) begin
            rd_data = { 1'd0,
                            6'd10, 8'd1, 11'd1, 6'd3, 10'd1,
                            4'd1, 4'd2,4'd1, 4'd4,
                            4'd1,4'd1, 4'd4,
                            12'd4, 8'd2,
                            { 20'd1, 8'd0, 1'd1, 1'd0, 3'd2 }};

        end else if (cfg_info[3 : 1] == 3) begin
            // rd_data = {{14+ wei_base_addr},{12 + 16*wei_addr_addr}[0+:16], {10 + 16*wei_addr_addr}[0+:16], {8 + 16*wei_addr_addr}[0+:16],
            //            {6 + 16*wei_addr_addr}[0+:16],{4  + 16*wei_addr_addr}[0+:16], {2  + 16*wei_addr_addr}[0+:16], {0 + 16*wei_addr_addr}[0+:16] };
            rd_data = { wei_base_addr7, wei_base_addr6, wei_base_addr5, wei_base_addr4,
                        wei_base_addr3, wei_base_addr2, wei_base_addr1, wei_base_addr0 };
        end else if (cfg_info[3 : 1] == 4) begin
            rd_data = {16{8'd1}};
        end else if (cfg_info[3 : 1] == 5) begin
            rd_data = {64{2'b10}};
        end else if (cfg_info[3 : 1] == 6) begin
            rd_data = {16{8'd1}};
        end else if (cfg_info[3 : 1] == 7) begin
            rd_data = {64{2'b10}};
        end else begin
            rd_data = 0;
        end
    end else begin
        rd_data = 0;
    end
end


//==============================================================================
// Sub-Module :
//==============================================================================

always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        cnt_block <= 0;
    end else if ( State == IDLE && next_State == TRANS ) begin
        cnt_block <= cnt_block + 1;
    end
end

`ifdef FPGA
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
.clk_out2(),
// Status and control signals
.locked(O_FPGA_clk_locked), // output locked
// Clock in ports
.clk_in1(clk_ibufg));

// assign clk_debug = clk_ibufg;

ILA_16bit ILA_Setup ( // Trigger: O_SW_clk edge
    .clk(clk_ibufg), // input wire clk
    .probe0({O_clk_in, O_FPGA_clk_locked, I_DLL_lock, O_SW1, O_SW0, O_reset_n, O_SW_clk, O_bypass_fifo, O_bypass}) // input wire [159:0] probe0
);  

// ILA_200bit ILA_Ctrl( // Trigger: I_config_req
//     .clk(clk_ibufg), // input wire clk

//     // {wr_rdy, wr_val, rd_rdy, rd_val, cfg_rdy, cfg_val}
//     // O_in_1,I_near_full,I_switch_rdwr, O_in_2,O_spi_cs_n, I_config_req,
//     .probe0({
//         I_Monitor_Out, I_Monitor_OutVld, O_Monitor_En, 
//         IO_spi_data, O_OE_req, 
//         wei_addr_addr, cnt_block, next_State,trans_cnt, total_trans_num, cfg_info[3:0],
//         wr_rdy, wr_val, rd_rdy, rd_val, cfg_rdy, cfg_val, 
//         O_clk_in, O_spi_sck, I_clk_out, I_sck_out, I_LAST_CLOCK_OUT, I_LAST_SCK
//         }) 
// );

ILA_200bit ILA_data (
    .clk(clk_ibufg), // input wire clk


    .probe0(IO_spi_data), // input wire [127:0]  probe0  
    .probe1(cfg_info), // input wire [3:0]  probe1 
    .probe2(cnt_block), // input wire [7:0]  probe2 
    .probe3({wr_rdy, wr_val, rd_rdy, rd_val, cfg_rdy, cfg_val}), // input wire [5:0]  probe3 
    .probe4({O_clk_in, O_spi_sck, I_clk_out, I_sck_out, I_LAST_CLOCK_OUT, I_LAST_SCK}), // input wire [5:0]  probe4 
    .probe5(O_OE_req), // input wire [0:0]  probe5 
    .probe6({I_Monitor_Out, I_Monitor_OutVld, O_Monitor_En}), // input wire [9:0]  probe6 
    .probe7({wei_addr_addr,next_State,trans_cnt, total_trans_num }) // input wire [30:0]  probe7
);
`endif
endmodule