`timescale 1ns/1ps

module tb_fp32_exp_lut;
    reg  [31:0] x;
    wire [31:0] result;
    integer errors;

    fp32_exp_lut dut (.x(x), .result(result));

    task check;
        input [31:0] input_x;
        input [31:0] expected;
        begin
            x = input_x;
            #10;
            if (result !== expected) begin
                $display("FAIL: x=%h expected=%h got=%h", x, expected, result);
                errors = errors + 1;
            end else begin
                $display("PASS: x=%h result=%h", x, result);
            end
        end
    endtask

    initial begin
        errors = 0;
        check(32'h80000000, 32'h3F800000); // exp(-0.0) = 1
        check(32'hBF000000, 32'h3F1B4598); // exp(-0.5), address 16
        check(32'hBF800000, 32'h3EBC5AB2); // exp(-1.0), address 32
        check(32'hC0000000, 32'h3E0A9555); // exp(-2.0), address 64
        check(32'hC0800000, 32'h3C960AAE); // exp(-4.0), address 128
        check(32'hC1000000, 32'h39AFE108); // exp(-8.0), address 256
        check(32'hC1200000, 32'h00000000); // exp(-10): clamped to zero

        if (errors == 0)
            $display("FP32 EXP LUT TESTS PASSED");
        else
            $display("FP32 EXP LUT TESTS FAILED: %0d errors", errors);
        $finish;
    end
endmodule
