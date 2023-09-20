`include "memory.v" // `include "alu.v"

module processor(clk,rst,start,data_in,data_out);
input clk;
input rst; //rst will stop processor and make every thing zero m_rst resets memory
input start; // starts the processing
input [7:0] data_in;// input to be stored in mem processed by ALU
output [7:0]data_out;
// register declaration
wire [7:0]mem_dat;
reg [7:0]data_in_reg;
reg counter;
reg [7:0]data_out_reg;
reg [7:0]A_Reg;
reg [7:0]B_Reg;
reg [7:0]RSR0,RSR1;
reg [7:0]pc,nxt_pc; // program counter helps to read address and data
reg [7:0]stack;
reg [3:0]op;
reg prs_state, nxt_state;
reg m_rst;//m_rst resets memory, for m_rst = 1b'0 it will be zero

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
parameter MULT = 4'h7; // unsigned multiplication
parameter DIV = 4'h4;
parameter HALT = 4'h8;

always @(posedge clk) begin
    if (!rst) begin
        prs_state <= 1'b0;
        m_rst <= 1'b0;
        A_Reg <= 8'd0;
        B_Reg <= 8'd0;
        RSR0 <= 8'd0;
        RSR1 <= 8'd0;
        op <= 4'd0;
        pc <= 8'd0;
        data_in_reg <= 8'd0;
        counter = 1'b0;
        data_out_reg <= 8'd0;
    end
    else begin
        prs_state <= nxt_state;
        pc <= nxt_pc;
        data_in_reg <= data_in;
        m_rst <= 1'b1;
    end
end
    always @(*)begin
    case (prs_state)
    WRITE : begin // processor writes to memory
        if (start) begin
            nxt_state = READ;
            m_rst = 1'b1;
        end
        else begin
            data_in_reg = data_in;
            nxt_state = WRITE;
            m_rst = 1'b1;
            if (counter == 1'b0) begin
              nxt_pc = data_in_reg;// first data input is the starting address
              counter = counter+1'b1;  
            end
            nxt_pc = pc+1;
            // counter = 1'b0;
        end
    end 
    READ: begin // processor reads from memory
        counter = 1'b0;
      if (counter == 1'b0) begin //first data from memory is op_code
          op = mem_dat[3:0];
          counter = counter + 1'b1;
      end
      else begin
          data_out_reg = mem_dat;
          counter = 1'b0;
      end
      nxt_pc = pc+1;
      case (op)
        NOP: begin
                A_Reg = A_Reg;B_Reg = B_Reg;
                RSR0=RSR0;RSR1=RSR1;
            end 
        MOVA : A_Reg = data_out_reg;
        MOVB : B_Reg = data_out_reg;
        MOVAM: begin
                if (counter == 1'b0) begin
                    stack = pc;
                    nxt_pc = M_Reg;
                    data_in_reg = A_Reg;
                    counter = counter + 1'b1; 
                end
                else begin
                    nxt_pc = stack;
                    counter = 1'b0; 
                end   
                end 
        MOVBM: begin
                if (counter == 1'b0) begin
                    stack = pc;
                    nxt_pc = M_Reg;
                    data_in_reg = B_Reg;
                    counter = counter + 1'b1; 
                end
                else begin
                    nxt_pc = stack;
                    counter = 1'b0; 
                end   
                end 
        MOVM: begin
                if (counter == 1'b0) begin
                    stack = pc;
                    nxt_pc = M_Reg;
                    counter = counter + 1'b1; 
                end
                else begin
                    nxt_pc = stack;
                    counter = 1'b0; 
                end   
                end 
        ADD: A_Reg = A_Reg+B_Reg;
        SUB: A_Reg = A_Reg-B_Reg;
        MULT: begin
                {RSR1,RSR0} = A_Reg*B_Reg;
                A_Reg = RSR0; B_Reg = RSR1;
            end
        DIV: begin RSR0 = A_Reg/B_Reg; 
               RSR1 = A_Reg-(RSR0*B_Reg);
               A_Reg = RSR0; B_Reg = RSR1; 
            end
    endcase
    end
    endcase
end

memory_64B u_memory_64B(
    .clk      	(clk),
    .rst      	(m_rst),
    .r_w      	(prs_state),
    .addr     	(pc),
    .data_in  	(data_in_reg[7:0]),
    .data_out 	(mem_dat[7:0])
);

endmodule

// case (op)
//    nop : no operatin is done
//    movA  : move data_in register A   address of Reg A = 00000110 = 8'h06
//    movB  : move data_in register B   address of reg B = 00010110 = 8'h16
//     default: 
// endcase