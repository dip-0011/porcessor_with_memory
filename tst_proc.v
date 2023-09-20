module processor(clk,rst,start,data_in,data_out);
input clk;
input rst; //rst will stop processor and make every thing zero m_rst resets memory
input start; // starts the processing
input [7:0]data_in;// input to be stored in mem processed by ALU
output [7:0]data_out;

reg [7:0]mem[0:255];//onsite memory
reg [7:0]A;
reg [7:0]B;
// reg [7:0]C; // 3 registers special registers
reg [7:0]PC;
reg [3:0]op_c;
reg state;
reg [1:0]counter; 
reg [7:0]temp;

wire [7:0]ALU_result;

parameter WRITE = 1'b0;//start writing to memory when start = 0
parameter READ = 1'b1;// start reading memory when start = 1

parameter M_Reg = 8'h26; // memeory register
// opeartion declaration
parameter NOP = 4'h0;
parameter MOVA = 4'h1;
parameter MOVB = 4'h2;
parameter MOVAM = 4'h9;
parameter MOVBM = 4'ha;
parameter MOVM = 4'hc;
parameter ADD = 4'h3;
parameter SUB = 4'h6;
// parameter MULT = 4'h7; // unsigned multiplication
// parameter DIV = 4'h4;
parameter HALT = 4'h8;

always @(posedge clk) begin
    if (!rst) begin
        state <= 1'b0;
        A <= 8'b0;
        B <= 8'b0;
        PC <= 8'b0;
        op_c <= 4'b0;
        counter <= 2'b00;
    end
    else begin
    case (state)
        WRITE : begin
             if (start) begin
                state <= state + 1'b1;
            end 
            else begin
                state = state;
                case (counter)
                    2'b00 : begin
                        PC <= data_in; // recording the starting address
                        PC <= PC + 1'b1; // increment program conter
                        counter <= counter + 1'b1;
                    end
                    2'b01: begin
                        mem[PC] <= data_in; // saving the instruction in address
                        PC <= PC+1'b1; // increment the Program Counter
                        counter <= counter + 1'b1;
                    end
                    2'b10: begin
                        mem[PC] <= data_in; // save the data 
                        PC <= PC+1'b1;
                        counter <= counter - 1'b1;
                    end
                endcase
            end
        end 
        READ : begin
            PC <= data_in;
            counter <= 2'b00;
            temp <= mem[PC];
            case (counter)
                2'b00 : begin
                    op_c <= temp[3:0];
                    PC <= PC+1'b1;
                    counter <= counter+1'b1;
                end
                2'b01 :begin
                    A <= temp;
                    PC <= PC+1'b1;
                    counter <= counter+1'b1;
                end
                2'b10 :begin
                    B <= temp;
                    PC <= PC+1;
                    counter <= 2'b00;
                end
            endcase
        end   
    endcase    
    end
end


endmodule
