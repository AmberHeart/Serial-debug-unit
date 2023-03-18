`timescale 1ns / 1ps

module uart_echo(
    input clk,
    input reset,
    input rxd,
    output txd
);
wire vld_rx;
wire [7:0] d_rx;
RX rx(
/*
input clk,//100MHZ
    input rst,
    input rxd,
    input rdy_rx,//1 means ready to accept new data, 0 otherwise
    output reg [7:0] d_rx,
    output reg vld_rx   
    //1 indicates that data has been received and is waiting for other modules to take it away
*/
    .clk(clk),
    .rst(reset),
    .rxd(rxd),
    .rdy_rx(1),//always ready for new data
    .d_rx(d_rx),
    .vld_rx(vld_rx)
);
parameter TICKS_PER_BIT = 10417; 
// assuming 100 MHz clock frequency
reg[13:0] fr_div;// frequency divider
reg clk_tx;
always @(posedge clk or posedge rst) begin
    if(rst)begin
        fr_div<=0;
        clk_tx<=0;
    end else if(fr_div==TICKS_PER_BIT)begin
        fr_div<=0;
        clk_tx<=!clk_tx;
    end else begin
        fr_div<=fr_div+1;
    end
end 
TX tx(
    /*
    input clk_tx,//clk_tx是9600的波特率，不要直接传100MHZ
    input rst,
    input [7:0] d_tx,
    input vld_tx,//vld需要其他模块输入，可以理解为发送使能
    output rdy_tx,//rdy只是遵循协议，其实PC不管这个
    output reg txd
    */
    .clk_tx(clk_tx),
    .rst(rst),
    .d_tx(d_rx),//echo computer's message
    .vld_tx(vld_rx),
    .rdy_tx(rdy_tx),
    .txd(txd)
);
wire vld_rx;
wire [7:0] d_rx;
RX rx(
/*
input clk,//100MHZ
    input rst,
    input rxd,
    input rdy_rx,//1 means ready to accept new data, 0 otherwise
    output reg [7:0] d_rx,
    output reg vld_rx   
    //1 indicates that data has been received and is waiting for other modules to take it away
*/
    .clk(clk),
    .rst(reset),
    .rxd(rxd),
    .rdy_rx(1),//always ready for new data
    .d_rx(d_rx),
    .vld_rx(vld_rx)
);
parameter TICKS_PER_BIT = 10417; 
// assuming 100 MHz clock frequency
reg[13:0] fr_div;// frequency divider
reg clk_tx;
always @(posedge clk or posedge rst) begin
    if(rst)begin
        fr_div<=0;
        clk_tx<=0;
    end else if(fr_div==TICKS_PER_BIT)begin
        fr_div<=0;
        clk_tx<=!clk_tx;
    end else begin
        fr_div<=fr_div+1;
    end
end 
TX tx(
    /*
    input clk_tx,//clk_tx是9600的波特率，不要直接传100MHZ
    input rst,
    input [7:0] d_tx,
    input vld_tx,//vld需要其他模块输入，可以理解为发送使能
    output rdy_tx,//rdy只是遵循协议，其实PC不管这个
    output reg txd
    */
    .clk_tx(clk_tx),
    .rst(rst),
    .d_tx(d_rx),//echo computer's message
    .vld_tx(vld_rx),
    .rdy_tx(rdy_tx),
    .txd(txd)
);

endmodule  