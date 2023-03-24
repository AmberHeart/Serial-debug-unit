`timescale 1ns / 1ps

module rx_tb(
/*
input clk,//100MHZ
input rst,
input rxd,
input rdy_rx,//其他模块输入，1表示可以接受新数据,0表示正在接收
output reg [7:0] d_rx,
output reg vld_rx   //1提示数据已经接收,等待其他模块拿走
*/
    );
    reg clk=0,rst,rxd,rdy_rx;
    wire[7:0] d_rx;
    wire vld_rx;
    uart_rx rx(
        .clk(clk),
        .rst(rst),
        .rxd(rxd),
        .rdy_rx(rdy_rx),
        .d_rx(d_rx),
        .vld_rx(vld_rx)
    );
    initial begin
        rst=1;rxd=1;rdy_rx=1;
        #2;
        rxd=0;rst=0;rdy_rx=0;
        #16;rxd=1;
        #16;rxd=0;
        #16;rxd=1;
        #16;rxd=0;
        #16;rxd=1;
        #16;rxd=0;
        #16;rxd=1;
        #16;rxd=0;
        #16;rxd=1;

    end
    always @(*) begin
        forever begin
            #1;
            clk=~clk;
        end
    end
endmodule
