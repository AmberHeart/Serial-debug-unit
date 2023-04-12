module WRITE_FIRST(
    input [4:0] a_addr,
    input [4:0] b_addr,
    input [31:0] a,
    input [31:0] b,
    input [31:0] irw,
    input [31:0] wd,
    input [31:0] ctrw,
    input [31:0] irm,
    input [31:0] y,
    input [31:0] ctrm,
    output reg [31:0] a_1,
    output reg [31:0] b_1

    );
always@(*) begin
    a_1 = a;
    b_1 = b;
    if(irm[11:7] == a_addr && ctrm[7] && ~ctrm[2] )
        a_1 = y;
    else if(irw[11:7]==a_addr && ctrw[7])
        a_1 = wd;
    if(irm[11:7] == b_addr && ctrm[7] && ~ctrm[2] )
        b_1 = y;
    else if(irw[11:7]==b_addr && ctrw[7])
        b_1 = wd;
end
endmodule