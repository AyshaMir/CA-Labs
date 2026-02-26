`timescale 1ns/1ps
module alu_tb;

reg  [31:0] A;
reg  [31:0] B;
reg  [3:0]  ALUControl;

wire [31:0] ALUResult;
wire Zero;

// Instantiate ALU
alu unit (
    .A(A),
    .B(B),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(Zero)
);

initial begin
//AND?OR?XOR
//    A = 32'hF0F0F0F0;
//    B = 32'h0F0F0F0F;
//    ALUControl = 4'b0000; //and
//    #10;
//    ALUControl = 4'b0001; //or
//    #10;
//    ALUControl = 4'b0011; //xor

//---------------------------------
//    A = 32'd20;
//    B = 32'd5;
//    ALUControl = 4'b0010;   //add
//    #10;
//    ALUControl = 4'b0110;   //sub

//------------------------
//A = 32'd4;
//B = 32'd2;
//ALUControl = 4'b0100;   //sll
//#10;
//ALUControl = 4'b0101;   //srl
//#10;


A = 32'd10;
B = 32'd10;
ALUControl = 4'b0111;//beq
#10;

A = 32'd10;
B = 32'd5; //beq not equal
#10;
$finish;

end

endmodule