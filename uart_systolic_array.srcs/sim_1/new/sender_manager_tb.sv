`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IITGN
// Engineer: Het and Christie
// 
// Create Date: 01.07.2024 15:52:38
// Design Name: 
// Module Name: sender_manager_tb
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


module testbench;
    
    parameter ROW_A = 3;
    parameter COL_A = 3;
    parameter ROW_B = 3;
    parameter COL_B = 3;
    parameter DATA_SIZE = 8;
    
    
    
    reg clk;
    reg reset;
    reg [7:0] num;
    reg isNewData;
    reg doTransmit;
    reg [7:0] TxData;
    wire TxD;
    wire isBusy;
    wire [2*DATA_SIZE-1:0] resMatrix [0:ROW_A-1][0:COL_B-1];
    wire computeDone;
    wire initiateCompute;
    wire [DATA_SIZE-1:0] matrix_A [0:ROW_A-1][0:COL_A-1];
    wire [DATA_SIZE-1:0] matrix_B [0:ROW_B-1][0:COL_B-1];
    wire doTransmit_wire;
    wire [7:0] sum;

    // Instantiate Sender module
    sender sender (
        .clk(clk),
        .reset(reset),
        .TxD(TxD),
        .doTransmit(doTransmit),
        .TxData(TxData),
        .isBusy(isBusy)
    );

    // Instantiate Adder module
    manager_8bits #(
    .ROW_A(ROW_A),
    .COL_A(COL_A),
    .ROW_B(ROW_B),
    .COL_B(COL_B),
    .DATA_SIZE(DATA_SIZE)
    ) manager_8bits (
        .clk(clk),
        .reset(reset),
        .num(num),
        .isNewData(isNewData),
        .isBusy(isBusy),
        .resMatrix(resMatrix),
        .computeDone(computeDone),
        .initiateCompute(initiateCompute),
        .matrix_A(matrix_A),
        .matrix_B(matrix_B),
        .doTransmit(doTransmit_wire),
        .sum(sum)
    );

    // Instantiate Systolic Array module
systolic_array #(
    .ROW_A(ROW_A),
    .COL_A(COL_A),
    .ROW_B(ROW_B),
    .COL_B(COL_B),
    .DATA_SIZE(DATA_SIZE)
) systolic (
    .clk(clk),
    .reset(reset),
    .matrix_A(matrix_A),
    .matrix_B(matrix_B),
    .initiateCompute(initiateCompute),
    .computeDone(computeDone),
    .resMatrix(resMatrix)
);

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Testbench procedure
    initial begin
        // Initialize all signals
        reset = 1;
        num = 0;
        isNewData = 0;
        doTransmit = 0;
        TxData = 0;

        // Apply reset
        #10 reset = 0;

        // Provide input data to the Adder
        // Matrix A
        
        sendNumber(8'd2);
        sendNumber(8'd2);
        sendNumber(8'd2);
        
        sendNumber(8'd2);
        sendNumber(8'd2);  
        sendNumber(8'd2);
          
        sendNumber(8'd2);
        sendNumber(8'd2);
        sendNumber(8'd2);  
        
       // Matrix B
       
        sendNumber(8'd2);
        sendNumber(8'd2);
        sendNumber(8'd2);
        
        sendNumber(8'd2);
        sendNumber(8'd2);  // A[1][2]
        sendNumber(8'd2);
          
        sendNumber(8'd2);
        sendNumber(8'd2);
        sendNumber(8'd2);  // A[0][1]
        
       
        // Wait for computation to finish
        #200;

        // Transmit the results
        transmitResults();
        
        // End of simulation
        #500 $finish;
    end

    // Task to send a number to the Adder
    task sendNumber;
        input [7:0] number;
        begin
            num = number;
            isNewData = 1;
            #10;
            isNewData = 0;
            #10;
        end
    endtask

    // Task to transmit the results
    task transmitResults;
        integer i, j;
        begin
            for (i = 0; i < ROW_A; i = i + 1) begin
                for (j = 0; j < COL_B; j = j + 1) begin
                    while (isBusy) #10;
                    TxData = resMatrix[i][j][31:24]; 
                    doTransmit = 1;
                    #10 doTransmit = 0;
                    while (isBusy) #10;
                    TxData = resMatrix[i][j][23:16];
                    doTransmit = 1;
                    #10 doTransmit = 0;
                    while (isBusy) #10;
                    TxData = resMatrix[i][j][15:8];
                    doTransmit = 1;
                    #10 doTransmit = 0;
                    
                    while (isBusy) #10;
                    TxData = resMatrix[i][j][7:0];
                    doTransmit = 1;
                    #10 doTransmit = 0;
                end
            end
        end
    endtask

endmodule

