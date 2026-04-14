module reciever(x0, x1, x2, x3, x4, y0, y1, y2, y3, y4, d0, d1, d2, cyp0, cyp1, dec0, dec1);
input [63:0] x0, x1, x2, x3, x4, d0, d1, d2, cyp0, cyp1;
output [63:0] y0, y1, y2, y3, y4, dec0, dec1;

wire [63:0] s14, s24, s34, s44, s04;
initialization u5(x0,x1,x2,x3,x4, s04, s14, s24, s34, s44, x1, x2);

wire [63:0] s15, s25, s35, s45, s05;
associated_data u6(s04, s14, s24, s34, s44, s05, s15, s25, s35, s45, d0, d1, d2);

wire [63:0] s16, s26, s36, s46, s06;
decrypt u7(s05, s15, s25, s35, s45, s06, s16, s26, s36, s46, dec0, dec1, cyp0, cyp1);
final u8(s06, s16, s26, s36, s46, y0, y1, y2, y3, y4, x1, x2);
endmodule

