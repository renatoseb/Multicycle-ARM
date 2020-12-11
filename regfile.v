//Reutilizado del single-cycle

module regfile (
	clk,
	we3,
	ra1,
	ra2,
	wa3_32,
	wa3_64,
	wd3_32,
	wd3_64,
	r15,
	rd1,
	rd2,
	Src_64b
);
	input wire clk;
	input wire we3;
	input wire Src_64b;
	input wire [3:0] ra1;
	input wire [3:0] ra2;
	input wire [3:0] wa3_32;
	input wire [3:0] wa3_64;
	input wire [31:0] wd3_32;
	input wire [31:0] wd3_64;
	input wire [31:0] r15;
	output wire [31:0] rd1;
	output wire [31:0] rd2;
	
	reg [31:0] rf [14:0];
	always @(posedge clk)
		if (we3)
			begin
				if(Src_64b) begin
					rf[wa_64] <= wd3_64;
				end
				else begin
					rf[wa3_32] <= wd3_32;	
				end
			end
	assign rd1 = (ra1 == 4'b1111 ? r15 : rf[ra1]);
	assign rd2 = (ra2 == 4'b1111 ? r15 : rf[ra2]);
endmodule