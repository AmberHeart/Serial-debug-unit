`timescale 1ns / 1ps
module DCP_R(
    input clk,
    input rstn,
    input [7:0] sel_mode,
    input [7:0] CMD_R,
    output reg finish_R,
    output reg req_tx_R,
    input ack_tx,
    output reg [31:0] addr_R,
    input [31:0] dout_rf,
    output reg type_tx_R,
    output reg [31:0] dout_R
    );

    reg [1:0] curr_state;
    reg [1:0] next_state;
    parameter IDLE = 2'b00;
    parameter TEST = 2'b01;
    always@(posedge clk or negedge rstn)
    begin
        if(rstn == 0)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    wire we = sel_mode == CMD_R;
    always@(*)
    begin
        if(we)
        begin
            if(curr_state == IDLE)
                next_state = TEST;
            else if(next_state == TEST)
            begin
                if(ack_tx == 1)
                    next_state = IDLE;
                else
                    next_state = TEST;
            end
                next_state = IDLE;
        end
        else
            next_state = IDLE;
    end
    always@(posedge clk)
    begin
        if(curr_state == IDLE)
        begin
            
            finish_R <= 0;
            req_tx_R <= 0;
            type_tx_R <= 0;
            dout_R <= 0;
            addr_R <= 32'h0;
        end
        else if(curr_state == TEST)
        begin
            req_tx_R <= 1;
            type_tx_R <= 0;
            dout_R <= {24'h0000000,CMD_R};
            if(ack_tx == 1)
                finish_R <= 1;
            else
                finish_R <= 0;
        end
        else
            ;
    end
endmodule