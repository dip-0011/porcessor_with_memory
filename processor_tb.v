`timescale 1ps/1ps
`include "processor.v"

module process_tb;//clk,rst,start,data_in,data_out
reg clk,rst,start;
reg [7:0]data_in;
wire [7:0]data_out;

processor uut(clk,rst,start,data_in,data_out);
always begin
    clk = ~clk;#1;
end
initial begin
    clk = 1'b1;
    rst = 1'b0;#2;
    rst = 1'b1;
end
initial begin
    $dumpfile("processor.vcd");
    $dumpvars(0,process_tb);
    data_in = 8'h55;#6; // starting address
    data_in = 8'h01;#5;
    data_in = 8'h0a;#5;
    data_in = 8'h02;#5;
    data_in = 8'ha0;#5;
    data_in = 8'h03;#5;
    start = 1'b1; #10;
    $finish;
end

endmodule