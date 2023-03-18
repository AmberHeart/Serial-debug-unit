`timescale 1ns / 1ps

// Debug Command Processing
module DCP(
    input clk,
    input rst,
    input [7:0] d_tx,
    input vld_tx,
    output rdy_tx,
    output reg txd,
    input rxd,
    input rdy_rx,
    output reg [7:0] d_rx,
    output reg vld_rx
);

endmodule