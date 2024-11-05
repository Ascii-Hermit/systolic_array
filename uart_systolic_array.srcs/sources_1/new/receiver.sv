`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IITGN
// Engineer: Het and Christie
// 
// Create Date: 01.07.2024 15:42:29
// Design Name: 
// Module Name: receiver
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


module receiver (
    input clk,  //input clock
    input reset,  //input reset 
    input RxD,  //input receving data line
    output reg [7:0] RxData,  // output for 8 bits data
    output reg isNewData  //indicates new value is received 
);

  parameter W5Frequency = 100_000_000;
  parameter baudRate = 9600;
  parameter samplingInterval = W5Frequency / baudRate;
  parameter halfSamplingInterval = samplingInterval / 2;

  reg [31:0] state;
  reg [31:0] counter;
  reg [7:0] data;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= 0;
      data <= 0;
      counter <= 0;
      isNewData <= 0;
      RxData <= 0;
    end else begin
      case (state)
        0: begin
          if (RxD == 0) begin
            state <= 1;
            counter <= 0; //important change not present in github code
          end
          isNewData <= 0;
        end
        1: begin
          // Starting  bit
          counter <= counter + 1;
          if (counter > halfSamplingInterval) begin
            counter <= 0;
            state <= 2;
          end
        end
        2: begin
          // The first bit receiving starts from here 
          counter <= counter + 1;
          if (counter > samplingInterval) begin
            counter <= 0;
            state <= 3;
            data[0] <= RxD;
          end
        end
        3: begin
          counter <= counter + 1;
          if (counter > samplingInterval) begin
            counter <= 0;
            state <= 4;
            data[1] <= RxD;
          end
        end
        4: begin
          counter <= counter + 1;
          if (counter > samplingInterval) begin
            counter <= 0;
            state <= 5;
            data[2] <= RxD;
          end
        end
        5: begin
          counter <= counter + 1;
          if (counter > samplingInterval) begin
            counter <= 0;
            state <= 6;
            data[3] <= RxD;
          end
        end
        6: begin
          counter <= counter + 1;
          if (counter > samplingInterval) begin
            counter <= 0;
            state <= 7;
            data[4] <= RxD;
          end
        end
        7: begin
          counter <= counter + 1;
          if (counter > samplingInterval) begin
            counter <= 0;
            state <= 8;
            data[5] <= RxD;
          end
        end
        8: begin
          counter <= counter + 1;
          if (counter > samplingInterval) begin
            counter <= 0;
            state <= 9;
            data[6] <= RxD;
          end
        end
        9: begin
          // This is the last received bit
          counter <= counter + 1;
          if (counter > samplingInterval) begin
            counter <= 0;
            state <= 10;
            data[7] <= RxD;
          end
        end
        10: begin
          // Stop bit
          counter <= counter + 1;
          if (counter > samplingInterval) begin
            counter <= 0;
            state <= 0;
            RxData <= data;
            isNewData <= 1;  // Indicate that new data has been completely received
          end
        end
        default: begin
          state <= 0;
        end
      endcase
    end
  end
endmodule
