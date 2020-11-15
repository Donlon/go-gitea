`timescale 1ms / 1us
`include "common.vh"

module display_led_scanner_tb;

    // Inputs
    reg clk;
    reg scan_clk;
    reg en;
    reg rst_n;

    reg flicker_clk;
    reg screen_flicker_en;
    reg point_flicker_en;
    reg [5:0] point_flicker_pos;
    reg point_flicker_color;

    reg ram_we;
    reg [5:0] ram_wr_addr;
    reg [1:0] ram_wr_data;

    wire [5:0] ram_rd_addr;
    wire [1:0] ram_rd_data_out;

    // Outputs
    wire [7:0] led_row;
    wire [7:0] led_col_red;
    wire [7:0] led_col_green;

    // Instantiate the Unit Under Test (UUT)
    display_led_scanner uut (
        .scan_clk(scan_clk), 
        .clk(clk), 
        .en(en), 
        .rst_n(rst_n), 
        .flicker_clk(flicker_clk), 
        .screen_flicker_en(screen_flicker_en), 
        .point_flicker_en(point_flicker_en), 
        .point_flicker_pos(point_flicker_pos), 
        .point_flicker_color(point_flicker_color), 

        .color_flicker_en(0),
        .color_flicker_color(0),

        .ram_rd_addr(ram_rd_addr), 
        .ram_data(ram_rd_data_out), 

        .led_row(led_row), 
        .led_col_red(led_col_red), 
        .led_col_green(led_col_green)
    );

    checkerboard_state_ram ram (
        .clk(clk),

        .wr_en(ram_we),

        .wr_addr(ram_wr_addr),
        .wr_data(ram_wr_data),

        .rd_addr(ram_rd_addr),
        .rd_data_out(ram_rd_data_out)
    );

    localparam TESTCASE_DATA_SIZE = 8 * 8 * 2;
    localparam _  = 2'b00;
    localparam R  = 2'b10;
    localparam G  = 2'b01;

    localparam testcase_empty = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase_data = {
        {_, G, R, R, G, G, R, _},
        {_, R, G, G, R, R, G, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {R, R, G, G, R, R, G, G},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase_data2 = {
        {R, _, _, _, _, _, _, _},
        {G, R, _, _, _, _, _, _},
        {_, G, R, _, _, _, _, _},
        {_, _, G, _, _, G, _, _},
        {_, _, _, _, _, _, G, _},
        {_, _, _, _, _, _, _, G},
        {G, _, _, _, _, _, _, _},
        {_, G, _, _, _, R, G, R}
    };

    integer row, col;
    
    task write_testcase;
            // input integer testcase_no;
            input [0:TESTCASE_DATA_SIZE - 1] data;
        begin
            #1;
            for (row = 0; row < 8; row = row + 1) begin
                for (col = 0; col < 8; col = col + 1) begin
                    ram.mem[row * 8 + col] = {data[(row * 8 + col) * 2 + 0], data[(row * 8 + col) * 2 + 1]};
                end
            end
        end
    endtask

    always #0.5 clk = ~clk;
    always #10 scan_clk = ~scan_clk;
    always #500 flicker_clk = ~flicker_clk;
    initial begin
        // Initialize Inputs
        scan_clk = 0;
        clk = 0;
        en = 0;
        rst_n = 0;
        flicker_clk = 0;
        screen_flicker_en = 0;
        point_flicker_en = 0;
        point_flicker_pos = 0;
        point_flicker_color = 0;

        write_testcase(testcase_data);
        #10;
        rst_n = 1;
        en = 1;
        // Wait 100 ns for global reset to finish
        #1000;

        // Clear memory
        write_testcase(testcase_empty);
        point_flicker_en = 1;
        point_flicker_color = `SIDE_RED;
        point_flicker_pos = {3'd2, 3'd2};

        #4000;

        point_flicker_color = `SIDE_GREEN;
        point_flicker_pos = {3'd0, 3'd7};
        
        #4000;

        point_flicker_color = `SIDE_RED;
        point_flicker_pos = {3'd7, 3'd7};
        
        #4000;
        
        $stop;
    end
      
endmodule

