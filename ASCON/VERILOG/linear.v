module linear(IV, k0, k1, n0,n1,oIV, ok0, ok1, on0,on1);
	input [63:0] IV, k0, k1, n0, n1;
	output [63:0] oIV, ok0, ok1, on0,on1;

	wire [63:0]t0, t1;
	rotate u00(IV, t0, 6'd19);
	rotate u01(IV, t1, 6'd28);
	assign oIV = IV^t0^t1;

	wire [63:0] a0, a1;
	rotate u10(k0, a0, 6'd61);
	rotate u11(k0, a1, 6'd39);
	assign ok0= k0^a0^a1;

	wire [63:0] b0, b1;
	rotate u20(k1, b0, 6'd1);
	rotate u21(k1, b1, 6'd6);
	assign ok1 = k1^b0^b1;

	wire [63:0] c0, c1;
	rotate u30(n0, c0, 6'd10);
	rotate u31(n0, c1, 6'd17);
	assign on0= n0^c0^c1;

	wire [63:0] d0, d1;
	rotate u40(n1, d0, 6'd7);
	rotate u41(n1, d1, 6'd41);
	assign on1= n1^d0^d1;
endmodule

