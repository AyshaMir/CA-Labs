module switches(
    input clk,
    input rst,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    input [15:0] sw,        //switches
    output reg [31:0] readData,
    output reg [15:0] leds
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            readData <= 0;
            leds <= 0;
        end
        else begin
            leds <= sw;
            if (readEnable)
                readData <= {16'b0, sw};
            else
                readData <= 0;
        end
    end

endmodule
