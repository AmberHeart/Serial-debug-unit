`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/17 11:07:30
// Design Name: 
// Module Name: uart_test
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


module uart_echo(
    input clk,
    input reset,
    input rxd,
    output txd
);

wire [7:0] d_tx;
wire vld_tx;
wire rdy_tx;
wire [7:0] d_rx;
wire vld_rx;
wire rdy_rx;

uart_tx tx(clk, reset, 25, vld_tx, rdy_tx, txd); // instantiate transmitter module
// uart_rx rx(clk, reset, rxd, rdy_rx, d_rx, vld_rx); // instantiate receiver module

assign d_tx = d_rx; // connect received data to transmitted data
assign vld_tx = vld_rx; // connect valid flag from receiver to transmitter
assign rdy_rx = rdy_tx; // connect ready flag from transmitter to receiver

endmodule  