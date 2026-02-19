module clk_divider(
    input clk,          
    input resett,          
    output reg clk_pulse
);

    // 27-bit counter (enough for large division)
    reg [26:0] counter;
    always @(posedge clk or posedge resett) begin
        if (resett) begin
            counter <= 0;
            clk_pulse <= 0;
        end 
        else if (counter == 20 - 1) begin
            counter <= 0;
            clk_pulse <= 1;      // generate 1-cycle pulse
        end 
        else begin
            counter <= counter + 1;
            clk_pulse <= 0;
        end
    end

endmodule
