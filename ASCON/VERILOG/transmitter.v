module transmitter(x0, x1, x2, x3, x4, y0, y1, y2, y3, y4, d0, d1, d2, plin0, plin1, cyp0, cyp1);
input [63:0] x0, x1, x2, x3, x4, d0, d1, d2, plin0, plin1;
output [63:0] y0, y1, y2, y3, y4, cyp0, cyp1;

wire [63:0] s10, s20, s30, s40, s00;
initialization u0(x0,x1,x2,x3,x4, s00, s10, s20, s30, s40, x1, x2);
wire [63:0] s11, s21, s31, s41, s01;
associated_data u2(s00, s10, s20, s30, s40, s01, s11, s21, s31, s41, d0, d1, d2);
wire [63:0] s12, s22, s32, s42, s02;
encrypt u3(s01, s11, s21, s31, s41, s02, s12, s22, s32, s42, plin0, plin1, cyp0, cyp1);
wire [63:0] s13, s23, s33, s43, s03;
final u4(s02, s12, s22, s32, s42, y0, y1, y2, y3, y4, x1, x2);
endmodule

