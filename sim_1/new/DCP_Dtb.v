`timescale 1ns / 1ps

module DCP_Dtb(

    );
    /*input clk,
    input rst,
    input [7:0] sel_mode,
    input [7:0] CMD_D,
    output reg finish_D,
    //input [31:0] last_addr_D, // the address of the last data when look up last time 
    output [31:0] addr_D, //the address sent to cpu
    input [31:0] din_rx,
    input [31:0] dout_dm, // data memory data output
    //output [31:0] addr, // for CPU to read data
    input ack_rx,
    input flag_rx,
    input ack_tx,
    output reg req_rx_D,
    output reg type_rx_D,
    output reg req_tx_D,
    output reg type_tx_D,
    output reg [7:0] dout_D*/

    reg clk =0;
    reg rst;
    
    wire finish;
    wire [31:0] addr_D;
    reg [31:0] din_rx;
    reg [31:0] dout_dm;
    reg ack_rx;
    reg flag_rx;
    reg ack_tx;
    wire req_rx_D;
    wire type_rx_D;
    wire req_tx_D;
    wire type_tx_D;
    wire [31:0] dout_D;


    DCP_D DCP_D_TB(
        .clk(clk),
        .rst(rst),
        .sel_mode(8'h44),
        .CMD_D(8'h44),
        .finish_D(finish),
        .addr_D(addr_D),
        .din_rx(din_rx),
        .dout_dm(dout_dm),//cpu data memory data output
        .ack_rx(ack_rx),
        .flag_rx(flag_rx),
        .ack_tx(ack_tx),
        .req_rx_D(req_rx_D),
        .type_rx_D(type_rx_D),
        .req_tx_D(req_tx_D),
        .type_tx_D(type_tx_D),
        .dout_D(dout_D)
    );



    initial begin
        rst=0;
        #2 rst =1;
        #2 rst =0;
        #2 ack_rx = 0;
        din_rx = 32'h00000123;
        dout_dm= 32'h00000716;
        #10
        flag_rx = 0;
        #2 ack_rx=1;
        #2 ack_rx=0; //SCAN
        #2 ack_tx =0;
        #2 ack_tx=1; //PRINT_INF
        #2 ack_tx=0;
        #2 ack_tx=1; //PRINT_INF
        #2 ack_tx=0;
        #2 ack_tx=1; //PRINTA
        #2 ack_tx=0;
        #2 ack_tx=1; //PRINT_MAO
        #2 ack_tx=0; 
        #2 ack_tx=1; //DATA1
        #2 ack_tx=0;
        #2 ack_tx=1; //DATA2
        #2 ack_tx=0;
        #2 ack_tx=1; //DATA3
        #2 ack_tx=0;
        #2 ack_tx=1; //DATA4
        #2 ack_tx=0;
        #2 ack_tx=1; //DATA5
        #2 ack_tx=0;
        #2 ack_tx=1; //DATA6
        #2 ack_tx=0;
        #2 ack_tx=1; //DATA7
        #2 ack_tx=0;
        #2 ack_tx=1; //DATA8
        #2 ack_tx=0;
        #2 ack_tx=1; //finish 0d
        #2 ack_tx=0;
        #2 ack_tx=1; //finish 0a


        

    end
    always @(*) begin
        forever begin
            #1;
            clk=~clk;
        end
    end
endmodule