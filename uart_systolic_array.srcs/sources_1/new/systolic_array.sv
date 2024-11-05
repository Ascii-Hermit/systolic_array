`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IITGN
// Engineer: Het and Christie
// 
// Create Date: 29.06.2024 00:17:51
// Design Name: 
// Module Name: systolic_array
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

// THE BELOW CODE ONLY WORKS UNDER THE ASSUMPTION THAT THE 
// MATRIX MULTIPLICATION OF THE GIVEN MATRICES IS MATHEMATICALLY POSSIBLE

module systolic_array#(  
    parameter ROW_A = 3,
    parameter COL_A = 3,
    parameter ROW_B = 3,
    parameter COL_B = 3,
    parameter DATA_SIZE = 8
    // specify the dimesions of the 2 matrices
    )(
    input clk,
    input reset,
    input [DATA_SIZE-1:0] matrix_A [0:ROW_A-1][0:COL_A-1],// first matrix being multiplied
    input [DATA_SIZE-1:0] matrix_B [0:ROW_B-1][0:COL_B-1],// second matrix to be multiplied
    input initiateCompute,  // to make the systolic array start computation
    output reg computeDone, // to notify once the systolic array computation is done 
    output reg [2*DATA_SIZE-1:0] resMatrix [0:ROW_A-1][0:COL_B-1] // 16 bits for result
    );

    reg init; // initial block was not working, so created a bit that initializes the 
              // matrices on a clock edge and is deactivated after one cycle.
 
    reg [DATA_SIZE-1:0] temp_A [0:ROW_A-1][0:COL_B-1];
    reg [DATA_SIZE-1:0] temp_B [0:ROW_A-1][0:COL_B-1];     

    reg [DATA_SIZE-1:0] A [0:ROW_A-1][0:COL_A-1+(ROW_A-1) + 2*(COL_B-1)];// this formula ensures there is enough padding  
    reg [DATA_SIZE-1:0] B [0:COL_B-1][0:ROW_B-1+(COL_B-1) + 2*(ROW_A-1)];// padded the matrix to ensure proper dataflow
    integer count;
    
//          1,2,3                   0,0,1,2,3,0,0,0,0
// A ->>>   1,2,3       ->>>>>>     0,0,0,1,2,3,0,0,0
//          1,2,3                   0,0,0,0,1,2,3,0,0
 
//                                  0,0,0
//                                  0,0,0  
//          1,2,3                   1,0,0
// B ->>>   1,2,3       ->>>>>>     1,2,0
//          1,2,3                   1,2,3
//                                  0,2,3   
//                                  0,0,3
//                                  0,0,0
//                                  0,0,0

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;
            init <= 1;
            computeDone = 0;
            for (int i = 0; i < ROW_A; i = i + 1) begin
                for (int j = 0; j < (COL_A*3)+3; j = j + 1) begin
                    A[i][j] = 0;
                end
            end
            for (int i = 0; i < COL_B; i = i + 1) begin
                for (int j = 0; j < (ROW_B*3)+3; j = j + 1) begin
                    B[i][j] = 0;
                end
            end
            for (int i = 0; i < ROW_A; i = i + 1) begin
                for (int j = 0; j < COL_B; j = j + 1) begin
                    temp_A[i][j] = 0;
                    temp_B[i][j] = 0;
                    resMatrix[i][j] <= 0;
                end
            end
        end 
      
        if (initiateCompute && count < ROW_B + (COL_B-1)+2*(ROW_A-1)-ROW_A+1) begin
            if (init) begin // initialising the matrix
                for(int i = 0;i<ROW_A;i++) begin
                    for(int j = 0;j<COL_A;j++)begin
                        A[i][j+i+ROW_A-1] = matrix_A[i][j];

                    end
                end    
                for(int i = 0;i<ROW_B;i++)begin                
                    for(int j = 0;j<COL_B;j++)begin    
                        B[j][i+j+ROW_A-1] = matrix_B[i][j];
                    end
                end                                   
                init = 0;// setting as zero once initialised        
            
            end else begin  //  the temp_A and temp_B matrix are initally filled as 0 
                            //  making any other multiplication invalid    
    
                for(int i = 0;i<ROW_A;i++)begin
                    for(int j = 0;j<COL_B;j++)begin
                        temp_A[i][j] = A[i][COL_B-1-j+count];                   
                    end
                end  
                
                for(int i = 0;i<ROW_A;i++)begin
                    for(int j = 0;j<COL_B;j++)begin
                        temp_B[i][j] = B[j][ROW_A - 1 - i + count];    
                    end
                end   
                       
                for(int i = 0;i<ROW_A;i = i + 1)begin
                    for(int j = 0;j<COL_B;j=j+1)begin
                        resMatrix[i][j] <= resMatrix[i][j] + temp_A[i][j]*temp_B[i][j];
                    end                
                end
               
                // Increment count
                //count is the variable that brings new values to the temp_A and temp_B matrices
                count <= count + 1;
            end
        end
        if(count == ROW_B + (COL_B-1)+2*(ROW_A-1)-ROW_A+1) computeDone = 1; // to notify the manager madule that the computation is done
       
    end

endmodule
