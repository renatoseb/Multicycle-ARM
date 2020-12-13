//TO DO:
//1. Extraiga bits de exponente y fracción.
//2. Anteponga el 1 inicial para formar la mantisa.
//3. Compara exponentes.
//4. Cambie la mantisa más pequeña si es necesario.
//5. Add mantisas.
//6. Normalice la mantisa y ajuste el exponente si es necesario.
//7. Resultado de la ronda.
//8. Reúna el exponente y la fracción de nuevo en un número de punto flotante.

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


module fpu_half_adder (R1, R2, result);
    input [15:0] R1, R2;
    output [15:0] result;

    //extract the exponent (5-bits) of 2 input
    wire [15:0] exponente1, exponente2;

    assign exponente1 = {11'b0, R1[4:0]}; assign exponente2 = {11'b0, R2[4:0]};

    //extract the mantissa (10-bits) of 2 input and add 1 in the mantissa
    wire [15:0] mantisa1;
    wire [15:0] mantisa2;

    assign mantisa1 = {5'b0, 1'b1, R1[9:0]}; assign mantisa2 = {5'b0, 1'b1, R2[9:0]};

    //compare exponent
    wire [15:0] diferencia;
    assign diferencia = exponente1 - exponente2;

    //save the higher exponent in exponent result
    wire [15:0] exponenteResult;
    assign exponenteResult = (diferencia > 0) ? exponente1 : exponente2;

    wire [15:0] mantisaMenor, mantisaMayor;

    //assign mantissas depende of the result of dif
    assign {mantisaMenor, mantisaMayor} = (diferencia > 0) ? {mantisa2, mantisa1} : {mantisa1, mantisa2};

    //shifting the result of dif in the min mantissa 
    wire [15:0] mantisaWithShift = mantisaMenor >> diferencia;

    //add both mantissas
    wire [15:0] sum;
    assign sum = mantisaMayor + mantisaWithShift;

    //normalize the mantissa
    wire [15:0] sum2;
    assign sum2 = (sum[15:11] != 0) ? sum >> 1 : sum;

    //adjust the exponent
    wire [15:0] exponenteWithshift;
    assign exponenteWithshift = sum[15:11] != 0 ? exponenteResult + 1 : exponenteResult;

    //concatenate the sign bit, exponent and mantissa
    assign result = {1'b0, exponenteWithshift[4:0], sum2[9:0]};

endmodule



//floating point in addition

module fpu(R1, R2, single, Result);
    input [31:0] R1, R2;
    input single;
    output wire [31:0] Result;

    wire [31:0] single_result;
    wire [15:0] half_result;

    fpu_single_adder float_single_add(
        .R1(R1),
        .R2(R2),
        .result(single_result)
    );

    fpu_half_adder float_half_add(
        .R1(R1[15:0]),
        .R2(R2[15:0]),
        .result(half_result)
    );

    assign Result = single ? single_result : {16'h0000, half_result} ;

endmodule