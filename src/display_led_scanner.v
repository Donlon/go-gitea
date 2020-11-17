`include "common.vh"

module display_led_scanner (
    input scan_clk,
    input clk,
    input en,
    input rst_n,

    input flicker_clk,

    input screen_flicker_en,

    input point_flicker_en,
    input [5:0] point_flicker_pos,
    input point_flicker_color,

    input color_flicker_en,
    input color_flicker_color,

    input        mem_busy,
    output reg   mem_en,
    input        mem_valid,
    output [5:0] mem_addr,
    input  [1:0] mem_data,

    output reg [7:0] led_row,
    output reg [7:0] led_col_red,
    output reg [7:0] led_col_green
);
    wire rst_n_ = rst_n && en;

    reg [7:0] red_line_buffer, green_line_buffer;

    reg [2:0] current_scan_row;
    wire [2:0] next_scan_row = current_scan_row + 1'b1;

    reg scan_clk_r;
    always @(posedge clk or negedge rst_n_) begin : proc_scan_clk_r
        if(~rst_n_) begin
            scan_clk_r <= 0;
        end else begin
            scan_clk_r <= scan_clk;
        end
    end
    wire frame_changed = scan_clk && ~scan_clk_r;

    wire flicker_state = flicker_clk;

    reg [2:0] mem_read_i;

    assign mem_addr = {next_scan_row, mem_read_i};

    always @(posedge scan_clk or negedge rst_n_) begin : proc_
        if (~rst_n_) begin
            current_scan_row <= 3'b111;
            led_col_red   <= 0;
            led_col_green <= 0;
        end else begin
            current_scan_row <= next_scan_row;
            led_col_red   <= red_line_buffer;
            led_col_green <= green_line_buffer;
        end
    end

    always @(posedge scan_clk or negedge rst_n_) begin
        if (~rst_n_) begin
            led_row <= {8{1'b1}};
        end else begin
            led_row <= {current_scan_row != 3'b111, led_row[7:1]};
        end
    end

    reg patched_mem_data_red, patched_mem_data_green;

    always @(*) begin : proc_rd_patch
        {patched_mem_data_red, patched_mem_data_green} = mem_data;

        if (screen_flicker_en) begin
            patched_mem_data_red   = flicker_state ? 1'b1 : 1'b0;
            patched_mem_data_green = flicker_state ? 1'b0 : 1'b1;
        end else if (point_flicker_en && point_flicker_pos == {next_scan_row, mem_read_i}) begin
            if (point_flicker_color == `SIDE_RED) begin
                patched_mem_data_red = flicker_state;
            end else begin
                patched_mem_data_green = flicker_state;
            end
        end else if (color_flicker_en) begin
            if (color_flicker_color == `SIDE_RED) begin
                if (mem_data[1]) patched_mem_data_red = flicker_state;
            end else begin
                if (mem_data[0]) patched_mem_data_green = flicker_state;
            end
        end
    end

    // Memeroy read control
    wire mem_read_done = mem_valid && mem_en;

    wire continue_read = mem_read_i != 3'b111;
    reg  continue_read_r;
    reg  continue_read_rr;
    
    always @(posedge clk or negedge rst_n_) begin : proc_mem_read_i
        if (~rst_n_) begin
            mem_read_i <= 0;
        end else begin
            if (frame_changed) begin // frame changed
                mem_read_i <= 0;
            end else if (mem_read_done && continue_read) begin
                mem_read_i <= mem_read_i + 1'b1;
            end
        end
    end

    always @(posedge clk) begin : proc_continue_read_r
        continue_read_r  <= continue_read;
        continue_read_rr <= continue_read_r;
    end

    always @(posedge clk or negedge rst_n_) begin : proc_mem_en
        if(~rst_n_) begin
            mem_en <= 0;
        end else begin
            if (mem_en) begin
                if (mem_valid) begin
                    mem_en <= 0;
                end
            end else begin
                if (continue_read_rr && ~mem_valid) begin
                    mem_en <= 1;
                end
            end
        end
    end

    always @(posedge clk) begin : proc_store
        if (mem_read_done) begin
            red_line_buffer   <= {patched_mem_data_red, red_line_buffer[7:1]};
            green_line_buffer <= {patched_mem_data_green, green_line_buffer[7:1]};
        end
    end
endmodule
