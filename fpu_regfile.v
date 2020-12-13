module fpu_regfile (
    clk,
    we3,
    ra1,
    ra2,
    wa3,
    A1,
    A2,
    A3,
    single,
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

    input wire single; //Instr[8]

    input wire [31:0] wd3;

    output wire [31:0] rd1;
    output wire [31:0] rd2;

    reg [31:0] rf [15:0];

    always @(posedge clk)
        if (we3)
            if(single == 1) // single
                rf[wa3] <= wd3;
            else // half
                if(A3 == 1)
                    rf[wa3][31:16] <= wd3[16:0];
                else
                    rf[wa3][15:0] <= wd3[16:0];

    wire [15:0] rd1f = A1 == 1 ? rf[ra1][31:16] : rf[ra1][15:0];
    wire [15:0] rd2f = A2 == 1 ? rf[ra2][31:16] : rf[ra2][15:0];

    assign rd1 = single == 1 ? rf[ra1] : {16'b0, rd1f};
    assign rd2 = single == 1 ? rf[ra2] : {16'b0, rd2f};
endmodule