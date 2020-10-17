module clock_divider #(
    parameter DIVISOR = 2
)(
    input clk,
    input rst_n,
    output reg clk_out
);
    function integer clog2; 
        input integer value; 
        integer temp;
    begin 
        value = value - 1;
        for (temp = 0; value > 0; temp = temp + 1) begin
            value = value >> 1; 
        end
        clog2 = temp;
        end 
    endfunction 

    localparam COUNT_BITS = clog2(DIVISOR / 2 - 1) + 1;

    reg[COUNT_BITS - 1:0] count;

    always @(posedge clk or negedge rst_n) begin : proc_
        if (~rst_n) begin
            count <= 0;
            clk_out <= 0;
        end else begin
            if (count == DIVISOR / 2 - 1) begin
                count <= 0;
                clk_out <= ~clk_out;
            end else begin
                count <= count + 1'b1;
            end
        end
    end
endmodule
