`timescale 1ns / 1ps

module CNTc(
    input clk,
    input rst,
    input rxd,
    input vld_rx,
    output reg process
    );
    reg [15:0] cnt;
    parameter SAMPLING_TICK = 5208;
    always @(posedge clk or posedge rst) begin
        if(rst || vld_rx)begin
            process<=0;
            cnt<=0;
        end else begin
            if(!rxd&&!process) begin//S
                cnt<=cnt+1;
                if(cnt==SAMPLING_TICK)begin
                    process<=1;
                    cnt<=0;
                end
            end else if(rxd&&!process)begin//边沿抖动
                cnt<=0;
            end else begin
                if(cnt==SAMPLING_TICK<<1)cnt<=0;
                else cnt<=cnt+1;
            end        
        end
    end
endmodule
