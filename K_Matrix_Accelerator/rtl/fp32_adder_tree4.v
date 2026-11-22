// Four-input positive FP32 adder tree.
// Inputs are expected to be non-negative finite FP32 values or zero.
module fp32_adder_tree4 (
    input  wire [31:0] d0,
    input  wire [31:0] d1,
    input  wire [31:0] d2,
    input  wire [31:0] d3,
    output wire [31:0] sum
);
    wire [31:0] sum01;
    wire [31:0] sum23;

    fp32_add_positive add_level1_0 (
        .a(d0), .b(d1), .result(sum01)
    );

    fp32_add_positive add_level1_1 (
        .a(d2), .b(d3), .result(sum23)
    );

    fp32_add_positive add_level2 (
        .a(sum01), .b(sum23), .result(sum)
    );
endmodule
