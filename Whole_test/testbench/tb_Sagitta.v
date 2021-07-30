
`timescale 1ns/1ps
`define FREQ_SCK 200 //MHz
`define FREQ_CLK 100 

module tb_FPGA (); /* this is automatically generated */

    // clock
    logic clk;
    initial begin
        clk = '0;
        forever #(1000/`FREQ_SCK/2) clk = ~clk;
    end
    logic clk_core;
    initial begin
        clk_core = '0;
        #( 10 + $random % 9 );
        forever #(1000.0/`FREQ_CLK/2) clk_core = ~clk_core;
    end
    // synchronous reset
    logic srst;
    initial begin
        srst <= '0;
        repeat(10)begin
        @(posedge clk);
        @(negedge clk);
        end
        srst <= '1;
        repeat(10)begin
            @(posedge clk);
            @(negedge clk);
        end
        srst <= '0;
    end

    // (*NOTE*) replace reset, clock, others

    parameter  IDLE = 2'b00;
    parameter TRANS = 2'b01;
    parameter  DONE = 2'b11;

    logic               I_clk_src;
    logic               I_rst_n;
    logic               I_SW0;
    logic               I_SW1;
    logic               I_SW2;
    logic               I_SW3;
    logic               I_SW_S;
    logic               I_SW4;
    logic               I_SW5;
    logic               Hold_I_spi_data;
    logic               O_SW_clk;
    logic               O_reset_n;
    logic               O_clk_in;
    logic               O_bypass;
    logic               O_SW0;
    logic               O_SW1;
    logic               I_DLL_lock;
    logic               I_clk_out;
    logic               I_sck_out;
    wire  [ 128 -1 : 0] IO_spi_data;
    logic               I_config_req;
    logic               I_near_full;
    logic               I_switch_rdwr;
    logic               O_OE_req;
    logic               O_spi_cs_n;
    logic               O_spi_sck;
    logic               O_in_1;
    logic               O_in_2;
    logic               O_bypass_fifo;
    logic               O_Monitor_En;
    logic   [ 8 -1 : 0] I_Monitor_Out;
    logic               I_Monitor_OutVld;

    FPGA_asysFIFO inst_FPGA_asysFIFO (
            .I_clk_src_p        (clk),
            .I_rst          (srst),
            .I_SW_N            (I_SW2),
            .I_SW_C           (I_SW3),
            .I_SW_S            (I_SW_S),
            .I_SW0            (1'b0),
            .I_SW1            (1'b0),
            .I_SW2            (1'b0),
            .I_SW3            (1'b0),
            .I_SW4            (1'b1),
            .I_SW5            (1'b0),
            .I_SW6            (1'b0),
            .I_SW7            (1'b0),
            .Hold_I_spi_data  (Hold_I_spi_data),

            .O_SW_clk         (O_SW_clk),
            .O_reset_n        (O_reset_n),
            .O_clk_in         (),
            .O_bypass         (O_bypass),
            .O_SW0            (O_SW0),
            .O_SW1            (O_SW1),
            .I_DLL_lock       (I_DLL_lock),
            .I_clk_out        (I_clk_out),
            .I_sck_out        (I_sck_out),
            .IO_spi_data      (IO_spi_data),
            .I_config_req     (I_config_req),
            .I_near_full      (I_near_full),
            .I_switch_rdwr    (I_switch_rdwr),
            .O_OE_req         (O_OE_req),
            .O_spi_cs_n       (O_spi_cs_n),
            .O_spi_sck        (O_spi_sck),
            .O_in_1           (O_in_1),
            .O_in_2           (O_in_2),
            .O_bypass_fifo    (O_bypass_fifo),
            .O_Monitor_En     (O_Monitor_En),
            .I_Monitor_Out    (I_Monitor_Out),
            .I_Monitor_OutVld (I_Monitor_OutVld)
        );

    task init();
        I_SW2            <= '0;
        I_SW3            <= '0;
        I_SW_S            <= '0;

    endtask

    task drive_SW2(int iter);
        for(int it = 0; it < iter; it++) begin
            I_SW2            <= '1;
            @(posedge clk);
        end
        I_SW2            <= '0;
    endtask
    task drive_SW3(int iter);
        for(int it = 0; it < iter; it++) begin
            I_SW3            <= '1;
            @(posedge clk);
        end
        I_SW3            <= '0;
    endtask
    task drive_SW_S(int iter);
        for(int it = 0; it < iter; it++) begin
            I_SW_S            <= '1;
            @(posedge clk);
        end
        I_SW_S            <= '0;
    endtask
    initial begin
        // do something

        init();
        repeat(10)@(posedge clk);
        drive_SW_S(200); // rst_n_auto
        drive_SW3(200); // O_reset_n
        repeat(10)@(posedge clk);
        drive_SW2(2000); // O_SW_clk

        repeat(100)@(posedge clk); // test loop
        drive_SW_S(200); // rst_n_auto
        drive_SW3(200); // O_reset_n
        repeat(10)@(posedge clk);
        drive_SW2(2000); // O_SW_clk

        repeat(10)@(posedge clk);
        
        // $finish;
    end

    // // dump wave
    // initial begin
    //     $display("random seed : %0d", $unsigned($get_initial_random_seed()));
    //     if ( $test$plusargs("fsdb") ) begin
    //         $fsdbDumpfile("tb_FPGA.fsdb");
    //         $fsdbDumpvars(0, "tb_FPGA", "+mda", "+functions");
    //     end
    // end

    ASIC ASIC_U
        (
            .I_reset_n     (O_reset_n),
            .I_reset_dll   (O_reset_n),
            .I_clk_in      (clk_core && O_SW_clk),
            .I_bypass      (O_bypass),
            .I_SW0         (O_SW0),
            .I_SW1         (O_SW1),
            .O_DLL_lock    (I_DLL_lock_),
            .O_clk_out     (I_clk_out),
            .O_sck_out     (I_sck_out),
            .IO_spi_data   (IO_spi_data),
            .O_config_req  (I_config_req),
            .O_near_full   (I_near_full),
            .O_switch_rdwr (I_switch_rdwr),
            .I_OE_req      (O_OE_req),
            .I_spi_cs_n    (O_spi_cs_n),
            .I_spi_sck     (O_spi_sck && O_SW_clk),
            .I_in_1        (O_in_1),
            .I_in_2        (O_in_2),
            .I_bypass_fifo (O_bypass_fifo),
            .O_Monitor_Out   (I_Monitor_Out),
            .I_Monitor_En    (O_Monitor_En),
            .O_Monitor_OutVld(I_Monitor_OutVld)
        );

    `ifdef SYNT
        initial $sdf_annotate("/workspace/home/zhoucc/Share/TS3D/zhoucc/synth/ASIC/200814_Margin_1.8_group_Track_3vt_Note_NOQRC_ADDDEBUG/gate/ASIC.sdf",
    ASIC_U,, "sdf.log", "MAXIMUM","1.0:1.0:1.0","FROM_MAXIMUM");
    `endif

endmodule
