`timescale 1ns / 1ps

module uart_tx(
    input clk,
    input rstn,
    input [7:0] d_tx,
    input vld_tx,//vld需要其他模块输入，可以理解为发送使能
    output rdy_tx,//rdy只是遵循协议，其实PC不管这个
    output reg txd
);

reg [3:0] CNT;
reg [15:0] fr_div;
reg [8:0] SOR;
// reg [3:0] CNT;
parameter TICKS_PER_BIT = 15; 
RDY rdy(
    .vld_tx(vld_tx),
    .rstn(rstn),
    .clk(clk),
    .CNT(CNT),
    .rdy_tx(rdy_tx),
    .fr_div(fr_div)
);

// reg [15:0] fr_div;
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        fr_div<=0;
    end else if(fr_div==TICKS_PER_BIT) begin
        fr_div<=0;
    end else begin
        fr_div<=fr_div+1;
    end
end
always @(posedge clk or negedge rstn) begin
    if(~rstn)begin
        CNT<=0;
    end else if(fr_div==0)begin
        if(CNT)begin
            CNT<=CNT-1;
        end else if(rdy_tx&&vld_tx) begin
            CNT<=8;
        end
    end
end
always @(posedge clk) begin
    if(fr_div==0)begin
        if(rdy_tx&&vld_tx)begin
            SOR<={d_tx[7:0],1'b0};
            txd<=0;
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
end
endmodule 