module CPU_PIPELINE( //流水线CPU
    input clk,
    input rstn,
    input clk_cpu,
    output  [31:0] pc_chk,    
    output  [31:0] npc,
    output  [31:0] pc,
    output  [31:0] ir,
    output  [31:0] pcd,
    output  [31:0] ire,
    output  [31:0] imm,
    output  [31:0] a,
    output  [31:0] b,
    output  [31:0] pce,
    output  [31:0] ctr,
    output  [31:0] irm,
    output  [31:0] mdw,
    output  [31:0] y,
    output  [31:0] ctrm,
    output  [31:0] irw,
    output  [31:0] yw,
    output  [31:0] mdr,
    output  [31:0] ctrw,
    input [31:0] addr,
    output [31:0] dout_rf,
    output [31:0] dout_dm,
    output [31:0] dout_im,
    input we_dm,
    input we_im,
    input clk_ld,
    input debug,
    input [31:0] din    
);

// parameter [2:0]
// IF = 3'h0,
// ID = 3'h1,
// EX = 3'h2,
// MEM = 3'h3,
// WB = 3'h4;
// reg [2:0] NS = IF , CS = IF;
// reg [31:0] pc_chk_reg = 0;
// reg [31:0] npc_reg = 32'h0000_3000;
// reg [31:0] pc_reg = 32'h0000_3000;
// reg [31:0] ir_reg = 0;
// reg [31:0] pcd_reg = 0;
// reg [31:0] ire_reg = 0;
// reg [31:0] imm_reg = 0;
// //reg [31:0] a_reg = 0;
// //reg [31:0] b_reg = 0;
// reg [31:0] pce_reg = 0;
// reg [31:0] ctr_reg = 0;
// reg [31:0] irm_reg = 0;
// reg [31:0] mdw_reg = 0;
// reg [31:0] y_reg = 0;
// reg [31:0] ctrm_reg = 0;
// reg [31:0] irw_reg = 0;
// reg [31:0] yw_reg = 0;
// reg [31:0] mdr_reg = 0;
// reg [31:0] ctrw_reg = 0;

// assign pc_chk = pc_chk_reg;
// assign npc = npc_reg;
// assign pc = pc_reg;
// assign ir = ir_reg;
// assign pcd = pcd_reg;
// assign ire = ire_reg;
// assign imm = imm_reg;
// assign pce = pce_reg;
// assign ctr = ctr_reg;
// assign irm = irm_reg;
// assign mdw = mdw_reg;
// assign y = y_reg;
// assign ctrm = ctrm_reg;
// assign irw = irw_reg;
// assign yw = yw_reg;
// assign mdr = mdr_reg;
// assign ctrw = ctrw_reg;


//register

    wire [4:0] a_addr;
    wire [4:0] b_addr;
    
    wire [4:0] ra0,ra1,wa;
    wire [31:0] rd0,rd1;
    wire [31:0] wd;
    wire we_rf;
    wire [4:0] wa_in;
    assign ra0=(debug? addr : a_addr);
    assign ra1 = b_addr;
    assign a=rd0;
    assign b=rd1;
    assign wa_in = irw[11:7];
    //wd??
    assign we_rf = ctrw[7];
    assign wd=(ctrw[2] ? mdr : yw);
    register_file regfile1(
        .rstn(rstn),
        .clk(clk_cpu),
        .ra0(ra0),
        .ra1(ra1),
        .rd0(rd0),
        .rd1(rd1),
        .wa(wa_in),
        .wd(wd),
        .we(we_rf)
    );

    
reg [7:0] dpra_dm;
reg [31:0] d_dm;
//wire [31:0] d_im ;
wire [31:0] d_dm_in;
wire [31:0] dpo_dm;
wire [7:0] a_dm_in;
wire [31:0] spo_dm;
reg [7:0] a_dm;
wire we_dm_in;
wire clk_dm;
wire [31:0] DM_read_data;
wire [31:0] DM_write_data;
wire [31:0] DM_addr;
assign clk_dm = (debug ? clk_ld: clk_cpu);
assign a_dm_in = (debug? addr[7:0] : DM_addr[9:2]);
assign d_dm_in = (debug? din : DM_write_data);
assign we_dm_in = (debug ? we_dm : ctrm[5]);
//assign d_im = din;
DM your_dm (
  .a(a_dm_in),        // input wire [7 : 0] a
  .d(d_dm_in),        // input wire [31 : 0] d
  .dpra(0),  // input wire [7 : 0] dpra
  .clk(clk_dm),    // input wire clk
  .we(we_dm_in),      // input wire we
  .spo(spo_dm),    // output wire [31 : 0] spo
  .dpo(dpo_dm)    // output wire [31 : 0] dpo
);
wire [31:0] dpo_im;
reg [7:0] a_im_in;
wire [31:0] spo_im;
IM your_im (
  .a(addr[7:0]),        // input wire [7 : 0] a
  .d(din),        // input wire [31 : 0] d
  .dpra(pcd[9:2]),  // input wire [7 : 0] dpra
  .clk(clk_ld),    // input wire clk
  .we(we_im),      // input wire we
  .spo(spo_im),    // output wire [31 : 0] spo
  .dpo(dpo_im)    // output wire [31 : 0] dpo
);

wire PCSrc;
wire [31:0] Addsum;
wire stall;
IF_MOD if_mod(
    .clk_cpu(clk_cpu),
    .rstn(rstn),
    .PCSrc(PCSrc),
    .Addsum(Addsum),
    .pcd(pcd),
    .stall(stall)
);

ID_MOD id_mod(
    .clk_cpu(clk_cpu),
    .rstn(rstn),
    .pcd(pcd),
    .ir(dpo_im),
    .pce(pce),
    .a_addr(a_addr),
    .b_addr(b_addr),
    .imm(imm),
    .ire(ire),
    .ctr(ctr),
    .ctrm(ctrm),
    .ctrw(ctrw),
    .stall(stall),
    .PCSrc(PCSrc)
);
wire [31:0] a_1;
wire [31:0] b_1;
wire [31:0] aluout;
EX_MOD ex_mod(
    .clk_cpu(clk_cpu),
    .rstn(rstn),
    .a(a_1),
    .b(b_1),
    .imm(imm),
    .ire(ire),
    .ctr(ctr),
    .pce(pce),
    .y(y),
    .Addsum(Addsum),
    .aluout(aluout),
    .PCSrc(PCSrc),
    .irm(irm),
    .mdw(mdw)

);
WRITE_FIRST write_first(
    .a_addr(a_addr),
    .b_addr(b_addr),
    .a(a),
    .b(b),
    .irw(irw),
    .wd(wd),
    .ctrw(ctrw),
    .irm(irm),
    .y(y),
    .ctrm(ctrm),
    .a_1(a_1),
    .b_1(b_1)
);
MEM_MOD mem_mod(
    .clk_cpu(clk_cpu),
    .rstn(rstn),
    .ctrm(ctrm),
    .y(y),
    .mdw(mdw),
    .irm(irm),
    .DM_read_data(spo_dm),
    .DM_write_data(DM_write_data),
    .DM_addr(DM_addr),
    .mdr(mdr),
    .yw(yw),
    .irw(irw)
);
assign ir=ire;
assign dout_dm = spo_dm;
assign dout_im = spo_im;
assign dout_rf = rd0;
assign pc = pcd;
assign npc = PCSrc? Addsum : pcd+4;
endmodule
