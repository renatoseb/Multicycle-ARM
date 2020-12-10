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
	64bFlag,
	64bSrc
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire 64bFlag;
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
	output wire 64bSrc;
	reg [3:0] state;
	reg [3:0] nextstate;
	reg [12:0] controls;
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
	localparam [3:0] ALU64BW = 11;

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
					default: nextstate = UNKNOWN;
				endcase
//DOING   
			EXECUTER:
				begin
					if(64bFlag == 1) begin
						nextstate = ALU64BW;
					end
					else begin
						nextstate = ALUWB;
					end
				end
            EXECUTEI:
				begin
					if(64bFlag == 1) begin
						nextstate = ALU64BW;
					end
					else begin
						nextstate = ALUWB;
					end
				end 
            MEMADR:
                if (Funct[0]) 
                    nextstate = MEMRD;
                else 
                    nextstate = MEMWR;
            MEMRD: nextstate = MEMWB;
            default: nextstate = FETCH;
		endcase

	// ADD CODE BELOW
	// Finish entering the output logic below.  We've entered the
	// output logic for the first two states, FETCH and DECODE, for you.

	// state-dependent output logic
	always @(*)
		case (state)
			FETCH: controls =     14'b01000101001100;                          //10001_0100_1100
			DECODE: controls =    14'b00000001001100;                         //00000_0100_1100
			EXECUTER: controls =  14'b00000000000001;                       //00000_0000_0001
			EXECUTEI: controls =  14'b00000000000011;                       //00000_0000_0011
			ALUWB: controls =     14'b00001000000000;                          //00010_0000_0000
			MEMADR: controls =    14'b00000000000010;                         //00000_0000_0010
			MEMWR: controls =     14'b00010010000000;                          //00100_1000_0000
			MEMRD: controls =     14'b00000010000000;                          //00000_1000_0000
			MEMWB: controls =     14'b00001000100000;                          //00010_0010_0000
			BRANCH: controls =    14'b00100001000010;                         //01000_0100_0010
			ALU64BW: control =    14'b10001000000000;
			default: controls = 13'bxxxxxxxxxxxxx;
		endcase
    
	assign {64bSrc,NextPC, Branch, MemW, RegW, IRWrite, AdrSrc, ResultSrc, ALUSrcA, ALUSrcB, ALUOp} = controls;
endmodule