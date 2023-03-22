`timescale 1ns / 1ps
module DCP_D(
    input clk,
    input rst,
    input we,
    output finish,
    input [31:0] last_add, // the address of the last data when look up last time 
    output [31:0] end_add, //the address of the last data when look up this time 
    //print
    input rdy_tx,
    output reg vld_tx,
    output reg [31:0] d_tx
);
    parameter [2:0]
    INIT = 3'h0,
    SCAN = 3'h1,
    NEWA = 3'h2,
    OLDA = 3'h3,
    PRINTA = 3'h4,
    DATA = 3'h5,
    PRINTD = 3'h6,
    FINISH = 3'h7;
    reg [2:0] NS = INIT , CS = INIT;
reg memory_rdy = 1;    
reg req;
wire ack;
always @(posedge clk or posedge rst) begin
    if(rst) CS <= INIT;
    else CS <= NS;
end
reg flag;
always @(*) begin
    NS=CS;
    case(CS)
        INIT: begin
            if(we) NS = SCAN;
        end
        SCAN: begin
            if(!flag && ack) NS = NEWA;
        end
        SCAN: begin
            if(flag && ack) NS = OLDA;
        end
        OLDA: begin
            if(memory_rdy) NS = PRINTA;
        end
        NEWA: begin
            if(memory_rdy) NS = PRINTA;
        end
        PRINTA: begin
            if(memory_rdy) NS = PRINTD;
        end
        PRINTD: begin
            if(memory_rdy) NS = FINISH;
        end
        FINISH: begin
            if(memory_rdy) NS = INIT;
        end
    endcase
end

endmodule