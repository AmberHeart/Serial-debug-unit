`timescale 1ns / 1ps
module DCP_D(
    input clk,
    input rst,
    input we,
    output finish,
    input [31:0] last_add, // the address of the last data when look up last time 
    output [31:0] end_add, //the address of the last data when look up this time 
    //print
    input rdy_tx,
    output reg vld_tx,
    output reg [31:0] d_tx
);

reg type_tx, req_tx;
wire ack_tx;

endmodule