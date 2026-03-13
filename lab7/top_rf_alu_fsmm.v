`timescale 1ns / 1ps

//led 0-2 current FSM state number (changes every 1 second)
//led3-5  = alu_step (which ALU operation we are on, 0 through 6)
//led 6 is WriteEnable
//led 7 is Zero flag from ALU output
//led[15:8] are the lower 8 bits of current ALU result (so you can see it change)

module top_rf_alu_fsmm (
    input  wire        clk,
    input  wire [15:0] SW,
    input  wire [4:0]  BTN,     //used as reset
    output wire [15:0] LED
);

wire rst_debounced;
debouncer db (
    .clk  (clk),
    .pbin (BTN[0] | SW[15]),
    .pbout(rst_debounced)
);

//you can use first three ot ovveride manual ALU op select 
//use the 4th one to maanual WriteEnable
wire [31:0] sw_captured;
switches swmod (
    .clk        (clk),
    .rst        (rst_debounced),
    .btns       ({11'b0, BTN}),
    .switches   (SW),
    .readEnable (1'b1),
    .writeData  (32'b0),
    .writeEnable(1'b0),
    .readData   (sw_captured)
);

reg        wen;          // write enable
reg  [4:0] rs1;
reg  [4:0] rs2;
reg  [4:0] rd;
reg [31:0] wdata;        // data to write into rd
wire [31:0] readdata1;
wire [31:0] readdata2;

registerfile rdmod (
    .clk        (clk),
    .rst        (rst_debounced),
    .WriteEnable(wen),
    .rs1        (rs1),
    .rs2        (rs2),
    .rd         (rd),
    .WriteData  (wdata),
    .readdata1  (readdata1),
    .readdata2  (readdata2)
);


reg  [3:0]  alu_opcode;
wire [31:0] alu_result;
wire zero_flag;
alu alumod(
    .A(readdata1),
    .B(readdata2),
    .ALUControl(alu_opcode),
    .ALUResult (alu_result),
    .Zero(zero_flag)
);


reg  [31:0] led_data;
wire [31:0] led_out_wire;
leds ledmod(
    .clk        (clk),
    .rst        (rst_debounced),
    .writeData  (led_data),
    .writeEnable(1'b1),
    .readEnable (1'b1),
    .memAddress (30'b0),
    .readData   (led_out_wire)
);
assign LED = led_out_wire[15:0];

//FSM STatss
localparam [2:0]
    S_RESET   = 3'd0,   // clear everything, go to S_WRITE_A
    S_WRITE_A = 3'd1,
    S_WRITE_B = 3'd2,
    S_FETCH   = 3'd3,
    S_EXECUTE = 3'd4,
    S_STORE   = 3'd5,
    S_BEQ     = 3'd6,
    S_IDLE    = 3'd7;
localparam [31:0] OPERAND_A = 32'h10101010;
localparam [31:0] OPERAND_B = 32'h01010101;

reg [2:0] cur_state; 
reg [2:0] op_index; // which ALU op 0 to 6 shows on led[5:3]

//clk div
reg [26:0] div_counter;
reg tick;

always @(posedge clk) begin
    if (rst_debounced) begin
        div_counter <= 27'd0;
        tick        <= 1'b0;
    end else begin
        tick <= 1'b0;
        if (div_counter == 27'd99_999_999) begin
            div_counter <= 27'd0;
            tick        <= 1'b1;
        end else begin
            div_counter <= div_counter + 1;
        end
    end
end

//FSM
always @(posedge clk) begin
    if (rst_debounced) begin
        cur_state  <= S_RESET;
        op_index   <= 3'd0;
        wen        <= 1'b0;
        alu_opcode <= 4'b0000;
        rs1       <= 5'd0;
        rs2       <= 5'd0;
        rd        <= 5'd0;
        wdata      <= 32'd0;
    end
    else if (tick) begin
        wen <= 1'b0;

        case (cur_state)
            S_RESET: begin
                op_index  <= 3'd0;
                cur_state <= S_WRITE_A;
            end
            //write A into register x1
            S_WRITE_A: begin
                wen       <= 1'b1;
                rd       <= 5'd1;
                wdata     <= OPERAND_A;
                cur_state <= S_WRITE_B;
            end
            //write B into register x2
            S_WRITE_B: begin
                wen       <= 1'b1;
                rd       <= 5'd2;
                wdata     <= OPERAND_B;
                cur_state <= S_FETCH;
            end
            //read ports at x1 and x2
            S_FETCH: begin
                rs1      <= 5'd1;
                rs2      <= 5'd2;
                cur_state <= S_EXECUTE;
            end
            //latch the ALU opcode for this op_index
            S_EXECUTE: begin
                case (op_index)
                    3'd0: alu_opcode <= 4'b0010; // ADD
                    3'd1: alu_opcode <= 4'b0110; // SUB
                    3'd2: alu_opcode <= 4'b0000; // AND
                    3'd3: alu_opcode <= 4'b0001; // OR
                    3'd4: alu_opcode <= 4'b0011; // XOR
                    3'd5: alu_opcode <= 4'b0100; // SLL
                    3'd6: alu_opcode <= 4'b0101; // SRL
                    default: alu_opcode <= 4'b0000;
                endcase
                cur_state <= S_STORE;
            end
            //write ALU result into x4 + op_index
            S_STORE: begin
                wen   <= 1'b1;
                rd   <= 5'd4 + {2'b00, op_index};
                wdata <= alu_result;

                if (op_index == 3'd6) begin
                    cur_state <= S_BEQ;
                end else begin
                    op_index  <= op_index + 1;
                    cur_state <= S_FETCH;
                end
            end

            //esult must be 0
            S_BEQ: begin
                rs1       <= 5'd1;
                rs2       <= 5'd1;
                alu_opcode <= 4'b0110; // SUB
                cur_state  <= S_IDLE;
            end
            S_IDLE: begin
                alu_opcode <= {1'b0, sw_captured[2:0]};
                wen        <= sw_captured[3];
                cur_state  <= S_RESET;
            end

            default: cur_state <= S_RESET;

        endcase
    end
end

always @(*) begin
    led_data = {
        16'b0,           // upper 16 bits unused
        alu_result[7:0],
        zero_flag,       // led[7]
        wen,             // led[6]
        op_index,        // led[5:3[
        cur_state        // led[2:0]
    };
end

endmodule