`timescale 1ns / 1ps
module DCP_D(
    input clk,
    input rst,
    input we,
    output finish,
    input [31:0] last_addr, // the address of the last data when look up last time 
    output [31:0] end_addr, //the address of the last data when look up this time 
    input [7:0] d_rx,
    input rdy_tx,
    input vld_rx,
    output vld_tx,
    output rdy_rx,
    output [7:0] d_tx
    // //print
    // input ack_scan,
    // input ack_print,
    // input flag,
    // output reg type_rx,
    // output reg type_tx,
    // output reg req_scan,
    // output reg req_print

);
// finite state machine
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
// wait for memory ready
    reg memory_rdy = 0;    // 0 for wait, 1 for ready

    reg req_rx = 0, req_tx = 0, type_rx, type_tx;
    wire ack_rx, ack_tx, flag_rx;
    reg [31:0] din_rx, dout_tx;

    PRINT print_D(
        .clk(clk), .rst(rst),
        .dout_tx(dout_tx),
        .type_tx(type_tx),
        .req_tx(req_tx),
        .ack_tx(ack_tx),
        .d_tx(d_tx),
        .vld_tx(vld_tx),
        .rdy_tx(rdy_tx)
    );

    SCAN scan_D(
        .clk(clk), .rst(rst),
        .din_rx(din_rx),
        .flag_rx(flag_rx),
        .type_rx(type_rx),
        .req_rx(req_rx),
        .ack_rx(ack_rx),
        .d_rx(d_rx),
        .vld_rx(vld_rx),
        .rdy_rx(rdy_rx)
    );

    always @(posedge clk or posedge rst) begin
        if(rst) CS <= INIT;
        else CS <= NS;
    end

    always @(*) begin
        case(CS)
            INIT: begin
                if(we) NS = SCAN;
            end
            SCAN: begin
                if (~ack_rx) NS = SCAN;
                // else if(!flag) NS = NEWA;
                // else NS = OLDA;
                else NS = PRINTA;
            end
            // OLDA: begin
            //     if(memory_rdy) NS = PRINTA;
            //     else NS = OLDA;
            // end
            // NEWA: begin
            //     if(memory_rdy) NS = PRINTA;
            //     else NS = NEWA;
            // end
            PRINTA: begin
                if (vld_tx && rdy_tx) NS = DATA;
                else NS = PRINTA;
            end
            DATA: begin
                
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