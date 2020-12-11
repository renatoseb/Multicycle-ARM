module mainfsm (
	clk,
	reset,
	Op,
	Funct,
	IRWrite,
	AdrSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	NextPC,
	RegW,
	MemW,
	Branch,
	ALUOp,
	Flag_64b,
	Src_64b,
	FpuW
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire Flag_64b;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ResultSrc;
	output wire NextPC;
	output wire RegW;
	output wire MemW;
	output wire Branch;
	output wire ALUOp;
	inout Src_64b;
	output wire FpuW;

	reg [3:0] state;
	reg [3:0] nextstate;
	reg [14:0] controls;
	localparam [3:0] FETCH = 0;
    localparam [3:0] DECODE = 1;
    localparam [3:0] MEMADR = 2;
    localparam [3:0] MEMRD = 3;
    localparam [3:0] MEMWB = 4;
	localparam [3:0] MEMWR = 5;
    localparam [3:0] EXECUTER = 6;
	localparam [3:0] EXECUTEI = 7;
    localparam [3:0] ALUWB = 8;
	localparam [3:0] BRANCH = 9;
	localparam [3:0] UNKNOWN = 10;
	localparam [3:0] EXECUTEF = 11;
	localparam [3:0] FPUWB = 12; 	
	localparam [3:0] ALU64BW = 13;


	// state register
	always @(posedge clk or posedge reset)
		if (reset)
			state <= FETCH;
		else
			state <= nextstate;
	

	// ADD CODE BELOW
  	// Finish entering the next state logic below.  We've completed the 
  	// first two states, FETCH and DECODE, for you.

  	// next state logic
	always @(*)
		casex (state)
			FETCH: nextstate = DECODE;
			DECODE:
				case (Op)
					2'b00:
						if (Funct[5])
							nextstate = EXECUTEI;
						else
							nextstate = EXECUTER;
					2'b01: nextstate = MEMADR;
					2'b10: nextstate = BRANCH;
					2'b11: nextstate = EXECUTEF;
					default: nextstate = UNKNOWN;
				endcase
//DOING   
			MEMADR:
                if (Funct[0]) 
                    nextstate = MEMRD;
                else 
                    nextstate = MEMWR;
			MEMRD:    nextstate = MEMWB;
            MEMWB:    nextstate = FETCH;
            MEMWR:    nextstate = FETCH;
			EXECUTER:
				begin
					if(Flag_64b == 1'b1) begin
						nextstate = ALU64BW;
					end
					else begin
						nextstate = ALUWB;
					end
				end
            EXECUTEI:
				begin
					if(Flag_64b == 1'b1) begin
						nextstate = ALU64BW;
					end
					else begin
						nextstate = ALUWB;
					end
				end
			EXECUTEF: nextstate = FPUWB;
			FPUWB:    nextstate = FETCH;
			ALUWB:    nextstate = FETCH;
			ALU64BW:   nextstate = FETCH;
			BRANCH:   nextstate = FETCH;
            default: nextstate = FETCH;
		endcase

	// ADD CODE BELOW
	// Finish entering the output logic below.  We've entered the
	// output logic for the first two states, FETCH and DECODE, for you.

	// state-dependent output logic
	always @(*)
		case (state)
			FETCH: controls =     15'b001000101001100;                          
			DECODE: controls =    15'b000000001001100;                         
			EXECUTER: controls =  15'b000000000000001;                       
			EXECUTEI: controls =  15'b000000000000011;                       
			ALUWB: controls =     15'b000001000000000;                          
			MEMADR: controls =    15'b000000000000010;                         
			MEMWR: controls =     15'b000010010000000;                          
			MEMRD: controls =     15'b000000010000000;                          
			MEMWB: controls =     15'b000001000100000;                          
			BRANCH: controls =    15'b000100001000010;
			EXECUTEF: controls =  15'b000000000000000;
			FPUWB:    controls =  15'b100000000000000;				
			ALU64BW: controls =    15'b010001000000000;
			default: controls =   15'bxxxxxxxxxxxxxxx;
		endcase
    
	assign {FpuW,Src_64b,NextPC, Branch, MemW, RegW, IRWrite, AdrSrc, ResultSrc, ALUSrcA, ALUSrcB, ALUOp} = controls;
endmodule