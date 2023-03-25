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
    wire pc_chk;
    wire [31:0] npc;
    wire [31:0] pc;
    wire [31:0] addr;
    wire [31:0] dout_rf;
    wire [31:0] dout_dm;
    wire [31:0] dout_im;
    wire [31:0] din;
    wire we_dm;
    wire we_im;
    wire clk_ld;
    wire [7:0] r;
    wire [7:0] t;
    SDU_wyl SDU_wyl(
        .clk(clk),
        .rstn(rstn),
        .rxd(rxd),
        .txd(txd),
        .clk_cpu(clk_cpu),
        .pc_chk(pc_chk),
        .npc(npc),
        .pc(pc),
        .addr(addr),
        .dout_rf(dout_rf),
        .dout_dm(dout_dm),
        .dout_im(dout_im),
        .din(din),
        .we_dm(we_dm),
        .we_im(we_im),
        .clk_ld(clk_ld),
        .cs(scan_w),
        .sel(print_w)
        //.r(r),
        //.t(t)
    );
   
    /*always@(posedge clk or negedge rstn) 
    begin
        if(!rstn)
        begin
            scan_w <= 8'hff;
            print_w <= 8'hff;
        end
        else
        begin
            if(|r)
                scan_w <= r;
            else
                scan_w <= scan_w;
            if(|t)
                print_w <= t;
            else
                print_w <= print_w;
        end
    end*/
endmodule
