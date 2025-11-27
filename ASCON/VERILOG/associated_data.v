module associated_data(x0, x1, x2, x3, x4,  y0, y1, y2, y3, y4, d0, d1, d2);
	input [63:0] x0, x1, x2, x3, x4,  d0, d1, d2;
	output [63:0] y0, y1, y2, y3, y4 ;

	wire [63:0] a0, a1, a2, a3, a4, b0, b1, b2, b3, b4;
	assign a0 = d0^x0;
	p6 u1(a0, x1, x2, x3, x4, b0, b1, b2, b3, b4); 	

	wire [63:0] B0, c0, c1, c2, c3, c4;
	assign B0 = d1^b0;
	p6 u2(B0, b1, b2, b3, b4, c0, c1, c2, c3, c4); 	
	 
	wire [63:0] C0;
	assign C0 = d2^c0;
	p6 u3(C0, c1, c2, c3, c4, y0, y1, y2, y3, y4); 	
endmodule

