module keyboard(
    input clk,
    input scan_clk, // low speed scan clock
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

    always @(*) begin
        casez (keyboard_row)
            4'b0???: row_code[1:0] <= 2'b00;
            4'b10??: row_code[1:0] <= 2'b01;
            4'b110?: row_code[1:0] <= 2'b10;
            4'b1110: row_code[1:0] <= 2'b11;
            default: row_code[1:0] <= 2'b00;
        endcase
    end

    reg key_pressed; // flag of first key press
    reg keydown_status; // cross clock domain
    reg keydown_status_r;

    always @(negedge scan_clk or negedge rst_n_) begin
        if (~rst_n_) begin
            pressed_index <= 4'b0;
            key_pressed <= 0;
            keydown_status <= 0;
        end else if (keyboard_row != 4'b1111) begin
            if (pressed_index != {row_code, scan_seq} || ~key_pressed) begin // key changed
                key_pressed <= 1;
                keydown_status <= ~keydown_status;
                pressed_index[3:2] <= row_code;
                pressed_index[1:0] <= scan_seq;
            end
        end
    end

    always @(posedge clk or negedge rst_n_) begin
        if (~rst_n_) begin
            key_valid <= 0;
        end else begin
            if (keydown_status != keydown_status_r) begin
                key_valid <= 1;
            end else if (key_valid && key_ready) begin
                key_valid <= 0;
            end
        end
    end

    always @(posedge clk) begin : proc_keydown_status_r
        keydown_status_r <= keydown_status;
    end
endmodule
