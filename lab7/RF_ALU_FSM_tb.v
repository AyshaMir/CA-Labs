`timescale 1ns / 1ps

module RF_ALU_FSM_tb;
reg clk;
reg rst;
reg WriteEnable;
reg [4:0] rs1;
reg [4:0] rs2;
reg [4:0] rd;
reg [31:0] WriteData;
reg [3:0] ALUControl;
wire [31:0] ReadData1;
wire [31:0] ReadData2;
wire [31:0] ALUResult;
wire Zero;

// Register File
registerfile rfmod(
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


// ALU
alu alumod(
    .A(ReadData1),
    .B(ReadData2),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(Zero)
);

// FSM states
reg [3:0] state;
parameter IDLE       = 0;
parameter WRITE_REGS = 1;
parameter READ_REGS  = 2;
parameter ALU_OP     = 3;
parameter WRITE_RES  = 4;
parameter DONE       = 5;

reg [2:0] op; //operation counter
always #5 clk = ~clk;

// FSM
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        state <= IDLE;
        op <= 0;
    end
    else
    begin
        case(state)
        IDLE:
        begin
            state <= WRITE_REGS;
        end
        // write constants
        WRITE_REGS:
        begin
            WriteEnable <= 1;
            rd <= 1;
            WriteData <= 32'h10101010;
            #10;
            rd <= 2;
            WriteData <= 32'h01010101;
            #10;
            rd <= 3;
            WriteData <= 32'h00000005;
            #10;
            WriteEnable <= 0;
            state <= READ_REGS;
        end
        // read registers
        READ_REGS:
        begin
            rs1 <= 1;
            rs2 <= 2;
            state <= ALU_OP;
        end
        // perform ALU op
        ALU_OP:
        begin
            case(op)
            0: ALUControl <= 4'b0010; // ADD
            1: ALUControl <= 4'b0110; // SUB
            2: ALUControl <= 4'b0000; // AND
            3: ALUControl <= 4'b0001; // OR
            4: ALUControl <= 4'b0011; // XOR
            5: ALUControl <= 4'b0100; // SLL
            6: ALUControl <= 4'b0101; // SRL
            endcase
            state <= WRITE_RES;
        end

        // write result
        WRITE_RES:
        begin
            WriteEnable <= 1;
            rd <= 4 + op;
            WriteData <= ALUResult;
            #10;
            WriteEnable <= 0;
            if(op == 6)
                state <= DONE;
            else
            begin
                op <= op + 1;
                state <= ALU_OP;
            end
        end
        DONE:
        begin
            $finish;
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