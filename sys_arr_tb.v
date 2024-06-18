module sys_arr_tb;

    reg clk;
    reg reset;
    reg signed [15:0] flat_A[3:0];
    reg signed [15:0] flat_B[3:0];
    wire signed [31:0] flat_C[3:0];

    // Instantiate the systolic array
    sys_arr tb (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    always #5 clk = ~clk;
    integer i, j;
    initial begin


        // Initialize signals
        clk = 0;
        reset = 1;

        // Reset the design
        #10 reset = 0;

        // Initialize matrices A and B
        for (i = 0; i < 4; i = i + 1) begin
            flat_A[i] = $random % 100;
            flat_B[i] = $random % 100;
        end

        // Wait for some time to compute matrix C
        #100;

        // Display the results
        $display("Matrix C:");
        for (i = 0; i < 2; i = i + 1) begin
            for (j = 0; j < 2; j = j + 1) begin
                $display("C[%0d][%0d] = %d", i, j, flat_C[i*2 + j]);
            end
        end

        // Finish simulation
        #100 $finish;
    end
endmodule
