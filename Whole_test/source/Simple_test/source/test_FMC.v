module  FPGA(

    output                          O_SW_clk        , // switch of clk_chip
    output                          O_reset_n       , // reset of whole chip

    output                          O_clk_in        , // clk_in of whole chip : clk_in of DLL

    output                          O_bypass        , // DLL
    output                          O_SW0           ,
    output                          O_SW1           ,


    inout[ 128              -1 : 0] IO_spi_data     , 

    output                          O_OE_req        , // OE_req_rd : pad_OE
    output                          O_spi_cs_n      , // ASICGB_cfg_rdy : I_spi_cs_n
    output                          O_spi_sck       , // clk_in of asyncFIFO

    output                          O_in_1          , // ASICGB_wr_rdy
    output                          O_in_2          , // ASICGB_rd_val

    output                          O_bypass_fifo   ,

    output                          O_Monitor_En    

    
);  

assign O_O_SW_clk       = 1'b1;
assign O_reset_n        = 1'b1;
assign O_clk_in         = 1'b1;
assign O_bypass         = 1'b1;
assign O_SW0            = 1'b1;
assign O_SW1            = 1'b1;
assign IO_spi_data      = 128{1'b1};
assign O_OE_req         = 1'b1;
assign O_spi_cs_n       = 1'b1;
assign O_spi_sck        = 1'b1;
assign O_in_1           = 1'b1;
assign O_in_2           = 1'b1;
assign O_bypass_fifo    = 1'b1;    
assign O_Monitor_En     = 1'b1;    
endmodule