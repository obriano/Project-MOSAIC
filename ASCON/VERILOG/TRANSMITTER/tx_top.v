module tx_top(
    input  wire        clk,
    input  wire        rst,
    input  wire        start_new_frame,
    input  wire [63:0] plin0,
    input  wire [63:0] plin1,
    output wire [63:0] cyp0,
    output wire [63:0] cyp1,
    output wire [63:0] T_out      
);


    // 1) Frame/message index

    reg [15:0] FrameIndex;
    always @(posedge clk or posedge rst) begin
        if (rst)
            FrameIndex <= 16'd0;
        else if (start_new_frame)
            FrameIndex <= FrameIndex + 16'd1;
    end


    // 2) Free-running timestamp; latched T per frame

    wire [63:0] time_counter;
    timestamp ts_inst (
        .clk(clk),
        .rst(rst),
        .time_counter(time_counter)
    );

    reg [63:0] T;
    always @(posedge clk or posedge rst) begin
        if (rst)
            T <= 64'd0;
        else if (start_new_frame)
            T <= time_counter;     // snapshot counter at frame start
    end
    assign T_out = T;


    // 3) Frame key generation: KDF(K_master, T)

    wire [127:0] frame_key;
    wire         kdf_done;

    frame_key_gen kdf (
        .clk       (clk),
        .rst       (rst),
        .start     (start_new_frame),  // derive new key each frame
        .T         (T),
        .frame_key (frame_key),
        .done      (kdf_done)
    );


    // 4) Split key and nonce for ASCON initialization

    wire [63:0] k0 = frame_key[127:64];
    wire [63:0] k1 = frame_key[63:0];
    wire [63:0] n0 = 64'h0;   // high half of nonce
    wire [63:0] n1 = T;       // low half of nonce

    // ASCON-AEAD IV
    localparam [63:0] ASCON_IV = 64'h00001000808c0001;

    wire [63:0] s0_init, s1_init, s2_init, s3_init, s4_init;

    initialization init_core(
        .IV   (ASCON_IV),
        .k0   (k0),
        .k1   (k1),
        .n0   (n0),
        .n1   (n1),
        .y0   (s0_init),
        .y1   (s1_init),
        .y2   (s2_init),
        .y3   (s3_init),
        .y4   (s4_init),
        .key0 (k0), 
        .key1 (k1)
    );


    // 5) Associated data with timestamp and frame index

    wire [63:0] s0_ad, s1_ad, s2_ad, s3_ad, s4_ad;
    wire [63:0] d0 = T;                          // AD word 0 = T
    wire [63:0] d1 = {48'd0, FrameIndex};        // AD word 1 = FrameIndex
    wire [63:0] d2 = 64'd0;                      // AD word 2 = 0

    associated_data ad_core (
        .x0(s0_init), .x1(s1_init), .x2(s2_init), .x3(s3_init), .x4(s4_init),
        .y0(s0_ad),   .y1(s1_ad),   .y2(s2_ad),   .y3(s3_ad),   .y4(s4_ad),
        .d0(d0), .d1(d1), .d2(d2)
    );


    // 6) Encrypt plaintext (per frame)

    wire [63:0] y0,y1,y2,y3,y4;
    encrypt enc_core (
        .x0   (s0_ad),
        .x1   (s1_ad),
        .x2   (s2_ad),
        .x3   (s3_ad),
        .x4   (s4_ad),
        .y0   (y0),
        .y1   (y1), 
        .y2   (y2),
        .y3   (y3),
        .y4   (y4),
        .pln0(plin0),
        .pln1(plin1),
        .cyp0 (cyp0),
        .cyp1 (cyp1)
    );
    wire [63:0] y0_f,y1_f,y2_f,y3_f,y4_f;
    final final_core(
        .IV(y0),
        .k0(y1),
        .k1(y2),
        .n0(y3),
        .n1(y4),
        .y0(y0_f),
        .y1(y1_f),
        .y2(y2_f),
        .y3(y3_f),
        .y4(y4_f),
        .key0(k0),
        .key1(k1)
    );
wire [63:0] tag0 = y3_f;
wire [63:0] tag1 = y4_f;

endmodule
