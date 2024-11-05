`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IITGN
// Engineer: Het and Christie
// 
// Create Date: 29.06.2024 00:17:51
// Design Name: 
// Module Name: manager_32bits
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

module manager_32bits #(
    parameter ROW_A = 3,
    parameter COL_A = 3,
    parameter ROW_B = 3,
    parameter COL_B = 3,
    parameter DATA_SIZE = 32
    
)(
    input clk,
    input reset,
    input [7:0] num,
    input isNewData, // if there exists a new data to be put in the matrix
    input isBusy, // if there is already a number that is transmitting
    input [2*DATA_SIZE-1:0] resMatrix[0:ROW_A-1][0:COL_B-1],
    input computeDone, // the systolic array sends this once the entire computation is done
    output reg initiateCompute, // tells the systolic array to start the computation
    output reg [DATA_SIZE-1:0] matrix_A[0:ROW_A-1][0:COL_A-1],
    output reg [DATA_SIZE-1:0] matrix_B[0:ROW_B-1][0:COL_B-1],
    output reg doTransmit, // gives the sender instruction to send data
    output reg [7:0] sum
);

    reg [2:0] state; // State machine
    reg isMatA; // to identify which matrix to fill

    parameter IDLE = 3'b000;
    parameter FILL_MATRIX = 3'b001;
    parameter COMPUTE = 3'b010;
    parameter BUSY = 3'b011;
    parameter SEND = 3'b100;

    reg [3:0] count;
    reg [3:0] row, col;
    reg [4:0] bit_set; // since we are sending a 64 bit data and receiving a 32 bit data
                       // we need to use this

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum <= 0;
            doTransmit <= 0;
            state <= IDLE;
            row <= 0;
            col <= 0;
            isMatA <= 1;
            initiateCompute <= 0;
            count <= 0;
            bit_set <= 0;
        end else begin
            case (state)
                IDLE: begin
                    doTransmit <= 0;
                    if (isNewData) begin
                        if (isMatA) begin
                            if(bit_set == 0)begin
                                matrix_A[row][col][31:24] <= num;
                                bit_set <= 1;
                            end else if(bit_set == 1)begin
                                matrix_A[row][col][23:16] <= num;
                                bit_set <= 2; 
                            end else if(bit_set == 2)begin
                                matrix_A[row][col][15:8] <= num;
                                bit_set <= 3; 
                            end else begin
                                matrix_A[row][col][7:0] <= num;
                                bit_set <= 0;
                                col <= col + 1;
                                if (col == COL_A - 1) begin
                                    col <= 0;
                                    row <= row + 1;
                                    if (row == ROW_A - 1) begin
                                        row <= 0;
                                        isMatA <= 0;
                                    end
                                end
                                state <= FILL_MATRIX;
                            end
                        end else begin
                            if(bit_set == 0)begin
                                matrix_B[row][col][31:24] <= num;
                                bit_set <= 1;
                            end else if (bit_set == 1) begin
                                matrix_B[row][col][23:16] <= num;
                                bit_set <= 2;
                            end else if (bit_set == 2) begin
                                matrix_B[row][col][15:8] <= num;
                                bit_set <= 3;
                            end else begin
                                matrix_B[row][col][7:0] <= num;
                                bit_set <= 0;
                                col <= col + 1;
                                if (col == COL_B - 1) begin
                                    col <= 0;
                                    row <= row + 1;
                                    if (row == ROW_B - 1) begin
                                        row <= 0;
                                        state <= COMPUTE;
                                    end
                                end
                                state <= FILL_MATRIX;
                            end
                        end
                    end
                end

                FILL_MATRIX: begin
                    if (isNewData) begin
                        if (isMatA) begin
                            if(bit_set == 0)begin
                                matrix_A[row][col][31:24] <= num;
                                bit_set <= 1;
                            end else if(bit_set == 1)begin
                                matrix_A[row][col][23:16] <= num;
                                bit_set <= 2; 
                            end else if(bit_set == 2)begin
                                matrix_A[row][col][15:8] <= num;
                                bit_set <= 3; 
                            end else begin
                                matrix_A[row][col][7:0] <= num;
                                bit_set <= 0;
                                col <= col + 1;
                                if (col == COL_A -1) begin
                                    col <= 0;
                                    row <= row + 1;
                                    if (row == ROW_A-1) begin
                                        row <= 0;
                                        isMatA <= 0;
                                    end
                                end
                            end
                        end else begin
                            if(bit_set == 0)begin
                                matrix_B[row][col][31:24] <= num;
                                bit_set <= 1;
                            end else if (bit_set == 1) begin
                                matrix_B[row][col][23:16] <= num;
                                bit_set <= 2;
                            end else if (bit_set == 2) begin
                                matrix_B[row][col][15:8] <= num;
                                bit_set <= 3;
                            end else begin
                                matrix_B[row][col][7:0] <= num;
                                bit_set <= 0;
                                col <= col + 1;
                                if (col == COL_B -1) begin
                                    col <= 0;
                                    row <= row + 1;
                                    if (row == ROW_B-1) begin
                                        row <= 0;
                                        col <= 0;
                                        state <= COMPUTE;
                                    end
                                end
                            end
                        end
                    end
                end

                COMPUTE: begin
                    initiateCompute <= 1;
                    bit_set <= 0;
                    if (computeDone) begin
                        initiateCompute <= 0;
                        state <= SEND;
                    end
                end

                BUSY: begin
                    if (!isBusy) begin
                        if (count == 0) begin
                            state <= BUSY;
                            count <= count + 1;
                        end else begin
                            state <= SEND;
                            doTransmit <= 1;
                        end
                    end else begin
                        state <= BUSY;
                    end
                end

                SEND: begin
                    if (bit_set == 0)begin
                        sum <= resMatrix[row][col][63:56];
                        bit_set = 1;    
                    end else if (bit_set == 1) begin
                        sum <= resMatrix[row][col][55:48];
                        bit_set <= 2;
                    end else if (bit_set == 2) begin
                        sum <= resMatrix[row][col][47:40];
                        bit_set <= 3;
                    end else if (bit_set == 3) begin
                        sum <= resMatrix[row][col][39:32];
                        bit_set <= 4;
                    end else if (bit_set == 4) begin
                        sum <= resMatrix[row][col][31:24];
                        bit_set <= 5;
                    end else if (bit_set == 5) begin
                        sum <= resMatrix[row][col][23:16];
                        bit_set <= 6;
                    end else if (bit_set == 6) begin
                        sum <= resMatrix[row][col][15:8];
                        bit_set <= 7;
                    end else begin
                        sum <= resMatrix[row][col][7:0];
                        bit_set <= 0;
                        col <= col + 1;
                        if (col == COL_B - 1) begin
                            col <= 0;
                            row <= row + 1;
                            if (row == ROW_A - 1) begin
                                row <= 0;
                                col <= 0;
                                state <= COMPUTE;
                            end
                        end
                    end
                    state <= BUSY;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
