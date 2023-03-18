module SCAN(
    input clk,
    input rst,
    input [7:0] d_rx,
    input type_rx, //0表示字节 1表示字
    input req_rx,
    output reg rdy_rx,
    output reg vld_rx,
    output reg flag_rx,       //这个信号不知道怎么控制了。。。
    output reg [31:0] din_rx,
    output reg ack_rx
);
    reg [2:0] count; //一个字是四个字节，计数
always @(posedge clk or posedge rst) begin
    if(rst) begin 
        count<=0;
        ack_rx<=0;
       
    end
    else
    if(req_rx) begin
        
        if(type_rx==0) begin
            din_rx<={24'b0, d_rx};
            ack_rx<=1;
            rdy_rx<=1;
        end
        else if(type_rx==1) begin
            
                if(count==0) begin
                    din_rx[7:0]<=d_rx;
                    count<=count+1;
                    rdy_rx<=1;
                end
                else if(count==1) begin
                    din_rx[15:8]<=d_rx;
                    count<=count+1;
                    rdy_rx<=1;
                end
                else if(count==2) begin
                    din_rx[23:16]<=d_rx;
                    count<=count+1;
                    rdy_rx<=1;
                end
                else if(count==3) begin
                    din_rx[31:24]<=d_rx;
                    count<=0;
                    ack_rx<=1;
                end
            end
        end
        
    end

endmodule
