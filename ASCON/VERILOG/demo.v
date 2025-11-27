module demo(x0, x1, x2, x3, x4, y0, y1, y2, y3, y4, d0, d1, d2, plin0, plin1, dec0, dec1);
input [63:0] x0, x1, x2, x3, x4, d0, d1, d2, plin0, plin1;
output [63:0] y0, y1, y2, y3, y4, dec0, dec1;

wire [63:0] s10, s20, s30, s40, s00;
initialization u0(x0,x1,x2,x3,x4, s00, s10, s20, s30, s40, x1, x2);
wire [63:0] s11, s21, s31, s41, s01;
associated_data u2(s00, s10, s20, s30, s40, s01, s11, s21, s31, s41, d0, d1, d2);
wire [63:0] s12, s22, s32, s42, s02, cyp0, cyp1;
encrypt u3(s01, s11, s21, s31, s41, s02, s12, s22, s32, s42, plin0, plin1, cyp0, cyp1);
wire [63:0] s13, s23, s33, s43, s03;
final u4(s02, s12, s22, s32, s42, s03, s13, s23, s33, s43, x1, x2);

wire [63:0] s14, s24, s34, s44, s04;
initialization u5(x0,x1,x2,x3,x4, s04, s14, s24, s34, s44, x1, x2);

wire [63:0] s15, s25, s35, s45, s05;
associated_data u6(s04, s14, s24, s34, s44, s05, s15, s25, s35, s45, d0, d1, d2);

wire [63:0] s16, s26, s36, s46, s06;
decrypt u7(s05, s15, s25, s35, s45, s06, s16, s26, s36, s46, dec0, dec1, cyp0, cyp1);
endmodule

