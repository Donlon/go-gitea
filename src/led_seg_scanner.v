module led_seg_scanner (
    input scan_clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    input [3:0] digit_0,
    input [3:0] digit_1,
    input [3:0] digit_2,
    input [3:0] digit_3,
    input [3:0] digit_4,
    input [3:0] digit_5,
    input [3:0] digit_6,
    input [3:0] digit_7,

    output     [7:0] seg_data,
    output reg [7:0] seg_sel
);
    reg [3:0] current_digit;

    reg [2:0] scan_seq;
    wire sel_inejction = scan_seq != 0;

    always @(*) begin : proc_current_digit
        case (scan_seq)
            0: current_digit <= digit_0;
            1: current_digit <= digit_1;
            2: current_digit <= digit_2;
            3: current_digit <= digit_3;
            4: current_digit <= digit_4;
            5: current_digit <= digit_5;
            6: current_digit <= digit_6;
            7: current_digit <= digit_7;
            default: current_digit <= 0;
        endcase
    end

    wire [6:0] seg_data_0;
    seg_decoder decoder(
        .bin_data(current_digit),     // bin data input
        .seg_data(seg_data_0)      // seven segments LED output
    );

    always @(posedge scan_clk or negedge rst_n) begin : proc_shift
        if(~rst_n) begin
            scan_seq <= 0;
            seg_sel  <= {8{1'b1}};
        end else begin
            scan_seq <= scan_seq + 1'b1;
            seg_sel  <= {seg_sel[6:0], sel_inejction};
        end
    end

    assign seg_data = {1'b0, seg_data_0};

endmodule