module PRINT_TX_tb(

);
reg clk =0;
reg rst =0;
always #1 clk=~clk;
wire rdy_tx, ack_tx;
wire [31:0] dout_tx;
reg type_tx=0, req_tx=0;
reg txd = 1;
wire [7:0] d_tx;
wire vld_tx;
PRINT PRINT_TB(
    .
)
endmodule