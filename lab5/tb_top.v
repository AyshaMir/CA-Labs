`timescale 1ns/1ps

module tb_top;

    reg clk;
    reg rst_btn;
    reg [15:0] sw;

    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate DUT
    top_module uut (
        .clk(clk),
        .rst_btn(rst_btn),
        .sw(sw),
        .seg(seg),
        .an(an)
    );

    // Clock generation (100 MHz ? 10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initial conditions
        rst_btn = 1;
        sw = 0;

        #20;
        rst_btn = 0;     // Release reset

        // -------------------------
        // Case 1: Switch 8 pressed
        // -------------------------
        #20;
        sw = 16'b0000000100000000;  // Switch 8

        #200;

        // Turn switches off
        sw = 0;

        #200;

        // -------------------------
        // Case 2: Switch 3 pressed
        // -------------------------
        sw = 16'b0000000000001000;  // Switch 3

        #200;

        sw = 0;

        #200;

        // -------------------------
        // Case 3: Reset during count
        // -------------------------
        sw = 16'b0000000000010000;  // Switch 4

        #50;
        rst_btn = 1;   // Press reset mid-count

        #20;
        rst_btn = 0;

        #200;

        $stop;
    end

endmodule
