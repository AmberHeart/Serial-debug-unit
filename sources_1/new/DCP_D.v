`timescale 1ns / 1ps
module DCP_D(
    input clk,
    input rst,
    input we,
    output reg finish,
    input [31:0] last_addr, // the address of the last data when look up last time 
    output [31:0] end_addr, //the address of the last data when look up this time 
    input [7:0] d_rx,
    input [31:0] dout_dm, // data memory data output
    output [31:0] addr, // for CPU to read data
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
    PRINT_INF = 3'h2,
    PRINT_MAO = 3'h3,
    PRINTA = 3'h4,
    DATA = 3'h5,
    PRINTD = 3'h6,
    FINISH = 3'h7;
    reg [2:0] NS = INIT , CS = INIT;

    reg req_rx = 0, req_tx = 0, type_rx, type_tx;
    wire ack_rx, ack_tx, flag_rx;
    reg [31:0] din_rx, dout_tx;
    reg [31:0] cur_addr; //keep the address of data to print
    reg count_INFO = 0; //used for print many bytes or words
    reg [2:0] count_DATA = 0;
    reg count_FINISH = 0;

    assign addr = cur_addr;

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
        else begin
        CS <= NS;
        case (CS)
            INIT: begin
                    finish <= 0;
                    req_rx <= 0;
                    count_INFO <= 0;
            end
            SCAN: begin
                if (~ack_rx) begin
                    req_rx <= 1;
                end
                else begin
                    req_rx <= 0;
                    if(!flag_rx) cur_addr <= din_rx;
                    else cur_addr <= last_addr;
                end
            end
            PRINT_INF: begin
                if (count_INFO == 0) begin
                    if (ack_tx) begin 
                        count_INFO <= 1;
                        req_tx <= 0;
                    end
                    else req_tx <= 1;
                end
                else begin
                    if (ack_tx) begin
                        count_INFO <= 0;
                        req_tx <= 0;
                    end
                    else req_tx <= 1;
                end
            end
            PRINTA: begin
                if (ack_tx) begin
                    req_tx <= 0;
                end
                else req_tx <= 1;
            end
            DATA: begin
                count_DATA <= count_DATA + 1;
                if (|count_DATA) begin
                    cur_addr <= cur_addr + 1;
                end
            end
            PRINTD: begin
                if (ack_tx) begin
                    req_tx <= 0;
                end
                else req_tx <= 1;
            end
            FINISH: begin
                if (count_FINISH == 0) begin
                    if (ack_tx) begin 
                        count_FINISH <= 1;
                        req_tx <= 0;
                    end
                    else req_tx <= 1;
                end
                else begin
                    if (ack_tx) begin
                        count_FINISH <= 0;
                        req_tx <= 0;
                    end
                    else req_tx <= 1;
                end
            end
        endcase
        end
    end

    always @(*) begin
        case(CS)
            INIT: begin
                if(we) NS = SCAN;
            end
            SCAN: begin
                if (~ack_rx) NS = SCAN;

                else NS = PRINT_INF;
            end
            // OLDA: begin
            //     if(memory_rdy) NS = PRINTA;
            //     else NS = OLDA;
            // end
            // NEWA: begin
            //     if(memory_rdy) NS = PRINTA;
            //     else NS = NEWA;
            // end
            PRINT_INF: begin //count_INFO =0 print 'D', count_INFO = 1 print '-'
                if (count_INFO == 0) begin
                    type_tx = 0;
                    dout_tx = 32'h41;
                    NS = PRINT_INF;
                end
                else begin
                    type_tx = 0;
                    dout_tx = 32'h2D;
                    if (ack_tx) begin
                    NS = PRINTA;
                    end
                    else NS = PRINT_INF;
                end
            end
            PRINTA: begin
                dout_tx = cur_addr;
                type_tx = 1;
                if (~ack_tx) NS = PRINTA;
                else NS = PRINT_MAO;
            end
            PRINT_MAO: begin
                type_tx = 0;
                dout_tx = 32'h3A; //print ':'
                if (~ack_tx) NS = PRINT_MAO;
                else NS = DATA;
            end
            DATA: begin
                NS = PRINTD;
                type_tx = 1;
            end
            PRINTD: begin
                dout_tx = dout_dm;
                if (~ack_tx) NS = PRINTD;
                else begin
                    if (|count_DATA) begin
                        NS = DATA;
                    end
                    else NS = FINISH;
                end
            end
            FINISH: begin
                if (count_FINISH == 0) begin
                    type_tx = 0;
                    dout_tx = 32'h0d;
                    NS = FINISH;
                end
                else begin
                    type_tx = 0;
                    dout_tx = 32'h0a;
                    if (ack_tx) begin
                        NS = INIT;
                        finish = 1;
                    end
                    else NS = FINISH;
                end
            end
        endcase
    end

endmodule