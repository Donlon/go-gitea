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

    // input color_flicker_en,
    // input color_flicker_color,

    output reg mem_req,
    input      mem_grant,
    input      mem_valid,

    output reg mem_rd_addr,
    input      mem_data,

    output reg [7:0] led_row,
    output reg [7:0] led_col_red,
    output reg [7:0] led_col_green
);
    wire rst_n_ = rst_n && en;

    reg [7:0] red_line_buffer;
    reg [7:0] green_line_buffer;

    reg [2:0] current_scan_row;

    reg current_frame_state, last_frame_state;

    wire flicker_state = flicker_clk;

    reg [2:0] mem_read_bit;

    assign mem_rd_addr = {current_scan_row, mem_read_bit};

    always @(posedge scan_clk or negedge rst_n_) begin : proc_
        if (~rst_n_) begin
            current_scan_row <= 3'b111;
            current_frame_state <= 0;
            led_col_red <= 0;
            led_col_green <= 0;
        end else begin
            current_scan_row <= current_scan_row + 1'b1;
            current_frame_state <= ~current_frame_state;
            if (screen_flicker_en) begin
                if (flicker_state) begin
                    led_col_red   <= {8{1'b1}};
                    led_col_green <= {8{1'b0}};
                end else begin
                    led_col_red   <= {8{1'b0}};
                    led_col_green <= {8{1'b1}};
                end
            end else begin
                led_col_red   <= red_line_buffer;
                led_col_green <= green_line_buffer;
            end
        end
    end

    wire led_row_injection = current_scan_row != 3'b111;

    always @(posedge scan_clk or negedge rst_n_) begin
        if (~rst_n_) begin
            led_row <= {8{1'b1}};
        end else begin
            led_row <= {led_row_injection, led_row[7:1]};
        end
    end

    reg patched_ram_data_red, patched_ram_data_green;

    always @(*) begin : proc_rd_patch
        {patched_ram_data_red, patched_ram_data_green} = mem_data;

        if (point_flicker_en && point_flicker_pos == {current_scan_row, mem_read_bit}) begin
            if (point_flicker_color == 1) begin
                patched_ram_data_red = flicker_state;
            end else begin
                patched_ram_data_green = flicker_state;
            end
        end

        // if (color_flicker_en) begin
        //  if (color_flicker_color == 1) begin
        //      if (ram_data[1]) patched_ram_data_red = flicker_state
        //  end else begin
        //      if (ram_data[0]) patched_ram_data_green = flicker_state
        //  end
        // end
    end

    always @(posedge clk or negedge rst_n_) begin : proc_store
        if (~rst_n_) begin
            last_frame_state <= 0;
        end else begin
            if (~screen_flicker_en && mem_read_bit != 3'b111) begin
                red_line_buffer   <= {red_line_buffer[6:0], patched_ram_data_red};
                green_line_buffer <= {green_line_buffer[6:0], patched_ram_data_green};
                mem_read_bit <= mem_read_bit + 1'b1;
            end
            if (current_frame_state != last_frame_state) begin // frame changed
                mem_read_bit <= 0;
            end
            last_frame_state <= current_frame_state;
        end
    end
endmodule