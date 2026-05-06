
`timescale 1ns/1ps

module rs_syndrome (
    input             clk,
    input             rst_n,
    input             start,
    input  [47:0]     rcv,       // r[0] at [3:0], r[11] at [47:44]
    output reg        done,
    output reg        error_free,
    output reg [3:0]  S1, S2, S3, S4, S5, S6
);
    wire [3:0] r[0:11];
    genvar i;
    generate for(i=0;i<12;i=i+1) begin:UP
        assign r[i] = rcv[i*4+:4];
    end endgenerate

    //alpha roots
    localparam [3:0] A1=4'h2,A2=4'h4,A3=4'h8,A4=4'h3,A5=4'h6,A6=4'hC;

    //horner accumulators
    reg [3:0] h1,h2,h3,h4,h5,h6;

    //acc*alpha multiplier outputs
    wire [3:0] m1,m2,m3,m4,m5,m6;
    gf16_mul um1(.a(h1),.b(A1),.y(m1));
    gf16_mul um2(.a(h2),.b(A2),.y(m2));
    gf16_mul um3(.a(h3),.b(A3),.y(m3));
    gf16_mul um4(.a(h4),.b(A4),.y(m4));
    gf16_mul um5(.a(h5),.b(A5),.y(m5));
    gf16_mul um6(.a(h6),.b(A6),.y(m6));

    reg [3:0] step;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            step<=0; done<=0;
            h1<=0;h2<=0;h3<=0;h4<=0;h5<=0;h6<=0;
        end else begin
            done<=0;
            case(step)
                4'd0: if(start) begin
                    h1<=r[11];h2<=r[11];h3<=r[11];h4<=r[11];h5<=r[11];h6<=r[11];
                    step<=4'd1;
                end
                4'd1:  begin h1<=m1^r[10];h2<=m2^r[10];h3<=m3^r[10];h4<=m4^r[10];h5<=m5^r[10];h6<=m6^r[10]; step<=4'd2;  end
                4'd2:  begin h1<=m1^r[9]; h2<=m2^r[9]; h3<=m3^r[9]; h4<=m4^r[9]; h5<=m5^r[9]; h6<=m6^r[9];  step<=4'd3;  end
                4'd3:  begin h1<=m1^r[8]; h2<=m2^r[8]; h3<=m3^r[8]; h4<=m4^r[8]; h5<=m5^r[8]; h6<=m6^r[8];  step<=4'd4;  end
                4'd4:  begin h1<=m1^r[7]; h2<=m2^r[7]; h3<=m3^r[7]; h4<=m4^r[7]; h5<=m5^r[7]; h6<=m6^r[7];  step<=4'd5;  end
                4'd5:  begin h1<=m1^r[6]; h2<=m2^r[6]; h3<=m3^r[6]; h4<=m4^r[6]; h5<=m5^r[6]; h6<=m6^r[6];  step<=4'd6;  end
                4'd6:  begin h1<=m1^r[5]; h2<=m2^r[5]; h3<=m3^r[5]; h4<=m4^r[5]; h5<=m5^r[5]; h6<=m6^r[5];  step<=4'd7;  end
                4'd7:  begin h1<=m1^r[4]; h2<=m2^r[4]; h3<=m3^r[4]; h4<=m4^r[4]; h5<=m5^r[4]; h6<=m6^r[4];  step<=4'd8;  end
                4'd8:  begin h1<=m1^r[3]; h2<=m2^r[3]; h3<=m3^r[3]; h4<=m4^r[3]; h5<=m5^r[3]; h6<=m6^r[3];  step<=4'd9;  end
                4'd9:  begin h1<=m1^r[2]; h2<=m2^r[2]; h3<=m3^r[2]; h4<=m4^r[2]; h5<=m5^r[2]; h6<=m6^r[2];  step<=4'd10; end
                4'd10: begin h1<=m1^r[1]; h2<=m2^r[1]; h3<=m3^r[1]; h4<=m4^r[1]; h5<=m5^r[1]; h6<=m6^r[1];  step<=4'd11; end
                4'd11: begin h1<=m1^r[0]; h2<=m2^r[0]; h3<=m3^r[0]; h4<=m4^r[0]; h5<=m5^r[0]; h6<=m6^r[0];  step<=4'd12; end
                4'd12: begin
                    S1<=h1;S2<=h2;S3<=h3;S4<=h4;S5<=h5;S6<=h6;
                    error_free <= (h1==0)&&(h2==0)&&(h3==0)&&(h4==0)&&(h5==0)&&(h6==0);
                    done<=1; step<=4'd0;
                end
            endcase
        end
    end
endmodule