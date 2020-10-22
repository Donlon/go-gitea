module spi_mem_arbiter (
    input clk,    // Clock
    input rst_n,  // Asynchronous reset active low
    
    input req_1,
    input req_2,
    input req_3,
    input req_4,

    output reg grant_1,
    output reg grant_2,
    output reg grant_3,
    output reg grant_4
);

    always @(posedge clk or negedge rst_n) begin : proc_
        if(~rst_n) begin
            {grant_1, grant_2, grant_3, grant_4} <= 0;
        end else begin
            case (1)
                grant_1:
                    if (~req_1) begin
                        grant_1 <= 0;
                        if (req_2) begin
                            grant_2 = 1;
                        end else if (req_3) begin
                            grant_3 <= 1;
                        end else if (req_4) begin
                            grant_4 <= 1;
                        end
                    end
                grant_2:
                    if (~req_2) begin
                        grant_2 <= 0;
                        if (req_3) begin
                            grant_3 <= 1;
                        end else if (req_4) begin
                            grant_4 <= 1;
                        end else if (req_1) begin
                            grant_1 <= 1;
                        end
                    end
                grant_3:
                    if (~req_3) begin
                        grant_3 <= 0;
                        if (req_4) begin
                            grant_4 <= 1;
                        end else if (req_1) begin
                            grant_1 <= 1;
                        end else if (req_2) begin
                            grant_2 <= 1;
                        end
                    end
                grant_4:
                    if (~req_4) begin
                        grant_4 <= 0;
                        if (req_1) begin
                            grant_1 <= 1;
                        end else if (req_2) begin
                            grant_2 <= 1;
                        end else if (req_3) begin
                            grant_3 <= 1;
                        end
                    end
                default:
                    if (req_1) begin
                        grant_1 <= 1;
                    end else if (req_2) begin
                        grant_2 <= 1;
                    end else if (req_3) begin
                        grant_3 <= 1;
                    end else if (req_4) begin
                        grant_4 <= 1;
                    end                
            endcase
        end
    end

endmodule