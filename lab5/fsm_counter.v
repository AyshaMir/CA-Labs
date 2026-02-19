module fsm_counter(
    input clk,
    input resett,
    input clk_pulse,          // slow pulse from clock divider
    input [15:0] sw,          // 16 FPGA switches
    output reg [3:0] display_value,
    output reg busy
);
    //state Encoding
    localparam IDLE  = 2'b00;
    localparam WAIT  = 2'b01;
    localparam COUNT = 2'b10;

    reg [1:0] state;
    reg [3:0] counter;
    
    //chooses which switch to be taken into acc when more thanone on 
    reg [3:0] encoded_value;
    reg valid;
    integer i;

    always @(*) begin
        encoded_value = 0;
        valid = 0;

        for (i = 15; i >= 0; i = i - 1) begin
            if (sw[i]) begin
                encoded_value = i[3:0];   // highest switch index
                valid = 1;
            end
        end
    end

    // FSM + Counter Logic
    always @(posedge clk or posedge resett) begin
        if (resett) begin
            state <= IDLE;
            counter <= 0;
            display_value <= 0;
            busy <= 0;
        end
        else begin
            case (state)
                // IDLE STATE
                IDLE: begin
                    busy <= 0;

                    if (valid) begin
                        counter <= encoded_value;
                        display_value <= encoded_value;
                        busy <= 1;
                        state <= WAIT;
                    end
                end

                // WAIT STATE
                // Wait for first pulse
                WAIT: begin
                    busy <= 1;
                    if (clk_pulse)
                        state <= COUNT;
                end

                // COUNT STATE
                COUNT: begin
                    busy <= 1;

                    if (clk_pulse) begin
                        if (counter > 0) begin
                            counter <= counter - 1;
                            display_value <= counter - 1;
                        end
                        else begin
                            state <= IDLE;
                            busy <= 0;
                        end
                    end
                end

            endcase
        end
    end

endmodule
