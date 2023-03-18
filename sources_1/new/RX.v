`timescale 1ns / 1ps

module uart_rx(
    input clk,//100MHZ
    input rst,
    input rxd,
    input rdy_rx,//1 means ready to accept new data, 0 otherwise.
    output reg [7:0] d_rx,
    output reg vld_rx   //1 indicates that data has been received and is waiting for other modules to take it away
);

parameter TICKS_PER_BIT = 10417>>4; // assuming 100 MHz clock frequency
reg[3:0] fr_div;// frequency divider 
reg [7:0] CNT;
reg [3:0] CNTb;
wire process;//indicates whether data is being received, 1 means receiving
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
        if(CNT==16)begin//sampling midpoint
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
        if(CNT==16)begin//data is not received during sampling.
            CNTb<=CNTb+1;
            vld_rx<=0;
        end
        if(CNTb==8)begin
            vld_rx<=1;
            CNTb<=0;
        end 
    end
end
endmodule   