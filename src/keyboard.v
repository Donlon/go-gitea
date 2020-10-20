module keyboard(
    input scan_clk, // low speed scan clock
    input clk,
    input en, // enable
    input rst_n,

    output reg [3:0] keyboard_col,
    input [3:0]      keyboard_row,

    output reg [3:0] pressed_index,
    output reg       key_valid,
    input            key_ready
);

    wire rst_n_ = rst_n && en;

    reg [1:0] row_code;

    reg [1:0] scan_seq;

    wire col_injection = scan_seq != 2'b11;

    always @(posedge scan_clk or negedge rst_n_) begin
        if (~rst_n_) begin
            scan_seq <= 2'b11;
        end else begin
            scan_seq <= scan_seq + 1'b1;
        end
    end

    always @(posedge scan_clk or negedge rst_n_) begin
        if (~rst_n_) begin
            keyboard_col <= 4'b1111;
        end else begin
            keyboard_col <= {col_injection, keyboard_col[3:1]};
        end
    end

    reg press_status;
    reg press_last_status;

    always @(*) begin
        casez (keyboard_row)
            4'b0???: row_code[1:0] <= 2'b00;
            4'b10??: row_code[1:0] <= 2'b01;
            4'b110?: row_code[1:0] <= 2'b10;
            4'b1110: row_code[1:0] <= 2'b11;
            default: row_code[1:0] <= 2'b00;
        endcase
    end

    reg key_pressed;

    always @(negedge scan_clk or negedge rst_n_) begin
        if (~rst_n_) begin
            pressed_index <= 4'b0;
            press_status <= 0;
            key_pressed <= 0;
        end else if (keyboard_row != 4'b1111) begin
            if (pressed_index != {scan_seq, row_code} || ~key_pressed) begin // key changed
                key_pressed <= 1;
                press_status <= ~press_status; // key press detected
                pressed_index[3:2] <= scan_seq;
                pressed_index[1:0] <= row_code;
            end
        end
    end

    always @(posedge clk or negedge rst_n_) begin
        if (~rst_n_) begin
            key_valid <= 0;
        end else begin
            if (press_status != press_last_status) begin
                key_valid <= 1;
            end
            if (key_valid && key_ready) begin
                key_valid <= 0;
            end
            press_last_status <= press_status; 
        end
    end
endmodule
