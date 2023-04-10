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
    reg jump=0;
    reg [31:0] npc_reg= 32'h0000_3000;
    reg [31:0] pc_reg;
    reg [31:0] ir_reg;
    reg [31:0] CTL_reg;
     //0:nothing    1:add   2:sub
     //3:auipc  4:lw   5:sw
     //6:beq    7:bltu   8:jal
     //9:slli   a:addi
    reg [31:0] A_reg;
    reg [31:0] B_reg;
    reg [31:0] Y_reg;
    reg [31:0] imm_reg;
    reg [31:0] MDR_reg;
  
    //wire clk_cpu_ps;
    // Posedge_Selector(clk,rstn,clk_cpu,clk_cpu_ps
    // //input clk, rstn, in,
    // //output reg out
    // );

    assign pc_chk = pc_reg;
    assign npc = npc_reg;
    assign pc = pc_reg;
    assign ir = ir_reg;
    assign ctr = CTL_reg;
    assign a = A_reg;
    assign b = B_reg;
    assign y = Y_reg;
    assign imm = imm_reg;
    assign pcd = 32'h0000_1001;
    assign ire = 32'h0000_1002;
    assign pce = 32'h0000_1003;
    assign irm = 32'h0000_1004;
    assign mdw = 32'h0000_1005;
    assign ctrm = 32'h0000_1006;
    assign irw = 32'h0000_1007;
    assign yw = 32'h0000_1008;
    assign mdr = 32'h0000_1009;
    assign ctrw = 32'h0000_1010;

//register
    reg [4:0] ra0,ra1,wa;
    wire [31:0] rd0,rd1;
    reg [31:0] wd;
    reg we_rf;
    reg [4:0] wa_in;
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
reg [31:0] d_dm_in;
wire [31:0] dpo_dm;
wire [7:0] a_dm_in;
wire [31:0] spo_dm;
reg [7:0] a_dm_in_1;
reg [7:0] a_dm_in_2;
reg [7:0] a_dm;
wire we_dm_in;
reg we_dm_in_1;
reg we_dm_in_2;
wire clk_dm;
assign clk_dm = (debug ? clk_ld: clk_cpu);
assign a_dm_in = (debug? a_dm_in_2 : a_dm_in_1);
assign we_dm_in = (debug ? we_dm_in_2 : we_dm_in_1);
//assign d_im = din;
DM your_dm (
  .a(a_dm_in),        // input wire [7 : 0] a
  .d(d_dm_in),        // input wire [31 : 0] d
  .dpra(dpra_dm),  // input wire [7 : 0] dpra
  .clk(clk_dm),    // input wire clk
  .we(we_dm_in),      // input wire we
  .spo(spo_dm),    // output wire [31 : 0] spo
  .dpo(dpo_dm)    // output wire [31 : 0] dpo
);
wire [31:0] dpo_im;
reg [7:0] a_im_in;
wire [31:0] spo_im;
IM your_im (
  .a(a_im_in),        // input wire [7 : 0] a
  .d(din),        // input wire [31 : 0] d
  .dpra(pc[9:2]),  // input wire [7 : 0] dpra
  .clk(clk_ld),    // input wire clk
  .we(we_im),      // input wire we
  .spo(spo_im),    // output wire [31 : 0] spo
  .dpo(dpo_im)    // output wire [31 : 0] dpo
);

    always@(posedge clk_cpu or negedge rstn)begin
        if(~rstn) begin
            pc_reg <= 32'h0000_3000; //
        end
        else 
        begin
            pc_reg <= npc_reg;
            
        end
    end
    always@(*) begin
        MDR_reg = dpo_dm;
        if(~debug) begin
            dout_dm = 32'h0000_0000;
            dout_im = 32'h0000_0000;
            dout_rf = 32'h0000_0000;
            we_dm_in_2 = 0;
            ir_reg=dpo_im;
            wd = Y_reg;
            wa_in = wa;
        case (ir_reg[6:0])
            7'b0110011:begin //add sub 
                case (ir[30])
                    0: begin //add
                        
                        imm_reg = 0;
                        jump=0;
                        A_reg = rd0;
                        B_reg = rd1;
                        Y_reg = A_reg + B_reg;
                        a_im_in = 0;
                        ra0 = ir_reg[19:15];
                        ra1 = ir_reg[24:20];
                        wa=ir_reg[11:7];
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = Y_reg;
                        CTL_reg = 32'h0000_0001;
                        a_dm_in_2 = 0;
                        npc_reg=pc_reg+4;
                        we_dm_in_1 = 0;
                        d_dm_in = 0;
                        a_dm_in_1 = 0;
                        we_rf = 1;
                    end
                    1: begin //sub
                        
                        imm_reg = 0;
                        jump=0;
                        A_reg = rd0;
                        B_reg = rd1;
                        Y_reg = A_reg - B_reg;
                        a_im_in = 0;
                        ra0 = ir_reg[19:15];
                        ra1 = ir_reg[24:20];
                        wa=ir_reg[11:7];
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = Y_reg;
                        CTL_reg = 32'h0000_0002;
                        a_dm_in_2 = 0;
                        npc_reg=pc_reg+4;
                        we_dm_in_1 = 0;
                        d_dm_in = 0;
                        a_dm_in_1 = 0;
                        we_rf = 1;
                    end
                    endcase
                    
            end
            7'b0010011: begin //addi slli
                case (ir[14:12])
                    3'b000: begin //addi
                        imm_reg = {ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                            ir_reg[31:20]};
                        jump=0;
                        A_reg = rd0;
                        B_reg = 0;
                        Y_reg = A_reg + imm_reg;
                        a_im_in = 0;
                        ra0 = ir_reg[19:15];
                        ra1 = 0;
                        wa=ir_reg[11:7];
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = Y_reg;
                        CTL_reg = 32'h0000_000a;
                        a_dm_in_2 = 0;
                        npc_reg=pc_reg+4;
                        we_dm_in_1 = 0;
                        d_dm_in = 0;
                        a_dm_in_1 = 0;
                        we_rf = 1;
                    end
                    3'b001: begin //slli
                        imm_reg = {27'h0,ir_reg[24:20]};
                        jump=0;
                        A_reg = rd0;
                        B_reg = 0;
                        Y_reg = A_reg << imm_reg;
                        a_im_in = 0;
                        ra0 = ir_reg[19:15];
                        ra1 = 0;
                        wa=ir_reg[11:7];
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = Y_reg;
                        CTL_reg = 32'h0000_0009;
                        a_dm_in_2 = 0;
                        npc_reg=pc_reg+4;
                        we_dm_in_1 = 0;
                        d_dm_in = 0;
                        a_dm_in_1 = 0;
                        we_rf = 1;
                    end
                    default: begin
                        imm_reg = 0;
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
                        we_dm_in_1 = 0;
                        d_dm_in = 0;
                        a_dm_in_1 = 0;
                        we_rf = 0;
                    end
                    endcase
            end
            

            7'b0000011: begin // lw
                imm_reg = {ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                            ir_reg[31:20]};
                jump=0;
                A_reg = rd0;
                B_reg = 0;
                Y_reg = dpo_dm;
                a_im_in = 0;
                ra0 = ir_reg[19:15];
                ra1 = 0;
                wa = ir_reg[11:7];
                a_dm = 0;
                d_dm = 0;
                dpra_dm = A_reg[9:2] + imm_reg[9:2];
                CTL_reg = 32'h0000_0004;
                a_dm_in_2 = 0;
                npc_reg=pc_reg+4;
                we_dm_in_1 = 0;
                d_dm_in = 0;
                a_dm_in_1 = 0;
                we_rf = 1;
            end
            7'b0010111: begin // auipc
                imm_reg = {ir_reg[31:12],12'h0};
                jump=0;
                A_reg = 0;
                B_reg = 0;
                Y_reg = pc_reg + imm_reg;
                a_im_in = 0;
                ra0 = 0;
                ra1 = 0;
                wa = ir_reg[11:7];
                a_dm = 0;
                d_dm = 0;
                dpra_dm = 0;
                CTL_reg = 32'h0000_0003;
                a_dm_in_2 = 0;
                npc_reg=pc_reg+4;
                we_dm_in_1 = 0;
                d_dm_in = 0;
                a_dm_in_1 = 0;
                we_rf = 1;
            end
            7'b1101111: begin // jal
                imm_reg = {ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31], ir_reg[31],
                        ir_reg[31] , ir_reg[19:12], ir_reg[20], ir_reg[30:21], 1'b0};
                jump=0;
                A_reg = 0;
                B_reg = 0;
                Y_reg = pc_reg + 4;
                a_im_in = 0;
                ra0 = 0;
                ra1 = 0;
                wa = ir_reg[11:7];
                a_dm = 0;
                d_dm = 0;
                dpra_dm = 0;
                CTL_reg = 32'h0000_0008;
                a_dm_in_2 = 0;
                npc_reg=pc_reg+imm_reg;
                we_dm_in_1 = 0;
                d_dm_in = 0;
                a_dm_in_1 = 0;
                we_rf = 1;
            end
            7'b0100011: begin // sw
                imm_reg = {ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                            ir_reg[31:25],ir_reg[11:7]};
                jump=0;
                A_reg = rd0;
                B_reg = rd1;
                Y_reg = A_reg[9:2] + imm_reg[9:2];
                a_im_in = 0;
                ra0 = ir_reg[19:15];
                ra1 = ir_reg[24:20];
                wa = 0;
                a_dm = A_reg[9:2] + imm_reg[9:2];
                d_dm = B_reg;
                dpra_dm = A_reg[9:2] + imm_reg[9:2];
                CTL_reg = 32'h0000_0005;
                a_dm_in_2 = 0;
                npc_reg=pc_reg+4;
                we_dm_in_1 = 1;
                d_dm_in = d_dm;
                a_dm_in_1 = a_dm;
                we_rf = 0;
            end
            7'b1100011: begin // beq bltu
                a_dm_in_1 = 0;
                we_rf = 0;
                case (ir[14:12])
                    3'b000: begin //beq
                        imm_reg = {ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31], ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[7] , ir_reg[30:25],ir_reg[11:8],1'b0};
                        
                        A_reg = rd0;
                        B_reg = rd1;
                        if(A_reg == B_reg) begin
                            jump=1;
                            npc_reg=pc_reg+imm_reg;
                        end
                        else begin
                            jump=0;
                            npc_reg = pc_reg+4;
                        end
                        Y_reg = 0;
                        a_im_in = 0;
                        ra0 = ir_reg[19:15];
                        ra1 = ir_reg[24:20];
                        wa = 0;
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = 0;
                        CTL_reg = 32'h0000_0006;
                        a_dm_in_2 = 0;
                        we_dm_in_1 = 0;
                        d_dm_in = 0;
                        
                    end
                    3'b110: begin //bltu
                        imm_reg = {ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31], ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],ir_reg[31],
                        ir_reg[7] , ir_reg[30:25],ir_reg[11:8],1'b0};
                        
                        A_reg = rd0;
                        B_reg = rd1;
                        Y_reg = 0;
                        if(A_reg< B_reg) begin
                            jump=1;
                            npc_reg = pc_reg + imm_reg;
                        end
                        else begin
                            jump=0;
                            npc_reg = pc_reg+4;
                        end
                        a_im_in = 0;
                        ra0 = ir_reg[19:15];
                        ra1 = ir_reg[24:20];
                        wa = 0;
                        a_dm = 0;
                        d_dm = 0;
                        dpra_dm = 0;
                        CTL_reg = 32'h0000_0007;
                        a_dm_in_2 = 0;
                        we_dm_in_1 = 0;
                        d_dm_in = 0;
                    end
                    default: begin
                        imm_reg = 0;
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
                        we_dm_in_1 = 0;
                        d_dm_in = 0;
                    end
                    endcase
            
            end


            default: begin
                imm_reg = 0;
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
                a_dm_in_2 = addr[7:0];
                npc_reg=pc_reg+4;
                we_dm_in_1 = 0;
                d_dm_in = 0;
                a_dm_in_1 = 0;
                we_rf = 0;
            end
        endcase
    end
    else begin
        ir_reg=0;
        imm_reg = 0;
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
        we_dm_in_1 = 0;
        d_dm_in = din;
        a_dm_in_1 = 0;
        we_dm_in_2 =we_dm;
        we_rf = 0;
        wd = 0;
        wa_in = 0;
    end
    end
    
endmodule
/*
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
    


//register
    reg [4:0] ra0,ra1,wa;
    wire [31:0] rd0,rd1;
    reg [31:0] wd;
    reg we_rf;
    reg [4:0] wa_in;
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
reg [31:0] d_dm_in;
wire [31:0] dpo_dm;
wire [7:0] a_dm_in;
wire [31:0] spo_dm;
reg [7:0] a_dm_in_1;
reg [7:0] a_dm_in_2;
reg [7:0] a_dm;
wire we_dm_in;
reg we_dm_in_1;
reg we_dm_in_2;
wire clk_dm;
assign clk_dm = (debug ? clk_ld: clk_cpu);
assign a_dm_in = (debug? a_dm_in_2 : a_dm_in_1);
assign we_dm_in = (debug ? we_dm_in_2 : we_dm_in_1);
//assign d_im = din;
DM your_dm (
  .a(a_dm_in),        // input wire [7 : 0] a
  .d(d_dm_in),        // input wire [31 : 0] d
  .dpra(dpra_dm),  // input wire [7 : 0] dpra
  .clk(clk_dm),    // input wire clk
  .we(we_dm_in),      // input wire we
  .spo(spo_dm),    // output wire [31 : 0] spo
  .dpo(dpo_dm)    // output wire [31 : 0] dpo
);
wire [31:0] dpo_im;
reg [7:0] a_im_in;
wire [31:0] spo_im;
IM your_im (
  .a(a_im_in),        // input wire [7 : 0] a
  .d(din),        // input wire [31 : 0] d
  .dpra(pc[9:2]),  // input wire [7 : 0] dpra
  .clk(clk_ld),    // input wire clk
  .we(we_im),      // input wire we
  .spo(spo_im),    // output wire [31 : 0] spo
  .dpo(dpo_im)    // output wire [31 : 0] dpo
);
endmodule*/