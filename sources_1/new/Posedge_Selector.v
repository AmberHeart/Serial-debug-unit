module Posedge_Selector(
    input clk, rstn, in,
    output reg out
    );
    reg last;
    always @(posedge clk, negedge rstn) begin
        if (!rstn) out <= 0;
        else begin
            out <= in & !last;
            last <= in;
        end
    end
endmodule