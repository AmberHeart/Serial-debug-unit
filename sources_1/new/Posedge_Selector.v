module Posedge_Selector(
    input clk, rst, in,
    output reg out
    );
    reg last;
    always @(posedge clk, posedge rst) begin
        if (rst) begin 
            out <= 0;
            last<=0;
        end
        else begin
            out <= in & !last;
            last <= in;
        end
    end
endmodule