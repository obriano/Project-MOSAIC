`timescale 1ns/1ps

module tb_tx_top;

    // inputs
    reg         clk;
    reg         rst;
    reg         start_new_frame;
    reg [63:0]  plin0;
    reg [63:0]  plin1;

    // outputs
    wire [63:0] cyp0;
    wire [63:0] cyp1;
    wire [63:0] T_out;

    // Instantiate the tx top module
    tx_top dut (
        .clk            (clk),
        .rst            (rst),
        .start_new_frame(start_new_frame),
        .plin0          (plin0),
        .plin1          (plin1),
        .cyp0           (cyp0),
        .cyp1           (cyp1),
        .T_out          (T_out)
    );

    initial begin
    $dumpfile("tx_top.vcd");
    $dumpvars(0, tb_tx_top);
end

    // Clock generation: 100 MHz
    initial begin
        clk = 1'b0;
    end

    always #5 clk = ~clk;  // Toggle every 5 ns

    // pulse start_new_frame for exactly 1 clock
    task pulse_start_new_frame;
    begin
        @(negedge clk);
        start_new_frame = 1'b1;
        @(negedge clk);
        start_new_frame = 1'b0;
    end
    endtask

    initial begin
        // Initialize inputs
        rst             = 1'b1;
        start_new_frame = 1'b0;
        plin0           = 64'd0;
        plin1           = 64'd0;

        // Hold reset for a few cycles
        repeat (5) @(negedge clk);
        rst = 1'b0;

        // Wait after reset
        repeat (5) @(negedge clk);

        
        // Frame 0
        
        plin0 = 64'h1111_2222_3333_4444;
        plin1 = 64'hAAAA_BBBB_CCCC_DDDD;
        $display("\n=== Starting Frame 0 ===");
        pulse_start_new_frame();

        repeat (10) @(negedge clk);

        $display("Time %0t | Frame 0:", $time);
        $display("  T_out   = 0x%016h", T_out);
        $display("  cyp0    = 0x%016h", cyp0);
        $display("  cyp1    = 0x%016h", cyp1);

        $display("  FrameIndex = %0d", dut.FrameIndex);
        $display("  tag0    = 0x%016h", dut.tag0);
        $display("  tag1    = 0x%016h", dut.tag1);

        
        // Frame 1 with different plaintext
        
        plin0 = 64'hDEAD_BEEF_0000_0001;
        plin1 = 64'h0123_4567_89AB_CDEF;
        $display("\n=== Starting Frame 1 ===");
        pulse_start_new_frame();

        repeat (10) @(negedge clk);

        $display("Time %0t | Frame 1:", $time);
        $display("  T_out   = 0x%016h", T_out);
        $display("  cyp0    = 0x%016h", cyp0);
        $display("  cyp1    = 0x%016h", cyp1);
        $display("  FrameIndex = %0d", dut.FrameIndex);
        $display("  tag0    = 0x%016h", dut.tag0);
        $display("  tag1    = 0x%016h", dut.tag1);

        // Stop simulation
        $display("\nSimulation finished.");
        #50;
        $stop;
    end


endmodule
