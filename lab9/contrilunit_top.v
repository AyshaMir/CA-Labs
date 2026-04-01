`timescale 1ns / 1ps

module controlunit_top(
    input clk,
    input rst,
    input btn,
    input [15:0] sw,
    output [15:0] led
);
    // ================================
    // Debouncer
    // ================================
    wire btn_db;

    debouncer db (
        .clk(clk),
        .pbin(btn),
        .pbout(btn_db)
    );

    // ================================
    // Switch module (READ INPUT)
    // ================================
    wire [31:0] switch_data;

    switches sw_mod (
        .clk(clk),
        .rst(rst),
        .writeData(32'b0),
        .writeEnable(1'b0),
        .readEnable(1'b1),
        .memAddress(30'b0),
        .sw(sw),
        .readData(switch_data)
    );

    // Extract fields from switch_data
    wire [6:0] opcode   = switch_data[6:0];
    wire [2:0] funct3   = switch_data[9:7];
    wire       funct7_5 = switch_data[10];

    // ================================
    // Control Units
    // ================================
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    main_control mc(
        .opcode(opcode),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch(Branch),
        .ALUOp(ALUOp)
    );

    alu_control ac (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ALUControl(ALUControl)
    );

    // ================================
    // FSM
    // ================================
    reg [1:0] state;

    localparam IDLE = 2'b00,
               READ = 2'b01,
               SHOW = 2'b10;

    reg [31:0] led_data;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            led_data <= 32'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (btn_db)
                        state <= READ;
                end

                READ: begin
                    // Capture control outputs into led_data
                    led_data[0]  <= RegWrite;
                    led_data[1]  <= MemRead;
                    led_data[2]  <= MemWrite;
                    led_data[3]  <= ALUSrc;
                    led_data[4]  <= MemtoReg;
                    led_data[5]  <= Branch;

                    led_data[7:6]   <= ALUOp;
                    led_data[11:8]  <= ALUControl;

                    led_data[31:12] <= 0;

                    state <= SHOW;
                end

                SHOW: begin
                    state <= IDLE;
                end
            endcase
        end
    end

    // ================================
    // LED module (WRITE OUTPUT)
    // ================================
    leds led_mod (
        .clk(clk),
        .rst(rst),
        .writeData(led_data),
        .writeEnable(state == READ),  // write when capturing
        .readEnable(1'b0),
        .memAddress(30'b0),
        .readData(),
        .led_out(led)
    );

endmodule