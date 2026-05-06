
`timescale 1ns/1ps

module gf16_mul (
    input  [3:0] a, b,
    output [3:0] y
);
    wire [6:0] p;
    assign p[0] = (a[0]&b[0]);
    assign p[1] = (a[1]&b[0])^(a[0]&b[1]);
    assign p[2] = (a[2]&b[0])^(a[1]&b[1])^(a[0]&b[2]);
    assign p[3] = (a[3]&b[0])^(a[2]&b[1])^(a[1]&b[2])^(a[0]&b[3]);
    assign p[4] = (a[3]&b[1])^(a[2]&b[2])^(a[1]&b[3]);
    assign p[5] = (a[3]&b[2])^(a[2]&b[3]);
    assign p[6] =  a[3]&b[3];
    assign y[0] = p[0]^p[4];
    assign y[1] = p[1]^p[4]^p[5];
    assign y[2] = p[2]^p[5]^p[6];
    assign y[3] = p[3]^p[6];
endmodule

module gf16_inv (
    input  [3:0] a,
    output reg [3:0] y
);
    always @(*) case(a)
        4'h0:y=4'h0; 4'h1:y=4'h1; 4'h2:y=4'h9; 4'h3:y=4'hE;
        4'h4:y=4'hD; 4'h5:y=4'hB; 4'h6:y=4'h7; 4'h7:y=4'h6;
        4'h8:y=4'hF; 4'h9:y=4'h2; 4'hA:y=4'hC; 4'hB:y=4'h5;
        4'hC:y=4'hA; 4'hD:y=4'h4; 4'hE:y=4'h3; 4'hF:y=4'h8;
    endcase
endmodule

module gf16_div (
    input  [3:0] a, b,
    output [3:0] y
);
    wire [3:0] bi;
    gf16_inv u0(.a(b),.y(bi));
    gf16_mul u1(.a(a),.b(bi),.y(y));
endmodule