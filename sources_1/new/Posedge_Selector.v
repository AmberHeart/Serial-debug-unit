module Posedge_Selector(
    input clk, rst, in,
    output reg out
    );
    reg last;
    always @(posedge clk, posedge rst) begin
        if (rst) out <= 0;
        else begin
            out <= in & !last;
            last <= in;
        end
    end
endmodule