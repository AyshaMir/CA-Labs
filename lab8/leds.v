module leds(
    input clk,
    input rst,
    input [31:0] writeData,
    input writeEnable,
    input [29:0] memAddress,

    output [31:0] readData,
    output reg [15:0] leds
);

always @(posedge clk)
begin
    if (rst)
        leds <= 16'b0;

    else if (writeEnable)
        leds <= writeData[15:0];
end

assign readData = {16'b0, leds};

endmodule