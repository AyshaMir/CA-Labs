`timescale 1ns / 1ps
module immGen(
    input wire [31:0] instruction,
    output reg [31:0] Imm
);
wire [6:0] opcode = instruction[6:0];
always @(*) begin
    case (opcode)
        7'b0010011,   // ADDI
        7'b0000011:   // LW, LH, LB
            Imm = {{20{instruction[31]}}, instruction[31:20]};

        // S-type: SW, SH, SB
        7'b0100011:
            Imm = {{20{instruction[31]}},
                   instruction[31:25],
                   instruction[11:7]};

        // B-type: BEQ
        7'b1100011:
            Imm = {{19{instruction[31]}},
                   instruction[31],
                   instruction[7],
                   instruction[30:25],
                   instruction[11:8],
                   1'b0};
        default:
            Imm = 32'b0;
    endcase
end
endmodule