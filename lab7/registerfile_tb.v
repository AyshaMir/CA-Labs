`timescale 1ns/1ps
module registerfile_tb;
reg clk;
reg rst;
reg WriteEnable;
reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;
reg [31:0] WriteData;

wire [31:0] readdata1;
wire [31:0] readdata2;

registerfile rwmod(
    .clk(clk),
    .rst(rst),
    .WriteEnable(WriteEnable),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .WriteData(WriteData),
    .readdata1(readdata1),
    .readdata2(readdata2)
);

always #5 clk = ~clk;
initial
begin
    clk = 0;
    rst = 1;
    WriteEnable = 0;
    rs1 = 0;
    rs2 = 0;
    rd = 0;
    WriteData = 0;
    #10;
    rst = 0;

    // TEST CASE 1
    // Write value into register x5
//    rd = 5;
//    WriteData = 32'hDEADBEEF;
//    WriteEnable = 1;
//    #10;
//    WriteEnable = 0;
//    rs1 = 5;
//    #10;
//---------------------------------------

    // TEST CASE 2
    // Attempt to write to x0 (should remain 0)
//    rd = 0;
//    WriteData = 32'hFFFFFFFF;
//    WriteEnable = 1;
//    #10;
//    WriteEnable = 0;
//    rs1 = 0;
//    #10;
//---------------------------------------

    // TEST CASE 3
    // Simultaneous read from two registers
//    WriteEnable = 0;
//    rs1 = 3;
//    rs2 = 7;
//    #10;
//-------------------------------------------
    
    // TEST CASE 4
    // Overwrite register
//    rd = 8;
//    WriteData = 32'hAAAAAAAA;
//    WriteEnable = 1;
//    #10;
//    WriteData = 32'hBBBBBBBB;
//    WriteEnable = 1;
//    #10;
//    WriteEnable = 0;
//    rs1 = 8;
//    #10;
//-------------------------------------------
    // TEST CASE 5
    // Reset behavior
    rst = 1;
    #10;
    rst = 0;
    rs1 = 8;
    #10;
    $finish;

end

endmodule