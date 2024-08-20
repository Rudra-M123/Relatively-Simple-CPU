module alu(input [7:0] bus_in, input [7:0] AC_in, input [7:1] ALUSEL, output [7:0] ALU_out);
    wire [7:0] mux1, mux2, mux3, arith_result;
    assign mux1 = (ALUSEL[1])? AC_in : 8'h00;
    assign mux2 = (ALUSEL[2] == 1'b1)? ~bus_in : (ALUSEL[3] == 1'b1)? bus_in : 8'h00;
    assign mux3 = (ALUSEL[6:5] == 2'b00)? AC_in & bus_in : (ALUSEL[6:5] == 2'b10) ? AC_in | bus_in : (ALUSEL[6:5] == 2'b01) ? AC_in ^ bus_in : ~AC_in;

    parallel_adder pa(.a(mux1), .b(mux2), .cin(ALUSEL[4]), .sum(arith_result));
    assign ALU_out = (ALUSEL[7])? (mux3) : arith_result;
endmodule

module parallel_adder(input [7:0] a, input [7:0] b, input cin, output [7:0] sum);
    wire c1, c2, c3, c4, c5, c6, c7;
    full_adder fa0(.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .cout(c1));
    full_adder fa1(.a(a[1]), .b(b[1]), .cin(c1), .sum(sum[1]), .cout(c2));
    full_adder fa2(.a(a[2]), .b(b[2]), .cin(c2), .sum(sum[2]), .cout(c3));
    full_adder fa3(.a(a[3]), .b(b[3]), .cin(c3), .sum(sum[3]), .cout(c4));
    full_adder fa4(.a(a[4]), .b(b[4]), .cin(c4), .sum(sum[4]), .cout(c5));
    full_adder fa5(.a(a[5]), .b(b[5]), .cin(c5), .sum(sum[5]), .cout(c6));
    full_adder fa6(.a(a[6]), .b(b[6]), .cin(c6), .sum(sum[6]), .cout(c7));
    full_adder fa7(.a(a[7]), .b(b[7]), .cin(c7), .sum(sum[7]));
endmodule

module full_adder(input a, input b, input cin, output sum, output cout);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | ((a ^ b) & cin);
endmodule