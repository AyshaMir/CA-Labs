`timescale 1ns / 1ps

module pc_update_imm_gen_tb;

    reg clk, rst;
    reg PCSrc;
    reg [31:0] imm_input;
    reg [31:0] instruction;

    wire [31:0] PC;
    wire [31:0] PC_add4;
    wire [31:0] branchTarget;
    wire [31:0] PC_Next;
    wire [31:0] Imm;

    always #5 clk = ~clk;

    ProgramCounter uut_pc (
        .clk    (clk),
        .rst    (rst),
        .PC_Next(PC_Next),
        .PC     (PC)
    );

    pcAdder uut_pcAdder (
        .PC     (PC),
        .PC_add4(PC_add4)
    );

    branchAdder uut_branchAdder (
        .PC          (PC),
        .imm         (imm_input),
        .branchTarget(branchTarget)
    );

    mux2 uut_mux2 (
        .in0   (PC_add4),
        .in1   (branchTarget),
        .select(PCSrc),
        .out   (PC_Next)
    );

    immGen uut_immGen (
        .instruction(instruction),
        .Imm        (Imm)
    );

    initial begin
        clk         = 0;
        rst         = 1;
        PCSrc       = 0;
        imm_input   = 32'd0;
        instruction = 32'd0;
        #10; rst    = 0;

        // TC1: PC increments by 4 (PCSrc = 0)
        PCSrc = 0;
        #40;

        // TC2: Branch taken (PCSrc = 1), offset = +8
        imm_input = 32'd8;
        PCSrc     = 1;
        #20;
        PCSrc     = 0;
        #10;

        // TC3: Immediate generation - I-type (imm = +5), S-type (imm = +12), B-type (imm = -8)
        instruction = 32'b000000000101_00000_000_00001_0010011; #10; // I-type imm = +5
        instruction = 32'b0000000_00010_00001_010_01100_0100011; #10; // S-type imm = +12
        instruction = 32'b1_111111_00000_00000_000_1100_1_1100011; #10; // B-type imm = -8

        $finish;
    end
endmodule