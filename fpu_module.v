module fpu_single_adder (R1, R2, result);
    input [31:0] R1, R2;
    output [31:0] result;

    //extract the exponent (8-bits) of 2 input
    wire [31:0] exponente1, exponente2;

    assign exponente1 = {24'b0, R1[30:23]}; assign exponente2 = {24'b0, R2[30:23]};

    //extract the mantissa (23-bits) of 2 input and add 1 in the mantissa
    wire [31:0] mantisa1;
    wire [31:0] mantisa2;

    assign mantisa1 = {8'b0, 1'b1, R1[22:0]}; assign mantisa2 = {8'b0, 1'b1, R2[22:0]};

    //compare exponent
    wire [31:0] diferencia;
    assign diferencia = exponente1 - exponente2;

    //save the higher exponent in exponent result
    wire [31:0] exponenteResult;
    assign exponenteResult = (diferencia > 0) ? exponente1 : exponente2;

    wire [31:0] mantisaMenor, mantisaMayor;

    //assign mantissas depende of the result of dif
    assign {mantisaMenor, mantisaMayor} = (diferencia > 0) ? {mantisa2, mantisa1} : {mantisa1, mantisa2};

    //shifting the result of dif in the min mantissa 
    wire [31:0] mantisaWithShift = mantisaMenor >> diferencia;

    //add both mantissas
    wire [31:0] sum;
    assign sum = mantisaMayor + mantisaWithShift;

    //normalize the mantissa
    wire [31:0] sum2;
    assign sum2 = (sum[31:24] != 0) ? sum >> 1 : sum;

    //adjust the exponent
    wire [31:0] exponenteWithshift;
    assign exponenteWithshift = sum[31:24] != 0 ? exponenteResult + 1 : exponenteResult;

    //concatenate the sign bit, exponent and mantissa
    assign result = {1'b0, exponenteWithshift[7:0], sum2[22:0]};

endmodule


module fpu(a, b, double, Result);
    input [63:0] a, b;
    input double;

    output [63:0] Result;

    wire [31:0] f_result;
    wire [63:0] d_result;

    fpu_single_adder float_a(
        .R1(a[31:0]),
        .R2(b[31:0]),
        .result(f_result)
    );

    double_adder double_a(
        .srcA(a),
        .srcB(b),
        .result(d_result)
    );

    assign Result = double ? d_result : {32'h0000, f_result} ;

endmodule
