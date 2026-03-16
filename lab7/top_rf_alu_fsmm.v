`timescale 1ns / 1ps

//   led[2:0]  = FSM state
//               000=S_RESET  001=S_WRITE_A  010=S_WRITE_B  011=S_FETCH
//               100=S_EXECUTE  101=S_STORE  110=S_BEQ  111=S_IDLE
//
//   led[5:3]  = op_index (which ALU operation, 0-6)
//               000=ADD  001=SUB  010=AND  011=OR  100=XOR  101=SLL  110=SRL
//
//   led[15:6] = lower 10 bits of ALU result
//               watch this change every 5 seconds when a new op runs

module top_rf_alu_fsm (
    input  wire clk,
    input  wire [15:0] SW,
    input  wire [4:0]  BTN, //rst
    output wire [15:0] LED
);

wire rst;
debouncer dbmod (
    .clk  (clk),
    .pbin (BTN[0] | SW[15]),
    .pbout(rst)
);

wire [31:0] sw_data;
switches swmod (
    .clk (clk),
    .rst (rst),
    .btns ({11'b0, BTN}),
    .switches (SW),
    .readEnable(1'b1),
    .writeData (32'b0),
    .writeEnable(1'b0),
    .readData (sw_data)
);

//reg file
reg rf_we;
reg [4:0] rf_rs1;
reg [4:0] rf_rs2;
reg [4:0] rf_rd;
reg [31:0] rf_wdata;
wire [31:0] rf_out1;
wire [31:0] rf_out2;

registerfile rfmod (
    .clk (clk),
    .rst (rst),
    .WriteEnable(rf_we),
    .rs1 (rf_rs1),
    .rs2 (rf_rs2),
    .rd (rf_rd),
    .WriteData (rf_wdata),
    .readdata1 (rf_out1),
    .readdata2 (rf_out2)
);

//alu
reg [3:0]  alu_ctrl;
wire [31:0] alu_res;
wire alu_zero;

alu alumod (
    .A (rf_out1),
    .B (rf_out2),
    .ALUControl(alu_ctrl),
    .ALUResult (alu_res),
    .Zero (alu_zero)
);

//leds
reg  [31:0] led_din;
wire [31:0] led_dout;

leds ledmod (
    .clk (clk),
    .rst (rst),
    .writeData (led_din),
    .writeEnable(1'b1),
    .readEnable (1'b0),
    .memAddress (30'b0),
    .readData (led_dout),
    .leds (LED)
);

//FSM state definitions
localparam [2:0]
    S_RESET   = 3'd0,
    S_WRITE_A = 3'd1,
    S_WRITE_B = 3'd2,
    S_FETCH   = 3'd3,
    S_EXECUTE = 3'd4,
    S_STORE   = 3'd5,
    S_BEQ     = 3'd6,
    S_IDLE    = 3'd7;

localparam [31:0] CONST_A = 32'h10101010;
localparam [31:0] CONST_B = 32'h01010101;

reg [2:0] state;
reg [2:0] op_idx;

//evry 5 seconds 
reg [28:0] tick_cnt;
reg        tick;

always @(posedge clk) begin
    if (rst) begin
        tick_cnt <= 29'd0;
        tick     <= 1'b0;
    end else begin
        tick <= 1'b0;
        if (tick_cnt == 29'd499_999_999) begin
            tick_cnt <= 29'd0;
            tick     <= 1'b1;
        end else begin
            tick_cnt <= tick_cnt + 1;
        end
    end
end

always @(posedge clk) begin
    if (rst) begin
        state    <= S_RESET;
        op_idx   <= 3'd0;
        rf_we    <= 1'b0;
        rf_rs1   <= 5'd0;
        rf_rs2   <= 5'd0;
        rf_rd    <= 5'd0;
        rf_wdata <= 32'd0;
        alu_ctrl <= 4'b0000;
    end
    else if (tick) begin
        rf_we <= 1'b0;
        case (state)
            S_RESET: begin
                op_idx <= 3'd0;
                state  <= S_WRITE_A;
            end
            // write x1 = 0x10101010
            S_WRITE_A: begin
                rf_we    <= 1'b1;
                rf_rd    <= 5'd1;
                rf_wdata <= CONST_A;
                state    <= S_WRITE_B;
            end
            // write x2 = 0x01010101
            S_WRITE_B: begin
                rf_we    <= 1'b1;
                rf_rd    <= 5'd2;
                rf_wdata <= CONST_B;
                state    <= S_FETCH;
            end
            // point rs1 -> x1, rs2 -> x2
            S_FETCH: begin
                rf_rs1 <= 5'd1;
                rf_rs2 <= 5'd2;
                state  <= S_EXECUTE;
            end

            S_EXECUTE: begin
                case (op_idx)
                    3'd0: alu_ctrl <= 4'b0010; // ADD 111
                    3'd1: alu_ctrl <= 4'b0110; // SUB f0f
                    3'd2: alu_ctrl <= 4'b0000; // AND 000
                    3'd3: alu_ctrl <= 4'b0001; // OR  111
                    3'd4: alu_ctrl <= 4'b0011; // XOR 111 
                    3'd5: alu_ctrl <= 4'b0100; // SLL 
                    3'd6: alu_ctrl <= 4'b0101; // SRL 
                    default: alu_ctrl <= 4'b0000;
                endcase
                state <= S_STORE;
            end

            // store result, loop or go to BEQ
            S_STORE: begin
                rf_we    <= 1'b1;
                rf_rd    <= 5'd4 + {2'b00, op_idx};
                rf_wdata <= alu_res;

                if (op_idx == 3'd6) begin
                    state <= S_BEQ;
                end else begin
                    op_idx <= op_idx + 1;
                    state  <= S_FETCH;
                end
            end

            // SUB(x1,x1) = 0, BEQ check
            S_BEQ: begin
                rf_rs1   <= 5'd1;
                rf_rs2   <= 5'd1;
                alu_ctrl <= 4'b0110;
                state    <= S_IDLE;
            end
            S_IDLE: begin
                alu_ctrl <= {1'b0, sw_data[2:0]};
                rf_we    <= sw_data[3];
                state    <= S_RESET;
            end

            default: state <= S_RESET;

        endcase
    end
end
always @(*) begin
    led_din = {
        16'b0,
        alu_res[9:0],    // led[15:6] -- ALU result
        op_idx,          // led[5:3]  -- current op
        state            // led[2:0]  -- FSM state
    };
end

endmodule