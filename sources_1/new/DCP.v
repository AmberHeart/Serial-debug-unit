`timescale 1ns / 1ps

// Debug Command Processing
module DCP#(parameter CONTROL_STATUS = 32)(
    input clk,
    input rst,
    //uart_rx
    input [7:0] d_rx,
    input vld_rx,
    output rdy_rx,
    //uart_tx
    input rdy_tx,
    output reg [7:0] d_tx,
    output reg vld_tx,
    //cpu_control
    output clk_cpu, //cpu working clock
    input pc_chk, // check current pc 
    //cpu_status:datapath
    input [31:0] PC, // current pc
    input [31:0] nPC, //next pc
    input [31:0] IR, // instruction
    input [31:0] A, // register A
    input [31:0] B, // register B
    input [CONTROL_STATUS-1:0] ctl, // control unit
    input [31:0] Y, // ALU result
    input [31:0] MDR, // memory data
    // input [31:0] MAR, // memory address
    // input [31:0] SP, // stack pointer
    //cpu_status:register file
    output [31:0] addr, // register file address(also used as memory address)
    input [31:0] dout_rf, // register file data output
    //cpu_status:Memory
    input [31:0] dout_dm, // data memory data output
    input [31:0] dout_im, // instruction memory data output
    //load_instruction
    output clk_ld,  // load instruction clock
    output [31:0] din, // data in(data or instruction, sharing address as addr)
    output we_dm, // write data enable
    output we_im  // load instruction enable
);
    //Some commands ACSII code:P、R、D、I、T、B、G、H、L
    parameter CMD_P = 80; //P
    parameter CMD_R = 82; //R
    parameter CMD_D = 68; //D
    parameter CMD_I = 73; //I
    parameter CMD_T = 84; //T
    parameter CMD_B = 66; //B
    parameter CMD_G = 71; //G
    parameter CMD_H = 72; //H
    parameter CMD_L = 76; //L

    
    reg busy, finish;
    reg [7:0] cmd; //command
    reg flag_cmd, ack_cmd; //acknowledge command
    reg we_P, we_R, we_D, we_I, we_T, we_B, we_G, we_H, we_L;

    //scan a command
    SCAN SCAN_CMD(
        .clk(clk),
        .rst(rst),
        .d_rx(d_rx),
        .vld_rx(vld_rx),
        .rdy_rx(rdy_rx),
        .type_rx(1'b0),
        .req_rx(!busy),
        .flag_rx(flag_cmd),
        .ack_rx(ack_cmd),
        .din_rx({24'b0, cmd})
    );
    
    //DCP states: 0 - scan 1 - busy 
    reg CS, NS;
    always @(posedge clk) begin
        if(rst)begin
            CS <= 0;
            NS <= 0;
        end
        else CS <= NS;
    end

    always@(*)
        case(CS)
            0: begin
                busy = 0;
                finish = 0;
                if((!flag_cmd)&&ack_cmd) NS = 1;  //recieve a command
                else NS = 0;
            end
            1: begin
                busy = 1;
                ack_cmd = 0;
                flag_cmd = 0;
                if(finish) NS = 0;  //finish a command
                else NS = 1;
            end
            default: begin
                busy = 0;
                NS = 0;
                finish = 0;
            end
        endcase
    //command process:choose a command module judge by cmd
    always@(*)
        case(cmd)
            CMD_P: we_P = 1'b1 && busy;
            CMD_R: we_R = 1'b1 && busy;
            CMD_D: we_D = 1'b1 && busy;
            CMD_I: we_I = 1'b1 && busy;
            CMD_T: we_T = 1'b1 && busy;
            CMD_B: we_B = 1'b1 && busy;
            CMD_G: we_G = 1'b1 && busy;
            CMD_H: we_H = 1'b1 && busy;
            CMD_L: we_L = 1'b1 && busy;
            default: begin
                we_P = 1'b0;
                we_R = 1'b0;
                we_D = 1'b0;
                we_I = 1'b0;
                we_T = 1'b0;
                we_B = 1'b0;
                we_G = 1'b0;
                we_H = 1'b0;
                we_L = 1'b0;
            end
        endcase
    //command module
    DCP_P DCP_P(
        .clk(clk),
        .rst(rst),
        .we(we_P),
        .finish(finish),
        .PC(PC),
        .nPC(nPC),
        .IR(IR),
        .A(A),
        .B(B),
        .ctl(ctl),
        .Y(Y),
        .MDR(MDR),
        .rdy_tx(rdy_tx),
        .vld_tx(vld_tx),
        .d_tx(d_tx)
    );

    
endmodule