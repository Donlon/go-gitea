module key_debounce(
    input key,
    input clk,
    input rst_n,
    output reg key_debounced
);
    // TODO: eliminate metastable state

    // reg last_key_state;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            // last_key_state <= key;
            key_debounced <= 0;
        end else begin
            key_debounced <= key;
        end
    end
endmodule
