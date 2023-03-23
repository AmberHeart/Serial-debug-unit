`timescale 1ns / 1ps

module print_tb(

);
    reg clk;
    always #1 clk = ~clk;
    

    wire vld_tx, ack_tx;
    wire [7:0] d_tx;
    reg [31:0] dout_tx = 31'h00000031;
    reg type_tx = 0, req_tx, rdy_tx = 1;
    PRINT print_D(
        .clk(clk), .rst(rst),
        .dout_tx(dout_tx),
        .type_tx(type_tx),
        .req_tx(req_tx),
        .ack_tx(ack_tx),
        .d_tx(d_tx),
        .vld_tx(vld_tx),
        .rdy_tx(rdy_tx)
    );

    initial begin
        #10 req_tx = 1;
        #10 req_tx = 0;
    end

endmodule