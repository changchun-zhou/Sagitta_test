module SUM (
    input   wire                    clk     ,
    input   wire                    rst_n      
);
//==============================================================================
// Constant Definition :
//==============================================================================




//==============================================================================
// Variable Definition :
//==============================================================================
wire [128     -1 : 0] cnt_clk_PEB;
wire [128     -1 : 0] cnt_clk_MAC;
wire [128     -1 : 0] cnt_clk_all;


wire inc_cnt_clk_PEB;
wire inc_cnt_clk_MAC;


//==============================================================================
// Logic Design :
//==============================================================================
reg flag_PEB_work;
always @ ( posedge clk or negedge rst_n ) begin
    if ( !rst_n ) begin
        flag_PEB_work <= 0;
    end else if (tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.next_block )begin
        flag_PEB_work <= 1;
    end else if (tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.PEBCCU_Fnh) begin
        flag_PEB_work <= 0;
    end
end

assign inc_cnt_clk_PEB =    flag_PEB_work
                            & !( tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.FLGWEIGB_Rdy&!tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.GBFLGWEI_Val) 
                            & !( tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.FLGACTGB_rdy&!tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.GBFLGACT_val) 
                            & !( tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.ACTGB_Rdy&!tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.GBACT_Val) 
                            & !( tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.inst_SRAM_ACT.fifo_empty[0] | tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.inst_SRAM_FLGACT.fifo_empty[0]) 
                            & !( tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.PSUMGB_rdy0&!tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.GBPSUM_val0 
                               | tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.PSUMGB_rdy1&!tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.GBPSUM_val1 
                               | tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.PSUMGB_rdy2&!tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.GBPSUM_val2);

assign inc_cnt_clk_MAC = tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.ARBMAC_Rst 
                        | tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MAC_Sta 
                        | tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.pipe 
                        | (tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.state == 3 
                            && tb_FPGA.ASIC_U.TS3D.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MUXMAC_Rdy); // valid Multip add computation time

//==============================================================================
// Sub-Module :
//==============================================================================

counter #(
        .COUNT_WIDTH(128)
    ) inst_counter_clk_PEB (
        .CLK       (clk),
        .RESET_N   (rst_n),
        .CLEAR     (1'b0),
        .DEFAULT   (0),
        .INC       (inc_cnt_clk_PEB),
        .DEC       (0),
        .MIN_COUNT (0),
        .MAX_COUNT (32'hffff_ffff),
        .OVERFLOW  (),
        .UNDERFLOW (),
        .COUNT     (cnt_clk_PEB)
    );

counter #(
        .COUNT_WIDTH(128)
    ) inst_counter_clk_MAC (
        .CLK       (clk),
        .RESET_N   (rst_n),
        .CLEAR     (1'b0),
        .DEFAULT   (0),
        .INC       (inc_cnt_clk_MAC),
        .DEC       (0),
        .MIN_COUNT (0),
        .MAX_COUNT (32'hffff_ffff),
        .OVERFLOW  (),
        .UNDERFLOW (),
        .COUNT     (cnt_clk_MAC)
    );

counter #(
        .COUNT_WIDTH(128)
    ) inst_counter_clk_all (
        .CLK       (clk),
        .RESET_N   (rst_n),
        .CLEAR     (1'b0),
        .DEFAULT   (0),
        .INC       (1'b1),
        .DEC       (0),
        .MIN_COUNT (0),
        .MAX_COUNT (32'hffff_ffff),
        .OVERFLOW  (),
        .UNDERFLOW (),
        .COUNT     (cnt_clk_all)
    );
endmodule