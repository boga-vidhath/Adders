module full_adder(
	input A,B,Cin,
	output Sum,Cout
);

assign Sum = A ^ B ^ Cin;
assign Cout = (A&B) | (Cin & (A ^ B)); 
endmodule

module Mux21 #(parameter OPERAND_SIZE=1)(
	input [OPERAND_SIZE-1:0] A,B,
	input Sel,
	output [OPERAND_SIZE-1:0] Out);

assign Out = (Sel==0)?A:B;
endmodule

module CarrySelectAdderBlock #(parameter OPERAND_SIZE=8)(
	input [OPERAND_SIZE-1:0] A,B,
	input Cin,
	output Cout,
	output [OPERAND_SIZE-1:0] Sout);

wire [OPERAND_SIZE-1:0] carry1; 
wire [OPERAND_SIZE-1:0] sum_int1;
wire [OPERAND_SIZE-1:0] carry0;
wire [OPERAND_SIZE-1:0] sum_int0;
genvar i;
generate 
for(i=0;i<OPERAND_SIZE;i++) begin
	full_adder inst1(
		.A(A[i]),
		.B(B[i]),
		.Cin(i==0?1'b1:carry1[i-1]),
		.Sum(sum_int1[i]),
		.Cout(carry1[i]));
	full_adder inst0(
			.A(A[i]),
			.B(B[i]),
			.Cin(i==0?1'b0:carry0[i-1]),
			.Sum(sum_int0[i]),
			.Cout(carry0[i]));
	Mux21 inst(
		.A(sum_int0[i]),
		.B(sum_int1[i]),
		.Sel(Cin),
		.Out(Sout[i]));
end
endgenerate
Mux21 coutMux(
	.A(carry0[OPERAND_SIZE-1]),
	.B(carry1[OPERAND_SIZE-1]),
	.Sel(Cin),
	.Out(Cout));
endmodule

module CarrySelectModule #(parameter OPERAND_SIZE=16, BLOCK_SIZE=4) (
	input [OPERAND_SIZE-1:0] A, B,
	input Cin,
	output [OPERAND_SIZE-1:0] Sout,
	output Cout);

parameter num_blocks = OPERAND_SIZE/BLOCK_SIZE;
wire [num_blocks-1:0] carry;
genvar i;
generate
for(i=0;i<num_blocks;i++)
begin
	CarrySelectAdderBlock #(.OPERAND_SIZE(BLOCK_SIZE)) block_inst(
		.A(A[i*BLOCK_SIZE +: BLOCK_SIZE]),
		.B(B[i*BLOCK_SIZE +: BLOCK_SIZE]),
		.Cin(i==0?Cin:carry[i-1]),
		.Sout(Sout[i*BLOCK_SIZE +: BLOCK_SIZE]),
		.Cout(carry[i]));
end
endgenerate
assign Cout = carry[num_blocks-1];
endmodule

