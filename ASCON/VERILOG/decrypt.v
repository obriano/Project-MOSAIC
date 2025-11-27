module decrypt(x0, x1, x2, x3, x4, y0, y1, y2, y3, y4, pln0, pln1, cyp0, cyp1);
	input [63:0] x0, x1, x2, x3, x4, cyp0, cyp1;
	output [63:0] y0, y1, y2, y3, y4, pln0, pln1;

	assign pln0 = cyp0^x0;

	wire [63:0]  b0, b1, b2, b3, b4, c0, d0;
	p6 u1(x0, x1, x2, x3, x4, b0, y1, y2, y3, y4); 	
	assign pln1 = cyp1^b0;
	assign y0 = cyp1;

	endmodule

