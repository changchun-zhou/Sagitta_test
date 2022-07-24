//======================================================
// Copyright (C) 2020 By
// All Rights Reserved
//======================================================
// Module :
// Author :
// Contact :
// Date :
//=======================================================
// Description :
//========================================================
`ifndef top
  `define top

`include "/workspace/home/zhoucc/Share/TS3D/liumin/tb/DEFINE.sv"
//`include "/workspace/home/zhoucc/Share/TS3D/liumin/TB_env/TEST.sv"
// `include "/workspace/home/zhoucc/Share/TS3D/liumin/TB_env/GB_DUMP_liu.sv"
// `include "/workspace/home/zhoucc/Share/TS3D/liumin/TB_env/GB_DUMP.sv"
// `include "/workspace/home/zhoucc/Share/TS3D/liumin/TB_env/PO_DUMP.sv"
`include "/workspace/home/zhoucc/Share/TS3D/zhoucc/source/include/dw_params_presim.vh"
`timescale 1ns/1ps
module top;
    parameter WEI_DATA_BLOCK = 4'd4;
    parameter WEI_FLAG_BLOCK  = 4'd2;
    parameter ACT_DATA_BLOCK = 4'd4;
    parameter ACT_FLAG_BLOCK = 4'd2;
    parameter FEATURE_GROUP  = 4'd2;

   parameter WEI_ADDR_ADDR_BW = 6 + clogb2(FEATURE_GROUP) - 1;
   parameter WEI_DATA_ADDR_BW = 9 + clogb2(WEI_DATA_BLOCK) - 1;
   parameter WEI_FLAG_ADDR_BW = 9 + clogb2(WEI_FLAG_BLOCK) - 1;
   parameter ACT_DATA_ADDR_BW = 9 + clogb2(ACT_DATA_BLOCK) - 1;
   parameter ACT_FLAG_ADDR_BW = 9 + clogb2(ACT_FLAG_BLOCK) - 1;

  bit clk;
  bit rst_n;
  bit DumpStart;

  bit                                IFGB_cfg_rdy ;
  bit                                GBIF_cfg_val ;
  bit [ 4                    -1 : 0] GBIF_cfg_info;

  bit                                IFGB_wr_rdy  ;
  bit                                GBIF_wr_val  ;
  bit [`TB_PORT_WIDTH        -1 : 0] GBIF_wr_data ;

  bit                                IFGB_rd_val  ;
  bit                                GBIF_rd_rdy  ;
  bit [`TB_PORT_WIDTH        -1 : 0] IFGB_rd_data ;
  bit rst_n_dll;
  // System Clock and Reset
  initial begin
    clk <= 'd1;
    #100;
    // @(negedge top.ASIC_U.TS3D.inst_CCU.Delay_inc_layer_d.DIN);
    // #200;
    // @(posedge top.ASIC_U.TS3D.inst_CCU.Delay_inc_layer_d.DIN);
    // $finish();
  end
  always #5 clk = ~clk;

  initial begin
    // rst_n <= 1'd0;
    // repeat(80+$urandom%20) @ (posedge clk);
    rst_n <= 1'd1;
    rst_n_dll <= 1'b0;
    repeat(20+$urandom%20) @ (posedge clk);
    rst_n <= 1'd0;
    repeat(200+$urandom%20) @ (posedge clk);
    rst_n <= 1'd1;
    repeat(30+$urandom%20) @ (posedge clk);
    rst_n_dll <= 1'b1;
  end


`ifdef QIU
   PO_DUMP     PO_DUMP_U(clk, rst_n, DumpStart);
   GB_DUMP     GB_DUMP_U(clk, rst_n, DumpStart);
`endif

`ifdef LIU
  GB_DUMP_liu GB_DUMP_liu(clk, rst_n, DumpStart);
`endif

`ifdef ZHOU
   PEB_DUMP PEB_DUMP_U (clk, rst_n, DumpStart);
   POOL_DUMP POOL_DUMP_U(clk, rst_n, DumpStart);
`endif

`ifndef ASIC
// *****************************************************************************
// inst_TS3D
// *****************************************************************************
   TS3D TS3D_U (
     .*
   );
`else
// *****************************************************************************
// inst_ASIC
// *****************************************************************************
wire                        I_OE_req;
wire [ `TB_PORT_WIDTH  -1 : 0] IO_spi_data;
wire [ `TB_PORT_WIDTH  -1 : 0] I_spi_data;
wire [ `TB_PORT_WIDTH  -1 : 0] O_spi_data;

reg [ `TB_PORT_WIDTH  -1 : 0]   O_spi_data_neg  ;
reg                             IFGB_cfg_rdy_neg;
reg                             IFGB_wr_rdy_neg ;
reg                             IFGB_rd_val_neg ;
wire clk_chip;

    ASIC ASIC_U
        (
            .I_reset_n     (rst_n_dll),
            .I_reset_dll   (rst_n),
            .I_clk_in      (clk_chip),
            .I_bypass      (1'b1),
            .I_SW0         (1'b0),
            .I_SW1         (1'b0),
            .O_DLL_lock    (),
            .O_clk_out     (),
            .O_sck_out     (),
            .IO_spi_data   (IO_spi_data),
            .O_config_req  (GBIF_cfg_val),
            .O_near_full   (GBIF_wr_val),
            .O_switch_rdwr (GBIF_rd_rdy),
            .I_OE_req      (I_OE_req),
            .I_spi_cs_n    (IFGB_cfg_rdy_neg),
            .I_spi_sck     (1'b0),
            .I_in_1        (IFGB_wr_rdy_neg),
            .I_in_2        (IFGB_rd_val_neg),
            .I_bypass_fifo (1'b1),
            .O_Monitor_Out   (),
            .I_Monitor_En    (1'b1),
            .O_Monitor_OutVld()
        );
`ifdef SDF
    initial $sdf_annotate("/workspace/home/zhoucc/Share/TS3D/TS3D_svn_co/zhoucc_svn_co/synth/ASIC/200814_Margin_1.8_group_Track_3vt_Note_NOQRC_ADDDEBUG/gate/ASIC.sdf",
       ASIC_U,, "sdf.log", "MAXIMUM","1.0:1.0:1.0","FROM_MAXIMUM");
    assign clk_chip = clk;
`else 
    assign #5 clk_chip = clk; // simulte gds clock delay
`endif

supply0 VSS,VSSIO,VSSA;
supply1 VDD,VDDIO,VDDA;
IPOC    IPOC_cell           (.PORE(PORE     ), .VDD  (VDD ), .VSS(VSS ), .VDDIO(VDDIO));
generate
  genvar i;
  for ( i=0; i<`TB_PORT_WIDTH; i=i+1 ) begin: PAD
    IUMBFS IO_spi_data_PAD (.DO (O_spi_data_neg[i]), .IDDQ (1'b0), .IE (1'b1), .OE (~I_OE_req), .PD (1'b0), .PIN1 (1'b1), .PIN2 (1'b1), .PU (1'b0), .SMT (1'b0), .DI (I_spi_data[i]), .PAD (IO_spi_data[i]), .PORE (PORE));
  end
endgenerate

// assign GBIF_cfg_info = I_spi_data;
assign O_spi_data = IFGB_rd_data;
assign GBIF_wr_data = I_spi_data;

reg [ 4                        -1 : 0] GBIF_cfg_info_d;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        GBIF_cfg_info_d <= 0;
    end else if ( GBIF_cfg_val && IFGB_cfg_rdy ) begin
        GBIF_cfg_info_d <= I_spi_data;
    end
end
assign GBIF_cfg_info = GBIF_cfg_val && IFGB_cfg_rdy ? I_spi_data : GBIF_cfg_info_d;
assign I_OE_req = GBIF_cfg_val && IFGB_cfg_rdy ? 1'b1 : ~GBIF_cfg_info_d[0];

always @ ( negedge clk ) begin
        O_spi_data_neg  <= O_spi_data  ;
        IFGB_cfg_rdy_neg<= IFGB_cfg_rdy;
        IFGB_wr_rdy_neg <= IFGB_wr_rdy ;
        IFGB_rd_val_neg <= IFGB_rd_val ;
end

// *****************************************************************************
//
// *****************************************************************************
`endif
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
            IDLE: if (GBIF_cfg_val & IFGB_cfg_rdy) begin
                next_State = TRANS;
            end else begin
                next_State = IDLE;
            end

            TRANS: if ((trans_cnt == total_trans_num) && ((IFGB_rd_val & GBIF_rd_rdy) == 1 || (GBIF_wr_val & IFGB_wr_rdy) == 1)) begin
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
        if (GBIF_cfg_val & IFGB_cfg_rdy) begin
            if (GBIF_cfg_info[3 : 1] == 0) begin
                total_trans_num    <= 63;
            end else if (GBIF_cfg_info[3 : 1] == 1) begin
                total_trans_num    <= 63;
            end else if (GBIF_cfg_info[3 : 1] == 2) begin
                total_trans_num    <= 63;
            end else if (GBIF_cfg_info[3 : 1] == 3) begin
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
        if (GBIF_cfg_info[3 : 1] == 0) begin
            if (IFGB_rd_val & GBIF_rd_rdy) begin
                trans_cnt <= (trans_cnt == total_trans_num) ? 0 : trans_cnt + 1;
            end
        end else if (GBIF_cfg_info[3 : 1] == 1) begin
            if (GBIF_wr_val & IFGB_wr_rdy) begin
                trans_cnt <= (trans_cnt == total_trans_num) ? 0 : trans_cnt + 1;
            end
        end else if (GBIF_cfg_info[3 : 1] == 2) begin
            if (GBIF_wr_val & IFGB_wr_rdy) begin
                trans_cnt <= (trans_cnt == total_trans_num) ? 0 : trans_cnt + 1;
            end
        end else if (GBIF_cfg_info[3 : 1] == 3) begin
            if (IFGB_rd_val & GBIF_rd_rdy) begin
                trans_cnt <= (trans_cnt == total_trans_num) ? 0 : trans_cnt + 1;
            end
        end else begin
            if (IFGB_rd_val & GBIF_rd_rdy) begin
                trans_cnt <= (trans_cnt == total_trans_num) ? 0 : trans_cnt + 1;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        IFGB_cfg_rdy <= 0;
    end else if (State == IDLE) begin
        if (IFGB_cfg_rdy) begin
            if (GBIF_cfg_val) begin
                IFGB_cfg_rdy <= 0;
            end
        end else begin
            if (IFGB_cfg_rdy) begin
                IFGB_cfg_rdy <= 1;
            end else begin
                IFGB_cfg_rdy <= $urandom%2;
            end
        end
    end else begin
        IFGB_cfg_rdy <= 0;
    end
end

//============== generate wr_rdy ==============
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        IFGB_wr_rdy <= 0;
    end else if (next_State == TRANS && (GBIF_cfg_info[3 : 1] == 1 || GBIF_cfg_info[3 : 1] == 2)) begin
        if (IFGB_wr_rdy) begin
            if (GBIF_wr_val) begin
                IFGB_wr_rdy <= $urandom%2;
            end
        end else begin
            IFGB_wr_rdy <= $urandom%2;
        end
    end else begin
        IFGB_wr_rdy <= 0;
    end
end

//============== generate rd_rdy ==============
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        IFGB_rd_val <= 0;
    end else if (next_State == TRANS && (GBIF_cfg_info[3 : 1] == 0 || GBIF_cfg_info[3 : 1] == 3 || GBIF_cfg_info[3 : 1] == 4 || GBIF_cfg_info[3 : 1] == 5 || GBIF_cfg_info[3 : 1] == 6 || GBIF_cfg_info[3 : 1] == 7)) begin
        if (IFGB_rd_val) begin
            if (GBIF_rd_rdy) begin
                IFGB_rd_val <= $urandom%2;
            end
        end else begin
            IFGB_rd_val <= $urandom%2;
        end
    end else begin
        IFGB_rd_val <= 0;
    end
end


//============== generate rd_data ==============
reg [`TB_PORT_WIDTH - 1 : 0]wei_data_mem[0 : WEI_DATA_BLOCK * 512 - 1];
reg [`TB_PORT_WIDTH - 1 : 0]wei_flag_mem[0 : WEI_FLAG_BLOCK * 512 - 1];
reg [`TB_PORT_WIDTH - 1 : 0]wei_addr_mem[0 :  FEATURE_GROUP * 54 - 1];


reg [`TB_PORT_WIDTH - 1 : 0]act_data_mem[0 : ACT_DATA_BLOCK * 512 - 1];
reg [`TB_PORT_WIDTH - 1 : 0]act_flag_mem[0 : ACT_FLAG_BLOCK * 512 - 1];

initial begin
    $readmemb("/workspace/home/zhoucc/Share/TS3D/liumin/TB_data/wei_data/datawei_L00.txt", wei_data_mem);
    $readmemb("/workspace/home/zhoucc/Share/TS3D/liumin/TB_data/wei_flag/flagwei_L00.txt", wei_flag_mem);
    $readmemb("/workspace/home/zhoucc/Share/TS3D/liumin/TB_data/wei_addr/addrwei_L00.txt", wei_addr_mem);
    $readmemb("/workspace/home/zhoucc/Share/TS3D/liumin/TB_data/act_data/dataact_L00.txt", act_data_mem);
    $readmemb("/workspace/home/zhoucc/Share/TS3D/liumin/TB_data/act_flag/flagact_L00.txt", act_flag_mem);
end

reg [WEI_DATA_ADDR_BW - 1 : 0]wei_data_addr;
reg [WEI_FLAG_ADDR_BW - 1 : 0]wei_flag_addr;
reg [WEI_ADDR_ADDR_BW - 1 : 0]wei_addr_addr;

reg [ACT_DATA_ADDR_BW - 1 : 0]act_data_addr;
reg [ACT_FLAG_ADDR_BW - 1 : 0]act_flag_addr;





always @ (posedge clk or negedge rst_n)begin
    if (~rst_n) begin
        wei_addr_addr <= 0;
    end else if (top.ASIC_U.TS3D.inst_CCU.Delay_inc_layer_d.DIN) begin
        wei_addr_addr <= 0;						   
    end else if (State == TRANS && GBIF_cfg_info[3 : 1] == 3) begin
        if (IFGB_rd_val & GBIF_rd_rdy) begin
            wei_addr_addr <= (wei_addr_addr == 54 * 2 - 1) ? 0 : wei_addr_addr + 1;
        end
    end
end

always @ (posedge clk or negedge rst_n)begin
    if (~rst_n) begin
        wei_data_addr <= 0;
    end else if (top.ASIC_U.TS3D.inst_CCU.Delay_inc_layer_d.DIN) begin
        wei_data_addr <= 0;						   
    end else if (State == TRANS && GBIF_cfg_info[3 : 1] == 4) begin
        if (IFGB_rd_val & GBIF_rd_rdy) begin
            wei_data_addr <= wei_data_addr + 1;
        end
    end
end

always @ (posedge clk or negedge rst_n)begin
    if (~rst_n) begin
        wei_flag_addr <= 0;
    end else if (top.ASIC_U.TS3D.inst_CCU.Delay_inc_layer_d.DIN) begin
        wei_flag_addr <= 0;						   
    end else if (State == TRANS && GBIF_cfg_info[3 : 1] == 5) begin
        if (IFGB_rd_val & GBIF_rd_rdy) begin
            wei_flag_addr <= wei_flag_addr + 1;
        end
    end
end

always @ (posedge clk or negedge rst_n)begin
    if (~rst_n) begin
        act_data_addr <= 0;
    end else if (top.ASIC_U.TS3D.inst_CCU.Delay_inc_layer_d.DIN) begin
        act_data_addr <= 0;						   
    end else if (State == TRANS && GBIF_cfg_info[3 : 1] == 6) begin
        if (IFGB_rd_val & GBIF_rd_rdy) begin
            act_data_addr <= act_data_addr + 1;
        end
    end
end

always @ (posedge clk or negedge rst_n)begin
    if (~rst_n) begin
        act_flag_addr <= 0;
    end else if (top.ASIC_U.TS3D.inst_CCU.Delay_inc_layer_d.DIN) begin
        act_flag_addr <= 0;													 						   
    end else if (State == TRANS && GBIF_cfg_info[3 : 1] == 7) begin
        if (IFGB_rd_val & GBIF_rd_rdy) begin
            act_flag_addr <= act_flag_addr + 1;
        end
    end
end


//========================== cfg ==============================
always @ ( * )begin
    if (State == TRANS) begin
        if (GBIF_cfg_info[3 : 1] == 0) begin
            IFGB_rd_data = { 1'd0,
                            6'd10, 8'd1, 11'd1, 6'd3, 10'd1,
                            4'd1, 4'd2,4'd1, 4'd2,
                            4'd1,4'd1, 4'd2,
                            12'd4, 8'd2,
                            { 20'd1, 8'd0, 1'd1, 1'd0, 3'd2 }};

        end else if (GBIF_cfg_info[3 : 1] == 3) begin
            IFGB_rd_data = wei_addr_mem[wei_addr_addr];
        end else if (GBIF_cfg_info[3 : 1] == 4) begin
            IFGB_rd_data = wei_data_mem[wei_data_addr];
        end else if (GBIF_cfg_info[3 : 1] == 5) begin
            IFGB_rd_data = wei_flag_mem[wei_flag_addr];
        end else if (GBIF_cfg_info[3 : 1] == 6) begin
            IFGB_rd_data = act_data_mem[act_data_addr];
        end else if (GBIF_cfg_info[3 : 1] == 7) begin
            IFGB_rd_data = act_flag_mem[act_flag_addr];
        end else begin
            IFGB_rd_data = 0;
        end
    end else begin
        IFGB_rd_data = 0;
    end
end


//========================== test ==============================
`ifdef TEST
initial begin
    GBIF_cfg_val = 1;
    GBIF_wr_val  = 1;
    GBIF_rd_rdy  = 1;
end

reg [3 : 0]info_mem[0 : 8];
initial begin
    info_mem[0] = {3'd0, 1'b1};
    info_mem[1] = {3'd1, 1'b0};
    info_mem[2] = {3'd2, 1'b0};
    info_mem[3] = {3'd3, 1'b1};
    info_mem[4] = {3'd4, 1'b1};
    info_mem[5] = {3'd5, 1'b1};
    info_mem[6] = {3'd6, 1'b1};
    info_mem[7] = {3'd7, 1'b1};
    info_mem[8] = {3'd0, 1'b1};
end
reg [3 : 0]addr_info, addr_info_d;
reg [3 : 0]GBIF_cfg_info_d;

always @ (posedge clk or negedge rst_n)begin
    if (~rst_n) begin
        GBIF_cfg_info_d <= 0;
    end else begin
        GBIF_cfg_info_d <= GBIF_cfg_info;
    end
end

always @ (posedge clk or negedge rst_n)begin
    if (~rst_n) begin
        addr_info       <= 0;
    end else if (GBIF_cfg_val && IFGB_cfg_rdy) begin
        addr_info       <= (addr_info == 8) ? 0 : addr_info + 1;
    end
end

always @ ( * )begin
    if (GBIF_cfg_val && IFGB_cfg_rdy) begin
        GBIF_cfg_info = info_mem[addr_info];
    end else begin
        GBIF_cfg_info = GBIF_cfg_info_d;
    end
end

`endif



initial  begin
    // $dumpfile("top.vcd");
    // $dumpvars;
    // $shm_open("wave_synth_shm" ,,,,1024);//1G
    // $shm_probe(top.ASIC_U.TS3D.inst_CCU,"AS");

end

endmodule

`endif
