`timescale 1ns / 1ps
/* print the datapathe status */

module DCP_P#(parameter CONTROL_STATUS = 32)(
    input clk,
    input rst,
    input we,
    output finish,
    input [31:0] PC, // current pc
    input [31:0] nPC, //next pc
    input [31:0] IR, // instruction
    input [CONTROL_STATUS-1:0] ctl, // control unit
    input [31:0] A, // register A
    input [31:0] B, // register B
    input [31:0] Y, // ALU result
    input [31:0] MDR, // memory data
    // input [31:0] MAR, // memory address
    // input [31:0] SP, // stack pointer
    //print
    input rdy_tx,
    output reg vld_tx,
    output reg [7:0] d_tx
);
    /*DCP_P states:
    0 - IDLE
    1 - PRINTING NPC=
    2 - PRINTING NPC_data
    3 - PRINTING PC=   
    4 - PRINTING PC_data
    5 - PRINTING IR=
    6 - PRINTING IR_data
    7 - PRINTING CTL=
    8 - PRINTING CTL_data
    9 - PRINTING A=
    10 - PRINTING A_data
    11 - PRINTING B=
    12 - PRINTING B_data
    13 - PRINTING IMM=
    14 - PRINTING IMM_data
    15 - PRINTING Y=
    16 - PRINTING Y_data
    17 - PRINTING MDR=
    18 - PRINTING MDR_data
    */
    reg [4:0] CS, NS;
    //PRINT
    reg [31:0] data;
    reg type_tx, req_tx;
    wire ack_tx;
    //ASCII code
    reg [2:0] count;
    parameter SPACE = 32;//space ASCII code
    reg [31:0] ASCII_NPC;
    reg [31:0] ASCII_CTL;
    reg [31:0] ASCII_IMM;
    reg [31:0] ASCII_MDR;
    reg [23:0] ASCII_PC;
    reg [23:0] ASCII_IR;
    reg [15:0] ASCII_A;
    reg [15:0] ASCII_B;
    reg [15:0] ASCII_Y;
    reg type;
    reg req;
    //state machine
    always @(posedge clk)begin
        if(rst)begin
            CS <= 0;
            NS <= 0;
        end
        else begin
            CS <= NS;
        end
    end

    always@(posedge clk)begin
        case(CS)
            0:begin
                if(we)begin
                    NS <= 1;
                end
                else begin
                    data <= 0;
                    type <= 0;
                    req <= 0;
                    NS <= 0;
                    count <= 0;
                    ASCII_NPC <= 32'h4E50433D;//NPC=
                    ASCII_PC <= 32'h50433D;//PC=
                    ASCII_IR <= 32'h49523D;//IR=
                    ASCII_CTL <= 32'h43544C3D;//CTL=
                    ASCII_A <= 32'h413D;//A=
                    ASCII_B <= 32'h423D;//B=
                    ASCII_IMM <= 32'h494D4D3D;//IMM=
                    ASCII_Y <= 32'h593D;//Y=
                    ASCII_MDR <= 32'h4D44523D;//MDR=
                end
            end
            1:begin
                data[7:0] <= ASCII_NPC[31:24];
                type <= 0;
                req <= 1;
                
            end
        endcase
    end


    PRINT PRINT_P(
        .clk(clk),
        .rst(rst),
        .dout_tx(data),
        .type_tx(type_tx),
        .req_tx(req_tx),
        .ack_tx(ack_tx),
        .vld_tx(vld_tx),
        .rdy_tx(rdy_tx),
        .d_tx(d_tx)
    );

endmodule