module p12 (x0, x1, x2, x3, x4, y0, y1, y2, y3, y4);
	input [63:0] x0, x1, x2, x3, x4;
	output [63:0] y0, y1, y2, y3, y4;

	wire [63:0] B2, b0, b1, b2, b3, b4, c0, c1, c2, c3, c4;
	add_constants Z0(x2, 4'd0, 4'd12,B2);	
	sbox Z1(x0, x1, B2, x3, x4, b0, b1, b2, b3, b4);
	linear Z2(b0, b1, b2, b3, b4, c0, c1, c2, c3, c4);

	wire [63:0] C2,e0, e1, e2, e3, e4, d0, d1, d2, d3, d4;
	add_constants Z3(c2, 4'd1, 4'd12,C2);	
	sbox Z4(c0, c1, C2, c3, c4, d0, d1, d2, d3, d4);
	linear u5(d0, d1, d2, d3, d4, e0, e1, e2, e3, e4);
 
	wire [63:0] E2,f0, f1, f2, F2, f3, f4, g0, g1, g2, g3, g4;
	add_constants u6(e2, 4'd2, 4'd12,E2);	
	sbox u7(e0, e1, E2, e3, e4, f0, f1, f2, f3, f4);
	linear u8(f0, f1, f2, f3, f4, g0, g1, g2, g3, g4);
   
	wire [63:0] G2, h0, h1, h2, h3, h4, i0, i1, i2, i3, i4;
	add_constants u9(g2, 4'd3, 4'd12,G2);	
	sbox ua(g0, g1, G2, g3, g4, h0, h1, h2, h3, h4);
	linear ub(h0, h1, h2, h3, h4, i0, i1, i2, i3, i4);

	wire [63:0] I2, j0, j1, j2, j3, j4, k0, k1, k2, k3, k4;
	add_constants uc(i2, 4'd4, 4'd12,I2);	
	sbox ud(i0, i1, I2, i3, i4, j0, j1, j2, j3, j4);
	linear ue(j0, j1, j2, j3, j4, k0, k1, k2, k3, k4);
	
	wire [63:0] K2, l0, l1, l2, l3, l4, m0, m1, m2, m3, m4;
	add_constants uf(k2, 4'd5, 4'd12,K2);	
	sbox ug(k0, k1, K2, k3, k4, l0, l1, l2, l3, l4);
	linear uh(l0, l1, l2, l3, l4, m0, m1, m2, m3, m4);

	wire [63:0] M2, n0, n1, n2, n3, n4, o0, o1, o2, o3, o4;
	add_constants ui(m2, 4'd6, 4'd12,M2);	
	sbox uj(m0, m1, M2, m3, m4, n0, n1, n2, n3, n4);
	linear uk(n0, n1, n2, n3, n4, o0, o1, o2, o3, o4);

	wire [63:0] O2,p0, p1, p2, p3, p4, q0, q1, q2, q3, q4;
	add_constants ul(o2, 4'd7, 4'd12,O2);	
	sbox um(o0, o1, O2, o3, o4, p0, p1, p2, p3, p4);
	linear un(p0, p1, p2, p3, p4, q0, q1, q2, q3, q4);
 
	wire [63:0] Q2,r0, r1, r2, R2, r3, r4, s0, s1, s2, s3, s4;
	add_constants uo(q2, 4'd8, 4'd12,Q2);	
	sbox up(q0, q1, Q2, q3, q4, r0, r1, r2, r3, r4);
	linear uq(r0, r1, r2, r3, r4, s0, s1, s2, s3, s4);
   
	wire [63:0] S2, t0, t1, t2, t3, t4, u0, u1, u2, u3, u4;
	add_constants us(s2, 4'd9, 4'd12,S2);	
	sbox ut(s0, s1, S2, s3, s4, t0, t1, t2, t3, t4);
	linear uu(t0, t1, t2, t3, t4, u0, u1, u2, u3, u4);

	wire [63:0] U2, v0, v1, v2, v3, v4, w0, w1, w2, w3, w4;
	add_constants uv(u2, 4'd10, 4'd12,U2);	
	sbox ux(u0, u1, U2, u3, u4, v0, v1, v2, v3, v4);
	linear uy(v0, v1, v2, v3, v4, w0, w1, w2, w3, w4);
	
	wire [63:0] W2, z0, z1, z2, z3, z4;
	add_constants uz(w2, 4'd11, 4'd12,W2);	
	sbox uA(w0, w1, W2, w3, w4, z0, z1, z2, z3, z4);
	linear uB(z0, z1, z2, z3, z4, y0, y1, y2, y3, y4);

endmodule

