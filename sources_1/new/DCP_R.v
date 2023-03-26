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
    output reg [31:0] dout_R,
    //test
    output [7:0] cs
    );

    reg [1:0] curr_state;
    reg [1:0] next_state;
    parameter IDLE = 2'b00;
    parameter TEST = 2'b01;
    parameter WAIT = 2'b10;
    parameter CHK = 2'b11;
    always@(posedge clk or negedge rstn)
    begin
        if(rstn == 0)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    wire we = (sel_mode == CMD_R);
    reg [1:0] cnt;
    reg [7:0] count = 8'h00;
    assign cs = count;
    always@(*)
    begin
        if(we)
        begin
            if(curr_state == IDLE)
                next_state = TEST;
            else if(curr_state == TEST)
                next_state = WAIT;
            else if(curr_state == WAIT)
            begin
                if(ack_tx == 1)
                begin
                    if(cnt == 2)
                        next_state = CHK;
                    else
                        next_state = TEST;
                end
                else
                    next_state = WAIT;
            end
            else if(curr_state == CHK)
                next_state = IDLE;
            else
                next_state = curr_state;
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
            cnt <= 0;
        end
        else if(curr_state == TEST)
        begin
            req_tx_R <= 1;
            //type_tx_R <= 0;
            cnt <= cnt + 1;
            case(cnt)
                2'b00: begin type_tx_R <= 0; dout_R <= {24'h0,CMD_R};end
                2'b01: begin type_tx_R <= 1; dout_R <= 32'h1357_9bdf;end
                default: dout_R <= 32'h0;
            endcase
        end
        else if(curr_state == WAIT)
        begin
            if(ack_tx == 1)
            begin
                req_tx_R <= 0;
            end
            else
                ;
        end
        else if(curr_state == CHK)
        begin
            cnt <= 0;
            finish_R <= 1;
            count <= count + 1;
        end
        else
            ;
    end
endmodule