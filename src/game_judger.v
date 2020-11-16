`include "common.vh"
`include "game_judger.vh"

module game_judger (
    input clk,    // Clock
    input en,
    input rst_n,

    input color,
    input [5:0] pos,

    output [5:0] ram_rd_addr,
    input  [1:0] ram_data,

    output reg [1:0] result,
    output reg       done
);

    localparam S_IDLE            = 2'b00;
    localparam S_TEST_OVERLAPSED = 2'b01;
    localparam S_READ_MEM        = 2'b11;
    localparam S_WAIT            = 2'b10;

    localparam TYPE_HORIZONTAL   = 2'b00;
    localparam TYPE_VERTICAL     = 2'b01;
    localparam TYPE_DIAGNOAL     = 2'b10;
    localparam TYPE_DIAGNOAL_2   = 2'b11;
    localparam FIRST_JUDGE_TYPE  = TYPE_HORIZONTAL;
    localparam LAST_JUDGE_TYPE   = TYPE_DIAGNOAL_2;
    // localparam LAST_JUDGE_TYPE   = TYPE_VERTICAL;

    reg [1:0] state, next_state;
    reg [1:0] judge_type, next_judge_type;
    
    reg [2:0] start_x, start_y;
    reg [2:0] inc_x, inc_y;
    reg [2:0] inc_x_r, inc_y_r;

    wire [2:0] pos_x, pos_y;
    assign {pos_y, pos_x} = pos;

    reg [2:0] ram_rd_addr_x, ram_rd_addr_y;
    assign ram_rd_addr = (state == S_TEST_OVERLAPSED) ? pos : {ram_rd_addr_y, ram_rd_addr_x};

    wire pos_inc_reach_boarder =
        (ram_rd_addr_x == 3'd7 && inc_x_r[2] == 0 && inc_x_r[1:0] != 0) || // right && inc_x_r > 0
        (ram_rd_addr_y == 3'd7 && inc_y_r[2] == 0 && inc_y_r[1:0] != 0) || // bottom && inc_y_r > 0
        (ram_rd_addr_y == 3'd0 && inc_y_r[2] == 1) || // top && inc_y_r < 0
        state == S_TEST_OVERLAPSED;

    reg pos_inc_reach_boarder_r;

    always @(posedge clk) begin : proc_pos_inc_reach_boarder_r
        if (~rst_n) begin
            pos_inc_reach_boarder_r <= 0;
            inc_x_r <= 0;
            inc_y_r <= 0;
        end else begin
            pos_inc_reach_boarder_r <= pos_inc_reach_boarder;
            inc_x_r <= inc_x;
            inc_y_r <= inc_y;
        end
    end

    reg[2:0] successive_count;
    wire judger_win = successive_count == 3'd5;

    always @(posedge clk or negedge rst_n) begin : proc_state
        if (~rst_n) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin : proc_next_state
        next_state = state;
        case (state)
            S_IDLE:
                if (en && ~done) next_state = S_TEST_OVERLAPSED;
            S_TEST_OVERLAPSED:
                if (ram_data != 2'b00)
                    next_state = S_IDLE;
                else
                    next_state = S_READ_MEM;
            S_READ_MEM: begin
                if (judge_type == LAST_JUDGE_TYPE && pos_inc_reach_boarder)
                    next_state = S_WAIT;
                if (judger_win)
                    next_state = S_IDLE;
            end
            S_WAIT:
                next_state = S_IDLE;
            default:
                next_state = S_IDLE;
        endcase
    end

    wire [3:0] x_minus_y = {1'b0, pos_x} - {1'b0, pos_y};
    wire [3:0] x_add_y   = {1'b0, pos_x} + {1'b0, pos_y};

    always @(*) begin : proc_jtype
        start_x = 0;
        start_y = 0;

        case (next_judge_type)
            TYPE_HORIZONTAL: begin
                start_x = 0;
                start_y = pos_y;
                inc_x = 1;
                inc_y = 0;
            end
            TYPE_VERTICAL: begin
                start_x = pos_x;
                start_y = 0;
                inc_x = 0;
                inc_y = 1;
            end
            TYPE_DIAGNOAL: begin
                if (~x_minus_y[3]) begin // Region A
                    start_x = x_minus_y[2:0];
                    start_y = 0;
                end else begin // Region B
                    start_x = 0;
                    start_y = 0 - x_minus_y[2:0];
                end
                inc_x = 1;
                inc_y = 1;
            end
            TYPE_DIAGNOAL_2: begin
                if (~x_add_y[3]) begin // Region A
                    start_y = x_add_y[2:0];
                    start_x = 0;
                end else begin // Region B
                    start_y = 7;
                    start_x = x_add_y[2:0] + 1;
                end
                inc_x = 1;
                inc_y = 3'b111; // -1
            end
            default: begin
                start_x = 0;
                start_y = 0;
                inc_x = 0;
                inc_y = 0;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin : proc_judge_type
        if (~rst_n) begin
            judge_type <= 0;
        end else begin
            judge_type <= next_judge_type;
        end
    end

    always @(*) begin : proc_next_judge_type
        if (next_state == S_TEST_OVERLAPSED)
            next_judge_type = FIRST_JUDGE_TYPE;
        else if (state == S_READ_MEM && pos_inc_reach_boarder) // next judge type
            next_judge_type = judge_type + 1'b1;
        else
            next_judge_type = judge_type;
    end

    // Mem addr increment
    always @(posedge clk or negedge rst_n) begin : proc_ram_rd_addr
        if (~rst_n) begin
            {ram_rd_addr_y, ram_rd_addr_x} <= 0;
        end else begin
            // if (state == S_READ_MEM) begin
            if (next_state == S_READ_MEM) begin
                if (pos_inc_reach_boarder) begin
                    ram_rd_addr_x <= start_x;
                    ram_rd_addr_y <= start_y;
                end else begin
                    ram_rd_addr_x <= ram_rd_addr_x + inc_x;
                    ram_rd_addr_y <= ram_rd_addr_y + inc_y;
                end
            end
        end
    end

    wire din_red   = ram_data[1]; // Data in - red
    wire din_green = ram_data[0]; // Data in - green

    wire mem_rd_color_matched = 
            (color == `SIDE_RED && din_red) || (color == `SIDE_GREEN && din_green);

    wire inc_suc_count = state == S_READ_MEM && (mem_rd_color_matched || ram_rd_addr == pos);

    always @(posedge clk or negedge rst_n) begin : proc_successive_count
        if (~rst_n) begin
            successive_count <= 0;
        end else begin
            case ({pos_inc_reach_boarder_r, inc_suc_count})
                2'b10:   successive_count <= 0;
                2'b11:   successive_count <= 1'b1;
                2'b01:   successive_count <= successive_count + 1'b1;
                default: successive_count <= 0;
            endcase
        end
    end

    // Callback logic
    always @(posedge clk or negedge rst_n) begin : proc_callback
        if (~rst_n) begin
            result <= `JUDGER_INVALID;
            done <= 0;
        end else begin
            if (~en) begin
                done <= 0;
            end else if (state == S_TEST_OVERLAPSED && next_state == S_IDLE) begin
                result <= `JUDGER_INVALID;
                done <= 1;
            end else if ((state == S_READ_MEM || state == S_WAIT) && next_state == S_IDLE) begin
                result <= judger_win ? `JUDGER_WIN : `JUDGER_VALID;
                done <= 1;
            end 
        end
    end

endmodule
