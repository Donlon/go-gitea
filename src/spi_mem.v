module spi_mem (
	input clk,    // Clock
	input clk_en, // Clock Enable
	input rst_n,  // Asynchronous reset active low
	
	input req_1,
	output grant_1,
	input req_2,
	output grant_2,

	input we_1,
	input  [5:0] addr_1,
	output [1:0] data_1,
);

endmodule