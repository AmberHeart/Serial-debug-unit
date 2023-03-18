module Posedge_Selector(
    input clk, rstn, in, st_pos,
    output reg out
    );
    reg last;
    always @(posedge clk, negedge rstn) begin
        if (st_pos) last <= 1;
        if (!rstn) out <= 0;
        else begin
            out <= in & !last;
            last <= in;
        end
    end
endmodule