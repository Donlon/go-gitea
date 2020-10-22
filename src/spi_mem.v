module spi_mem (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    // Arbitration
    input  req_1,
    output grant_1,
    input  req_2,
    output grant_2,
    input  req_3,
    output grant_3,

    // data interface
    input we_1,
    input  [5:0] addr_1,
    input  [1:0] wr_data_1,
    // output [1:0] data_1,
    input  [5:0] addr_2,
    output [1:0] data_2,
    input  [5:0] addr_3,
    output [1:0] data_3,

    // SPI intterface
    output reg spi_clk,
    output reg spi_cs,
    input      spi_si,
    output     spi_so,

    // Callback interface
    output reg valid
);

    spi_mem_arbiter arbiter (
        .clk(clk),
        .rst_n(rst_n),
        
        .req_1(req_1),
        .req_2(req_2),
        .req_3(req_3),
        .req_4(req_4),

        .grant_1(grant_1),
        .grant_2(grant_2),
        .grant_3(grant_3),
        .grant_4(grant_4)
    );

    localparam FM25L16_OP_WRITE = 8'b00000010;
    localparam FM25L16_OP_READ  = 8'b00000011;

    wire grant = grant_1 || grant_2;
    wire rd_en = ~we_1;
    wire wr_data = wr_data_1;
    wire [5:0] addr = (grant_1 & addr_1) | (grant_2 & addr_2) | (grant_3 & addr_3);
    
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
        if (rd_en) begin
            fm25l16_op = FM25L16_OP_WRITE;
        end else begin
            fm25l16_op = FM25L16_OP_READ;
        end
    end

    // always @(*) begin : proc_load_data
    //     case (byte_count)
    //         2'd0:    spi_tx_byte = fm25l16_op;
    //         2'd1:    spi_tx_byte = 0;
    //         2'd2:    spi_tx_byte = {0, addr};
    //         2'd3:    spi_tx_byte = rd_en ? 0 : wr_data;
    //         default: spi_tx_byte = 0;
    //     endcase
    // end

    always @(*) begin : proc_load_data
        case (next_byte_count)
            2'd0:    spi_tx_byte = 8'h11;
            2'd1:    spi_tx_byte = 8'h22;
            2'd2:    spi_tx_byte = 8'h33;
            2'd3:    spi_tx_byte = 8'h44;
            default: spi_tx_byte = 8'hff;
        endcase
    end

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
                if (grant && ~valid)
                    next_state = S_WRITE;
            S_WRITE:
                if (rd_en) begin
                    if (byte_count == 2 && bit_count == 7) begin
                        next_state = S_READ;
                    end
                end else begin
                    // if (byte_count == 3 && bit_count == 7) begin
                    //     next_state = S_IDLE;
                    // end
                    if (byte_count == 4 && bit_count == 0) begin
                        next_state = S_IDLE;
                    end
                end
            S_READ:
                if (byte_count == 2 && bit_count == 7) begin
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
            bit_count <= 3'b111;
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

    wire spi_load_data = (/*state == S_IDLE ||*/ (bit_count == 3'b111 && ~spi_clk))
                                  && next_state == S_WRITE;

    // Transmission logic
    always @(posedge clk or negedge rst_n) begin : proc_tx_buffer
        if(~rst_n) begin
            tx_buffer <= 0;
        end else begin
            if (spi_load_data) begin // load data
                tx_buffer <= spi_tx_byte;
            end
            if (state == S_WRITE && spi_clk/*spi_clk_rising*/) begin
                tx_buffer <= {tx_buffer[6:0], 1'b0}; // MSB first
            end
        end
    end

    // Receive logic
    always @(posedge clk or negedge rst_n) begin : proc_rx_buffer
        if(~rst_n) begin
            rx_buffer <= 0;
        end else begin
            if (state == S_READ && ~spi_clk) begin // read on rising edge of spi_clk
                rx_buffer <= {rx_buffer, spi_si}; // MSB first
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin : proc_valid
        if(~rst_n) begin
            valid <= 0;
        end else begin
            if (~grant) begin
                valid <= 0;
            end else if (state != S_IDLE && next_state == S_IDLE) begin
                valid <= 1;
            end
        end
    end

endmodule