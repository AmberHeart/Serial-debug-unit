module scan_print_test(
    input clk,
    input rst,
    //tx
    output txd,
    //rx
    output rxd,
    // for test
    output reg [7:0] scan_w,
    output reg [7:0] print_w
 
);
wire d_rx;
wire d_tx;
reg d_tx_reg;
wire rdy_rx;
wire vld_tx;
reg vld_rx;
reg rdy_tx;
DIV_CLK div_clk(
    .clk(clk),
    .rstn(rst),
    .div_clk(dclk)
);
RX rx_test(
    .clk(dclk),
    .rstn(!rst),
    .rxd(rxd),
    .d_rx(d_rx),
    .vld_rx(vld_rx),
    .rdy_rx(rdy_rx)
);
uart_tx tx_test(
    .clk(dclk),
    .rst(rst),
    .d_tx(d_tx),
    .vld_tx(vld_tx),
    .rdy_tx(rdy_tx),
    .txd(txd)
);
reg [32:0] count;
always@(posedge dclk) begin
    scan_w <= d_rx;
    print_w <= d_tx;
    d_tx_reg=d_rx;
    if(count==0) begin
        vld_rx=~vld_rx;
        rdy_tx=~rdy_tx;
    end
end
assign d_tx=d_tx_reg;
endmodule