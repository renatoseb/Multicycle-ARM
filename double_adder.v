// vim: set expandtab:
module double_adder (srcA, srcB, result);
    input [63:0] srcA;
    input [63:0] srcB;

    output [63:0] result;
    //output [3:0] ALUFlags;

    //wire N, Z, C, V;

    wire [63:0] expA = {56'b0, srcA[62:52]};
    wire [63:0] expB = {56'b0, srcB[62:52]};

    wire [63:0] manA = {11'b0, 1'b1, srcA[51:0]};
    wire [63:0] manB = {11'b0, 1'b1, srcB[51:0]};

    wire [63:0] diff = expA - expB;
    wire [63:0] expR = diff > 0 ? expA : expB;

    wire [63:0] manMin;
    wire [63:0] manMax;

    assign {manMin, manMax} = diff > 0 ? {manB, manA} : {manA, manB};

    wire [63:0] manMinShift = manMin >> diff;

    wire [63:0] sum = manMax + manMinShift;
    wire [63:0] _sum = sum[63:53] != 0 ? sum >> 1 : sum;
    wire [63:0] expRshift = sum[63:53] != 0 ? expR + 1 : expR;

    assign result = {1'b0, expRshift[10:0], _sum[51:0]};

endmodule
