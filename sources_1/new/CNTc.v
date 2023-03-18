`timescale 1ns / 1ps

module CNTc(
    input clk,fr_div,
    input rst,
    input rxd,
    input vld_rx,
    output reg process
    );
    reg [7:0] cnt;
    always @(posedge clk or posedge rst) begin
        if(rst || vld_rx)begin
            process<=0;
        end else if(fr_div==0)begin
            if(!rxd&&!process) begin//S
                cnt<=cnt+1;
                if(cnt>=8)begin
                    process<=1;
                    cnt<=0;
                end
            end else if(rxd&&!process)begin//边沿抖动
                cnt<=0;
            end else begin
                if(cnt==16)cnt<=0;
                else cnt<=cnt+1;
            end        
        end
    end
endmodule
