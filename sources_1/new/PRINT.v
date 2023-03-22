module PRINT(
    input clk, rst,
    input [31:0] dout_tx,
    input type_tx, //0 stand for Byte, 1 stand for Word
    input req_tx, 
    input rdy_tx,
    output reg vld_tx,
    output reg [7:0] d_tx,
    output reg ack_tx
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
    wire [63:0] dout;

    Posedge_Selector(
        .clk(clk), .rstn(rst), .in(req_tx),
        .out(req_tx_ps)
    );

    h2c hextochar (
        .clka(clk),    // input wire clka
        .addra(dout_tx[31:16]),  // input wire [15 : 0] addra
        .douta(dout[63:32]),  // output wire [31 : 0] douta
        .clkb(clk),    // input wire clkb
        .addrb(dout_tx[15:0]),  // input wire [15 : 0] addrb
        .doutb(dout[31:0])  // output wire [31 : 0] doutb
    );

    always @(posedge clk or posedge rst) begin
        if (rst) Print_State <= PRINT_INIT;
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
            case (count)
                0: d_tx <= dout[63:56];
                7: d_tx <= dout[55:48];
                6: d_tx <= dout[47:40];
                5: d_tx <= dout[39:32];
                4: begin 
                    if (underline) begin
                        d_tx <= 8'h5F;
                        underline <= 0;
                    end
                    else begin
                        d_tx <= dout[31:24];
                        underline <= 1;
                    end
                end
                3: d_tx <= dout[23:16];
                2: d_tx <= dout[15:8];
                1: d_tx <= dout[7:0];
            endcase
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
