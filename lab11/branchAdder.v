module branchAdder(
    input  [31:0] PC,
    input  [31:0] imm,
    output [31:0] branchTarget
);
    assign branchTarget = PC + (imm << 1); //this means shifting to thr left which means multiplying by 2
endmodule