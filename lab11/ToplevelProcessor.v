`timescale 1ns / 1ps

module TopLevelProcessor(
    input wire clk,
    input wire rst,
    output wire [15:0] leds
);

    // Instruction Fetch
    wire [31:0] PC;
    wire [31:0] PC_Next;
    wire [31:0] PC_add4;
    wire [31:0] branchTarget;
    wire [31:0] instruction;

    // Decode
    wire [31:0] Imm;
    wire [31:0] readdata1;
    wire [31:0] readdata2;

    // Control Signals
    wire RegWrite;
    wire ALUSrc;
    wire MemRead;
    wire MemWrite;
    wire MemtoReg;
    wire Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    // Execute
    wire [31:0] ALU_B;
    wire [31:0] ALUResult;
    wire Zero;
    wire PCSrc;

    // Memory
    wire [31:0] MemReadData;

    // Writeback
    wire [31:0] WriteData;

    // INSTRUCTION FETCH
    ProgramCounter pc_reg (
        .clk(clk),
        .rst(rst),
        .PC_Next(PC_Next),
        .PC(PC)
    );

    InstructionMemory imem (
        .instAddress(PC),
        .instruction(instruction)
    );

    pcAdder pc_adder (
        .PC(PC),
        .PC_add4(PC_add4)
    );

    branchAdder branch_adder (
        .PC(PC),
        .imm(Imm),
        .branchTarget(branchTarget)
    );

    assign PCSrc = Branch & Zero;

    mux2 pc_mux (
        .in0(PC_add4),
        .in1(branchTarget),
        .select(PCSrc),
        .out(PC_Next)
    );

    // DECODE
    main_control ctrl (
        .opcode(instruction[6:0]),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    registerfile regfile (
        .clk(clk),
        .rst(rst),
        .WriteEnable(RegWrite),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .WriteData(WriteData),
        .readdata1(readdata1),
        .readdata2(readdata2)
    );

    immGen imm_gen (
        .instruction(instruction),
        .Imm(Imm)
    );

    // EXECUTE
    alu_control alu_ctrl (
        .ALUOp(ALUOp),
        .funct3(instruction[14:12]),
        .funct7_5(instruction[30]),
        .ALUControl(ALUControl)
    );

    mux2 alu_mux (
        .in0(readdata2),
        .in1(Imm),
        .select(ALUSrc),
        .out(ALU_B)
    );

    alu alu_unit (
        .A(readdata1),
        .B(ALU_B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    // MEMORY
    datamemory dmem (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .address(ALUResult),
        .write_data(readdata2),
        .read_data(MemReadData)
    );

    // WRITEBACK
    mux2 wb_mux (
        .in0(ALUResult),
        .in1(MemReadData),
        .select(MemtoReg),
        .out(WriteData)
    );

    // LED output - forces all signals to survive optimization
    assign leds = PC[15:0] ^ instruction[15:0] ^ ALUResult[15:0] ^ WriteData[15:0];

endmodule