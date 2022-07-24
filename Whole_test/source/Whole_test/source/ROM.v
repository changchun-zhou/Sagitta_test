`timescale 1ns/1ps
module ROM #(
// Parameters
  parameter   DATA_WIDTH          = 16,
  parameter   INIT                = "weight.mif",
  parameter   ADDR_WIDTH          = 6,
  parameter   TYPE                = "DISTRIBUTED",
  parameter   INITIALIZE_FIFO     = "yes"
) (
// Port Declarations
  input  wire                         clk,
  input  wire  [ADDR_WIDTH-1:0]       address,
  input  wire                         enable,
  output reg   [DATA_WIDTH-1:0]       data_out
);

// ******************************************************************
// Internal variables
// ******************************************************************
  localparam   ROM_DEPTH          = 1 << ADDR_WIDTH;
  (* ram_style = TYPE *)
  reg     [DATA_WIDTH-1:0]        mem[0:ROM_DEPTH-1];     //Memory
  reg [DATA_WIDTH-1:0]       data_out_;
// ******************************************************************
// Read Logic
// ******************************************************************

  always @ (posedge clk)
  begin : READ_BLK
      if (enable)
        data_out <= mem[address];
  end

// ******************************************************************
// Initialization
// ******************************************************************

  initial begin
    if ( INITIALIZE_FIFO == "yes")
      $readmemh(INIT, mem);
  end


endmodule
