`timescale 1ns / 1ps
module fsm_counter(
    input clk,
    input rst,
    input [15:0] sw_in,
    output reg [15:0] led_state
);

    localparam WAIT  = 1'b0;
    localparam COUNT = 1'b1;

    reg state, next_state;
    reg enable;
    reg load_counter;
    reg [15:0] latched_value;
    wire [15:0] count_val;

    countdown timer(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .load(load_counter),
        .load_value(latched_value),
        .count_out(count_val)
    );

    always @(*) begin
        case(state)
            WAIT:
                next_state = (sw_in != 0) ? COUNT : WAIT;
            COUNT:
                next_state = (count_val == 0) ? WAIT : COUNT;
            default:
                next_state = WAIT;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= WAIT;
            enable <= 0;
            load_counter <= 0;
            latched_value <= 0;
            led_state <= 0;
        end
        else begin
            state <= next_state;

            if (state == WAIT && next_state == COUNT) begin
                latched_value <= sw_in;
                load_counter <= 1;
                enable <= 1;
            end
            else begin
                load_counter <= 0;
                enable <= (next_state == COUNT);
            end

            if (state == WAIT)
                led_state <= sw_in;
            else
                led_state <= count_val;
        end
    end

endmodule