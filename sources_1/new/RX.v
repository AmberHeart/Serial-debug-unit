`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/03/17 10:22:26
// Design Name: 
// Module Name: RX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx(
    input clk,
    input rst,
    input rxd,
    input rdy_rx,
    output reg [7:0] d_rx,
    output reg vld_rx
);

parameter TICKS_PER_BIT = 104; // assuming 100 MHz clock frequency

reg [7:0] shift_reg;
reg [3:0] bit_cnt;
reg [TICKS_PER_BIT-1:0] tick_cnt;
reg start_bit, stop_bit;

always @(posedge clk) begin
    if (rst) begin // rst logic
        bit_cnt <= 4'd0;
        tick_cnt <= TICKS_PER_BIT - 1;
        start_bit <= 1'b0;
        stop_bit <= 1'b1;
        shift_reg <= 8'h00;
        d_rx <= 8'h00;
        vld_rx <= 1'b0;
    end else begin // reception logic
        if (bit_cnt == 4'd0) begin // no data is being received 
            if (!rxd && rdy_rx) begin // start bit detected and ready to receive 
                bit_cnt <= 4'd9; // set bit count to 9 (start + data + stop)
                tick_cnt <= TICKS_PER_BIT /2 ; // set tick count to half of max value 
                start_bit <= rxd; // sample start bit 
                vld_rx <= 1'b0 ; //clear valid flag 
            end else begin //no start bit detected or not ready to receive 
                tick_cnt <=TICKS_PER_BIT - 1 ; //keep tick count at max value 
            end  
        end else begin //some data is being received 
            if (tick_cnt ==TICKS_PER_BIT - 1 ) begin //one bit period has elapsed 
                tick_cnt <=TICKS_PER_BIT - 1 ; //rst tick count 
                case (bit_cnt ) 
                    4 'd9 : begin//start bit expected next  
                        start_bit <=rxd ;//sample start bit  
                        if (start_bit ==1'b0 )begin//start bit is low  
                            bit_cnt <=bit_cnt - 1 ;//decrement bit count by one  
                        end  
                    end
                    default : shift_reg[7 :0 ] <={rxd ,shift_reg[7 :1 ]};//sample data bits  
                endcase  
                if (bit_cnt ==4 'd2 )begin//stop bit expected next  
                    stop_bit<=rxd;//sample stop bit  
                    d_rx<=shift_reg;//output received data  
                    vld_rx<=stop_bit;//set valid flag if stop bit is high  
                end  
                bit_cnt<=bit_cnt - 1;//decrement bit count by one  
            end else begin//one bit period has not elapsed yet  
                tick_cnt<=tick_cnt - 1;//decrement tick count by one  
            end   
        end   
    end   
end
endmodule   