module SDU_test(
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

//tx
wire [7:0] d_tx;
wire vld_tx;
wire rdy_tx;
//rx
wire [7:0] d_rx;
wire vld_rx;
wire rdy_rx;
//cpu
wire [31:0] addr;
wire dout_dm;
//1 个通道共享读写（等同于单口），1 个通道只读，2 个输出，
//spo 数据对应 a 地址，dpo 数据对应 dpra 地址；
//a[5:0]，读写共用的地址，当 we = 1 时表示写地址，将 d[15:0] 写入 RAM，当 we = 0 时，将 a[5:0] 地址的数据从 spo[15:0] 上输出；
//dpra[5:0] 只用于读的地址，读出 dpra[5:0] 上的数据，从 dpo[15:0] 输出。
dist_mem_gen_0 your_instance_name (
  .a(addr[9:0]),        // input wire [9 : 0] a
  .d(0),        // input wire [31 : 0] d
  .dpra(0),  // input wire [9 : 0] dpra
  .clk(clk),    // input wire clk
  .we(0),      // input wire we
  .spo(dout_dm)    // output wire [31 : 0] spo
  //.dpo(dpo)    // output wire [31 : 0] dpo
);
DCP DCP_test(
    .clk(clk),
    .rst(rst),
    //rx
    .d_rx(d_rx),
    .vld_rx(vld_rx),
    .rdy_rx(rdy_rx),
    //tx
    .d_tx(d_tx),
    .vld_tx(vld_tx),
    .rdy_tx(rdy_tx),
    //cpu
    //.clk_cpu(clk_cpu),
    .pc_chk(1),
    .PC(0),
    .nPC(0),
    .IR(0),
    .A(0),
    .B(0),
    .ctl(0),
    .Y(0),
    .MDR(0),
    .addr(addr),
    .dout_rf(0),
    .dout_dm(dout_dm),
    .dout_im(0)
    //.clk_ld(clk_ld),
    //.din(din),
    //.we_dm(we_dm),
    //.we_im(we_im)
);
uart_rx rx_test(
    .clk(clk),
    .rst(rst),
    .rxd(rxd),
    .d_rx(d_rx),
    .vld_rx(vld_rx),
    .rdy_rx(rdy_rx)
);
uart_tx tx_test(
    .clk(clk),
    .rst(rst),
    .d_tx(d_tx),
    .vld_tx(vld_tx),
    .rdy_tx(rdy_tx),
    .txd(txd)
);
always@(*) begin
    scan_w = d_rx;
    print_w = d_tx;
end
endmodule