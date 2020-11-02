module clock_gen #(
    parameter IN_FREQ = 1e6
) (
    input clk_in,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    output clk_2k,
    output clk_200Hz,
    output reg clk_100Hz,
    output clk_2Hz,
    output reg clk_1Hz
);

    clock_divider #(
        .DIVISOR(IN_FREQ / 2000)
    )
    div1(
        .clk(clk_in),
        .rst_n(rst_n),
        .clk_out(clk_2k)
    );

    clock_divider #(
        .DIVISOR(10)
    )
    div2(
        .clk(clk_2k),
        .rst_n(rst_n),
        .clk_out(clk_200Hz)
    );

    always @(posedge clk_200Hz or negedge rst_n) begin : proc_clk_100Hz
        if (~rst_n) begin
            clk_100Hz <= 0;
        end else begin
            clk_100Hz <= ~clk_100Hz;
        end
    end

    clock_divider #(
        .DIVISOR(50)
    )
    div3(
        .clk(clk_100Hz),
        .rst_n(rst_n),
        .clk_out(clk_2Hz)
    );

    always @(posedge clk_2Hz or negedge rst_n) begin : proc_clk_1Hz
        if (~rst_n) begin
            clk_1Hz <= 0;
        end else begin
            clk_1Hz <= ~clk_1Hz;
        end
    end
endmodule