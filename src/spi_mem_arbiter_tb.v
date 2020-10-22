`timescale 1us / 1ns

module spi_mem_arbiter_tb;
	// Inputs
	reg clk;

	reg rst_n;

	reg req_1;
	reg req_2;
	reg req_3;
	reg req_4;

	// Outputs
	wire grant_1;
	wire grant_2;
	wire grant_3;
	wire grant_4;

	// Instantiate the Unit Under Test (UUT)
	spi_mem_arbiter uut (
		.clk(clk),
		.rst_n(rst_n),

		.req_1(req_1),
		.req_2(req_2),
		.req_3(req_3),
		.req_4(req_4),

		.grant_1(grant_1),
		.grant_2(grant_2),
		.grant_3(grant_3),
		.grant_4(grant_4)
	);

    always #0.5 clk = ~clk;

	initial begin
		// Initialize Inputs
		clk = 0;
		rst_n = 0;

		req_1 = 0;
		req_2 = 0;
		req_3 = 0;
		req_4 = 0;

		// Wait 100 ns for global reset to finish
		#5;

        rst_n = 1;

        #4;

        req_1 = 1;
        wait (grant_1 == 1);

        #4;
        req_2 = 1;
        #4;
        req_3 = 1;
        #4;

        req_1 = 0;
        wait (grant_1 == 0);
        wait (grant_2 == 1);
        #4;
        req_2 = 0;
        wait (grant_2 == 0);
        wait (grant_3 == 1);

        #4;

        $stop;
	end

endmodule

