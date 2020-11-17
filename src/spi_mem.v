`include "spi_mem_cmd.vh"

module spi_mem (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low

    // Data interface
    input [1:0]      cmd,
    input [5:0]      addr,
    output reg [7:0] rd_data,
    input      [7:0] wr_data,

    // SPI interface
    output reg spi_clk,
    output reg spi_cs,
    input      spi_si,
    output     spi_so,

    // Callback interface
    input en,
    output reg valid
);

    localparam FM25L16_OP_WREN     = 8'b0000_0110;
    localparam FM25L16_OP_WRDI     = 8'b0000_0100;
    localparam FM25L16_OP_RDSR     = 8'b0000_0101;
    localparam FM25L16_OP_WRSR     = 8'b0000_0001;
    localparam FM25L16_OP_READ     = 8'b0000_0011;
    localparam FM25L16_OP_WRITE    = 8'b0000_0010;
    
    // wire spi_clk_rising;
    // wire spi_clk_falling;

    reg [2:0] bit_count;
    reg [2:0] next_bit_count;
    reg [2:0] byte_count;
    reg [2:0] next_byte_count;

    reg [7:0] tx_buffer;
    reg [7:0] rx_buffer;

    assign spi_so = tx_buffer[7]; // MSB first

    reg [7:0] spi_tx_byte;
    reg [7:0] fm25l16_op;

    always @(*) begin : proc_fm25l16_op
        case (cmd)
            `CMD_READ:
                fm25l16_op = FM25L16_OP_READ;
            `CMD_WRITE:
                fm25l16_op = FM25L16_OP_WRITE;
            `CMD_WREN:
                fm25l16_op = FM25L16_OP_WREN;
            default:
                fm25l16_op = 0;
        endcase
    end

    always @(*) begin : proc_load_data
        case (byte_count)
            2'd0:    spi_tx_byte = fm25l16_op;
            2'd1:    spi_tx_byte = 0;
            2'd2:    spi_tx_byte = {2'b0, addr};
            2'd3:    spi_tx_byte = cmd == `CMD_WRITE ? wr_data : 8'b0;
            default: spi_tx_byte = 0;
        endcase
    end

    // always @(*) begin : proc_load_data
    //     case (byte_count)
    //         2'd0:    spi_tx_byte = 8'h11;
    //         2'd1:    spi_tx_byte = 8'h22;
    //         2'd2:    spi_tx_byte = 8'h33;
    //         2'd3:    spi_tx_byte = 8'h44;
    //         default: spi_tx_byte = 8'hff;
    //     endcase
    // end

    localparam S_IDLE  = 2'b00;
    localparam S_WRITE = 2'b01;
    localparam S_READ  = 2'b11;

    reg [1:0] state, next_state;

    always @(posedge clk or negedge rst_n) begin : proc_state
        if(~rst_n) begin
            state <= 0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin : proc_next_state
        next_state = state;

        case (state)
            S_IDLE:
                if (en && ~valid)
                    next_state = S_WRITE;
            S_WRITE:
                case (cmd)
                    `CMD_WREN:
                        if (byte_count == 1 && bit_count == 0) begin
                            next_state = S_IDLE;
                        end
                    `CMD_WRITE:
                        if (byte_count == 4 && bit_count == 0) begin
                            next_state = S_IDLE;
                        end
                    `CMD_READ:
                        if (byte_count == 3 && bit_count == 7) begin
                            next_state = S_READ;
                        end
                endcase
            S_READ:
                if (byte_count == 4 && bit_count == 0) begin
                    next_state = S_IDLE;
                end
            default:
                next_state = S_IDLE;
        endcase
    end

    // CS pin
    always @(posedge clk or negedge rst_n) begin : proc_spi_cs
        if(~rst_n) begin
            spi_cs <= 1;
        end else begin
            if (state == S_IDLE && next_state == S_WRITE) begin
                spi_cs <= 0;
            end else if (next_state == S_IDLE) begin
                spi_cs <= 1;
            end
        end
    end

    // Clock output
    always @(posedge clk or negedge rst_n) begin : proc_spi_clk
        if(~rst_n) begin
            spi_clk <= 0;
        end else begin
            if ((state == S_READ || state == S_WRITE) && next_state != S_IDLE) begin
                spi_clk <= ~spi_clk;
            end
        end
    end

    // Bit counting
    always @(*) begin : proc_next_bit_count
        next_bit_count = bit_count + 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin : proc_bit_count
        if(~rst_n) begin
            bit_count <= 0;
        end else begin
            if (state != S_IDLE && spi_clk /*spi_clk_rising*/) begin
                bit_count <= next_bit_count;
            end
        end
    end

    // Byte counting
    always @(*) begin : proc_next_byte_count
        next_byte_count = byte_count + 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin : proc_byte_count
        if(~rst_n) begin
            byte_count <= 0;
        end else begin
            if (state == S_IDLE) begin
                byte_count <= 0;
            end else if (state != S_IDLE && bit_count == 3'd7 && ~spi_clk) begin
                byte_count <= next_byte_count;
            end
        end
    end

    wire spi_load_data = (state == S_IDLE || (bit_count == 3'b111 && spi_clk))
                                  && next_state == S_WRITE; // delayed...

    // Transmission logic
    always @(posedge clk or negedge rst_n) begin : proc_tx_buffer
        if(~rst_n) begin
            tx_buffer <= 0;
        end else begin
            if (spi_load_data) begin // load data
                tx_buffer <= spi_tx_byte;
            end else if (state == S_WRITE && spi_clk/*spi_clk_rising*/) begin
                tx_buffer <= {tx_buffer[6:0], 1'b0}; // MSB first
            end
        end
    end

    // Receive logic
    always @(posedge clk or negedge rst_n) begin : proc_rx_buffer
        if(~rst_n) begin
            rx_buffer <= 0;
            rd_data <= 0;
        end else begin
            if (state == S_READ && spi_clk) begin // read on rising edge of spi_clk
                rx_buffer <= {rx_buffer[6:0], spi_si}; // MSB first
            end else if (next_state == S_IDLE) begin
                rd_data <= rx_buffer;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin : proc_valid
        if(~rst_n) begin
            valid <= 0;
        end else begin
            if (~en) begin
                valid <= 0;
            end else if (state != S_IDLE && next_state == S_IDLE) begin
                valid <= 1;
            end
        end
    end

endmodule