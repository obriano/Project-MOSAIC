// Input:  48-bit packed received codeword, r[k] at bits [4k+3:4k]
// Output: 48-bit packed corrected codeword, same packing
//         error_free      - no syndromes, nothing to do
//         uncorrectable   - more than 3 errors detected
//         done            - output valid
`timescale 1ns/1ps

module rs_decoder (
    input             clk,
    input             rst_n,
    input             start,
    input  [47:0]     rcv,

    output            done,
    output [47:0]     corrected,
    output            error_free,
    output            uncorrectable
);
    //Syndrome stage 
    wire        synd_done;
    wire        synd_ef;
    wire [3:0]  S1,S2,S3,S4,S5,S6;

    rs_syndrome u_synd (
        .clk(clk), .rst_n(rst_n),
        .start(start), .rcv(rcv),
        .done(synd_done), .error_free(synd_ef),
        .S1(S1),.S2(S2),.S3(S3),.S4(S4),.S5(S5),.S6(S6)
    );

    //BM stage
    wire        bm_done;
    wire [3:0]  L1,L2,L3;
    wire [1:0]  num_errors;

    wire bm_start = synd_done & ~synd_ef;

    rs_bm u_bm (
        .clk(clk), .rst_n(rst_n),
        .start(bm_start),
        .S1(S1),.S2(S2),.S3(S3),.S4(S4),.S5(S5),.S6(S6),
        .done(bm_done),
        .L1(L1),.L2(L2),.L3(L3),.num_errors(num_errors)
    );

    reg [47:0] rcv_lat;
    always @(posedge clk) if(start) rcv_lat <= rcv;

    //chien/Forney stage
    wire        cf_done;
    wire [47:0] cf_corr;
    wire        cf_uncorr;

    rs_chien_forney u_cf (
        .clk(clk), .rst_n(rst_n),
        .start(bm_done),
        .S1(S1),.S2(S2),.S3(S3),.S4(S4),.S5(S5),.S6(S6),
        .L1(L1),.L2(L2),.L3(L3),.num_errors(num_errors),
        .rcv(rcv_lat),
        .corrected(cf_corr),
        .uncorrectable(cf_uncorr),
        .done(cf_done)
    );

    //output mux 
    reg        out_done;
    reg [47:0] out_corr;
    reg        out_ef;
    reg        out_uncorr;

    reg ef_latch;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ef_latch<=0; out_done<=0;
            out_corr<=0; out_ef<=0; out_uncorr<=0;
        end else begin
            out_done<=0;
            if(synd_done && synd_ef) begin
                out_corr   <= rcv_lat;
                out_ef     <= 1;
                out_uncorr <= 0;
                out_done   <= 1;
            end
            if(cf_done) begin
                out_corr   <= cf_corr;
                out_ef     <= 0;
                out_uncorr <= cf_uncorr;
                out_done   <= 1;
            end
        end
    end

    assign done          = out_done;
    assign corrected     = out_corr;
    assign error_free    = out_ef;
    assign uncorrectable = out_uncorr;

endmodule