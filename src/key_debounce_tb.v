`timescale 1ms / 1us

module key_debounce_tb;
	// Inputs
	reg key;
	reg clk;
	reg rst_n;

	// Outputs
	wire key_debounced;

	// Instantiate the Unit Under Test (UUT)
	key_debounce uut(
		.key(key), 
		.clk(clk), 
		.rst_n(rst_n), 
		.key_debounced(key_debounced)
	);
    
    always #5 clk = ~clk;

    integer i;
    
	initial begin
		// Initialize Inputs
		key = 0;
		clk = 0;
		rst_n = 0;

		// Wait 100 ns for global reset to finish
		#2.5;
        
        rst_n = 1;
        
        #16.4;
        
        for (i = 0; i < 10; i = i + 1) begin
            key = 1;
            #0.35;
            key = 0;
            #0.35;
            key = 1;
            #0.35;
            key = 0;
            #0.35;
            key = 1;
            #0.35;
            key = 0;
            #0.35;
            key = 1;
            #0.35;
            key = 0;
            #0.35;
            key = 1;
            #0.35;
            key = 0;
            #0.35;
            key = 1;
            #0.35;
            key = 0;
            #0.35;
            key = 1;
            #0.35;
            
            #30.6;
            key = 0;
            #50.6;
        end
    $finish();

	end
      
endmodule

