`timescale 1us / 1ns

module spi_mem_tb;
    // Inputs
    reg clk;
    reg rst_n;
    reg req_1;
    reg req_2;
    reg req_3;
    reg we_1;
    reg [5:0] addr_1;
    reg [1:0] wr_data_1;
    reg [5:0] addr_2;
    reg [5:0] addr_3;

    // Outputs
    wire grant_1;
    wire grant_2;
    wire grant_3;
    wire [1:0] data_2;
    wire [1:0] data_3;

    wire spi_clk;
    wire spi_cs;
    reg  spi_si;
    wire spi_so;
    wire valid;

    // SPI device emulation
    reg [7:0] spi_rx_data;
    integer spi_rx_bits;
    integer spi_rx_bytes;

    localparam FM25L16_OP_WREN     = 8'b0000_0110;
    localparam FM25L16_OP_WRDI     = 8'b0000_0100;
    localparam FM25L16_OP_RDSR     = 8'b0000_0101;
    localparam FM25L16_OP_WRSR     = 8'b0000_0001;
    localparam FM25L16_OP_READ     = 8'b0000_0011;
    localparam FM25L16_OP_WRITE    = 8'b0000_0010;

    reg [7:0]  spi_op;
    reg [10:0] spi_addr; // 11-bit Address
    reg [7:0]  spi_wr_data; // data to write
    reg [7:0]  spi_tx_buffer; // data to write
    //assign spi_si = spi_tx_buffer[7];

    initial begin
        forever begin
            wait (spi_cs == 0);
            $display("SPI chip-select signal received");

            for (spi_rx_bytes = 0, spi_rx_bits = 0;
                 spi_rx_bits < 32; spi_rx_bits = spi_rx_bits + 1) begin
                @(posedge spi_clk);
                spi_rx_data = {spi_rx_data, spi_so};
                if ((spi_rx_bits + 1) % 8 == 0) begin
                    $display(">>Receied byte: %x", spi_rx_data[7:0]);
                    case (spi_rx_bytes)
                        0: begin
                            spi_op = spi_rx_data;
                        end
                        1: begin
                            spi_addr[10:8] = spi_rx_data[2:0];
                        end
                        2: begin
                            spi_addr[7:0] = spi_rx_data;
                            case (spi_op)
                                FM25L16_OP_READ:
                                    spi_tx_buffer = spi_tx_buffer;
                                    // spi_tx_buffer = ram[spi_addr];
                            endcase
                        end
                        3: begin
                            spi_wr_data = spi_rx_data;
                            // ram[spi_addr] = spi_wr_data;
                        end
                    endcase
                    spi_rx_bytes = spi_rx_bytes + 1;
                end
                if (spi_rx_bytes == 3 && spi_op == FM25L16_OP_READ) begin
                    @(negedge spi_clk);
                    spi_tx_buffer = {spi_tx_buffer[6:0], 1'b0};
                end
            end

            wait(spi_cs == 1);
            $display("SPI chip-diselect signal received");
        end
    end

    // Instantiate the Unit Under Test (UUT)
    spi_mem uut (
        .clk(clk), 
        .rst_n(rst_n), 
        
        .req_1(req_1), 
        .grant_1(grant_1), 
        .req_2(req_2), 
        .grant_2(grant_2), 
        .req_3(req_3), 
        .grant_3(grant_3), 
        
        .we_1(we_1), 
        .addr_1(addr_1),
        .wr_data_1(wr_data_1), 
        
        .addr_2(addr_2), 
        .data_2(data_2), 
        
        .addr_3(addr_3), 
        .data_3(data_3), 
        
        .spi_clk(spi_clk), 
        .spi_cs(spi_cs), 
        .spi_si(spi_si), 
        .spi_so(spi_so), 
        
        .valid(valid)
    );

    always #0.5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        rst_n = 0;

        req_1 = 0;
        req_2 = 0;
        req_3 = 0;

        we_1 = 0;
        addr_1 = 0;
        wr_data_1 = 0;
        addr_2 = 0;
        addr_3 = 0;
        spi_si = 0;

        // Wait 100 ns for global reset to finish
        #4;

        rst_n = 1;

        #3;

        req_1 = 1;
        addr_1 = 6'b101010;
        wr_data_1 = 2'b11;
        we_1 = 1;

        wait (grant_1 == 1);

        @(negedge clk);

        // Wait SPI operation to finish

        wait(valid == 1); // TODO: use fork-join task to capture timed-out event

        req_1 = 0;

        #10;

        $stop();
        // Add stimulus here

    end
      
endmodule

