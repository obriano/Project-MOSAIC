module p6(x0, x1, x2, x3, x4, y0, y1, y2, y3, y4);
	input [63:0] x0, x1, x2, x3, x4;
	output [63:0] y0, y1, y2, y3, y4;

	wire [63:0] B2, b0, b1, b2, b3, b4, c0, c1, c2, c3, c4;
	add_constants u0(x2, 4'd0, 4'd6,B2);	
	sbox u1(x0, x1, B2, x3, x4, b0, b1, b2, b3, b4);
	linear u2(b0, b1, b2, b3, b4, c0, c1, c2, c3, c4);

	wire [63:0] C2,e0, e1, e2, e3, e4, d0, d1, d2, d3, d4;
	add_constants u3(c2, 4'd1, 4'd6,C2);	
	sbox u4(c0, c1, C2, c3, c4, d0, d1, d2, d3, d4);
	linear u5(d0, d1, d2, d3, d4, e0, e1, e2, e3, e4);
 
	wire [63:0] E2,f0, f1, f2, F2, f3, f4, g0, g1, g2, g3, g4;
	add_constants u6(e2, 4'd2, 4'd6,E2);	
	sbox u7(e0, e1, E2, e3, e4, f0, f1, f2, f3, f4);
	linear u8(f0, f1, f2, f3, f4, g0, g1, g2, g3, g4);
   
	wire [63:0] G2, h0, h1, h2, h3, h4, i0, i1, i2, i3, i4;
	add_constants u9(g2, 4'd3, 4'd6,G2);	
	sbox ua(g0, g1, G2, g3, g4, h0, h1, h2, h3, h4);
	linear ub(h0, h1, h2, h3, h4, i0, i1, i2, i3, i4);

	wire [63:0] I2, j0, j1, j2, j3, j4, k0, k1, k2, k3, k4;
	add_constants uc(i2, 4'd4, 4'd6,I2);	
	sbox ud(i0, i1, I2, i3, i4, j0, j1, j2, j3, j4);
	linear ue(j0, j1, j2, j3, j4, k0, k1, k2, k3, k4);
	
	wire [63:0] K2, l0, l1, l2, l3, l4;
	add_constants uf(k2, 4'd5, 4'd6,K2);	
	sbox ug(k0, k1, K2, k3, k4, l0, l1, l2, l3, l4);
	linear uh(l0, l1, l2, l3, l4, y0, y1, y2, y3, y4);

endmodule

