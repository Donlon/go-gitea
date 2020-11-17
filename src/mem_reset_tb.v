`timescale 1us / 1ns

module mem_reset_tb;

    reg clk;
    reg memrst_en;
    reg rst_n;

    wire memrst_done;

    wire mem_en;
    wire mem_valid;
    wire [5:0] mem_addr;
    wire [1:0] mem_wr_data;


    always #0.5 clk = ~clk;

    spi_mem_emu mem(
        .clk(clk),    ///* Clock
        .rst_n(rst_n),  //*/ Asynchronous reset active low

        // Data interface
        .wr_en(1'b1),
        .addr(mem_addr),
        .rd_data(),
        .wr_data({6'b0, mem_wr_data}),

        // Callback interface
        .en(mem_en),
        .valid(mem_valid)
    );

    // Instantiate the Unit Under Test (UUT)
    mem_reset uut (
        .clk(clk),
        .en(memrst_en),
        .rst_n(rst_n),

        .mem_en(mem_en),
        .mem_valid(mem_valid),
        .mem_addr(mem_addr),
        .mem_data(mem_wr_data),

        .done(memrst_done)
    );

    integer i;

    integer error_count = 0;

    reg memrst_is_done;

    initial begin
        // Initialize Inputs
        clk = 0;
        memrst_en = 0;
        rst_n = 0;
        memrst_is_done = 0;

        // Wait 100 ns for global reset to finish
        #3;

        rst_n = 1;

        for (i = 0; i < 64; i = i + 1) begin
            mem.mem[i] = $random();
        end
        $display("ramdon data written to memory.");

        #3;

        memrst_en = 1;

        wait (memrst_done == 1);

        $display("mem_reset done.");
        memrst_is_done = 1;

        #1;

        memrst_en = 0;
        #10;

        for (i = 0; i < 64; i = i + 1) begin
            if (mem.mem[i] != 0) begin
                $display("[ERROR] read memory[%0d]: get: %b, expected: 0", i, mem.mem[i]);
                error_count = error_count + 1;
            end
        end

        if (error_count == 0) begin
            $display("== module test pass ==");
        end else begin
            $display("== FAILED: error_count: %d ==", error_count);
        end

        $stop;
        // Add stimulus here

    end

    initial begin
        #10000;
        if (~memrst_is_done) begin
            $display("=== ERROR: mem_reset timed out! ===");
            $stop;
        end
    end

endmodule

