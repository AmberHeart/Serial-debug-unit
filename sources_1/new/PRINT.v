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
    reg [1:0] count; //count for how many Bytes left to send
    wire req_tx_ps;

    parameter [1:0] PRINT_INIT = 0,
                    PRINT_BYTE = 1,
                    PRINT_WORD = 2,
                    PRINT_WAIT = 3;
    reg [1:0] Print_State = PRINT_INIT;
    Posedge_Selector(
        .clk(clk), .rst(rst), .in(req_tx),
        .out(req_tx_ps)
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
                0: d_tx <= dout_tx[31:24];
                3: d_tx <= dout_tx[23:16];
                2: d_tx <= dout_tx[15:8];
                1: d_tx <= dout_tx[7:0];
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
