module mem_reset (
	input clk,    // Clock
	input en, // Clock Enable
	input rst_n,  // Asynchronous reset active low
	
	output reg ram_we,
	output reg [5:0] ram_addr,
	output reg [1:0] ram_data,
	
	// output valid,
	// input ready
	output reg done
);
	localparam S_IDLE    = 1'b0;
	localparam S_WORKING = 1'b1;

	reg [0:0] state, next_state;

	always @(*) begin : proc_
		next_state <= S_IDLE;

		case (state)
			S_IDLE:
				if (en && ~done)
					next_state <= S_WORKING;
			S_WORKING:
				if (ram_addr == 6'b111111)
					next_state <= S_IDLE;
				else
					next_state <= S_WORKING;
		endcase
	end

	always @(posedge clk or negedge rst_n) begin : proc_state
		if(~rst_n) begin
			state <= 0;
		end else begin
			state <= next_state;
		end
	end

	always @(posedge clk or negedge rst_n) begin : proc_update_addr
		if (~rst_n) begin
			ram_addr <= 0;
		end else begin
			if (state == S_WORKING)
				ram_addr <= ram_addr + 1'b1;
		end
	end

	always @(*) begin : proc_ram_data
		ram_we = state == S_WORKING;
		ram_data = 0;
	end

	always @(posedge clk or negedge rst_n) begin : proc_callback
		if(~rst_n) begin
			done <= 0;
		end else begin
			if (~done && en)
				done <= 0;
			if (state == S_WORKING && next_state == S_IDLE)
				done <= 1;
		end
	end
endmodule