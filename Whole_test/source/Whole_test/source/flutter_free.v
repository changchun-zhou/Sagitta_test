`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/15 10:07:00
// Design Name: 
// Module Name: flutter_free
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module flutter_free(
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    input btn, 
    output reg signal
);

parameter T_20MS = 2000000; 
reg [20 : 0]time_cnt;

reg [1 : 0]state, next_state;
parameter IDLE = 2'b00, QUDOU = 2'b01, STABLE = 2'b11;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        state <= IDLE;        
    end else begin
        state <= next_state;        
    end
end

always @( * ) begin
    if (~rst_n) begin
        next_state = IDLE;        
    end else begin
        case(state)
            IDLE: if (btn) begin
                next_state = QUDOU;
            end else begin
                next_state = IDLE;
            end
            QUDOU: if (time_cnt == T_20MS) begin
                if (btn) begin
                    next_state = STABLE;
                end else begin
                    next_state = IDLE;
                end
            end else begin
                next_state = QUDOU;
            end
            STABLE: if (~btn) begin
                next_state = QUDOU;
            end else begin
                next_state = STABLE;
            end
            default: next_state = IDLE;
        endcase        
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        time_cnt <= 0;        
    end else if (state == QUDOU) begin
        time_cnt <= time_cnt + 1;
    end else begin
        time_cnt <= 0;
    end
end

reg stable_btn, stable_btn_d;
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        stable_btn <= 0;        
    end else if (next_state == STABLE && state == QUDOU) begin
        stable_btn <= 1;
    end else if (next_state == IDLE && state == QUDOU) begin
        stable_btn <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        stable_btn_d <= 0;        
    end else begin
        stable_btn_d <= stable_btn;
    end
end


always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        signal <= 0;        
    end else if (stable_btn & (~stable_btn_d)) begin
        signal <= 1;
    end else begin
        signal <= 0;
    end
end


endmodule
