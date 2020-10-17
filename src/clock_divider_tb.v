`timescale 1us / 1ns

module clock_divider_tb;
	// Inputs
	reg clk;
	reg rst_n;

	// Outputs
	wire clk_div2_out;
	wire clk_div10_out;
	wire clk_div16_out;
	wire clk_div1234_out;

	// Instantiate the Unit Under Test (UUT)
	clock_divider #(.DIVISOR(2))
    uut_div2 (
		.clk(clk), 
		.rst_n(rst_n), 
		.clk_out(clk_div2_out)
	);
    
	clock_divider #(.DIVISOR(10))
    uut_div10 (
		.clk(clk), 
		.rst_n(rst_n), 
		.clk_out(clk_div10_out)
	);

	clock_divider #(.DIVISOR(16))
    uut_div16 (
		.clk(clk), 
		.rst_n(rst_n), 
		.clk_out(clk_div16_out)
	);
    
	clock_divider #(.DIVISOR(1234))
    uut_div1234 (
		.clk(clk), 
		.rst_n(rst_n), 
		.clk_out(clk_div1234_out)
	);
	
	always #0.5 clk <= ~clk;

	initial begin
		clk = 0;
		rst_n = 0;

		#10;
        
        rst_n = 1;
        #10000

        $finish;
	end
      
endmodule

