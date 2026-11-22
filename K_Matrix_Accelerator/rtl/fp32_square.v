// FP32 squaring unit for finite, normalized IEEE-754 inputs.
// Implements round-to-nearest, ties-to-even.
// Zero is supported. Subnormal, infinity and NaN inputs are outside
// the initial implementation scope. Underflow flushes to zero.
module fp32_square (
    input  wire [31:0] a,
    output reg  [31:0] result
);

    reg [23:0] significand;
    reg [47:0] product;
    reg [24:0] rounded_significand;
    reg [7:0] exponent_result;
    reg guard_bit, round_bit, sticky_bit, round_up;
    reg [22:0] fraction;
    integer unbiased_exponent;

    always @* begin
        result = 32'b0;
        significand = {1'b1, a[22:0]};
        product = 48'b0;
        rounded_significand = 25'b0;
        exponent_result = 8'b0;
        guard_bit = 1'b0;
        round_bit = 1'b0;
        sticky_bit = 1'b0;
        round_up = 1'b0;
        fraction = 23'b0;
        unbiased_exponent = 0;

        if (a[30:23] == 0) begin
            // Zero is supported; subnormal values are flushed to zero.
            result = 32'b0;
        end else if (a[30:23] == 8'hff) begin
            // NaN and infinity are not handled in this initial version.
            result = 32'b0;
        end else begin
            product = significand * significand;

            // Squaring removes the input sign.
            if (product[47]) begin
                unbiased_exponent = ($signed({1'b0, a[30:23]}) - 127) * 2 + 1;
                rounded_significand = {1'b0, product[47:24]};
                guard_bit = product[23];
                round_bit = product[22];
                sticky_bit = |product[21:0];
            end else begin
                unbiased_exponent = ($signed({1'b0, a[30:23]}) - 127) * 2;
                rounded_significand = {1'b0, product[46:23]};
                guard_bit = product[22];
                round_bit = product[21];
                sticky_bit = |product[20:0];
            end

            round_up = guard_bit &&
                       (round_bit || sticky_bit || rounded_significand[0]);

            if (round_up)
                rounded_significand = rounded_significand + 1'b1;

            if (rounded_significand[24]) begin
                rounded_significand = rounded_significand >> 1;
                unbiased_exponent = unbiased_exponent + 1;
            end

            if (unbiased_exponent > 127) begin
                result = {1'b0, 8'hff, 23'b0}; // +infinity on overflow
            end else if (unbiased_exponent < -126) begin
                result = 32'b0; // flush underflow to zero
            end else begin
                exponent_result = unbiased_exponent + 127;
                fraction = rounded_significand[22:0];
                result = {1'b0, exponent_result, fraction};
            end
        end
    end
endmodule
