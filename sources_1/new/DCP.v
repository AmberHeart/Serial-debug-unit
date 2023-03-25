`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/20 16:15:34
// Design Name: 
// Module Name: DCP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DCP(
    input clk,
    input rst,
    input [7:0] d_rx,
    input vld_rx,
    output  rdy_rx,
    output [7:0] d_tx,
    output  vld_tx,
    input rdy_tx,
    output reg clk_cpu,
    input pc_chk,
    input [31:0] npc,
    input [31:0] pc,
    input [31:0] IR,
    input [31:0] A,
    input [31:0] B,
    input [31:0] Y,
    input [31:0] MDR,
    output reg [31:0] addr, //for CPU
    input [31:0] dout_rf,
    input [31:0] dout_dm,
    input [31:0] dout_im,
    output reg [31:0] din,
    output reg we_dm,
    output reg we_im,
    output reg clk_ld
    //test part
    ,output [7:0] cs
    ,output rqs_rx
    ,output akn_rx
    );

    //instantiate SCAN and PRINT
    reg type_rx,req_rx;
    wire flag_rx,ack_rx;
    wire [31:0] din_rx;
    SCAN(
        .clk(clk), .rst(rst),
        .d_rx(d_rx),
        .vld_rx(vld_rx),   .rdy_rx(rdy_rx),
        .type_rx(type_rx), .req_rx(req_rx),
        .flag_rx(flag_rx), .ack_rx(ack_rx),
        .din_rx(din_rx)
        );
    reg type_tx,req_tx;
    reg [31:0] dout_tx;
    wire ack_tx;
    PRINT(
        .clk(clk), .rst(rst),
        .d_tx(d_tx),
        .vld_tx(vld_tx),   .rdy_tx(rdy_tx),
        .type_tx(type_tx), .req_tx(req_tx),
        .ack_tx(ack_tx),
        .dout_tx(dout_tx)
        );

    
    // FSM
    reg [7:0] sel_mode;
    reg finish;
    reg [7:0] curr_state = 0;
    reg [7:0] next_state;
    parameter INIT = 8'h00; // initialize
    parameter REQ_1ST = 8'h01; // read first character
    parameter WAIT = 8'h02; // wait for child mode
    // states for CMD
    //suggest to use CNT to read arguments
    parameter CMD_P = 8'h50; // 
    parameter CMD_R = 8'h52; //
    parameter CMD_D = 8'h44; //
    //parameter D_addr = 8'h13; 
    parameter CMD_I = 8'h49; //
    //parameter I_addr = 8'h15; //
    parameter CMD_T = 8'h54; //
    parameter CMD_B = 8'h42; //
    //parameter B_addr = 8'h18; //
    parameter CMD_G = 8'h47; //
    parameter CMD_H = 8'h48; //
    parameter CMD_L = 8'h4C; //
    parameter CMD_LI = 8'h69; //
    parameter CMD_LD = 8'h64; //

    // current state <= next state
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            curr_state <= INIT;
        else    
            curr_state <= next_state;
    end 
    // next state = f(current state,input)
    always@(*)
    begin
        case(curr_state)
            INIT: next_state = REQ_1ST;
            REQ_1ST: begin
                if(ack_rx == 1)
                begin
                    /*case(din_rx)
                        CMD_P: next_state = CMD_P;
                        CMD_D: next_state = CMD_D;
                        default: next_state = REQ_1ST;
                    endcase*/
                    next_state = WAIT;
                end
                else
                    next_state = REQ_1ST;             
            end
            //CMD_D: next_state = WAIT;
            WAIT: begin
                if(finish) //finish is a signal from child module
                    next_state = INIT;
                else
                    next_state = WAIT;
            end
            default: next_state = curr_state;
        endcase
    end
    //output <= g(current state,input)
    reg req_rx_1ST;
    reg type_rx_1ST;
    always@(posedge clk)
    begin
        if(curr_state == INIT)
        begin
            //do something to initialize
            sel_mode <= INIT;
            req_rx_1ST <= 0;
            type_rx_1ST <= 0;
        end
        else if(curr_state == REQ_1ST)
        begin
            req_rx_1ST <= 1;
            type_rx_1ST <= 0;
            if(ack_rx == 1)
            begin
                case(din_rx[7:0])  //read first character
                    CMD_D: sel_mode <= CMD_D;
                    default: sel_mode <= INIT;
                endcase
            end
        end
        else if(curr_state == WAIT)
            ;
        else
            ;
    end


    // instantiate child modules 
    //wire finish_D;
    wire req_rx_D,req_tx_D,type_rx_D,type_tx_D;
    wire [31:0] dout_D;
    wire [31:0] addr_D;
    wire finish_D;
    DCP_D(
        .clk(clk), .rst(rst),
        .sel_mode(sel_mode),
        .CMD_D(CMD_D),
        .finish_D(finish_D),
        .addr_D(addr_D),
        .din_rx(din_rx),
        .dout_dm(dout_dm),
        .ack_rx(ack_rx), .flag_rx(flag_rx),
        .ack_tx(ack_tx),
        .req_rx_D(req_rx_D), .type_rx_D(type_rx_D),
        .req_tx_D(req_tx_D), .type_tx_D(type_tx_D),
        .dout_D(dout_D)
    );

    // sel data from child modules
    always@(*) // sel print data
    begin
        case(sel_mode)
            INIT: begin
                req_rx = req_rx_1ST;
                type_rx = type_rx_1ST;
                req_tx = 0;
                type_tx = 0;
                dout_tx = 32'h0000_0000;
                addr = 32'h0000_0000;
                finish = 1;
            end
            REQ_1ST: begin
                req_rx = req_rx_1ST;
                type_rx = type_rx_1ST;

            end
            CMD_D: begin
                req_rx = req_rx_D;
                type_rx = type_rx_D;
                req_tx = req_tx_D;
                type_tx = type_tx_D;
                dout_tx = dout_D;
                addr = addr_D;
                finish = finish_D;
            end
            /*CMD_R: begin
                ack_child = ack_R;
                type_child = type_R;
                dout_child = dout_R;
                addr = addr_R;
            end*/
            default: begin
                req_rx = 0;
                type_rx = 0;
                req_tx = 0;
                type_tx = 0;
                dout_tx = 32'h0000_0000;
                addr = 32'h0000_0000;
                finish = 0;
            end
        endcase
    end

    //test part
    assign cs = curr_state;
    assign rqs_rx = req_rx;
    assign akn_rx = ack_rx;
endmodule