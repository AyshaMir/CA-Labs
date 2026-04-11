module alu_control(
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire funct7_5,   
    output reg [3:0] ALUControl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010;   // ADD
            2'b01: ALUControl = 4'b0110;   // SUB for beq as well
            2'b10: begin
                case (funct3)
                    3'b000: ALUControl = funct7_5 ? 4'b0110 : 4'b0010;  // SUB else ADD                                     
                    3'b111: ALUControl = 4'b0000;  // AND
                    3'b110: ALUControl = 4'b0001;  // OR
                    3'b100: ALUControl = 4'b0011;  // XOR
                    3'b001: ALUControl = 4'b0100;  // SLL
                    3'b101: ALUControl = 4'b0101;  // SRL
                    default: ALUControl = 4'b0010;
                endcase
            end
            default: ALUControl = 4'b0010;
        endcase
    end
endmodule