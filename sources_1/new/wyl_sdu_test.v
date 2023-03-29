`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/25 16:05:08
// Design Name: 
// Module Name: SDU_test
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


module SDU_test_wyl(
    input clk,
    input rstn,
    input rxd,
    input [1:0]sw,
    output type_rx,
    output txd,
    output [7:0] scan_w,
    output [7:0] print_w
    );
    wire clk_cpu;
    wire [31:0] pc_chk;
    wire [31:0] npc;
    wire [31:0] pc;
    wire [31:0] IR;
    wire [31:0] CTL;
    wire [31:0] A;
    wire [31:0] B;
    wire [31:0] Y;
    wire [31:0] MDR;
    wire [31:0] addr;
    wire [31:0] dout_rf;
    wire [31:0] dout_dm;
    wire [31:0] dout_im;
    wire [31:0] din;
    wire we_dm;
    wire we_im;
    wire clk_ld;
    CPU_test test_CPU(
        .clk(clk),
        .rstn(rstn),
        .clk_cpu(clk_cpu),
        .pc_chk(pc_chk),
        .npc(npc),
        .pc(pc),
        .IR(IR),
        .CTL(CTL),
        .A(A),
        .B(B),
        .Y(Y),
        .MDR(MDR),
        .addr(addr),
        .dout_rf(dout_rf),
        .dout_dm(dout_dm),
        .dout_im(dout_im),
        .din(din),
        .we_dm(we_dm),
        .we_im(we_im),
        .clk_ld(clk)
    );
    SDU SDU_wyl(
        .clk(clk),
        .rstn(rstn),
        .rxd(rxd),
        .txd(txd),
        .clk_cpu(clk_cpu),
        .pc_chk(pc),
        .npc(npc),
        .pc(pc),
        .IR(IR),
        .CTL(CTL),
        .A(A),
        .B(B),
        .Y(Y),
        .MDR(MDR),
        .addr(addr),
        .dout_rf(dout_rf),
        .dout_dm(dout_dm),
        .dout_im(dout_im),
        .din(din),
        .we_dm(we_dm),
        .we_im(we_im),
        .clk_ld(clk_ld)
        ,.cs(scan_w)
        ,.sel(print_w)
    );
endmodule