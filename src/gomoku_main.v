`include "common.vh"
`include "game_judger.vh"

module gomoku_main(
    input clk,
    input buzzer_clk,
    input buzzer_clk_2,
    input led_scan_clk,
    input kb_scan_clk,
    input led_flicker_clk_slow,
    input led_flicker_clk_fast,
    input countdown_clk,

    input rst_n,

    // KEY Pin define
    input sw_power,
    input btn_reset,
    input btn_ok,

    // Buzzer output
    output buzzer_out,

    // LED Pin define
    output reg led_red_status,
    output reg led_green_status,

    /// LED Matrix
    output [7:0] led_row,
    output [7:0] led_col_red,
    output [7:0] led_col_green,

    output reg [3:0] num_countdown_h,
    output reg [3:0] num_countdown_l,
    output           countdown_en,
    output reg [3:0] red_win_count,
    output reg [3:0] green_win_count,

    // SPI interface
`ifndef SPI_MEM_EMU
    output spi_clk,
    output spi_cs,
    input  spi_si,
    output spi_so,
`endif

    // keyboard
    output [3:0] keyboard_col,
    input  [3:0] keyboard_row,

    output reg   led_flicker_clk_rst,
    output reg   countdown_clk_rst
);
    // === Game states ===
    reg current_active_side;
    reg [2:0] x_pos;
    reg [2:0] y_pos;
    wire [5:0] pos = {y_pos, x_pos};

    reg [1:0] presseed_keys; // {y_pressed, x_pressed}

    reg [5:0] piece_count;
    reg screen_flicker_done;

    // Control signals
    wire s_judge_finish;
    wire game_draw = piece_count == 6'd63;
    reg  timed_out;

    // FSM
    localparam S_STOPPED     = 3'd0;
    localparam S_STARTING    = 3'd1;
    localparam S_RESET_STATE = 3'd2;
    localparam S_WAIT_INPUT  = 3'd3;
    localparam S_JUDGE       = 3'd4;
    localparam S_MEM_WRITE   = 3'd5;
    localparam S_END         = 3'd6;

    reg [2:0] state, next_state;

    reg  mem_wr_en;
    reg  [5:0] mem_addr;
    wire [7:0] mem_rd_data;
    reg  [1:0] mem_wr_data;

    reg  mem_en;
    wire mem_valid;

`ifndef SPI_MEM_EMU
    spi_mem spi_mem_inst(
        .clk(clk),    // Clock
        .rst_n(rst_n),  // Asynchronous reset active low

        // Data interface
        .wr_en(mem_wr_en),
        .addr(mem_addr),
        .rd_data(mem_rd_data),
        .wr_data(mem_wr_data),

        // SPI interface
        .spi_clk(spi_clk),
        .spi_cs(spi_cs),
        .spi_si(spi_si),
        .spi_so(spi_so),

        // Callback interface
        .en(mem_en),
        .valid(mem_valid)
    );
`else
    spi_mem_emu spi_mem_emu_inst(
        .clk(clk),    ///* Clock
        .rst_n(rst_n),  //*/ Asynchronous reset active low

        // Data interface
        .wr_en(mem_wr_en),
        .addr(mem_addr),
        .rd_data(mem_rd_data),
        .wr_data({6'b0, mem_wr_data}),

        // Callback interface
        .en(mem_en),
        .valid(mem_valid)
    );
`endif

    // Mem write
    reg mw_mem_en;
    reg mw_mem_valid;
    reg [5:0] mw_mem_addr;
    reg [1:0] mw_mem_wr_data;

    // === Mem reset ===
    wire memrst_en;
    wire memrst_done;
    wire memrst_we;

    wire memrst_mem_en;
    reg  memrst_mem_valid;
    wire [5:0] memrst_mem_addr;
    wire [1:0] memrst_mem_wr_data;

    mem_reset memrst_inst(
        .clk(clk),
        .en(memrst_en), // Clock Enable
        .rst_n(rst_n),  // Asynchronous reset active low

        .mem_en(memrst_mem_en),
        .mem_valid(memrst_mem_valid),
        .mem_addr(memrst_mem_addr),
        .mem_data(memrst_mem_wr_data),

        .done(memrst_done)
    );

    // === LED display signals ===
    wire led_flicker_clk;

    wire led_scanner_en;

    wire led_screen_flicker_en;   // enable when state == S_STARTING

    wire led_point_flicker_en;
    wire [5:0] led_point_flicker_pos;
    wire led_point_flicker_color;

    reg led_color_flicker_en;
    reg led_color_flicker_color;

    wire scanner_mem_busy;
    wire scanner_mem_en;
    reg  scanner_mem_valid;
    wire [5:0] scanner_mem_addr;
    wire [1:0] scanner_mem_rd_data = mem_rd_data[1:0];

    display_led_scanner scanner_inst(
        .clk(clk),
        .scan_clk(led_scan_clk),
        .en(led_scanner_en),
        .rst_n(rst_n),

        .flicker_clk(led_flicker_clk),

        .screen_flicker_en(led_screen_flicker_en),

        .point_flicker_en(led_point_flicker_en),
        .point_flicker_pos(led_point_flicker_pos),
        .point_flicker_color(led_point_flicker_color),

        .color_flicker_en(color_flicker_en),
        .color_flicker_color(color_flicker_color),

        .mem_busy(scanner_mem_busy),
        .mem_en(scanner_mem_en),
        .mem_valid(scanner_mem_valid),
        .mem_addr(scanner_mem_addr),
        .mem_data(scanner_mem_rd_data),

        .led_row(led_row),
        .led_col_red(led_col_red),
        .led_col_green(led_col_green)
    );

    // === keyboard signals ===
    wire kb_en;

    wire [3:0] kb_pressed_key;
    wire kb_key_valid;
    reg  kb_key_received;

    keyboard kb_inst(
        .scan_clk(kb_scan_clk), // low speed scan clock
        .clk(clk),
        .en(kb_en), // enable
        .rst_n(rst_n),

        .keyboard_row(keyboard_row),
        .keyboard_col(keyboard_col),

        .pressed_index(kb_pressed_key),
        .key_valid(kb_key_valid),
        .key_received(kb_key_received)
    );

    // btn_ok test
    reg btn_ok_r;
    reg btn_ok_rr;
    always @(posedge clk) begin : proc_btn_ok_r
        btn_ok_r <= btn_ok;
        btn_ok_rr <= btn_ok_r;
    end

    // capture key-down (lo to hi transition) event only
    reg btn_ok_down;
    always @(posedge clk or negedge rst_n) begin : proc_btn_ok_down
        if(~rst_n) begin
            btn_ok_down <= 0;
        end else begin
            if (state == S_WAIT_INPUT) begin
                btn_ok_down <= btn_ok_down || (btn_ok_rr == 0 && btn_ok_r == 1);
            end else begin
                btn_ok_down <= 0;
            end
        end
    end
    // wire btn_ok_down = btn_ok_rr == 0 && btn_ok_r == 1;

    // === Judger signals ===
    wire judger_en;

    wire [1:0] judger_result;
    wire       judger_done;

    wire judger_mem_en;
    reg  judger_mem_valid;
    wire [5:0] judger_mem_addr;
    wire [1:0] judger_mem_rd_data = mem_rd_data[1:0];

    game_judger judger_inst(
        .clk(clk),    // Clock
        .en(judger_en),
        .rst_n(rst_n),

        .color(current_active_side),
        .pos(pos),

        .mem_en(judger_mem_en),
        .mem_valid(judger_mem_valid),
        .mem_addr(judger_mem_addr),
        .mem_data(judger_mem_rd_data),

        .result(judger_result),
        .done(judger_done)
    );

    // Buzzer
    wire buzzer_en;
    buzzer buzzer_inst(
        .clk(buzzer_clk),     // Clock 1MHz
        .clk_2(buzzer_clk_2), // Clock 200Hz
        .rst_n(rst_n),
        .en(buzzer_en),

        .buzzer_out(buzzer_out)
    );

    // FSM logic
    always @(posedge clk or negedge rst_n) begin : proc_state
        if (~rst_n) begin
            state <= S_STOPPED;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin : proc_next_state
        next_state = state;
        case (state)
            S_STOPPED:
                if (sw_power) next_state = S_STARTING;
            S_STARTING:
                if (screen_flicker_done) next_state = S_RESET_STATE;
            S_RESET_STATE:
                if (memrst_done) next_state = S_WAIT_INPUT;
            S_WAIT_INPUT: begin
                if (presseed_keys == 2'b11 && (btn_ok_down || timed_out) && ~scanner_mem_en) begin
                    // btn_ok_down: both x and y pos were input
                    // timed_out:   timed-out and auto commit
                    next_state = S_JUDGE;
                end
            end
            S_JUDGE:
                if (judger_done) begin
                    if (judger_result == `JUDGER_WIN) begin
                        next_state = S_MEM_WRITE;
                    end else if (game_draw && judger_result == `JUDGER_VALID) begin
                        next_state = S_MEM_WRITE;
                    end else begin
                        if (judger_result == `JUDGER_VALID) begin
                            next_state = S_MEM_WRITE;
                        end else begin
                            next_state = S_WAIT_INPUT;
                        end
                    end
                end
            S_MEM_WRITE: begin
                if (mw_mem_valid && mw_mem_en) begin
                    if (judger_result == `JUDGER_WIN || (game_draw && judger_result == `JUDGER_VALID)) begin
                        next_state = S_END;
                    end else begin
                        next_state = S_WAIT_INPUT;
                    end
                end
            end
            S_END:
                next_state = S_END;
            default:
                next_state = S_STOPPED;
        endcase

        if (btn_reset) begin
            next_state = S_RESET_STATE;
        end

        if (~sw_power) begin
            next_state = S_STOPPED;
        end
    end

    // Screen flicker
    reg [1:0] screen_flicker_count;
    reg screen_flicker_last_state_r;
    always @(posedge clk) begin : proc_screen_flicker_last_state_r
        screen_flicker_last_state_r <= led_flicker_clk;
    end

    always @(posedge clk or negedge rst_n) begin : proc_screen_flicker_count
        if (~rst_n) begin
            screen_flicker_count <= 0;
        end else begin
            if (state == S_STARTING) begin
                if (screen_flicker_last_state_r == 1 && led_flicker_clk == 0) begin
                     screen_flicker_count <= screen_flicker_count + 1'b1;
                end
            end else if (next_state == S_STARTING) begin
                screen_flicker_count <= 0;
            end
        end
    end

    always @(*) begin : proc_screen_flicker_done
        screen_flicker_done <= screen_flicker_count == 2;
    end

    assign s_judge_finish = (state == S_JUDGE) && judger_done;

    // Game state transfer
    always @(posedge clk or negedge rst_n) begin : proc_state_xfer
        if (~rst_n) begin
            current_active_side <= `SIDE_RED;
            piece_count <= 0;
        end else begin
            if (state == S_RESET_STATE) begin
                current_active_side <= `SIDE_RED;
                piece_count <= 0;

            end else if (timed_out && presseed_keys != 2'b11 && next_state == S_WAIT_INPUT) begin
                current_active_side <= ~current_active_side;

            end if (s_judge_finish && judger_result != `JUDGER_WIN) begin
                current_active_side <= ~current_active_side;
                if (judger_result == `JUDGER_VALID && ~game_draw) begin
                    piece_count <= piece_count + 1'b1;
                end
            end
        end
    end

    // Clock reset
    always @(posedge clk or negedge rst_n) begin : proc_led_flicker_clk_rst
        if (~rst_n) begin
            led_flicker_clk_rst <= 0;
            countdown_clk_rst <= 0;
        end else begin
            led_flicker_clk_rst <= state != S_STARTING && next_state == S_STARTING;
            countdown_clk_rst   <= s_judge_finish;
        end
    end

    // Status LED output
    always @(*) begin : proc_led_status
        if (state == S_END && game_draw) begin
            led_red_status   = led_flicker_clk_fast;
            led_green_status = led_flicker_clk_fast;
        end else begin
            led_red_status   = state == S_WAIT_INPUT && current_active_side == `SIDE_RED;
            led_green_status = state == S_WAIT_INPUT && current_active_side == `SIDE_GREEN;
        end
    end

    // Countdown logic
    reg countdown_clk_r;
    assign countdown_en = state == S_WAIT_INPUT;
    wire countdown_next = countdown_clk == 1 && countdown_clk_r == 0;
    
    always @(posedge clk or negedge rst_n) begin : proc_timed_out
        if(~rst_n) begin
            timed_out <= 0;
        end else begin
            if (state == S_WAIT_INPUT) begin
                timed_out <= timed_out || (countdown_next && num_countdown_h == 0 && num_countdown_l == 0);
                if (presseed_keys != 2'b11 && timed_out) begin
                    timed_out <= 0;
                end
            end else begin
                timed_out <= 0;
            end
        end
    end

    always @(posedge clk) begin : proc_countdown_clk_r
        countdown_clk_r <= countdown_clk;
    end

    always @(posedge clk or negedge rst_n) begin : proc_countdown
        if (~rst_n) begin
            num_countdown_h <= 0;
            num_countdown_l <= 0;
        end else begin
            if (~countdown_en || timed_out) begin
                num_countdown_h <= 2;
                num_countdown_l <= 5;
            end else if (countdown_next) begin
                if (num_countdown_l == 0) begin
                    num_countdown_h <= num_countdown_h - 1'b1;
                    num_countdown_l <= 9;
                end else begin
                    num_countdown_l <= num_countdown_l - 1'b1;
                end
            end
        end
    end

    // Win counting
    always @(posedge clk or negedge rst_n) begin : proc_win_count
        if (~rst_n) begin
            red_win_count   <= 0;
            green_win_count <= 0;
        end else begin
            if (~sw_power) begin
                red_win_count   <= 0;
                green_win_count <= 0;
            end else if (s_judge_finish && judger_result == `JUDGER_WIN) begin
                if (current_active_side == `SIDE_RED) begin
                    red_win_count   <= red_win_count + 1'b1;
                end else begin
                    green_win_count <= green_win_count + 1'b1;
                end
            end
        end
    end

    // LED display
    assign led_scanner_en = state != S_STOPPED && state != S_RESET_STATE;
    assign led_screen_flicker_en = state == S_STARTING;

    assign led_point_flicker_en = state == S_WAIT_INPUT && presseed_keys == 2'b11;
    assign led_point_flicker_color = current_active_side;

    assign led_flicker_clk = (state == S_STARTING || state == S_END) ? led_flicker_clk_slow : led_flicker_clk_fast;

    assign led_point_flicker_pos = pos;

    assign color_flicker_en = state == S_END && ~game_draw;
    assign color_flicker_color = current_active_side;

    // Keyboard
    assign kb_en = state == S_WAIT_INPUT;

    always @(posedge clk) begin : proc_keyboard
        if (~rst_n) begin
            kb_key_received <= 0;
        end else begin
            if (kb_key_valid) begin
                kb_key_received <= 1;
            end else begin
                kb_key_received <= 0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin : proc_recv_keys
        if (~rst_n) begin
            presseed_keys <= 0;
            {y_pos, x_pos} <= 0;
        end else begin
            if (kb_key_valid) begin
                if (kb_pressed_key[3] == 1) begin // x-pos
                    x_pos <= kb_pressed_key[2:0];
                    presseed_keys[0] <= 1;
                end else begin // y-pos
                    y_pos <= kb_pressed_key[2:0];
                    presseed_keys[1] <= 1;
                end
            end
            if (timed_out || s_judge_finish || state == S_RESET_STATE) begin
                presseed_keys <= 0;
            end
        end
    end

    // Judger
    assign judger_en = state == S_JUDGE;

    // Mem reset
    assign memrst_en = state == S_RESET_STATE;

    // Memory read/write mux/demux
    always @(*) begin : proc_ram_write
        mem_wr_en = 0;
        mem_en = 0;
        mem_addr = 0;
        mem_wr_data = 0;

        memrst_mem_valid = 0;
        scanner_mem_valid = 0;
        judger_mem_valid = 0;
        mw_mem_valid = 0;
        case (state)
            S_RESET_STATE: begin
                mem_wr_en = 1;
                mem_en = memrst_mem_en;
                mem_addr = memrst_mem_addr;
                mem_wr_data = memrst_mem_wr_data;
                memrst_mem_valid = mem_valid;
            end
            S_WAIT_INPUT: begin
                mem_wr_en = 0;
                mem_en = scanner_mem_en;
                mem_addr = scanner_mem_addr;
                scanner_mem_valid = mem_valid;
            end
            S_JUDGE: begin
                mem_wr_en = 0;
                mem_en = judger_mem_en;
                mem_addr = judger_mem_addr;
                judger_mem_valid = mem_valid;
            end
            S_MEM_WRITE: begin
                mem_wr_en = 1;
                mem_en = mw_mem_en;
                mem_addr = mw_mem_addr;
                mem_wr_data = mw_mem_wr_data;
                mw_mem_valid = mem_valid;
            end
        endcase
    end

    assign scanner_mem_busy = next_state != S_WAIT_INPUT;

    // RAM writing
    assign mw_mem_addr = pos;
    always @(posedge clk or negedge rst_n) begin : proc_ram_we
        if (~rst_n) begin
            mw_mem_en <= 0;
            mw_mem_wr_data <= 0; 
        end else begin
            if (mw_mem_en) begin
                if (mw_mem_valid) begin
                    mw_mem_en <= 0;
                end
            end else begin
                // write pos to mem
                if (s_judge_finish && (judger_result == `JUDGER_VALID || judger_result == `JUDGER_WIN)) begin
                    mw_mem_en <= 1;
                    mw_mem_wr_data <= current_active_side ? 2'b10 : 2'b01;
                end
            end
        end
    end

    // Buzzer
    assign buzzer_en = state == S_END;

endmodule
