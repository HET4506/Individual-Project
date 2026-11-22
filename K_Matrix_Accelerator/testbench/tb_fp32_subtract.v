`timescale 1ns/1ps

module tb_fp32_subtract;
    reg  [31:0] a;
    reg  [31:0] b;
    wire [31:0] result;
    integer errors;

    fp32_subtract dut (
        .a(a),
        .b(b),
        .result(result)
    );

    task check;
        input [31:0] input_a;
        input [31:0] input_b;
        input [31:0] expected;
        begin
            a = input_a;
            b = input_b;
            #10;
            if (result !== expected) begin
                $display("FAIL: a=%h b=%h expected=%h got=%h",
                         a, b, expected, result);
                errors = errors + 1;
            end else begin
                $display("PASS: a=%h b=%h result=%h", a, b, result);
            end
        end
    endtask

    initial begin
        errors = 0;
        check(32'h3F800000, 32'h3F000000, 32'h3F000000); // 1.0 - 0.5 = 0.5
        check(32'h40000000, 32'h3F800000, 32'h3F800000); // 2.0 - 1.0 = 1.0
        check(32'h3F800000, 32'h40000000, 32'hBF800000); // 1.0 - 2.0 = -1.0
        check(32'h3FC00000, 32'h3F000000, 32'h3F800000); // 1.5 - 0.5 = 1.0
        check(32'hBF800000, 32'h3F800000, 32'hC0000000); // -1.0 - 1.0 = -2.0
        check(32'h40400000, 32'h3F800000, 32'h40000000); // 3.0 - 1.0 = 2.0

        if (errors == 0)
            $display("FP32 SUBTRACT TESTS PASSED");
        else
            $display("FP32 SUBTRACT TESTS FAILED: %0d errors", errors);
        $finish;
    end
endmodule
