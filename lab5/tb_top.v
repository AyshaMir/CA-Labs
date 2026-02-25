`timescale 1ns / 1ps
module tb_top;
    reg clk;
    reg rst;
    reg [15:0] sw;
    wire [15:0] leds;
    top uut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .leds(leds)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        sw  = 16'd0; 
        #20;
        rst = 0;
        //testcase1: Switch 6 counts down
        #20;
        sw = 16'd6;
        #20000;
        sw = 16'd0;
        #10000;
        //testcase2: Switch 11 counts down, Switch 4 pressed during countdown (shld be ignored)
        sw = 16'd11;
        #50000;
        sw = 16'd4;
        #20000;
        sw = 16'd0;
        #10000;
        //testcase 3: switch 6 counts, reset pressed mid-count
        sw = 16'd6;
        #50000;
        rst = 1;      // press reset
        #20;
        rst = 0;
        sw = 16'd0;
        #50000000;
        //testcase 4: Switch 4 and 5 pressed together 16 + 32 = 48
        sw = 16'b0000000000110000;  // bits 4 and 5
        #30000;   // allow full 48 ? 0
        $finish;
    end
endmodule