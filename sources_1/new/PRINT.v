module PRINT(
    input clk_tx,
    input rst,
    input [31:0] dout_tx,
    input type_tx, //0表示字节 1表示字
    input req_tx,
    input rdy_tx,
    output reg vld_tx,
    output reg [7:0] d_tx,
    output reg ack_tx
);
    reg [2:0] count; //一个字是四个字节，计数
always @(posedge clk_tx or posedge rst) begin
    if(rst) begin
        count<=0;
        ack_tx<=0;
    end
    else
    if(req_tx) begin
        if(type_tx==0) begin
            if(rdy_tx)begin
            d_tx<=dout_tx[7:0];
            ack_tx<=1;
            end
        end
        else if(type_tx==1) begin
            if(rdy_tx) begin
                if(count==0) begin
                    d_tx<=dout_tx[7:0];///
                    count<=count+1;
                end
                else if(count==1) begin
                    d_tx<=dout_tx[15:8];
                    count<=count+1;
                end
                else if(count==2) begin
                    d_tx<=dout_tx[23:16];
                    count<=count+1;
                end
                else if(count==3) begin
                    d_tx<=dout_tx[31:24];
                    count<=0;
                    ack_tx<=1;
                end
            end
        end
        
    end
    
end
    
endmodule
