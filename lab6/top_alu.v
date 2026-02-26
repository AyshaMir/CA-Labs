`timescale 1ns / 1ps

module top_alu(
    input clk,
    input rst,
    input [15:0] switches_in,
    output [15:0] leds_out
);

// ----------------------------------------------------
// 1) SWITCH MODULE (reuse from Lab 5)
// ----------------------------------------------------
wire [31:0] switchData;

switches swblock (
    .clk(clk),
    .rst(rst),
    .btns(16'b0),
    .switches(switches_in),
    .readEnable(1'b1),
    .writeData(32'b0),
    .writeEnable(1'b0),
    .readData(switchData)
);

// ALUControl from lower 4 switches
wire [3:0] ALUControl;
assign ALUControl = switchData[3:0];


// ----------------------------------------------------
// 2) DEBOUNCER for display selector (switch[4])
// ----------------------------------------------------
wire display_select_clean;

debouncer db(
    .clk(clk),
    .pbin(switches_in[4]),
    .pbout(display_select_clean)
);


// ----------------------------------------------------
// 3) FIXED OPERANDS (as required by PDF)
// ----------------------------------------------------
wire [31:0] A = 32'b00010000000100000001000000010000;
wire [31:0] B = 32'b00000001000000010000000100000001;


// ----------------------------------------------------
// 4) ALU
// ----------------------------------------------------
wire [31:0] ALUResult;
wire Zero;

alu alublock(
    .A(A),
    .B(B),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(Zero)
);


// ----------------------------------------------------
// 5) LED MODULE (reuse from Lab 5)
// ----------------------------------------------------
wire [31:0] ledData;

leds ledblock(
    .clk(clk),
    .rst(rst),
    .btns(16'b0),
    .writeData(ALUResult),
    .writeEnable(1'b1),     // always follow ALU
    .readEnable(1'b0),
    .memAddress(30'b0),
    .switches(16'b0),
    .readData(ledData)
);


// ----------------------------------------------------
// 6) DISPLAY SELECTION (Upper / Lower 16 bits)
// ----------------------------------------------------
assign leds_out = (display_select_clean) ?
                  ledData[31:16] :   // upper half
                  ledData[15:0];    // lower half

endmodule