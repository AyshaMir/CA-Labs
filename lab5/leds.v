module leds(
    input clk,
    input rst,
    input [15:0] btns,
    input [31:0] writeData,
    input writeEnable,
    input readEnable,
    input [29:0] memAddress,
    input [3:0] display_value,   // read the current value from FSM
    output [6:0] seg,
    output [3:0] an
);
    seven_segment ssd(
        .digit(display_value),
        .seg(seg)
    );

    //wwe are using only the first segment
    assign an = 4'b1110;

endmodule
