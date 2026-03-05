`timescale 1ns / 1ps

module registerfile(
    input clk,
    input rst,
    input WriteEnable,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] WriteData,
    output [31:0] readdata1,
    output [31:0] readdata2
);

// 32 registers each 32 bits
reg [31:0] regs [31:0];

integer i;

// reset registers
always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] <= i;
        
        regs[0] <= 32'b0;
    end
    else
    begin
        //agr rd is zero then the coniditon wont come true so xero handled, never writes x0.
        if (WriteEnable && rd != 5'b00000)
            regs[rd] <= WriteData;

        // always keep x0 = 0
        regs[0] <= 32'b0;
    end
end

//if rs1 or rs2 is 0, then output 0 else ouput rs1 and rs2 
assign readdata1 = (rs1 == 5'b00000) ? 32'b0 : regs[rs1];
assign readdata2 = (rs2 == 5'b00000) ? 32'b0 : regs[rs2];

endmodule