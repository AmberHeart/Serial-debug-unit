`timescale 1ns / 1ps
module DCP_G(
    input clk,
    input rstn,
    input [7:0] sel_mode,
    input [7:0] CMD_G,
    output reg finish_G,
    input [31:0] pc_chk,
    input [31:0] B_1,
    input [31:0] B_2,
    output clk_cpu_G,
);
endmodule