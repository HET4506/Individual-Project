// Multiply a non-negative FP32 value by -0.5.
// For normalized finite inputs this is an exact exponent decrement and sign set.
// Zero is mapped to negative zero. Subnormal inputs/results and Inf/NaN
// are outside this initial module's supported scope; underflow flushes to zero.
module fp32_mul_neg_half (
    input  wire [31:0] a,
    output reg  [31:0] result
);
    always @* begin
        if (a[30:23] == 8'h00) begin
            // Preserve zero as -0.0; subnormal inputs are flushed to zero.
            result = 32'h80000000;
        end else if (a[30:23] == 8'hff) begin
            // Special values are not supported in this initial version.
            result = 32'b0;
        end else if (a[30:23] == 8'h01) begin
            // Scaling would produce a subnormal result; flush to -0.0.
            result = 32'h80000000;
        end else begin
            result = {1'b1, (a[30:23] - 8'd1), a[22:0]};
        end
    end
endmodule
