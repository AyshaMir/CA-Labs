`timescale 1ns / 1ps

module addressDecoderTop(

    input clk, rst,
    input [31:0] address,
    input readEnable, writeEnable,
    input [31:0] writeData,
    input [15:0] switches,
    output [31:0] readData,
    output [15:0] leds
);

wire DataMemSelect;
wire LEDSelect;
wire SwitchSelect;
wire [31:0] mem_read;
wire [31:0] led_read;
wire [31:0] switch_read;
adressdecoder decoder(
    .address(address),
    .DataMemSelect(DataMemSelect),
    .LEDSelect(LEDSelect),
    .SwitchSelect(SwitchSelect)
);
datamemory dataMem(
    .clk(clk),
    .MemWrite(writeEnable & DataMemSelect),
    .address(address),
    .write_data(writeData),
    .read_data(mem_read)
);
leds ledmod(
    .clk(clk),
    .rst(rst),
    .writeData(writeData),
    .writeEnable(writeEnable & LEDSelect),
    .readEnable(readEnable & LEDSelect),
    .memAddress(address[29:0]),
    .readData(led_read),
    .led_out(leds)
);
switches switchmod(
    .clk(clk),
    .rst(rst),
    .writeData(32'b0),
    .writeEnable(1'b0),
    .readEnable(readEnable & SwitchSelect),
    .memAddress(address[29:0]),
    .sw(switches),     
    .readData(switch_read));
    
assign readData =
       DataMemSelect ? mem_read :
       LEDSelect     ? led_read :
       SwitchSelect  ? switch_read :
       32'b0;

endmodule