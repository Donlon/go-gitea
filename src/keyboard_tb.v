`timescale 1ms / 1us

module keyboard_tb;
    // Inputs
    reg scan_clk;
    reg clk;
    reg rst_n;
    reg en;
    reg [3:0] keyboard_col;

    // Outputs
    wire [3:0] keyboard_row;

    reg is_key_pressed;
    reg [3:0] key_code;

    reg [1:0] row_keycode;
    reg [3:0] col_keyarray;

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
                2'b00:   keycode_decode = 4'b1000;
                2'b01:   keycode_decode = 4'b0100;
                2'b10:   keycode_decode = 4'b0010;
                2'b11:   keycode_decode = 4'b0001;
                default: keycode_decode = 4'b0000;
            endcase
        end     
    endfunction

    function [1:0] keycode_encode(input [3:0] code);
        begin
            casez (code)
                4'b1???: keycode_encode = 2'b00;
                4'b01??: keycode_encode = 2'b01;
                4'b001?: keycode_encode = 2'b10;
                4'b0001: keycode_encode = 2'b11;
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

    always #0.5 scan_clk <= ~scan_clk;
    always #0.1 clk <= ~clk;

    initial begin
        // Initialize Inputs
        scan_clk = 0;
        clk = 0;
        rst_n = 0;
        en = 0;
        keyboard_col = 0;
        is_key_pressed = 0;
        key_code = 0;

        // Wait 100 ns for global reset to finish
        #2;

        rst_n = 1;

        #10.4;

        task_press_key(4'h1);
        #20.4;

        task_key_up();
        #20.3;

        task_press_key(4'h5);
        #20.3;

        task_key_up();
        #20.3;

        task_press_key(4'ha);
        #25.4;

        task_key_up();
        en = 1;

        #20.3;

        task_press_key(4'he);
        #25.3;

        task_key_up();

        #20.3;

        task_press_key(4'hf);
        #20.4;

        task_key_up();

        en = 0;

        #20.3;

        task_press_key(4'h0);
        #20.4;

        task_key_up();
        #20.3;

        en = 1;

        task_press_key(4'h5);
        #20.3;

        task_key_up();
        #20.3;

        task_press_key(4'ha);
        #25.4;

        task_key_up();
        #20.3;

        task_press_key(4'he);
        #25.3;

        task_key_up();

        #20.3;

        task_press_key(4'hf);
        #20.4;

        task_key_up();

        #20.3;

        // Add stimulus here

        $finish();

    end

    always @(*) begin
        row_keycode  <= keycode_encode(~keyboard_row);
        col_keyarray <= ~keycode_decode(key_code[1:0]);
    end

    always @(*) begin
        if (~is_key_pressed) begin
            keyboard_col <= 4'b1111;
        end else begin
            if (row_keycode == key_code[3:2]) begin
                keyboard_col <= col_keyarray;
            end else begin
                keyboard_col <= 4'b1111;
            end
        end
    end

    always @(posedge clk) begin : proc_
        if (~rst_n) begin
            kb_key_ready <= 0;
        end else begin
            if (kb_key_valid) begin
                kb_key_ready <= 1;
            end else begin
                kb_key_ready <= 0;
            end
        end
    end

endmodule

