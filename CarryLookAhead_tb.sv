module tb_CarryLookAhead;

    parameter OPERAND_SIZE = 16;
    reg [OPERAND_SIZE-1:0] A;
    reg [OPERAND_SIZE-1:0] B;
    reg Cin;
    wire [OPERAND_SIZE-1:0] Sum;
    wire Cout;

    initial begin
        $dumpfile("tb_CarryLookAhead.vcd");
        $dumpvars(0, tb_CarryLookAhead);
    end

    initial begin
      for (int i = 0; i < 100; i++) begin
            // Randomizing inputs manually
            A = $random;
            B = $random;
            Cin = $random & 1;  // to get a single bit
            #10;
        end
        $finish;
    end

    CarryLookAhead #(OPERAND_SIZE) UUT (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

endmodule

