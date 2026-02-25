`timescale 1ns / 1ps
module top(
    input clk,
    input rst,
    input [15:0] sw,
    output [15:0] leds
);

    wire [31:0] switch_bus;
    wire [15:0] fsm_led_out;
    switches swmod (
        .clk(clk),
        .rst(rst),
        .btns(16'b0),
        .switches(sw),
        .readEnable(1'b0),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readData(switch_bus)
    );
    fsm_counter fsm (
        .clk(clk),
        .rst(rst),
        .sw_in(switch_bus[15:0]),
        .led_state(fsm_led_out)
    );

    assign leds = fsm_led_out;

endmodule