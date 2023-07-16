module pg_gen(
	input a,b,
	output p,g);
	assign p = a ^ b; // Propagate
	assign g = a & b; // Generate	
endmodule

module CarryLookAhead #(parameter OPERAND_SIZE=16) (
	input [OPERAND_SIZE-1:0] A,
	input [OPERAND_SIZE-1:0] B,
	input Cin,
	output logic [OPERAND_SIZE-1:0] Sum,
	output logic Cout);
	
	logic [OPERAND_SIZE-1:0] p_x,g_x,p_out,g_out;
	logic [OPERAND_SIZE-1:0] inter_p, inter_g;
	logic [OPERAND_SIZE-1:0] carry;
	
	// Propagate and Generate
	genvar i;
	generate
	    for (i = 0; i < OPERAND_SIZE; i = i + 1) begin : gen_pg
	        pg_gen instance_pg (
	            .a(A[i]),
	            .b(B[i]),
	            .p(p_x[i]),
	            .g(g_x[i])
	        );
	    end
	endgenerate

	always_comb
	begin
	// Generate and Propagate Ranges:
	integer j;
	inter_p[0] = p_x[0];
	for (j=1;j<OPERAND_SIZE;j++) begin
		inter_p[j] = inter_p[j-1] & p_x[j];
	end
	
	inter_g[0] = g_x[0];
	for (j=1;j<OPERAND_SIZE;j++) begin
		inter_g[j] = g_x[j] | (inter_g[j-1]&p_x[j]);
	end
	
	carry[0] = Cin;
	for (j=0;j<OPERAND_SIZE;j++) begin
      carry[j] = (j==0)? Cin : inter_g[j-1] | (inter_p[j-1] & carry[0]);
		Sum[j] = p_x[j] ^ carry[j];
	end	
	end
  assign Cout = inter_g[OPERAND_SIZE-1] | (inter_p[OPERAND_SIZE-1] & carry[0]);

endmodule

