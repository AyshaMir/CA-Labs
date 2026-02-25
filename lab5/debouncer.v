`timescale 1ns / 1ps
module debouncer(
    input clk,
    input pbin,
    output reg pbout
);

    reg [15:0] counter = 0;

    initial begin
        pbout = 0;     // initialize output
    end

    always @(posedge clk) begin
        if (pbin == pbout) begin
            counter <= 0;
        end
        else begin
            counter <= counter + 1;
            if (counter == 16'hFFFF)
                pbout <= pbin;
        end
    end

endmodule