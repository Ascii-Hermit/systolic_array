module pe (
    input clk,
    input reset,
    input signed [15:0] a,
    input signed [15:0] b,
    input signed [31:0] c_in,
    output reg signed [15:0] a_out,
    output reg signed [15:0] b_out,
    output reg signed [31:0] c_out
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            a_out <= 0;
            b_out <= 0;
            c_out <= 0;
        end else begin
            a_out <= a;       // Pass A value to the next PE
            b_out <= b;       // Pass B value to the next PE
            c_out <= c_in + (a * b);  // Directly multiply and accumulate the result
        end
    end
endmodule
