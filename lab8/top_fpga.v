`timescale 1ns / 1ps
module top_fpga(
    input clk,
    input btnC,
    input btnU,
    input [15:0] sw,
    output [15:0] led
);

wire rst = btnU;
//debounc
wire btn_clean;
debouncer db(
    .clk  (clk),
    .pbin (btnC),
    .pbout(btn_clean)
);

reg btn_latched;
reg slow_tick;
always @(posedge clk or posedge rst) begin
    if (rst)
        btn_latched <= 0;
    else if (btn_clean)
        btn_latched <= 1;
    else if (btn_latched && slow_tick)  // clear when FSM will see it
        btn_latched <= 0;
end

//clk div
reg [26:0] clk_div_counter;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        clk_div_counter <= 0;
        slow_tick       <= 0;
    end else begin
        slow_tick <= 0;
        if (clk_div_counter == 27'd99_999_999) begin
            clk_div_counter <= 0;
            slow_tick       <= 1;
        end else begin
            clk_div_counter <= clk_div_counter + 1;
        end
    end
end

//FSM
localparam IDLE          = 3'd0;
localparam READ_SWITCHES = 3'd1;
localparam WAIT_SWITCHES = 3'd2;
localparam WRITE_DATAMEM = 3'd3;
localparam READ_DATAMEM  = 3'd4;
localparam WAIT_DATAMEM  = 3'd5;
localparam WRITE_LED     = 3'd6;

reg [2:0] state;
reg [31:0] captured;
reg  [31:0] address;
reg readEnable;
reg writeEnable;
reg [31:0] writeData;
wire[31:0] readData;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        address <= 0;
        readEnable <= 0;
        writeEnable <= 0;
        writeData <= 0;
        captured <= 0;
    end
    else if (slow_tick) begin
        readEnable  <= 0;
        writeEnable <= 0;
        case (state)
            IDLE: begin
                if (btn_latched)
                    state <= READ_SWITCHES;
            end
            READ_SWITCHES: begin
                address <= 32'd512;
                readEnable <= 1;
                state <= WAIT_SWITCHES;
            end
            WAIT_SWITCHES: begin
                captured <= readData;
                state <= WRITE_DATAMEM;
            end
            WRITE_DATAMEM: begin
                address <= 32'd10;
                writeData <= captured;
                writeEnable <= 1;
                state <= READ_DATAMEM;
            end
            READ_DATAMEM: begin
                address <= 32'd10;
                readEnable <= 1;
                state <= WAIT_DATAMEM;
            end
            WAIT_DATAMEM: begin
                captured <= readData;
                state <= WRITE_LED;
            end
            WRITE_LED: begin
                address <= 32'd256;
                writeData <= captured;
                writeEnable <= 1;
                state <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
end
//memeory system
addressDecoderTop mem_sys(
    .clk (clk),
    .rst (rst),
    .address (address),
    .readEnable (readEnable),
    .writeEnable(writeEnable),
    .writeData (writeData),
    .switches (sw),
    .readData(readData),
    .leds(led)
);
endmodule