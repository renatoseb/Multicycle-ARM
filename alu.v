module alu (input [31:0] a,b,
             input [2:0] ALUControl,    
             output reg [31:0] Result32, //assign always block
             output reg [31:0] Result64,
             output wire [3:0] ALUFlags); //explicit wire for assign with {}
  
  wire negative, zero, carry, overflow; // define wire for each flag (n,z,c,v)
  wire [32:0] sum;
  
  
  assign sum = a + (ALUControl[0]? ~b: b) + ALUControl[0]; //ADDER: two's complement
  
  /*
  ALUControl Logic
  00: sum
  01: sub
  10: and
  11: or
  10: eor
  */
  always @(*)
    casex (ALUControl[1:0]) //case, casex, casez
      3'b00?: Result = sum;    // ADD
      3'b001: Result = a - b;  // SUB
      3'b010: Result = a & b;  // AND
      3'b011: Result = a | b;  // OR
      3'b100: Result = a * b;  // MUL
      3'b101: Result =      ;  // UMULL
      3'b110: Result =      ;  // SMULL
    endcase
  
 //flags: result -> negative, zero
  assign negative = Result[31];
  assign zero = (Result == 32'b0);
  //flags: additional logic -> v, c
  assign carry = (ALUControl[1]==1'b0) & sum[32];
  assign overflow = (ALUControl[1]==1'b0) & ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]);

  assign ALUFlags = {negative, zero, carry, overflow};

endmodule