`timescale 1ns / 1ps
module MemorySystem_tb;

reg clk, rst;
reg [31:0] address;
reg readEnable, writeEnable;
reg [31:0] writeData;
reg [15:0] switches;

wire [31:0] readData;
wire [15:0] leds;

addressDecoderTop mod(
    .clk(clk),
    .rst(rst),
    .address(address),
    .readEnable(readEnable),
    .writeEnable(writeEnable),
    .writeData(writeData),
    .switches(switches),
    .readData(readData),
    .leds(leds)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    // Reset
    rst         = 1;
    address     = 0;
    readEnable  = 0;
    writeEnable = 0;
    writeData   = 0;
    switches    = 0;
    @(posedge clk); @(posedge clk);
    rst = 0;

    //test1: Write to Data Memory (address 10, bits[9:8]=00)
    @(negedge clk);
    address     = 32'd10;
    writeData   = 32'hAAAA5555;
    writeEnable = 1;
    @(posedge clk); #1;
    writeEnable = 0;

    //test2: Read from Data Memory (address 10, bits[9:8]=00)
    @(negedge clk);
    address    = 32'd10;
    readEnable = 1;
    @(posedge clk); #1;
    readEnable = 0;
    // readData should be 0xAAAA5555

    //test3: Write to LEDs (address 256, bits[9:8]=01)
    @(negedge clk);
    address     = 32'd256;
    writeData   = 32'h0000F0F0;
    writeEnable = 1;
    @(posedge clk); #1;
    writeEnable = 0;
    // leds should be 0xF0F0

    //test4: Read from Switches (address 512, bits[9:8]=10)
    @(negedge clk);
    switches   = 16'b0000000000001010;
    address    = 32'd512;
    readEnable = 1;
    @(posedge clk); #1;
    readEnable = 0;
    // readData should be 0x0000000A

    //test5 :Write second value to Data Memory, verify LEDs unchanged
    @(negedge clk);
    address     = 32'd20;
    writeData   = 32'hDEADBEEF;
    writeEnable = 1;
    @(posedge clk); #1;
    writeEnable = 0;
    // leds should still be 0xF0F0

    //test6:  Read second Data Memory location
    @(negedge clk);
    address    = 32'd20;
    readEnable = 1;
    @(posedge clk); #1;
    readEnable = 0;
    // readData should be 0xDEADBEEF
    @(posedge clk); @(posedge clk);
    $finish;
end
endmodule