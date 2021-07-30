`timescale 1ns/1ps

module BRAM_tb;

reg clk;
reg blk_mem_en;
reg [ 32        -1 : 0] blk_mem_addr;
wire    [128       -1 : 0] blk_mem_dout;
               
initial begin
    clk = 0;
    forever #1 clk = ~clk;
end

initial begin
    blk_mem_en = 0;
    repeat(100000) begin
        @(posedge clk)
        blk_mem_en = 1;
    end
end
initial begin
    blk_mem_addr = 0;
    repeat(100000) begin
        @(posedge clk);
        if (blk_mem_en==1) begin 
            blk_mem_addr = blk_mem_addr + 1;
        end
    end
end

blk_mem_gen_0 blk_mem_128x2_18 (
  .clka(clk),    // input wire clka
  .ena(blk_mem_en),
  .addra(blk_mem_addr<<4),  // input wire [31 : 0] addra
  .douta(blk_mem_dout)  // output wire [127 : 0] douta
);

endmodule