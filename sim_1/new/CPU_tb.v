module CPU_tb();
    reg clk_cpu;
    reg rstn;
    wire [31:0] pc_chk;
    wire [31:0] npc;
    wire [31:0] pc;
    wire [31:0] IR;
    wire [31:0] IMM;
    wire [31:0] CTL;
    wire [31:0] A;
    wire [31:0] B;
    wire [31:0] Y;
    wire [31:0] MDR;
    wire [31:0] addr;
    wire [31:0] dout_rf;
    wire [31:0] dout_dm;
    wire [31:0] dout_im;
    wire [31:0] din;
    reg we_dm;
    reg we_im;
    reg clk_ld;
    reg debug;
    reg [31:0] data_L;
    CPU_test test_CPU(
        .clk(clk),
        .rstn(rstn),
        .clk_cpu(clk_cpu),
        .pc_chk(pc_chk),
        .npc(npc),
        .pc(pc),
        .IR(IR),
        .IMM(IMM),
        .CTL(CTL),
        .A(A),
        .B(B),
        .Y(Y),
        .MDR(MDR),
        .addr(addr),
        .dout_rf(dout_rf),
        .dout_dm(dout_dm),
        .dout_im(dout_im),
        .we_dm(we_dm),
        .we_im(we_im),
        .clk_ld(clk_ld),
        .debug(debug)
        ,.data_L(data_L)
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
        data_L = 0;


    end
    always @(*) begin
    forever begin
        #4;
        clk_cpu=~clk_cpu;
    end
end
endmodule