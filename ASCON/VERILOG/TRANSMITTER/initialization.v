module initialization(IV, k0, k1, n0, n1, y0, y1, y2, y3, y4, key0, key1);
	input [63:0] IV, k0, k1, n0, n1, key0, key1;
	output [63:0] y0, y1, y2, y3, y4;
	
	wire [63:0] t0, t1, t2, t3, t4;

	p12 u1(IV, k0, k1, n0, n1, y0, y1, y2, t3, t4);
	assign y3 = t3^key0;
	assign y4 = t4^key1;
endmodule

