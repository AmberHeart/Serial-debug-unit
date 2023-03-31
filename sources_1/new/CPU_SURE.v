module CPU_test(
    input clk,
    input rstn,
    input clk_cpu,
    output [31:0] pc_chk,
    output [31:0] npc,
    output [31:0] pc,
    output [31:0] IR,
    output [31:0] CTL,
    output [31:0] A,
    output [31:0] B,
    output [31:0] Y,
    output [31:0] MDR,
    output [31:0] IMM,
    input [31:0] addr,
    output reg [31:0] dout_rf,
    output reg [31:0] dout_dm,
    output reg [31:0] dout_im,
    input [31:0] din,
    input we_dm,
    input we_im,
    input clk_ld,
    input debug
);
    reg jump=0;
    reg [31:0] npc_reg;
    reg [31:0] pc_reg;
    reg [31:0] IR_reg;
    reg [31:0] CTL_reg;
     //0:nothing    1:add   2:sub
     //3:auipc  4:lw   5:sw
     //6:beq    7:bltu   8:jal
     //9:slli   a:addi
    reg [31:0] A_reg;
    reg [31:0] B_reg;
    reg [31:0] Y_reg;
    reg [31:0] IMM_reg;
    reg [31:0] MDR_reg;
  
    //wire clk_cpu_ps;
    // Posedge_Selector(clk,rstn,clk_cpu,clk_cpu_ps
    // //input clk, rstn, in,
    // //output reg out
    // );

    assign pc_chk = pc_reg;
    assign npc = npc_reg;
    assign pc = pc_reg;
    assign IR = IR_reg;
    assign CTL = CTL_reg;
    assign A = A_reg;
    assign B = B_reg;
    assign Y = Y_reg;
    assign IMM = IMM_reg;
    assign MDR = MDR_reg;

//register
    reg [4:0] ra0,ra1,wa;
    wire [31:0] rd0,rd1;
    reg [31:0] wd;
    reg we_rf;
    reg [4:0] wa_in;
    register_file regfile1(
        .rstn(rstn),
        .clk(clk),
        .ra0(ra0),
        .ra1(ra1),
        .rd0(rd0),
        .rd1(rd1),
        .wa(wa_in),
        .wd(wd),
        .we(we_rf)
    );


reg [7:0] dpra_dm;
reg [7:0] dpra_dm_in;
reg [31:0] d_dm;
reg [31:0] d_dm_in;
wire [31:0] dpo_dm;
wire [7:0] a_dm_in;
wire [31:0] spo_dm;
reg [7:0] a_dm_in_1;
reg [7:0] a_dm_in_2;
reg [7:0] a_dm;
reg we_dm_in;
assign a_dm_in = (debug? a_dm_in_2 : a_dm_in_1);
DM your_dm (
  .a(a_dm_in),        // input wire [7 : 0] a
  .d(d_dm_in),        // input wire [31 : 0] d
  .dpra(dpra_dm_in),  // input wire [7 : 0] dpra
  .clk(clk_ld),    // input wire clk
  .we(we_dm_in),      // input wire we
  .spo(spo_dm),    // output wire [31 : 0] spo
  .dpo(dpo_dm)    // output wire [31 : 0] dpo
);
wire [31:0] dpo_im;
reg [7:0] a_im_in;
wire [31:0] spo_im;
IM your_im (
  .a(a_im_in),        // input wire [7 : 0] a
  .d(d_im),        // input wire [31 : 0] d
  .dpra(pc[9:2]),  // input wire [7 : 0] dpra
  .clk(clk_ld),    // input wire clk
  .we(we_im),      // input wire we
  .spo(spo_im),    // output wire [31 : 0] spo
  .dpo(dpo_im)    // output wire [31 : 0] dpo
);

    always@(posedge clk_cpu or negedge rstn)begin
        if(~rstn) begin
            pc_reg <= 32'h0000_3000; //
            npc_reg <= 32'h0000_3000;
            wd <= 0;
            we_rf <= 0;
            wa_in <= 0;
            d_dm_in <= 0;
            dpra_dm_in <= 0;
            we_dm_in <= 0;
            a_dm_in_1 <= 0;
        end
        else 
        begin
            if(CTL_reg != 6 && CTL_reg != 7 && CTL_reg != 8) begin
                pc_reg <= npc_reg;
                npc_reg <= npc_reg + 4;
            end
            else if(CTL_reg == 8) begin
                pc_reg <= pc_reg  + IMM_reg;
                npc_reg <= pc_reg + 4 + IMM_reg;
            end
            else if(CTL_reg == 6 || CTL_reg == 7)
            begin
                if(jump) begin
                pc_reg <= pc_reg  + IMM_reg;
                npc_reg <= pc_reg + 4 + IMM_reg;
                end
                else begin
                pc_reg <= npc_reg;
                npc_reg <= npc_reg + 4;
                end
            end
            IR_reg<=dpo_im;
            
                case(CTL_reg) 
                    32'h1: begin //add
                        wd<=Y_reg;
                        we_rf<=1;
                        wa_in <= wa;
                    end
                    32'h2: begin //sub
                        wd<=Y_reg;
                        we_rf<=1;
                        wa_in <= wa;
                    end
                    32'ha: begin //addi
                        wd<=Y_reg;
                        we_rf<=1;
                        wa_in <= wa;
                    end
                    32'h9: begin //slli
                        wd<=Y_reg;
                        we_rf<=1;
                        wa_in <= wa;
                    end
                    32'h4: begin //lw
                        wd<=Y_reg;
                        we_rf<=1;
                        wa_in <= wa;
                        dpra_dm_in <= dpra_dm;
                    end
                    32'h3: begin //auipc
                        wd<=Y_reg;
                        we_rf<=1;
                        wa_in <= wa;
                    end
                    32'h5: begin //sw
                        d_dm_in <= d_dm;
                        we_dm_in <= 1;
                        a_dm_in_1 <= a_dm;
                    end


                endcase
        end
    end
    always@(*) begin
        if(~debug) begin
            dout_dm = 32'h0000_0000;
            dout_im = 32'h0000_0000;
            dout_rf = 32'h0000_0000;
        case (IR_reg[6:0])
            7'b0110011:begin //add sub 
                case (IR[30])
                    0: begin //add
                        ra0 = IR_reg[19:15];
                        ra1 = IR_reg[24:20];
                        A_reg = rd0;
                        B_reg = rd1;
                        Y_reg = A_reg + B_reg;
                        IMM_reg = 0;
                        wa=IR_reg[11:7];
                        CTL_reg = 32'h0000_0001;
                        jump=0;
                    end
                    1: begin //sub
                        ra0 = IR_reg[19:15];
                        ra1 = IR_reg[24:20];
                        A_reg = rd0;
                        B_reg = rd1;
                        Y_reg = A_reg - B_reg;
                        IMM_reg = 0;
                        wa=IR_reg[11:7];
                        CTL_reg = 32'h0000_0002;
                        jump=0;
                    end
                    endcase
                    
            end
            7'b0010011: begin //addi slli
                case (IR[14:12])
                    3'b000: begin //addi
                        ra0 = IR_reg[19:15];
                        A_reg = rd0;
                        B_reg = 0;
                        IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                            IR_reg[31:20]};
                        Y_reg = A_reg + IMM_reg;
                        wa=IR_reg[11:7];
                        CTL_reg = 32'h0000_000a;
                        jump=0;
                    end
                    3'b001: begin //slli
                        ra0 = IR_reg[19:15];
                        A_reg = rd0;
                        B_reg = 0;
                        IMM_reg = {27'h0,IR_reg[24:20]};
                        Y_reg = A_reg << IMM_reg;
                        wa=IR_reg[11:7];
                        CTL_reg = 32'h0000_0009;
                        jump=0;
                    end
                    endcase
            end
            

            7'b0000011: begin // lw
                wa = IR_reg[11:7];
                ra0 = IR_reg[19:15];
                A_reg = rd0;
                IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                            IR_reg[31:20]};
                B_reg = 0;
                dpra_dm = A_reg[9:2] + IMM_reg[9:2];
                Y_reg = dpo_dm;
                wa = IR_reg[11:7];
                CTL_reg = 32'h0000_0004;
                jump=0;
            end
            7'b0010111: begin // auipc
                IMM_reg = {IR_reg[31:12],12'h0};
                Y_reg = pc_reg + IMM_reg;
                wa = IR_reg[11:7];
                A_reg = 0;
                B_reg = 0;
                CTL_reg = 32'h0000_0003;
                jump=0;
            end
            7'b1101111: begin // jal
                Y_reg = pc_reg + 4;
                wa = IR_reg[11:7];
                A_reg = 0;
                B_reg = 0;
                IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31], IR_reg[31],
                        IR_reg[31] , IR_reg[19:12], IR_reg[20], IR_reg[30:21]};
                CTL_reg = 32'h0000_0008;
                jump=0;
            end
            7'b0100011: begin // sw
                ra0 = IR_reg[19:15];
                ra1 = IR_reg[24:20];
                A_reg = rd0;
                B_reg = rd1;
                IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                            IR_reg[31:25],IR_reg[11:7]};
                a_dm = A_reg[9:2] + IMM_reg[9:2];
                d_dm = B_reg;
                CTL_reg = 32'h0000_0005;
                jump=0;
                
            end
            7'b1100011: begin // beq bltu
                case (IR[14:12])
                    3'b000: begin //beq
                        CTL_reg = 32'h0000_0006;
                        ra0 = IR_reg[19:15];
                        ra1 = IR_reg[24:20];
                        A_reg = rd0;
                        B_reg = rd1;
                        if(A_reg == B_reg) jump=1;
                        else jump=0;
                        IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31], IMM_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[7] , IR_reg[30:25],IR_reg[11:8],1'b0};
                    end
                    3'b110: begin //bltu
                        CTL_reg = 32'h0000_0007;
                        ra0 = IR_reg[19:15];
                        ra1 = IR_reg[24:20];
                        A_reg = rd0;
                        B_reg = rd1;
                        if(A_reg < B_reg) jump=1;
                        else jump=0;
                        IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31], IMM_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[7] , IR_reg[30:25],IR_reg[11:8],1'b0};
                    end
                    endcase
            
            end


            default: begin
                A_reg = 32'h0000_0000;
                B_reg = 32'h0000_0000;
                IMM_reg = 32'h0000_0000;
                CTL_reg = 32'h0000_0000;//JUMP TO ITSELF
            end
        endcase
    end
    else begin
        ra0 = addr[4:0];
        dout_rf = rd0;
        a_im_in = addr[7:0];
        dout_im = spo_im;
        a_dm_in_2 = addr[7:0];
        dout_dm = spo_dm;


    end
    end
    
endmodule