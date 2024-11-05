`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IITGN
// Engineer: Het and Christie
// 
// Create Date: 01.07.2024 15:50:56
// Design Name: 
// Module Name: main
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

module main#(
    parameter ROW_A = 3,
    parameter COL_A = 3,
    parameter ROW_B = 3,
    parameter COL_B = 3,
    parameter DATA_SIZE = 8 // Set default data size to 8 bits, can be up to 64 bits
) (
    input clk,  //input clock
    input reset,  //input reset 
    input RxD,  //input receiving data line
    output TxD,
    output isNewData
);
    wire [7:0] sum;
    wire [7:0] RxData;
    wire doTransmit;
    wire isBusy;
    wire initiateCompute;
    wire computeDone;

    reg [DATA_SIZE-1:0] matrix_A[0:ROW_A-1][0:COL_A-1];
    reg [DATA_SIZE-1:0] matrix_B[0:ROW_B-1][0:COL_B-1];
    reg [2*DATA_SIZE-1:0] resMatrix[0:ROW_A-1][0:COL_B-1];

    receiver receiver (
        .clk(clk),
        .reset(reset),
        .RxD(RxD),
        .RxData(RxData),
        .isNewData(isNewData)
    );

    manager_8bits#(
        .ROW_A(ROW_A),
        .COL_A(COL_A),
        .ROW_B(ROW_B),
        .COL_B(COL_B),
        .DATA_SIZE(DATA_SIZE)
    ) manager_8bits (
        .clk(clk),
        .reset(reset),
        .num(RxData),
        .isNewData(isNewData),
        .doTransmit(doTransmit),
        .matrix_A(matrix_A),
        .initiateCompute(initiateCompute),
        .matrix_B(matrix_B),
        .resMatrix(resMatrix),
        .sum(sum),
        .computeDone(computeDone),
        .isBusy(isBusy)
    );

    systolic_array #(
        .ROW_A(ROW_A),
        .COL_A(COL_A),
        .ROW_B(ROW_B),
        .COL_B(COL_B),
        .DATA_SIZE(DATA_SIZE)
    ) systolic_array_inst (
        .clk(clk),
        .reset(reset),
        .matrix_A(matrix_A),
        .matrix_B(matrix_B),
        .computeDone(computeDone),
        .initiateCompute(initiateCompute),
        .resMatrix(resMatrix)   
    );

    sender sender (
        .clk(clk),
        .reset(reset),
        .TxD(TxD),
        .doTransmit(doTransmit),
        .TxData(sum),
        .isBusy(isBusy)
    );

endmodule
