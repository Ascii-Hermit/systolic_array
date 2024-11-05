`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IITGN
// Engineer: Het and Christie
// 
// Create Date: 01.07.2024 02:57:48
// Design Name: 
// Module Name: sys_arr_tb
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

module systolic_array_tb #(
    parameter ROW_A = 3,
    parameter COL_A = 5,
    parameter ROW_B = 5,
    parameter COL_B = 2  
    );

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] matrix_A [0:ROW_A-1][0:COL_A-1];
    reg [7:0] matrix_B [0:ROW_B-1][0:COL_B-1];
    reg initiateCompute;

    // Outputs
    wire computeDone;
    wire [15:0] resMatrix [0:ROW_A-1][0:COL_B-1];

    // Instantiate the Unit Under Test (UUT)
    systolic_array #(
        .ROW_A(ROW_A),
        .COL_A(COL_A),
        .ROW_B(ROW_B),
        .COL_B(COL_B)
    ) uut (
        .clk(clk), 
        .reset(reset), 
        .matrix_A(matrix_A), 
        .matrix_B(matrix_B), 
        .initiateCompute(initiateCompute),
        .computeDone(computeDone), 
        .resMatrix(resMatrix)
    );
    // Clock generator
    always #5 clk = ~clk;
    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        initiateCompute = 0;
        
        // Initialize matrix_A and matrix_B
        
        // Wait 100 ns for global reset to finish
        #6;
        reset = 0;
        
        matrix_A[0][0] = 8'd1; matrix_A[0][1] = 8'd1; matrix_A[0][2] = 8'd1; matrix_A[0][3] = 8'd1; matrix_A[0][4] = 8'd1;
        matrix_A[1][0] = 8'd1; matrix_A[1][1] = 8'd1; matrix_A[1][2] = 8'd1; matrix_A[1][3] = 8'd1; matrix_A[1][4] = 8'd1;
        matrix_A[2][0] = 8'd1; matrix_A[2][1] = 8'd1; matrix_A[2][2] = 8'd1; matrix_A[2][3] = 8'd1; matrix_A[2][4] = 8'd1;

        matrix_B[0][0] = 8'd3; matrix_B[0][1] = 8'd3;  
        matrix_B[1][0] = 8'd3; matrix_B[1][1] = 8'd3; 
        matrix_B[2][0] = 8'd3; matrix_B[2][1] = 8'd3; 
        matrix_B[3][0] = 8'd3; matrix_B[3][1] = 8'd3; 
        matrix_B[4][0] = 8'd3; matrix_B[4][1] = 8'd3; 
        
//        matrix_A[0][0] = 8'd1; matrix_A[0][1] = 8'd2; matrix_A[0][2] = 8'd3; 
//        matrix_A[1][0] = 8'd4; matrix_A[1][1] = 8'd5; matrix_A[1][2] = 8'd6; 
//        matrix_A[2][0] = 8'd7; matrix_A[2][1] = 8'd8; matrix_A[2][2] = 8'd9; 

//        matrix_B[0][0] = 8'd1; matrix_B[0][1] = 8'd2; matrix_B[0][2] = 8'd3; 
//        matrix_B[1][0] = 8'd4; matrix_B[1][1] = 8'd5; matrix_B[1][2] = 8'd6; 
//        matrix_B[2][0] = 8'd7; matrix_B[2][1] = 8'd8; matrix_B[2][2] = 8'd9; 
               
        
        
//        matrix_A[0][0] = 8'd1; matrix_A[0][1] = 8'd2; matrix_A[0][2] = 8'd0; matrix_A[0][3] = 8'd1;
//        matrix_A[1][0] = 8'd3; matrix_A[1][1] = 8'd4; matrix_A[1][2] = 8'd0; matrix_A[1][3] = 8'd1;
//        matrix_A[2][0] = 8'd5; matrix_A[2][1] = 8'd6; matrix_A[2][2] = 8'd0; matrix_A[2][3] = 8'd1;
//        matrix_A[3][0] = 8'd7; matrix_A[3][1] = 8'd8; matrix_A[3][2] = 8'd0; matrix_A[3][3] = 8'd1;

//        matrix_B[0][0] = 8'd1; matrix_B[0][1] = 8'd2; matrix_B[0][2] = 8'd3; matrix_B[0][3] = 8'd0;
//        matrix_B[1][0] = 8'd4; matrix_B[1][1] = 8'd5; matrix_B[1][2] = 8'd6; matrix_B[1][3] = 8'd0;
//        matrix_B[2][0] = 8'd7; matrix_B[2][1] = 8'd8; matrix_B[2][2] = 8'd9; matrix_B[2][3] = 8'd0;
//        matrix_B[3][0] = 8'd0; matrix_B[3][1] = 8'd0; matrix_B[3][2] = 8'd0; matrix_B[3][3] = 8'd0;
        
        initiateCompute = 1;
        #12;
        
        // Start computation
        
       
        
        // Wait for computation to complete
        wait(computeDone);
        
        // Display results
        $display("resMatrix[0][0] = %d", resMatrix[0][0]);
        $display("resMatrix[0][1] = %d", resMatrix[0][1]);
        $display("resMatrix[0][2] = %d", resMatrix[0][2]);
        $display("resMatrix[1][0] = %d", resMatrix[1][0]);
        $display("resMatrix[1][1] = %d", resMatrix[1][1]);
        $display("resMatrix[1][2] = %d", resMatrix[1][2]);
        $display("resMatrix[2][0] = %d", resMatrix[2][0]);
        $display("resMatrix[2][1] = %d", resMatrix[2][1]);
        $display("resMatrix[2][2] = %d", resMatrix[2][2]);

        $finish;
    end
    
    
      
endmodule

