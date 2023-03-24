`timescale 1ns / 1ps

module uart_rx(
    input clk,//9600*16  HZ
    input rst,
    input rxd,
    input rdy_rx,//1 means ready to accept new data, 0 otherwise.
    output reg [7:0] d_rx,
    output reg vld_rx   //1 indicates that data has been received and is waiting for other modules to take it away
);

// parameter TICKS_PER_BIT = 10416; // assuming 100 MHz clock frequency
reg [15:0] CNT;
// reg[3:0] fr_div;//分频器
reg [3:0] CNTb;
wire process;//表示是否正在接收数据，1表示正在接受
assign flg=process;
CNTc cntc(
    /*
    input clk,
    input rst,
    input rxd,
    input vld_rx,
    output reg process
    */
    .clk(clk),
    .rst(rst),
    .rxd(rxd),
    .vld_rx(vld_rx),//vld_rx=1--->process=0
    .process(process)
);
reg edg_up,tmp;//取process上升沿
always @(posedge clk) begin
    tmp<=process;
    if(process&&!tmp)begin
        edg_up<=1;
    end else begin
        edg_up<=0;
    end
end
always @(posedge clk) begin
    if(rst||edg_up)begin
        d_rx<=0;
        CNT<=0;
    end
    if(process) begin
        if(CNT==8)begin//取样中点
            CNT<=0;
            d_rx<={rxd,d_rx[7:1]};
        end else begin
            CNT<=CNT+1;
        end
    end
end
always @(posedge clk) begin
    if(rst||edg_up)begin
        CNTb<=0;
        vld_rx<=0;
    end else if(process)begin
        if(CNT==0)begin//取样中数据还未被接受
            CNTb<=CNTb+1;
        end
        if(CNTb==8)begin
            vld_rx<=1;
            CNTb<=0;
        end else begin
            vld_rx<=0;
        end
    end else if(rdy_rx)begin
        vld_rx<=0;
    end
end
endmodule   