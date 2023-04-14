module ID_MOD(
    input clk_cpu,
    input rstn,
    input [31:0] pcd,
    input [31:0] ir,
    output reg [31:0] pce,
    output reg [4:0] a_addr,
    output reg [4:0] b_addr,
    output reg [31:0] imm,
    output reg [31:0] ire,            
    // output branch,           ctr[0] 1:branch 0:non-branch
    // output memread,          ctr[1] 1:read 0:no read
    // output memtoreg,         ctr[2] 1:lw 0:alu
    // output [1:0] aluop,      ctr[4:3] 00: add 01:sub 10:slli 
    // output memwrite,         ctr[5] 1:write 0:no write
    // output alusrc,           ctr[6] 1:imm 0:reg
    // output regwrite,         ctr[7] 1:write 0: no write
    output reg [31:0] ctr,
    output reg [31:0] ctrm,
    output reg [31:0] ctrw,
    output reg stall,
    input PCSrc
);
reg count; //冲掉两条指令计数器
always@(posedge clk_cpu or negedge rstn)begin
    if(~rstn) begin
        imm <= 32'h0;
        ctr <= 32'h0;
        ctrm <= 32'h0;
        ctrw <= 32'h0;
        count <= 0;
    end
    else begin
        ctrm <= ctr;
        ctrw <= ctrm;
        a_addr <= ir[19:15];
        b_addr <= ir[24:20];
        pce <= pcd;
        if(PCSrc == 1'b1) begin
            ctr[7:0] <= 8'b0000_0000;
            imm<=0;
            ire<=0;
            count<=1;
        end
        // else if(count == 1) begin
        //     ctr[7:0] <= 8'b0000_0000;
        //     imm<=0;
        //     ire<=0;
        //     count<=0;
        // end
        else begin
        ire<=ir;    
        case(ir[6:0])
        7'b0010011: begin //addi slli
            if(ire[6:0]==7'b0000011 && ire[11:7] == ir[19:15]) begin
                ctr[7:0] <= 8'b0000_0000;
                imm <= 0;
                
            end
            else begin
            case(ir[14:12])
            3'b000: //addi 
            begin
            imm <= { {20{ir[31]}}, ir[31:20] };
            ctr[7:0] <=8'b1100_0000;
            end
            3'b001: //slli
            begin
            imm <= { 27'h0, ir[24:20] };
            ctr[7:0] <= 8'b1101_0000;
            end
            
        endcase
        end

        end
        7'b0000011: //lw
        begin
            imm <= { {20{ir[31]}}, ir[31:20] };
            ctr[7:0] <= 8'b1100_0110;
        end
        7'b0100011:  //sw
        begin
            if(ire[6:0]==7'b0000011 && ire[11:7] == ir[19:15]) begin
                ctr[7:0] <= 8'b0000_0000;
                imm <= 0;
            end
            else begin
            imm <= { {20{ir[31]}}, ir[31:25], ir[11:7] };
            ctr[7:0] <= 8'b0110_0000;
            end
        end
        7'b1100011:  //beq bne blt bge bltu bgeu
        if(ire[6:0]==7'b0000011 && (ire[11:7] == ir[19:15] || ire[11:7] == ir[24:20])) begin
                ctr[7:0] <= 8'b0000_0000;
                imm <= 0;
            end
        else
        begin
            imm <= { {19{ir[31]}}, ir[31], ir[7], ir[30:25], ir[11:8], 1'b0 };
            ctr[7:0] <= 8'b0000_0001;
        end        

        7'b1101111:  //jal
        begin
            imm <= { {11{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21], 1'b0 };
            ctr[7:0] <= 8'b1000_0001;
        end
        7'b0010111: //auipc
        begin
            imm <=  {ir[31:12], 12'h0 };
            //ctr[7] <= 1'b1;
            //ctr[6] <= 1'b1;
            ctr[7:0] <= 8'b1101_1000;
        end
        7'b0110011: begin
            if(ire[6:0]==7'b0000011 && (ire[11:7] == ir[19:15] || ire[11:7] == ir[24:20])) begin
                ctr[7:0] <= 8'b0000_0000;
                imm <= 0;
            end
        else
            case(ir[30])
            0: begin //add
                //ctr[4:3] = 2'b00;
                //ctr[7] = 1'b1;
                imm <= 0;
                ctr[7:0] <= 8'b1000_0000;
            end
            1: begin //sub
                //ctr[4:3] = 2'b01;
                //ctr[7] = 1'b1;
                imm <= 0;
                ctr[7:0] <= 8'b1000_1000;
            end
        endcase
        end
endcase
end
    end
    
end
always@(*)begin
    
    
        stall = 0;
        case(ir[6:0])
        7'b0010011:  //addi slli
            if(ire[6:0]==7'b0000011 && ire[11:7] == ir[19:15]) begin
                stall = 1;
                
            end
        
        7'b0000011: //lw
        ;
    
        7'b0100011:  //sw
        
        if(ire[6:0]==7'b0000011 && (ire[11:7] == ir[19:15] || ire[11:7] == ir[24:20])) begin
                stall = 1;
            
        end
        7'b1100011:  //beq bne blt bge bltu bgeu
        if(ire[6:0]==7'b0000011 && (ire[11:7] == ir[19:15] || ire[11:7] == ir[24:20])) begin
                stall = 1;
            end    

        7'b1101111:  //jal
        ;
        7'b0010111: //auipc
        ;
        7'b0110011: 
            if(ire[6:0]==7'b0000011 && (ire[11:7] == ir[19:15] || ire[11:7] == ir[24:20]))
                stall=1;
endcase
end
    
endmodule