`timescale 1ns / 1ps

module print_tb(

);
    reg clk = 0;
    always #1 clk = ~clk;
    

    wire vld_tx, ack_tx, txd, rdy_tx;
    wire [7:0] d_tx;
    reg [31:0] dout_tx = 31'h00000031;
    reg type_tx = 0, req_tx = 0, rstn = 1;
    PRINT print_D(
        .clk(clk), .rstn(rstn),
        .dout_tx(dout_tx),
        .type_tx(type_tx),
        .req_tx(req_tx),
        .ack_tx(ack_tx),
        .d_tx(d_tx),
        .vld_tx(vld_tx),
        .rdy_tx(rdy_tx)
    );

    uart_tx tx(
        .clk(clk), .rstn(rstn),
        .d_tx(d_tx),
        .vld_tx(vld_tx),
        .rdy_tx(rdy_tx),
        .txd(txd)
    );

    initial begin
        #10 rstn = 0;
        #2 rstn = 1;
        #20 req_tx = 1;
        #10 req_tx = 0;
        #1000 $finish;
    end
initial
begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, print_tb);    //tb模块名称
end



endmodule

module Posedge_Selector(
    input clk, rstn, in,
    output reg out
    );
    reg last;
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin 
            out <= 0;
            last<=0;
        end
        else begin
            out <= in & !last;
            last <= in;
        end
    end
endmodule

module PRINT(
    input clk, rstn,
    input [31:0] dout_tx,   //data to be printed (from DCP)
    input type_tx,          //0 stand for Byte, 1 stand for Word (from DCP)
    input req_tx,           //request to send (from DCP)
    input rdy_tx,           //ready to send (from tx)
    output reg vld_tx,      //valid to send (to tx)
    output reg [7:0] d_tx,  //data to send (to tx)
    output reg ack_tx       //acknowledge to send (to DCP)
);
    reg [2:0] count = 0; //count for how many Bytes left to send
    reg underline = 1;  //whether to output the underline
    wire req_tx_ps; //positive edge selector for req_tx

    //finite state machine
    parameter [1:0] PRINT_INIT = 0,
                    PRINT_BYTE = 1,
                    PRINT_WORD = 2,
                    PRINT_WAIT = 3;
    reg [1:0] Print_State = PRINT_INIT;

    //h2c module variables
    // wire [63:0] dout;

    Posedge_Selector ps(
        .clk(clk), .rstn(rstn), .in(req_tx),
        .out(req_tx_ps)
    );

    // h2c hextochar (
    //     .clka(clk),    // input wire clka
    //     .addra(dout_tx[31:16]),  // input wire [15 : 0] addra
    //     .douta(dout[63:32]),  // output wire [31 : 0] douta
    //     .clkb(clk),    // input wire clkb
    //     .addrb(dout_tx[15:0]),  // input wire [15 : 0] addrb
    //     .doutb(dout[31:0])  // output wire [31 : 0] doutb
    // );

    always @(posedge clk or negedge rstn) begin
        if (~rstn) Print_State <= PRINT_INIT;
        else begin
            case (Print_State)
                PRINT_INIT: begin
                    if (req_tx_ps) 
                        if (~type_tx) Print_State <= PRINT_BYTE;
                        else Print_State <= PRINT_WORD;
                end
                PRINT_BYTE: begin
                    Print_State <= PRINT_WAIT;
                end
                PRINT_WORD: begin
                    Print_State <= PRINT_WAIT;
                end
                PRINT_WAIT: begin
                    if (rdy_tx && ~|count) Print_State <= PRINT_INIT;
                end
            endcase
        end
    end

always @(posedge clk) begin
    case (Print_State) 
        PRINT_INIT: begin
            vld_tx <= 0;
            d_tx <= 0;
            ack_tx <= 0;
            count <= 0;
        end
        PRINT_BYTE: begin
            vld_tx <= 1;
            d_tx <= dout_tx[7:0];
            ack_tx <= 0;
            count <= 0;
        end
        PRINT_WORD: begin
            vld_tx <= 1;
            ack_tx <= 0;
            count <= count - 1;
            // case (count)
            //     0: d_tx <= dout[63:56];
            //     7: d_tx <= dout[55:48];
            //     6: d_tx <= dout[47:40];
            //     5: d_tx <= dout[39:32];
            //     4: begin 
            //         if (underline) begin
            //             d_tx <= 8'h5F;
            //             underline <= 0;
            //         end
            //         else begin
            //             d_tx <= dout[31:24];
            //             underline <= 1;
            //         end
            //     end
            //     3: d_tx <= dout[23:16];
            //     2: d_tx <= dout[15:8];
            //     1: d_tx <= dout[7:0];
            // endcase
        end
        PRINT_WAIT: begin
            if (rdy_tx) begin
                vld_tx <= 1;
                if (count == 0) ack_tx <= 1;
            end
        end
    endcase
end
    
endmodule

module uart_tx(
    input clk,
    input rstn,
    input [7:0] d_tx,
    input vld_tx,//vld需要其他模块输入，可以理解为发送使能
    output rdy_tx,//rdy只是遵循协议，其实PC不管这个
    output reg txd
);

    reg cs = 0;
    reg [7:0] SOR = 8'hff;
    reg [2:0] CNT = 0;
    reg rdy = 1;
    assign rdy_tx = rdy;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cs <= 0;
            SOR <= 8'hff;
            CNT <= 0;
            rdy <= 1;
        end else begin
            case (cs)
                0: begin
                    if (vld_tx) begin
                        cs <= 1;
                        SOR <= d_tx;
                        txd <= 0;
                        rdy <= 0;
                    end
                    else begin 
                        rdy <= 1;
                        txd <= 1;
                        SOR <= 1;
                    end
                end
                1: begin 
                    CNT <= CNT + 1;
                    if (&CNT) begin
                        cs <= 0;
                        rdy <= 1;
                    end
                    SOR <= {1'b1, SOR[7:1]};
                    txd <= SOR[0];
                end
            endcase
        end
    end

endmodule 