// FP32 subtraction for finite, normalized IEEE-754 operands.
// Implements round-to-nearest, ties-to-even.
// Initial project scope: normal finite values. NaN, infinity and subnormal
// input handling are intentionally not implemented in this first version.
module fp32_subtract (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output reg  [31:0] result
);

    function [26:0] shift_right_jam;
        input [26:0] value;
        input integer shift;
        reg sticky;
        begin
            if (shift <= 0) begin
                shift_right_jam = value;
            end else if (shift >= 27) begin
                shift_right_jam = (|value) ? 27'b1 : 27'b0;
            end else begin
                sticky = |(value << (27 - shift));
                shift_right_jam = value >> shift;
                shift_right_jam[0] = shift_right_jam[0] | sticky;
            end
        end
    endfunction

    reg [7:0] exp_a, exp_b, exp_large, exp_small;
    reg [23:0] sig_a, sig_b, sig_large, sig_small;
    reg sign_a, sign_b_eff, sign_large;
    reg [26:0] ext_large, ext_small, ext_small_aligned;
    reg [27:0] magnitude_sum;
    reg [26:0] magnitude;
    reg [7:0] exp_work;
    reg sign_work;
    reg [24:0] mantissa_rounded;
    reg guard_bit, round_bit, sticky_bit, round_up;
    integer exp_diff;

    always @* begin
        result = 32'b0;

        exp_a = a[30:23];
        exp_b = b[30:23];
        sig_a = {1'b1, a[22:0]};
        sig_b = {1'b1, b[22:0]};
        sign_a = a[31];
        sign_b_eff = ~b[31]; // a - b == a + (-b)

        exp_large = exp_a;
        exp_small = exp_b;
        sig_large = sig_a;
        sig_small = sig_b;
        sign_large = sign_a;

        // Order operands by magnitude so subtraction remains non-negative.
        if ((exp_b > exp_a) || ((exp_b == exp_a) && (sig_b > sig_a))) begin
            exp_large = exp_b;
            exp_small = exp_a;
            sig_large = sig_b;
            sig_small = sig_a;
            sign_large = sign_b_eff;
        end

        ext_large = {sig_large, 3'b000};
        ext_small = {sig_small, 3'b000};
        exp_diff = exp_large - exp_small;
        ext_small_aligned = shift_right_jam(ext_small, exp_diff);
        exp_work = exp_large;
        sign_work = sign_large;
        magnitude_sum = 28'b0;
        magnitude = 27'b0;
        mantissa_rounded = 24'b0;
        guard_bit = 1'b0;
        round_bit = 1'b0;
        sticky_bit = 1'b0;
        round_up = 1'b0;

        if (exp_a == 0 || exp_b == 0 || exp_a == 8'hff || exp_b == 8'hff) begin
            // Special values are outside the initial supported scope.
            result = 32'b0;
        end else if (sign_a == sign_b_eff) begin
            magnitude_sum = {1'b0, ext_large} + {1'b0, ext_small_aligned};
            if (magnitude_sum[27]) begin
                magnitude = shift_right_jam(magnitude_sum[27:1], 1);
                exp_work = exp_large + 1'b1;
            end else begin
                magnitude = magnitude_sum[26:0];
            end
            sign_work = sign_a;
        end else begin
            magnitude = ext_large - ext_small_aligned;
            sign_work = sign_large;
            if (magnitude == 0) begin
                exp_work = 0;
                sign_work = 0;
            end else begin
                // Normalize left. The leading significand bit is bit 26.
                while (!magnitude[26] && exp_work > 1) begin
                    magnitude = magnitude << 1;
                    exp_work = exp_work - 1'b1;
                end
            end
        end

        if (magnitude != 0 && exp_work < 8'hff) begin
            mantissa_rounded = magnitude[26:3];
            guard_bit = magnitude[2];
            round_bit = magnitude[1];
            sticky_bit = magnitude[0];
            round_up = guard_bit && (round_bit || sticky_bit || mantissa_rounded[0]);
            if (round_up)
                mantissa_rounded = mantissa_rounded + 1'b1;

            if (mantissa_rounded[23]) begin
                result = {sign_work, exp_work, mantissa_rounded[22:0]};
            end else if (mantissa_rounded[24]) begin
                result = {sign_work, (exp_work + 1'b1), 23'b0};
            end else begin
                result = {sign_work, exp_work, mantissa_rounded[22:0]};
            end
        end else if (magnitude == 0) begin
            result = 32'b0;
        end else begin
            result = {sign_work, 8'hff, 23'b0};
        end
    end
endmodule
