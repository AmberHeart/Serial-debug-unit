module IF_MOD(
    input clk_cpu,
    input rstn,
    input PCSrc, //PC源选择 0：PC+4 1：Addsum
    input [31:0] Addsum,
    output [31:0] pcd,
    input stall
);
reg [31:0] pc=32'h0000_3000;
assign pcd = pc;
always@(posedge clk_cpu or negedge rstn) begin
    if(~rstn)begin
        pc <= 32'h0000_3000;
    end
    else begin
        if(stall) begin
            pc <= pc;
        end
        else
        if(PCSrc == 1'b0)begin
            pc <= pc + 4;
        end
        else begin
            pc <= Addsum;
        end
    end
end
endmodule