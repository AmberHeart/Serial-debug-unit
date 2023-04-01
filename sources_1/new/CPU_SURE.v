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
    reg [31:0] npc_reg= 32'h0000_3000;
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
  .dpra(dpra_dm),  // input wire [7 : 0] dpra
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
            wd <= 0;
            we_rf <= 0;
            wa_in <= 0;
            d_dm_in <= 0;
            we_dm_in <= 0;
            a_dm_in_1 <= 0;
        end
        else 
        begin
            pc_reg <= npc_reg;
            
            
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
            IR_reg=dpo_im;
        case (IR_reg[6:0])
            7'b0110011:begin //add sub 
                case (IR[30])
                    0: begin //add
                        
                        IMM_reg = 0;
                        jump=0;
                        A_reg = rd0;
                        B_reg = rd1;
                        Y_reg = A_reg + B_reg;
                        a_im_in = 0;
                        ra0 = IR_reg[19:15];
                        ra1 = IR_reg[24:20];
                        wa=IR_reg[11:7];
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = 0;
                        CTL_reg = 32'h0000_0001;
                        a_dm_in_2 = 0;
                        npc_reg=pc_reg+4;
                    end
                    1: begin //sub
                        
                        IMM_reg = 0;
                        jump=0;
                        A_reg = rd0;
                        B_reg = rd1;
                        Y_reg = A_reg - B_reg;
                        a_im_in = 0;
                        ra0 = IR_reg[19:15];
                        ra1 = IR_reg[24:20];
                        wa=IR_reg[11:7];
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = 0;
                        CTL_reg = 32'h0000_0002;
                        a_dm_in_2 = 0;
                        npc_reg=pc_reg+4;
                    end
                    endcase
                    
            end
            7'b0010011: begin //addi slli
                case (IR[14:12])
                    3'b000: begin //addi
                        IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                            IR_reg[31:20]};
                        jump=0;
                        A_reg = rd0;
                        B_reg = 0;
                        Y_reg = A_reg + IMM_reg;
                        a_im_in = 0;
                        ra0 = IR_reg[19:15];
                        ra1 = 0;
                        wa=IR_reg[11:7];
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = 0;
                        CTL_reg = 32'h0000_000a;
                        a_dm_in_2 = 0;
                        npc_reg=pc_reg+4;
                    end
                    3'b001: begin //slli
                        IMM_reg = {27'h0,IR_reg[24:20]};
                        jump=0;
                        A_reg = rd0;
                        B_reg = 0;
                        Y_reg = A_reg << IMM_reg;
                        a_im_in = 0;
                        ra0 = IR_reg[19:15];
                        ra1 = 0;
                        wa=IR_reg[11:7];
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = 0;
                        CTL_reg = 32'h0000_0009;
                        a_dm_in_2 = 0;
                        npc_reg=pc_reg+4;
                    end
                    default: begin
                        IMM_reg = 0;
                        jump = 0;
                        A_reg = 32'h0000_0000;
                        B_reg = 32'h0000_0000;
                        Y_reg = 0;
                        a_im_in = 0;
                        ra0 = 0;
                        ra1 = 0;
                        wa = 0;
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = 0;
                        CTL_reg = 32'h0000_0000;//JUMP TO ITSELF
                        a_dm_in_2 = 0;
                        npc_reg=pc_reg+4;
                    end
                    endcase
            end
            

            7'b0000011: begin // lw
                IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                            IR_reg[31:20]};
                jump=0;
                A_reg = rd0;
                B_reg = 0;
                Y_reg = dpo_dm;
                a_im_in = 0;
                ra0 = IR_reg[19:15];
                ra1 = 0;
                wa = IR_reg[11:7];
                a_dm = 0;
                d_dm = 0;
                dpra_dm = A_reg[9:2] + IMM_reg[9:2];
                CTL_reg = 32'h0000_0004;
                a_dm_in_2 = 0;
                npc_reg=pc_reg+4;
            end
            7'b0010111: begin // auipc
                IMM_reg = {IR_reg[31:12],12'h0};
                jump=0;
                A_reg = 0;
                B_reg = 0;
                Y_reg = pc_reg + IMM_reg;
                a_im_in = 0;
                ra0 = 0;
                ra1 = 0;
                wa = IR_reg[11:7];
                a_dm = 0;
                d_dm = 0;
                dpra_dm = 0;
                CTL_reg = 32'h0000_0003;
                a_dm_in_2 = 0;
                npc_reg=pc_reg+4;
            end
            7'b1101111: begin // jal
                IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31], IR_reg[31],
                        IR_reg[31] , IR_reg[19:12], IR_reg[20], IR_reg[30:21]};
                jump=0;
                A_reg = 0;
                B_reg = 0;
                Y_reg = pc_reg + 4;
                a_im_in = 0;
                ra0 = 0;
                ra1 = 0;
                wa = IR_reg[11:7];
                a_dm = 0;
                d_dm = 0;
                dpra_dm = 0;
                CTL_reg = 32'h0000_0008;
                a_dm_in_2 = 0;
                npc_reg=pc_reg+IMM_reg;
            end
            7'b0100011: begin // sw
                IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                            IR_reg[31:25],IR_reg[11:7]};
                jump=0;
                A_reg = rd0;
                B_reg = rd1;
                Y_reg = 0;
                a_im_in = 0;
                ra0 = IR_reg[19:15];
                ra1 = IR_reg[24:20];
                wa = 0;
                a_dm = A_reg[9:2] + IMM_reg[9:2];
                d_dm = B_reg;
                dpra_dm = 0;
                CTL_reg = 32'h0000_0005;
                a_dm_in_2 = 0;
                npc_reg=pc_reg+4;
            end
            7'b1100011: begin // beq bltu
                case (IR[14:12])
                    3'b000: begin //beq
                        IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31], IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[7] , IR_reg[30:25],IR_reg[11:8],1'b0};
                        
                        A_reg = rd0;
                        B_reg = rd1;
                        if(A_reg == B_reg) begin
                            jump=1;
                            npc_reg=pc_reg+IMM_reg;
                        end
                        else begin
                            jump=0;
                            npc_reg = pc_reg+4;
                        end
                        Y_reg = 0;
                        a_im_in = 0;
                        ra0 = IR_reg[19:15];
                        ra1 = IR_reg[24:20];
                        wa = 0;
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = 0;
                        CTL_reg = 32'h0000_0006;
                        a_dm_in_2 = 0;
                    end
                    3'b110: begin //bltu
                        IMM_reg = {IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31], IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],IR_reg[31],
                        IR_reg[7] , IR_reg[30:25],IR_reg[11:8],1'b0};
                        
                        A_reg = rd0;
                        B_reg = rd1;
                        Y_reg = 0;
                        if(A_reg< B_reg) begin
                            jump=1;
                            npc_reg = pc_reg + IMM_reg;
                        end
                        else begin
                            jump=0;
                            npc_reg = pc_reg+4;
                        end
                        a_im_in = 0;
                        ra0 = IR_reg[19:15];
                        ra1 = IR_reg[24:20];
                        wa = 0;
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = 0;
                        CTL_reg = 32'h0000_0007;
                        a_dm_in_2 = 0;
                    end
                    default: begin
                        IMM_reg = 0;
                        jump = 0;
                        A_reg = 32'h0000_0000;
                        B_reg = 32'h0000_0000;
                        Y_reg = 0;
                        a_im_in = 0;
                        ra0 = 0;
                        ra1 = 0;
                        wa = 0;
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = 0;
                        CTL_reg = 32'h0000_0000;//JUMP TO ITSELF
                        a_dm_in_2 = 0;
                        npc_reg=pc_reg+4;
                    end
                    endcase
            
            end


            default: begin
                IMM_reg = 0;
                jump = 0;
                A_reg = 32'h0000_0000;
                B_reg = 32'h0000_0000;
                Y_reg = 0;
                a_im_in = 0;
                ra0 = 0;
                ra1 = 0;
                wa = 0;
                a_dm = 0;
                d_dm = 0;
                dpra_dm = 0;
                CTL_reg = 32'h0000_0000;//JUMP TO ITSELF
                a_dm_in_2 = 0;
                npc_reg=pc_reg+4;
            end
        endcase
    end
    else begin
        IR_reg=0;
        IMM_reg = 0;
        jump = 0;
        A_reg = 0;
        B_reg = 0;
        Y_reg = 0;
        a_im_in = addr[7:0];
        ra0 = addr[4:0];
        ra1 = 0;
        wa = 0;
        a_dm = 0;
        d_dm = 0;
        dout_rf = rd0;
        dout_im = spo_im;
        a_dm_in_2 = addr[7:0];
        dout_dm = spo_dm;
        dpra_dm = 0;
        CTL_reg = 32'h0000_0000;//JUMP TO ITSELF
        npc_reg=pc_reg+4;
    end
    end
    
endmodule