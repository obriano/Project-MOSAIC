
`timescale 1ns/1ps

module rs_tb;
    reg clk, rst_n;
    integer pass_cnt, fail_cnt, test_num;

    reg        enc_start;
    reg  [3:0] ed0,ed1,ed2,ed3,ed4,ed5;
    wire       enc_done;
    wire [3:0] ec0,ec1,ec2,ec3,ec4,ec5;
    wire [3:0] ep0,ep1,ep2,ep3,ep4,ep5;

    rs_encoder u_enc(.clk(clk),.rst_n(rst_n),.start(enc_start),
        .d0(ed0),.d1(ed1),.d2(ed2),.d3(ed3),.d4(ed4),.d5(ed5),
        .done(enc_done),.c0(ec0),.c1(ec1),.c2(ec2),.c3(ec3),.c4(ec4),.c5(ec5),
        .p0(ep0),.p1(ep1),.p2(ep2),.p3(ep3),.p4(ep4),.p5(ep5));

    reg        dec_start;
    reg [47:0] dec_rcv;
    wire       dec_done, dec_ef, dec_uncorr;
    wire [47:0] dec_corr;

    rs_decoder u_dec(.clk(clk),.rst_n(rst_n),.start(dec_start),.rcv(dec_rcv),
        .done(dec_done),.corrected(dec_corr),.error_free(dec_ef),.uncorrectable(dec_uncorr));

    initial clk=0;
    always #5 clk=~clk;

    function [47:0] pk;
        input [3:0] p0,p1,p2,p3,p4,p5,d0,d1,d2,d3,d4,d5;
        pk = {d5,d4,d3,d2,d1,d0,p5,p4,p3,p2,p1,p0};
    endfunction

    //Encoder test
    task enc_test;
        input [3:0] d0,d1,d2,d3,d4,d5;
        input [3:0] xp0,xp1,xp2,xp3,xp4,xp5;  //expected parity
        reg ok;
        begin
            @(negedge clk); ed0<=d0;ed1<=d1;ed2<=d2;ed3<=d3;ed4<=d4;ed5<=d5; enc_start<=1;
            @(negedge clk); enc_start<=0;
            @(posedge enc_done); @(negedge clk);
            ok = (ep0===xp0)&&(ep1===xp1)&&(ep2===xp2)&&
                 (ep3===xp3)&&(ep4===xp4)&&(ep5===xp5);
            if(ok) begin
                $display("PASS ENC %0d: d=[%h,%h,%h,%h,%h,%h] p=[%h,%h,%h,%h,%h,%h]",
                    test_num,d0,d1,d2,d3,d4,d5,ep0,ep1,ep2,ep3,ep4,ep5);
                pass_cnt=pass_cnt+1;
            end else begin
                $display("FAIL ENC %0d: d=[%h,%h,%h,%h,%h,%h]",test_num,d0,d1,d2,d3,d4,d5);
                $display("  exp p=[%h,%h,%h,%h,%h,%h]",xp0,xp1,xp2,xp3,xp4,xp5);
                $display("  got p=[%h,%h,%h,%h,%h,%h]",ep0,ep1,ep2,ep3,ep4,ep5);
                fail_cnt=fail_cnt+1;
            end
            test_num=test_num+1;
        end
    endtask

    //Decoder test
    task dec_test;
        input [47:0] rcv_cw;
        input [47:0] exp_corr;
        input exp_ef, exp_unc;
        reg ok;
        begin
            @(negedge clk); dec_rcv<=rcv_cw; dec_start<=1;
            @(negedge clk); dec_start<=0;
            @(posedge dec_done); @(negedge clk);
            ok = (dec_corr===exp_corr)&&(dec_ef===exp_ef)&&(dec_uncorr===exp_unc);
            if(ok) begin
                $display("PASS DEC %0d", test_num);
                pass_cnt=pass_cnt+1;
            end else begin
                $display("FAIL DEC %0d", test_num);
                if(dec_corr!==exp_corr) $display("  corr exp=%012h got=%012h",exp_corr,dec_corr);
                if(dec_ef!==exp_ef)     $display("  error_free exp=%b got=%b",exp_ef,dec_ef);
                if(dec_uncorr!==exp_unc)$display("  uncorr exp=%b got=%b",exp_unc,dec_uncorr);
                fail_cnt=fail_cnt+1;
            end
            test_num=test_num+1;
        end
    endtask

    initial begin
        pass_cnt=0; fail_cnt=0; test_num=0;
        rst_n=0; enc_start=0; dec_start=0; dec_rcv=0;
        ed0=0;ed1=0;ed2=0;ed3=0;ed4=0;ed5=0;
        repeat(4) @(negedge clk); rst_n=1; repeat(2) @(negedge clk);

        $display("===== RS(12,6) ENCODER TESTS =====");
        enc_test(4'h1,4'h2,4'h3,4'h4,4'h5,4'h6,  4'h3,4'h2,4'h9,4'hE,4'h4,4'hE);
        enc_test(4'hA,4'hB,4'hC,4'hD,4'hE,4'hF,  4'h4,4'h4,4'hB,4'h4,4'h9,4'h4);
        enc_test(4'h7,4'h3,4'h8,4'hF,4'h1,4'h0,  4'h2,4'hD,4'h4,4'hC,4'hC,4'h2);
        enc_test(4'h0,4'h0,4'h0,4'h0,4'h0,4'h0,  4'h0,4'h0,4'h0,4'h0,4'h0,4'h0);
        enc_test(4'hF,4'hF,4'hF,4'hF,4'hF,4'hF,  4'h2,4'hA,4'h1,4'h9,4'h1,4'hA);
        enc_test(4'h0,4'h0,4'h0,4'h0,4'h0,4'h1,  4'h7,4'h4,4'h8,4'h3,4'h2,4'h3);

        $display("");
        $display("===== RS(12,6) DECODER TESTS =====");

        //No-error cases
        // Case 0: clean codeword
        dec_test(pk(4'hC,4'h9,4'hA,4'h8,4'h3,4'h4, 4'hC,4'hC,4'h6,4'h5,4'h7,4'h7),
                 pk(4'hC,4'h9,4'hA,4'h8,4'h3,4'h4, 4'hC,4'hC,4'h6,4'h5,4'h7,4'h7), 1,0);
        // Case 1: clean
        dec_test(pk(4'hA,4'h6,4'hF,4'h0,4'h3,4'hC, 4'h4,4'h2,4'h8,4'hC,4'h2,4'hF),
                 pk(4'hA,4'h6,4'hF,4'h0,4'h3,4'hC, 4'h4,4'h2,4'h8,4'hC,4'h2,4'hF), 1,0);
        // Case 2: clean
        dec_test(pk(4'hC,4'hC,4'h7,4'hF,4'h7,4'h6, 4'h6,4'hD,4'h6,4'hB,4'hC,4'h6),
                 pk(4'hC,4'hC,4'h7,4'hF,4'h7,4'h6, 4'h6,4'hD,4'h6,4'hB,4'hC,4'h6), 1,0);
        // Case 3: clean
        dec_test(pk(4'h9,4'h1,4'hF,4'h0,4'h5,4'h4, 4'h4,4'hE,4'h5,4'hA,4'h2,4'h2),
                 pk(4'h9,4'h1,4'hF,4'h0,4'h5,4'h4, 4'h4,4'hE,4'h5,4'hA,4'h2,4'h2), 1,0);

        //1-error cases
        // Case 4: error at pos 6, xor 4
        dec_test(pk(4'hA,4'hA,4'h5,4'h9,4'h2,4'h2, 4'hB,4'hA,4'hC,4'h1,4'h8,4'h0),
                 pk(4'hA,4'hA,4'h5,4'h9,4'h2,4'h2, 4'hF,4'hA,4'hC,4'h1,4'h8,4'h0), 0,0);
        // Case 5: error at pos 5, xor 3
        dec_test(pk(4'hF,4'h1,4'h5,4'h1,4'hE,4'hA, 4'hB,4'h2,4'hE,4'h6,4'hE,4'h1),
                 pk(4'hF,4'h1,4'h5,4'h1,4'hE,4'h9, 4'hB,4'h2,4'hE,4'h6,4'hE,4'h1), 0,0);
        // Case 6: error at pos 1, xor 1
        dec_test(pk(4'h0,4'h1,4'hB,4'hC,4'h7,4'h6, 4'h6,4'h5,4'hE,4'h5,4'h5,4'h1),
                 pk(4'h0,4'h0,4'hB,4'hC,4'h7,4'h6, 4'h6,4'h5,4'hE,4'h5,4'h5,4'h1), 0,0);
        // Case 7: error at pos 2, xor 5
        dec_test(pk(4'h2,4'h6,4'h9,4'hD,4'h9,4'h3, 4'h5,4'hF,4'hD,4'h2,4'hD,4'h2),
                 pk(4'h2,4'h6,4'hC,4'hD,4'h9,4'h3, 4'h5,4'hF,4'hD,4'h2,4'hD,4'h2), 0,0);

        //2-error cases
        // Case 8: errors at pos 0(xor 4), pos 10(xor 8)
        dec_test(pk(4'hD,4'h4,4'h5,4'hE,4'h3,4'h5, 4'h0,4'hC,4'hA,4'h4,4'h4,4'h6),
                 pk(4'h9,4'h4,4'h5,4'hE,4'h3,4'h5, 4'h0,4'hC,4'hA,4'h4,4'hC,4'h6), 0,0);
        // Case 9: errors at pos 2(xor D), pos 9(xor C)
        dec_test(pk(4'h7,4'h7,4'hF,4'h8,4'hF,4'hD, 4'h8,4'hC,4'h4,4'h7,4'hF,4'h1),
                 pk(4'h7,4'h7,4'h2,4'h8,4'hF,4'hD, 4'h8,4'hC,4'h4,4'hB,4'hF,4'h1), 0,0);
        // Case 10: errors at pos 2(xor 7), pos 4(xor 3)
        dec_test(pk(4'hE,4'hB,4'hA,4'hF,4'hB,4'h8, 4'h4,4'hD,4'h3,4'h3,4'h3,4'h4),
                 pk(4'hE,4'hB,4'hD,4'hF,4'h8,4'h8, 4'h4,4'hD,4'h3,4'h3,4'h3,4'h4), 0,0);
        // Case 11: errors at pos 1(xor 3), pos 5(xor B)
        dec_test(pk(4'h2,4'h8,4'h8,4'hE,4'h0,4'h3, 4'h4,4'h6,4'hA,4'hF,4'h7,4'h8),
                 pk(4'h2,4'hB,4'h8,4'hE,4'h0,4'h8, 4'h4,4'h6,4'hA,4'hF,4'h7,4'h8), 0,0);

        //3-error cases
        // Case 12: errors at pos 5(xor 7), 6(xor E), 11(xor D)
        dec_test(pk(4'h5,4'h1,4'h6,4'hE,4'h3,4'h5, 4'hC,4'h9,4'h0,4'h1,4'hA,4'hB),
                 pk(4'h5,4'h1,4'h6,4'hE,4'h3,4'h2, 4'h2,4'h9,4'h0,4'h1,4'hA,4'h6), 0,0);
        // Case 13: errors at pos 5(xor 4), 6(xor 5), 7(xor E)
        dec_test(pk(4'h8,4'h1,4'h6,4'hC,4'h3,4'h2, 4'h9,4'h3,4'hB,4'h2,4'h5,4'h1),
                 pk(4'h8,4'h1,4'h6,4'hC,4'h3,4'h6, 4'hC,4'hD,4'hB,4'h2,4'h5,4'h1), 0,0);
        // Case 14: errors at pos 4(xor 2), 6(xor D), 7(xor F)
        dec_test(pk(4'hF,4'hB,4'h1,4'h5,4'hE,4'h9, 4'hA,4'h6,4'h3,4'hA,4'h6,4'h7),
                 pk(4'hF,4'hB,4'h1,4'h5,4'hC,4'h9, 4'h7,4'h9,4'h3,4'hA,4'h6,4'h7), 0,0);
        // Case 15: errors at pos 2(xor 5), 7(xor F), 8(xor F)
        dec_test(pk(4'hA,4'h5,4'h8,4'h8,4'h8,4'h7, 4'hE,4'h2,4'h7,4'h2,4'h9,4'hA),
                 pk(4'hA,4'h5,4'hD,4'h8,4'h8,4'h7, 4'hE,4'hD,4'h8,4'h2,4'h9,4'hA), 0,0);
        // Case 16: errors at pos 9(xor B), 10(xor E), 11(xor A)
        dec_test(pk(4'hE,4'h2,4'h9,4'h3,4'hB,4'hF, 4'hD,4'h9,4'hD,4'hE,4'h7,4'h6),
                 pk(4'hE,4'h2,4'h9,4'h3,4'hB,4'hF, 4'hD,4'h9,4'hD,4'h5,4'h9,4'hC), 0,0);

        repeat(4) @(negedge clk);
        $display("");
        $display("===== RESULTS: %0d PASS  %0d FAIL =====", pass_cnt, fail_cnt);
        if(fail_cnt==0) $display("*** ALL TESTS PASSED - RS(12,6) OK ***");
        else            $display("*** %0d FAILURES ***", fail_cnt);
        $finish;
    end

    initial begin #500000; $display("TIMEOUT"); $finish; end

    initial begin
        $dumpfile("rs_12_6.vcd");
        $dumpvars(0, rs_tb);
    end
endmodule