module multiply(
    parameter BITS = 16,
    input clk,
    input reset,
    input signed [BITS-1:0] multiplicand,
    input signed [BITS-1:0] multiplier,
);
    reg signed [2*BITS-1:0] multiplicand_reg;
    reg signed [2*BITS-1:0] multiplier_reg;
    reg signed [2*BITS-1:0] temp_product;

    wire signed [2*BITS-1:0] product;
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize registers to zero on reset 
            multiplicand_reg <= 0;
            multiplier_reg <= 0;
            temp_product <= 0;
            product <= 0;
            i <= 0;
        end 
        else if (i < BITS) begin
        // Perform multiplication step by step using the shift and add method
        //this for normal positive numbers 
        //this is how we do multiplication
        //      1101
        //     *1110
        //     ------
        //      0000
        //     1101-
        //    1101--
        //   1101---
        // ----------
        //  10110110     
        // ----------
            if (multiplier_reg[0] == 1'b1) begin
                temp_product <= temp_product + (multiplicand_reg << i);
            end
            multiplier_reg <= multiplier_reg >>> 1; // Arithmetic shift right
            i <= i + 1;
        end 
        else begin
            // Assigning the the final product
            product <= temp_product;
        end
    end
endmodule