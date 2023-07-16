module pg_gen(
	input a,b,
	output p,g);
	assign p = a ^ b; // Propagate
	assign g = a & b; // Generate	
endmodule

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

module CarrySkipAdderBlock #(parameter OPERAND_SIZE=8)(
	input [OPERAND_SIZE-1:0] A,B,
	input Cin,
	output Cout,
	output [OPERAND_SIZE-1:0] Sout);

wire [OPERAND_SIZE-1:0] p_x; 
wire [OPERAND_SIZE-1:0] g_x;
wire [OPERAND_SIZE-1:0] Carry;
genvar i;
generate 
for(i=0;i<OPERAND_SIZE;i++) begin
	pg_gen inst(
		.a(A[i]),
		.b(B[i]),
		.p(p_x[i]),
		.g(g_x[i]));

	full_adder inst_add(
		.A(A[i]),
		.B(B[i]),
		.Cin(i==0?Cin:Carry[i-1]),
		.Sum(Sum[i]),
		.Cout(Carry[i]));
end
endgenerate
wire group_prop = &p_x;
Mux21 coutMux(
	.A(Carry[OPERAND_SIZE-1]),
	.B(Cin),
	.Sel(group_prop),
	.Out(Cout));
endmodule

module CarrySkipModule #(parameter OPERAND_SIZE=16, BLOCK_SIZE=4) (
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
	CarrySkipAdderBlock #(.OPERAND_SIZE(BLOCK_SIZE)) block_inst(
		.A(A[i*BLOCK_SIZE +: BLOCK_SIZE]),
		.B(B[i*BLOCK_SIZE +: BLOCK_SIZE]),
		.Cin(i==0?Cin:carry[i-1]),
		.Sout(Sout[i*BLOCK_SIZE +: BLOCK_SIZE]),
		.Cout(carry[i]));
end
endgenerate
assign Cout = carry[num_blocks-1];
endmodule

