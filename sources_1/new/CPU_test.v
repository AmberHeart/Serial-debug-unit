module CPU_test(
    input clk,
    input rstn,
    input clk_cpu,
    output [31:0] pc_chk,
    output [31:0] npc,
    output [31:0] pc,
    output [31:0] ir,
    output [31:0] pcd,
    output [31:0] ire,
    output [31:0] imm,
    output [31:0] a,
    output [31:0] b,
    output [31:0] pce,
    output [31:0] ctr,
    output [31:0] irm,
    output [31:0] mdw,
    output [31:0] y,
    output [31:0] ctrm,
    output [31:0] irw,
    output [31:0] yw,
    output [31:0] mdr,
    output [31:0] ctrw,
    input [31:0] addr,
    output reg [31:0] dout_rf,
    output reg [31:0] dout_dm,
    output reg [31:0] dout_im,
    input we_dm,
    input we_im,
    input clk_ld,
    input debug,
    input [31:0] din
);
    
    //wire clk_cpu_ps;
    // Posedge_Selector(clk,rstn,clk_cpu,clk_cpu_ps
    // //input clk, rstn, in,
    // //output reg out
    // );
assign pc_chk=pce;
assign npc=32'h0000_0000;
assign pc=32'h0000_0001;
assign ir=32'h0000_0002;
assign pcd=32'h0000_0003;
assign ire=32'h0000_0004;
assign imm=32'h0000_0005;
assign a=32'h0000_0006;
assign b=32'h0000_0007;
assign pce=32'h0000_0008;
assign ctr=32'h0000_0009;
assign irm=32'h0000_000a;
assign mdw=32'h0000_000b;
assign y=32'h0000_000c;
assign ctrm=32'h0000_000d;
assign irw=32'h0000_000e;
assign yw=32'h0000_000f;
assign mdr=32'h0000_0010;
assign ctrw=32'h0000_0011;
    


    dist_mem_gen_0 your_instance_name (
        .a(addr[9:0]),      // input wire [9 : 0] a
        .clk(clk_ld),  // input wire clk
        .we(we_dm),    // input wire we
        .spo(dout_dm),  // output wire [31 : 0] spo
        .d(0)     // input wire [31 : 0] d
        );
    test_text text (
        .a(addr[9:0]),      // input wire [9 : 0] a
        .d(0),      // input wire [31 : 0] d
        .clk(clk_ld),  // input wire clk
        .we(we_im),    // input wire we
        .spo(dout_im)  // output wire [31 : 0] spo
        );
endmodule