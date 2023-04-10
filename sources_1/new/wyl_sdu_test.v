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
    output txd,
    output [7:0] scan_w,
    output [7:0] print_w
    );
    wire clk_cpu;
    wire [31:0] pc_chk;
    wire [31:0] npc;
    wire [31:0] pc;
    wire [31:0] ir;
    wire [31:0] pcd;
    wire [31:0] ire;
    wire [31:0] imm;
    wire [31:0] a;
    wire [31:0] b;
    wire [31:0] pce;
    wire [31:0] ctr;
    wire [31:0] irm;
    wire [31:0] mdw;
    wire [31:0] y;
    wire [31:0] ctrm;
    wire [31:0] irw;
    wire [31:0] yw;
    wire [31:0] mdr;
    wire [31:0] ctrw;
    wire [31:0] addr;
    wire [31:0] dout_rf;
    wire [31:0] dout_dm;
    wire [31:0] dout_im;
    wire [31:0] din;
    wire we_dm;
    wire we_im;
    wire clk_ld;
    wire debug;
    CPU_test test_CPU(
        .clk(clk),
        .rstn(rstn),
        .clk_cpu(clk_cpu),
        .pc_chk(pc_chk),
                .npc(npc),
.pc(pc),
.ir(ir),
.pcd(pcd),
.ire(ire),
.imm(imm),
.a(a),
.b(b),
.pce(pce),
.ctr(ctr),
.irm(irm),
.mdw(mdw),
.y(y),
.ctrm(ctrm),
.irw(irw),
.yw(yw),
.mdr(mdr),
.ctrw(ctrw),
        .addr(addr),
        .dout_rf(dout_rf),
        .dout_dm(dout_dm),
        .dout_im(dout_im),
        .we_dm(we_dm),
        .we_im(we_im),
        .clk_ld(clk_ld),
        .debug(debug)
        ,.din(din)
    );
    SDU SDU_wyl(
        .clk(clk),
        .rstn(rstn),
        .rxd(rxd),
        .txd(txd),
        .clk_cpu(clk_cpu),
        .pc_chk(pce),
        .npc(npc),
.pc(pc),
.ir(ir),
.pcd(pcd),
.ire(ire),
.imm(imm),
.a(a),
.b(b),
.pce(pce),
.ctr(ctr),
.irm(irm),
.mdw(mdw),
.y(y),
.ctrm(ctrm),
.irw(irw),
.yw(yw),
.mdr(mdr),
.ctrw(ctrw),
        .addr(addr),
        .dout_rf(dout_rf),
        .dout_dm(dout_dm),
        .dout_im(dout_im),
        .we_dm(we_dm),
        .we_im(we_im),
        .clk_ld(clk_ld)
        ,.cs(scan_w)
        ,.sel(print_w)
        ,.debug(debug)
        ,.din(din)
    );
endmodule