`timescale 1ns / 1ps
module RDY (
    input vld_tx,
    input rst,clk,
    input [3:0] CNT,
    output reg rdy_tx
);
    always @(posedge clk or posedge rst) begin
        if(rst)begin
            rdy_tx<=1;
        end else if(vld_tx&&rdy_tx)begin
            rdy_tx<=0;
        end else if(!CNT)begin
            rdy_tx<=1;
        end
    end
endmodule