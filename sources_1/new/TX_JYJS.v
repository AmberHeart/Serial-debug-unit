`timescale 1ns / 1ps

module uart_tx(
    input clk,
    input rstn,
    input [7:0] d_tx,
    input vld_tx,//vld需要其他模块输入，可以理解为发送使能
    output rdy_tx,//rdy只是遵循协议，其实PC不管这个
    output reg txd
);

    reg cs = 0;
    reg [7:0] SOR = 8'hff;
    reg [2:0] CNT = 0;
    reg rdy = 1;
    assign rdy_tx = rdy;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            cs <= 0;
            SOR <= 8'hff;
            CNT <= 0;
            rdy <= 1;
        end else begin
            case (cs)
                0: begin
                    if (vld_tx) begin
                        cs <= 1;
                        SOR <= d_tx;
                        txd <= 0;
                        rdy <= 0;
                    end
                    else begin 
                        rdy <= 1;
                        txd <= 1;
                        SOR <= 1;
                    end
                end
                1: begin 
                    CNT <= CNT + 1;
                    if (&CNT) begin
                        cs <= 0;
                        rdy <= 1;
                    end
                    SOR <= {1'b1, SOR[7:1]};
                    txd <= SOR[0];
                end
            endcase
        end
    end

endmodule 