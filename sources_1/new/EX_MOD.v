module EX_MOD (
    input clk_cpu,
    input rstn,
    input [31:0] a,
    input [31:0] b,
    input [31:0] imm,
    input [31:0] ire,
    input [31:0] ctr,
    input [31:0] pce,
    output reg [31:0] y,
    output  [31:0] Addsum,
    output reg [31:0] mdw,
    output reg [31:0] irm,
    output reg [31:0] aluout,
    output reg PCSrc
);
wire branch;
wire memread;
wire memtoreg;
wire [1:0] aluop;
wire memwrite;
wire alusrc;
wire regwrite;
assign branch = ctr[0];
assign memread = ctr[1];
assign memtoreg = ctr[2];
assign aluop = ctr[4:3];
assign memwrite = ctr[5];
assign alusrc = ctr[6];
assign regwrite = ctr[7];
assign Addsum = pce + imm;
always@(posedge clk_cpu or negedge rstn) begin
    if(~rstn) begin
        y <= 32'h0;
        mdw <= 32'h0;
        irm <= 32'h0;
    end
    else begin
    y<= aluout;    
    
    mdw <= b;
    irm <= ire;
    end
end
always@(*) begin
    aluout = 32'h0;
    PCSrc = 1'b0;
case(aluop)
        2'b00: begin //add
            case(alusrc) 
            0:
            aluout= a + b;
            1:
            aluout= a + imm;
            endcase
        end
        2'b01: begin //sub
            case(alusrc) 
            0:
            aluout= a - b;
            1:
            aluout= a - imm;
            endcase
        end
        2'b10: begin //slli
            aluout= a << imm[4:0];
        end
    endcase
        case(branch) 
        0:
        PCSrc = 1'b0;
        1:
        if(ire[14:12]==3'b000 && a==b || ire[14:12]==3'b110 && a<=b)
        PCSrc = 1'b1;
        endcase

    end
endmodule