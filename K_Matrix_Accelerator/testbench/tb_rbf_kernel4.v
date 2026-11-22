`timescale 1ns/1ps

module tb_rbf_kernel4;
    reg [31:0] x0, x1, x2, x3;
    reg [31:0] z0, z1, z2, z3;
    wire [31:0] k;
    integer errors;

    rbf_kernel4 dut (
        .x0(x0), .x1(x1), .x2(x2), .x3(x3),
        .z0(z0), .z1(z1), .z2(z2), .z3(z3),
        .k(k)
    );

    task check;
        input [31:0] expected;
        input [127:0] label;
        begin
            #10;
            if (k !== expected) begin
                $display("FAIL %0s: expected K=%h, got K=%h", label, expected, k);
                errors = errors + 1;
            end else begin
                $display("PASS %0s: K=%h", label, k);
            end
        end
    endtask

    initial begin
        errors = 0;

        // Case 1: identical vectors. D=0, exp(0)=1.
        x0=32'h3F800000; x1=32'h40000000;
        x2=32'h40400000; x3=32'h40800000;
        z0=32'h3F800000; z1=32'h40000000;
        z2=32'h40400000; z3=32'h40800000;
        check(32'h3F800000, "identical vectors");

        // Case 2: one feature differs by 1. D=1, exponent=-0.5.
        x0=32'h40000000; x1=32'h40000000;
        x2=32'h40400000; x3=32'h40800000;
        z0=32'h3F800000; z1=32'h40000000;
        z2=32'h40400000; z3=32'h40800000;
        check(32'h3F1B4598, "squared distance 1");

        // Case 3: all four features differ by 1. D=4, exponent=-2.
        x0=32'h40000000; x1=32'h40400000;
        x2=32'h40800000; x3=32'h40A00000;
        z0=32'h3F800000; z1=32'h40000000;
        z2=32'h40400000; z3=32'h40800000;
        check(32'h3E0A9555, "squared distance 4");

        // Case 4: negative differences are squared to positive values.
        x0=32'h3F800000; x1=32'h40000000;
        x2=32'h40400000; x3=32'h40800000;
        z0=32'h40000000; z1=32'h40400000;
        z2=32'h40800000; z3=32'h40A00000;
        check(32'h3E0A9555, "negative feature differences");

        if (errors == 0)
            $display("RBF KERNEL 4-FEATURE TESTS PASSED");
        else
            $display("RBF KERNEL 4-FEATURE TESTS FAILED: %0d errors", errors);
        $finish;
    end
endmodule
