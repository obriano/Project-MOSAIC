
module rs_chien_forney (
    input             clk,
    input             rst_n,
    input             start,

    input  [3:0]      S1, S2, S3, S4, S5, S6,
    input  [3:0]      L1, L2, L3,
    input  [1:0]      num_errors,
    input  [47:0]     rcv,

    output reg [47:0] corrected,
    output reg        uncorrectable,
    output reg        done
);

    //Omega[0] = L0*S1 = S1
    //Omega[1] = L0*S2 + L1*S1
    //Omega[2] = L0*S3 + L1*S2 + L2*S1
    //Omega[3] = L0*S4 + L1*S3 + L2*S2 + L3*S1
    //Omega[4] = L0*S5 + L1*S4 + L2*S3 + L3*S2
    //Omega[5] = L0*S6 + L1*S5 + L2*S4 + L3*S3

    wire [3:0] l1s1,l1s2,l1s3,l1s4,l1s5;
    wire [3:0] l2s1,l2s2,l2s3,l2s4;
    wire [3:0] l3s1,l3s2,l3s3;

    gf16_mul ol1s1(.a(L1),.b(S1),.y(l1s1));
    gf16_mul ol1s2(.a(L1),.b(S2),.y(l1s2));
    gf16_mul ol1s3(.a(L1),.b(S3),.y(l1s3));
    gf16_mul ol1s4(.a(L1),.b(S4),.y(l1s4));
    gf16_mul ol1s5(.a(L1),.b(S5),.y(l1s5));
    gf16_mul ol2s1(.a(L2),.b(S1),.y(l2s1));
    gf16_mul ol2s2(.a(L2),.b(S2),.y(l2s2));
    gf16_mul ol2s3(.a(L2),.b(S3),.y(l2s3));
    gf16_mul ol2s4(.a(L2),.b(S4),.y(l2s4));
    gf16_mul ol3s1(.a(L3),.b(S1),.y(l3s1));
    gf16_mul ol3s2(.a(L3),.b(S2),.y(l3s2));
    gf16_mul ol3s3(.a(L3),.b(S3),.y(l3s3));

    wire [3:0] Om0, Om1, Om2, Om3, Om4, Om5;
    assign Om0 = S1;
    assign Om1 = S2 ^ l1s1;
    assign Om2 = S3 ^ l1s2 ^ l2s1;
    assign Om3 = S4 ^ l1s3 ^ l2s2 ^ l3s1;
    assign Om4 = S5 ^ l1s4 ^ l2s3 ^ l3s2;
    assign Om5 = S6 ^ l1s5 ^ l2s4 ^ l3s3;

    // ---------------------------------------------------------------
    // Alpha inverse powers for Chien search
    // alpha^{-k} = alpha^{15-k mod 15}
    // Precomputed: a^0=1,a^14=9,a^13=D,a^12=F,a^11=E,a^10=7,a^9=A,
    //              a^8=5,a^7=B,a^6=C,a^5=6,a^4=3,a^3=8,a^2=4,a^1=2
    // alpha^{-k} for k=0..11:
    //   k=0: a^0  =1   k=1: a^14=9  k=2: a^13=D  k=3: a^12=F
    //   k=4: a^11=E   k=5: a^10=7  k=6: a^9=A    k=7: a^8=5
    //   k=8: a^7=B    k=9: a^6=C   k=10:a^5=6    k=11:a^4=3
    // ---------------------------------------------------------------
    // For each position k, evaluate Lambda(Xk_inv), Omega(Xk_inv), Lambda'(Xk_inv)
    // Lambda'(x) = L1 + L3*x^2  (formal derivative, characteristic 2)

    // We implement Chien sequentially: iterate k=0..11
    //Current Xk_inv register
    reg [3:0] xi;   // current Xk_inv = alpha^{-(k)}

    //Polynomial evaluation accumulators for current xi
    //Lambda(xi): 1 + L1*xi + L2*xi^2 + L3*xi^3
    //We evaluate by multiplying xi powers on the fly
    wire [3:0] xi2, xi3;
    wire [3:0] l1xi, l2xi2, l3xi3;
    wire [3:0] lp_l3xi2;  //L3*xi^2 for Lambda'

    gf16_mul uxi2 (.a(xi), .b(xi),  .y(xi2));
    gf16_mul uxi3 (.a(xi2),.b(xi),  .y(xi3));
    gf16_mul ul1xi(.a(L1), .b(xi),  .y(l1xi));
    gf16_mul ul2x2(.a(L2), .b(xi2), .y(l2xi2));
    gf16_mul ul3x3(.a(L3), .b(xi3), .y(l3xi3));
    gf16_mul ulp3 (.a(L3), .b(xi2), .y(lp_l3xi2));

    wire [3:0] lam_val = 4'h1 ^ l1xi ^ l2xi2 ^ l3xi3;
    wire [3:0] ldiff_val = L1 ^ lp_l3xi2;  // Lambda'(xi)

    //Omega(xi): Om0 + Om1*xi + Om2*xi^2 + Om3*xi^3 + Om4*xi^4 + Om5*xi^5
    wire [3:0] xi4, xi5;
    wire [3:0] om1xi, om2xi2, om3xi3, om4xi4, om5xi5;
    gf16_mul uxi4  (.a(xi2),.b(xi2), .y(xi4));
    gf16_mul uxi5  (.a(xi4),.b(xi),  .y(xi5));
    gf16_mul uom1  (.a(Om1),.b(xi),  .y(om1xi));
    gf16_mul uom2  (.a(Om2),.b(xi2), .y(om2xi2));
    gf16_mul uom3  (.a(Om3),.b(xi3), .y(om3xi3));
    gf16_mul uom4  (.a(Om4),.b(xi4), .y(om4xi4));
    gf16_mul uom5  (.a(Om5),.b(xi5), .y(om5xi5));
    wire [3:0] omega_val = Om0 ^ om1xi ^ om2xi2 ^ om3xi3 ^ om4xi4 ^ om5xi5;

    //Forney: ek = Omega(Xk_inv) / Lambda'(Xk_inv)
    wire [3:0] ek;
    gf16_div uek (.a(omega_val), .b(ldiff_val), .y(ek));

    //Received symbols unpacked
    wire [3:0] rv[0:11];
    genvar gi;
    generate for(gi=0;gi<12;gi=gi+1) begin:RVU
        assign rv[gi] = rcv[gi*4+:4];
    end endgenerate

    function [3:0] xinv_lut;
        input [3:0] k;
        case(k)
            4'd0:  xinv_lut=4'h1;
            4'd1:  xinv_lut=4'h9;
            4'd2:  xinv_lut=4'hD;
            4'd3:  xinv_lut=4'hF;
            4'd4:  xinv_lut=4'hE;
            4'd5:  xinv_lut=4'h7;
            4'd6:  xinv_lut=4'hA;
            4'd7:  xinv_lut=4'h5;
            4'd8:  xinv_lut=4'hB;
            4'd9:  xinv_lut=4'hC;
            4'd10: xinv_lut=4'h6;
            4'd11: xinv_lut=4'h3;
            default: xinv_lut=4'h0;
        endcase
    endfunction

    reg [3:0] k;       //current position 
    reg [1:0] st;
    reg [1:0] err_cnt; //how many roots
    reg [47:0] cw_r;   //copy of codeword

    localparam IDLE=2'd0, CHIEN=2'd1, FIXUP=2'd2, OUTP=2'd3;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            st<=IDLE; done<=0; k<=0; xi<=0; err_cnt<=0;
            corrected<=0; uncorrectable<=0; cw_r<=0;
        end else begin
            done<=0;
            case(st)
                IDLE: begin
                    if(start) begin
                        cw_r   <= rcv;
                        k      <= 4'd0;
                        xi     <= xinv_lut(4'd0);  //alpha^0 = 1
                        err_cnt<= 2'd0;
                        st     <= CHIEN;
                    end
                end

                CHIEN: begin
                    if(lam_val == 4'h0) begin
                        if(ldiff_val != 4'h0) begin
                            cw_r[k*4+:4] <= cw_r[k*4+:4] ^ ek;
                            err_cnt <= err_cnt + 1;
                        end
                    end
                    if(k == 4'd11) begin
                        st <= OUTP;
                    end else begin
                        k  <= k + 4'd1;
                        xi <= xinv_lut(k + 4'd1);
                        st <= CHIEN;  
                    end
                end

                OUTP: begin
                    corrected     <= cw_r;
                    //uncorrectable if num_errors doesnt match Lambda degree
                    uncorrectable <= (err_cnt != num_errors);
                    done          <= 1;
                    st            <= IDLE;
                end

                default: st<=IDLE;
            endcase
        end
    end
endmodule