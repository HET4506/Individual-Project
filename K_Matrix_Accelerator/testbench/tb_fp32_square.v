`timescale 1ns/1ps

module tb_fp32_square;
    reg  [31:0] a;
    wire [31:0] result;
    integer errors;

    fp32_square dut (
        .a(a),
        .result(result)
    );

    task check;
        input [31:0] input_a;
        input [31:0] expected;
        begin
            a = input_a;
            #10;
            if (result !== expected) begin
                $display("FAIL: a=%h expected=%h got=%h", a, expected, result);
                errors = errors + 1;
            end else begin
                $display("PASS: a=%h result=%h", a, result);
            end
        end
    endtask

    initial begin
        errors = 0;
        check(32'h3F800000, 32'h3F800000); // 1.0^2 = 1.0
        check(32'h40000000, 32'h40800000); // 2.0^2 = 4.0
        check(32'h3F000000, 32'h3E800000); // 0.5^2 = 0.25
        check(32'h3FC00000, 32'h40100000); // 1.5^2 = 2.25
        check(32'h40400000, 32'h41100000); // 3.0^2 = 9.0
        check(32'hC0000000, 32'h40800000); // (-2.0)^2 = 4.0
        check(32'h00000000, 32'h00000000); // 0.0^2 = 0.0

        if (errors == 0)
            $display("FP32 SQUARE TESTS PASSED");
        else
            $display("FP32 SQUARE TESTS FAILED: %0d errors", errors);
        $finish;
    end
endmodule
