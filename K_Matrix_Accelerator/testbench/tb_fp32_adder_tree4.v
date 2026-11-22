`timescale 1ns/1ps

module tb_fp32_adder_tree4;
    reg  [31:0] d0, d1, d2, d3;
    wire [31:0] sum;
    integer errors;

    fp32_adder_tree4 dut (
        .d0(d0), .d1(d1), .d2(d2), .d3(d3), .sum(sum)
    );

    task check;
        input [31:0] a0, a1, a2, a3, expected;
        begin
            d0=a0; d1=a1; d2=a2; d3=a3;
            #10;
            if (sum !== expected) begin
                $display("FAIL: %h + %h + %h + %h expected=%h got=%h",
                         d0,d1,d2,d3,expected,sum);
                errors=errors+1;
            end else begin
                $display("PASS: %h + %h + %h + %h = %h",
                         d0,d1,d2,d3,sum);
            end
        end
    endtask

    initial begin
        errors=0;
        check(32'h3F800000,32'h40000000,32'h40400000,32'h40800000,
              32'h41200000); // 1+2+3+4 = 10
        check(32'h3E800000,32'h3F000000,32'h3F800000,32'h40000000,
              32'h40700000); // 0.25+0.5+1+2 = 3.75
        check(32'h00000000,32'h3F800000,32'h00000000,32'h40000000,
              32'h40400000); // 0+1+0+2 = 3
        check(32'h3F800000,32'h3F800000,32'h3F800000,32'h3F800000,
              32'h40800000); // 1+1+1+1 = 4

        if (errors==0)
            $display("FP32 ADDER TREE TESTS PASSED");
        else
            $display("FP32 ADDER TREE TESTS FAILED: %0d errors",errors);
        $finish;
    end
endmodule
