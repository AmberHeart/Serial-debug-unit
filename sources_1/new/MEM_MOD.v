module MEM_MOD(
    input clk_cpu,
    input rstn,
    input [31:0] ctrm,
    input [31:0] y,
    input [31:0] mdw,
    input [31:0] irm,
    input [31:0] DM_read_data,
    output [31:0] DM_addr,
    output [31:0] DM_write_data,
    output reg [31:0] mdr,
    output reg [31:0] yw,
    output reg [31:0] irw
);
assign DM_addr = y;
assign DM_write_data = mdw;
always@(posedge clk_cpu or negedge rstn) begin
    if(~rstn) begin
        mdr <= 32'h0;
        yw <= 32'h0;
        irw <= 32'h0;
    end
    else begin
        yw <= y;
        irw <= irm;
        case(ctrm[1])
        0: begin
            mdr <= 0;
        end
        1: begin
            mdr <= DM_read_data;
        end
        endcase
    end
end
endmodule