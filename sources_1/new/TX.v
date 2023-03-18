`timescale 1ns / 1ps

module uart_tx(
    input clk_tx,//clk_tx是9600的波特率，不要直接传100MHZ
    input rst,
    input [7:0] d_tx,
    input vld_tx,//vld需要其他模块输入，可以理解为发送使能
    output rdy_tx,//rdy只是遵循协议，其实PC不管这个
    output reg txd
);

reg [8:0] SOR;
reg [3:0] CNT;
RDY rdy(
    .vld_tx(vld_tx),
    .rst(rst),
    .clk(clk_tx),
    .CNT(CNT),
    .rdy_tx(rdy_tx)
);
always @(posedge clk_tx or posedge rst) begin
    if(rst)begin
        CNT<=0;
        SOR<=9'b1111_11111;
    end else begin
        if(CNT)begin
            CNT<=CNT-1;
        end else if(rdy_tx) begin
            CNT<=4'b1000;
        end
    end
end
always @(posedge clk_tx) begin
    if(rdy_tx&&vld_tx)begin
        SOR<={d_tx[7:0],1'b0};
        txd<=1'b0;
    end
    else if(CNT)begin
        SOR<={1'b1,SOR[8:1]};
        txd<=SOR[1];
    end
    else begin
        SOR<=9'b1111_11111;
        txd<=1'b1;
    end
end
endmodule 