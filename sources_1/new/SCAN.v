`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/20 16:18:47
// Design Name: 
// Module Name: SCAN
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


module SCAN(
    input clk,
    input rst,
    input [7:0] d_rx,
    input vld_rx,   
    output reg rdy_rx,  // 0 - not ready, 1 - ready
    input type_rx,  // 0 - byte, 1 - word
    input req_rx,   // 0 - no request, 1 - request
    output reg flag_rx, // 0 - no error, 1 - error
    output reg ack_rx,  // 0 - not acknowledge, 1 - acknowledge
    output reg [31:0] din_rx   
    );
    parameter IDLE = 2'b00; // wait for request
    parameter BYTE = 2'b01; // request a btye
    parameter ADDR = 2'b10; // request an address
    parameter SEND = 2'b11; // send data
    reg [1:0] curr_state;
    reg [1:0] next_state;
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    reg [4:0] cnt;
    always@(posedge clk)
    begin
        if(curr_state == IDLE)
        begin
            rdy_rx <= 0; //not ready to receive data
            ack_rx <= 0; //not acknowledge
            din_rx <= 32'h00000000; //clear data
            cnt <= 0;
            if(req_rx == 1)
            begin
                if(type_rx == 0)
                    next_state <= BYTE;
                else
                    next_state <= ADDR;
            end
            else //waiting for request
                next_state <= IDLE;
        end
        else if(curr_state == BYTE)
        begin
            rdy_rx <= 1; // ready to receive data
            if(vld_rx == 1)
            begin
                din_rx <= {24'h000000,d_rx};
                next_state <= SEND;
            end
            else // not valid, then wait for data
                next_state <= BYTE;
        end
        else if(curr_state == ADDR)
        begin
            rdy_rx <= 1; // ready to receive data
            if(vld_rx == 1)
            begin
                din_rx <= {din_rx[23:0],d_rx};
                if(cnt == 3)
                begin
                    cnt <= 0;
                    next_state <= SEND;
                end
                else if(cnt == 0 && din_rx[7:0] == 8'h20)
                    next_state <= ADDR; // if the first byte is 20, then it is a space, then ignore it
                else 
                begin
                    cnt <= cnt + 1;
                    next_state <= ADDR;
                end
            end
            else
            begin
                if(cnt == 1 && din_rx[15:0] == 16'h0d0a) // if the first two bytes are 0d0a, then it is a new line
                    next_state <= SEND;
                else
                    next_state <= ADDR;  
            end
        end
        else if(curr_state == SEND)
        begin
            if(type_rx == 0) // request a byte
            begin
                flag_rx <= 0; 
                ack_rx <= 1; // acknowledge
                next_state <= IDLE;
            end
            else // request an address 
            begin
                ack_rx <= 1;
                next_state <= IDLE;
                if(din_rx[15:0] == 16'h0a0d) 
                    flag_rx <= 1; // empty address
                else
                    flag_rx <= 0; // clear flag
            end
        end
    end
endmodule
