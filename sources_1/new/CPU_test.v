module CPU_test(
    input clk,
    input rstn,
    input clk_cpu,
    output pc_chk,
    output [31:0] npc,
    output [31:0] pc,
    output [31:0] IR,
    output [31:0] A,
    output [31:0] B,
    output [31:0] Y,
    output [31:0] MDR,
    output [31:0] IMM,
    input [31:0] addr,
    output [31:0] dout_rf,
    output [31:0] dout_dm,
    output [31:0] dout_im,
    input [31:0] din,
    input we_dm,
    input we_im,
    input clk_ld
);
    reg pc_chk_reg;
    reg [31:0] npc_reg;
    reg [31:0] pc_reg;
    reg [31:0] IR_reg;
    reg [31:0] A_reg;
    reg [31:0] B_reg;
    reg [31:0] Y_reg;
    reg [31:0] IMM_reg;
    reg [31:0] MDR_reg;
    reg [31:0] dout_rf_reg;

    assign pc_chk = pc_chk_reg;
    assign npc = npc_reg;
    assign pc = pc_reg;
    assign IR = IR_reg;
    assign A = A_reg;
    assign B = B_reg;
    assign Y = Y_reg;
    assign MDR = MDR_reg;
    assign dout_rf = dout_rf_reg;


    dist_mem_gen_0 your_instance_name (
        .a(addr[15:0]),      // input wire [15 : 0] a
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