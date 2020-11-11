`timescale 1us / 1ns

module gomoku_main_draw_tb;

    // Inputs
    reg clk;
    reg buzzer_clk;
    reg buzzer_clk_2;
    reg led_scan_clk;
    reg kb_scan_clk;
    reg led_flicker_clk_slow;
    reg led_flicker_clk_fast;
    reg countdown_clk;
    reg rst_n;
    reg sw_power;
    reg btn_reset;
    reg btn_ok;
    reg [3:0] keyboard_row;

    // Outputs
    wire buzzer;
    wire led_red_status;
    wire led_green_status;
    wire [3:0] num_countdown_h;
    wire [3:0] num_countdown_l;
    wire [3:0] red_win_count;
    wire [3:0] green_win_count;
    wire [7:0] led_row;
    wire [7:0] led_col_red;
    wire [7:0] led_col_green;
    wire [3:0] keyboard_col;
    wire led_flicker_clk_rst;
    wire countdown_clk_rst;

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

    task task_enter_position(integer x, integer y);
        begin
            task_press_key(x[2:0] + 8);
            #50 task_key_up();

            #50;

            task_press_key(y[2:0]);
            #50 task_key_up();

            #50;

            btn_ok = 1;
            #50 btn_ok = 0;
        end
    endtask

    always @(*) begin
        col_keycode  <= keycode_encode(keyboard_col);
        row_keyarray <= keycode_decode(key_code[3:2]);
    end

    always @(*) begin
        if (~is_key_pressed) begin
            keyboard_row <= 4'b1111;
        end else begin
            if (col_keycode == key_code[1:0]) begin
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
        .buzzer_clk_2(buzzer_clk_2), 
        .led_scan_clk(led_scan_clk), 
        .kb_scan_clk(kb_scan_clk), 
        .led_flicker_clk_slow(led_flicker_clk_slow), 
        .led_flicker_clk_fast(led_flicker_clk_fast), 
        .countdown_clk(countdown_clk),
        .rst_n(rst_n), 
        .sw_power(sw_power), 
        .btn_reset(btn_reset), 
        .btn_ok(btn_ok), 
        .buzzer_out(buzzer), 
        .led_red_status(led_red_status), 
        .led_green_status(led_green_status), 
        .led_row(led_row), 
        .led_col_red(led_col_red), 
        .led_col_green(led_col_green),
        .num_countdown_h(num_countdown_h),
        .num_countdown_l(num_countdown_l),
        .red_win_count(red_win_count),
        .green_win_count(green_win_count), 
        .keyboard_row(keyboard_row), 
        .keyboard_col(keyboard_col),

        .led_flicker_clk_rst(led_flicker_clk_rst),
        .countdown_clk_rst(countdown_clk_rst)
    );

    always #0.5 clk = ~clk;
    always #8 buzzer_clk = ~buzzer_clk;
    always #8 led_scan_clk = ~led_scan_clk;
    always #4 kb_scan_clk = ~kb_scan_clk;

    always #100 countdown_clk        = ~countdown_clk;
    always #100 led_flicker_clk_slow = ~led_flicker_clk_slow;
    always #150 led_flicker_clk_fast = ~led_flicker_clk_fast;

    always @(posedge led_flicker_clk_rst) begin : proc_led_flicker_clk_rst
        led_flicker_clk_slow = 0;
        led_flicker_clk_fast = 0;
    end

    always @(posedge countdown_clk_rst) begin : proc_countdown_clk_rst
        countdown_clk = 0; // TODO: use fork-join task to reset the clock
    end

    // initial begin
    //     wait (uut)
    // end

    initial begin
        clk = 0;
        buzzer_clk = 0;
        led_scan_clk = 0;
        kb_scan_clk = 0;
        countdown_clk = 0;
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

        #100 task_enter_position(0, 0); // Red
        #100 task_enter_position(0, 1); // Green
        #100 task_enter_position(0, 2); // Red
        #100 task_enter_position(0, 3); // Green
        #100 task_enter_position(0, 4); // Red
        #100 task_enter_position(0, 5); // Green
        #100 task_enter_position(0, 6); // Red
        #100 task_enter_position(0, 7); // Green

        #100 task_enter_position(1, 0); // Red
        #100 task_enter_position(1, 1); // Green
        #100 task_enter_position(1, 2); // Red
        #100 task_enter_position(1, 3); // Green
        #100 task_enter_position(1, 4); // Red
        #100 task_enter_position(1, 5); // Green
        #100 task_enter_position(1, 6); // Red
        #100 task_enter_position(1, 7); // Green

        #100 task_enter_position(2, 0); // Red
        #100 task_enter_position(2, 1); // Green
        #100 task_enter_position(2, 2); // Red
        #100 task_enter_position(2, 3); // Green
        #100 task_enter_position(2, 4); // Red
        #100 task_enter_position(2, 5); // Green
        #100 task_enter_position(2, 6); // Red
        #100 task_enter_position(2, 7); // Green

        #100 task_enter_position(3, 0); // Red
        #100 task_enter_position(3, 1); // Green
        #100 task_enter_position(3, 2); // Red
        #100 task_enter_position(3, 3); // Green
        #100 task_enter_position(3, 4); // Red
        #100 task_enter_position(3, 5); // Green
        #100 task_enter_position(3, 6); // Red
        #100 task_enter_position(3, 7); // Green

        #100 task_enter_position(2, 2); // Red
        //
        #100 task_enter_position(4, 0); // Green
        #100 task_enter_position(4, 1); // Red
        #100 task_enter_position(4, 2); // Green
        #100 task_enter_position(4, 3); // Red
        #100 task_enter_position(4, 4); // Green
        #100 task_enter_position(4, 5); // Red
        #100 task_enter_position(4, 6); // Green
        #100 task_enter_position(4, 7); // Red

        #100 task_enter_position(5, 0); // Green
        #100 task_enter_position(5, 1); // Red
        #100 task_enter_position(5, 2); // Green
        #100 task_enter_position(5, 3); // Red
        #100 task_enter_position(5, 4); // Green
        #100 task_enter_position(5, 5); // Red
        #100 task_enter_position(5, 6); // Green
        #100 task_enter_position(5, 7); // Red

        #100 task_enter_position(6, 0); // Green
        #100 task_enter_position(6, 1); // Red
        #100 task_enter_position(6, 2); // Green
        #100 task_enter_position(6, 3); // Red
        #100 task_enter_position(6, 4); // Green
        #100 task_enter_position(6, 5); // Red
        #100 task_enter_position(6, 6); // Green
        #100 task_enter_position(6, 7); // Red

        #100 task_enter_position(7, 0); // Green
        #100 task_enter_position(7, 1); // Red
        #100 task_enter_position(7, 2); // Green
        #100 task_enter_position(7, 3); // Red
        #100 task_enter_position(7, 4); // Green
        #100 task_enter_position(7, 5); // Red
        #100 task_enter_position(7, 6); // Green
        #100 task_enter_position(7, 7); // Red

        #100 task_enter_position(3, 1); // Green

        #10000;
        // Reset
        btn_reset = 1;
        #1000 btn_reset = 0;
 
        #10000;
        
        $stop;

    end

endmodule

