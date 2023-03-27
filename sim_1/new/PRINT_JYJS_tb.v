`timescale 1ns / 1ps

module print_tb(

);
    reg clk = 0;
    always #1 clk = ~clk;
    

    wire vld_tx, ack_tx, txd, rdy_tx;
    wire [7:0] d_tx;
    reg [31:0] dout_tx = 31'h00000031;
    reg type_tx = 1, req_tx = 0, rstn = 1;
    PRINT_J print_D(
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

    wire vld_tx_w, ack_tx_w, txd_w, rdy_tx_w;
    wire [7:0] d_tx_w;

    PRINT print_W(
        .clk(clk), .rstn(rstn),
        .dout_tx(dout_tx),
        .type_tx(type_tx),
        .req_tx(req_tx),
        .ack_tx(ack_tx_w),
        .d_tx(d_tx_w),
        .vld_tx(vld_tx_w),
        .rdy_tx(rdy_tx_w)
    );

    TX tx_W(
        .clk(clk), .rstn(rstn),
        .d_tx(d_tx_w),
        .vld_tx(vld_tx_w),
        .rdy_tx(rdy_tx_w),
        .txd(txd_w)
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
