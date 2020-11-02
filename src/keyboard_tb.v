`timescale 1ms / 1us

module keyboard_tb;
    // Inputs
    reg scan_clk;
    reg clk;
    reg rst_n;
    reg en;
    wire [3:0] keyboard_col;

    // Outputs
    reg [3:0] keyboard_row;

    reg is_key_pressed;
    reg [3:0] key_code;

    reg [1:0] col_keycode;
    reg [3:0] row_keyarray;

    wire kb_key_valid;
    reg  kb_key_ready;
    wire[3:0] kb_pressed_index;

    // Instantiate the Unit Under Test (UUT)
    keyboard uut (
        .scan_clk(scan_clk),
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .keyboard_row(keyboard_row),
        .keyboard_col(keyboard_col),

        .key_valid(kb_key_valid),
        .key_ready(kb_key_ready),

        .pressed_index(kb_pressed_index)
    );

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
            key_code = keycode;
            is_key_pressed = 1;
        end
    endtask

    task task_key_up();
        is_key_pressed = 0;
    endtask

    integer tested_count = 0;
    integer failed_count = 0;
    task test_key_press(input [3:0] key, input real keydown_duration);
        begin
            task_press_key(key);
            if (en) begin
                wait(kb_key_valid == 1);
                #0.5;
                kb_key_ready = 1;
                if (kb_pressed_index != key) begin
                    $display("[ERROR] [%0d] keycode should be %4b but %4b",
                             tested_count,  key, kb_pressed_index);
                    failed_count = failed_count + 1;
                end

                wait(kb_key_valid == 0);
                kb_key_ready = 0;
            end
            #(keydown_duration) task_key_up();
            tested_count = tested_count + 1;
        end
    endtask

    always #0.5 scan_clk <= ~scan_clk;
    always #0.1 clk <= ~clk;

    initial begin
        // Initialize Inputs
        scan_clk = 0;
        clk = 0;
        rst_n = 0;
        en = 0;
        keyboard_row = 0;
        is_key_pressed = 0;
        key_code = 0;
        kb_key_ready = 0;

        // Wait 100 ns for global reset to finish
        #2;

        rst_n = 1;

        #10.4 test_key_press('h1, 30.4);
        
        #20.3 test_key_press(4'h5, 30.3);
        #20.3 test_key_press(4'ha, 45.4);
        
        #10 en = 1;

        #20.3 test_key_press(4'he, 75.3);
        #20.3 test_key_press(4'hf, 50.4);

        #10 en = 0;

        #20.3 test_key_press(4'h0, 20.4);

        #20.3 en = 1;

        #20.3 test_key_press(4'h0, 20.3);
        #20.3 test_key_press(4'h1, 25.4);
        #20.3 test_key_press(4'h2, 25.3);
        #20.3 test_key_press(4'h3, 20.4);
        #20.3 test_key_press(4'h4, 20.3);
        #20.3 test_key_press(4'h5, 25.4);
        #20.3 test_key_press(4'h6, 25.3);
        #20.3 test_key_press(4'h7, 20.4);
        #20.3 test_key_press(4'h8, 20.3);
        #20.3 test_key_press(4'h9, 25.4);
        #20.3 test_key_press(4'ha, 25.3);
        #20.3 test_key_press(4'hb, 20.4);
        #20.3 test_key_press(4'hc, 20.3);
        #20.3 test_key_press(4'hd, 25.4);
        #20.3 test_key_press(4'he, 25.3);
        #20.3 test_key_press(4'hf, 20.4);

        #20.3;

        if (failed_count == 0) begin
            $display("=== TEST PASS ===");
        end else begin
            $display("=== TEST FAILED ===");
        end
        $display("tested: %0d, failed: %0d", tested_count, failed_count);

        $stop();

    end

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
endmodule

