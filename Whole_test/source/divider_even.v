module divider_even# (
    parameter WIDTH_NUM_DIV = 4)
(
    input                           clk,
    input                           rst_n,
    input [ WIDTH_NUM_DIV   -1 : 0] num_div,
    output reg                      clk_div
);

reg [WIDTH_NUM_DIV     : 0] cnt;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt     <= 4'd0;
        clk_div <= 1'b0;
    end else if(cnt < num_div / 2 - 1) begin
        cnt     <= cnt + 1'b1;
        clk_div <= clk_div;
    end else begin
        cnt     <= 4'd0;
        clk_div <= ~clk_div;
    end
end

endmodule