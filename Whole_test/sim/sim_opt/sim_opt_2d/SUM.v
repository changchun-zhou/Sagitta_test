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
wire summary_inc_cnt_clk_MAC_work_compute_sta;
wire summary_inc_cnt_clk_MAC_work_wait;

wire [128     -1 : 0] summary_cnt_clk_PEB;
wire [128     -1 : 0] summary_cnt_clk_MAC;
wire [128     -1 : 0] summary_cnt_clk_all;





//==============================================================================
// Logic Design :
//==============================================================================

generate
    genvar i, j;
    for(i=0; i<16; i=i+1) begin
        for(j=0; j<16; j=j+1) begin
            assign inc_cnt_clk_MAC_work_compute_sta 
                = top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.MAC_Sta 
                | top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.en_mac;
            counter #(
                .COUNT_WIDTH(128)
            ) inst_counter_clk_compute_sta (
                .CLK       (clk),
                .RESET_N   (rst_n),
                .CLEAR     (1'b0),
                .DEFAULT   (0),
                .INC       (inc_cnt_clk_MAC_work_compute_sta),
                .DEC       (0),
                .MIN_COUNT (0),
                .MAX_COUNT (32'hffff_ffff),
                .OVERFLOW  (),
                .UNDERFLOW (),
                .COUNT     (cnt_clk_MAC_work_compute_sta)
            );

            assign inc_cnt_clk_MAC_work_wait 
                = (top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.state == 1) & !top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.MAC_FlgWei_Val  
                | (top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.state == 1) & !top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.MAC_FlgAct_Val  
                | (top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.state == 0) & (top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.MAC_AddrWei_Rdy & top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.!MAC_Wei_Val)
                | (top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.state == 0) & (top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.MAC_AddrAct_Rdy & top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.!MAC_Act_Val)
                | top.TS3D_U.inst_PEL.PEB[i].inst_PEB.MAC[j].inst_MAC.state == 3; // wait psum out

            counter #(
                .COUNT_WIDTH(128)
            ) inst_counter_clk_wait (
                .CLK       (clk),
                .RESET_N   (rst_n),
                .CLEAR     (1'b0),
                .DEFAULT   (0),
                .INC       (inc_cnt_clk_MAC_work_wait),
                .DEC       (0),
                .MIN_COUNT (0),
                .MAX_COUNT (32'hffff_ffff),
                .OVERFLOW  (),
                .UNDERFLOW (),
                .COUNT     (cnt_clk_MAC_work_wait)
            );

        end

    end
endgenerate


assign summary_cnt_clk_MAC_work_compute_sta =       cnt_clk_MAC_work_compute_sta[0][0 ]
                                                +   cnt_clk_MAC_work_compute_sta[0][13]
                                                +   cnt_clk_MAC_work_compute_sta[0][26]
                                                +   cnt_clk_MAC_work_compute_sta[8][0 ]
                                                +   cnt_clk_MAC_work_compute_sta[8][13]
                                                +   cnt_clk_MAC_work_compute_sta[8][26]
                                                +   cnt_clk_MAC_work_compute_sta[15][0 ]
                                                +   cnt_clk_MAC_work_compute_sta[15][13]
                                                +   cnt_clk_MAC_work_compute_sta[15][26];


assign summary_cnt_clk_MAC_work_wait =              cnt_clk_MAC_work_wait[0][0 ]
                                                +   cnt_clk_MAC_work_wait[0][13]
                                                +   cnt_clk_MAC_work_wait[0][26]
                                                +   cnt_clk_MAC_work_wait[8][0 ]
                                                +   cnt_clk_MAC_work_wait[8][13]
                                                +   cnt_clk_MAC_work_wait[8][26]
                                                +   cnt_clk_MAC_work_wait[15][0 ]
                                                +   cnt_clk_MAC_work_wait[15][13]
                                                +   cnt_clk_MAC_work_wait[15][26];

assign summary_MAC = summary_cnt_clk_MAC_work_compute_sta + summary_cnt_clk_MAC_work_wait;





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