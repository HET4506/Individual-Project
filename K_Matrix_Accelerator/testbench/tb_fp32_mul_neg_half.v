`timescale 1ns/1ps

module tb_fp32_mul_neg_half;
    reg  [31:0] a;
    wire [31:0] result;
    integer errors;

    fp32_mul_neg_half dut (.a(a), .result(result));

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
        check(32'h3F800000, 32'hBF000000); // 1.0 * -0.5 = -0.5
        check(32'h40000000, 32'hBF800000); // 2.0 * -0.5 = -1.0
        check(32'h40800000, 32'hC0000000); // 4.0 * -0.5 = -2.0
        check(32'h41200000, 32'hC0A00000); // 10.0 * -0.5 = -5.0
        check(32'h00000000, 32'h80000000); // +0.0 * -0.5 = -0.0

        if (errors == 0)
            $display("FP32 NEGATIVE HALF SCALE TESTS PASSED");
        else
            $display("FP32 NEGATIVE HALF SCALE TESTS FAILED: %0d errors", errors);
        $finish;
    end
endmodule
