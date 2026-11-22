// Positive finite FP32 adder for non-negative kernel-distance terms.
// Supports zero and normalized finite operands. Subnormal, NaN and infinity
// are outside this initial implementation scope. Rounding: ties-to-even.
module fp32_add_positive (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg  [31:0] result
);
    function [26:0] shift_right_jam;
        input [26:0] value;
        input integer shift;
        reg sticky;
        begin
            if (shift <= 0)
                shift_right_jam = value;
            else if (shift >= 27)
                shift_right_jam = (|value) ? 27'b1 : 27'b0;
            else begin
                sticky = |(value << (27 - shift));
                shift_right_jam = value >> shift;
                shift_right_jam[0] = shift_right_jam[0] | sticky;
            end
        end
    endfunction

    reg [7:0] exp_a, exp_b, exp_large;
    reg [23:0] sig_a, sig_b, sig_large, sig_small;
    reg [26:0] ext_large, ext_small, aligned_small, magnitude;
    reg [27:0] sum_ext;
    reg [24:0] rounded_sig;
    reg [7:0] exp_work;
    reg guard_bit, round_bit, sticky_bit, round_up;
    integer exp_diff;

    always @* begin
        result = 32'b0;
        exp_a = a[30:23];
        exp_b = b[30:23];
        sig_a = {1'b1, a[22:0]};
        sig_b = {1'b1, b[22:0]};
        exp_large = exp_a;
        sig_large = sig_a;
        sig_small = sig_b;

        if (exp_b > exp_a) begin
            exp_large = exp_b;
            sig_large = sig_b;
            sig_small = sig_a;
        end

        ext_large = {sig_large, 3'b000};
        ext_small = {sig_small, 3'b000};
        exp_diff = (exp_a >= exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
        aligned_small = shift_right_jam(ext_small, exp_diff);
        sum_ext = {1'b0, ext_large} + {1'b0, aligned_small};
        magnitude = 27'b0;
        exp_work = exp_large;
        rounded_sig = 25'b0;
        guard_bit = 1'b0;
        round_bit = 1'b0;
        sticky_bit = 1'b0;
        round_up = 1'b0;

        if (a[31] || b[31]) begin
            result = 32'b0; // Negative inputs are outside this unit's contract.
        end else if (exp_a == 8'hff || exp_b == 8'hff) begin
            result = 32'b0; // NaN/Inf not supported in this initial version.
        end else if (exp_a == 0 && exp_b == 0) begin
            result = 32'b0;
        end else if (exp_a == 0) begin
            result = b;
        end else if (exp_b == 0) begin
            result = a;
        end else begin
            if (sum_ext[27]) begin
                magnitude = sum_ext[27:1];
                magnitude[0] = magnitude[0] | sum_ext[0];
                exp_work = exp_large + 1'b1;
            end else begin
                magnitude = sum_ext[26:0];
            end

            rounded_sig = {1'b0, magnitude[26:3]};
            guard_bit = magnitude[2];
            round_bit = magnitude[1];
            sticky_bit = magnitude[0];
            round_up = guard_bit && (round_bit || sticky_bit || rounded_sig[0]);
            if (round_up)
                rounded_sig = rounded_sig + 1'b1;

            if (rounded_sig[24]) begin
                rounded_sig = rounded_sig >> 1;
                exp_work = exp_work + 1'b1;
            end

            if (exp_work == 8'hff)
                result = {1'b0, 8'hff, 23'b0};
            else
                result = {1'b0, exp_work, rounded_sig[22:0]};
        end
    end
endmodule
