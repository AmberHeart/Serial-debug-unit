`timescale 1ns / 1ps
module RDY (
    input rst,clk,
    input vld_tx,
    input [3:0] CNT,
    input [15:0] fr_div,
    output reg rdy_tx
);
    always @(posedge clk or posedge rst) begin
        if(rst)begin
            rdy_tx<=1;
        end else if(fr_div==0)begin
            if(vld_tx&&rdy_tx)begin
                rdy_tx<=0;
            end
            else if(!CNT)begin
                rdy_tx<=1;
            end
        end
    end
endmodule