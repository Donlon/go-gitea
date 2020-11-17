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
    output [7:0] seg_data,
    output [7:0] seg_sel,

    // LED Matrix
    output [7:0] led_row,
    output [7:0] led_col_red,
    output [7:0] led_col_green,

    output spi_clk,
    output spi_cs,
    input  spi_si,
    output spi_so,

    // keyboard
    output [3:0] keyboard_col,
    input  [3:0] keyboard_row
);
    // Press buttons
    wire key_reset = btn[0];
    wire key_ok    = btn[7];
    wire rst_n     = ~btn[6];

    wire sw_power  = switch[7];

    wire key_reset_deb;
    wire key_ok_deb;

    // LEDs
    wire led_red_status;
    wire led_green_status;

    assign led[15] = led_red_status;
    assign led[1]  = led_green_status;

    // Countdown number
    wire [3:0] num_countdown_h, num_countdown_l;
    wire countdown_en;

    // Win count
    wire [3:0] red_win_count;
    wire [3:0] green_win_count;

    // Clock
    wire clk_2k;
    wire clk_100Hz;
    wire clk_200Hz;
    wire clk_2Hz;
    wire clk_1Hz;

    wire led_scan_clk = clk_2k;
    wire kb_scan_clk = clk_100Hz;
    wire key_debounce_clk = clk_100Hz;
    wire buzzer_clk = clk;
    wire buzzer_clk_2 = clk_200Hz;
    wire led_flicker_clk_slow = clk_1Hz;
    wire led_flicker_clk_fast = clk_2Hz;
    wire countdown_clk = clk_1Hz;

    wire led_flicker_clk_rst;
    wire countdown_clk_rst;

    clock_gen #(
        .IN_FREQ(1000000) // 1M
    ) clock_gen_inst(
        .clk_in(clk),
        .rst_n(rst_n),  // Asynchronous reset active low

        .clk_2k(clk_2k),
        .clk_100Hz(clk_100Hz),
        .clk_200Hz(clk_200Hz),
        .clk_2Hz(clk_2Hz),
        .clk_1Hz(clk_1Hz),

        .clk_2Hz_rst(led_flicker_clk_rst),
        .clk_1Hz_rst(countdown_clk_rst)
    );

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

    gomoku_main main(
        .clk(clk),
        .buzzer_clk(buzzer_clk),
        .buzzer_clk_2(buzzer_clk_2),
        .led_scan_clk(led_scan_clk),
        .kb_scan_clk(kb_scan_clk),
        .led_flicker_clk_slow(led_flicker_clk_slow),
        .led_flicker_clk_fast(led_flicker_clk_fast),
        .countdown_clk(countdown_clk),

        .rst_n(rst_n),

        .sw_power(sw_power), // power switch
        .btn_reset(key_reset_deb), 
        .btn_ok(key_ok_deb),

        // Buzzer output
        .buzzer_out(buzzer),

        // LED Pin define
        .led_red_status(led_red_status),
        .led_green_status(led_green_status),

        /// LED Matrix
        .led_row(led_row),
        .led_col_red(led_col_red),
        .led_col_green(led_col_green),

        .num_countdown_h(num_countdown_h),
        .num_countdown_l(num_countdown_l),
        .countdown_en(countdown_en),
        .red_win_count(red_win_count),
        .green_win_count(green_win_count),

        .spi_clk(spi_clk),
        .spi_cs(spi_cs),
        .spi_si(spi_si),
        .spi_so(spi_so),

        // keyboard
        .keyboard_row(keyboard_row),
        .keyboard_col(keyboard_col),

        .led_flicker_clk_rst(led_flicker_clk_rst),
        .countdown_clk_rst(countdown_clk_rst)
    );

    led_seg_scanner seg_scanner(
        .scan_clk(clk_2k),    // Clock
        .rst_n(rst_n),  // Asynchronous reset active low
    
        .digit_0(red_win_count),
        .digit_1(0),
        .digit_2(0),
        .digit_3(num_countdown_h),
        .digit_4(num_countdown_l),
        .digit_5(0),
        .digit_6(0),
        .digit_7(green_win_count),

        .digit_en_0(1),
        .digit_en_1(0),
        .digit_en_2(0),
        .digit_en_3(countdown_en),
        .digit_en_4(countdown_en),
        .digit_en_5(0),
        .digit_en_6(0),
        .digit_en_7(1),

        .seg_data(seg_data),
        .seg_sel(seg_sel)
    );

    //assign {led[15], led[14]} = main.state;

endmodule
