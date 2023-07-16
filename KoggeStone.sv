module pg_gen(
	input a,b,
	output p,g);
	assign p = a ^ b; // Propagate
	assign g = a & b; // Generate	
endmodule


module dot_prod(
	input g1,g2,p1,p2,
	output g,p);

	assign g = g2 | (g1 & p2);
	assign p = p1 & p2;	
endmodule

module KoggeStone #(parameter OPERAND_SIZE=16) (
	input [OPERAND_SIZE-1:0] A,
	input [OPERAND_SIZE-1:0] B,
	input Cin,
	output logic [OPERAND_SIZE-1:0] Sum,
	output logic Cout);
	
	logic [64:0] p_x,g_x;
	logic [OPERAND_SIZE-1:0] carry;
  	
  	genvar i;
	//Calculating initial Cx:x
	generate
	    for (i = 0; i < OPERAND_SIZE; i = i + 1) begin : stage_0
	        pg_gen instance_pg (
	            .a(A[i]),
	            .b(B[i]),
	            .p(p_x[i]),
	            .g(g_x[i])
	        );
	    end
	endgenerate
	

	//Calculating Stage-1
	generate
		for(i=16;i<31;i=i+1) begin: stage_1
			dot_prod inst1 (
				.g1(g_x[i-16]),
				.g2(g_x[i-15]),
				.p1(p_x[i-16]),
				.p2(p_x[i-15]),
				.g(g_x[i]),
				.p(p_x[i])
			);
		end
	endgenerate


	//Calculating Stage-2
	dot_prod inst2 (
		.g1(g_x[0]),
		.g2(g_x[17]),
		.p1(p_x[0]),
		.p2(p_x[17]),
		.g(g_x[31]),
		.p(p_x[31])
	);
	generate
		for(i=32;i<45;i=i+1) begin: stage_2
			dot_prod inst3 (
				.g1(g_x[i-16]),
				.g2(g_x[i-14]),
				.p1(p_x[i-16]),
				.p2(p_x[i-14]),
				.g(g_x[i]),
				.p(p_x[i])
			);
		end
	endgenerate

	//Calculating Stage-3
	dot_prod inst4 (
		.g1(g_x[0]),
		.g2(g_x[33]),
		.p1(p_x[0]),
		.p2(p_x[33]),
		.g(g_x[45]),
		.p(p_x[45])
	);
	dot_prod inst5 (
			.g1(g_x[16]),
			.g2(g_x[34]),
			.p1(p_x[16]),
			.p2(p_x[34]),
			.g(g_x[46]),
			.p(p_x[46])
		);
	generate
		for(i=47;i<57;i=i+1) begin: stage_3
			dot_prod inst6 (
				.g1(g_x[i-16]),
				.g2(g_x[i-12]),
				.p1(p_x[i-16]),
				.p2(p_x[i-12]),
				.g(g_x[i]),
				.p(p_x[i])
			);
		end
	endgenerate


	//Calculating Stage-4
	dot_prod inst7 (
			.g1(g_x[0]),
			.g2(g_x[49]),
			.p1(p_x[0]),
			.p2(p_x[49]),
			.g(g_x[57]),
			.p(p_x[57])
		);
	dot_prod inst8 (
			.g1(g_x[16]),
			.g2(g_x[50]),
			.p1(p_x[16]),
			.p2(p_x[50]),
			.g(g_x[58]),
			.p(p_x[58])
		);
	dot_prod inst9 (
			.g1(g_x[31]),
			.g2(g_x[51]),
			.p1(p_x[31]),
			.p2(p_x[51]),
			.g(g_x[59]),
			.p(p_x[59])
		);
	dot_prod inst10 (
			.g1(g_x[32]),
			.g2(g_x[52]),
			.p1(p_x[32]),
			.p2(p_x[52]),
			.g(g_x[60]),
			.p(p_x[60])
		);

	generate
      for(i=61;i<65;i=i+1) begin: stage_4
		dot_prod inst6 (
			.g1(g_x[i-16]),
			.g2(g_x[i-8]),
			.p1(p_x[i-16]),
			.p2(p_x[i-8]),
			.g(g_x[i]),
			.p(p_x[i])
		);
	end
	endgenerate
  int c_index [0:15] = '{0,16,31,32,45,46,47,48,57,58,59,60,61,62,63,64};
  
  always_comb begin
    for (int i=0; i < OPERAND_SIZE; i++) begin
      carry[i] =  g_x[c_index[i]] | (p_x[c_index[i]] & Cin);
      Sum[i] = (i==0)? (A[i]^B[i]) ^ Cin : (A[i]^B[i]) ^ carry[i-1];
    end
  end

  assign Cout = carry[15];

endmodule
