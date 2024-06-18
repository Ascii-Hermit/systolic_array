module sys_arr (
    input clk,
    input reset
//    input signed [15:0] flat_A[3:0],
//    input signed [15:0] flat_B[3:0],
//    output reg signed [31:0] flat_C[3:0]
);

    wire signed [15:0] flat_A[3:0];
    wire signed [15:0] flat_B[3:0];
    reg signed [31:0] flat_C[3:0];

    wire signed [15:0] a_wire[0:1][0:1];
    wire signed [15:0] b_wire[0:1][0:1];
    wire signed [31:0] c_wire[0:1][0:1];
    
    generate
        genvar m, n;
        for (m = 0; m < 2; m = m + 1) begin : row
            for (n = 0; n < 2; n = n + 1) begin : col
                if (m == 0 && n == 0) begin
                    pe pe0 (
                        .clk(clk),
                        .reset(reset),
                        .a(flat_A[m*2 + n]),
                        .b(flat_B[m*2 + n]),
                        .c_in(32'b0),
                        .a_out(a_wire[m][n]),
                        .b_out(b_wire[m][n]),
                        .c_out(c_wire[m][n])
                    );
                end else if (m == 0) begin
                    pe pe0 (
                        .clk(clk),
                        .reset(reset),
                        .a(flat_A[m*2 + n]),
                        .b(b_wire[m][n-1]),
                        .c_in(c_wire[m][n-1]),
                        .a_out(a_wire[m][n]),
                        .b_out(b_wire[m][n]),
                        .c_out(c_wire[m][n])
                    );
                end else if (n == 0) begin
                    pe pe0 (
                        .clk(clk),
                        .reset(reset),
                        .a(a_wire[m-1][n]),
                        .b(flat_B[m*2 + n]),
                        .c_in(c_wire[m-1][n]),
                        .a_out(a_wire[m][n]),
                        .b_out(b_wire[m][n]),
                        .c_out(c_wire[m][n])
                    );
                end else begin
                    pe pe0 (
                        .clk(clk),
                        .reset(reset),
                        .a(a_wire[m-1][n]),
                        .b(b_wire[m][n-1]),
                        .c_in(c_wire[m-1][n-1]),
                        .a_out(a_wire[m][n]),
                        .b_out(b_wire[m][n]),
                        .c_out(c_wire[m][n])
                    );
                end
            end
        end
    endgenerate

    generate
        for (m = 0; m < 2; m = m + 1) begin : out_row
            for (n = 0; n < 2; n = n + 1) begin : out_col
                always @(posedge clk or posedge reset) begin
                    if (reset) begin
                        flat_C[m*2 + n] <= 0;
                    end else begin
                        flat_C[m*2 + n] <= c_wire[m][n];
                    end
                end
            end
        end
    endgenerate

endmodule
