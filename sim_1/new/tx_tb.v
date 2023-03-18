`timescale 1ns / 1ps

module tx_tb(
    output rdy_tx,txd
    );
    /*
    input clk_tx,
    input rst,
    input [7:0] d_tx,
    input vld_tx,
    output rdy_tx,
    output reg txd
    */
    reg clk_tx=0,rst,vld_tx;
    reg [7:0] d_tx;
    uart_tx utx(
        .clk_tx(clk_tx),
        .rst(rst),
        .d_tx(d_tx),
        .vld_tx(vld_tx),
        .rdy_tx(rdy_tx),
        .txd(txd)
    );
    initial begin
        rst<=1;
        #6;
        rst<=0;
        #8;
        vld_tx<=1;d_tx<=8'h65;
        #51;
        vld_tx<=1;d_tx<=8'hab;
        #60;
        vld_tx<=0;
    end
    always @(*) begin
        forever begin
            #5;
            clk_tx=~clk_tx;
        end
    end
    
endmodule
