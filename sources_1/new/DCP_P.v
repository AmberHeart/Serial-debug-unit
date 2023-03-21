`timescale 1ns / 1ps
/* print the datapathe status */

module DCP_P#(parameter CONTROL_STATUS = 32)(
    input clk,
    input rst,
    input we,
    output finish,
    input [31:0] PC, // current pc
    input [31:0] nPC, //next pc
    input [31:0] IR, // instruction
    input [31:0] A, // register A
    input [31:0] B, // register B
    input [CONTROL_STATUS-1:0] ctl, // control unit
    input [31:0] Y, // ALU result
    input [31:0] MDR, // memory data
    // input [31:0] MAR, // memory address
    // input [31:0] SP, // stack pointer
    //print
    input rdy_tx,
    output reg vld_tx,
    output reg [7:0] d_tx
);


endmodule