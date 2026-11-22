// One RBF kernel element datapath for four features.
// K = exp(-0.5 * sum((xj - zj)^2)), j = 0..3.
// This first integration is combinational (no pipeline or handshake).
// Arithmetic modules retain their documented initial FP32 limitations.
module rbf_kernel4 (
    input  wire [31:0] x0, x1, x2, x3,
    input  wire [31:0] z0, z1, z2, z3,
    output wire [31:0] k
);
    wire [31:0] diff0, diff1, diff2, diff3;
    wire [31:0] sq0, sq1, sq2, sq3;
    wire [31:0] distance;
    wire [31:0] exponent_arg;

    fp32_subtract sub0 (.a(x0), .b(z0), .result(diff0));
    fp32_subtract sub1 (.a(x1), .b(z1), .result(diff1));
    fp32_subtract sub2 (.a(x2), .b(z2), .result(diff2));
    fp32_subtract sub3 (.a(x3), .b(z3), .result(diff3));

    fp32_square square0 (.a(diff0), .result(sq0));
    fp32_square square1 (.a(diff1), .result(sq1));
    fp32_square square2 (.a(diff2), .result(sq2));
    fp32_square square3 (.a(diff3), .result(sq3));

    fp32_adder_tree4 sum_squares (
        .d0(sq0), .d1(sq1), .d2(sq2), .d3(sq3),
        .sum(distance)
    );

    fp32_mul_neg_half scale_distance (
        .a(distance), .result(exponent_arg)
    );

    fp32_exp_lut exponential (
        .x(exponent_arg), .result(k)
    );
endmodule
