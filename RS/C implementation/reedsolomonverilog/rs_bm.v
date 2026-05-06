//Computes error locator polynomial Lambda(x) from syndromes S1..S6.
`timescale 1ns/1ps

module rs_bm (
    input            clk,
    input            rst_n,
    input            start,
    input  [3:0]     S1, S2, S3, S4, S5, S6,
    output reg       done,
    output reg [3:0] L1, L2, L3,
    output reg [1:0] num_errors
);
    reg [3:0] C1, C2, C3;
    reg [3:0] B0, B1, B2, B3;
    reg [3:0] b_r;
    reg [1:0] L_r;
    reg [2:0] m_r;
    reg [2:0] iter;
    reg [3:0] sv1,sv2,sv3,sv4,sv5,sv6;
    reg [3:0] sc, sn, sn1, sn2;

    wire [3:0] p1,p2,p3;
    gf16_mul uc1(.a(C1),.b(sn), .y(p1));
    gf16_mul uc2(.a(C2),.b(sn1),.y(p2));
    gf16_mul uc3(.a(C3),.b(sn2),.y(p3));
    wire [3:0] disc = sc ^ p1 ^ p2 ^ p3;

    //c_coeff = disc / b_r
    wire [3:0] binv, cc;
    gf16_inv uinv(.a(b_r),.y(binv));
    gf16_mul ucc (.a(disc),.b(binv),.y(cc));

    //B shifted by m_r positions (B_sh[i] = B[i-m_r] if i >= m_r else 0)
    reg [3:0] bs1,bs2,bs3;
    always @(*) begin
        bs1=4'h0; bs2=4'h0; bs3=4'h0;
        case(m_r)
            3'd1: begin bs1=B0; bs2=B1; bs3=B2; end
            3'd2: begin bs2=B0; bs3=B1;          end
            3'd3: begin bs3=B0;                  end
            default: ;  
        endcase
    end

    wire [3:0] cb1,cb2,cb3;
    gf16_mul ub1(.a(cc),.b(bs1),.y(cb1));
    gf16_mul ub2(.a(cc),.b(bs2),.y(cb2));
    gf16_mul ub3(.a(cc),.b(bs3),.y(cb3));

    reg [1:0] st;
    localparam IDLE=2'd0, LOAD=2'd1, EVAL=2'd2, OUTP=2'd3;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            st<=IDLE; done<=0; iter<=0;
            C1<=0;C2<=0;C3<=0;
            B0<=1;B1<=0;B2<=0;B3<=0;
            b_r<=1; L_r<=0; m_r<=1;
            sv1<=0;sv2<=0;sv3<=0;sv4<=0;sv5<=0;sv6<=0;
            sc<=0;sn<=0;sn1<=0;sn2<=0;
            L1<=0;L2<=0;L3<=0;num_errors<=0;
        end else begin
            done<=0;
            case(st)
                IDLE: begin
                    if(start) begin
                        sv1<=S1;sv2<=S2;sv3<=S3;sv4<=S4;sv5<=S5;sv6<=S6;
                        C1<=0;C2<=0;C3<=0;
                        B0<=1;B1<=0;B2<=0;B3<=0;
                        b_r<=1; L_r<=0; m_r<=1; iter<=0;
                        st<=LOAD;
                    end
                end

                LOAD: begin
                    //Set up syndrome MUX 
                    case(iter)
                        3'd0: begin sc<=S1; sn<=4'h0; sn1<=4'h0; sn2<=4'h0; end
                        3'd1: begin sc<=S2; sn<=sv1;  sn1<=4'h0; sn2<=4'h0; end
                        3'd2: begin sc<=S3; sn<=sv2;  sn1<=sv1;  sn2<=4'h0; end
                        3'd3: begin sc<=S4; sn<=sv3;  sn1<=sv2;  sn2<=sv1;  end
                        3'd4: begin sc<=S5; sn<=sv4;  sn1<=sv3;  sn2<=sv2;  end
                        3'd5: begin sc<=S6; sn<=sv5;  sn1<=sv4;  sn2<=sv3;  end
                        default: begin sc<=0; sn<=0; sn1<=0; sn2<=0; end
                    endcase
                    st<=EVAL;
                end

                EVAL: begin
                    if(disc==4'h0) begin
                        m_r <= m_r + 1;
                    end else if({L_r, 1'b0} <= {1'b0, iter}) begin
                        C1 <= C1 ^ cb1;
                        C2 <= C2 ^ cb2;
                        C3 <= C3 ^ cb3;
                        B0 <= 4'h1; B1 <= C1; B2 <= C2; B3 <= C3;
                        b_r  <= disc;
                        L_r  <= iter[1:0] + 2'd1 - L_r;
                        m_r  <= 3'd1;
                    end else begin
                        C1 <= C1 ^ cb1;
                        C2 <= C2 ^ cb2;
                        C3 <= C3 ^ cb3;
                        m_r <= m_r + 1;
                    end

                    if(iter==3'd5) st<=OUTP;
                    else begin iter<=iter+1; st<=LOAD; end
                end

                OUTP: begin
                    L1<=C1; L2<=C2; L3<=C3;
                    num_errors<=L_r;
                    done<=1; st<=IDLE;
                end
            endcase
        end
    end
endmodule