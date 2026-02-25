`timescale 1ns / 1ps
module switches(
    input clk,
    input rst,
    input [15:0] btns,
    input [15:0] switches,
    input readEnable,
    input [31:0] writeData,
    input writeEnable,
    output reg [31:0] readData
);

    always @(posedge clk) begin
        if (rst)
            readData <= 32'b0;
        else
            readData <= {16'b0, switches};
    end

endmodule