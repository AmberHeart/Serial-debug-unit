`timescale 1ns / 1ps
/* print the datapathe status */

module DCP_P(
    input clk,
    input rstn,
    input [7:0] sel_mode,
    input [7:0] CMD_P,
    output reg finish_P,
    input [31:0] IMM, // immediate
    input [31:0] pc, // current pc
    input [31:0] npc, //next pc
    input [31:0] IR, // instruction
    input [3:0] ctl, // control unit
    input [31:0] A, // register A
    input [31:0] B, // register B
    input [31:0] Y, // ALU result
    input [31:0] MDR, // memory data
    //print
    //input ack_rx,
    //input flag_rx,
    input ack_tx,
    //output reg req_rx_P,
    output type_rx_P,
    output reg req_tx_P,
    output reg type_tx_P,
    output reg [31:0] dout_P
);
    parameter [4:0]
    INIT = 5'b00000,
    PRINT_NPC = 5'b00001,
    PRINT_NPC_DATA = 5'b00010,
    PRINT_PC = 5'b00011,
    PRINT_PC_DATA = 5'b00100,
    PRINT_IR = 5'b00101,
    PRINT_IR_DATA = 5'b00110,
    PRINT_CTL = 5'b00111,
    PRINT_CTL_DATA = 5'b01000,
    PRINT_A = 5'b01001,
    PRINT_A_DATA = 5'b01010,
    PRINT_B = 5'b01011,
    PRINT_B_DATA = 5'b01100,
    PRINT_IMM = 5'b01101,
    PRINT_IMM_DATA = 5'b01110,
    PRINT_Y = 5'b01111,
    PRINT_Y_DATA = 5'b10000,
    PRINT_MDR = 5'b10001,
    PRINT_MDR_DATA = 5'b10010,
    FINISH = 5'b10011;
    /*DCP_P states:
    0 - IDLE
    1 - PRINT NPC=
    2 - PRINT NPC_data
    3 - PRINT PC=   
    4 - PRINT PC_data
    5 - PRINT IR=
    6 - PRINT IR_data
    7 - PRINT CTL=
    8 - PRINT CTL_data
    9 - PRINT A=
    10 - PRINT A_data
    11 - PRINT B=
    12 - PRINT B_data
    13 - PRINT IMM=
    14 - PRINT IMM_data
    15 - PRINT Y=
    16 - PRINT Y_data
    17 - PRINT MDR=
    18 - PRINT MDR_data
                    ASCII_NPC <= 32'h4E50433D;//NPC=
                    ASCII_PC <= 32'h50433D;//PC=
                    ASCII_IR <= 32'h49523D;//IR=
                    ASCII_CTL <= 32'h43544C3D;//CTL=
                    ASCII_A <= 32'h413D;//A=
                    ASCII_B <= 32'h423D;//B=
                    ASCII_IMM <= 32'h494D4D3D;//IMM=
                    ASCII_Y <= 32'h593D;//Y=
                    ASCII_MDR <= 32'h4D44523D;//MDR=
    */
    reg [4:0] CS=INIT, NS=INIT;
    //PRINT
    reg [2:0] count_NPC=0;
    reg [2:0] count_PC=0;
    reg [2:0] count_IR=0;
    reg [2:0] count_CTL=0;
    reg [2:0] count_A=0;
    reg [2:0] count_B=0;
    reg [2:0] count_IMM=0;
    reg [2:0] count_Y=0;
    reg [2:0] count_MDR=0;
    reg count_FINISH =0;
    wire we;
    assign we = (sel_mode == CMD_P);
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            CS<=INIT;
            finish_P<=0;
            count_NPC<=0;
            count_PC<=0;
            count_IR<=0;
            count_CTL<=0;
            count_A<=0;
            count_B<=0;
            count_IMM<=0;
            count_Y<=0;
            count_MDR<=0;
            //req_rx_P<=0;
            req_tx_P<=0;
        end
        else begin 
            CS<=NS;
            case(CS)
                INIT: begin
                    finish_P<=0;
                    count_NPC<=0;
                    count_PC<=0;
                    count_IR<=0;
                    count_CTL<=0;
                    count_A<=0;
                    count_B<=0;
                    count_IMM<=0;
                    count_Y<=0;
                    count_MDR<=0;
                    //req_rx_P<=0;
                    count_FINISH <=0;
                    
                end
                PRINT_NPC: begin
                    if(count_NPC < 3) begin
                        if(ack_tx) begin
                            count_NPC <=count_NPC + 1;
                            req_tx_P<=0;
                        end
                        else req_tx_P<=1;
                    end
                    else begin
                        if (ack_tx) begin
                            count_NPC <= 0;
                            req_tx_P <= 0;
                        end
                        else req_tx_P <= 1;
                    end
                end
                PRINT_NPC_DATA: begin
                    if(ack_tx) begin
                        req_tx_P <= 0;
                    end
                    else req_tx_P <= 1;
                end
                PRINT_PC: begin
                    if(count_PC < 2) begin
                        if(ack_tx) begin
                            count_PC <=count_PC + 1;
                            req_tx_P<=0;
                        end
                        else req_tx_P<=1;
                    end
                    else begin
                        if (ack_tx) begin
                            count_PC <= 0;
                            req_tx_P <= 0;
                        end
                        else req_tx_P <= 1;
                    end
                end
                PRINT_PC_DATA: begin
                    if(ack_tx) begin
                        req_tx_P <= 0;
                    end
                    else req_tx_P <= 1;
                end
                PRINT_IR: begin
                    if(count_IR < 2) begin
                        if(ack_tx) begin
                            count_IR <=count_IR + 1;
                            req_tx_P<=0;
                        end
                        else req_tx_P<=1;
                    end
                    else begin
                        if (ack_tx) begin
                            count_IR <= 0;
                            req_tx_P <= 0;
                        end
                        else req_tx_P <= 1;
                    end
                end
                PRINT_IR_DATA: begin
                    if(ack_tx) begin
                        req_tx_P <= 0;
                    end
                    else req_tx_P <= 1;
                end
                PRINT_CTL: begin
                    if(count_CTL < 3) begin
                        if(ack_tx) begin
                            count_CTL <=count_CTL + 1;
                            req_tx_P<=0;
                        end
                        else req_tx_P<=1;
                    end
                    else begin
                        if (ack_tx) begin
                            count_CTL <= 0;
                            req_tx_P <= 0;
                        end
                        else req_tx_P <= 1;
                    end
                end
                PRINT_CTL_DATA: begin
                    if(ack_tx) begin
                        req_tx_P <= 0;
                    end
                    else req_tx_P <= 1;
                end
                PRINT_A: begin
                    if(count_A < 1) begin
                        if(ack_tx) begin
                            count_A <=count_A + 1;
                            req_tx_P<=0;
                        end
                        else req_tx_P<=1;
                    end
                    else begin
                        if (ack_tx) begin
                            count_A <= 0;
                            req_tx_P <= 0;
                        end
                        else req_tx_P <= 1;
                    end
                end
                PRINT_A_DATA: begin
                    if(ack_tx) begin
                        req_tx_P <= 0;
                    end
                    else req_tx_P <= 1;
                end
                PRINT_B: begin
                    if(count_B < 1) begin
                        if(ack_tx) begin
                            count_B <=count_B + 1;
                            req_tx_P<=0;
                        end
                        else req_tx_P<=1;
                    end
                    else begin
                        if (ack_tx) begin
                            count_B <= 0;
                            req_tx_P <= 0;
                        end
                        else req_tx_P <= 1;
                    end
                end
                PRINT_B_DATA: begin
                    if(ack_tx) begin
                        req_tx_P <= 0;
                    end
                    else req_tx_P <= 1;
                end
                PRINT_IMM: begin
                    if(count_IMM < 3) begin
                        if(ack_tx) begin
                            count_IMM <=count_IMM + 1;
                            req_tx_P<=0;
                        end
                        else req_tx_P<=1;
                    end
                    else begin
                        if (ack_tx) begin
                            count_IMM <= 0;
                            req_tx_P <= 0;
                        end
                        else req_tx_P <= 1;
                    end
                end
                PRINT_IMM_DATA: begin
                    if(ack_tx) begin
                        req_tx_P <= 0;
                    end
                    else req_tx_P <= 1;
                end
                PRINT_Y: begin
                    if(count_Y < 1) begin
                        if(ack_tx) begin
                            count_Y <=count_Y + 1;
                            req_tx_P<=0;
                        end
                        else req_tx_P<=1;
                    end
                    else begin
                        if (ack_tx) begin
                            count_Y <= 0;
                            req_tx_P <= 0;
                        end
                        else req_tx_P <= 1;
                    end
                end
                PRINT_Y_DATA: begin
                    if(ack_tx) begin
                        req_tx_P <= 0;
                    end
                    else req_tx_P <= 1;
                end
                PRINT_MDR: begin
                    if(count_MDR < 3) begin
                        if(ack_tx) begin
                            count_MDR <=count_MDR + 1;
                            req_tx_P<=0;
                        end
                        else req_tx_P<=1;
                    end
                    else begin
                        if (ack_tx) begin
                            count_MDR <= 0;
                            req_tx_P <= 0;
                        end
                        else req_tx_P <= 1;
                    end
                end
                PRINT_MDR_DATA: begin
                    if(ack_tx) begin
                        req_tx_P <= 0;
                    end
                    else req_tx_P <= 1;
                end
                FINISH: begin
                    if(count_FINISH == 0) begin
                        if(ack_tx) begin
                            count_FINISH <= 1;
                            req_tx_P<=0;
                    end
                        else req_tx_P<=1;
                    end
                    else begin
                        if (ack_tx) begin
                            count_FINISH <= 0;
                            req_tx_P <= 0;
                        end
                        else req_tx_P <= 1;
                    end
                end
            endcase
        end
    end
    always @(*) begin
        if(~we) NS =INIT;
        else case (CS)
            INIT: begin
                if(we) NS = PRINT_NPC;
            end
            PRINT_NPC: begin //ASCII_NPC <= 32'h4E50433D;//NPC=
                if(count_NPC == 0) begin
                     NS = PRINT_NPC;
                     type_tx_P = 0;
                     dout_P=32'h4E;
                end
                else if(count_NPC == 1) begin
                    NS = PRINT_NPC;
                    type_tx_P = 0;
                    dout_P=32'h50;
                end
                else if(count_NPC == 2) begin
                    NS = PRINT_NPC;
                    type_tx_P = 0;
                    dout_P=32'h43;
                end
                else  begin
                    type_tx_P = 0;
                    dout_P=32'h3D;
                    if(ack_tx) begin
                        NS=PRINT_NPC_DATA;
                    end
                    else NS = PRINT_NPC;
                end
            end
            PRINT_NPC_DATA: begin
                
            end

            endcase
    end
endmodule