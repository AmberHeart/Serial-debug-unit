module CPU_tb();

    reg clk_cpu;
    reg rstn;
    wire [31:0] pc_chk;
    wire [31:0] npc;
    wire [31:0] pc;
    wire [31:0] ir;
    wire [31:0] pcd;
    wire [31:0] ire;
    wire [31:0] imm;
    wire [31:0] a;
    wire [31:0] b;
    wire [31:0] pce;
    wire [31:0] ctr;
    wire [31:0] irm;
    wire [31:0] mdw;
    wire [31:0] y;
    wire [31:0] ctrm;
    wire [31:0] irw;
    wire [31:0] yw;
    wire [31:0] mdr;
    wire [31:0] ctrw;
    wire [31:0] addr;
    wire [31:0] dout_rf;
    wire [31:0] dout_dm;
    wire [31:0] dout_im;
    reg [31:0] din;
    reg we_dm;
    reg we_im;
    reg clk_ld;
    reg debug;   
     CPU_PIPELINE test_CPU(
        .clk(clk),
        .rstn(rstn),
        .clk_cpu(clk_cpu),
        .pc_chk(pc_chk),
        .npc(npc),
        .pc(pc),
        .ir(ir),
        .pcd(pcd),
        .ire(ire),
        .imm(imm),
        .a(a),
        .b(b),
        .pce(pce),
        .ctr(ctr),
        .irm(irm),
        .mdw(mdw),
        .y(y),
        .ctrm(ctrm),
        .irw(irw),
        .yw(yw),
        .mdr(mdr),
        .ctrw(ctrw),
        .addr(addr),
        .dout_rf(dout_rf),
        .dout_dm(dout_dm),
        .dout_im(dout_im),
        .we_dm(we_dm),
        .we_im(we_im),
        .clk_ld(clk_ld),
        .debug(debug)
        ,.din(din)
    );
    initial begin
        clk_cpu = 0;
        #1 rstn = 1;
        #1 rstn =0;
        #1 rstn = 1;
        we_dm = 0;
        we_im = 0;
        debug = 0;
        clk_ld = 0;
        din = 0;


    end
    always @(*) begin
    forever begin
        #4;
        clk_cpu=~clk_cpu;
    end
end
endmodule