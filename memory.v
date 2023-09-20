module memory_64B(clk,rst,r_w,addr,data_in,data_out);

input clk,rst,r_w; // R\W' i.e. r_w = 1 means read and r_w = 0 means write;
input [7:0]addr;
input [7:0]data_in;
output [7:0]data_out;

reg [7:0] in_bus;
reg [7:0] out_bus;
reg [7:0] mem_reg [0:255];

integer i;

always @(*) begin
  in_bus <= data_in;  
end

always @(*) begin // resetting the memory block
  if (!rst) begin
      out_bus <= 8'd0;
      for ( i = 0 ; i<256 ; i = i+1 ) begin
          mem_reg[i] <= 8'd0;
      end
  end
end

always @(posedge clk) begin
  if (r_w) begin
    out_bus <= mem_reg[addr];
  end
  if (!r_w) begin
      mem_reg[addr] <= in_bus;
  end
end

assign data_out = out_bus;

endmodule