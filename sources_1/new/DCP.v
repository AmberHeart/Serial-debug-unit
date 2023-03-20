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
    //DCP states: 0 - scan 1 - busy 
    reg CS, NS;
    always @(posedge clk) begin
        if(rst) CS <= 0;
        else CS <= NS;
    end
    
    reg [7:0] cmd; //command
    /*
    TO BE DONE: scan the command and set NS to 1
    */
    
    reg busy, finish;
    
    always@(*)
        case(CS)
            0: begin
                busy = 0;
                finish = 0;
                if(vld_rx) NS = 1;  //recieve a command
                else NS = 0;
            end
            1: begin
                busy = 1;
                if(finish) NS = 0;  //finish a command
                else NS = 1;
            end
            default: begin
                busy = 0;
                NS = 0;
                finish = 0;
            end
        endcase
    //command processing
    
    
endmodule