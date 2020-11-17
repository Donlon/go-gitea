`include "spi_mem_cmd.vh"

module spi_mem_emu (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    // Data interface
    input [1:0]      cmd,
    input [5:0]      addr,
    output reg [7:0] rd_data,
    input      [7:0] wr_data,

    // Callback interface
    input en,
    output reg valid
);

    reg [7:0] mem [63:0];

    initial
    forever begin
        wait (en == 1);
        @(posedge clk);
        if (cmd == `CMD_WRITE) begin
            mem[addr] = wr_data;
        end else begin
            rd_data = mem[addr];
        end
        repeat(4) @(posedge clk);
        valid = 1;
        wait (en == 0);
        @(posedge clk);
        valid = 0;
    end

    integer i;

    initial begin
        valid = 0;
        rd_data = 0;
        for (i = 0; i < 64; i = i + 1) begin
            mem[i] = 0;
        end
    end
endmodule