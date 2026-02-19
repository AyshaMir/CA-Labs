module debouncer(
    input clk,
    input pbin,
    output reg pbout
);

    reg [19:0] counter = 0;
    reg sync_0 = 0;
    reg sync_1 = 0;

    always @(posedge clk) begin
        sync_0 <= pbin;
        sync_1 <= sync_0;
    end

    always @(posedge clk) begin
        if (pbout == sync_1)
            counter <= 0;
        else begin
            counter <= counter + 1;
            if (counter == 5) begin
                pbout <= sync_1;
                counter <= 0;
            end
        end
    end

endmodule
