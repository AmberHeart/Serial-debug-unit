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
    input rstn,
    input [7:0] d_rx,
    input vld_rx,
    output reg rdy_rx,
    input type_rx,
    input req_rx,
    output reg flag_rx,
    output reg ack_rx,
    output reg [31:0] din_rx 
    );
    parameter IDLE = 3'b000; // wait for request
    parameter BYTE = 3'b001; // request a btye
    parameter ADDR = 3'b010; // request an address
    parameter ENTER = 3'b011; // 0d0a
    parameter SEND = 3'b100; // send data
    reg [2:0] curr_state;
    reg [2:0] next_state;
    reg [4:0] cnt;
    wire Hex;
    assign Hex = (8'h30 <= d_rx && d_rx <= 8'h39) 
              || (8'h41 <= d_rx && d_rx <= 8'h46) 
              || (8'h61 <= d_rx && d_rx <= 8'h66);
    reg [7:0] C2H;
    always@(*)
    begin
        if(8'h30 <= d_rx && d_rx <= 8'h39) 
            C2H = Hex - 8'h30;
        else if(8'h41 <= d_rx && d_rx <= 8'h46)
            C2H = Hex - 8'h37;
        else if(8'h61 <= d_rx && d_rx <= 8'h66)
            C2H = Hex - 8'h57;
        else
            C2H = 8'h000000;
    end
    always@(posedge clk or negedge rstn)
    begin
        if(~rstn)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    always@(*)
    begin
        if(curr_state == IDLE)
        begin
            if(req_rx == 1)
            begin
                if(type_rx == 0)
                    next_state = BYTE;
                else
                    next_state = ADDR;
            end
            else 
                next_state = IDLE;  
        end
        else if(curr_state == BYTE)
        begin
            if(vld_rx == 1)
            begin
                if(d_rx == 8'h0d)
                    next_state = ENTER;
                else if(d_rx == 8'h20)
                    next_state = BYTE;
                else 
                    next_state = SEND;
            end
            else // not valid, then wait for data
                next_state = BYTE;
        end
        else if(curr_state == ADDR)
        begin
            if(cnt == 8)
                next_state = SEND;
            else 
            begin
                if(vld_rx == 1)
                begin
                    if(d_rx == 8'h0d)
                        next_state = ENTER;
                    else
                        next_state = ADDR;
                end
            end
        end
        else if(curr_state == SEND)
            next_state = IDLE;
        else
            next_state = curr_state;
    end
    always@(posedge clk)
    begin
        if(curr_state == IDLE)
        begin
            rdy_rx <= 0; //not ready to receive data
            ack_rx <= 0; //not acknowledge
            din_rx <= 32'h00000000; //clear data
            cnt <= 0; //reset counter
            flag_rx <= 1; 
        end
        else if(curr_state == BYTE)
        begin
            rdy_rx <= 1; // ready to receive data
            if(vld_rx == 1)
            begin
                if(d_rx == 8'h0d || d_rx == 8'h20) 
                    ;// not legal, then wait for data
                else
                begin
                    flag_rx <= 0;
                    din_rx <= {24'h000000,d_rx}; 
                end
            end
            else 
                ;// not valid, then wait for data
        end
        else if(curr_state == ADDR)
        begin
            rdy_rx <= 1; // ready to receive data
            if(cnt <= 7)
            begin
                if(vld_rx == 1)
                begin
                    if(Hex)
                    begin
                        cnt <= cnt + 1;
                        din_rx <= {din_rx[27:0],C2H[3:0]};
                    end
                    else 
                        ; // not Hex, then wait for data    
                end
                else
                    ; // not valid, then wait for data
            end
            else 
                flag_rx <= 0; // cnt > 7, then wait for sending data      
        end
        else if(curr_state == ENTER)
        begin
            if(vld_rx == 1)
            begin
                if(d_rx == 8'h0a)
                    flag_rx <= 1;
                else 
                    ; // not legal, then wait for data
            end
            else 
                ; // not valid, then wait for data
        end
        else if(curr_state == SEND)
            ack_rx <= 1; // acknowledge
        else 
            ; // do nothing 
    end
endmodule