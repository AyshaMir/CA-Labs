`timescale 1ns / 1ps
module countdown(
    input clk,
    input rst,
    input enable,
    input load,
    input [15:0] load_value,
    output reg [15:0] count_out
);
    reg [26:0] clk_div;
    wire tick;
    always @(posedge clk or posedge rst) begin
        if (rst)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    assign tick = (clk_div == 100_000_000 - 1);

    always @(posedge clk or posedge rst) begin
        if (rst)
            count_out <= 0;
        else if (load)
            count_out <= load_value;
        else if (enable && tick && count_out > 0)
            count_out <= count_out - 1;
    end

endmodule