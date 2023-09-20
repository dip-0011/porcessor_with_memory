module ALU(clk,A,B,sel,Res1,Res2); 
input clk;
input [7:0]A,B;
input [3:0]sel;  
output reg [7:0]Res1; 
output reg [7:0]Res2;

reg [7:0]A_r;
reg [7:0]B_r;

parameter NOP = 4'h0; 
parameter ADD = 4'h3; 
parameter SUB = 4'h6; 
parameter MUL = 4'h7; 
parameter DIV = 4'h4; 
// parameter AND=3'b100; 
// parameter OR=3'b101; 
// parameter NOT1 =3'b110; 
// parameter NOT2 =3'b111;

always@(posedge clk) begin
    A_r = A;
    B_r = B;
case(sel) 
ADD: Res1 = A_r+B_r; 
SUB: Res1 = A_r-B_r;
MUL: {Res2,Res1}=A_r*B_r; 
DIV: begin Res1 = A_r/B; 
     Res2 = A_r-(Res1*B_r); end
NOP: begin
    A_r = A_r; 
    B_r = B_r; 
    Res1 = Res1; 
    Res2 = Res2;
end
// AND: z=x&&y; 
// OR: z=x||y; 
// NOT1: z=!x; 
// NOT2: z=!y; 
endcase 
end
endmodule 