module frame_key_gen (
    input  wire        clk,       
    input  wire        rst,       
    input wire          start,
    input  wire [63:0] T,          // timestamp
    output wire [127:0] frame_key, // derived per-frame key
    output wire         done
);

    // Long-term master key
    localparam [127:0] K_MASTER = 128'hDEADBEEF_00112233_44556677_8899AABB;

    // Ascon-Hash IV;
    localparam [63:0] HASH_IV = 64'h0000080100cc0002;

    // Hash messages: K_master || T = M0,M1,M2
    wire [63:0] M0 = K_MASTER[127:64];
    wire [63:0] M1 = K_MASTER[63:0];
    wire [63:0] M2 = T;

    
    // Step 1: Initialization 
    
    wire [63:0] I0 = HASH_IV;
    wire [63:0] I1 = 64'd0;
    wire [63:0] I2 = 64'd0;
    wire [63:0] I3 = 64'd0;
    wire [63:0] I4 = 64'd0;

    wire [63:0] A0, A1, A2, A3, A4;

    p12 P_INIT (
        .x0(I0),
        .x1(I1),
        .x2(I2),
        .x3(I3),
        .x4(I4),
        .y0(A0),
        .y1(A1),
        .y2(A2),
        .y3(A3),
        .y4(A4)
    );

   
   //Absorb M0
  
    wire [63:0] B0 = A0 ^ M0;
    wire [63:0] B1 = A1;
    wire [63:0] B2 = A2;
    wire [63:0] B3 = A3;
    wire [63:0] B4 = A4;

    wire [63:0] C0, C1, C2, C3, C4;

    p12 P_M0 (
        .x0(B0),
        .x1(B1),
        .x2(B2),
        .x3(B3),
        .x4(B4),
        .y0(C0),
        .y1(C1),
        .y2(C2),
        .y3(C3),
        .y4(C4)
    );

   
     //Absorb M1 
    wire [63:0] D0 = C0 ^ M1;
    wire [63:0] D1 = C1;
    wire [63:0] D2 = C2;
    wire [63:0] D3 = C3;
    wire [63:0] D4 = C4;

    wire [63:0] E0, E1, E2, E3, E4;

    p12 P_M1 (
        .x0(D0),
        .x1(D1),
        .x2(D2),
        .x3(D3),
        .x4(D4),
        .y0(E0),
        .y1(E1),
        .y2(E2),
        .y3(E3),
        .y4(E4)
    );

    
    //Absorb M2  
    
    wire [63:0] F0 = E0 ^ M2;
    wire [63:0] F1 = E1;
    wire [63:0] F2 = E2;
    wire [63:0] F3 = E3;
    wire [63:0] F4 = E4;

    wire [63:0] H0, H1, H2, H3, H4;

    p12 P_M2 (
        .x0(F0),
        .x1(F1),
        .x2(F2),
        .x3(F3),
        .x4(F4),
        .y0(H0),
        .y1(H1),
        .y2(H2),
        .y3(H3),
        .y4(H4)
    );

    assign frame_key = {H1, H0}; // 128-bit key from 2×64-bit words
    assign done = 1'b1;
endmodule
