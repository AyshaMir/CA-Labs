`timescale 1ns / 1ps
module control_tb;
    // Inputs
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg funct7_5;
    // Outputs from main_control
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    // Output from alu_control
    wire [3:0] ALUControl;

    // ================================
    // Instantiate Main Control
    // ================================
    main_control mc (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    // ================================
    // Instantiate ALU Control
    // ================================
    alu_control ac (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ALUControl(ALUControl)
    );

    // ================================
    // Test Sequence
    // ================================
    initial begin
        // ================================
        // R-TYPE: ADD
        // ================================
        opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 0;
        #10;

        // ================================
        // R-TYPE: SUB
        // ================================
        opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 1;
        #10;

        // ================================
        // R-TYPE: AND
        // ================================
        opcode = 7'b0110011; funct3 = 3'b111; funct7_5 = 0;
        #10;

        // ================================
        // R-TYPE: OR
        // ================================
        opcode = 7'b0110011; funct3 = 3'b110; funct7_5 = 0;
        #10;

        // ================================
        // R-TYPE: XOR
        // ================================
        opcode = 7'b0110011; funct3 = 3'b100; funct7_5 = 0;
        #10;

        // ================================
        // R-TYPE: SLL
        // ================================
        opcode = 7'b0110011; funct3 = 3'b001; funct7_5 = 0;
        #10;

        // ================================
        // R-TYPE: SRL
        // ================================
        opcode = 7'b0110011; funct3 = 3'b101; funct7_5 = 0;
        #10;

        // ================================
        // I-TYPE: ADDI
        // ================================
        opcode = 7'b0010011; funct3 = 3'b000; funct7_5 = 0;
        #10;

        // ================================
        // LOAD: LW
        // ================================
        opcode = 7'b0000011; funct3 = 3'b010; funct7_5 = 0; // LW
        #10;
        
        // ================================
        // LOAD: LH
        // ================================
        opcode = 7'b0000011; funct3 = 3'b001; funct7_5 = 0; // LH
        #10;
        
        // ================================
        // LOAD: LB
        // ================================
        opcode = 7'b0000011; funct3 = 3'b000; funct7_5 = 0; // LB
        #10;
        
        // ================================
        // STORE: SW
        // ================================
        opcode = 7'b0100011; funct3 = 3'b010; funct7_5 = 0; // SW
        #10;
        
        // ================================
        // STORE: SH
        // ================================
        opcode = 7'b0100011; funct3 = 3'b001; funct7_5 = 0; // SH
        #10;
        
        // ================================
        // STORE: SB
        // ================================
        opcode = 7'b0100011; funct3 = 3'b000; funct7_5 = 0; // SB
        #10;

        // ================================
        // BRANCH: BEQ
        // ================================
        opcode = 7'b1100011; funct3 = 3'b000; funct7_5 = 0;
        #10;
    end

endmodule