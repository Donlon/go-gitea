`timescale 1us / 1ns

module buzzer_tb;
    // Inputs
    reg clk; // 1M
    reg clk_2;
    reg en;
    reg rst_n;

    // Outputs
    wire buzzer_out;

    // Instantiate the Unit Under Test (UUT)
    buzzer uut (
        .clk(clk), 
        .clk_2(clk_2), 
        .en(en), 
        .rst_n(rst_n), 
        .buzzer_out(buzzer_out)
    );

    always #0.5  clk = ~clk;      // 1M
    always #2500 clk_2 = ~clk_2;  // 200Hz

    initial begin
        // Initialize Inputs
        clk = 0;
        clk_2 = 0;

        en = 0;
        rst_n = 0;

        // Wait 100 ns for global reset to finish
        #100;
        rst_n = 1;
        #100000;
        en = 1;
        // Add stimulus here

        #4000000; //4s

        $stop();
    end
endmodule

