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


module CPU_SDU(
    input clk,
    input rstn,
    input rxd,
    output txd
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
    wire [31:0] IMM;
    wire [31:0] addr;
    wire [31:0] dout_rf;
    wire [31:0] dout_dm;
    wire [31:0] dout_im;
    wire [31:0] din;
    wire we_dm;
    wire we_im;
    wire clk_ld;
    CPU CPU(
        .clk(clk_cpu),
        .pc_chk(pc_chk),

        .npc(npc),
        .PC(pc),
        .IR(IR),
        .CTL(CTL),
        .A(A),
        .B(B),
        .Y(Y),
        .IMM(IMM),
        .MD(MDR),
        .addr(addr),
        .R_read_data(dout_rf),
        .D_read_data(dout_dm),
        .I_read_data(dout_im),
        .D_write_data(din),
        .I_write_data(din),
        .D_we(we_dm),
        .I_we(we_im),
        .clk_ld(clk_ld)
    );
    SDU SDU(
        .clk(clk),
        .rstn(rstn),
        .rxd(rxd),
        .txd(txd),
        .clk_cpu(clk_cpu),
        .pc_chk(pc_chk),
        .npc(npc),
        .pc(pc),
        .IR(IR),
        .CTL(CTL),
        .A(A),
        .B(B),
        .Y(Y),
        .IMM(IMM),
        .MDR(MDR),
        .addr(addr),
        .dout_rf(dout_rf),
        .dout_dm(dout_dm),
        .dout_im(dout_im),
        .din(din),
        .we_dm(we_dm),
        .we_im(we_im),
        .clk_ld(clk_ld)
    );
endmodule