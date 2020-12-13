// vim: set expandtab:

// ADD CODE BELOW
// Complete the datapath module below for Lab 11.
// You do not need to complete this module for Lab 10.
// The datapath unit is a structural SystemVerilog module. That is,
// it is composed of instances of its sub-modules. For example,
// the instruction register is instantiated as a 32-bit flopenr.
// The other submodules are likewise instantiated.
module datapath (
    clk,
    reset,
    Adr,
    WriteData,
    ReadData,
    Instr,
    ALUFlags,
    PCWrite,
    RegWrite,
    IRWrite,
    AdrSrc,
    RegSrc,
    ALUSrcA,
    ALUSrcB,
    ResultSrc,
    ImmSrc,
    ALUControl,
    Src_64b,
    FPUWrite,
    RegSrc64b
);
    input wire clk;
    input wire reset;
    output wire [31:0] Adr;
    output wire [31:0] WriteData;
    input wire [31:0] ReadData;
    output wire [31:0] Instr;
    output wire [3:0] ALUFlags;
    input wire PCWrite;
    input wire RegWrite;
    input wire IRWrite;
    input wire AdrSrc;
    input wire [1:0] RegSrc;
    input wire [1:0] ALUSrcA;
    input wire [1:0] ALUSrcB;
    input wire [1:0] ResultSrc;
    input wire [1:0] ImmSrc;
    input wire [2:0] ALUControl;
    input wire Src_64b;
    input wire FPUWrite;
    input wire RegSrc64b;

    wire [31:0] PCNext;
    wire [31:0] PC;
    wire [31:0] ExtImm;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] Result;
    wire [31:0] Data;
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [31:0] A;
    wire [31:0] ALUResult;
    wire [31:0] ALUResult2;
    wire [31:0] ALUOut;
    wire [31:0] ALUOut2;
    wire [3:0] RA1;
    wire [3:0] RA2;
    wire [63:0] FRD1;
    wire [63:0] FRD2;
    wire [63:0] FA;
    wire [63:0] FWriteData;
    wire [63:0] FResult;
    wire [63:0] FPUResult;


    // Your datapath hardware goes below. Instantiate each of the
    // submodules that you need. Remember that you can reuse hardware
    // from previous labs. Be sure to give your instantiated modules
    // applicable names such as pcreg (PC register), adrmux
    // (Address Mux), etc. so that your code is easier to understand.

    // ADD CODE HERE

    flopenr #(32) pcreg(
        .clk(clk),
        .reset(reset),
        .en(PCWrite),
        .d(PCNext),
        .q(PC)
    );

    mux2 #(32) adrmux(
        .d0(PC),
        .d1(PCNext),
        .s(AdrSrc),
        .y(Adr)
    );

    flopenr #(32) instrreg(
        .clk(clk),
        .reset(reset),
        .en(IRWrite),
        .d(ReadData),
        .q(Instr)
    );

    flopr #(32) datareg(
        .clk(clk),
        .reset(reset),
        .d(ReadData),
        .q(Data)
    );

    wire [3:0] _RA1;
    mux2 #(4) ra1mulmux(
        .d0(Instr[19:16]),
        .d1(Instr[3:0]),
        .s(RegSrc64b),
        .y(_RA1)
    );

    mux2 #(4) ra1mux(
        .d0(_RA1),
        .d1(4'd15),
        .s(RegSrc[0]),
        .y(RA1)
    );

    wire [3:0] _RA2;
    mux2 #(4) ra2mulmux(
        .d0(Instr[3:0]),
        .d1(Instr[11:8]),
        .s(RegSrc64b),
        .y(_RA2)
    );

    mux2 #(4) ra2mux(
        .d0(_RA2),
        .d1(Instr[15:12]),
        .s(RegSrc[1]),
        .y(RA2)
    );

    wire [3:0] A3;
    mux2 #(4) a3mux(
        .d0(Instr[15:12]),
        .d1(Instr[19:16]),
        .s(RegSrc64b),
        .y(A3)
    );


    regfile rf(
        .clk(clk),
        .we3(RegWrite),
        .ra1(RA1),
        .ra2(RA2),
        .wa3_32(A3),
        .wa3_64(Instr[15:12]),
        .wd3_32(Result),
        .wd3_64(ALUOut2),
        .Src_64b(lmulFlag),
        .r15(Result),
        .rd1(RD1),
        .rd2(RD2)
    );

    extend ext(
        .Instr(Instr[23:0]),
        .ImmSrc(ImmSrc),
        .ExtImm(ExtImm)
    );

    flopr #(64) rdreg(
        .clk(clk),
        .reset(reset),
        .d({RD1, RD2}),
        .q({A, WriteData})
    );

    mux2 #(32) srcamux(
        .d0(A),
        .d1(PC),
        .s(ALUSrcA[0]),
        .y(SrcA)
    );

    mux3 #(32) srcbmux(
        .d0(WriteData),
        .d1(ExtImm),
        .d2(32'd4),
        .s(ALUSrcB),
        .y(SrcB)
    );

    alu a(
        .a(SrcA),
        .b(SrcB),
        .ALUControl(ALUControl),
        .Result32(ALUResult),
        .Result64(ALUResult2),
        .ALUFlags(ALUFlags)
    );

    fpu_regfile fpu_regfile(
        .clk(clk),
        .we3(FPUWrite),
        .ra1(Instr[19:16]),
        .ra2(Instr[3:0]),
        .wa3(Instr[15:12]),
        .A1(Instr[7]),
        .A2(Instr[5]),
        .A3(Instr[6]),
        .sod(Instr[8]),
        .wd3(FResult),
        .rd1(FRD1),
        .rd2(FRD2)
    );

    flopr #(128) frdreg(
        .clk(clk),
        .reset(reset),
        .d({FRD1, FRD2}),
        .q({FA, FWriteData})
    );

    fpu f(
        .a(FA),
        .b(FWriteData),
        .double(Instr[8]),
        .Result(FPUResult)
    );

    flopr #(64) fpureg(
        .clk(clk),
        .reset(reset),
        .d(FPUResult),
        .q(FResult)
    );

    flopr #(32) alureg(
        .clk(clk),
        .reset(reset),
        .d(ALUResult),
        .q(ALUOut)
    );

    flopr #(32) alureg2(
        .clk(clk),
        .reset(reset),
        .d(ALUResult2),
        .q(ALUOut2)
    );

    mux3 #(32) resultmux(
        .d0(ALUOut),
        .d1(Data),
        .d2(ALUResult),
        .s(ResultSrc),
        .y(Result)
    );

    assign PCNext = Result;

endmodule


module flopenr (
    clk,
    reset,
    en,
    d,
    q
);
    parameter WIDTH = 8;
    input wire clk;
    input wire reset;
    input wire en;
    input wire [WIDTH - 1:0] d;
    output reg [WIDTH - 1:0] q;
    always @(posedge clk or posedge reset)
        if (reset)
            q <= 0;
        else if (en)
            q <= d;
endmodule

module flopr (
    clk,
    reset,
    d,
    q
);
    parameter WIDTH = 8;
    input wire clk;
    input wire reset;
    input wire [WIDTH - 1:0] d;
    output reg [WIDTH - 1:0] q;
    always @(posedge clk or posedge reset)
        if (reset)
            q <= 0;
        else
            q <= d;
endmodule

module mux2 (
    d0,
    d1,
    s,
    y
);
    parameter WIDTH = 8;
    input wire [WIDTH - 1:0] d0;
    input wire [WIDTH - 1:0] d1;
    input wire s;
    output wire [WIDTH - 1:0] y;
    assign y = (s ? d1 : d0);
endmodule

// ADD CODE BELOW
// Add needed building blocks below (i.e., parameterizable muxes,
// registers, etc.). Remember, you can reuse code from previous labs.
// We've also provided a parameterizable 3:1 mux below for your
// convenience.

module mux3 (
    d0,
    d1,
    d2,
    s,
    y
);
    parameter WIDTH = 8;
    input wire [WIDTH - 1:0] d0;
    input wire [WIDTH - 1:0] d1;
    input wire [WIDTH - 1:0] d2;
    input wire [1:0] s;
    output wire [WIDTH - 1:0] y;
    assign y = (s[1] ? d2 : (s[0] ? d1 : d0));
endmodule

module extend (
    Instr,
    ImmSrc,
    ExtImm
);
    input wire [23:0] Instr;
    input wire [1:0] ImmSrc;
    output reg [31:0] ExtImm;
    always @(*)
        case (ImmSrc)
            2'b00: ExtImm = {24'b000000000000000000000000, Instr[7:0]};
            2'b01: ExtImm = {20'b00000000000000000000, Instr[11:0]};
            2'b10: ExtImm = {{6 {Instr[23]}}, Instr[23:0], 2'b00};
            default: ExtImm = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        endcase
endmodule
