`timescale 1ns / 1ps

module uart_echo(
    input clk,
    input reset,
    input rxd,
    // input [7:0] btn,
    // output txd,
    output reg [7:0] word
);
wire vld_rx;
wire [7:0] d_rx;
reg  [31:0] cnt;
// assign word=btn;
wire  vld_rx;
uart_rx rx(
    /*
    input clk,//100MHZ
    input rst,
    input rxd,
    input rdy_rx,//其他模块输入，1表示可以接受新数据,0表示正在接收
    output reg [7:0] d_rx,
    output reg vld_rx,   //1提示数据已经接收,等待其他模块拿走,只有一个脉冲
    */
    .clk(clk),
    .rst(reset),
    .rxd(rxd),
    .rdy_rx(1),
    .d_rx(d_rx),
    .vld_rx(vld_rx)
);
always @(posedge clk) begin
    if(vld_rx)begin
        word<=d_rx;
        cnt<=32'h007f_ffff;
    end
    else if(cnt)begin
        cnt<=cnt-1;
    end else begin
        word<=0;
    end
end
// uart_tx tx(
//     /*
//     input clk_tx,//clk_tx是9600的波特率，不要直接传100MHZ
//     input rst,
//     input [7:0] d_tx,
//     input vld_tx,//vld需要其他模块输入，可以理解为发送使能(脉冲信号)
//     output rdy_tx,//rdy只是遵循协议，其实PC不管这个
//     output reg txd
//     */
//     .clk(clk),
//     .rst(reset),
//     .d_tx(word),//echo computer's message
//     .vld_tx(vld_rx),
//     .rdy_tx(rdy_tx),
//     .txd(txd)
// );

endmodule  