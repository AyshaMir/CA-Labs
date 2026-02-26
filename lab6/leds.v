`timescale 1ns / 1ps

module leds(
    input clk,
    input rst,
    input [15:0] btns,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    input [15:0] switches,
    output reg [31:0] readData
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            readData <= 32'b0;
        else if (writeEnable)
            readData <= writeData;
    end

endmodule