`timescale 1ns/1ps

module RF_ALU_FSM_tb;

reg clk;
reg rst;
reg WriteEnable;
reg [4:0] rs1, rs2, rd;
reg [31:0] WriteData;
reg [3:0] ALUControl;

wire [31:0] ReadData1;
wire [31:0] ReadData2;
wire [31:0] ALUResult;
wire Zero;

registerfile RFmod(
    .clk(clk),
    .rst(rst),
    .WriteEnable(WriteEnable),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .WriteData(WriteData),
    .readdata1(ReadData1),
    .readdata2(ReadData2)
);

alu ALUmod(
    .A(ReadData1),
    .B(ReadData2),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(Zero)
);

reg [2:0] state;
reg [2:0] op;
reg [1:0] init_counter;

parameter IDLE            = 3'd0;
parameter WRITE_REGS      = 3'd1;
parameter READ_REGISTERS  = 3'd2;
parameter ALU_OPERATION   = 3'd3;
parameter WRITE_RESULTS   = 3'd4;

always #5 clk = ~clk;

always @(posedge clk or posedge rst)
begin
if(rst)
begin
    state <= IDLE;
    op <= 0;
    init_counter <= 0;
end
else
begin

case(state)

IDLE:
begin
    WriteEnable <= 0;
    state <= WRITE_REGS;
end


// Write x1,x2,x3
WRITE_REGS:
begin
    WriteEnable <= 1;

    case(init_counter)
        2'd0:
        begin
            rd <= 5'd1;
            WriteData <= 32'h10101010;
        end
        2'd1:
        begin
            rd <= 5'd2;
            WriteData <= 32'h01010101;
        end
        2'd2:
        begin
            rd <= 5'd3;
            WriteData <= 32'h00000005;
        end
    endcase

    if(init_counter == 2'd2)
    begin
        WriteEnable <= 0;
        state <= READ_REGISTERS;
    end
    else
        init_counter <= init_counter + 1;
end


// Read x1,x2
READ_REGISTERS:
begin
    rs1 <= 5'd1;
    rs2 <= 5'd2;
    state <= ALU_OPERATION;
end


// Select ALU operation
ALU_OPERATION:
begin
    case(op)
        3'd0: ALUControl <= 4'b0010; // ADD
        3'd1: ALUControl <= 4'b0110; // SUB
        3'd2: ALUControl <= 4'b0000; // AND
        3'd3: ALUControl <= 4'b0001; // OR
        3'd4: ALUControl <= 4'b0011; // XOR
        3'd5: ALUControl <= 4'b0100; // SLL
        3'd6: ALUControl <= 4'b0101; // SRL
    endcase

    state <= WRITE_RESULTS;
end


// Write results to x4-x10
WRITE_RESULTS:
begin
    WriteEnable <= 1;
    rd <= 5'd4 + op;
    WriteData <= ALUResult;
    WriteEnable <= 0;
    if(op == 3'd6)
    begin
        rs1 <= 5'd1;
        rs2 <= 5'd1;
        ALUControl <= 4'b0110;
        if(Zero)
        begin
            rd <= 5'd11;
            WriteEnable <= 1;
            WriteData <= 32'h1;
        end
        $finish;
    end
    else
    begin
        op <= op + 1;
        state <= READ_REGISTERS;
    end
end
endcase
end
end
initial
begin
clk = 0;
rst = 1;
WriteEnable = 0;
rs1 = 0;
rs2 = 0;
rd = 0;
WriteData = 0;
ALUControl = 0;
#10 rst = 0;
end
endmodule