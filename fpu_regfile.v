module fpu_regfile (
    clk,
    we3,
    ra1,
    ra2,
    wa3,
    A1,
    A2,
    A3,
    sod,
    wd3,
    rd1,
    rd2
);
    input wire clk;
    input wire we3;

    input wire [3:0] ra1;
    input wire [3:0] ra2;
    input wire [3:0] wa3;

    input wire A1;
    input wire A2;
    input wire A3;

    input wire sod; // 0 = single 1 = double Instr[8]

    input wire [63:0] wd3;

    output wire [63:0] rd1;
    output wire [63:0] rd2;

    reg [63:0] rf [15:0];

    always @(posedge clk)
        if (we3)
            if(sod == 1) // Double
                rf[wa3] <= wd3;
            else // Single
                if(A3 == 1)
                    rf[wa3][63:32] <= wd3[31:0];
                else
                    rf[wa3][31:0] <= wd3[31:0];

    wire [31:0] rd1f = A1 == 1 ? rf[ra1][63:32] : rf[ra1][31:0];
    wire [31:0] rd2f = A2 == 1 ? rf[ra2][63:32] : rf[ra2][31:0];

    assign rd1 = sod == 1 ? rf[ra1] : {32'b0, rd1f};
    assign rd2 = sod == 1 ? rf[ra2] : {32'b0, rd2f};
endmodule
