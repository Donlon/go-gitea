module mem_reset (
    input clk,    // Clock
    input en, // Clock Enable
    input rst_n,  // Asynchronous reset active low

    output reg mem_en,
    input  reg mem_valid,
    output reg [5:0] mem_addr,
    output     [1:0] mem_data,

    output reg done
);

    assign mem_data = 0;

    localparam S_IDLE    = 1'b0;
    localparam S_WORKING = 1'b1;

    reg [0:0] state, next_state;

    always @(*) begin : proc_next_state
        next_state <= S_IDLE;

        case (state)
            S_IDLE:
                if (en && ~done)
                    next_state <= S_WORKING;
            S_WORKING:
                if (mem_addr == 6'b111111 && mem_valid && mem_en) begin
                    next_state <= S_IDLE;
                end else begin
                    next_state <= S_WORKING;
                end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin : proc_state
        if(~rst_n) begin
            state <= 0;
        end else begin
            state <= next_state;
        end
    end

    always @(posedge clk or negedge rst_n) begin : proc_update_addr
        if (~rst_n) begin
            mem_addr <= 0;
        end else begin
            if (state == S_WORKING && mem_valid && mem_en) begin
                mem_addr <= mem_addr + 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin : proc_callback
        if(~rst_n) begin
            done <= 0;
        end else begin
            if (done && ~en)
                done <= 0;
            if (state == S_WORKING && next_state == S_IDLE)
                done <= 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin : proc_mem_en
        if(~rst_n) begin
            mem_en <= 0;
        end else begin
            if (mem_en) begin
                if (mem_valid) begin
                    mem_en <= 0;
                end
            end else begin
                if (next_state == S_WORKING && ~mem_valid) begin
                    mem_en <= 1;
                end
            end
        end
    end
endmodule