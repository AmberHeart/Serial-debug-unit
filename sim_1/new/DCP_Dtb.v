`timescale 1ns / 1ps

module DCP_Dtb(

    );
    //input clk,
    //input rst,
    //input we,
    //output reg finish,
    //input [31:0] last_addr_D, // the address of the last data when look up last time 
    //output reg [31:0] end_addr_D, //the address of the last data when look up this time 
    //input [7:0] d_rx,
    //input [31:0] dout_dm, // data memory data output
    //output [31:0] addr, // for CPU to read data
    //input rdy_tx,
    //input vld_rx,
    //output vld_tx,
    //output rdy_rx,
    //output [7:0] d_tx

    reg clk =0;
    reg rst;
    reg we =1;
    wire finish;
    reg [31:0] last_addr_D = 32'h00000000;
    wire [31:0] end_addr_D;
    reg [7:0] d_rx = 8'h00;
    reg [31:0] dout_dm = 32'h0000123;
    wire [31:0] addr;
    reg rdy_tx = 1;
    reg vld_rx = 1;
    wire vld_tx;
    wire rdy_rx;
    wire [7:0] d_tx;
    reg clk_tx = 0;


    DCP_D DCP_D_TB(
        .clk(clk),
        .rst(rst),
        .we(we),
        .finish(finish),
        .last_addr_D(last_addr_D),
        .end_addr_D(end_addr_D),
        .d_rx(d_rx),
        .dout_dm(dout_dm),
        .addr(addr),
        .rdy_tx(rdy_tx),
        .vld_rx(vld_rx),
        .vld_tx(vld_tx),
        .rdy_rx(rdy_rx),
        .d_tx(d_tx)
    );
    uart_tx utx(
        .clk_tx(clk_tx),
        .rst(rst),
        .d_tx(d_tx),
        .vld_tx(vld_tx),
        .rdy_tx(rdy_tx),
        .txd(txd)
    );
    uart_rx rx(
        .clk(clk),
        .rst(rst),
        .rxd(rxd),
        .rdy_rx(rdy_rx),
        .d_rx(d_rx),
        .vld_rx(vld_rx)
    );


    initial begin
        rst=0;
        #1 rst =1;
        #1 rst =0;

        #2;
        

    end
    always @(*) begin
        forever begin
            #1;
            clk=~clk;
        end
    end
endmodule