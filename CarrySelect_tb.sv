// Code your testbench here
// or browse Examples
module tb_CarrySelectModule;

    parameter OPERAND_SIZE = 16;
    parameter BLOCK_SIZE = 4;
    reg [OPERAND_SIZE-1:0] A;
    reg [OPERAND_SIZE-1:0] B;
    reg Cin;
    wire [OPERAND_SIZE-1:0] Sout;
    wire Cout;

    CarrySelectModule #(OPERAND_SIZE, BLOCK_SIZE) UUT (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sout(Sout),
        .Cout(Cout)
    );

    initial begin
        $dumpfile("tb_CarrySelectModule.vcd");
        $dumpvars(0, tb_CarrySelectModule);
    end

    initial begin
        for (int i = 0; i < 100; i++) begin
            // Randomizing inputs manually
            A = $random;
            B = $random;
            Cin = $random & 1;  // to get a single bit
            #10;
        end
        // Display the final values
        #10;
        $display("A: %h, B: %h, Cin: %b, Sout: %h, Cout: %b", A, B, Cin, Sout, Cout);
        $finish;
    end

endmodule

