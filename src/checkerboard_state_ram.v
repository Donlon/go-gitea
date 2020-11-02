module checkerboard_state_ram # (
    parameter DATA_BITS = 2,
    parameter EDGE_ADDR_BITS = 3 // 8x8 checkerboard
)(
    input clk,
    input wr_en,

    input [2 * EDGE_ADDR_BITS - 1:0] wr_addr,
    input [DATA_BITS - 1:0] wr_data,

    input [2 * EDGE_ADDR_BITS - 1:0]  rd_addr,
    output reg [DATA_BITS - 1:0] rd_data_out
);

    reg [DATA_BITS - 1:0] mem[2 ** (2 * EDGE_ADDR_BITS) - 1:0];

    always @(posedge clk) begin
        if (wr_en) begin
            mem[wr_addr] <= wr_data;
        end
    end

    always @(*) begin
        rd_data_out = mem[rd_addr];
    end

endmodule
