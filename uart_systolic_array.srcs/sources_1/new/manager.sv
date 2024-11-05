module manager_8bits#(
    parameter ROW_A = 3,
    parameter COL_A = 3,
    parameter ROW_B = 3,
    parameter COL_B = 3
)(
    input clk,
    input reset,
    input [7:0] num,
    input isNewData,// if there exists a new data to be put in the matrix
    input isBusy,// if there is already a number that is transmitting
    input [15:0] resMatrix[0:ROW_A-1][0:COL_B-1],
    input computeDone,// the systolic array sends this once the entire computation is done
    output reg initiateCompute, //tells the systolic array to start the computation
    output reg [7:0] matrix_A[0:ROW_A-1][0:COL_A-1],
    output reg [7:0] matrix_B[0:ROW_B-1][0:COL_B-1],
    output reg doTransmit, // gives the sender instruction to send data
    output reg [7:0] sum
);
    
    reg [3:0] state;  // State machine
    reg [1:0] isMatA; // to identify which matrix to fill
    

    parameter IDLE = 3'b000;
    parameter FILL_MATRIX = 3'b001;
    parameter COMPUTE = 3'b010;
    parameter BUSY = 3'b011;
    parameter SEND = 3'b100;
    
    reg [3:0] count;
    reg [3:0] row,col;
    reg isUpper; // since we are sending a 16 bit data, we need to send the upper 8 bits first
                 // and the lower 8 bits next
       
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum <= 0;
            doTransmit <= 0;
            state <= IDLE;
            row = 0;
            col<= 0;
            isMatA <= 1;
            initiateCompute = 0;
            count<=0;
            isUpper = 1;
            
        end else begin
            case (state)
                IDLE: begin
                    doTransmit <= 0;
                    if (isNewData) begin
                        if(isMatA)begin
                            matrix_A[0][0] <= num;
                            state <= FILL_MATRIX;
                            col++;
                        end else begin
                            matrix_B[0][0] <= num;
                            state <= FILL_MATRIX;
                            col++;
                        end                        
                    end
                end

                FILL_MATRIX: begin
                    if (isNewData) begin
                        if (isMatA) begin
                            matrix_A[row][col] <= num;
                            col++;
                            if(col == COL_A)begin
                                col <= 0;
                                row++;
                                if(row == ROW_A)begin
                                    isMatA = 0;
                                    row = 0;
                                    col = 0;
                                end                            
                            end
                            state <= FILL_MATRIX;
                        end else begin
                            matrix_B[row][col] <= num;
                            col++;
                            if(col == COL_B)begin
                                col <= 0;
                                row++;
                                if(row == ROW_B)begin
                                    row = 0;
                                    col = 0;
                                    state <= COMPUTE;
                                end                            
                            end
                        end
                    end
                end

                COMPUTE: begin
                    initiateCompute = 1;
                    if(!computeDone)begin
                        state <= COMPUTE;
                    end else begin
                        state = SEND;          
                    end
                end

                BUSY: begin
                   if(!isBusy)begin
                    if(count==0)begin
                        state= BUSY;
                        count = count+1;
                     end
                     
                     else state <=SEND;
                        doTransmit=1;
                   end
                   else state = BUSY;  
                end
                
                SEND: begin
                    if(row<ROW_A)begin                        
                        if(isUpper)begin
                            sum = resMatrix[row][col][15:8];
                            isUpper = 0;
                        end else begin
                            sum = resMatrix[row][col][7:0];
                            col++;
                            isUpper = 1;
                            if(col==COL_B)begin
                                row++;
                                col = 0;
                            end
                        end
                        state = BUSY;//we send the control back to CALCULATE to ensure there
                                     //is no error due to clash of loading and sending data
                    end else begin
                        state = BUSY;
                        count = count+1;  
                    end 
                   end
                   
                default: state <= IDLE;
            endcase
        end
    end
endmodule


