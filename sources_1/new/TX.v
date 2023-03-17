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


module uart_tx(
    input clk_tx,
    input rst,
    input [7:0] d_tx,
    input vld_tx,
    output rdy_tx,
    output txd
);

parameter TICKS_PER_BIT = 104; // assuming 100 MHz clock frequency

reg [7:0] shift_reg;
reg [3:0] bit_cnt;
reg [TICKS_PER_BIT-1:0] tick_cnt; 
reg start_bit, stop_bit;

assign rdy_tx = (bit_cnt == 4'd0) && !vld_tx; // ready when no data is being transmitted or received
assign txd = (bit_cnt == 4'd0) ? 1'b1 : shift_reg[0]; // idle high, send LSB first

always @(posedge clk_tx) begin
    if (rst) begin // rst logic
        bit_cnt <= 4'd0;
        tick_cnt <= TICKS_PER_BIT - 1;
        start_bit <= 1'b0;
        stop_bit <= 1'b1;
        shift_reg <= 8'h00;
    end else begin // transmission logic
        if (bit_cnt == 4'd0) begin // no data is being transmitted
            if (vld_tx) begin // new data is available
                bit_cnt <= 4'd9; // set bit count to 9 (start + data + stop)
                tick_cnt <= TICKS_PER_BIT - 1; // set tick count to max value
                start_bit <= 1'b0; // set start bit to low
                stop_bit <= 1'b1; // set stop bit to high
                shift_reg <= d_tx; // load data into shift register
            end else begin // no new data is available 
                tick_cnt <= TICKS_PER_BIT - 1; // keep tick count at max value 
            end 
        end else begin // some data is being transmitted 
            if (tick_cnt == TICKS_PER_BIT - 1) begin // one bit period has elapsed 
                tick_cnt <= TICKS_PER_BIT -2 ; // rst tick count 
                case (bit_cnt) 
                    4'd9: shift_reg[7:0] <= {shift_reg[6:0], start_bit}; // send start bit 
                    4'd8: shift_reg[7:0] <= {shift_reg[6:0], d_tx[7]};   // send MSB of data 
                    4'd7: shift_reg[7:0] <= {shift_reg[6:0], d_tx[6]};
                    4'd6: shift_reg[7:0] <= {shift_reg[6:0], d_tx[5]};
                    4'd5: shift_reg[7:0] <= {shift_reg[6:0], d_tx[4]};
                    4'd4: shift_reg[7:0] <= {shift_reg[6:0], d_tx[3]};
                    4'd3: shift_reg[7:0] <= {shift_reg[6:0], d_tx[2]};
                    4'd2: shift_reg[7:0] <= {shift_reg[6:0], d_tx[1]};
                    4'd1: shift_reg[7:0] <= {shift_reg[6:0], d_tx[0]};
                    default: shift_reg[7 :0 ] <={shift_reg [6:0], stop_bit }; //send stop bit 
                endcase 
                bit_cnt <= bit_cnt - 1 ; //decrement bit count by one 
            end else begin //one bit period has not elapsed yet 
                tick_cnt <= tick_cnt - 1 ; //decrement tick count by one 
            end  
        end  
    end  
end  

endmodule 