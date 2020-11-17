`timescale 1us / 1ns
`include "spi_mem_cmd.vh"

module spi_mem_tb;
    // Inputs
    reg clk;
    reg rst_n;

    reg uut_en;
    reg  [1:0] uut_cmd;
    reg  [5:0] uut_addr;
    reg  [7:0] uut_wr_data;
    wire [7:0] uut_rd_data;

    // Outputs
    wire spi_clk;
    wire spi_cs;
    wire spi_si;
    reg  spi_so;
    wire uut_valid;

    // SPI device emulation
    localparam FM25L16_OP_WREN     = 8'b0000_0110;
    localparam FM25L16_OP_WRDI     = 8'b0000_0100;
    localparam FM25L16_OP_RDSR     = 8'b0000_0101;
    localparam FM25L16_OP_WRSR     = 8'b0000_0001;
    localparam FM25L16_OP_READ     = 8'b0000_0011;
    localparam FM25L16_OP_WRITE    = 8'b0000_0010;

    reg [7:0] spi_rx_buffer;
    integer   spi_rx_bits;
    integer   spi_rx_bytes;

    reg [7:0]  spi_op;
    reg [10:0] spi_addr; // 11-bit Address
    reg [7:0]  spi_wr_data; // data to write
    reg [7:0]  spi_tx_buffer; // data to write

    integer error_count;
    integer tested_count;

    reg [7:0] spi_mem [0:2**6 - 1]; //16kib in real chip

    initial begin
        forever begin
            while (1) begin
                wait (spi_cs == 0);
                $display("SPI chip-select signal received");

                for (spi_rx_bytes = 0, spi_rx_bits = 0;
                     spi_rx_bits < 32; spi_rx_bits = spi_rx_bits + 1) begin
                    @(posedge spi_clk);
                    spi_rx_buffer = {spi_rx_buffer[6:0], spi_si};
                    if ((spi_rx_bits + 1) % 8 == 0) begin
                        $display(">>Received byte: %x (%8b)", spi_rx_buffer[7:0], spi_rx_buffer[7:0]);
                        case (spi_rx_bytes)
                            0: begin
                                spi_op = spi_rx_buffer;
                                case (spi_op)
                                    FM25L16_OP_WREN:  $display("SPI op=WREN");
                                    FM25L16_OP_WRDI:  $display("SPI op=WRDI");
                                    FM25L16_OP_RDSR:  $display("SPI op=RDSR");
                                    FM25L16_OP_WRSR:  $display("SPI op=WRSR");
                                    FM25L16_OP_READ:  $display("SPI op=READ");
                                    FM25L16_OP_WRITE: $display("SPI op=WRITE");
                                    default:          $display("SPI op=%8b(unknown)", spi_op);
                                endcase;
                            end
                            1: begin
                                spi_addr[10:8] = spi_rx_buffer[2:0];
                            end
                            2: begin
                                spi_addr[7:0] = spi_rx_buffer;
                                case (spi_op)
                                    FM25L16_OP_READ: begin
                                        spi_tx_buffer = spi_mem[spi_addr[5:0]];
                                        $display("SPI send mem[%11b[5:0]] (%8b)", spi_addr, spi_tx_buffer);
                                    end
                                endcase
                            end
                            3: begin
                                spi_wr_data = spi_rx_buffer;
                                spi_mem[spi_addr] = spi_rx_buffer;
                            end
                        endcase
                        spi_rx_bytes = spi_rx_bytes + 1;

                        case (spi_op)
                            FM25L16_OP_WREN:
                                if (spi_rx_bytes == 1) begin
                                    break;
                                end
                            FM25L16_OP_WRITE, FM25L16_OP_READ:
                                if (spi_rx_bytes == 4) begin
                                    break;
                                end
                        endcase
                    end
                    if (spi_rx_bytes == 3 && spi_op == FM25L16_OP_READ) begin
                        @(negedge spi_clk);
                        spi_so = spi_tx_buffer[7];
                        spi_tx_buffer = {spi_tx_buffer[6:0], 1'b0};
                    end
                end

                wait (spi_cs == 1);
                $display("SPI chip-diselect signal received");
                if (spi_op == FM25L16_OP_WRITE) begin
                    $display("SPI: write addr: %6b, data: %2b", spi_addr, spi_wr_data);
                end
            end
        end
    end

    task test_wren;
        begin
            wait (uut_en == 0 && uut_valid == 0);

            @(posedge clk);
            uut_en = 1;
            uut_cmd = `CMD_WREN;

            // Wait SPI operation to finish

            wait(uut_valid == 1); // TODO: use fork-join task to capture timed-out event

            @(posedge clk);

            if (spi_op == FM25L16_OP_WREN) begin
                $display("uut sent correct data");
            end else begin
                $display("[Error] uut sent incorrect data");
                error_count = error_count + 1;
            end
            tested_count = tested_count + 1;
            uut_en = 0;
        end
    endtask

    task test_write;
        input [5:0] addr;
        input [7:0] data;
        begin
            wait (uut_en == 0 && uut_valid == 0);

            @(posedge clk);
            uut_en = 1;
            uut_cmd = `CMD_WRITE;
            uut_addr = addr;
            uut_wr_data = data;

            // Wait SPI operation to finish

            wait(uut_valid == 1); // TODO: use fork-join task to capture timed-out event

            @(posedge clk);

            if (spi_addr == addr && spi_wr_data == data) begin
                $display("uut sent correct data");
            end else begin
                $display("[Error] uut sent incorrect data");
                error_count = error_count + 1;
            end
            tested_count = tested_count + 1;
            uut_en = 0;
        end
    endtask

    task test_read;
        input [5:0] addr;
        input [7:0] expected;
        begin
            wait (uut_en == 0 && uut_valid == 0);

            @(posedge clk);
            uut_en = 1;
            uut_cmd = `CMD_READ;
            uut_addr = addr;

            // Wait SPI operation to finish

            wait (uut_valid == 1); // TODO: use fork-join task to capture timed-out event

            @(posedge clk);

            if (spi_addr == addr && uut_rd_data == expected) begin
                $display("uut read correct data");
            end else begin
                $display("[Error] uut read incorrect data");
                error_count = error_count + 1;
            end
            tested_count = tested_count + 1;
            uut_en = 0;
        end
    endtask

    // Instantiate the Unit Under Test (UUT)
    spi_mem uut (
        .clk(clk),
        .rst_n(rst_n),

        .cmd(uut_cmd),
        .addr(uut_addr),
        .rd_data(uut_rd_data),
        .wr_data(uut_wr_data),

        // SPI interface
        .spi_clk(spi_clk),
        .spi_cs(spi_cs),
        .spi_si(spi_so),
        .spi_so(spi_si),

        // Callback interface
        .en(uut_en),
        .valid(uut_valid)
    );

    always #0.5 clk = ~clk;

    integer i;
    reg [5:0] rand_addr;
    reg [7:0] rand_data;
    initial begin
        error_count = 0;
        tested_count = 0;
        clk = 0;
        rst_n = 0;

        uut_en = 0;
        uut_cmd = 0;
        uut_addr = 0;
        uut_wr_data = 0;

        spi_tx_buffer = 0;
        spi_rx_buffer = 0;
        spi_so = 0;

        @(posedge clk);

        rst_n = 1;

        @(posedge clk);

        test_wren();

        // Write tests
        for (i = 0; i < 100; i = i + 1) begin
            $display("=======");
            test_write($random(), $random());
        end

        // Read tests
        for (i = 0; i < 100; i = i + 1) begin
            $display("=======");
            rand_addr = $random();
            rand_data = $random();
            spi_mem[rand_addr] = rand_data;
            test_read(rand_addr, rand_data);
        end

        // Alternate Write/Read tests
        for (i = 0; i < 100; i = i + 1) begin
            $display("=======");
            rand_addr = $random();
            rand_data = $random();
            test_write(rand_addr, rand_data);
            test_read(rand_addr, rand_data);
        end
        

        if (error_count == 0) begin
            $display("=== TEST PASS ===");
        end else begin
            $display("=== TEST FAILED ===");
        end
        $display("tested: %0d, failed: %0d", tested_count, error_count);
        $stop();
    end

    initial begin
        #100000;
        $stop();
    end

endmodule

