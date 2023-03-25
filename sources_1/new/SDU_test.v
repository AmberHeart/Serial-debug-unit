module SDU_test(
    input clk,
    input rst,
    //tx
    output txd,
    //rx
    output rxd,
    // for test
    output reg [7:0] scan_w,
    output [7:0] print_w,
    output req_rx,
    output ack_rx,
    output reg test_dclk
);
wire dclk;
reg [10:0] test_dclk_count=0;
always@(posedge dclk) begin
 if(dclk) test_dclk_count<=test_dclk_count+1;
    if(test_dclk_count>1024) begin
        test_dclk <=1;
    end
    else test_dclk<=0;
    
end
DIV_CLK div_clk(
    .clk(clk),
    .rstn(rst),
    .div_clk(dclk)
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
wire [31:0] dout_dm;
wire [31:0] dpo;
//1 个�?�道共享读写（等同于单口），1 个�?�道只读�?2 个输出，
//spo 数据对应 a 地址，dpo 数据对应 dpra 地址�?
//a[5:0]，读写共用的地址，当 we = 1 时表示写地址，将 d[15:0] 写入 RAM，当 we = 0 时，�? a[5:0] 地址的数据从 spo[15:0] 上输出；
//dpra[5:0] 只用于读的地�?，读�? dpra[5:0] 上的数据，从 dpo[15:0] 输出�?
dist_mem_gen_0 your_instance_name (
  .a(addr[9:0]),        // input wire [9 : 0] a
  .d(0),        // input wire [31 : 0] d
  .dpra(0),  // input wire [9 : 0] dpra
  .clk(dclk),    // input wire clk
  .we(0),      // input wire we
  .spo(dout_dm),    // output wire [31 : 0] spo
  .dpo(dpo)    // output wire [31 : 0] dpo
);
wire clk_cpu;
wire clk_ld;
wire [31:0] din;
wire we_dm;
wire we_im;

//test part
wire [7:0] cs;

DCP DCP_test(
    .clk(dclk),
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
    .clk_cpu(clk_cpu),
    .pc_chk(1),
    .pc(0),
    .npc(0),
    .IR(0),
    .A(0),
    .B(0),
    .Y(0),
    .MDR(0),
    .addr(addr),
    .dout_rf(0),
    .dout_dm(dout_dm),
    .dout_im(0),
    .clk_ld(clk_ld),
    .din(din),
    .we_dm(we_dm),
    .we_im(we_im),
    //test part
    .cs(cs),
    .rqs_rx(req_rx),
    .akn_rx(akn_rx)
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
always@(posedge clk) begin
    scan_w <= d_rx == 0? scan_w : d_rx;
    //print_w <= d_tx == 0? print_w : d_tx;
end
assign print_w = cs;
endmodule