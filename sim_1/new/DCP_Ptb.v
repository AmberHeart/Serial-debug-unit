module DCP_Ptb(

);
    reg clk=0;
    reg rstn;
    wire finish;
    reg [31:0] IMM;
    reg [31:0] pc;
    reg [31:0] npc;
    reg [31:0] IR;
    reg [31:0] CTL;
    reg [31:0] A;
    reg [31:0] B;
    reg [31:0] Y;
    reg [31:0] MDR;
    DCP_P DCP_PTB(
        .clk(clk),
        .rstn(rstn),
        .sel_mode(8'h50),
        .CMD_P(8'h50),
        .finish_P(finish),
        .IMM(IMM),
        .pc(pc),
        .npc(npc),
        .IR(IR),
        .CTL(CTL),
        .A(A),
        .B(B),
        .Y(Y),
        .MDR(MDR),
        .ack_tx(ack_tx),
        .req_tx_P(req_tx_P),
        .type_tx_P(type_tx_P),
        .dout_P(dout_P)
    );
initial begin
        rstn =1;
        IMM=32'h00000001;
        pc=32'h00000002;
        npc=32'h00000003;
        IR=32'h00000004;
        CTL=32'h00000005;
        A=32'h00000006;
        B=32'h00000007;
        Y=32'h00000008;
        MDR=32'h00000009;

        #2 rstn =0;


    end
always@(*)
begin
    #1 clk = ~clk;
end
    
endmodule