module top_module(
    input clk,
    input rst_btn,
    input [15:0] sw,
    output [6:0] seg,
    output [3:0] an
);
    wire rst;
    wire clk_pulse;
    wire [3:0] display_value;
    wire busy;
    debouncer db(
        .clk(clk),
        .pbin(rst_btn),
        .pbout(rst)
    );

    clk_divider cd(
        .clk(clk),
        .resett(rst),
        .clk_pulse(clk_pulse)
    );

    fsm_counter fsm(
        .clk(clk),
        .resett(rst),
        .clk_pulse(clk_pulse),
        .sw(sw),
        .display_value(display_value),
        .busy(busy)
    );

    leds led_interface(
        .clk(clk),
        .rst(rst),
        .btns(16'b0),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(1'b1),
        .memAddress(30'b0),
        .display_value(display_value),
        .seg(seg),
        .an(an)
    );

endmodule
