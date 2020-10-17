`timescale 1us / 1ns

module mem_reset_tb;

	reg clk;
	reg memrst_en;
	reg rst_n;

	reg ram_we;
	reg [5:0] ram_addr;
	reg [1:0] ram_data;

	reg ram_we_0;
	reg [5:0] ram_addr_0;
	reg [1:0] ram_data_0;

	wire ram_we_1;
	wire [5:0] ram_addr_1;
	wire [1:0] ram_data_1;

	reg  [5:0] rd_addr_1;
	wire [1:0] rd_data_out_1;
	wire done;

	always #0.5 clk = ~clk;

	checkerboard_state_ram ram (
		.clk(clk),

		.wr_en(ram_we),

		.wr_addr(ram_addr),
		.wr_data(ram_data),

		.rd_addr_1(rd_addr_1),
		.rd_data_out_1(rd_data_out_1),

		.rd_addr_2(),
		.rd_data_out_2()
	);

	// Instantiate the Unit Under Test (UUT)
	mem_reset uut (
		.clk(clk),
		.en(memrst_en),
		.rst_n(rst_n),

		.ram_we(ram_we_1),
		.ram_addr(ram_addr_1),
		.ram_data(ram_data_1),

		.done(done)
	);
    
    task write_memory;
        input [5:0] addr;
        input [1:0] data;
        begin
            repeat(1) @(posedge clk);
            ram_we_0 = 1;
            ram_addr_0 = addr;
            ram_data_0 = data;
            repeat(1) @(posedge clk);
            ram_we_0 = 0;
        end
    endtask

    integer i;

    reg ram_write_src; // 0: task write_memory, 1: uut

    always @(*) begin
    	if (ram_write_src == 0) begin
    		ram_we = ram_we_0;
			ram_addr = ram_addr_0;
			ram_data = ram_data_0;
    	end else begin
    		ram_we = ram_we_1;
			ram_addr = ram_addr_1;
			ram_data = ram_data_1;
    	end
    end

    integer error_count = 0;
    
    reg memrst_done;
    
	initial begin
		// Initialize Inputs
		clk = 0;
		memrst_en = 0;
		rst_n = 0;
		ram_we_0 = 0;
		ram_addr_0 = 0;
		ram_data_0 = 0;
		memrst_done = 0;

		// Wait 100 ns for global reset to finish
		#3;

		rst_n = 1;

		ram_write_src = 0;
		for (i = 0; i < 64; i = i + 1) begin
			write_memory(i, $random());
		end
        $display("ramdon data written to memory.");
		
		#3;

		ram_write_src = 1;
        memrst_en = 1;

        repeat(1) @(posedge done);

        $display("mem_reset done.");
        memrst_done = 1;
        
        #1;

        memrst_en = 0;
        #10;
        
		for (i = 0; i < 64; i = i + 1) begin
            rd_addr_1 = i;
			#0.5;
			$display("read memory[%d]: get: %b, expected: 0", i, rd_data_out_1);
			if (rd_data_out_1 != 0) begin
				error_count = error_count + 1;
			end
		end
        
		if (error_count == 0) begin
			$display("== module test pass ==");
		end else begin
			$display("== FAILED: error_count: %d ==", error_count);
		end

        $finish;
		// Add stimulus here

	end
    
    initial begin
        #10000;
        if (~memrst_done) begin
	        $display("=== ERROR: mem_reset timed out! ===");
	        $finish;
	    end;
    end
      
endmodule

