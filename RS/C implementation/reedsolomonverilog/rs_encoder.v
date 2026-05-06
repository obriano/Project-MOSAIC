
`timescale 1ns/1ps

module rs_encoder (
    input             clk,
    input             rst_n,
    input             start,
    input  [3:0]      d0,d1,d2,d3,d4,d5,  
    output reg        done,
    output reg [3:0]  c0,c1,c2,c3,c4,c5,   
    output reg [3:0]  p0,p1,p2,p3,p4,p5    
);
    //Generator polynomial coefficients
    localparam [3:0] G0=4'hC, G1=4'hA, G2=4'hC, G3=4'h3, G4=4'h9, G5=4'h7;

    //LFSR registers (r[0]=lowest degree coefficient)
    reg [3:0] r0,r1,r2,r3,r4,r5;

    //Symbol input to LFSR
    reg [3:0] sym;

    //Feedback = sym XOR r5 (divides into generator feedback)
    wire [3:0] fb = sym ^ r5;

    //fb * g[i]
    wire [3:0] fbg0,fbg1,fbg2,fbg3,fbg4,fbg5;
    gf16_mul m0(.a(fb),.b(G0),.y(fbg0));
    gf16_mul m1(.a(fb),.b(G1),.y(fbg1));
    gf16_mul m2(.a(fb),.b(G2),.y(fbg2));
    gf16_mul m3(.a(fb),.b(G3),.y(fbg3));
    gf16_mul m4(.a(fb),.b(G4),.y(fbg4));
    gf16_mul m5(.a(fb),.b(G5),.y(fbg5));

    //Latched inputs
    reg [3:0] di0,di1,di2,di3,di4,di5;

    task lfsr_step;
    begin
        r0 <= fbg0;
        r1 <= r0 ^ fbg1;
        r2 <= r1 ^ fbg2;
        r3 <= r2 ^ fbg3;
        r4 <= r3 ^ fbg4;
        r5 <= r4 ^ fbg5;
    end
    endtask

    //State machine
    reg [2:0] st;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            st<=0; done<=0;
            r0<=0;r1<=0;r2<=0;r3<=0;r4<=0;r5<=0; sym<=0;
            di0<=0;di1<=0;di2<=0;di3<=0;di4<=0;di5<=0;
        end else begin
            done<=0;
            case(st)
                3'd0: begin
                    if(start) begin
                        di0<=d0;di1<=d1;di2<=d2;di3<=d3;di4<=d4;di5<=d5;
                        r0<=0;r1<=0;r2<=0;r3<=0;r4<=0;r5<=0;
                        sym<=d5;          //feed highest degree first
                        st<=3'd1;
                    end
                end
                3'd1: begin lfsr_step(); sym<=di4; st<=3'd2; end
                3'd2: begin lfsr_step(); sym<=di3; st<=3'd3; end
                3'd3: begin lfsr_step(); sym<=di2; st<=3'd4; end
                3'd4: begin lfsr_step(); sym<=di1; st<=3'd5; end
                3'd5: begin lfsr_step(); sym<=di0; st<=3'd6; end
                3'd6: begin lfsr_step();            st<=3'd7; end
                3'd7: begin
                    c0<=di0;c1<=di1;c2<=di2;c3<=di3;c4<=di4;c5<=di5;
                    p0<=r0; p1<=r1; p2<=r2; p3<=r3; p4<=r4; p5<=r5;
                    done<=1; st<=3'd0;
                end
            endcase
        end
    end
endmodule