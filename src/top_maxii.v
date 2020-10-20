module top_maxii(
    input clk,

    // KEY Pin define
    input [7:0] btn,

    input [7:0] switch,

    // buzzer Pin define
    output buzzer,

    // LED Pin define
    output [15:0] led,

    // seg pin define
    // output [7:0] seg_data,
    // output [5:0] seg_sel,

    // LED Matrix
    output [7:0] led_row,
    output [7:0] led_col_red,
    output [7:0] led_col_green,

    // keyboard
    output [3:0] keyboard_col,
    input  [3:0] keyboard_row
);
    // Clock
    wire led_scan_clk;
    wire kb_scan_clk;
    wire key_debounce_clk = kb_scan_clk;
    wire buzzer_clk = led_scan_clk;
    wire led_flicker_clk_slow;
    wire led_flicker_clk_fast;

    // Press buttons
    wire key_reset = btn[0];
    wire key_ok    = btn[7];
    wire rst_n     = ~btn[6];
    

    wire sw_power  = switch[7];

    wire key_reset_deb;
    wire key_ok_deb;

    key_debounce debouncer_1(
        .key(key_reset),
        .clk(key_debounce_clk),
        .rst_n(rst_n),
        .key_debounced(key_reset_deb)
    );

    key_debounce debouncer_2(
        .key(key_ok),
        .clk(key_debounce_clk),
        .rst_n(rst_n),
        .key_debounced(key_ok_deb)
    );

    // LEDs
    wire led_red_status;
    wire led_green_status;

    assign led[0] = led_red_status;
    assign led[1] = led_green_status;
    assign led[6] = led_flicker_clk_slow;
    assign led[7] = led_flicker_clk_fast;

    // === Clock generator ===
    clock_gen #(
        .IN_FREQ(1000000) // 1M
    )
    clock_gen_inst(
        .clk_in(clk),
        .rst_n(rst_n),  // Asynchronous reset active low
        
        .clk_2k(led_scan_clk),
        .clk_100Hz(kb_scan_clk),
        .clk_2Hz(led_flicker_clk_slow),
        .clk_1Hz(led_flicker_clk_fast)
    );

    gomoku_main main(
        .clk(clk),
        .buzzer_clk(buzzer_clk),
        .led_scan_clk(led_scan_clk),
        .kb_scan_clk(kb_scan_clk),
        .led_flicker_clk_slow(led_flicker_clk_slow),
        .led_flicker_clk_fast(led_flicker_clk_fast),

        .rst_n(rst_n),

        .sw_power(sw_power), // power switch
        .btn_reset(key_reset_deb), 
        .btn_ok(key_ok_deb),

        // Buzzer output
        .buzzer(buzzer),

        // LED Pin define
        .led_red_status(led_red_status),
        .led_green_status(led_green_status),

        /// LED Matrix
        .led_row(led_row),
        .led_col_red(led_col_red),
        .led_col_green(led_col_green),

        // output [3:0] num_countdown,
        // output [3:0] red_win_count,
        // output [3:0] green_win_count,

        // keyboard
        .keyboard_row(keyboard_row),
        .keyboard_col(keyboard_col)
    );
    
    //assign {led[15], led[14]} = main.state;

endmodule
