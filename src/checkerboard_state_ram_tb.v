`timescale 1us / 1ns

module checkerboard_state_ram_tb;
    // Inputs
    reg clk;
    reg wr_en;
    reg [5:0] wr_addr;
    reg [1:0] wr_data;

    reg  [5:0] rd_addr_1;
    wire [1:0] rd_data_out_1;

    // reg  [5:0] rd_addr_2;
    // wire [1:0] rd_data_out_2;

    // Instantiate the Unit Under Test (UUT)
    checkerboard_state_ram uut (
        .clk(clk),

        .wr_en(wr_en),

        .wr_addr(wr_addr),
        .wr_data(wr_data),

        .rd_addr(rd_addr_1),
        .rd_data_out(rd_data_out_1)

        // .rd_addr_1(rd_addr_1),
        // .rd_data_out_1(rd_data_out_1),

        // .rd_addr_2(rd_addr_2),
        // .rd_data_out_2(rd_data_out_2)
    );

    always #0.5 clk = ~clk;

    task write_memory;
        input [5:0] addr;
        input [1:0] data;
        begin
            repeat(1) @(posedge clk);
            wr_en = 1;
            wr_addr = addr;
            wr_data = data;
            repeat(2) @(posedge clk);
            wr_en = 0;
        end
    endtask

    task read_memory;
        input [5:0] addr;
        input port;
        begin
            if (port == 0) begin
                rd_addr_1 = addr;
                #0.4;
                // read_memory = rd_data_out_1;
            end/* else begin
                rd_addr_2 = addr;
                #0.4;
                // read_memory = rd_data_out_2;
            end*/
        end
    endtask

    reg [1:0] random_data [63:0];

    integer i, error_count;
    reg [1:0] rd_data;

    initial begin
        // Initialize Inputs
        clk = 0;
        wr_en = 0;
        wr_addr = 0;
        wr_data = 0;
        rd_addr_1 = 0;
        // rd_addr_2 = 0;
        error_count = 0;

        write_memory(6'h00, 2'b10);
        write_memory(6'h01, 2'b01);
        write_memory(6'h02, 2'b00);

        for (i = 0; i < 64; i = i + 1) begin
            random_data[i] = $random();
            write_memory(i, random_data[i]);
        end

        #4;

        for (i = 0; i < 64; i = i + 1) begin
            read_memory(i, 0);
            #0.5;
            $display("read memory[%d] port 1: get: %b, expected: %b", i, rd_data_out_1, random_data[i]);
            if (random_data[i] != rd_data_out_1) begin
                error_count = error_count + 1;
            end
        end

        // for (i = 0; i < 64; i = i + 1) begin
        //     read_memory(i, 1);
        //     #0.5;
        //     $display("read memory[%d] port 2: get: %b, expected: %b", i, rd_data_out_2, random_data[i]);
        //     if (random_data[i] != rd_data_out_2) begin
        //         error_count = error_count + 1;
        //     end
        // end

        if (error_count == 0) begin
            $display("== module test pass ==");
        end else begin
            $display("== FAILED: error_count: %d ==", error_count);
        end

        #100;

        $stop;
    end

endmodule

