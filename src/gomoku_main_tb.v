`timescale 1us / 1ns

module gomoku_main_tb;

	// Inputs
	reg clk;
	reg buzzer_clk;
	reg led_scan_clk;
	reg kb_scan_clk;
	reg led_flicker_clk_slow;
	reg led_flicker_clk_fast;
	reg rst_n;
	reg sw_power;
	reg btn_reset;
	reg btn_ok;
	reg [3:0] keyboard_row;

	// Outputs
	wire buzzer;
	wire led_red_status;
	wire led_green_status;
	wire [7:0] led_row;
	wire [7:0] led_col_red;
	wire [7:0] led_col_green;
	wire [3:0] keyboard_col;

	// Key press emulator

	reg is_key_pressed;
	reg [3:0] key_code;

	reg [1:0] col_keycode;
	reg [3:0] row_keyarray;

	function [3:0] keycode_decode(input [1:0] code);
		begin
			case (code)
				2'b00:   keycode_decode = 4'b0111;
				2'b01:   keycode_decode = 4'b1011;
				2'b10:   keycode_decode = 4'b1101;
				2'b11:   keycode_decode = 4'b1110;
				default: keycode_decode = 4'b1111;
			endcase
		end		
	endfunction

	function [1:0] keycode_encode(input [3:0] code);
		begin
			casez (code)
				4'b0???: keycode_encode = 2'b00;
				4'b10??: keycode_encode = 2'b01;
				4'b110?: keycode_encode = 2'b10;
				4'b1110: keycode_encode = 2'b11;
				default: keycode_encode = 2'b11;
			endcase
		end		
	endfunction

	task task_press_key(input [3:0] keycode);
        begin
            key_code <= keycode;
            is_key_pressed <= 1;
        end
	endtask

	task task_key_up();
		is_key_pressed <= 0;
	endtask

	always @(*) begin
		col_keycode  <= keycode_encode(keyboard_col);
		row_keyarray <= keycode_decode(key_code[1:0]);
	end

	always @(*) begin
		if (~is_key_pressed) begin
			keyboard_row <= 4'b1111;
		end else begin
			if (col_keycode == key_code[3:2]) begin
				keyboard_row <= row_keyarray;
			end else begin
				keyboard_row <= 4'b1111;
			end
		end
	end

	// Instantiate the Unit Under Test (UUT)
	gomoku_main uut (
		.clk(clk), 
		.buzzer_clk(buzzer_clk), 
		.led_scan_clk(led_scan_clk), 
		.kb_scan_clk(kb_scan_clk), 
		.led_flicker_clk_slow(led_flicker_clk_slow), 
		.led_flicker_clk_fast(led_flicker_clk_fast), 
		.rst_n(rst_n), 
		.sw_power(sw_power), 
		.btn_reset(btn_reset), 
		.btn_ok(btn_ok), 
		.buzzer(buzzer), 
		.led_red_status(led_red_status), 
		.led_green_status(led_green_status), 
		.led_row(led_row), 
		.led_col_red(led_col_red), 
		.led_col_green(led_col_green), 
		.keyboard_row(keyboard_row), 
		.keyboard_col(keyboard_col)
	);
    
    always #0.5 clk = ~clk;
    always #25 buzzer_clk = ~buzzer_clk;
    always #25 led_scan_clk = ~led_scan_clk;
    always #25 kb_scan_clk = ~kb_scan_clk;
    
    always #200 led_flicker_clk_slow = ~led_flicker_clk_slow;
    always #400 led_flicker_clk_fast = ~led_flicker_clk_fast;

	initial begin
		clk = 0;
		buzzer_clk = 0;
		led_scan_clk = 0;
		kb_scan_clk = 0;
		led_flicker_clk_slow = 0;
		led_flicker_clk_fast = 0;
		rst_n = 0;
		sw_power = 0;
		btn_reset = 0;
		btn_ok = 0;
		keyboard_row = 0;
        is_key_pressed = 0;

		#10;
        
        rst_n = 1;
        
        #1000;
        
        sw_power = 1;
        
        
        wait(uut.memrst_done == 1);

        #1000;
        
		task_press_key(4'h1);
		#600 task_key_up();

        #2000;
        
		task_press_key(4'hf);
		#500 task_key_up();
        
        #1000;
        
        btn_ok = 1;
        #500;
        btn_ok = 0;
        
        #10000;
        
        $stop;

	end
      
endmodule

