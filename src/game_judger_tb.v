`timescale 1us / 1ns

`include "game_judger.vh"
`include "common.vh"

module game_judger_tb;
    reg clk;
    reg rst_n;

    wire [5:0] mem_addr;
    wire [7:0] mem_rd_data;

    reg       judger_en;
    reg       judger_color;
    reg [5:0] judger_pos;

    wire [1:0] judger_result;
    wire judger_done;

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
    game_judger uut (
        .clk(clk),
        .rst_n(rst_n),

        .en(judger_en),

        .color(judger_color),
        .pos(judger_pos),

        .mem_en(mem_en),
        .mem_valid(mem_valid),
        .mem_addr(mem_addr),
        .mem_data(mem_rd_data[1:0]),

        .result(judger_result),
        .done(judger_done)
    );

    always #0.5 clk = ~clk;

    localparam TESTCASE_DATA_SIZE = 8 * 8 * 3;
    localparam _  = 3'b000;
    localparam R  = 3'b010;
    localparam G  = 3'b001;
    localparam X  = 3'b100;
    localparam XR = X | R;
    localparam XG = X | G;
    localparam RX = XR;
    localparam GX = XG;

    localparam testcase1_color = `SIDE_RED;
    localparam testcase1_expected_res = `JUDGER_WIN;
    localparam testcase1_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, R, R, R, R, X, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase2_color = `SIDE_GREEN;
    localparam testcase2_expected_res = `JUDGER_VALID;
    localparam testcase2_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, R, R, R, R, X, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase3_color = `SIDE_GREEN;
    localparam testcase3_expected_res = `JUDGER_VALID;
    localparam testcase3_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, R, R, R, R, X, R, R},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase4_color = `SIDE_RED;
    localparam testcase4_expected_res = `JUDGER_VALID;
    localparam testcase4_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {R, R, R, _, R, X, R, R},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase5_color = `SIDE_GREEN;
    localparam testcase5_expected_res = `JUDGER_INVALID;
    localparam testcase5_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, G, _, _, _, _},
        {_, _, _, G, _, _, _, _},
        {_, R, R,RX, R, _, _, _},
        {_, _, R, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase6_color = `SIDE_GREEN;
    localparam testcase6_expected_res = `JUDGER_WIN;
    localparam testcase6_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, G, G, G, G, X, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase7_color = `SIDE_RED;
    localparam testcase7_expected_res = `JUDGER_VALID;
    localparam testcase7_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, R, _, _, _, _},
        {_, G, R, X, R, R, G, _},
        {_, _, _, R, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase8_color = `SIDE_RED;
    localparam testcase8_expected_res = `JUDGER_VALID;
    localparam testcase8_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, R, R, R, X, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase9_color = `SIDE_RED;
    localparam testcase9_expected_res = `JUDGER_INVALID;
    localparam testcase9_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, R, R,RX, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase10_color = `SIDE_RED;
    localparam testcase10_expected_res = `JUDGER_INVALID;
    localparam testcase10_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, R, R,GX, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase11_color = `SIDE_RED;
    localparam testcase11_expected_res = `JUDGER_WIN;
    localparam testcase11_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, G, _, _, _, _},
        {_, _, G, R, _, _, _, _},
        {_, _, _, R, _, _, _, _},
        {G, G, R, X, R, R, _, _},
        {_, _, _, R, _, _, _, _},
        {_, _, _, R, _, _, _, _}
    };

    localparam testcase12_color = `SIDE_RED;
    localparam testcase12_expected_res = `JUDGER_WIN;
    localparam testcase12_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, R, _, _, _},
        {_, _, _, _, R, _, _, _},
        {_, _, _, _, R, _, _, _},
        {_, _, _, _, R, _, _, _},
        {_, _, _, _, X, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase13_color = `SIDE_RED;
    localparam testcase13_expected_res = `JUDGER_WIN;
    localparam testcase13_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, R, _, _},
        {_, _, _, _, _, R, _, _},
        {_, _, _, _, _, R, _, _},
        {_, _, R, R, R, X, _, _},
        {_, _, _, _, _, R, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase14_color = `SIDE_RED;
    localparam testcase14_expected_res = `JUDGER_VALID;
    localparam testcase14_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, R, R, G, R, X, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase15_color = `SIDE_RED;
    localparam testcase15_expected_res = `JUDGER_VALID;
    localparam testcase15_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, X, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase16_color = `SIDE_GREEN;
    localparam testcase16_expected_res = `JUDGER_VALID;
    localparam testcase16_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, X, R, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase17_color = `SIDE_RED;
    localparam testcase17_expected_res = `JUDGER_WIN;
    localparam testcase17_data = {
        {_, _, _, R, R, X, R, R},
        {_, _, _, _, _, G, _, _},
        {_, _, _, _, G, G, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, G, R, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase18_color = `SIDE_GREEN;
    localparam testcase18_expected_res = `JUDGER_WIN;
    localparam testcase18_data = {
        {_, _, _, _, _, _, R, G},
        {_, _, _, _, _, G, _, X},
        {_, _, _, _, G, G, _, G},
        {_, _, _, _, _, _, _, G},
        {_, _, _, _, _, _, _, G},
        {_, _, _, _, G, R, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase19_color = `SIDE_GREEN;
    localparam testcase19_expected_res = `JUDGER_WIN;
    localparam testcase19_data = {
        {_, _, _, _, R, G, R, R},
        {_, _, _, _, _, G, _, _},
        {_, _, _, _, G, G, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, G, R, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, G, X, G, G, G}
    };

    localparam testcase20_color = `SIDE_RED;
    localparam testcase20_expected_res = `JUDGER_VALID;
    localparam testcase20_data = {
        {R, R, R, _, R, _, R, R},
        {R, G, _, _, _, G, _, R},
        {R, _, _, _, G, G, _, _},
        {_, _, R, _, _, _, _, _},
        {_, R, _, _, _, _, _, R},
        {_, _, _, _, G, R, _, R},
        {_, _, _, _, _, _, _, _},
        {R, R, R, G, R, R, R, X}
    };

    localparam testcase21_color = `SIDE_RED;
    localparam testcase21_expected_res = `JUDGER_WIN;
    localparam testcase21_data = {
        {_, _, _, _, _, _, _, R},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, G, G, _, _},
        {_, _, _, _, _, _, _, R},
        {_, _, _, _, _, _, _, X},
        {_, _, _, _, G, R, _, R},
        {_, _, _, _, _, _, _, R},
        {_, _, _, _, _, _, _, R}
    };

    localparam testcase22_color = `SIDE_RED;
    localparam testcase22_expected_res = `JUDGER_VALID;
    localparam testcase22_data = {
        {R, _, _, R, _, _, _, R},
        {_, _, _, _, R, _, _, R},
        {R, _, _, _, G, G, _, R},
        {R, _, _, _, _, _, R, _},
        {R, _, _, G, R, R, R, X},
        {_, R, _, _, G, _, R, R},
        {R, _, _, _, _, R, _, R},
        {R, _, _, _, R, _, _, R}
    };

    localparam testcase23_color = `SIDE_RED;
    localparam testcase23_expected_res = `JUDGER_VALID;
    localparam testcase23_data = {
        {_, _, _, _, _, _, R, R},
        {_, _, _, _, _, _, _, R},
        {_, _, _, _, G, G, _, _},
        {R, _, _, _, _, _, R, R},
        {R, R, R, _, R, _, R, X},
        {R, _, _, _, G, R, R, R},
        {_, _, _, _, _, R, _, G},
        {_, _, _, _, _, _, _, R}
    };

    localparam testcase24_color = `SIDE_RED;
    localparam testcase24_expected_res = `JUDGER_VALID;
    localparam testcase24_data = {
        {_, _, _, _, _, _, _, R},
        {R, _, _, _, _, _, _, R},
        {_, _, _, _, R, R, R, X},
        {_, R, _, _, _, _, _, R},
        {R, _, _, _, G, G, _, G},
        {_, _, _, _, G, R, _, R},
        {R, R, R, G, R, R, _, R},
        {_, _, _, _, _, R, _, R}
    };

    localparam testcase25_color = `SIDE_GREEN;
    localparam testcase25_expected_res = `JUDGER_VALID;
    localparam testcase25_data = {
        {_, _, _, _, _, _, G, G},
        {R, _, _, _, _, _, G, G},
        {_, _, _, _, R, R, R, R},
        {G, G, G, _, G, G, X, G},
        {R, _, _, _, G, G, G, G},
        {R, R, _, G, R, R, G, R},
        {_, _, _, _, G, R, G, R},
        {_, _, _, _, _, R, _, R}
    };

    // Diagnoal
    localparam testcase26_color = `SIDE_GREEN;
    localparam testcase26_expected_res = `JUDGER_WIN;
    localparam testcase26_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, G, _, _, _, _, _},
        {_, _, _, G, _, _, _, _},
        {_, _, _, _, G, _, _, _},
        {_, _, _, _, _, G, _, _},
        {_, _, _, _, _, _, X, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase27_color = `SIDE_GREEN;
    localparam testcase27_expected_res = `JUDGER_WIN;
    localparam testcase27_data = {
        {_, _, G, _, _, _, _, _},
        {_, _, _, G, _, _, _, _},
        {_, _, _, _, G, _, _, _},
        {_, _, _, _, _, G, _, _},
        {_, _, _, _, _, _, X, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase28_color = `SIDE_GREEN;
    localparam testcase28_expected_res = `JUDGER_WIN;
    localparam testcase28_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, G, _, _, _, _, _, _},
        {_, _, G, _, _, _, _, _},
        {_, _, _, G, _, _, _, _},
        {_, _, _, _, G, _, _, _},
        {_, _, _, _, _, X, _, _}
    };

    localparam testcase29_color = `SIDE_GREEN;
    localparam testcase29_expected_res = `JUDGER_WIN;
    localparam testcase29_data = {
        {_, _, _, G, _, _, _, _},
        {_, _, _, _, G, _, _, _},
        {_, _, _, _, _, G, _, _},
        {_, _, _, _, _, _, G, _},
        {_, _, _, _, _, _, _, X},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    // D-2
    localparam testcase30_color = `SIDE_GREEN;
    localparam testcase30_expected_res = `JUDGER_WIN;
    localparam testcase30_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, G, _},
        {_, _, _, _, _, G, _, _},
        {_, _, _, _, G, _, _, _},
        {_, _, _, G, _, _, _, _},
        {_, _, X, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase31_color = `SIDE_GREEN;
    localparam testcase31_expected_res = `JUDGER_WIN;
    localparam testcase31_data = {
        {_, _, _, _, _, G, _, _},
        {_, _, _, _, G, _, _, _},
        {_, _, _, G, _, _, _, _},
        {_, _, G, _, _, _, _, _},
        {_, X, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    localparam testcase32_color = `SIDE_GREEN;
    localparam testcase32_expected_res = `JUDGER_WIN;
    localparam testcase32_data = {
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, G, _},
        {_, _, _, _, _, G, _, _},
        {_, _, _, _, G, _, _, _},
        {_, _, _, G, _, _, _, _},
        {_, _, X, _, _, _, _, _}
    };

    localparam testcase33_color = `SIDE_GREEN;
    localparam testcase33_expected_res = `JUDGER_WIN;
    localparam testcase33_data = {
        {_, _, _, _, G, _, _, _},
        {_, _, _, G, _, _, _, _},
        {_, _, G, _, _, _, _, _},
        {_, G, _, _, _, _, _, _},
        {X, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    // D-O
    localparam testcase34_color = `SIDE_GREEN;
    localparam testcase34_expected_res = `JUDGER_VALID;
    localparam testcase34_data = {
        {G, G, G, G, _, G, G, G},
        {G, G, _, G, G, _, _, G},
        {G, G, G, _, _, _, _, G},
        {_, G, _, _, G, G, G, _},
        {X, _, G, _, G, G, _, G},
        {G, G, G, _, _, _, G, G},
        {G, _, G, _, G, G, G, G},
        {G, G, G, G, _, G, G, G}
    };

    localparam testcase35_color = `SIDE_GREEN;
    localparam testcase35_expected_res = `JUDGER_VALID;
    localparam testcase35_data = {
        {_, _, _, _, R, _, _, _},
        {_, _, _, G, _, _, _, _},
        {G, _, G, _, _, _, _, G},
        {G, G, _, _, _, _, _, G},
        {X, G, G, G, _, _, _, G},
        {G, G, _, _, _, _, _, G},
        {_, _, G, _, _, _, _, _},
        {_, _, _, G, _, _, _, _}
    };

    localparam testcase36_color = `SIDE_GREEN;
    localparam testcase36_expected_res = `JUDGER_VALID;
    localparam testcase36_data = {
        {_, _, G, _, G, _, _, _},
        {_, G, _, _, _, _, _, _},
        {X, _, G, _, _, _, _, _},
        {_, G, _, _, _, _, _, _},
        {G, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _},
        {_, _, _, _, _, _, _, _}
    };

    integer error_count = 0;
    integer tested_count = 0;

    integer row = 0;
    integer col = 0;
    integer exec_y = -1;
    integer exec_x = -1;

    task do_testcase;
            input integer testcase_no;
            input [0:TESTCASE_DATA_SIZE - 1] data;
            input color;
            input [1:0] expected_result;
        begin
            exec_y = -1;
            exec_x = -1;
            // copy data to memory
            // mem_we = 1;
            #1;
            for (row = 0; row < 8; row = row + 1) begin
                for (col = 0; col < 8; col = col + 1) begin
                    mem.mem[row * 8 + col] = {data[(row * 8 + col) * 3 + 1], data[(row * 8 + col) * 3 + 2]};
                    if (data[(row * 8 + col) * 3 + 0]) begin
                        exec_x = col;
                        exec_y = row;
                    end
                end
            end
            if (exec_x < 0 || exec_y < 0) begin
                $display("[Error] testcase #%0d: exec pos is not definded in data", testcase_no);
                $finish;
            end

            @(posedge clk);

            judger_pos = {exec_y[2:0], exec_x[2:0]};
            judger_color = color;

            @(posedge clk);

            judger_en = 1;

            wait (judger_done == 1);

            @(posedge clk);

            judger_en = 0;

            if (judger_result == expected_result) begin
                $display("testcase #%0d: judger result: %0d, expected: %0d",
                    testcase_no, judger_result, expected_result);
            end else begin
                $display("[Error] testcase #%0d: judger result: %0d, expected: %0d",
                    testcase_no, judger_result, expected_result);
                error_count = error_count + 1;
            end
            tested_count = tested_count + 1;
        end
    endtask

    integer testcase_index;
    initial begin
        // Initialize Inputs
        clk = 0;
        judger_en = 0;
        rst_n = 0;
        judger_color = 0;
        judger_pos = 0;

        // Wait 100 ns for global reset to finish
        #3;

        rst_n = 1;

        for (testcase_index = 1; testcase_index <= 35; testcase_index = testcase_index + 1) begin
            case (testcase_index)
                1:  do_testcase(testcase_index, testcase1_data, testcase1_color, testcase1_expected_res);
                2:  do_testcase(testcase_index, testcase2_data, testcase2_color, testcase2_expected_res);
                3:  do_testcase(testcase_index, testcase3_data, testcase3_color, testcase3_expected_res);
                4:  do_testcase(testcase_index, testcase4_data, testcase4_color, testcase4_expected_res);
                5:  do_testcase(testcase_index, testcase5_data, testcase5_color, testcase5_expected_res);
                6:  do_testcase(testcase_index, testcase6_data, testcase6_color, testcase6_expected_res);
                7:  do_testcase(testcase_index, testcase7_data, testcase7_color, testcase7_expected_res);
                8:  do_testcase(testcase_index, testcase8_data, testcase8_color, testcase8_expected_res);
                9:  do_testcase(testcase_index, testcase9_data, testcase9_color, testcase9_expected_res);
                10: do_testcase(testcase_index, testcase10_data, testcase10_color, testcase10_expected_res);
                11: do_testcase(testcase_index, testcase11_data, testcase11_color, testcase11_expected_res);
                12: do_testcase(testcase_index, testcase12_data, testcase12_color, testcase12_expected_res);
                13: do_testcase(testcase_index, testcase13_data, testcase13_color, testcase13_expected_res);
                14: do_testcase(testcase_index, testcase14_data, testcase14_color, testcase14_expected_res);
                15: do_testcase(testcase_index, testcase15_data, testcase15_color, testcase15_expected_res);
                16: do_testcase(testcase_index, testcase16_data, testcase16_color, testcase16_expected_res);
                17: do_testcase(testcase_index, testcase17_data, testcase17_color, testcase17_expected_res);
                18: do_testcase(testcase_index, testcase18_data, testcase18_color, testcase18_expected_res);
                19: do_testcase(testcase_index, testcase19_data, testcase19_color, testcase19_expected_res);
                20: do_testcase(testcase_index, testcase20_data, testcase20_color, testcase20_expected_res);
                21: do_testcase(testcase_index, testcase21_data, testcase21_color, testcase21_expected_res);
                22: do_testcase(testcase_index, testcase22_data, testcase22_color, testcase22_expected_res);
                23: do_testcase(testcase_index, testcase23_data, testcase23_color, testcase23_expected_res);
                24: do_testcase(testcase_index, testcase24_data, testcase24_color, testcase24_expected_res);
                25: do_testcase(testcase_index, testcase25_data, testcase25_color, testcase25_expected_res);
                // Diagnoal
                26: do_testcase(testcase_index, testcase26_data, testcase26_color, testcase26_expected_res);
                27: do_testcase(testcase_index, testcase27_data, testcase27_color, testcase27_expected_res);
                28: do_testcase(testcase_index, testcase28_data, testcase28_color, testcase28_expected_res);
                29: do_testcase(testcase_index, testcase29_data, testcase29_color, testcase29_expected_res);
                30: do_testcase(testcase_index, testcase30_data, testcase30_color, testcase30_expected_res);
                31: do_testcase(testcase_index, testcase31_data, testcase31_color, testcase31_expected_res);
                32: do_testcase(testcase_index, testcase32_data, testcase32_color, testcase32_expected_res);
                33: do_testcase(testcase_index, testcase33_data, testcase33_color, testcase33_expected_res);
                34: do_testcase(testcase_index, testcase34_data, testcase34_color, testcase34_expected_res);
                35: do_testcase(testcase_index, testcase35_data, testcase35_color, testcase35_expected_res);
            endcase
        end

        if (error_count == 0) begin
            $display("=== TEST PASS ===");
        end else begin
            $display("=== TEST FAILED ===");
        end
        $display("tested: %0d, failed: %0d", tested_count, error_count);

        $stop;
    end
endmodule
