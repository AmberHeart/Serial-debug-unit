`timescale 1ns / 1ps

module uart_test_tb(
);
reg clk,rst;
/*
module uart_echo(
    input clk,
    input reset,
    input rxd,
    output txd,
    output [7:0] word
);
*/
// wire txd,rdy_tx;
reg rxd;
wire [7:0] d_rx;
wire [7:0] cnt;
wire flg,vld_rx;
uart_rx rx(
    /*
    input clk,//100MHZ
    input rst,
    input rxd,
    input rdy_rx,//其他模块输入，1表示可以接受新数据,0表示正在接收
    output reg [7:0] d_rx,
    output reg vld_rx,   //1提示数据已经接收,等待其他模块拿走
    output flg//process
    */
    .clk(clk),
    .rst(rst),
    .rxd(rxd),
    .rdy_rx(1),
    .d_rx(d_rx),
    .vld_rx(vld_rx)
);
initial begin
    clk=0;rst=0;rxd=1;
    #1;
    rst=1;
    #1;
    rst=0;
    #30;
    rxd=0;//0
    #16;
    rxd=1;//1
    #16;
    rxd=1;//2
    #16;
    rxd=1;//3
    #16;
    rxd=1;//4
    #16;
    rxd=1;//5
    #16;
    rxd=1;//6
    #16;
    rxd=0;//7
    #16;
    rxd=0;//8
    #16;
    rxd=1;//rst
end
always @(*) begin
    forever begin
        #1;
        clk=~clk;
    end
end
endmodule