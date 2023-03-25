module Posedge_Selector(
    input clk, rstn, in,
    output reg out
    );
    reg last;
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin 
            out <= 0;
            last<=0;
        end
        else begin
            out <= in & !last;
            last <= in;
        end
    end
endmodule