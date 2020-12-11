module controller (
	clk,
	reset,
	Instr,
	ALUFlags,
	PCWrite,
	MemWrite,
	RegWrite,
	IRWrite,
	AdrSrc,
	RegSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	ImmSrc,
	ALUControl,
	RegSrc64b,
	Src_64b,
	FPUWrite
);
	input wire clk;
	input wire reset;
	input wire [31:12] Instr;
	input wire [3:0] ALUFlags;
	output wire PCWrite;
	output wire MemWrite;
	output wire RegWrite;
	output wire IRWrite;
	output wire FPUWrite;

	output wire AdrSrc;
	output wire [1:0] RegSrc;
	output wire [1:0] ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ResultSrc;
	output wire [1:0] ImmSrc;
	output wire [2:0] ALUControl;
	output wire RegSrc64b;
	output wire Src_64b;
	wire [1:0] FlagW;
	wire PCS;
	wire NextPC;
	wire RegW;
	wire MemW;
	wire FpuW;



	decode decoder_module(
		.clk(clk),
		.reset(reset),
		.Op(Instr[27:26]),
		.Funct(Instr[25:20]),
		.Rd(Instr[15:12]),
		.FlagW(FlagW),
		.PCS(PCS),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ResultSrc(ResultSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ImmSrc(ImmSrc),
		.RegSrc(RegSrc),
		.ALUControl(ALUControl),
		.multiByte(Instr[7:4]),
		.RegSrc64b(RegSrc64b),
		.Src_64b(Src_64b),
		.FpuW(FpuW)
	);
	condlogic condlogic_module(
		.clk(clk),
		.reset(reset),
		.Cond(Instr[31:28]),
		.ALUFlags(ALUFlags),
		.FlagW(FlagW),
		.PCS(PCS),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.PCWrite(PCWrite),
		.RegWrite(RegWrite),
		.MemWrite(MemWrite)
	);
endmodule

module decode (
	clk,
	reset,
	Op,
	Funct,
	Rd,
	FlagW,
	PCS,
	NextPC,
	RegW,
	MemW,
	IRWrite,
	AdrSrc,
	ResultSrc,
	ALUSrcA,
	ALUSrcB,
	ImmSrc,
	RegSrc,
	ALUControl,
	multiByte,
	RegSrc64b,
	Src_64b,
	FpuW
);
	input wire clk;
	input wire reset;
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	input wire [3:0] multiByte;
	output reg [1:0] FlagW;
	output wire PCS;
	output wire NextPC;
	output wire RegW;
	output wire MemW;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] ResultSrc;
	output wire [1:0] ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ImmSrc;
	output wire [1:0] RegSrc;
	output wire RegSrc64b;
	output wire Src_64b;
	output wire FpuW;

	output reg [2:0] ALUControl;

	wire Branch;
	wire ALUOp;
	reg Flag_64b;


	// To do
	// Main FSM
	mainfsm fsm(
		.clk(clk),
		.reset(reset),
		.Op(Op),
		.Funct(Funct),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ResultSrc(ResultSrc),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.Branch(Branch),
		.ALUOp(ALUOp),
		.Flag_64b(Flag_64b),
		.Src_64b(Src_64b),
		.FpuW(FpuW)
	);

	
	// ALU Decoder
    always @(*)
        if (ALUOp) 
			begin // which Data-processing Instr?
				Flag_64b = 0;
				if(multiByte == 4'b1001) begin
					case(Funct[3:1]) // Check cmd
						3'b000: ALUControl = 3'b100; // MUL
						3'b100: begin
							Flag_64b = 1;
							ALUControl = 3'b101; // UMULL
						end
						3'b110: begin
							Flag_64b = 1;
							ALUControl = 3'b110; // SMULL
						end
						default: ALUControl = 3'bX;  // No implemented
					endcase
				end
				case(Funct[4:1])
					4'b0100: ALUControl = 3'b000; // ADD
					4'b0010: ALUControl = 3'b001; // SUB
					4'b0000: ALUControl = 3'b010; // AND
					4'b1100: ALUControl = 3'b011; // ORR
					default: ALUControl = 3'bxxx; // unimplemented
				endcase
				FlagW[1] = Funct[0];    // update N & Z flags if S bit is set
				FlagW[0] = Funct[0] & (ALUControl == 2'b00 | ALUControl == 2'b01);
			end 
        else 
			begin
				ALUControl = 2'b00; // add for non data-processing instructions
				FlagW = 2'b00;      // don't update Flags
			end

	// PC Logic
    assign PCS = ((Rd == 4'b1111) & RegW) | Branch; 

	// Instr Decoder
    // Add code for the Instruction Decoder (Instr Decoder) below.
	// Recall that the input to Instr Decoder is Op, and the outputs are
	// ImmSrc and RegSrc. We've completed the ImmSrc logic for you.
	
    assign ImmSrc = Op;

    //DOING
	assign RegSrc64b = (multiByte == 4'b1001) && (Funct[3:1] == 3'b101 || Funct[3:1] == 3'b110); 
    assign RegSrc[0] = (Op == 2'b10); // read PC on Branch
    assign RegSrc[1] = (Op == 2'b01); // read Rd on STR 

endmodule

// ADD CODE BELOW
// Add code for the condlogic and condcheck modules. Remember, you may
// reuse code from prior labs.
module condlogic (
	clk,
	reset,
	Cond,
	ALUFlags,
	FlagW,
	PCS,
	NextPC,
	RegW,
	MemW,
	PCWrite,
	RegWrite,
	MemWrite,
	FPUWrite
);
	input wire clk;
	input wire reset;
	input wire [3:0] Cond;
	input wire [3:0] ALUFlags;
	input wire [1:0] FlagW;
	input wire PCS;
	input wire NextPC;
	input wire RegW;
	input wire MemW;
	input wire FpuW;

	output wire PCWrite;
	output wire RegWrite;
	output wire MemWrite;
	output wire FPUWrite;

	wire [1:0] FlagWrite;
	wire [3:0] Flags;
	wire CondEx;
	wire CondexOut;
    condcheck cc(
        .Cond(Cond),
        .Flags(Flags),
        .CondEx(CondEx)
    );
	flopr #(1) condexdelay(
        .clk(clk),
        .reset(reset),
        .d(CondEx),
        .q(CondexOut)
    );
	flopenr #(2) ALUFlags1(
        .clk(clk),
        .reset(reset),
        .en(FlagWrite[1]),
        .d(ALUFlags[3:2]),
        .q(Flags[3:2])
    );
	flopenr #(2) ALUFlags0(
        .clk(clk),
        .reset(reset),
        .en(FlagWrite[0]),
        .d(ALUFlags[1:0]),
        .q(Flags[1:0])
    );

    
    assign FlagWrite = FlagW & {2 {CondEx}};
	assign RegWrite = RegW & CondexOut;
	assign MemWrite = MemW & CondexOut;
	assign FpuWrite = FpuW & CondexOut;
	assign PCWrite = (PCS & CondexOut) | NextPC;

endmodule

module condcheck (
	Cond,
	Flags,
	CondEx
);
	input wire [3:0] Cond;
	input wire [3:0] Flags;
	output reg CondEx;

	// ADD CODE HERE
    //Reutilizado del LAB06

    wire neg;
	wire zero;
	wire carry;
	wire overflow;
	wire ge;
	assign {neg, zero, carry, overflow} = Flags;
	assign ge = neg == overflow;
	always @(*)
		case (Cond)
			4'b0000: CondEx = zero;
			4'b0001: CondEx = ~zero;
			4'b0010: CondEx = carry;
			4'b0011: CondEx = ~carry;
			4'b0100: CondEx = neg;
			4'b0101: CondEx = ~neg;
			4'b0110: CondEx = overflow;
			4'b0111: CondEx = ~overflow;
			4'b1000: CondEx = carry & ~zero;
			4'b1001: CondEx = ~(carry & ~zero);
			4'b1010: CondEx = ge;
			4'b1011: CondEx = ~ge;
			4'b1100: CondEx = ~zero & ge;
			4'b1101: CondEx = ~(~zero & ge);
			4'b1110: CondEx = 1'b1;
			default: CondEx = 1'bx;
		endcase
endmodule