`timescale 1ns / 1ps

module uart_rx(
    input clk,//100MHZ
    input rst,
    input rxd,
    input rdy_rx,//其他模块输入，1表示可以接受新数据,0表示正在接收
    output reg [7:0] d_rx,
    output reg vld_rx   //1提示数据已经接收,等待其他模块拿走
);

parameter TICKS_PER_BIT = 10417>>4; // assuming 100 MHz clock frequency
reg[3:0] fr_div;//分频器
reg [7:0] CNT;
reg [3:0] CNTb;
wire process;//表示是否正在接收数据，1表示正在接受
CNTc cntc(
    /*
    input clk,
    input rst,
    input rxd,
    input vld_rx,
    output reg process
    */
    .clk(clk),
    .fr_div(fr_div),
    .rst(rst),
    .rxd(rxd),
    .vld_rx(vld_rx),//vld_rx=1--->process=0
    .process(process)
);
always @(posedge clk or posedge rst) begin
    if(rst)begin
        fr_div<=0;
    end else if(fr_div==TICKS_PER_BIT) begin
        fr_div<=0;
    end else begin
        fr_div<=fr_div+1;
    end
end
always @(posedge clk or posedge rst) begin
    if(rst)begin
        d_rx<=0;
    end else if(process&&fr_div==0) begin
        if(CNT==16)begin//取样中点
            CNT<=0;
            d_rx<={rxd,d_rx[7:1]};
        end else begin
            CNT<=CNT+1;
        end
    end
end
always @(posedge clk or posedge rst) begin
    if(rst)begin
        CNTb<=0;
        CNT<=0;
        vld_rx<=0;
    end else if (fr_div==0) begin
        else if(CNT==16)begin//取样中数据还未被接受
            CNTb<=CNTb+1;
            vld_rx<=0;
        end
        else if(CNTb==8)begin
            vld_rx=1;
            CNTb<=0;
        end 
    end
end
endmodule   