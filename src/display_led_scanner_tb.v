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

    wire mem_busy = 0;
    wire mem_en;
    wire mem_valid;
    wire [5:0] mem_addr;
    wire [7:0] mem_rd_data;

    // Outputs
    wire [7:0] led_row;
    wire [7:0] led_col_red;
    wire [7:0] led_col_green;

    spi_mem_emu mem(
        .clk(clk),    ///* Clock
        .rst_n(rst_n),  //*/ Asynchronous reset active low

        // Data interface
        .wr_en(1'b0),
        .addr(mem_addr),
        .rd_data(mem_rd_data),
        .wr_data(8'b0),

        // Callback interface
        .en(mem_en),
        .valid(mem_valid)
    );

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

        .color_flicker_en(1'b0),
        .color_flicker_color(1'b0),

        .mem_busy(mem_busy),
        .mem_en(mem_en),
        .mem_valid(mem_valid),
        .mem_addr(mem_addr),
        .mem_data(mem_rd_data[1:0]),

        .led_row(led_row), 
        .led_col_red(led_col_red), 
        .led_col_green(led_col_green)
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
                    mem.mem[row * 8 + col] = {data[(row * 8 + col) * 2 + 0], data[(row * 8 + col) * 2 + 1]};
                end
            end
        end
    endtask

    always #0.5 clk = ~clk;
    always #60 scan_clk = ~scan_clk;
    always #5000 flicker_clk = ~flicker_clk;
    initial begin
        // Initialize Inputs
        scan_clk = 1;
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
        #10000;

        // Clear memory
        write_testcase(testcase_empty);
        point_flicker_en = 1;
        point_flicker_color = `SIDE_RED;
        point_flicker_pos = {3'd2, 3'd2};

        #40000;

        point_flicker_color = `SIDE_GREEN;
        point_flicker_pos = {3'd0, 3'd7};
        
        #40000;

        point_flicker_color = `SIDE_RED;
        point_flicker_pos = {3'd7, 3'd7};
        
        #40000;
        
        $stop;
    end
      
endmodule

