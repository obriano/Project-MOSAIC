module sbox(x0, x1, x2, x3, x4, y0, y1, y2, y3, y4);
	input [63:0] x0, x1, x2, x3, x4;
	output [63:0] y0, y1, y2, y3, y4;
	assign y0 = x4&x1^x3^x2&x1^x2^x1&x0^x1^x0;
	assign y1 = x4^x2&x3^x3^x3&x1^x2^x1&x2^x1^x0;
	assign y2 = x4&x3^x4^x2^x1^64'hffffffffffffffff;
	assign y3 = x4&x0^x3&x0^x4^x3^x2^x1^x0;
	assign y4 = x4&x1^x4^x3^x1&x0^x1;
endmodule

