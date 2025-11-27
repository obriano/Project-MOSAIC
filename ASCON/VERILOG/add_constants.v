module add_constants(state2, i, a, out);
	input [63:0]state2;
	output [63:0]out;
	input [3:0]a, i;
	wire [3:0] I;
	wire [63:0] const;
	assign I = 12 -a+i;
	constants u1(I, const);
	assign out = state2^const;
endmodule

