`timescale 1ns/1ps

module tb_matrix_buffers;

    reg clk = 1'b0;
    reg rst = 1'b1;

    always #5 clk = ~clk;

    // X buffer: 16 samples x 4 features = 64 words.
    reg         x_wr_en;
    reg  [5:0]  x_wr_addr;
    reg  [31:0] x_wr_data;
    reg         x_rd_en;
    reg  [5:0]  x_rd_addr;
    wire [31:0] x_rd_data;
    wire        x_rd_valid;

    // Z buffer: 5 inducing points x 4 features = 20 words.
    reg         z_wr_en;
    reg  [4:0]  z_wr_addr;
    reg  [31:0] z_wr_data;
    reg         z_rd_en;
    reg  [4:0]  z_rd_addr;
    wire [31:0] z_rd_data;
    wire        z_rd_valid;

    integer i;
    integer errors;

    matrix_reg_buffer #(
        .DATA_WIDTH(32),
        .DEPTH(64),
        .ADDR_WIDTH(6)
    ) x_buffer (
        .clk(clk), .rst(rst),
        .wr_en(x_wr_en), .wr_addr(x_wr_addr), .wr_data(x_wr_data),
        .rd_en(x_rd_en), .rd_addr(x_rd_addr),
        .rd_data(x_rd_data), .rd_valid(x_rd_valid)
    );

    matrix_reg_buffer #(
        .DATA_WIDTH(32),
        .DEPTH(20),
        .ADDR_WIDTH(5)
    ) z_buffer (
        .clk(clk), .rst(rst),
        .wr_en(z_wr_en), .wr_addr(z_wr_addr), .wr_data(z_wr_data),
        .rd_en(z_rd_en), .rd_addr(z_rd_addr),
        .rd_data(z_rd_data), .rd_valid(z_rd_valid)
    );

    initial begin
        x_wr_en = 0; x_wr_addr = 0; x_wr_data = 0;
        x_rd_en = 0; x_rd_addr = 0;
        z_wr_en = 0; z_wr_addr = 0; z_wr_data = 0;
        z_rd_en = 0; z_rd_addr = 0;
        errors = 0;

        // Reset output registers and valid flags.
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Write every location in X.
        for (i = 0; i < 64; i = i + 1) begin
            @(negedge clk);
            x_wr_en = 1;
            x_wr_addr = i;
            x_wr_data = 32'h3F800000 + i;
        end

        @(negedge clk);
        x_wr_en = 0;

        // Write every location in Z.
        for (i = 0; i < 20; i = i + 1) begin
            @(negedge clk);
            z_wr_en = 1;
            z_wr_addr = i;
            z_wr_data = 32'h40000000 + i;
        end

        @(negedge clk);
        z_wr_en = 0;

        // Read and verify every X location.
        for (i = 0; i < 64; i = i + 1) begin
            x_rd_en = 1;
            x_rd_addr = i;
            @(posedge clk);
            #1;
            if (x_rd_valid !== 1'b1 || x_rd_data !== (32'h3F800000 + i)) begin
                $display("X ERROR at address %0d: valid=%b data=%h", i, x_rd_valid, x_rd_data);
                errors = errors + 1;
            end
            @(negedge clk);
        end
        x_rd_en = 0;

        // Read and verify every Z location.
        for (i = 0; i < 20; i = i + 1) begin
            z_rd_en = 1;
            z_rd_addr = i;
            @(posedge clk);
            #1;
            if (z_rd_valid !== 1'b1 || z_rd_data !== (32'h40000000 + i)) begin
                $display("Z ERROR at address %0d: valid=%b data=%h", i, z_rd_valid, z_rd_data);
                errors = errors + 1;
            end
            @(negedge clk);
        end
        z_rd_en = 0;

        if (errors == 0) begin
            $display("--------------------------------");
            $display("X BUFFER: ALL 64 LOCATIONS PASSED");
            $display("Z BUFFER: ALL 20 LOCATIONS PASSED");
            $display("BUFFER SIMULATION SUCCESSFUL");
            $display("--------------------------------");
        end
        else begin
            $display("--------------------------------");
            $display("BUFFER SIMULATION FAILED: %0d errors", errors);
            $display("--------------------------------");
        end

        $finish;
    end

endmodule
