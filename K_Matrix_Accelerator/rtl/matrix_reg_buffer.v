module matrix_reg_buffer #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 64,
    parameter ADDR_WIDTH = 6
)(
    input  wire                  clk,
    input  wire                  rst,

    input  wire                  wr_en,
    input  wire [ADDR_WIDTH-1:0] wr_addr,
    input  wire [DATA_WIDTH-1:0] wr_data,

    input  wire                  rd_en,
    input  wire [ADDR_WIDTH-1:0] rd_addr,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output reg                   rd_valid
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (rst) begin
            rd_data  <= {DATA_WIDTH{1'b0}};
            rd_valid <= 1'b0;
        end
        else begin
            if (wr_en && (wr_addr < DEPTH)) begin
                mem[wr_addr] <= wr_data;
            end

            rd_valid <= 1'b0;

            if (rd_en && (rd_addr < DEPTH)) begin
                rd_data  <= mem[rd_addr];
                rd_valid <= 1'b1;
            end
        end
    end
endmodule
