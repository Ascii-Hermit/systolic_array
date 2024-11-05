`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IITGN
// Engineer: Het and Christie
// 
// Create Date: 01.07.2024 15:40:54
// Design Name: 
// Module Name: sender
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


module sender (
    input clk, 
    input reset,
    output reg TxD, //output sending dataline
    input doTransmit, //if the sender should send or not
    input [7:0] TxData, // the data that is being sent
    output reg isBusy
);

    reg [31:0] state;
    reg [31:0] counter;
    reg [7:0] data;

    parameter W5Frequency = 100_000_000;
    parameter baudRate = 9600;
    parameter samplingInterval = W5Frequency / baudRate;
    parameter halfSamplingInterval = samplingInterval / 2;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= 0;
            data <= 0;
            counter <= 0;
            TxD <= 1;
            isBusy <= 0;
        end else begin
            case (state)
                0: begin
                    if (doTransmit == 1) begin
                        state <= 2;
                        data <= TxData;
                        isBusy <= 1;
                        counter <= 0;
                        TxD <= 0; // Start bit
                    end
                end
                2: begin
                    // The first bit sending starts from here 
                    counter <= counter + 1;
                    if (counter > samplingInterval) begin
                        counter <= 0;
                        state <= 3;
                        TxD <= data[0];
                    end
                end
                3: begin
                    counter <= counter + 1;
                    if (counter > samplingInterval) begin
                        counter <= 0;
                        state <= 4;
                        TxD <= data[1];
                    end
                end
                4: begin
                    counter <= counter + 1;
                    if (counter > samplingInterval) begin
                        counter <= 0;
                        state <= 5;
                        TxD <= data[2];
                    end
                end
                5: begin
                    counter <= counter + 1;
                    if (counter > samplingInterval) begin
                        counter <= 0;
                        state <= 6;
                        TxD <= data[3];
                    end
                end
                6: begin
                    counter <= counter + 1;
                    if (counter > samplingInterval) begin
                        counter <= 0;
                        state <= 7;
                        TxD <= data[4];
                    end
                end
                7: begin
                    counter <= counter + 1;
                    if (counter > samplingInterval) begin
                        counter <= 0;
                        state <= 8;
                        TxD <= data[5];
                    end
                end
                8: begin
                    counter <= counter + 1;
                    if (counter > samplingInterval) begin
                        counter <= 0;
                        state <= 9;
                        TxD <= data[6];
                    end
                end
                9: begin
                    // This is the last sending bit 
                    counter <= counter + 1;
                    if (counter > samplingInterval) begin
                        counter <= 0;
                        state <= 10;
                        TxD <= data[7];
                    end
                end
                10: begin
                    // Stop bit
                    counter <= counter + 1;
                    if (counter > samplingInterval) begin
                        counter <= 0;
                        state <= 11;
                        TxD <= 1; // Stop bit
                    end
                end
                11: begin
                    counter <= counter + 1;
                    if (counter > samplingInterval) begin
                        counter <= 0;
                        state <= 0;
                        isBusy <= 0;
                    end
                end
                default: state <= 0;
            endcase
        end
    end
endmodule

